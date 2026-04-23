# Rebuttal: Harness Engineering to Coordination Engineering

> Date: 2026-04-23
> Type: Architecture review rebuttal and value-add proposal
> Related report: `docs/internal/harness-to-coordination-engineering.md`
> Scope: SDD-wide coordination strategy, with Claude-native runtime preserved and
> Codex treated as an adapter client.

---

## 1. Executive Position

The core thesis of the report is directionally correct:

```text
Harness Engineering -> Shared State Engineering -> Coordination Engineering
```

SDD should not jump directly into autonomous coordination or negotiation between
agents. The next valuable layer is shared, auditable state that lets agents read
the same operational truth without relying on chat history or producer summaries.

However, the upgrade must not add parallel sources of truth. SDD already has
working coordination primitives:

- `docs/technical/API.md` for API surface documentation
- `design/specs/` for feature-level specifications
- `.claude/docs/coordination-rules.md` for coordination policy
- `production/traces/decision_ledger.jsonl` for decision audit
- `/trace-history` and `scripts/trace-history.sh` for ledger querying
- `.tasks/handoffs/` and `/handoff` for formal high-risk handoffs

Therefore the next phase should be framed as:

```text
Shared State Adoption and Source-of-Truth Consolidation
```

not simply "add more shared-state artifacts."

---

## 2. Response to Review Findings

### Finding 1: Contract Store Risks a Second API Source of Truth

**Finding accepted.**

The proposed `design/contracts/` directory is useful only if its authority is
strictly bounded. Without precedence rules, it competes with `docs/technical/API.md`,
`design/specs/`, `/api-design`, and backend ownership.

Recommended correction:

- Treat `design/contracts/` as a pre-implementation interface lock, not the final
  API reference.
- Treat `docs/technical/API.md` as the implemented API source of truth.
- Require every stable contract to link to the feature spec that justifies it.
- Require every implemented contract to be reflected in `docs/technical/API.md`.
- Route conflicts through `spec-evolution` or an ADR, depending on durability.

Suggested source-of-truth matrix:

| Artifact | Purpose | Owner | Authority | Conflict winner |
| --- | --- | --- | --- | --- |
| `design/specs/*` | Feature intent, behavior, acceptance | `lead-programmer` / `product-manager` | Approved feature behavior | Approved spec unless evolved |
| `design/contracts/*` | Pre-implementation interface lock | `lead-programmer` / `backend-developer` | Draft or stable interface between agents/layers | ADR or approved spec |
| `docs/technical/API.md` | Implemented API reference | `backend-developer` | Current implemented API contract | Runtime implementation after review |
| ADR | Durable architecture decision | `technical-director` | Architecture-level constraint | ADR supersedes lower-level docs |

Decision rule:

```text
Spec explains why.
Contract locks what to build.
API.md documents what exists.
ADR decides what must remain true.
```

### Finding 2: Trace-History Gap Is Factually Wrong

**Finding accepted.**

The report should not say `/trace-history` still needs to be implemented.
It already exists as `.claude/skills/trace-history/SKILL.md` and delegates to
`scripts/trace-history.sh`.

The real gap is adoption:

- Agents write ledger entries, but do not consistently query prior decisions.
- Planning and ADR workflows do not always require a ledger read before new
  architectural decisions.
- Review workflows do not always check whether a rejected or superseded decision
  already exists.

Recommended correction:

```text
Gap: decision ledger has write and query paths, but lacks mandatory read gates
for high-risk planning, ADRs, coordination-rule changes, and repeated failures.
```

High-value addition:

- Before ADR: run `/trace-history --risk High --last 20`.
- Before coordination-rule changes: query related prior blocked/fail entries.
- Before retrying a failed orchestration: query `--outcome blocked` and `--outcome fail`.
- Before deleting or weakening a protocol: query adoption/failure history.

### Finding 3: Shared State Must Not Bypass Orchestrator Authority

**Finding accepted.**

Shared state should reduce the producer's burden as a text relay, but it must not
weaken the human-governed operating model.

Recommended wording:

```text
Agents should read shared source-of-truth artifacts directly for visibility.
Decision authority, conflict resolution, and scope approval remain with the
human, producer, technical-director, and Rule 3 escalation paths.
```

This distinction is important:

- Shared state improves observability.
- It does not grant autonomous authority.
- It does not let agents self-negotiate binding decisions outside SDD hierarchy.

### Finding 4: Readiness Table Overstates Completion

**Finding accepted.**

The report should distinguish between having an artifact and having an adopted,
operational capability.

Suggested status labels:

| Status | Meaning |
| --- | --- |
| Baseline exists | Artifact/policy exists and can be used manually |
| Operational | Runtime path exists and is used in normal workflows |
| Needs adoption | Capability exists but is not consistently invoked |
| Needs tooling | Policy exists but lacks ergonomic automation |
| Needs consolidation | Multiple artifacts overlap or conflict |

Revised interpretation:

