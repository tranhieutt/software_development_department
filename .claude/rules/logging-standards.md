---
scope: global
---

# Logging & Observability Standards

Applies to: logging, metrics, traces, audit events, and operational diagnostics.

## Core Principles

- Logs exist for humans to debug and for machines to alert — serve both audiences
- Every log entry must answer: **what happened, when, where, to whom, and why**
- Structured logging (JSON) is mandatory — no unstructured text logs in production
- Log at the right level — too verbose is as useless as too silent

## Log Levels

| Level | When to Use | Example |
|-------|------------|---------|
| **TRACE** | Ultra-verbose internal details, disabled in production | Variable values at each step of an algorithm |
| **DEBUG** | Development diagnostics, disabled by default in production | SQL query text, cache hit/miss, function entry/exit |
| **INFO** | Normal business events that indicate system is working | User logged in, order created, scheduled job started |
| **WARN** | Unexpected but recoverable — system continues but attention needed | Retry attempt, deprecated API usage, high memory usage |
| **ERROR** | Operation failed, user/system impacted, needs investigation | Database connection failed, payment processing error |
| **FATAL** | Process cannot continue, immediate shutdown required | Corrupted config, out of memory, unhandled exception |

## Structured Log Format

Every log entry must be a JSON object with these required fields:

```json
{
  "timestamp": "2025-01-15T10:30:00.000Z",
  "level": "ERROR",
  "message": "Failed to process payment",
  "service": "payment-service",
  "requestId": "req_abc123",
  "userId": "user_xyz",
  "duration_ms": 1523,
  "error": {
    "code": "PAYMENT_GATEWAY_TIMEOUT",
    "message": "Gateway did not respond within 5000ms"
  },
  "context": {
    "orderId": "order_456",
    "amount": 99.99,
    "currency": "USD"
  }
}
```

### Required Fields
- `timestamp` — ISO 8601 format with milliseconds, UTC timezone
- `level` — uppercase log level
- `message` — human-readable description of the event
- `service` — name of the service/module generating the log

### Optional but Recommended
- `requestId` — unique request identifier for tracing across services
- `userId` — authenticated user (if applicable)
- `duration_ms` — elapsed time for operations
- `error` — structured error object (code + message)
- `context` — additional domain-specific data

## What to Log

### Always Log
- API requests and responses (method, path, status, duration)
- Authentication events (login, logout, token refresh, failed auth)
- External service calls (endpoint, status, duration, attempt number)
- Database queries that exceed latency threshold (> 100ms)
- Configuration changes at startup
- Background job execution (start, complete, fail)

### Never Log
- Passwords, tokens, API keys, secrets (see `secrets-config.md`)
- Full credit card numbers, SSNs, or other PII
- Request/response bodies containing sensitive data (log only sanitized summaries)
- Raw SQL queries with user-supplied values (use parameterized query logging)

### Log with Caution (Sanitize)
- User input — truncate and strip control characters
- Email addresses — mask middle portion (`j***@example.com`)
- IP addresses — may need masking in GDPR jurisdictions
- File paths — log filename only, not full server path

## Request Tracing

- Every incoming request must receive a unique `requestId` (generate if not provided by caller)
- Propagate `requestId` across all downstream service calls via headers
- Include `requestId` in every log entry generated during that request
- For distributed tracing, use OpenTelemetry `traceparent` header format

## Metrics & Health Checks

- Expose a `/health` endpoint returning service status and dependency checks
- Expose a `/metrics` endpoint in Prometheus format (or project-standard)
- Track these baseline metrics:
  - Request rate (requests/second)
  - Error rate (errors/second, by status code)
  - Latency percentiles (p50, p95, p99)
  - Active connections
  - Queue depth (if applicable)
- Set alerting thresholds: error rate > 1%, p99 latency > 2s, queue depth > 1000

## Log Rotation & Retention

- Rotate log files by size (max 100MB) or time (daily)
- Retain application logs for 30 days minimum
- Retain audit/security logs for 90 days minimum (or per compliance requirement)
- Compress rotated logs
- Never store logs only on the local filesystem — ship to centralized log aggregation

## Forbidden Patterns

- `console.log("here")` — unstructured debug output left in code
- `console.log(JSON.stringify(data))` — unstructured serialization of entire objects
- Logging inside tight loops (batch or sample instead)
- Logging the same message repeatedly in a hot path (use sampling or rate limiting)
- Using `console.log` for production logging — use a structured logging library (winston, pino, bunyan)
