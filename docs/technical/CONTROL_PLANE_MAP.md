# Control-Plane Map

> **Spec reference:** §15.1 of [`ARCHITECTURE_SPEC_CLAUDE_SYSTEM.md`](ARCHITECTURE_SPEC_CLAUDE_SYSTEM.md)
> **Audit reference:** P1 item in [`AUDIT_2026-04-19.md`](../internal/AUDIT_2026-04-19.md) §5
> **Version:** 1.0 (2026-04-19)
> **Status:** Initial version. This document is the single source of truth for "what stage is the work in, which skill and agent run there, and what has to be true to exit the stage." If this document disagrees with a runtime artifact, the runtime wins and this document is the bug.

---

## 1. Purpose

The `.claude` system enforces work through a layered control plane: workflow commands mark stages, hooks fire at lifecycle events, skills supply expertise, agents own domains, and a human approves at every decision point. Until now, that plane has only been described in fragments across `CLAUDE.md`, `coordination-rules.md`, the skills registry, and the agent frontmatter. This document pulls the fragments into one table so an agent (or a new contributor) can answer four questions at a glance:

1. What stage is this task in?
2. Which skill supplies the method, and which agent owns the domain?
3. What has to be true before we can leave the stage?
4. Who or what is the fallback when the primary path fails?

## 2. How to read the map

- **Task type** — the kind of request that comes in (new feature, bug fix, audit, …).
- **Stage** — the `/command` gate that governs the stage. A task flows through the stages top-to-bottom; skipping a stage requires an explicit user waiver.
- **Primary skill** — the skill whose `SKILL.md` is the authoritative method for that stage.
- **Owning agent(s)** — the agent whose frontmatter domain covers the stage's artifact.
- **Exit criteria** — the concrete, testable check that must pass before advancing. "Looks good" is not an exit criterion (Rule 12 — Verifiable Plan Format).
- **Fallback / escalation** — where to route on persistent failure (Rule 14) or on domain conflict (Rule 3).
- **State update** — the file(s) that must be touched as the stage closes, so recovery and audit work.

---

## 3. Canonical stage ladder

These stages cover the fullstack feature path. Every other task type in §5 references this ladder.

| # | Stage (command) | Primary skill | Owning agent(s) | Exit criteria | Fallback / escalation | State update |
|---|---|---|---|---|---|---|
| 1 | `/plan` | `planning-and-task-breakdown` | `producer` (coordinator), `product-manager` (requirements) | Atomic markdown task checklist exists. Every step has an inline `verify:` clause. User has approved. | If scope is ambiguous → `product-manager`. If effort unknown → `producer` requests estimate from specialist. | Append plan to the relevant `.tasks/NNN-*.md` file. Update `production/session-state/active.md` status block. |
| 2 | `/spec` | `spec-driven-development` | `lead-programmer` (code spec), `cto` / `technical-director` (architecture), `ui-spec-designer` (UI) | Blueprint is written to `design/specs/…` or `docs/ui-spec/…`. API contracts locked (Rule 13). User has approved. | PRD conflict → `product-manager`. Architecture conflict → `technical-director`. UI ambiguity → `ui-spec-designer` + `ux-designer`. | New spec file committed OR ADR created at `docs/internal/adr/` if the decision is architectural. Ledger entry (Rule 15). |
| 3 | `/vertical-slice` (optional, fullstack) | `vertical-slicing` | `fullstack-developer`, with `backend-developer` + `frontend-developer` in support | Each slice covers DB → API → UI and is independently verifiable. API contract between layers locked per Rule 13. | `fullstack-developer` if any single-layer slice expands to multi-layer. | Task list in `.tasks/…` updated with slice checklist. |
| 4 | `/tdd` | `test-driven-development` | The implementing specialist (backend / frontend / data / ai / ui / mobile / network) | 🔴 RED log: failing test captured in terminal. 🟢 GREEN log: test passes. No claim of success without logs. | Persistent failure 3× → Rule 14 circuit fallback (see §6). Test framework disagreement → `qa-engineer`. | Test file(s) + source diff. Optional ledger entry for Medium/High risk decisions. |
| 5 | Review | `code-review` / `design-review` | `lead-programmer` (code), `ux-designer` (design), `security-engineer` (security scope), `accessibility-specialist` (a11y scope) | Review checklist passed. Critical comments resolved or explicitly deferred with owner + ticket. | Any single reviewer blocks → cannot merge. Cross-domain conflict → Rule 3 escalation. | Review notes captured in PR body or linked markdown. Ledger entry if High risk. |
| 6 | Merge / deliver | `commit` / `changelog` | `producer` (coordinates), `devops-engineer` (pipeline) | Working tree clean. CI green. `docs/internal/CHANGELOG.md` updated. User approved commit + push. | CI red → return to `/diagnose`. Release gate failure → `release-manager`. | `docs/internal/CHANGELOG.md`, git history. Ledger entry for release cut. |

