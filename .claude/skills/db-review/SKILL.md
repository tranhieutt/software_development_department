---
name: db-review
type: workflow
description: "Reviews database schemas, queries, and migrations for correctness, performance, security, and best practices. Use when reviewing SQL migration files or when the user mentions database review, schema review, or query audit."
argument-hint: "[path-to-schema-migration-or-query-files]"
user-invocable: true
allowed-tools: Read, Glob, Grep
context: fork
agent: data-engineer
effort: 2
when_to_use: "When reviewing database schemas, migrations, or queries for correctness, performance, and data integrity"
---

When this skill is invoked:

1. **Read the target schema, migration, or query files** in full.

2. **Evaluate schema design**:
   - [ ] All tables have a primary key
   - [ ] Tables have `created_at` and `updated_at` columns
   - [ ] Foreign key relationships defined with proper constraints
   - [ ] Column types are appropriate (don't use VARCHAR(255) for everything)
   - [ ] NULL vs NOT NULL is intentionally chosen and documented
   - [ ] Enum types used for fixed sets of values

3. **Evaluate indexing strategy**:
   - [ ] Every foreign key column is indexed
   - [ ] Columns in frequent WHERE, ORDER BY, or JOIN conditions are indexed
   - [ ] Composite indexes match the query patterns
   - [ ] No over-indexing (too many indexes slow writes)
   - [ ] Unique constraints used where business rules require uniqueness

4. **Evaluate migration safety**:
   - [ ] Migration is reversible (has a down/rollback script)
   - [ ] Adding columns with defaults is safe for zero-downtime
   - [ ] Removing columns uses soft-delete / multi-phase approach
   - [ ] Renaming columns uses multi-phase migration (add → backfill → drop old)
   - [ ] Large table operations consider locking implications

5. **Evaluate data integrity**:
   - [ ] Check constraints for value ranges where appropriate
   - [ ] No orphaned records possible (foreign keys or enforced at app layer)
   - [ ] Soft delete implemented (`deleted_at`) not hard delete for important records

6. **Evaluate query quality** (if queries provided):
   - [ ] No SELECT * in application queries
   - [ ] N+1 queries avoided (eager loading where needed)
   - [ ] Parameterized queries (no string concatenation)
   - [ ] Pagination on all list queries

7. **Output the review**:

```
## Database Review: [Schema/Migration Name]

### Schema Design: [CLEAN / ISSUES FOUND]
[List design problems]

### Indexes: [APPROPRIATE / MISSING / OVER-INDEXED]
[List index recommendations]

### Migration Safety: [SAFE / RISKY / BLOCKING]
[List migration risks and recommendations]

### Data Integrity: [ENFORCED / GAPS FOUND]
[List integrity concerns]

### Query Quality: [CLEAN / ISSUES FOUND]
[List query problems]

### Positive Observations
[What is well-designed]

### Required Changes
[Must-fix before applying]

### Suggestions
[Nice-to-have improvements]

### Verdict: [APPROVED / APPROVED WITH SUGGESTIONS / CHANGES REQUIRED]
```

## Protocol

- **Question**: Auto-starts from argument (schema, migration, or query files)
- **Options**: Skip — single review path
- **Decision**: Skip — verdict is advisory
- **Draft**: Full review shown in conversation only
- **Approval**: Skip — read-only; no files written

## Output

Deliver exactly:

- **Schema score** (X/6 design checks passing)
- **Migration safety**: `SAFE` / `RISKY` / `BLOCKING` with specific risks listed
- **Required changes** — must fix before applying migration (or "None")
- **Verdict**: `APPROVED` / `APPROVED WITH SUGGESTIONS` / `CHANGES REQUIRED`
