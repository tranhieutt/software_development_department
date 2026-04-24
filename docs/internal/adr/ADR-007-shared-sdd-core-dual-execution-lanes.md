# ADR-007: Shared SDD Core with Dual Execution Lanes for Claude and Codex

**Status:** Accepted
**Date:** 2026-04-24
**Deciders:** User, technical-director
**Prior decision check:** Reviewed `production/traces/decision_ledger.jsonl` and found no conflicting recent high-risk decision governing dual-runtime execution. Relevant standing context: ADR-006 keeps shared state as a read layer, not a decide layer.
**Related artifacts:** `AGENTS.md`, `docs/codex-compatibility.md`, `docs/technical/CONTROL_PLANE_MAP.md`
**Complements:** Rule 3 (Conflict Resolution), Rule 12 (Verifiable Plan Format), Rule 13 (Fullstack Vertical Slicing), Rule 15 (Decision Tracing Ledger)

---

## Context

The intended use of SDD is no longer Claude-only. The target operating model is
to build CRM, SaaS, and AI Agent products while using both Claude and Codex in
the same repo to exploit complementary strengths:

- Claude Opus is stronger at ambiguity reduction, spec shaping, architectural
  reasoning, and review.
- GPT-5.x / Codex is stronger at terminal-heavy implementation, patching, fast
  code iteration, and execution discipline.

The architectural risk is not whether both runtimes can be used. They can.
The real risk is **decision drift**:

1. Claude and Codex each maintain separate plans in chat.
2. Both runtimes make architecture or scope decisions independently.
3. Shared artifacts fall out of sync with implementation.
4. The team ends up maintaining two process systems instead of one SDD core.

This ADR exists to prevent that drift while still allowing both runtimes to be
used deliberately.

---

## Decision

SDD will operate as **one shared core** with **two execution lanes**:

```text
Shared SDD core
  - PRD, specs, ADRs, tasks, registry, rules, lifecycle map
  - one source of truth for scope and decisions

Claude lane
  - DEFINE
  - PLAN
  - REVIEW
  - high-risk escalation

Codex lane
  - BUILD
  - narrow VERIFY
  - terminal-heavy implementation execution
```

### 1. One core, not two frameworks

Claude remains the canonical runtime owner for native slash-command semantics.
Codex remains an additive execution client through the existing adapter.

SDD will **not** fork into separate Claude-SDD and Codex-SDD systems for normal
product work.

### 2. Claude is the control plane

Claude is the default owner for:

- onboarding and problem framing
- product clarification and ambiguity reduction
- spec creation and architecture decisions
- task decomposition and approval gates
- cross-domain conflict resolution
- final code review or design review on risky work

### 3. Codex is the execution plane

Codex is the default owner for:

- scoped implementation tasks already approved
- terminal-heavy debugging and reproduction
- file patching, test running, and local verification
- narrow refactors inside an already-approved task boundary
- executing mechanical follow-up fixes from review findings

### 4. Shared state is mandatory between lanes

Claude and Codex must converge on the same repository artifacts, not chat-only
state. The minimum handoff surface is:

- `PRD.md` for product intent
- `design/specs/*` or equivalent approved spec
- `TODO.md` and `.tasks/NNN-*.md` for task scope and execution state
- ADRs for durable architecture decisions
- current diffs, tests, and verification evidence

### 5. Single-decider rule

For any one task at any one moment:

- exactly one runtime is the current **decision owner**
- exactly one runtime is the current **execution owner**

These roles may be the same runtime for a small task, but they must not be
ambiguous.

### 6. Parallelism rule

Claude and Codex may work in parallel only when all of the following are true:

- file scopes are disjoint
- the governing spec is already approved
- the downstream integration owner is named
- each parallel track has an explicit verification check

If those conditions are not true, run sequentially.

---

## Consequences

### Positive

- Preserves one SDD system of record across both runtimes.
- Lets Claude focus on strategy, quality, and ambiguity reduction.
- Lets Codex focus on execution speed and terminal-heavy implementation.
- Reduces dual-maintenance pressure compared with a full Codex fork.

### Negative

- Operators must maintain discipline about handoff boundaries.
- Some friction remains because Codex still uses an adapter, not Claude-native
  slash commands and hooks.
- The repo must carry a small amount of runtime-specific onboarding and
  documentation for Codex.

### Risks and mitigation

| Risk | Mitigation |
| --- | --- |
| Claude and Codex diverge on scope | Use shared artifacts only; no chat-only scope authority. |
| Both runtimes edit the same concern at once | Name one execution owner per task and enforce disjoint scope for parallel work. |
| Codex bypasses review gates | Claude stays primary on DEFINE/PLAN/REVIEW and high-risk escalation. |
| Adapter overhead becomes too high | Improve `.codex/` UX surface first; do not fork SDD core by default. |

---

## Rejected Options

### Option A: Claude-only operations

Rejected because it leaves execution throughput on the table and does not use
GPT-5.x strengths for implementation-heavy work.

### Option B: Full Codex fork of SDD

Rejected because it creates dual-maintenance, skill drift, and conflicting
process semantics.

### Option C: No formal split, let operators choose ad hoc

Rejected because informal multi-runtime usage causes scope drift and duplicated
decision-making.

---

## Summary

The operating model for product work is:

- **one SDD core**
- **Claude as control plane**
- **Codex as execution plane**
- **shared repo artifacts as the only durable cross-runtime truth**

The goal is not symmetry. The goal is controlled asymmetry that exploits the
best strengths of each runtime without splitting the framework.
