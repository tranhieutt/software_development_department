# ADR-005: Resolve Rule 14 vs ADR-004 Circuit Breaker Conflict

**Status:** Accepted
**Date:** 2026-04-18
**Deciders:** Production Readiness Assessment (2026-04-18), User
**Supersedes (partially):** Rule 14 in `coordination-rules.md`
**Complements:** ADR-004 (Unified Failure State Machine)

---

## Context

The SDD framework has two overlapping specifications for circuit breaker behavior that contradict
each other across four dimensions. This conflict was identified during Sprint A of the
"Enforced But Not Yet Stable" production-readiness push and was deliberately deferred pending
a team decision (v1.36.0 CHANGELOG, "Skipped — Epic 2").

### The Two Conflicting Sources

**Rule 14** (`coordination-rules.md`, added v1.30.0):

```
State file:   production/session-state/circuit-state.json
Scope:        per-agent (each agent has its own state)
HALF-OPEN:    after 10 minutes in OPEN state
Threshold:    3+ failures → OPEN directly
Routing:      fallback pairs (backend→fullstack, qa-tester→qa-lead, etc.)
```

**ADR-004** (`docs/internal/adr/ADR-004-unified-failure-state-machine.md`, accepted 2026-04-17):

```
State file:   .claude/memory/circuit-state.json
Scope:        global flat (single state for entire session)
HALF-OPEN:    after 60 minutes TTL
Threshold:    3 failures → HALF_OPEN, 4 failures → OPEN
Routing:      block all Task tool calls when OPEN (no fallback routing)
```

### Conflict Matrix

| Dimension                | Rule 14                     | ADR-004                 | Contradiction |
| ------------------------ | --------------------------- | ----------------------- | ------------- |
| State scope              | Per-agent                   | Global flat             | ❌ DIRECT      |
| State file path          | `production/session-state/` | `.claude/memory/`       | ❌ DIRECT      |
| TTL to HALF-OPEN         | 10 minutes                  | 60 minutes              | ❌ DIRECT      |
| Failure threshold → OPEN | 3 → OPEN                    | 3 → HALF_OPEN, 4 → OPEN | ❌ DIRECT      |
| Fallback routing         | Yes (5 pairs defined)       | No (blocks all)         | ❌ DIRECT      |

### Physical Manifestation of the Conflict

Both state files now **exist simultaneously** in the repository:

- `production/session-state/circuit-state.json` — Rule 14 format (nested per-agent schema,
  written manually, never read by any hook)
- `.claude/memory/circuit-state.json` — ADR-004 format (flat global schema, read/written
  by `circuit-guard.sh`, `circuit-updater.sh`)

No hook reads `production/session-state/circuit-state.json`. The Rule 14 file is dead code.
The ADR-004 file is the only live state file.

---

## Decision

**ADR-004 wins for mechanism. Rule 14 wins for routing intelligence.**

Rather than declaring one spec "wrong", this ADR recognizes that the two specs solved
different problems. They can be integrated without contradiction:

- ADR-004's **global flat state** is the ground truth for circuit state. Simple, enforceable
  via hooks, no per-agent tracking overhead.
- Rule 14's **fallback pairs** are routing guidance that remains valid and useful — they tell
  the orchestrator *where to go* when the circuit is not CLOSED. This knowledge is not in
  conflict with a global state machine; it complements it.

### Authoritative Definitions (this ADR)

**State file:** `.claude/memory/circuit-state.json` (ADR-004 path, single source of truth)

**State scope:** Global flat. The circuit reflects the *session's overall Task execution health*,
not individual agent health. Per-agent isolation is handled by Rule 7 (sequential vs parallel
classification) and Rule 16 (A2A handoff contracts), not the circuit breaker.

**Failure thresholds** (ADR-004 spec, more graduated):

