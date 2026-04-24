# Source-of-Truth Registry

> Purpose: Define which SDD artifact owns which kind of truth before adding
> more shared-state or coordination artifacts.
> Status: Accepted for Sprint 0.
> Date: 2026-04-23.
> Related: `docs/internal/harness-to-coordination-engineering.md`.

---

## 1. Operating Principle

This registry does not replace the SDD control plane. It makes source ownership
explicit so agents can read shared state directly without bypassing human,
producer, technical-director, or Rule 3 authority.

Shared state is a read layer, not a decide layer.

When instructions conflict, use this order:

1. `CLAUDE.md` critical rules.
2. `.claude/docs/coordination-rules.md` and governing ADRs.
3. `.claude/settings.json` permissions and hooks.
4. Hook behavior registered in `.claude/settings.json`.
5. Active skill instructions.
6. This registry and other advisory docs.

If this registry disagrees with a runtime artifact, the runtime artifact wins and
this registry must be updated.

---

## 2. Registry Schema

Each entry uses these fields:

| Field | Meaning |
| --- | --- |
| Artifact | File or path pattern. |
| Purpose | The truth this artifact owns. |
| Owner | Agent or human role accountable for updates. |
| Authority level | Kind of truth owned by the artifact. |
| Updated by | Who may update it. |
| Updated when | Trigger for updates. |
| Conflict resolution | Which artifact or role wins on disagreement. |
| Verification | How to confirm the entry is still accurate. |
| Status | Current maturity or availability. |

Authority levels:

| Level | Meaning |
| --- | --- |
| constitution | Session-wide rules and non-negotiable behavior. |
| runtime-policy | Tool permissions, hook registration, runtime wiring. |
| coordination-policy | Multi-agent delegation, concurrency, fallback, handoff, and ledger policy. |
| agent-definition | Specialist agent role, ownership boundary, delegation rules, and behavioral contract. |
| architecture-constraint | Durable system or technology decision. |
| feature-behavior | Approved product or feature behavior. |
| interface-lock | Pre-implementation interface contract. |
| impl-reference | Implemented technical surface or source reference. |
| task-state | Backlog, task ownership, dependency, and execution status. |
| runtime-state | Current machine-readable runtime state governed by a higher policy artifact. |
| audit-trace | Historical decision, event, or verification evidence. |
| memory | Durable recall and session continuity state. |
| adapter-policy | Codex compatibility behavior that must not change Claude runtime. |

---

## 3. Source-of-Truth Entries

### 3.1 Core SDD Runtime

