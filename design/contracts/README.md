# Contract Store

This directory stores pre-implementation interface locks between layers, tools,
or agents.

Use the source-of-truth rule:

```text
Spec explains why.
Contract locks what to build.
API.md documents what exists.
ADR decides what must remain true.
```

## Status Lifecycle

| Status | Meaning |
| --- | --- |
| `proposed` | Interface draft for discussion only. Do not implement against it. |
| `reviewed` | Owning lead reviewed it; details may still change. |
| `stable` | Safe to implement against. |
| `implemented` | Reflected in reviewed implementation and, for API surfaces, in `docs/technical/API.md`. |
| `deprecated` | Superseded or no longer used. |

## Current Sprint 2 Scope

- The contract store scaffold exists.
- One pilot contract exists as a bounded example.
- Broad rollout is still blocked.

The current repo does not yet contain `design/specs/*` feature specs that would
support a full end-to-end pilot with backend and frontend consumers. Until that
exists, keep contracts narrow and explicit about their status.

## Files

- `contract-template.md` - base structure for new contracts
- `decision-ledger-query-v1.contract.md` - pilot contract for the decision
  ledger query interface

## Rules

1. Do not add a contract when an existing artifact already owns the truth.
2. Link the contract to its governing PRD/spec/ADR before moving beyond
   `proposed`.
3. Do not mark a contract `implemented` unless the implementation exists and the
   API reference is updated when applicable.
4. Keep one pilot until adoption evidence justifies broader use.
