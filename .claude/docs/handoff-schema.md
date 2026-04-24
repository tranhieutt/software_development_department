# Lightweight Handoff Schema

> **Purpose:** Keep cross-domain handoffs explicit without repeating the
> friction of Rule 16's older full-contract workflow.
> **Owner:** All agents — sender writes it, receiver verifies it.
> **Default carrier:** `/orchestrate` prompt context between waves.
> **Optional durable carrier:** `.tasks/handoffs/<from>-to-<to>-<task_id>.json`
> for High-risk cross-domain transfers or when a formal artifact is explicitly
> requested.

---

## Default 3-field schema

Every cross-domain handoff should carry exactly these three fields:

```markdown
## Handoff Summary
- What was built: <finished artifact or behavior now available>
- What's missing: <known gaps, partial work, explicit risks, or "Nothing blocking in current scope">
- Acceptance criteria:
  - <concrete receiver check 1>
  - <concrete receiver check 2>
```

This is the Tier 2 Sprint 3 default. Keep it narrow. Do not add extra required
fields unless a later ADR changes the rule.

---

## When to use which form

| Situation | Required form |
| :--- | :--- |
| Cross-domain handoff in `/orchestrate` | 3-field summary in the downstream prompt |
| Same-domain minor follow-up | Optional; plain text is enough |
| High-risk cross-domain handoff | 3-field summary plus formal `/handoff` artifact |
| User explicitly asks for durable handoff file | 3-field summary plus formal `/handoff` artifact |

---

## Field rules

### What was built

State the artifact or behavior that now exists. Name the endpoint, file, UI
surface, schema change, or test coverage that is ready for the next agent.

Good:
- `POST /api/users now returns 201 with {id, email, created_at}`
- `Login form renders, validates required fields, and submits to the new auth endpoint`

Weak:
- `Backend done`
- `UI mostly ready`

### What's missing

State only the remaining gap or risk the next agent must know before starting.
If nothing is blocking inside the approved scope, say that explicitly.

Good:
- `Rate limiting is not implemented yet`
- `Happy path is complete; empty-state styling is still pending`
- `Nothing blocking in current scope`

Weak:
- `Might need more work`
- `See files`

### Acceptance criteria

List receiver-verifiable checks, not implementation trivia.

Good:
- `Frontend receives 201 and the created user id after valid submit`
- `QA can trigger 401 on invalid credentials`
- `Receiver sees no schema mismatch in docs/technical/API.md`

Weak:
- `Works correctly`
- `Looks good`
- `Should be fine`

---

## Example

```markdown
## Handoff Summary
- What was built: `POST /api/users` validates email, creates the user, and returns `201 {id, email, created_at}`.
- What's missing: Rate limiting is not implemented yet.
- Acceptance criteria:
  - Frontend receives `201` and a persisted `id` after a valid submit.
  - Invalid email returns `400` with the documented error shape.
```

---

## Formal artifact rule

The optional JSON contract remains available for High-risk cross-domain
handoffs. When used, the formal artifact must still preserve the same three
semantic fields above. The file exists to make the transfer durable, not to add
new mandatory process.
