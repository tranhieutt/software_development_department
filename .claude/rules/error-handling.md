---
scope: global
---

# Error Handling Strategy

Applies to: runtime code paths that create, handle, log, or surface errors.

## Core Principles

- Errors are not exceptions to be hidden — they are expected outcomes that must be handled explicitly
- Every error must provide enough context for a developer to diagnose the issue without reading source code
- Fail fast in development; fail safely in production
- Never swallow errors silently — log, propagate, or handle with explicit intent

## Error Classification

| Category | Description | Action |
|----------|-------------|--------|
| **User Error** | Invalid input, missing fields, unauthorized access | Return 4xx with descriptive message |
| **System Error** | Database down, network timeout, out of memory | Return 5xx, log with full context, alert |
| **Business Logic Error** | Insufficient balance, duplicate entry, constraint violation | Return domain-specific error code + message |
| **Programming Error** | Null reference, type mismatch, assertion failure | Return 5xx, log stack trace, fix in code |

## Throw vs Return

- **Throw** for programming errors and unrecoverable system failures (let the global handler catch)
- **Return error result** for expected business logic failures that the caller should handle
- **Never throw** across module boundaries for recoverable conditions — return a Result type instead

## Error Types

- Define a base application error class with: `code`, `message`, `statusCode`, `isOperational`, `cause`
- `isOperational: true` = expected failure (safe to show to user)
- `isOperational: false` = programming bug (show generic message, log details server-side)
- Extend base error for each domain: `ValidationError`, `AuthenticationError`, `NotFoundError`, `ConflictError`

## Global Error Handler

- One centralized error handler middleware (not scattered try/catch blocks)
- Handler must: classify error → format response → log structured entry → emit metrics
- Unhandled promise rejections and uncaught exceptions must be caught and trigger graceful shutdown
- Never let the process continue after an unhandled programming error

## Logging Errors

- Every logged error must include: `timestamp`, `error.code`, `error.message`, `stack`, `requestId`, `userId` (if available)
- User errors (4xx) logged at WARN level
- System errors (5xx) logged at ERROR level
- Programming errors logged at FATAL level with full stack trace
- Never log sensitive data in error messages (passwords, tokens, PII)

## Retry & Recovery

- Transient errors (network timeout, 503, 429) may be retried with exponential backoff
- Non-transient errors (400, 401, 404) must NOT be retried
- All retry attempts must be logged with attempt number
- Circuit breaker pattern for external dependencies (see `network-code.md`)

## Validation Errors

- Return ALL validation failures at once, not one at a time
- Include field name, rejected value (sanitized), and reason for each failure
- Use consistent format: `{ field: "email", message: "Invalid email format", value: "***" }`

## Error Response Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "reason": "Invalid email format" },
      { "field": "age", "reason": "Must be a positive integer" }
    ],
    "requestId": "req_abc123"
  }
}
```

## Forbidden Patterns

- `catch (e) {}` — empty catch block (swallowing errors)
- `catch (e) { console.log(e) }` — unstructured logging without propagation
- `throw new Error("error")` — generic error without code or context
- Using HTTP status codes as business logic error codes (use domain codes instead)
- Exposing internal error details (stack traces, SQL queries) to API consumers
