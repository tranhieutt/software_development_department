---
name: sql-optimization-patterns
type: reference
description: "Provides SQL optimization patterns for query performance, indexing strategies, schema design, and database tuning. Use when optimizing slow queries, designing indexes, or tuning database performance."
paths: ["**/*.sql", "**/migrations/**"]
effort: 3
allowed-tools: Read, Glob, Grep, Bash
user-invocable: true
when_to_use: "When optimizing slow SQL queries, designing indexes, or tuning database performance"
---

# SQL Optimization Patterns

Query optimization, indexing, and performance tuning for PostgreSQL, MySQL, and SQLite.

## Index Strategy

### When to Create Index
\`\`\`sql
-- High selectivity columns (many unique values)
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Composite index: order matters (equality first, then range)
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at DESC);

-- Covering index (includes all needed columns)
CREATE INDEX idx_orders_covering ON orders(user_id, status) INCLUDE (total, created_at);
\`\`\`

### When NOT to Index
- Low cardinality columns (boolean, status with few values)
- Small tables (< 1000 rows)
- Write-heavy tables with rare reads

## Query Patterns

### Avoid SELECT *
\`\`\`sql
-- Bad
SELECT * FROM orders WHERE user_id = 1;

-- Good (select only needed columns)
SELECT id, total, status FROM orders WHERE user_id = 1;
\`\`\`

### Avoid N+1 (use JOIN or subquery)
\`\`\`sql
-- Bad: N+1 queries from application
-- Good: Single query with JOIN
SELECT o.id, o.total, u.name
FROM orders o JOIN users u ON o.user_id = u.id
WHERE o.status = 'pending';
\`\`\`

### Pagination (keyset, not OFFSET)
\`\`\`sql
-- Bad: OFFSET scans all skipped rows
SELECT * FROM orders ORDER BY id LIMIT 20 OFFSET 10000;

-- Good: Keyset pagination
SELECT * FROM orders WHERE id > 10000 ORDER BY id LIMIT 20;
\`\`\`

## EXPLAIN ANALYZE

\`\`\`sql
EXPLAIN ANALYZE
SELECT * FROM orders WHERE user_id = 1 AND status = 'pending';
\`\`\`

Read output:
- Seq Scan = missing index
- Index Scan = good
- Nested Loop with high row count = check join strategy

## Schema Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| EAV (Entity-Attribute-Value) | No type safety, slow queries | Use JSONB or proper columns |
| God table | Too many columns | Normalize into related tables |
| No constraints | Data integrity issues | Add CHECK, FK, UNIQUE constraints |
| String dates | Sorting/filtering issues | Use TIMESTAMP type |

## Connection Pooling

\`\`\`
App → Pool (min: 5, max: 20) → PostgreSQL
\`\`\`

Tools: PgBouncer (PostgreSQL), ProxySQL (MySQL).

## Related Skills

- `database-architect` — schema design
- `postgres-patterns` — PostgreSQL specifics
- `nosql-expert` — NoSQL alternatives
- `db-review` — database code review
