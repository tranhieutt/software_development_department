# Database Schema Design

**Feature/System**: [Name]
**Author**: [Your name]
**Status**: Draft | Reviewed | Approved
**Date**: [YYYY-MM-DD]

---

## Context

[1-2 sentences: What feature or system requires these schema changes?]

## Entity Relationship

[Describe the entities and their relationships in prose, or embed an ERD diagram link]

```
[Table A] 1--N [Table B] (A has many B's)
[Table A] N--N [Table C] via [junction_table]
```

---

## Tables

### `table_name`

**Purpose**: [What this table stores and why]

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NOT NULL | gen_random_uuid() | Primary key |
| `field_name` | VARCHAR(255) | NOT NULL | | [Description] |
| `status` | ENUM('active','inactive') | NOT NULL | 'active' | Current status |
| `created_at` | TIMESTAMPTZ | NOT NULL | now() | Creation time |
| `updated_at` | TIMESTAMPTZ | NOT NULL | now() | Last update time |

**Indexes**:
```sql
CREATE INDEX idx_table_name_field ON table_name (field_name);
CREATE INDEX idx_table_name_status ON table_name (status) WHERE status = 'active';
```

**Constraints**:
```sql
ALTER TABLE table_name ADD CONSTRAINT chk_field_length CHECK (char_length(field_name) > 0);
```

---

## Migrations

### Up
```sql
CREATE TABLE table_name (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_table_name_field ON table_name (field_name);
```

### Down
```sql
DROP TABLE IF EXISTS table_name;
```

---

## Rollout Plan

| Step | Action | Risk | Zero-Downtime? |
|------|--------|------|----------------|
| 1 | Add column nullable | Low | Yes |
| 2 | Backfill data | Medium | Yes |
| 3 | Add NOT NULL constraint | Low | Yes |

## Open Questions

- [ ] [Question about schema that needs resolution]
