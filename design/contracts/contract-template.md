# Contract: <name>

**Status:** proposed | reviewed | stable | implemented | deprecated
**Owners:** lead-programmer, backend-developer
**Consumers:** <agent-or-layer>
**Producers:** <agent-or-layer>
**Purpose:** <one-line contract purpose>

## Source Links

- PRD: `PRD.md#fr-xxx` or `none`
- Feature spec: `design/specs/...` or `none`
- ADR: `docs/internal/adr/ADR-...` or `none`
- Implemented API reference: `docs/technical/API.md` or `not applicable`

## Scope

Describe the exact interface boundary this contract locks.

## Inputs

List each required input, parameter, field, or precondition.

| Name | Type | Required | Meaning |
| --- | --- | --- | --- |
| `<field>` | `<type>` | yes/no | `<description>` |

## Outputs

List each output, field, side effect, or postcondition.

| Name | Type | Meaning |
| --- | --- | --- |
| `<field>` | `<type>` | `<description>` |

## Error / Drift Conditions

List the conditions that make the interface invalid, blocked, or incompatible.

## Verification

- Producer check: `<command-or-file-check>`
- Consumer check: `<command-or-file-check>`
- Source-of-truth check: `<doc-or-runtime-check>`

## Change Rules

- Status may move from `proposed` to `reviewed` only after owner review.
- Status may move from `reviewed` to `stable` only when the consumer and
  producer agree on the locked interface.
- Status may move to `implemented` only when reviewed runtime behavior matches
  the contract and the API reference is updated when applicable.
