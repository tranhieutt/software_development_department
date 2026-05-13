---
paths:
  - "src/networking/**"
  - "src/http/**"
  - "src/clients/**"
  - "src/services/**"
---

# Network Code Rules

Applies to: HTTP clients, service calls, webhooks, retries, and external network integrations.

## General Principles

- Server is AUTHORITATIVE for all business-critical state — never trust the client
- All network communication must be explicitly versioned for forward/backward compatibility
- Handle connection failures, timeouts, and retries gracefully — network is unreliable by default
- Rate-limit all network logging to prevent log flooding

## HTTP Client Standards

- Use a centralized HTTP client module — no direct `fetch`/`axios` scattered across codebase
- All HTTP requests must have explicit timeouts (connect timeout + read timeout)
- All HTTP clients must implement retry with exponential backoff for transient errors (5xx, 429, network timeout)
- Max retry count and backoff intervals must be configurable
- Never retry non-idempotent operations (POST, PATCH) without idempotency keys
- Connection pooling must be configured for high-throughput services

## Error Handling

- Classify network errors: transient (retry-safe) vs permanent (fail-fast)
- Timeout errors must include the timeout value and endpoint in the error message
- Distinguish between DNS failure, connection refused, TLS error, read timeout, and server error
- All network errors must be logged with: endpoint, method, status code, latency, attempt number

## Resilience Patterns

- Implement circuit breaker for external service calls (open after N consecutive failures, half-open after cooldown)
- Define SLA per external dependency (expected latency, availability target)
- Fallback behavior must be defined when external service is unavailable
- Health checks for all external dependencies at startup and periodically

## Security

- Validate all incoming response sizes before processing
- TLS required for all external communication — no plaintext HTTP in production
- Certificate pinning for critical external services
- Validate Content-Type headers on responses before parsing
- Never follow HTTP redirects automatically for non-GET requests

## Performance & Observability

- Define and track per-request latency budgets
- All network calls must emit structured logs: `{ method, url, status, duration_ms, attempt }`
- Distributed tracing headers (`traceparent`, `trace-id`) must be propagated across service calls
- DNS resolution must be cached with appropriate TTL