---

## 4. Incident & investigation path

Used when something is already broken (prod bug, stuck test, regression).

| # | Stage (command) | Primary skill | Owning agent(s) | Exit criteria | Fallback / escalation | State update |
|---|---|---|---|---|---|---|
| 1 | `/diagnose` — Investigate | `diagnose` | `diagnostics` (Investigation role) | A reproducible failure path is documented: input → observed behavior → expected behavior. Evidence cited by file:line. | `diagnostics` circuit open → surface to human or route to the owning specialist. | `active.md` "Open Questions" section updated. |
| 2 | `/diagnose` — Verify | `diagnose` | `diagnostics` (Verification role) | Devil's-advocate check passed: root cause survives triangulation. False causes ruled out. | Verification disagrees with investigation → surface both reports to user; do not proceed to solution. | Ledger entry (High risk). |
| 3 | `/diagnose` — Solve | `diagnose` | `diagnostics` (Solution role) | Fix proposed with tradeoffs listed. User chose an option. | If fix requires architecture change → `technical-director`. | Plan appended to `.tasks/…`. |
| 4 | Return to `/tdd` | `test-driven-development` | implementing specialist | Regression test added first; then fix; then GREEN. | As stage 4 in §3. | Test diff + source diff. |

---

## 5. Task-type routing table

Maps incoming intent to the correct first stage.

| Task type | First stage | Typical path | Notes |
|---|---|---|---|
| Brand-new feature | `/plan` | plan → spec → vertical-slice → tdd → review → merge | Start from §3 row 1. |
| Small enhancement | `/spec` | spec → tdd → review → merge | Skip `/plan` only for single-file, reversible edits. |
| Bug fix (reproducible) | `/diagnose` | diagnose → tdd → review → merge | Use §4. |
| Bug fix (flaky, intermittent) | `/diagnose` | diagnostics investigation → verification → solution → tdd | Verification stage is non-optional here. |
| Architecture change | `/spec` | spec (with ADR) → affected slices → review → merge | ADR at `docs/internal/adr/` is a hard requirement. |
| UI change | `/ui-spec` | ui-spec → tdd → review → merge | `ui-spec-designer` owns the spec; `frontend-developer` or `ui-programmer` implements. |
| Refactor (5+ files) | `/plan` + worktree isolation (Rule 10) | plan → slice-by-slice tdd → review → merge | `isolation: worktree` is required. |
| Audit / review-only | none | read-only subagents in parallel (Rule 7) | Never writes; produces a report under `docs/internal/`. |
| Onboarding / `/start` | `/start` | guided questionnaire → configure CLAUDE.md → seed PRD | First-session path only. |
| Memory consolidation | `/dream` | triggered automatically when `MEMORY.md` exceeds 40 lines | Fail-open (Rule 9). |

---

## 6. Fallback & escalation ladder

The order of operations when a stage does **not** meet its exit criteria.

1. **Layered Recovery (Rule 6)** — retry with fresh context, then delegate to a subagent with full diagnosis, then `/compact` and retry. Only after all three fail do we move to step 2.
2. **Circuit Breaker (Rule 14 + ADR-004 + ADR-005)** — if Task-tool failures persist, read `.claude/memory/circuit-state.json`:
   - `CLOSED` → continue.
   - `HALF_OPEN` → route non-critical sub-tasks to the fallback agent; keep critical sub-tasks on primary.
   - `OPEN` → route all dispatches to the fallback, or surface to human if no fallback exists.
3. **Fallback pairs** (from Rule 14):
   | Primary | Fallback |
   |---|---|
   | `backend-developer` | `fullstack-developer` |
   | `frontend-developer` | `fullstack-developer` |
   | `qa-engineer` | `fullstack-developer` |
   | `data-engineer` | `backend-developer` |
   | `diagnostics` | `fullstack-developer` |