| Artifact | Purpose | Owner | Authority level | Updated by | Updated when | Conflict resolution | Verification | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `CLAUDE.md` | Claude-native constitution, critical rules, workflow command semantics, memory include references. | Human + technical-director | constitution | Human-approved edits only; technical-director may propose. | Critical rule, workflow command, memory include, or project-wide behavior changes. | `CLAUDE.md` wins over all lower layers. Human resolves L1 ambiguity. | Direct file review; Claude manual regression check. | Operational |
| `.claude/settings.json` | Claude Code permissions, hooks, status line, and runtime dispatcher. | Human + technical-director | runtime-policy | Human-approved edits only; technical-director may propose. | Tool permission, hook registration, or runtime dispatcher changes. | L1 and L2 may constrain it; skills cannot override it. | JSON parse plus direct diff review; Claude-only behavior must be manually verified. | Operational |
| `.claude/hooks/*` | Runtime side effects implementing hook behavior. | technical-director | runtime-policy | Hook owner with explicit approval. | Hook behavior changes, bug fixes, or new runtime events. | Hooks implement L1/L2/L3; if they disagree, the higher layer wins. | Hook Responsibility Matrix, direct script review, targeted runtime/manual checks. | Operational |
| `.claude/docs/coordination-rules.md` | Multi-agent delegation, concurrency, recovery, circuit breaker, ledger, and handoff policy. | technical-director + producer | coordination-policy | technical-director with human approval for behavior changes. | Coordination policy changes or new multi-agent failure modes. | Same-layer conflicts route to governing ADR or Rule 3 escalation. | Review against `CONTROL_PLANE_MAP.md`, ADRs, and harness audit. | Operational |
| `.claude/docs/skills-precedence.md` | Rule and skill precedence across L1-L5 layers. | technical-director | coordination-policy | technical-director. | Any new rule layer, command/skill overlap, or precedence ambiguity. | Higher layer wins; same-layer conflicts escalate as documented. | Direct file review; compare with `CLAUDE.md`, settings, hooks, and skills. | Operational |
| `.claude/agents/*.md` | Authoritative specialist agent definitions: role, scope, delegation boundary, and operating constraints. | technical-director | agent-definition | technical-director; domain leads may propose scoped updates. | Agent role, ownership, delegation, or responsibility changes. | Coordination rules and accepted ADRs constrain agents; the specific agent file owns specialist behavior within its domain. | Agent file review; compare with coordination rules, control-plane ownership, and harness audit. | Operational |
| `.claude/skills/*/SKILL.md` | Authoritative workflow and capability instructions for SDD skills. | technical-director | coordination-policy | technical-director; skill owner may propose updates. | New skill, routing behavior, workflow gate, allowed-tool, or verification rule changes. | Higher-level runtime rules win; within a workflow, the active skill file owns execution behavior. | Skill validator; route review through `using-sdd`; harness audit. | Operational |

### 3.2 Architecture and Technical References

| Artifact | Purpose | Owner | Authority level | Updated by | Updated when | Conflict resolution | Verification | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `docs/technical/ARCHITECTURE.md` | Current system architecture overview. | technical-director | architecture-constraint | technical-director; contributors may propose edits. | System boundaries, components, or integration architecture change. | Accepted ADRs and runtime reality win; update architecture doc to match. | Direct review; compare against code, ADRs, and CODEMAP. | Operational; stale risk |
| `docs/technical/DECISIONS.md` | ADR index and quick-reference decision log. | technical-director; cto for strategic ADRs | architecture-constraint | technical-director, cto, lead-programmer for append-only entries within domain. | New, deprecated, or superseded architecture decision. | Accepted ADR body wins over summary row. | Review index links and status values. | Operational |
| `docs/internal/adr/ADR-*.md` | Durable internal architecture decisions and supersession records. | technical-director | architecture-constraint | technical-director with human approval for accepted decisions. | Architecture, coordination, runtime, or governance decision with durable consequences. | Latest accepted non-superseded ADR wins within its scope. | ADR status, related ADR links, and `DECISIONS.md` index review. | Operational |
| `docs/technical/CODEMAP.md` | Codebase navigation and module map. | technical-director | impl-reference | technical-director via `/update-codemap`. | Significant feature merges or structural code changes. | Live code wins; stale codemap must be updated. | Run/update codemap after significant changes; direct spot check. | Operational if present; stale risk |
| `docs/technical/API.md` | Implemented API reference: endpoints, request/response schemas, auth, errors, and deprecation policy. | backend-developer | impl-reference | backend-developer; tech-writer may improve examples only. | Endpoint surface, schema, auth, error, or deprecation changes. | Runtime implementation after review wins; then `API.md` must be updated. Stable contracts must reflect here after implementation. | Skeleton exists; endpoint review must compare entries against implementation/tests. | Skeleton exists; endpoint inventory pending |
| `docs/technical/DATABASE.md` | Implemented database schema, migration notes, indexes, and data integrity rules. | data-engineer | impl-reference | data-engineer; backend-developer may propose. | Schema, migration, index, or data integrity changes. | Applied migrations/runtime schema win; then `DATABASE.md` must be updated. | Compare with migrations/schema files and data-engineer review. | Planned; currently missing |

