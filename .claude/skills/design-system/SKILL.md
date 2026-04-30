---
name: design-system
type: reference
description: "Decomposes a product concept into architectural components, domain systems, data models, and integration boundaries. Use when starting system architecture or when the user mentions system design or component breakdown."
effort: 3
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
when_to_use: "When designing system architecture, defining domain boundaries, or creating a component breakdown for a new product or feature"
---

# System Design

## Phase 1: Clarify requirements (always do this first)

Ask before designing:
1. **Scale**: How many users/requests/day? Read-heavy or write-heavy?
2. **Consistency**: Strong (banking) or eventual (social feed)?
3. **Availability target**: 99.9% (8.7h/yr downtime) or 99.99% (52min/yr)?
4. **Latency budget**: p99 < 100ms? < 1s?
5. **Geography**: Single region or multi-region?

## Capacity estimation shortcuts

```
1M users/day active → ~12 req/s avg, ~120 req/s peak (10x)
1KB per request → 1M req/day = ~1GB/day = ~365GB/year
Read:write ratio 10:1 (typical social) → optimize read path first
1 server handles ~1000 req/s (rule of thumb for I/O-bound services)
```

## Component breakdown template

```
Client layer  → Web / Mobile / API consumers
CDN           → Static assets, edge caching
API Gateway   → Rate limiting, auth, routing, SSL termination
Services      → Domain-specific services (User, Order, Payment, Notification)
Cache         → Redis for hot data (sessions, rate limits, computed results)
Database      → Primary DB + Read replicas
Message queue → Async operations, event-driven decoupling
Storage       → Object storage for files (S3/GCS)
Monitoring    → Metrics, logs, traces, alerts
```

## Database selection guide

| Need | Choose |
|---|---|
| ACID transactions, relations | PostgreSQL |
| High-scale document store | MongoDB |
| Key-value, cache, pub/sub | Redis |
| Time-series data | TimescaleDB / InfluxDB |
| Graph relationships | Neo4j |
| Full-text search | Elasticsearch |
| Analytical/OLAP | ClickHouse / BigQuery |

## Caching strategies

```
Cache-aside (read):  App checks cache → miss → DB → write to cache
Write-through:        Write to cache AND DB simultaneously (consistent, slower writes)
Write-behind:         Write to cache → async flush to DB (fast writes, risk of loss)
Read-through:         Cache handles DB reads automatically

TTL guidelines:
- Sessions: 15-30 min
- User profile: 5 min
- Product catalog: 1 hour
- Config/settings: 24 hours
```

## Message queue patterns

```
When to use queues:
✓ Async processing (email, PDF generation, notifications)
✓ Rate-limiting downstream services
✓ Decoupling services (order → payment → shipping)
✓ Fan-out (1 event → multiple consumers)

Queue selection:
- RabbitMQ: complex routing, request-reply, low latency
- Kafka: high throughput, event log/replay, stream processing
- SQS: managed, simple, AWS-native, at-least-once delivery
- Redis Streams: lightweight, same infra as cache
```

## API design decisions

```
REST:    Standard CRUD, simple clients, team familiarity (default choice)
GraphQL: Multiple clients with different data needs, reduce over-fetching
gRPC:    Internal service-to-service, binary protocol, streaming needed
WebSocket: Real-time bidirectional (chat, live updates, collaborative tools)
```

## Scaling patterns

```
Vertical (scale up):   More CPU/RAM — quick, limited ceiling
Horizontal (scale out): More instances — requires stateless services
Database read replicas: Offload read traffic (good for 80%+ read workloads)
Database sharding:      Shard by user_id, geography — last resort, complex
CQRS:                   Separate read/write models — when read/write patterns diverge heavily
```

## Common design mistakes

| Mistake | Better approach |
|---|---|
| Over-engineering for scale you don't have | Start monolith, extract services at clear pain points |
| Synchronous calls to all dependencies | Use async queues for non-critical paths |
| No caching strategy | Cache at API layer + DB query results |
| Storing sessions in DB | Use Redis; DB sessions don't scale horizontally |
| Single point of failure | Redundancy at every critical layer |
