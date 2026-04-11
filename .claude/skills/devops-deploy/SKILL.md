---
name: devops-deploy
description: "Executes infrastructure deployment operations including Docker, CI/CD, AWS Lambda, SAM, Terraform, and GitHub Actions. Use when dockerizing applications, configuring CI/CD pipelines, or deploying to cloud infrastructure."
paths: ["**/Dockerfile*", "**/k8s/**", "**/infra/**", "**/.github/workflows/**", "**/template.yaml"]
effort: 3
argument-hint: "[target: docker|lambda|k8s|terraform|github-actions]"
user-invocable: true
when_to_use: "When dockerizing applications, configuring CI/CD pipelines, deploying to AWS, or setting up infrastructure as code"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# DevOps Deploy

## Production checklist (always verify)

- [ ] Env vars via Secrets Manager — never hardcoded
- [ ] Health check endpoint responding
- [ ] Structured JSON logs with `request_id`
- [ ] Rate limiting configured
- [ ] CORS restricted to authorized domains
- [ ] Lambda timeout appropriate (10–30s)
- [ ] CloudWatch alarms for errors and latency
- [ ] Rollback plan documented
- [ ] Load test before launch

## Docker: multi-stage Python

```dockerfile
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8000/health || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Docker Compose (local dev)

```yaml
services:
  app:
    build: .
    ports: ["8000:8000"]
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    volumes:
      - .:/app
    depends_on: [db, redis]
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: app
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
  redis:
    image: redis:7-alpine
volumes:
  pgdata:
```

## SAM template (Lambda + DynamoDB)

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Globals:
  Function:
    Timeout: 30
    Runtime: python3.11
    Environment:
      Variables:
        DYNAMODB_TABLE: !Ref AppTable

Resources:
  AppFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/
      Handler: lambda_function.handler
      MemorySize: 512
      Policies:
        - DynamoDBCrudPolicy:
            TableName: !Ref AppTable

  AppTable:
    Type: AWS::DynamoDB::Table
    Properties:
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: userId
          AttributeType: S
      KeySchema:
        - AttributeName: userId
          KeyType: HASH
      TimeToLiveSpecification:
        AttributeName: ttl
        Enabled: true
```

```bash
# SAM commands
sam build
sam deploy --guided          # first time (creates samconfig.toml)
sam deploy                   # subsequent
sam deploy --no-confirm-changeset --no-fail-on-empty-changeset
sam logs -n AppFunction --tail
```

## GitHub Actions: test + security + deploy

```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.11" }
      - run: pip install -r requirements.txt
      - run: pytest tests/ -v --cov=src --cov-report=xml

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pip install bandit safety
      - run: bandit -r src/ -ll
      - run: safety check -r requirements.txt

  deploy:
    needs: [test, security]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/setup-sam@v2
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - run: sam build
      - run: sam deploy --no-confirm-changeset
```

## Health check endpoint (FastAPI)

```python
import time, os
from fastapi import FastAPI

app = FastAPI()
START_TIME = time.time()

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "uptime_seconds": time.time() - START_TIME,
        "version": os.environ.get("APP_VERSION", "unknown"),
    }
```

## CloudWatch alarm (Python)

```python
import boto3

def create_error_alarm(function_name: str, sns_topic_arn: str):
    cw = boto3.client("cloudwatch")
    cw.put_metric_alarm(
        AlarmName=f"{function_name}-errors",
        MetricName="Errors",
        Namespace="AWS/Lambda",
        Dimensions=[{"Name": "FunctionName", "Value": function_name}],
        Period=300, EvaluationPeriods=1, Threshold=5,
        ComparisonOperator="GreaterThanThreshold",
        AlarmActions=[sns_topic_arn],
        TreatMissingData="notBreaching",
    )
```
