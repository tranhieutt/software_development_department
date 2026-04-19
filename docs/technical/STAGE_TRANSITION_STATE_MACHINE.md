# Stage Transition State Machine

> **Spec ref:** §15.3 — required artifact for workflow gate legibility.
> **Source:** `CLAUDE.md` workflow gates + `ARCHITECTURE_SPEC_CLAUDE_SYSTEM.md` §5–§8
> **Last updated:** 2026-04-19 (v1.41.0)

This document defines the allowed state transitions between SDD workflow stages, entry/exit criteria for each stage, and which agents/hooks are activated at each transition.

---

## Stage Definitions

```
IDLE ──► PLAN ──► SPEC ──► TDD ──► IMPL ──► REVIEW ──► DONE
          │                  │                  │
          │                  └──► DIAGNOSE ──────┘
          └──────────────────────────────────────┘
                     (abort at any stage → IDLE)
```

---

## Transition Table

| From       | Event / Command         | To               | Guard condition                                      | Hook / Agent activated                    |
| ---------- | ----------------------- | ---------------- | ---------------------------------------------------- | ----------------------------------------- |
| `IDLE`     | `/plan`                 | `PLAN`           | Session started, `active.md` exists                  | `session-start.sh` (bootstraps state)     |
| `PLAN`     | Plan approved by user   | `SPEC`           | User confirms plan in conversation                   | —                                         |
| `PLAN`     | `/diagnose`             | `DIAGNOSE`       | Triggered when task is ambiguous or blocker detected | `detect-gaps.sh`                          |
| `SPEC`     | `/spec` completes       | `TDD`            | Spec written to file, user accepts                   | `validate-assets.sh` (PostToolUse)        |
| `SPEC`     | Scope change detected   | `PLAN`           | User explicitly changes scope                        | —                                         |
| `TDD`      | `/tdd` — tests written  | `IMPL`           | Failing tests committed to branch                    | `validate-commit.sh` (PreToolUse)         |
| `TDD`      | Test design conflict    | `SPEC`           | Spec ambiguity blocks test writing                   | —                                         |
| `IMPL`     | Implementation complete | `REVIEW`         | All tests pass, code compiles                        | `validate-assets.sh`, `log-writes.sh`     |
| `IMPL`     | `/vertical-slice`       | `REVIEW`         | Vertical slice delivered end-to-end                  | `pre-refactor-impact.sh` (PreToolUse)     |
| `REVIEW`   | PR approved + merged    | `DONE`           | PR merged, `git push` succeeds                       | `log-commit.sh`, `validate-push.sh`       |
| `REVIEW`   | Review comments         | `IMPL`           | Feedback requires code changes                       | —                                         |
| `DIAGNOSE` | Root cause found        | `IMPL`           | Decision logged to ledger                            | `decision-ledger-writer.sh`               |
| `DIAGNOSE` | Blocker unresolvable    | `IDLE`           | Surface to user, await input                         | `session-stop.sh`                         |
| `DONE`     | New task                | `IDLE`           | Session state reset / `/clear`                       | `session-stop.sh`, `auto-dream.sh`        |
| **ANY**    | Circuit OPEN            | `IDLE` (blocked) | `circuit-state.json` state = `OPEN`                  | `circuit-guard.sh` (blocks Task dispatch) |
| **ANY**    | `/clear`                | `IDLE`           | User explicitly clears context                       | `pre-compact.sh`, `session-stop.sh`       |

---

## Stage Detail Cards

### `IDLE`

| Field            | Value                                                                     |
| ---------------- | ------------------------------------------------------------------------- |
| **Meaning**      | No active task. Session may have just started or previous task completed. |
| **Entry action** | `session-start.sh` bootstraps `active.md` template                        |
| **Exit trigger** | `/plan`, `/diagnose`, or user prompt with clear task intent               |
| **Active hooks** | `SessionStart` → `session-start.sh`, `detect-gaps.sh`                     |

---

### `PLAN`

