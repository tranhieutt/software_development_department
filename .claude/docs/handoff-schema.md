# A2A Handoff Schema

> **Purpose:** Standardize context transfer between agents so no information
> is lost when work crosses domain boundaries.
> **Owner:** All agents — written by the sender, read by the receiver.
> **Storage:** `.tasks/handoffs/<from>-to-<to>-<task_id>.json`

---

## Why Handoffs Matter

When an agent finishes its slice and passes work to the next agent, two
failure modes are common:

1. **Context loss** — the receiving agent has no idea what decisions were made
2. **Assumption mismatch** — the receiver assumes the artifact is complete when
   it is only partially done

A formal handoff contract prevents both by making the transfer explicit,
structured, and verifiable.

---

## Contract Schema

```jsonc
{
  // Who is sending and who is receiving
  "from": "<agent-name>",           // e.g. "backend-developer"
  "to": "<agent-name>",             // e.g. "qa-tester"

  // What is being handed off
  "task_id": "<task-id>",           // links back to .tasks/checkpoints/ and TODO.md
  "artifact": "<file-or-path>",     // primary deliverable, e.g. "src/api/auth.ts"
  "artifact_status": "complete | partial | draft",

  // What the receiver must verify before accepting
  "acceptance_criteria": [
    "<criterion 1>",                // e.g. "POST /auth returns 201 with valid JWT"
    "<criterion 2>"                 // e.g. "Invalid credentials return 401"
  ],

  // Where the receiver can recover full context if needed
  "context_snapshot": "<path>",     // e.g. ".tasks/checkpoints/auth-api-v1.md"

  // Risk assessment — governs ledger logging (Rule 15)
  "risk_tier": "Low | Medium | High",

  // Metadata
  "ts": "<ISO timestamp>",
  "session": "<git branch>"
}
```

---

## Field Guide

| Field | Required | Notes |
| :--- | :--- | :--- |
| `from` | yes | Must match a file in `.claude/agents/` |
| `to` | yes | Must match a file in `.claude/agents/` |
| `task_id` | yes | Used to look up checkpoint and task file |
| `artifact` | yes | Primary file/path being handed off |
| `artifact_status` | yes | `complete` = fully done; `partial` = more work needed; `draft` = needs review |
| `acceptance_criteria` | yes | At least 1 item. Testable, not vague. |
| `context_snapshot` | no | Path to checkpoint file — omit if no checkpoint exists |
| `risk_tier` | yes | High → mandatory ledger entry; Medium → ledger entry; Low → optional |
| `ts` | auto | Set by `/handoff` skill |
| `session` | auto | Set by `/handoff` skill from `git branch` |

---

## Acceptance Criteria Rules

Strong criteria (use these):
- `"POST /auth returns 201 with a signed JWT"`
- `"All 12 unit tests in auth.test.ts pass"`
- `"Button is keyboard-operable and has aria-label"`

Weak criteria (avoid these):
- `"Works correctly"` — not testable
- `"Looks good"` — subjective
- `"Should be fine"` — no verification path

---

## Example: Backend → QA

```json
{
  "from": "backend-developer",
  "to": "qa-tester",
  "task_id": "042",
  "artifact": "src/api/auth.ts",
  "artifact_status": "complete",
  "acceptance_criteria": [
    "POST /auth with valid credentials returns 201 and a signed JWT",
    "POST /auth with invalid credentials returns 401",
    "POST /auth with missing body returns 400"
  ],
  "context_snapshot": ".tasks/checkpoints/042.md",
  "risk_tier": "Medium",
  "ts": "2026-04-16T11:00:00Z",
  "session": "main"
}
```

## Example: Frontend → Lead Programmer (partial handoff)

```json
{
  "from": "frontend-developer",
  "to": "lead-programmer",
  "task_id": "055",
  "artifact": "src/components/LoginForm.tsx",
  "artifact_status": "partial",
  "acceptance_criteria": [
    "Form renders without console errors",
    "Submit button is disabled when fields are empty"
  ],
  "context_snapshot": null,
  "risk_tier": "Low",
  "ts": "2026-04-16T14:30:00Z",
  "session": "feature/login-ui"
}
```

---

## Handoff Lifecycle

```
Sender runs: /handoff [from] [to] [artifact] [task_id]
  → skill generates contract JSON
  → saves to .tasks/handoffs/<from>-to-<to>-<task_id>.json
  → prints contract for user review
  → if risk_tier Medium/High → appends entry to decision_ledger.jsonl

Receiver starts work:
  → reads .tasks/handoffs/<from>-to-<to>-<task_id>.json
  → verifies each acceptance_criterion before starting
  → if criteria not met → returns to sender with specific failures listed
```
