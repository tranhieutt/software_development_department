---
name: devops-deploy
type: workflow
description: "Designs and executes CI/CD pipelines, GitOps workflows, deployment automation, and cloud infrastructure deployment including Docker, AWS Lambda, SAM, Terraform, and GitHub Actions. Use when building or improving CI/CD pipelines, containerizing applications, creating deployment runbooks, or deploying to cloud infrastructure."
paths: ["**/Dockerfile*", "**/k8s/**", "**/infra/**", "**/.github/workflows/**", "**/template.yaml", "**/deploy/**"]
effort: 3
argument-hint: "[target: docker|lambda|k8s|terraform|github-actions|pipeline|runbook]"
user-invocable: true
when_to_use: "When dockerizing applications, configuring CI/CD pipelines, deploying to AWS, setting up infrastructure as code, designing GitOps workflows, or creating deployment runbooks"
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

## Pipeline Design

### Standard Pipeline Stages

```
[Build] -> [Test] -> [Security Scan] -> [Package] -> [Deploy Staging] -> [Integration Test] -> [Approval] -> [Deploy Prod] -> [Verify]
```

| Stage | Actions | Failure Policy |
|-------|---------|----------------|
| Build | Compile, lint, type-check | Block |
| Test | Unit + integration tests | Block |
| Security | SAST, dependency scan, container scan | Block on Critical/High |
| Package | Docker build, push to registry, sign image | Block |
| Deploy Staging | Apply manifests/Helm, run smoke tests | Block |
| Approval | Manual gate for production | Require approval |
| Deploy Prod | Progressive rollout | Auto-rollback on failure |
| Verify | Health checks, metrics validation | Auto-rollback |

### Deployment Strategy Selection

| Strategy | Zero-downtime | Rollback Speed | Resource Cost | Use When |
|----------|---------------|----------------|---------------|----------|
| Rolling Update | Yes | Slow (redeploy) | Low | Default for most services |
| Blue/Green | Yes | Instant (switch) | 2x | Critical services, DB-independent |
| Canary | Yes | Fast (shift) | 1.1x | High-traffic, need real-user validation |

### GitOps Repository Structure

```
app-repo/           # Application source code + Dockerfile
env-repo/           # Environment configs
  base/             # Base manifests
  overlays/
    dev/
    staging/
    prod/
```

Tools: ArgoCD or Flux v2 · Kustomize or Helm · External Secrets Operator

### Security Scanning in Pipeline

- SAST: CodeQL, Semgrep, SonarQube
- Dependency: Snyk, Dependabot, npm audit
- Container: Trivy, Grype
- Secrets: GitLeaks, TruffleHog
- SBOM: Syft · Image signing: Cosign

### DORA Metrics to Track

- Deployment frequency
- Lead time for changes
- Change failure rate
- Mean time to recovery (MTTR)

---

## Deployment Runbook Principles

### Platform Selection

```
What are you deploying?
├── Static site → Vercel, Netlify, Cloudflare Pages
├── Simple web app → Railway, Render, Fly.io / VPS + PM2
├── Microservices → Container orchestration
└── Serverless → Edge functions, Lambda
```

| Platform | Deployment Method | Rollback |
|----------|------------------|---------|
| Vercel/Netlify | Git push, auto-deploy | Redeploy previous commit |
| Railway/Render | Git push or CLI | Dashboard rollback |
| VPS + PM2 | SSH + manual steps | Restore backup, restart |
| Docker | Image push + orchestration | Previous image tag |
| Kubernetes | kubectl apply | kubectl rollout undo |

### 5-Phase Deployment Process

```
1. PREPARE  → Verify code, build, env vars
2. BACKUP   → Save current state before changing
3. DEPLOY   → Execute with monitoring open
4. VERIFY   → Health check, logs, key flows
5. CONFIRM or ROLLBACK
```

### Verification Window

- First 5 min: Active monitoring
- 15 min: Confirm stable
- 1 hour: Final verification
- Next day: Review metrics

### Rollback Decision

| Symptom | Action |
|---------|--------|
| Service down | Rollback immediately |
| Critical errors | Rollback |
| Performance >50% degraded | Consider rollback |
| Minor issues | Fix forward if quick |

Rollback principles: Speed over perfection → Communicate → Post-mortem after stable.

### Anti-Patterns

| ❌ Don't | ✅ Do |
|----------|-------|
| Deploy on Friday | Deploy early in week |
| Skip staging | Always test first |
| Deploy without backup | Backup before deploy |
| Walk away after deploy | Monitor for 15+ min |
| Multiple changes at once | One change at a time |

---

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
