---
paths:
  - "assets/data/**"
  - "config/**"
  - "src/config/**"
---

# Data File Rules

- All JSON files must be valid JSON — broken JSON blocks the entire application startup
- File naming: lowercase with underscores only, following `[domain]_[name].json` pattern
- Every data file must have a documented schema (either JSON Schema or documented in the API/design docs)
- Numeric values must include comments or companion docs explaining what the numbers mean
- Use consistent key naming: camelCase for keys within JSON files
- No orphaned data entries — every entry must be referenced by code or another config file
- Version data files when making breaking schema changes
- Include sensible defaults for all optional fields

## Examples

**Correct** naming and structure (`api_rate_limits.json`):

```json
{
  "default": {
    "requestsPerMinute": 60,
    "burstLimit": 10,
    "retryAfterSeconds": 60
  },
  "premium": {
    "requestsPerMinute": 600,
    "burstLimit": 100,
    "retryAfterSeconds": 10
  }
}
```

**Incorrect** (`RateLimits.json`):

```json
{
  "Default": { "rpm": 60 }
}
```

Violations: uppercase filename, uppercase key, no `[domain]_[name]` pattern, missing required fields.
