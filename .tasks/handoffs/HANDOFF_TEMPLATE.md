# Handoff Template

Use this template when handing work between Claude and Codex, or between two
agents/runtimes working under the same approved SDD task.

This template follows the lightweight 3-field schema in
`.claude/docs/handoff-schema.md` and the operating split in
`docs/technical/CLAUDE_CODEX_OPERATING_MODEL.md`.

---

## Minimal Handoff

```markdown
## Handoff Summary
- What was built: <finished artifact or behavior now available>
- What's missing: <known gap, explicit risk, or "Nothing blocking in current scope">
- Acceptance criteria:
  - <concrete receiver check 1>
  - <concrete receiver check 2>
```

---

## Claude <-> Codex Handoff

```markdown
## Handoff Summary
- What was built: <artifact or behavior now available>
- What's missing: <remaining gap, risk, or "Nothing blocking in current scope">
- Acceptance criteria:
  - <receiver-verifiable check 1>
  - <receiver-verifiable check 2>

Task: <task-id or task name>
Decision owner: <Claude|Codex>
Execution owner: <Claude|Codex>
Source of truth: <PRD/spec/task/ADR paths>
Allowed scope: <files or bounded module>
Verification: <exact command/check>
Open risks: <none or list>
```

Use this extended form when the runtime split matters and you want the next
operator to know exactly who owns decisions vs execution.

---

## Quick Example

```markdown
## Handoff Summary
- What was built: `POST /api/users` now validates input, creates the record, and returns `201 {id, email, created_at}`.
- What's missing: Empty-state copy for the frontend success screen is still pending.
- Acceptance criteria:
  - Frontend receives `201` with a persisted `id` after a valid submit.
  - Invalid email returns `400` with the documented error shape.

Task: 042-user-create-flow
Decision owner: Claude
Execution owner: Codex
Source of truth: PRD.md#fr-042; design/specs/user-create.md; .tasks/042-user-create-flow.md
Allowed scope: src/api/users/**, tests/api/users/**
Verification: npm test -- users-create
Open risks: No rate limiting yet; out of current scope.
```

---

## Field Rules

### What was built

State the artifact or behavior that now exists. Name the endpoint, file, UI
surface, schema change, test coverage, or review outcome that is ready.

Good:

- `Login form renders, validates required fields, and submits to the auth endpoint`
- `ADR-008 drafted with accepted option and risk notes`

Weak:

- `Backend done`
- `Mostly ready`

### What's missing

State only the next relevant gap or risk. If nothing blocks the approved scope,
say that explicitly.

Good:

- `Nothing blocking in current scope`
- `Rate limiting not implemented yet`
- `Receiver still needs to re-run the migration on a clean DB`

Weak:

- `See files`
- `Maybe more work later`

### Acceptance criteria

List checks the receiver can verify directly.

Good:

- `QA can reproduce 401 on invalid credentials`
- `Receiver sees no schema mismatch in docs/technical/API.md`
- `Claude review confirms the patch still matches design/specs/user-create.md`

Weak:

- `Works correctly`
- `Looks good`
- `Should be fine`

---

## When To Use Which Form

| Situation | Recommended form |
| --- | --- |
| Same-runtime small follow-up | Minimal handoff or plain text |
| Claude -> Codex scoped implementation | Claude <-> Codex handoff |
| Codex -> Claude risky review/escalation | Claude <-> Codex handoff |
| High-risk cross-domain transfer | Claude <-> Codex handoff plus formal `/handoff` artifact |
| User requests durable transfer file | Claude <-> Codex handoff plus formal `/handoff` artifact |

---

## Durable Artifact Note

If the transfer is High-risk or needs a durable file, also run `/handoff` to
create the optional JSON artifact in `.tasks/handoffs/` and the matching ledger
entry.