### 3.3 Product, Feature, UI, and Contracts

| Artifact | Purpose | Owner | Authority level | Updated by | Updated when | Conflict resolution | Verification | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `PRD.md` | Product requirements and approved scope. | Human + product-manager | feature-behavior | Human-approved edits; product-manager may draft. | Product intent, scope, or acceptance changes. | Human-approved PRD wins over downstream specs; route drift through `spec-evolution`. | Direct review; acceptance criteria traceability. | Operational if present |
| `design/specs/*` | Feature-level behavior, business logic, UX intent, acceptance criteria, and non-goals. | lead-programmer / product-manager depending feature scope | feature-behavior | Owning lead after user approval. | New feature or behavior changes. | PRD and accepted ADRs win; unresolved drift routes to `spec-evolution`. | `review-spec`; task plan links; acceptance criteria present. | Operational baseline |
| `docs/ui-spec/*` | Detailed UI states, interactions, loading/error/empty states, and implementation-ready UI behavior. | ui-spec-designer | feature-behavior | ui-spec-designer with UX/product review. | UI flow, state matrix, interaction, or accessibility spec changes. | PRD and approved UX/design decisions win; technical feasibility escalates to technical-director. | UI spec checklist; frontend feasibility review; a11y review for risky flows. | Planned; ui-spec skill exists but artifact path not populated |
| `design/` | UX wireframes, flows, research-informed design artifacts, and prototypes. | ux-designer; ux-researcher for `design/research/` | feature-behavior | ux-designer or ux-researcher in owned subpaths. | UX flow, visual, interaction, or research updates. | PRD wins on product intent; UI spec wins for implementation matrix after approval. | Design review; PRD traceability; a11y review when relevant. | Operational baseline |
| `design/contracts/*` | Proposed pre-implementation interface locks between layers or agents. | lead-programmer / backend-developer | interface-lock | Owning lead after registry and API skeleton exist. | Pilot only after Sprint 0.5; API surface or cross-layer contract changes. | Accepted ADR or approved spec wins; implemented contract must be reflected in `docs/technical/API.md`. | Contract lifecycle status; linked feature spec; backend/frontend references. | Proposed; do not roll out before pilot |

### 3.4 Planning, Tasks, Handoffs, and Release

| Artifact | Purpose | Owner | Authority level | Updated by | Updated when | Conflict resolution | Verification | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `TODO.md` | Backlog, priority, and high-level task tracking. | producer | task-state | producer; user may reprioritize. | Task creation, priority changes, WIP movement, completion. | Human priority wins; producer maintains consistency. | Every TODO item maps to `.tasks/NNN-*.md`; WIP limit checked. | Operational if present |
| `.tasks/NNN-*.md` | Per-task detail: status, owner, dependencies, acceptance criteria, and verification. | producer | task-state | producer; implementing agent updates assigned task fields. | Task starts, blocks, completes, or dependency changes. | `TODO.md` and user-approved plan win on priority; task file wins on execution detail. | Status and `blocked_by` fields; acceptance/verification present. | Operational baseline |
| `.tasks/handoffs/*` | Formal high-risk or cross-domain handoff contracts. | sending agent; producer coordinates | coordination-policy | sending agent via `/handoff`; receiver acknowledges. | High-risk handoff, cross-domain partial artifact, or non-trivial acceptance transfer. | Rule 16 is SHOULD; lightweight text handoff may replace formal file for low/medium risk. | Handoff has sender, receiver, artifact, missing work, acceptance criteria, and ledger entry when Medium/High. | Baseline exists; needs adoption |
| `production/session-state/active.md` | Live session checkpoint and recovery context. | active session / producer for task status | memory | Hooks and active agent. | Session start, significant milestone, compaction, stop, or recovery. | Live repo state wins if active checkpoint is stale. | Session-start/stop behavior; direct review before recovery claims. | Operational |
| `docs/internal/CHANGELOG.md` | Internal project change history and release/change narrative. | release-manager / technical-director depending change type | audit-trace | release-manager, technical-director, or task owner. | Significant SDD change, release prep, or architecture/runtime update. | Git history and accepted ADRs win; changelog must be corrected if stale. | Entry matches changed files and verification evidence. | Operational |

