# ADR-006: Shared State Adoption as Tier 2 Evolution of SDD Coordination

**Status:** Accepted
**Date:** 2026-04-23
**Deciders:** User, technical-director
**Related analysis:** `docs/internal/harness-to-coordination-engineering.md` (Revision 2)
**Rebuttal source:** `docs/internal/harness-to-coordination-engineering-rebuttal.md`
**Complements:** Rule 15 (Decision Tracing Ledger), Rule 11 (Permission Modes)
**Does NOT supersede:** Rule 3 (Conflict Resolution), Rule 6 (Layered Recovery), Rule 16 (A2A Handoffs)

---

## Context

SDD has successfully built **Tier 1 (Harness Engineering)** — agents can exist, route, fall
back, recover from failures, and persist session state. The question is what the next
durable architectural direction should be.

### The original proposal: "Coordination Engineering"

An early framing proposed jumping directly to Coordination Engineering — autonomous
negotiation and conflict resolution between agents. Analysis (primary doc + rebuttal)
concluded this is premature for current SDD scale.

### The observable gap

Across sessions, two recurring problems appeared:

1. **Authority ambiguity.** Multiple artifacts claim overlapping scope over the "same truth":
   - `design/specs/` (feature behavior)
   - `.claude/docs/coordination-rules.md` (coordination policy)
   - `decision_ledger.jsonl` (decisions)
   - `docs/technical/API.md` (intended but not yet created)
   - Ad-hoc ADRs

   Without a declared owner and conflict winner per artifact type, every conflict is
   re-litigated from scratch.

2. **Write-only infrastructure.** Decision ledger has an operational write path
   (23+ entries as of 2026-04-23) and a working query tool (`/trace-history` skill +
   `scripts/trace-history.sh`) — but no workflows require reads before writing new
   decisions. Prior decisions are silently ignored.

### The precedent: Rule 16 friction failure

Rule 16 (A2A Handoff Contracts) was downgraded from MUST to SHOULD on 2026-04-21
after multiple sessions produced zero handoff contracts:

> "No handoff contracts were generated across multiple sessions, indicating the
> full protocol has too much friction."

This is the cautionary tale: **broad mandates at the wrong abstraction level produce
zero adoption**. Any Tier 2 artifact must be designed with this failure mode in mind.

---

## Decision

### Three-tier coordination model

```
Tier 1: Harness Engineering              → agents can EXIST
Tier 2: Shared State Adoption &          → agents SHARE TRUTH
        Source-of-Truth Consolidation      (through bounded authority)
Tier 3: Coordination Engineering         → agents can NEGOTIATE & RESOLVE conflicts
```

**Tier 1 is complete. This ADR commits SDD to Tier 2 as the next direction.
Tier 3 is deferred until measurable triggers justify it.**

### Tier 2 scope and priority

Tier 2 is **adoption-first, not build-heavy**. Priority ordering (from lowest to highest
implementation risk):

| Priority | Artifact | Type | Rationale |
|---|---|---|---|
| 0 | `docs/technical/SOURCE_OF_TRUTH_REGISTRY.md` | New file | Declare authority before building anything |
| 0.5 | `docs/technical/API.md` skeleton | New file | Required target for contract "implemented" state |
| 1 | Decision Log read gates | Adoption of existing infra | `/trace-history` already exists; compliance gap only |
| 2 | `design/contracts/` pilot | New artifact (one pilot only) | Pre-implementation interface lock |
| 3 | Lightweight handoff schema (3 fields) | New artifact + `/orchestrate` integration | Replace Rule 16's full protocol |

### Authority boundary (non-negotiable)

Shared state is a **READ LAYER, not a DECIDE LAYER**.

| Shared state DOES | Shared state DOES NOT |
|---|---|
| Improve observability for agents | Grant autonomous authority to agents |
| Reduce producer's text-relay burden | Let agents self-negotiate binding decisions |
| Let agents read the same truth directly | Bypass Rule 3 (escalation) or Rule 11 (permissions) |
| Reduce friction in handoffs | Replace human approval for multi-file changes |

Decision authority, conflict resolution, and scope approval remain with **human,
producer, technical-director, and Rule 3 escalation paths**.

### Tiered enforcement (anti-Rule-16)

Mandates must be narrow by risk tier to avoid Rule 16 redux:

| Enforcement | Scope | Examples |
|---|---|---|
| **MUST** query ledger before | ADR, coordination-rule change, high-risk retry, protocol removal | High-risk only |
| **SHOULD** consult ledger before | API design in existing domain, feature spec in existing domain | Medium-risk, non-blocking |
| **SKIP** (no gate) | Bug fix, cosmetic, doc typo, one-line fix, low-risk style | Low-risk |

**Broad MUST across all workflows is explicitly forbidden.** Any attempt to widen MUST
scope beyond the table above requires a new ADR.

