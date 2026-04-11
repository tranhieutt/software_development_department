---
name: aws-serverless
type: reference
description: "Provides AWS serverless architecture patterns for Lambda, API Gateway, DynamoDB, SQS, and SAM/CDK. Use when working with AWS serverless files (serverless.yml, CDK stacks) or when the user mentions Lambda, API Gateway, serverless, or AWS SAM."
paths: ["**/serverless.yml", "**/template.yaml", "**/cdk/**", "**/sam/**"]
effort: 3
allowed-tools: Read, Glob, Grep
user-invocable: true
when_to_use: "When building or deploying serverless applications on AWS with Lambda, API Gateway, DynamoDB, or SAM/CDK"
---

# AWS Serverless

## Critical rules (non-obvious)

- **Initialize clients OUTSIDE handler** — Lambda reuses execution environments across invocations; creating clients inside costs 100-500ms per cold start
- **`context.callbackWaitsForEmptyEventLoop = false`** — prevents Node.js from hanging on open async handles (DB connections, etc.)
- **SQS `VisibilityTimeout` = 6× Lambda timeout** — if Lambda takes 30s, set 180s; otherwise messages return to queue mid-processing
- **`FunctionResponseTypes: [ReportBatchItemFailures]`** — partial batch failure; without this, any single failure retries the entire batch
- **Never use `*` in `Access-Control-Allow-Origin` with `credentials: true`** — browsers block it; use explicit origin

## Lambda handler pattern

```javascript
// Initialize once (reused across invocations = faster after cold start)
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");

const docClient = DynamoDBDocumentClient.from(new DynamoDBClient({}));

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;  // don't hang on open handles
  try {
    const body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
    const result = await docClient.send(new GetCommand({
      TableName: process.env.TABLE_NAME,
      Key: { id: body.id },
    }));
    return { statusCode: 200, headers: { "Content-Type": "application/json" }, body: JSON.stringify(result.Item) };
  } catch (err) {
    console.error(JSON.stringify({ error: err.message, requestId: context.awsRequestId }));
    return { statusCode: err.statusCode ?? 500, body: JSON.stringify({ error: err.message }) };
  }
};
```

## SAM template: HTTP API + DynamoDB

```yaml
# template.yaml
AWSTemplateFormatVersion: "2010-09-09"
Transform: AWS::Serverless-2016-10-31

Globals:
  Function:
    Runtime: nodejs20.x
    Timeout: 30
    MemorySize: 256
    Environment:
      Variables:
        TABLE_NAME: !Ref ItemsTable

Resources:
  HttpApi:
    Type: AWS::Serverless::HttpApi
    Properties:
      CorsConfiguration:
        AllowOrigins: ["https://yourdomain.com"]  # never * with credentials
        AllowMethods: [GET, POST, DELETE]
        AllowHeaders: ["*"]

  GetItemFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler: src/handlers/get.handler
      Events:
        GetItem:
          Type: HttpApi
          Properties:
            ApiId: !Ref HttpApi
            Path: /items/{id}
            Method: GET
      Policies:
        - DynamoDBReadPolicy:
            TableName: !Ref ItemsTable

  ItemsTable:
    Type: AWS::DynamoDB::Table
    Properties:
      AttributeDefinitions:
        - AttributeName: id
          AttributeType: S
      KeySchema:
        - AttributeName: id
          KeyType: HASH
      BillingMode: PAY_PER_REQUEST

Outputs:
  ApiUrl:
    Value: !Sub "https://${HttpApi}.execute-api.${AWS::Region}.amazonaws.com"
```

## SQS async processing with partial batch failure

```yaml
# In template.yaml
ProcessorFunction:
  Type: AWS::Serverless::Function
  Properties:
    Events:
      SQSEvent:
        Type: SQS
        Properties:
          Queue: !GetAtt ProcessingQueue.Arn
          BatchSize: 10
          FunctionResponseTypes:
            - ReportBatchItemFailures  # critical: retry only failed items

ProcessingQueue:
  Type: AWS::SQS::Queue
  Properties:
    VisibilityTimeout: 180  # 6x Lambda timeout (30s)
    RedrivePolicy:
      deadLetterTargetArn: !GetAtt DeadLetterQueue.Arn
      maxReceiveCount: 3

DeadLetterQueue:
  Type: AWS::SQS::Queue
  Properties:
    MessageRetentionPeriod: 1209600  # 14 days
```

```javascript
// Handler with partial batch failure reporting
exports.handler = async (event) => {
  const batchItemFailures = [];
  for (const record of event.Records) {
    try {
      await processMessage(JSON.parse(record.body));
    } catch (err) {
      console.error(`Failed ${record.messageId}:`, err.message);
      batchItemFailures.push({ itemIdentifier: record.messageId });
    }
  }
  return { batchItemFailures };  // only failed items are retried
};
```

## Sharp edges

| Issue | Severity | Fix |
|---|---|---|
| Cold start > 1s | High | Move SDK init outside handler; use `--no-install-suggests` in Docker layers |
| Timeout without response | High | Always set explicit timeout < Lambda timeout in downstream calls |
| Memory = CPU allocation | High | 1792MB = 1 full vCPU; increase memory for CPU-bound tasks |
| VPC cold start adds 1-10s | Medium | Use VPC Endpoints instead of public NAT to reduce ENI setup |
| Infinite Lambda→SQS loop | High | Never write to same SQS queue that triggers Lambda without a dead-letter |
| S3 trigger infinite loop | High | Use separate source/destination buckets or prefix filters |

## Commands

```bash
sam build
sam local invoke GetItemFunction --event events/get-item.json
sam local start-api    # local API Gateway emulation
sam deploy --guided    # first deploy (creates samconfig.toml)
sam deploy             # subsequent deploys
```
