---
name: database-architect
type: workflow
description: "Designs relational and NoSQL database schemas, indexing strategies, migration plans, and data modeling patterns. Use when designing a database or when the user mentions database architecture, schema design, or data modeling."
effort: 5
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
argument-hint: "[project type or tech stack]"
user-invocable: true
when_to_use: "When selecting database technologies, designing schemas from scratch, or planning data layer migrations"
---

# Database Architect

## Workflow

1. **Understand domain**: Access patterns, scale targets, consistency needs, compliance requirements
2. **Select technology**: Match DB type to workload (see matrix below)
3. **Design schema**: Normalization level, relationships, constraints, temporal data strategy
4. **Plan indexing**: Query-pattern-driven index design (not speculative)
5. **Design caching**: Layer strategy with invalidation
6. **Plan migration**: Zero-downtime approach, rollback procedures
7. **Document decisions**: ADR with rationale and trade-offs

## Technology selection matrix

| Workload | Primary choice | Alternative |
|---|---|---|
| OLTP / relational | PostgreSQL | MySQL |
| Flexible documents | MongoDB | Firestore |
| Key-value / cache | Redis | DynamoDB |
| Time-series / IoT | TimescaleDB | InfluxDB |
| Analytical / OLAP | ClickHouse | BigQuery |
| Graph relationships | Neo4j | Amazon Neptune |
| Full-text search | Elasticsearch | Meilisearch |
| Globally distributed | CockroachDB | Google Spanner |
| Multi-tenant SaaS | PostgreSQL (row-level security) | Schema-per-tenant |

**Decision rule**: Choose PostgreSQL by default; deviate only when access patterns demand it with documented rationale.

## Non-obvious rules

- **Normalize first, denormalize with evidence** â€” premature denormalization creates update anomalies; measure before optimizing
- **Index on access patterns, not columns** â€” index the query, not the table; one slow-query explain plan is worth more than any speculation
- **Foreign keys always** â€” letting the application enforce referential integrity is a data corruption waiting to happen
- **JSONB for flexible attributes, not as a schema escape hatch** â€” use JSONB when fields are genuinely variable; not to avoid schema discipline
- **Partition late** â€” partition tables only once you have row counts >50M or explicit I/O pressure; early partitioning adds complexity with zero benefit
- **UUID v7 over v4** â€” v7 is time-ordered (k-sortable), avoids index fragmentation, same uniqueness guarantees

## Schema design patterns

```sql
-- Multi-tenancy: row-level security (best for <1000 tenants, shared infra)
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON orders
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- Soft delete + audit trail (never DELETE production data)
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN updated_by UUID REFERENCES users(id);
CREATE INDEX idx_users_active ON users(id) WHERE deleted_at IS NULL;

-- Temporal / slowly-changing dimensions
CREATE TABLE product_prices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id),
  price NUMERIC(10,2) NOT NULL,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  valid_until TIMESTAMPTZ  -- NULL = current price
);
```

## Indexing rules

```sql
-- Composite index: most selective column FIRST
CREATE INDEX idx_orders_user_status ON orders(user_id, status, created_at DESC);

-- Partial index: filter out the 95% noise
CREATE INDEX idx_orders_pending ON orders(created_at) WHERE status = 'pending';

-- Covering index: index-only scan (no heap access)
CREATE INDEX idx_users_email_name ON users(email) INCLUDE (name, avatar_url);

-- JSONB GIN index for flexible attribute queries
CREATE INDEX idx_metadata_gin ON events USING gin(metadata jsonb_path_ops);
```

## Migration strategy (non-negotiable steps)

```sql
-- 1. Expand: add new column nullable (no lock)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- 2. Backfill: batch update (never one giant UPDATE)
UPDATE users SET phone = '' WHERE phone IS NULL AND id BETWEEN x AND y;

-- 3. Constrain: add NOT NULL only after backfill complete
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;

-- 4. Switch: deploy code using new column
-- 5. Contract: drop old column in separate release
ALTER TABLE users DROP COLUMN old_phone;
```

**Zero-downtime rule**: Never add a NOT NULL column without a default in a single migration on a live table â€” it acquires an ACCESS EXCLUSIVE lock.

## Caching architecture

| Layer | Tool | Strategy | Invalidation |
|---|---|---|---|
| Hot data | Redis | Cache-aside | TTL + event-driven |
| Query results | PostgreSQL materialized views | Refresh on schedule | `REFRESH MATERIALIZED VIEW CONCURRENTLY` |
| Session data | Redis | Write-through | TTL |
| Static references | App memory | Eager load on startup | Deploy |

## Scope

- Query tuning on existing system â†’ `database-optimizer`
- Database operations, backups, maintenance â†’ `database-admin`
- System-wide performance â†’ `performance-engineer`
- ORM-specific patterns â†’ `prisma-expert` / `drizzle-orm-expert`