### Trigger for Tier 3 (not now)

Tier 3 (Coordination Engineering) activates only when at least one threshold is met,
measured over a full quarter:

| Condition | Threshold | Data source |
|---|---|---|
| Concurrent-write conflicts | ≥ 3/sprint requiring manual merge | git log, `active.md` conflict markers |
| Decisions requiring automated negotiation | ≥ 2/sprint producer escalates Rule 3 | `decision_ledger.jsonl` outcome:blocked |
| Orchestrator complexity | Routinely spawning > 5 agents/task | `agent-metrics.jsonl` |

As of 2026-04-23, none met. Review end of each quarter.

### Trigger for coordination-audit script (conditional)

An automation script (`scripts/coordination-audit.js`) is deferred until BOTH:

1. Adoption ≥ 70% across Tier 2 artifacts over 2 consecutive sprints, AND
2. ≥ 2 drift incidents occur despite adoption (i.e. artifacts used but inconsistent).

**Low adoption is not an audit trigger** — it is a rollback trigger per the
Anti-pattern Watch below. Audit catches drift in well-adopted systems; it does not
compensate for missing adoption.

---

## Migration

### Sprint 0: Source-of-Truth Registry

**Deliverable:** `docs/technical/SOURCE_OF_TRUTH_REGISTRY.md`

**Schema per entry:**

```yaml
artifact:            # file or pattern
purpose:             # one-line purpose
owner:               # agent ID or human role
authority_level:     # feature-behavior | interface-lock | impl-reference | architecture-constraint
updated_by:          # who may update
updated_when:        # update trigger
conflict_resolution: # winner + escalation path
verification:        # how to check entry is still correct
```

**Minimum coverage:** 8 artifact types — `design/specs/`, ADR, `docs/technical/API.md`,
`.tasks/handoffs/`, `.tasks/NNN-*.md`, `decision_ledger.jsonl`, `.claude/memory/`,
proposed `design/contracts/`.

**Drafting assignment:** Codex GPT 5.4 (proposed the artifact; meticulous enumeration
suits its strength). Claude Opus reviews.

**Verify:** registry covers ≥ 8 artifact types; every entry has `owner` +
`conflict_resolution`; technical-director review passes.

### Sprint 0.5: API.md skeleton

**Deliverable:** `docs/technical/API.md` with structure but no populated endpoints
(endpoints table, schema conventions, deprecation policy headers).

**Verify:** file exists with structure; registry entry added.

### Sprint 1: Decision Log read-gate adoption

**Workflow-to-artifact mapping** *(added per P2 rebuttal 2026-04-23 — resolves
ambiguity about which file must change and who owns it)*:

| Workflow label | Concrete artifact to update | Owner | How compliance is checked |
|---|---|---|---|
| ADR workflow | `.claude/skills/architecture-decision-records/SKILL.md` | technical-director | ADR body contains `/trace-history` output or cite |
| Coordination-rule change | `.claude/docs/coordination-rules.md` preamble + any PR that edits it | technical-director | PR description must include ledger query result |
| High-risk retry | `.claude/docs/coordination-rules.md` Rule 6 (Layered Recovery) — step 3 explicit mention | technical-director | Ledger entry for retry includes `prior_blocked_query: true` field |
| Protocol-removal | `.claude/docs/coordination-rules.md` Rule 16 note + any PR removing a MUST rule | technical-director | PR description cites `/trace-history --outcome blocked` for that protocol |
| API design (SHOULD) | `.claude/skills/api-design/SKILL.md` | lead-programmer | Voluntary; tracked via sprint retro, not enforced |
| Spec evolution (SHOULD) | `.claude/skills/spec-evolution/SKILL.md` | lead-programmer | Voluntary; tracked via sprint retro, not enforced |

**Deliverable:**

- **MUST tier:** Edit the 4 artifacts in the mapping table above (ADR skill,
  coordination-rules Rule 6, coordination-rules Rule 16 note, protocol-removal PR
  template) to require `/trace-history` query before proceeding.
- **SHOULD tier:** Add one-line ledger-consult recommendation to `spec-evolution`
  and `api-design` skills. Non-blocking.
- **SKIP tier:** No gate for low-risk workflows.

**Verify:** ≥ 1 ADR cites prior ledger entry; ≥ 1 high-risk retry ledger entry
includes `prior_blocked_query` field; SHOULD-tier skills contain the recommendation
text; no blanket mandate wider than the mapping table above is introduced.

### Sprint 2: Contract Store pilot

**Dependency:** Sprint 0.5 complete.

**Deliverable:** contract template + `design/contracts/` directory + exactly one
pilot contract for one real feature. No broad rollout.

**Verify:** pilot contract links from feature spec; both `backend-developer` and
`frontend-developer` reference it in their PR; implemented endpoint is reflected
in `docs/technical/API.md`.

