# ADR-006: Shared State Adoption as Tier 2 Evolution of SDD Coordination

**Status:** Accepted
**Date:** 2026-04-23
**Last cleaned:** 2026-04-24
**Deciders:** User, technical-director
**Related analysis:** `docs/internal/harness-to-coordination-engineering.md`
**Complements:** Rule 15 (Decision Tracing Ledger), Rule 11 (Permission Modes)
**Does NOT supersede:** Rule 3 (Conflict Resolution), Rule 6 (Layered Recovery), Rule 16 (A2A Handoffs)

---

## Context

SDD has already completed **Tier 1 (Harness Engineering)**: agents can exist,
route, recover, and persist state.

The architectural question was whether SDD should jump directly to full
**Coordination Engineering**. The answer is no. The correct next layer is
**Tier 2: Shared State Adoption & Source-of-Truth Consolidation**.

The gaps that justified this ADR were:

1. **Authority ambiguity**
   Multiple artifacts overlapped on the same truth without a declared conflict
   winner.

2. **Write-only infrastructure**
   The decision ledger already existed and could be queried, but workflows did
   not consistently read it before making new high-risk decisions.

3. **Rule 16 friction precedent**
   Heavy cross-agent handoff process had already failed once because the mandate
   was too broad for actual usage.

This ADR exists to move Tier 2 forward without repeating that mistake.

---

## Decision

### Three-tier model

```text
Tier 1: Harness Engineering
Tier 2: Shared State Adoption & Source-of-Truth Consolidation
Tier 3: Coordination Engineering
```

**Decision:** Tier 1 is complete. SDD continues in Tier 2. Tier 3 stays deferred
until measurable operational triggers justify it.

### Shared state boundary

Shared state is a **READ LAYER**, not a **DECIDE LAYER**.

It may:
- improve observability
- reduce producer text-relay burden
- let agents read the same truth directly
- reduce handoff friction

It may not:
- grant autonomous authority
- bypass human approval
- bypass Rule 3 escalation
- let agents self-negotiate binding decisions

### Tier 2 enforcement rule

Mandates must stay narrow by risk tier:

| Enforcement | Scope |
| --- | --- |
| `MUST` | ADRs, coordination-rule change, high-risk retry, protocol removal |
| `SHOULD` | API design in existing domain, feature spec in existing domain |
| `SKIP` | Bug fix, cosmetic, doc typo, trivial low-risk choice |

**Broad MUST across all workflows is forbidden.**

---

## Current Status

The following Tier 2 work has already landed:

- `docs/technical/SOURCE_OF_TRUTH_REGISTRY.md`
- `docs/technical/API.md` skeleton
- decision-log read-gate wiring
- `design/contracts/` scaffold, template, and one pilot contract
- lightweight 3-field handoff summary wired into `/orchestrate`
- manual `scripts/coordination-audit.js` scaffold

The following are **not closed yet**:

1. **Contract pilot verification**
   The contract-store scaffold exists, but there is not yet end-to-end evidence
   tied to one real feature spec and downstream consumer flow.

2. **Handoff adoption verification**
   The 3-field handoff schema is wired, but real operational adoption has not yet
   been proven by repeated cross-domain handoffs.

3. **Coordination audit rollout**
   `scripts/coordination-audit.js` exists only as a manual, report-only tool.
   Scheduled or blocking rollout is still deferred.

---

## Remaining Gates

### Contract pilot gate

Do not call the contract pilot complete until:
- one real feature spec links the pilot contract
- downstream backend/frontend work references it
- implemented endpoint behavior is reflected in `docs/technical/API.md` when applicable

### Lightweight handoff gate

Do not call Sprint 3 complete until:
- 3 consecutive cross-domain handoffs carry the 3-field summary
- the schema is inserted without user intervention
- adoption rate reaches at least 70% for the sprint window

### Coordination audit rollout gate

Do not promote `scripts/coordination-audit.js` beyond manual usage until both
conditions hold:

1. adoption is at least 70% across Tier 2 artifacts for 2 consecutive sprints
2. there are at least 2 real drift incidents despite that adoption

Low adoption is **not** an audit trigger. It is a rollback or simplification
trigger.

---

## Tier 3 Trigger

Tier 3 is considered only when at least one of these thresholds is reached:

- concurrent-write conflicts >= 3 per sprint
- producer must escalate Rule 3 >= 2 per sprint
- orchestrator routinely spawns more than 5 agents per task

If these are not met, SDD remains in Tier 2.

---

## Anti-Pattern Watch

Any Tier 2 artifact should be simplified, downgraded, or removed if these show up:

| Red flag | Threshold | Action |
| --- | --- | --- |
| Contract bypass | > 30% handoffs skip contract | reduce required fields |
| Decision-log churn | ledger written but not read for 2 sprints | remove read-gate mandate |
| Schema expansion | > 5 required handoff fields | reject expansion |
| Broad low adoption | < 50% after 3 sprints | MUST -> SHOULD or remove |
| Registry stale | > 30 days stale after artifact changes | review and prune |
| Registry bureaucracy | > 3 files updated per new artifact | simplify process |

Rollback is expected feedback, not failure.

---

## What This ADR Does Not Decide

- full Tier 3 Coordination Engineering design
- retirement of Rule 16
- automatic CI enforcement for coordination audit
- further automation beyond `scripts/coordination-audit.js`
- cross-project Codex adapter policy

---

## Summary

This ADR commits SDD to Tier 2, not Tier 3.

The main build work for Tier 2 already exists. The remaining work is to prove
adoption, verify the pilot artifacts in real usage, and only then decide whether
audit tooling should be rolled out more broadly.
