---
name: backend-architect
description: "Designs scalable backend architectures covering microservices, event-driven systems, API gateways, and data stores. Use when designing a backend system or when the user mentions backend architecture, scalability, or distributed systems."
paths: ["**/src/**/*.ts", "**/src/**/*.js", "**/package.json"]
effort: 5
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
argument-hint: "[project description or requirements]"
user-invocable: true
when_to_use: "When designing new backend services, defining service boundaries, or planning scalable API architecture"
---

# Backend Architect

## Workflow

1. **Capture requirements**: Domain context, use cases, NFRs (scale, latency, consistency)
2. **Define service boundaries**: DDD bounded contexts, service decomposition
3. **Design API contracts**: REST/GraphQL/gRPC with versioning strategy
4. **Plan communication**: Sync (REST, gRPC) vs async (queues, events)
5. **Build in resilience**: Circuit breakers, retries, timeouts, graceful degradation
6. **Design observability**: structured logging, RED metrics, distributed tracing
7. **Security**: Auth/Z strategy, rate limiting, secrets management
8. **Caching**: Layer strategy (app → API → CDN) with invalidation plan
9. **Document**: Service diagram (Mermaid), ADRs, trade-offs

## API design decision matrix

| Use case | Protocol | Reason |
|---|---|---|
| Standard CRUD API | REST | Widest tooling support |
| Client queries complex data | GraphQL | Reduces over-fetching |
| Internal service-to-service | gRPC | Typed contracts, low latency |
| Real-time bidirectional | WebSocket | Full duplex |
| Server push (one-way) | SSE | Simpler than WS for unidirectional |
| High-volume async work | SQS/Kafka | Decoupling, retry, backpressure |

## Service boundary rules (non-obvious)

- **Bounded context = 1 database** — shared DB across services creates hidden coupling; eventual consistency is the price of independence
- **Sync calls create latency chains** — A → B → C means P99(A) = P99(A) + P99(B) + P99(C); use async for non-blocking flows
- **Saga over 2PC** — distributed transactions via saga (choreography or orchestration); 2PC blocks and creates distributed deadlocks
- **Stateless for horizontal scale** — session state in Redis/DynamoDB, not in memory
- **Database per service, not schema per service** — separate schemas in shared DB = shared schema migrations = coupling still exists

## Resilience patterns (always include these)

```
Circuit Breaker: CLOSED → [failures > threshold] → OPEN → [timeout] → HALF-OPEN → [success] → CLOSED
Retry: exponential backoff with jitter — base_delay * 2^attempt + random(0, base_delay)
Timeout: always set; propagate deadline via context/headers
Bulkhead: separate thread pools per dependency; one slow dep shouldn't starve others
Idempotency: every mutating operation needs idempotency key; store result, return on duplicate
```

## Observability essentials

```
Logs:  structured JSON, always include: traceId, userId, duration, status
Metrics (RED): Rate (req/s), Errors (%), Duration (p50/p95/p99)
Traces: OpenTelemetry → Jaeger/Tempo; trace every cross-service call
Alerts: error rate > 1%, p99 latency > SLO, queue depth > threshold
```

## Caching strategy

| Layer | Tool | Pattern | Invalidation |
|---|---|---|---|
| App | Redis | Cache-aside | TTL + event-driven |
| API | CDN (CloudFront) | Read-through | Cache-Control headers |
| DB reads | Read replica | Direct query | N/A (replica lag) |

Cache-aside rule: **read → cache miss → DB → cache set → return**. Never write to cache directly on writes — let TTL or event invalidate.

## Auth patterns

- **User auth**: OAuth2 + OIDC, JWT access token (15 min TTL) + refresh token (7 days, rotated)  
- **Service-to-service**: mTLS or signed JWT with short expiry; never share user tokens between services
- **API keys**: Hash on storage (SHA-256), include key prefix in metadata for lookup

## Deliver

- Service diagram (Mermaid) showing communication patterns + boundaries
- API contract excerpt (OpenAPI or Protobuf)
- Auth/Z strategy
- Resilience patterns per dependency
- Caching plan with invalidation strategy
- Tech recommendations with explicit rationale
- ADR for each major decision

## Scope boundaries

- Database schema design → `database-architect`
- Infrastructure + cloud services → `cloud-architect`
- Comprehensive security audit → `security-auditor`
- System-wide performance optimization → `performance-engineer`