### Sprint 3: Lightweight handoff schema

**Deliverable:** 3-field schema (`what was built`, `what's missing`,
`acceptance criteria`) auto-inserted by `/orchestrate` on cross-domain handoffs.

**Verify:** 3 consecutive cross-domain handoffs carry schema without user
intervention; ≥ 70% adoption rate after sprint.

### Gate check before Tier 3

End of Q2 2026, Tier 3 is considered only if ALL hold:

1. At least one Tier 3 trigger (from Decision section) has met threshold.
2. No anti-pattern red flag (Consequences section below) is active, including
   Registry-specific red flags.
3. Tier 2 adoption ≥ 50% across artifacts.
4. Registry reviewed at least once by technical-director.

If not all hold, **continue iterating at Tier 2**. Do not build Tier 3.

---

## Consequences

### Positive

- **Authority clarity first.** Registry prevents future coordination artifacts from
  competing with existing ones.
- **Re-use over rebuild.** Sprint 1 exploits infra that already exists (`/trace-history`
  skill, `scripts/trace-history.sh`, 23+ ledger entries). No duplicate tooling.
- **Rule-16 protection built in.** Tiered enforcement + conditional audit script +
  explicit anti-trigger list prevent broad-mandate friction.
- **Reversibility.** Every Tier 2 artifact has a declared rollback condition
  (Anti-pattern Watch). Sunk cost does not win.

### Negative

- **Registry itself can become bureaucracy.** Mitigated by applying the same
  rollback criteria to Registry as to other artifacts (see Anti-pattern Watch).
- **Two-file requirement for API state.** Contracts (pre-impl) and API.md (post-impl)
  must both be maintained. Contract lifecycle (`proposed → reviewed → stable →
  implemented → deprecated`) explicitly handles the transition.
- **Tier 3 deferred indefinitely.** If SDD scales to require autonomous negotiation
  but triggers are never measured or reviewed, Tier 3 could be deferred forever.
  Mitigated by mandatory quarterly review.

### Neutral

- **No existing file is deleted.** This ADR is purely additive plus a one-time
  creation of `docs/technical/API.md` skeleton.
- **No hook changes required for Sprints 0–1.** Sprint 2+ may introduce hook-level
  automation, which will require separate review.

### Anti-pattern Watch (rollback conditions)

Any Tier 2 artifact must be rolled back / simplified if a red flag activates:

| Red flag | Artifact | Threshold | Action |
|---|---|---|---|
| Bypass rate high | `design/contracts/` | > 30% handoffs skip contract | Reduce required fields |
| Churn without reads | `decision_ledger.jsonl` | No agent reads entries over 2 sprints | Remove read-gate mandate |
| Schema expansion | Handoff schema | > 5 required fields | Reject; keep at 3 fields |
| Broad low adoption | Any new artifact | < 50% after 3 sprints | Treat like Rule 16: MUST → SHOULD or remove |
| Registry stale | `SOURCE_OF_TRUTH_REGISTRY.md` | > 30 days without refresh when artifacts added | Audit + prune |
| Registry bureaucracy | `SOURCE_OF_TRUTH_REGISTRY.md` | Adding 1 artifact requires updating > 3 files | Simplify schema |

Rollback is not a failure. It is the intended feedback loop.

---

## References

- `docs/internal/harness-to-coordination-engineering.md` — primary analysis (Revision 2)
- `docs/internal/harness-to-coordination-engineering-rebuttal.md` — Codex rebuttal
- `docs/internal/adr/ADR-004-unified-failure-state-machine.md` — circuit breaker mechanism
- `docs/internal/adr/ADR-005-resolve-rule14-vs-adr004-conflict.md` — precedent for resolving
  overlapping specs via authority boundary (same pattern applied here)
- `.claude/docs/coordination-rules.md` Rule 3, Rule 6, Rule 11, Rule 15, Rule 16
- `.claude/skills/trace-history/SKILL.md` — existing ledger query skill
- `scripts/trace-history.sh` — backing script
- `production/traces/decision_ledger.jsonl` — operational write path

---

## Appendix: What this ADR explicitly does NOT decide

To prevent scope creep, the following are deliberately out of scope:

- **Full Coordination Engineering architecture.** Deferred until triggers met.
- **Replacing Rule 16.** Sprint 3 creates a lightweight handoff schema alongside
  Rule 16 (which remains SHOULD). Whether to retire Rule 16 is a separate decision
  after Sprint 3 data.
- **Replacing existing ADRs or specs.** Registry documents authority; it does not
  change ownership of already-authored decisions.
- **Automation beyond `coordination-audit.js`.** Any further automation (CI gates,
  pre-commit hooks, auto-resolution) requires a new ADR with its own trigger analysis.
- **Cross-project / Codex adapter concerns.** This ADR is SDD-internal. Codex adapter
  behavior may evolve independently.
