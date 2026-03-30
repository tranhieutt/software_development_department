# CODEMAP

> **Owner**: @technical-director (overall structure), @lead-programmer (module-level entries)
> **Update**: Run `/update-codemap` after each significant feature merge or refactor.
> **Purpose**: Navigation map for AI agents — read this before searching the codebase to avoid hallucination and redundant file reads.
> **Warning**: A stale CODEMAP is worse than none. If entries feel outdated, run `/update-codemap`.

---

## How to Read This File

Each entry follows the format:

```
| Module | Path | Description | Key exports / interfaces |
```

Agents should check this file first when they need to:
- Find where a specific system/feature is implemented
- Identify reusable utilities before creating new ones
- Understand which files to read before modifying a domain

---

## Application Modules

> Fill in when source code is added to `src/`. Run `/update-codemap` to regenerate.

| Module | Path | Description | Key exports |
| --- | --- | --- | --- |
| *(not yet populated)* | — | — | — |

---

## API Endpoints

> Summary of available API routes. See `docs/technical/API.md` for full spec.

| Method | Route | Handler file | Description |
| --- | --- | --- | --- |
| *(not yet populated)* | — | — | — |

---

## Shared Utilities

> Common helpers and utilities. Check here before creating new ones.

| Utility | Path | Description |
| --- | --- | --- |
| *(not yet populated)* | — | — |

---

## Data Models / Schemas

> Key entities and where they are defined. See `docs/technical/DATABASE.md` for full schema.

| Model | Path | Table name | Description |
| --- | --- | --- | --- |
| *(not yet populated)* | — | — | — |

---

## External Integrations

> Third-party services and where they are wired in.

| Service | Path | Description |
| --- | --- | --- |
| *(not yet populated)* | — | — |

---

## Revision History

| Date | Updated by | Summary of changes |
| --- | --- | --- |
| *(not yet populated)* | — | — |