| Field            | Value                                                                     |
| ---------------- | ------------------------------------------------------------------------- |
| **Meaning**      | Defining scope, breaking down the task, identifying risks.                |
| **Entry action** | `/plan` command invokes `ui-spec` or `planner` skill                      |
| **Exit trigger** | User approves plan (verbal confirmation)                                  |
| **Blocked by**   | Circuit OPEN state                                                        |
| **Active hooks** | `prompt-context.sh` (injects tech decisions context), `persist-memory.sh` |

---

### `SPEC`

| Field            | Value                                                                |
| ---------------- | -------------------------------------------------------------------- |
| **Meaning**      | Writing formal spec, user stories, acceptance criteria into a file.  |
| **Entry action** | `/spec` command                                                      |
| **Exit trigger** | Spec file written and accepted by user                               |
| **Quality gate** | `validate-assets.sh` — validates frontmatter and schema of spec file |
| **Active hooks** | `log-writes.sh`, `validate-assets.sh`, `file-history.sh`             |

---

### `TDD`

| Field            | Value                                                   |
| ---------------- | ------------------------------------------------------- |
| **Meaning**      | Writing failing tests before implementation code.       |
| **Entry action** | `/tdd` command                                          |
| **Exit trigger** | Tests written, committed, confirmed failing (RED state) |
| **Quality gate** | `validate-commit.sh` — enforces commit message format   |
| **Active hooks** | `validate-commit.sh`, `log-commit.sh`                   |

---

### `IMPL`

| Field            | Value                                                           |
| ---------------- | --------------------------------------------------------------- |
| **Meaning**      | Implementation — writing code to make tests pass.               |
| **Entry action** | Tests committed, GREEN phase begins                             |
| **Exit trigger** | All tests pass; `/vertical-slice` completes or PR ready         |
| **Quality gate** | `pre-refactor-impact.sh` — blast radius check on large edits    |
| **Active hooks** | `pre-refactor-impact.sh`, `log-writes.sh`, `validate-assets.sh` |

---

### `REVIEW`

| Field            | Value                                                   |
| ---------------- | ------------------------------------------------------- |
| **Meaning**      | Code review, PR open, feedback integration.             |
| **Entry action** | `git push` + PR creation                                |
| **Exit trigger** | PR merged → `DONE`, or review feedback → back to `IMPL` |
| **Quality gate** | `validate-push.sh` — branch protection, remote target   |
| **Active hooks** | `validate-push.sh`, `log-commit.sh`                     |

---

### `DIAGNOSE`

| Field            | Value                                                               |
| ---------------- | ------------------------------------------------------------------- |
| **Meaning**      | Root cause analysis — triggered by bug, blocker, or spec ambiguity. |
| **Entry action** | `/diagnose` command or 3x retry failure (diminishing returns rule)  |
| **Exit trigger** | Root cause written to `active.md`, decision logged to ledger        |
| **Decision log** | `decision-ledger-writer.sh` writes `ledger/v1` entry on resolution  |
| **Active hooks** | `decision-ledger-writer.sh`, `detect-gaps.sh`                       |

---

### `DONE`

| Field             | Value                                                                   |
| ----------------- | ----------------------------------------------------------------------- |
| **Meaning**       | Task complete. PR merged or deliverable accepted.                       |
| **Entry action**  | Merge confirmed                                                         |
| **Exit trigger**  | New task → `IDLE`                                                       |
| **Close actions** | `session-stop.sh` writes session archive; `/dream` if memory near limit |

---

## Circuit Breaker Integration

The `circuit-guard.sh` hook runs at `PreToolUse[Task]` and can block any stage transition that involves subagent dispatch:

```
circuit-state.json:
  CLOSED  → normal operation   (Task dispatch allowed)
  HALF    → degraded mode      (Task dispatch allowed, escalation logged)
  OPEN    → blocked            (Task dispatch DENIED — surface to user)
```

**Reset path:** OPEN → CLOSED requires manual user intervention or `/diagnose` resolution.
See `docs/internal/adr/ADR-004-unified-failure-state-machine.md` for full FSM spec.

---

## Relationship to `/context` Command

At any stage, `/context` can be invoked to:
1. Load the relevant Tier 2 memory files for the current stage
2. Re-read `active.md` to recover position
3. Resume from last checkpoint without stage regression