### 3.5 Audit, Memory, and Telemetry

| Artifact | Purpose | Owner | Authority level | Updated by | Updated when | Conflict resolution | Verification | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `production/traces/decision_ledger.jsonl` | Append-only audit trail for Medium/High decisions, circuit transitions, handoffs, and task outcomes. | technical-director / active agent | audit-trace | Hooks, `/handoff`, active agents, commit tooling. | Medium/High risk decisions, circuit transitions, handoffs, task completion/failure. | Accepted ADR or latest runtime fact wins over stale ledger interpretation; ledger remains historical. | `scripts/trace-integrity-check.js`; `/trace-history` queries. | Operational write/query path; needs read adoption |
| `production/traces/agent-metrics.jsonl` | Agent telemetry and orchestration metrics. | producer / technical-director | audit-trace | Runtime hooks or metrics scripts. | Agent invocation, orchestration, or health events. | Metrics are evidence, not policy; coordination rules decide actions. | Trace integrity check; spot-check event schema. | Operational baseline |
| `production/traces/skill-usage.jsonl` | Skill invocation telemetry. | technical-director | audit-trace | Hook telemetry. | Skill usage events. | Telemetry informs cleanup; skills remain governed by skill files. | Trace integrity check; harness audit unused-skill checks. | Operational baseline |
| `.claude/memory/MEMORY.md` | Tier 1 memory index and durable recall entrypoint. | technical-director / active memory hooks | memory | Memory hooks and explicit annotation workflows. | Durable project preference, gotcha, or topic index changes. | Live repo state wins over memory. Memory must be corrected when stale. | Direct review; context-management rules; no stale claims. | Operational |
| `.claude/memory/*` | Tiered memory, specialist memory, circuit state, and archives. | technical-director; specialist agents for specialist namespaces | memory | Hooks or owning specialist workflows. | Learned project facts, session archives, circuit updates, specialist notes. | Live repo and accepted ADRs win; memory is advisory context. | Memory retrieval map; circuit schema check; archive review when needed. | Operational |
| `.claude/memory/circuit-state.json` | Circuit breaker state for persistent agent failure routing. | technical-director | runtime-state | `circuit-guard` / `circuit-updater` hooks. | Task-tool failure thresholds and circuit transitions. | ADR-004/ADR-005 define policy and mechanism; state file records current circuit fact under that policy. | JSON schema v2 readable; circuit transitions logged to ledger. | Operational |

### 3.6 Codex Adapter Artifacts

| Artifact | Purpose | Owner | Authority level | Updated by | Updated when | Conflict resolution | Verification | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `AGENTS.md` | Codex entrypoint and manual SDD operating contract. | technical-director | adapter-policy | technical-director with Codex regression check. | Codex workflow, tool mapping, or completion discipline changes. | Claude-native `.claude/` remains canonical; adapter must conform. | Codex behavior check; no Claude runtime files changed for Codex-only reasons. | Operational |
| `.claude/skills/codex-sdd/SKILL.md` | Codex-specific adapter skill routing Codex back to `using-sdd`. | technical-director | adapter-policy | technical-director. | Codex setup, tool mapping, or manual hook equivalent changes. | `using-sdd`, `CLAUDE.md`, and `.claude/` source of truth win. | Skill validator; Codex preflight. | Operational |
| `docs/codex-compatibility.md` | Codex parity matrix, manual hook equivalents, and verification checklist. | technical-director | adapter-policy | technical-director. | Codex compatibility phases or manual verification changes. | `.claude/` and `AGENTS.md` win for runtime behavior. | `scripts/codex-preflight.*`; direct review. | Operational |
| `.codex/INSTALL.md` | Optional Codex skill discovery setup instructions. | technical-director | adapter-policy | technical-director. | Codex install path or discovery mechanism changes. | Adapter install must not copy or fork `.claude/skills` unless explicitly intended. | `Test-Path "$env:USERPROFILE\\.agents\\skills\\sdd"` after install. | Documentation exists; local install may be absent |
| `scripts/codex-preflight.*` | Manual Codex approximation of key Claude hook checks. | technical-director | adapter-policy | technical-director. | Codex preflight requirements change. | Does not replace Claude hooks; failures narrow Codex readiness only. | Run script; expect 0 failures and reviewed warnings. | Operational |