4. **Domain escalation (Rule 3)** — conflicts between equal-tier agents escalate to the shared parent (or `cto` for design, `technical-director` for technical).
5. **Surface to human** — Rule 6 Layer 4. Every prior attempt must be documented in the report (Rule 8 — no withheld errors).

Every Circuit Breaker state transition is a mandatory ledger entry (`production/traces/decision_ledger.jsonl`, `risk_tier: "High"`).

---

## 7. State update points

The files that the control plane must touch to keep recovery and audit working. If a stage closes without updating these, the stage is incomplete.

| State file | Updated by | When | Purpose |
|---|---|---|---|
| `production/session-state/active.md` | `session-start.sh` (bootstrap), implementing agent (status block), `session-stop.sh` (close) | On session start, after every significant milestone, and at session end | Crash recovery, `/compact` survival |
| `.claude/memory/circuit-state.json` | `circuit-guard.sh`, `circuit-updater.sh` | Before / after every Task tool call | Circuit Breaker authoritative state |
| `production/traces/decision_ledger.jsonl` | `decision-ledger-writer.sh`, `log-commit.sh` | On any Medium/High risk decision, Circuit Breaker transition, handoff, task outcome | Audit trail |
| `.tasks/handoffs/<from>-to-<to>-<task_id>.json` | Sending agent via `/handoff` | High-risk cross-domain handoff or explicit durable handoff request | Optional durable A2A contract layered on top of the lightweight 3-field summary |
| `docs/internal/adr/ADR-NNN-*.md` | Architecture decision author | Any architecture-level decision that constrains future work | Durable architectural record |
| `.claude/memory/MEMORY.md` + Tier 2 files | `persist-memory.sh`, agent via `/annotate` | Whenever a non-obvious gotcha or durable preference is learned | Cross-session knowledge (auto memory system) |

---

## 8. Human decision points vs. AI proposal points

The control plane is explicit about which steps require a human and which are AI proposals that the human accepts or rejects.

| Step | Who decides | Why |
|---|---|---|
| Task scope (what are we building?) | **Human** | Product intent. |
| Plan / task checklist | AI proposes → **Human approves** | Rule 12 — no implementation before plan approval. |
| Architecture / spec / ADR | AI proposes → **Human approves** | L2 of precedence (see `skills-precedence.md`). |
| Skill and agent selection | **AI** (governed by this document + Rule 7 concurrency) | Routing is deterministic from the task type. |
| Test strategy (what to test) | AI proposes → **Human approves** on sensitive paths | Coding Standards — verification-driven development. |
| Code edits | AI proposes → **Human approves** (unless `acceptEdits` mode) | Rule 11 — Permission Mode Selection. |
| Commits | **Human** explicitly authorizes every commit | L1 Critical Rule — no commits without permission. |
| Push / release | **Human** explicitly authorizes | Same as above + `release-manager` gate for store submissions. |
| `/reset-circuit`, `/compact`, `/clear` | **Human** only | Session-affecting commands, not AI-driven. |

---

## 9. Open items tracked against this map

These are the known gaps the audit flagged; they are tracked here so the map stays honest.

- **Ledger write orchestrator** (P1) — `log-commit.sh` and `decision-ledger-writer.sh` both write to the ledger without an explicit ordering. Target: shared `ledger-append` helper. Until resolved, the "State update points" table §7 row for `decision_ledger.jsonl` is racy.
- **Hook Responsibility Matrix** (P2, §15.4 of the spec) — not yet written. Once it lands at `docs/technical/HOOK_RESPONSIBILITY_MATRIX.md`, every "State update" cell in §7 will cross-link to the hook that performs the write.
- **Memory Retrieval Map** (P2, §15.5) — not yet written. Will live at `docs/technical/MEMORY_RETRIEVAL_MAP.md` and will be the authoritative account of which tier loads when.
- **Stage Transition State Machine** (P2, §15.3) — a formal state-machine view of the §3 ladder; this document is a tabular precursor.

---

## 10. Change log

| Date | Change |
|---|---|
| 2026-04-19 | Initial version authored as part of P1 remediation for audit §5. Covers stage ladder, incident path, task-type routing, fallback ladder, state update points, and human vs. AI decision rights. |
