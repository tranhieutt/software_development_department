# Contract: Decision Ledger Query v1

**Status:** proposed
**Owners:** technical-director, lead-programmer
**Consumers:** `trace-history` skill, coordination-rule readers, ADR workflow
**Producers:** `decision-ledger` writers, `log-commit`, `decision-ledger-writer`
**Purpose:** Lock the minimum query boundary for reading decision-ledger history
before higher-risk workflow decisions.

## Source Links

- PRD: `PRD.md#fr-021`
- Feature spec: `none`
- ADR: `docs/internal/adr/ADR-006-shared-state-adoption.md`
- Implemented API reference: `not applicable`

## Scope

This contract covers the read interface for querying
`production/traces/decision_ledger.jsonl` through the existing `/trace-history`
workflow and equivalent local ledger inspection. It does not define write-path
schema ownership beyond the already-implemented ledger format.

## Inputs

| Name | Type | Required | Meaning |
| --- | --- | --- | --- |
| `risk` | enum | no | Filter by `High`, `Medium`, or `Low`. |
| `outcome` | enum | no | Filter by `pass`, `fail`, `blocked`, or `skipped`. |
| `task` | string | no | Match a specific task identifier. |
| `agent` | string | no | Match a specific `agent_id`. |
| `since` | date | no | Lower time bound in `YYYY-MM-DD`. |
| `last` | integer | no | Limit to the newest N entries after filtering. |
| `format` | enum | no | Render as `pretty` or `json`. |

## Outputs

| Name | Type | Meaning |
| --- | --- | --- |
| `entries` | array | Matching ledger entries in reverse-relevance or latest-first output. |
| `empty-message` | string | Deterministic message when the ledger is empty or no entries match. |
| `history-citation` | string | Human-readable prior decision summary suitable for ADR or policy notes. |

## Minimum Entry Fields Required by Readers

| Field | Type | Meaning |
| --- | --- | --- |
| `ts` | string | ISO timestamp for ordering and citation. |
| `agent_id` | string | Originating agent or hook identifier. |
| `task_id` | string | Task or checkpoint association. |
| `choice` | string | Decision or action taken. |
| `outcome` | enum | `pass`, `fail`, `blocked`, or `skipped`. |
| `risk_tier` | enum | `High`, `Medium`, or `Low`. |

## Error / Drift Conditions

- Query output omits one of the minimum reader fields above.
- Workflow guidance requires a `/trace-history` read gate but the reader cannot
  cite equivalent ledger history.
- A policy or ADR claims prior-decision review happened without a query result
  or an explicit "none found" note.

## Verification

- Producer check: `node scripts/trace-integrity-check.js`
- Consumer check: inspect `.claude/skills/trace-history/SKILL.md` and
  `scripts/trace-history.sh` for the documented filter surface
- Source-of-truth check: compare this contract with
  `docs/internal/adr/ADR-006-shared-state-adoption.md` and
  `.claude/docs/coordination-rules.md`

## Change Rules

- Keep this contract at `proposed` until a feature-spec-backed consumer path
  exists or owner review promotes it.
- Do not treat this contract as an API implementation record; `API.md` remains
  unchanged because this pilot is not an application endpoint.
