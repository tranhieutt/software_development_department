---
name: memory-structure
description: Tier 2.5 specialist namespace map and loading rules for selective memory retrieval.
type: project
---

# 🧠 SDD Memory Structure — Tier 2.5 Specialist Namespace

> Moved from `MEMORY.md` (A8 — 2026-04-17) to keep Tier 1 index under 40 lines.
> Load **max 1 specialist file** per session — only for the active agent.

## Tier 2.5 — Specialist Files

| Agent               | File                                                                     | Load When                 |
| ------------------- | ------------------------------------------------------------------------ | ------------------------- |
| Backend Developer   | [specialists/backend-developer.md](specialists/backend-developer.md)     | backend tasks, API, DB    |
| Frontend Developer  | [specialists/frontend-developer.md](specialists/frontend-developer.md)   | UI, React, CSS            |
| QA Engineer         | *(merged — use `qa-engineer` agent directly)*                            | testing, coverage, bugs   |
| Data Engineer       | [specialists/data-engineer.md](specialists/data-engineer.md)             | pipelines, ETL, analytics |
| Fullstack Developer | [specialists/fullstack-developer.md](specialists/fullstack-developer.md) | full-stack features       |
| Diagnostics         | *(merged — use `diagnostics` agent directly)*                            | debugging, root cause     |
| Technical Director  | [specialists/technical-director.md](specialists/technical-director.md)   | arch decisions, review    |

## Consensus

- [Merged Decisions](consensus/merged-decisions.md) — cross-agent consensus log

## Rules

- **Max 1 file** from this namespace per session.
- Do NOT preload — only load when the active agent matches.
- After loading, do NOT load another Tier 2.5 file unless agent changes.
