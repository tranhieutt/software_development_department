# Database Code Standards

Applies to: `src/db/**`, `src/models/**`, `src/repositories/**`, `migrations/**`, `schema/**`

## Schema Design
- Every table must have: primary key, `created_at` (NOT NULL), `updated_at` (NOT NULL)
- Use meaningful column names — avoid abbreviations
- Foreign keys must have database-level constraints, not just application-level checks
- Use database-native enum types for fixed sets of values
- Always specify column nullability explicitly — no implicit nulls

## Migrations
- Every migration must have a reversible `down` function
- Column removal uses multi-phase approach: deprecate → backfill null → remove (across deploys)
- Migrations that lock large tables must be reviewed by data-engineer before running
- Never modify a migration file that has already run in any environment

## Queries
- No `SELECT *` in application code — always name columns
- Parameterized queries only — no string concatenation in SQL
- All list/search queries must have pagination (LIMIT/OFFSET or cursor)
- N+1 queries are not allowed — use eager loading or joins

## Indexing
- Index all foreign key columns
- Index columns that appear in frequent WHERE, ORDER BY, or GROUP BY
- Partial indexes for common filtered subsets
- Document the query pattern an index is for

## Data Integrity
- Sensitive data (PII, payment info) must be encrypted at rest
- Soft deletes with `deleted_at` for user-generated content
- Hard deletes only with documented data retention policy justification