```
Failure 1 in CLOSED   → stay CLOSED, backoff 2s
Failure 2 in CLOSED   → stay CLOSED, backoff 4s
Failure 3 in CLOSED   → → HALF_OPEN, backoff 8s
Failure 1 in HALF_OPEN → stay HALF_OPEN
Failure 2 in HALF_OPEN → → OPEN (circuit blown)
```

**TTL:** 60 minutes (ADR-004 value). The Rule 14 value of 10 minutes was insufficiently
conservative for the types of persistent failures this circuit is designed to catch.

**Fallback pairs** (preserved from Rule 14, re-contextualized):

Fallback pairs are now routing *suggestions* for the orchestrator (`@producer`, `@cto`) when
the circuit is HALF_OPEN or OPEN — not per-agent state machines. The decision to route or to
surface to human remains with the orchestrator.

| Primary agent        | Suggested fallback    |
| :------------------- | :-------------------- |
| `backend-developer`  | `fullstack-developer` |
| `frontend-developer` | `fullstack-developer` |
| `qa-tester`          | `qa-lead`             |
| `data-engineer`      | `backend-developer`   |
| `investigator`       | `solver`              |

When circuit is **HALF_OPEN**: orchestrator MAY route to fallback for any sub-task that is
non-critical. For critical tasks, prefer the primary agent (HALF_OPEN is the probe phase).

When circuit is **OPEN**: orchestrator SHOULD route to fallback for all Task dispatches,
OR surface to human if no suitable fallback exists, per Rule 6 Layer 4.

### Updated Rule 14 Semantics

Rule 14 is updated in-place to reference ADR-004 + ADR-005 for mechanism and retain only
the fallback pairs table. The full state machine description (states, thresholds, TTL, file
path) is removed from Rule 14 to avoid future drift.

---

## Migration

### Step 1 — Delete legacy state file ✅ (Sprint A Item 3)

```bash
git rm production/session-state/circuit-state.json
```

No hooks read this file. Safe to delete immediately. This was the v1.30.0 Rule 14 state file.

### Step 2 — Update coordination-rules.md Rule 14

Replace the current Rule 14 implementation detail block with a lean version that:
- Delegates mechanism to ADR-004 + ADR-005
- Retains the fallback pairs table (routing intelligence)
- Removes the duplicate state file reference, TTL, and threshold definitions

### Step 3 — No hook changes required

`circuit-guard.sh` (Phase 1), `decision-ledger-writer.sh` (Phase 2), and
`circuit-updater.sh` (Phase 3) already implement ADR-004 spec and are correct per this ADR.
No code changes needed.

---

## Consequences

**Positive:**
- Single source of truth for circuit state — no more dual-file ambiguity
- Fallback pairs preserved where they add value (routing guidance)
- Hooks already correct — no code changes
- Rule 14 becomes lean, delegates complexity to authoritative ADR docs

**Negative:**
- Per-agent circuit state (the Rule 14 vision) is officially abandoned. Future work
  that requires per-agent isolation must use Rule 7 + Rule 10 (worktree isolation) instead.
- Rule 14 loses its implementation detail — developers must read ADR-004 + ADR-005 for
  the full picture.

**Neutral:**
- TTL change: 10min → 60min. May allow OPEN state to persist longer before auto-recovery.
  Accepted as the conservative choice for persistent failures.

---

## References

- `coordination-rules.md` Rule 14 — original per-agent circuit breaker spec (v1.30.0)
- `docs/internal/adr/ADR-004-unified-failure-state-machine.md` — global UFSM mechanism
- `.claude/hooks/circuit-guard.sh` — Phase 1: reads state
- `.claude/hooks/decision-ledger-writer.sh` — Phase 2: logs decision
- `.claude/hooks/circuit-updater.sh` — Phase 3: writes state transitions
- `.claude/memory/circuit-state.json` — authoritative state file
- `production/session-state/circuit-state.json` — deprecated, pending deletion (Sprint A Item 3)