---

## 4. Conflict Rules

Use these rules when two artifacts disagree.

### 4.1 Product vs Feature Spec

If `PRD.md` and `design/specs/*` disagree, stop and route through
`spec-evolution`. Do not implement from the lower-level spec until the
disagreement is resolved.

### 4.2 Spec vs Contract

If a feature spec and `design/contracts/*` disagree, the approved spec wins until
an ADR or `spec-evolution` changes the feature behavior. Contract status must
move back to `proposed` or `reviewed` until reconciled.

### 4.3 Contract vs Implemented API

Before implementation, `stable` contract wins for what should be built. After
implementation and review, `docs/technical/API.md` documents what exists.
During implementation, the approved spec owns scope; divergence pauses the slice
until the contract status returns to `reviewed`.
If runtime implementation differs from the contract, either fix the implementation
or route through `spec-evolution` and update the contract/API docs.

### 4.4 ADR vs Lower-Level Artifacts

Accepted ADRs constrain specs, contracts, API docs, implementation plans, and
coordination policy within their scope. Superseded ADRs are historical and must
not be used as current authority.

### 4.5 Memory vs Repo

Memory is context, not authority. If `.claude/memory/*` disagrees with live repo
files, current code/docs/ADRs win and memory should be corrected or ignored.

### 4.6 Codex Adapter vs Claude Runtime

Codex adapter artifacts cannot change Claude runtime behavior. If `AGENTS.md`,
`codex-sdd`, or `docs/codex-compatibility.md` disagree with `CLAUDE.md` or
`.claude/`, the Claude-native source wins and the adapter must be updated.

---

## 5. Update Rules

Before adding a new shared-state artifact:

1. Check this registry for an existing artifact that already owns the truth.
2. Add or update a registry entry before adding the artifact.
3. Define owner, authority level, conflict resolution, and verification.
4. Do not add schema fields without an ADR.
5. Apply the anti-pattern watch from
   `docs/internal/harness-to-coordination-engineering.md`.

Before changing this registry:

1. Confirm the change does not alter Claude runtime behavior by itself.
2. If the registry change implies runtime behavior, route through ADR or
   coordination-rule update first.
3. Run docs validation checks and inspect affected source files.

---

## 6. Verification Checklist

Sprint 0 acceptance for this registry:

- [x] Covers at least these artifact types: specs, ADRs, API docs, handoffs,
      task files, decision ledger, memory, proposed contracts.
- [x] Every entry has owner, authority level, update trigger, conflict
      resolution, and verification.
- [x] `docs/technical/API.md` skeleton exists for Sprint 0.5; endpoint inventory
      remains pending until implemented APIs are reviewed.
- [x] `design/contracts/*` is marked proposed and blocked from broad rollout
      until API skeleton and pilot criteria exist.
- [x] Registry does not claim to override `CLAUDE.md`, `.claude/settings.json`,
      hooks, coordination rules, or accepted ADRs.

Recommended checks after edits:

```powershell
git diff --check -- docs\technical\SOURCE_OF_TRUTH_REGISTRY.md
powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1
node scripts\harness-audit.js --compact
```