| Capability | Current state |
| --- | --- |
| Agent identity and domain | Operational |
| Delegation hierarchy | Baseline exists |
| Routing and fallback | Operational with open consolidation items |
| Failure handling | Operational |
| Session persistence | Operational |
| Decision ledger | Operational write path, needs read adoption |
| Handoff protocol | Baseline exists, downgraded due to friction |
| API contract discipline | Baseline exists, needs source-of-truth consolidation |

---

## 3. Additional Value to Add to SDD

### 3.1 Add a Source-of-Truth Registry

Before introducing any new coordination artifact, SDD should define which files
own which truth.

Proposed file:

```text
docs/technical/SOURCE_OF_TRUTH_REGISTRY.md
```

Minimum fields:

```yaml
artifact:
purpose:
owner:
authority_level:
updated_by:
updated_when:
conflict_resolution:
verification:
```

This would reduce drift across specs, ADRs, API docs, task files, handoff files,
and ledgers.

### 3.2 Add Read Gates Before Write Gates

SDD already has many write paths. The next value is to force important workflows
to read relevant shared state before producing more artifacts.

Recommended read gates:

| Workflow | Required read gate |
| --- | --- |
| ADR | `/trace-history --risk High --last 20` |
| API design | existing `docs/technical/API.md`, related specs, related contracts |
| Orchestration | active task state, circuit state, prior blocked ledger entries |
| Handoff | latest contract/spec/API state for the artifact being handed off |
| Review | source-of-truth registry for changed artifact type |

This turns shared state from archive into operational memory.

### 3.3 Prefer Adoption Metrics Over New Infrastructure

Shared state should be validated by usage, not existence.

Suggested metrics:

| Metric | Why it matters |
| --- | --- |
| Contract reference rate | Shows whether cross-layer agents read the same interface |
| Ledger read-before-decision rate | Shows whether prior decisions prevent repeated reasoning |
| Handoff completion rate | Shows whether lightweight handoffs are usable |
| Desync incidents | Tracks frontend/backend/API mismatch reduction |
| Protocol rollback triggers | Prevents Rule 16-style over-design from persisting |

### 3.4 Introduce a Minimal Contract Lifecycle

If `design/contracts/` is adopted, use a small lifecycle:

```text
proposed -> reviewed -> stable -> implemented -> deprecated
```

Rules:

- `proposed`: can be discussed, not implemented against.
- `reviewed`: checked by owning lead, may still change.
- `stable`: implementation may begin.
- `implemented`: reflected in `docs/technical/API.md`.
- `deprecated`: superseded or no longer used.

This keeps the contract store useful without making it another permanent source
of drift.

### 3.5 Add a Coordination Audit Before Coordination Automation

Automation should come after contract clarity.

Potential script:

```text
scripts/coordination-audit.js
```

Initial checks:

- Stable contract not linked from a spec.
- Implemented contract not reflected in `docs/technical/API.md`.
- Medium/High handoff missing ledger entry.
- Repeated blocked decisions without linked follow-up.
- Task marked complete without verification reference.
- Shared-state artifact added without source-of-truth registry entry.

This adds value without changing Claude runtime behavior.

---

## 4. Revised Roadmap

### Phase 0: Correct the Report

Required edits:

- Replace "trace-history not implemented" with "trace-history lacks adoption/read gates."
- Reword shared state so it improves visibility without bypassing authority.
- Replace "complete" labels with operational maturity labels.
- Add `docs/technical/API.md` to the API contract source-of-truth discussion.

### Phase 1: Source-of-Truth Registry

Deliverable:

```text
docs/technical/SOURCE_OF_TRUTH_REGISTRY.md
```

Verify:

- Registry covers specs, ADRs, API docs, handoffs, task files, ledger, memory,
  and any proposed contract store.
- Every artifact has owner, authority, update trigger, and conflict winner.

### Phase 2: Ledger Read Gates

Deliverable:

- Update relevant skills or docs to require `/trace-history` before high-risk
  ADRs, repeated failures, and coordination-rule changes.

Verify:

- At least one real decision cites a prior ledger entry.
- `/trace-history` output is used in a planning or ADR decision.

### Phase 3: Contract Store Pilot

Deliverable:

- Contract template only.
- One pilot contract for one feature.
- No broad automation.

Verify:

- Contract is linked from feature spec.
- Backend and frontend both reference it.
- Implemented endpoint is reflected in `docs/technical/API.md`.

### Phase 4: Coordination Audit

Deliverable:

```text
scripts/coordination-audit.js
```

Verify:

- Detects at least one intentionally malformed fixture or test scenario.
- Runs without modifying Claude runtime files.

---

## 5. Final Recommendation

Keep the report's main thesis, but tighten it:

```text
The next SDD upgrade is not full Coordination Engineering.
It is Shared State Adoption with explicit source-of-truth authority.
```

The highest-value next artifact is not `design/contracts/`.
It is:

```text
docs/technical/SOURCE_OF_TRUTH_REGISTRY.md
```

Once source authority is clear, contract store, ledger read gates, lightweight
handoffs, and coordination audits can be added without increasing ambiguity.

