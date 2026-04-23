# SDD Lifecycle Map

> **Purpose:** Daily operating map for humans and agents using SDD.
> **Status:** v1.0, additive guidance. The detailed control-plane source remains
> [`CONTROL_PLANE_MAP.md`](CONTROL_PLANE_MAP.md), and runtime behavior remains
> governed by `.claude/settings.json`, `CLAUDE.md`, and the active skill files.

---

## 1. Why This Map Exists

SDD has many powerful workflows: specs, plans, TDD, review, release gates,
specialist agents, hooks, memory, circuit breakers, and audit traces. That depth
is useful, but it can make the first routing decision feel heavier than it needs
to be.

This map gives a simple six-phase navigation layer:

```text
DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP
```

Use it to answer:

1. What phase is the current work in?
2. Which SDD skills usually govern that phase?
3. What evidence is required before moving forward?
4. What actions are forbidden in this phase?

This document is a navigation aid, not a replacement for the control plane.

---

## 2. Phase Overview

| Phase | Goal | Primary SDD skills | Exit evidence |
| --- | --- | --- | --- |
| DEFINE | Decide what should be built, fixed, or reviewed. | `brainstorm`, `deep-interview`, `spec-driven-development`, `review-spec`, `source-driven-development`, `spec-evolution` | Approved intent, spec, reviewed source of truth, or verified technical source. |
| PLAN | Turn intent into executable, reviewable tasks. | `planning-and-task-breakdown`, `vertical-slicing`, `orchestrate`, `fork-join` | Task list with files, acceptance criteria, verification commands, dependencies, and user approval. |
| BUILD | Make the approved change with narrow scope. | `test-driven-development`, `subagent-driven-development`, domain implementation skills | RED/GREEN or equivalent implementation evidence. |
| VERIFY | Prove the exact claim being made. | `verification-before-completion`, `systematic-debugging`, `diagnose`, future browser/runtime verification skills | Fresh test, build, lint, manual, visual, runtime, or review evidence. |
| REVIEW | Check quality, safety, maintainability, and scope. | `code-review`, `code-review-checklist`, `receiving-code-review`, `code-simplification`, `security-audit`, `design-review`, `db-review`, `mobile-review` | Findings classified and blocking issues fixed, rejected with evidence, deferred, or routed to `spec-evolution`. |
| SHIP | Package, commit, PR, release, or hand off safely. | `commit`, `pr-writer`, `changelog`, `release-checklist`, `launch-checklist`, `patch-notes`, `save-state` | User-approved commit/push/PR/release step, changelog or release evidence, and stated residual risks. |

---

## 3. Phase Detail

### DEFINE

**Use when:**

- The user has an idea, feature request, bug, vague goal, existing spec, or
  architecture question.
- Requirements are missing, ambiguous, or hidden behind assumptions.
- A technical decision depends on official docs, version-specific behavior, a
  migration path, or external API semantics.

**Typical skills:**

- `brainstorm` for early product or feature ideation.
- `deep-interview` when the user wants structured questions or the goal is
  ambiguous.
- `spec-driven-development` for new behavior, architecture, UI flow, API, data,
  or side-effect changes.
- `review-spec` when a spec already exists and must be checked before planning.
- `source-driven-development` when technical correctness depends on official
  framework, library, API, or platform documentation.
- `spec-evolution` when approved spec, code, tests, review findings, or platform
  reality disagree.

**Exit criteria:**

- The source of truth is clear enough to plan or execute.
- Product intent and non-goals are explicit.
- Technical decisions that depend on external truth are confirmed, adjusted, or
  marked unverified.
- User approval exists where SDD gates require it.

**Forbidden in DEFINE:**

- Implementation edits.
- RED tests unless an execution gate is already approved.
- Silent assumptions for security, data, billing, release, or architecture.
- Rewriting an approved spec without routing through `spec-evolution`.

---

### PLAN

**Use when:**

- The work touches multiple files, multiple tasks, or multiple domains.
- The spec needs decomposition before implementation.
- The agent must choose between inline TDD, sequential subagents, orchestration,
  or parallel worktrees.

**Typical skills:**

- `planning-and-task-breakdown` for atomic implementation tasks.
- `vertical-slicing` for fullstack features that must be split into end-to-end
  slices.
- `orchestrate` for multi-domain specialist wave execution.
- `fork-join` for independent workstreams touching disjoint files.

**Exit criteria:**

- Task list has exact or bounded file scope.
- Each task has acceptance criteria and verification commands/checks.
- Dependencies are ordered.
- Execution mode is recommended.
- User explicitly approves Task 1 or the execution plan.

**Forbidden in PLAN:**

- Writing implementation code.
- Writing RED tests before approval.
- Creating vague tasks such as "build backend" or "add validation".
- Omitting verification commands or expected outcomes.

---

### BUILD

**Use when:**

- A Fast, Spec, Plan, Interview, or Override gate has been satisfied.
- The next edit is clear.
- The verification path is known.

**Typical skills:**

- `test-driven-development` for behavior changes and bug fixes.
- `subagent-driven-development` for approved multi-task sequential plans with
  review gates.
- Domain skills such as `backend-patterns`, `frontend-patterns`,
  `fastapi-pro`, `nextjs-patterns`, `postgres-patterns`, or
  `kubernetes-architect` when the implementation surface calls for them.

**Exit criteria:**

- Code changes stay inside approved scope.
- RED/GREEN evidence exists for behavior changes, or a named non-code
  verification path exists.
- Any deviation from the approved plan/spec is surfaced.

**Forbidden in BUILD:**

- Drive-by refactors.
- Extra behavior not in the spec or approved task.
- Writing implementation before the pre-code gate is stated.
- Continuing after discovering spec drift without `spec-evolution`.

---

### VERIFY

**Use when:**

- The agent is about to claim the work is done, fixed, passing, safe, clean, or
  ready.
- A bug fix needs proof against the original symptom.
- A subagent reports completion.
- A visual/manual/runtime result must be checked.

**Typical skills:**

- `verification-before-completion` for every success or readiness claim.
- `systematic-debugging` when verification fails or a bug is reproducible.
- `diagnose` for complex, intermittent, unfamiliar, or repeatedly failed
  investigations.

**Exit criteria:**

- Each claim maps to fresh evidence.
- Test/build/lint/manual/visual/runtime checks are reported with result.
- Failed or partial verification narrows the final claim instead of hiding the
  gap.

**Forbidden in VERIFY:**

- "Looks good", "should work", or "probably fixed".
- Trusting a previous run without checking freshness.
- Trusting a subagent report without inspecting relevant output.
- Ignoring warnings, skipped tests, or partial failures.

---

### REVIEW

**Use when:**

- Implementation has basic verification evidence.
- PR or merge readiness is being assessed.
- Review comments need classification.
- Working code is too complex and needs behavior-preserving cleanup.

**Typical skills:**

- `code-review` and `code-review-checklist` for quality and architecture.
- `receiving-code-review` for review feedback triage.
- `code-simplification` for behavior-preserving cleanup after tests pass.
- `security-audit` for security-sensitive changes.
- `design-review`, `db-review`, or `mobile-review` for domain-specific review.

**Exit criteria:**

- Findings are classified as fix, reject, defer, needs clarification, or route
  to `spec-evolution`.
- Blocking findings are resolved or explicitly escalated.
- Any cleanup preserves behavior and has fresh verification.

**Forbidden in REVIEW:**

- Forwarding vague review feedback as "fix comments".
- Resolving review threads without evidence.
- Calling behavior-changing work "simplification".
- Letting optional cleanup expand beyond approved scope.

---

### SHIP

**Use when:**

- Work is verified/reviewed enough for commit, PR, merge, release, or handoff.
- The user asks to commit, push, open PR, write release notes, or prepare launch.

**Typical skills:**

- `commit` for user-approved commits.
- `pr-writer` for PR title/body and linked context.
- `changelog`, `patch-notes`, `release-checklist`, and `launch-checklist` for
  release readiness.
- `save-state` before session end, context reset, handoff, or pause.

**Exit criteria:**

- User explicitly approves commit, push, PR, or release actions where required.
- Working tree and relevant checks are understood.
- Release notes, changelog, rollback notes, or residual risks are clear when
  applicable.

**Forbidden in SHIP:**

- Commit or push without explicit user permission.
- Claiming CI/build/test status without fresh evidence.
- Releasing risky changes without rollback or monitoring notes.
- Hiding unverified areas.

---

## 4. Common Paths

### New Feature

```text
DEFINE
  spec-driven-development
  source-driven-development if technical docs matter
PLAN
  planning-and-task-breakdown
  vertical-slicing if fullstack
BUILD
  test-driven-development
  subagent-driven-development if approved multi-task plan
VERIFY
  verification-before-completion
REVIEW
  code-review
  code-simplification if readability cleanup is needed
SHIP
  commit / pr-writer / changelog as authorized
```

### Bug Fix

```text
DEFINE
  systematic-debugging or diagnose
PLAN
  Fast Gate for tiny obvious fixes, otherwise planning-and-task-breakdown
BUILD
  test-driven-development with regression RED test
VERIFY
  verification-before-completion against original symptom
REVIEW
  code-review if shared or risky code changed
SHIP
  commit / patch-notes as authorized
```

### Review Feedback

```text
DEFINE
  receiving-code-review
BUILD
  test-driven-development if behavior changes
  code-simplification if behavior is unchanged
VERIFY
  verification-before-completion
REVIEW
  targeted re-review of the finding
SHIP
  update PR or resolve thread only after evidence
```

### Documentation or ADR

```text
DEFINE
  review-spec, architecture-decision-records, or source-driven-development
PLAN
  planning-and-task-breakdown only if multi-file or cross-domain
BUILD
  documentation-and-skill-specific edits
VERIFY
  file/link/index validation
REVIEW
  code-review only if docs alter executable examples or policy
SHIP
  commit / changelog as authorized
```

---

## 5. Relationship to Existing Control Documents

| Document | Role |
| --- | --- |
| `SDD_LIFECYCLE_MAP.md` | Simple six-phase navigation for daily use. |
| `CONTROL_PLANE_MAP.md` | Detailed stage, owner, exit criteria, fallback, and state update map. |
| `STAGE_TRANSITION_STATE_MACHINE.md` | Formal state transition model and hook/agent activation points. |
| `.claude/skills/using-sdd/SKILL.md` | Runtime routing skill that decides which workflow governs a request. |
| `.claude/settings.json` | Claude Code hook and permission runtime configuration. |

If this lifecycle map disagrees with a runtime artifact, the runtime artifact
wins and this map should be updated.

---

## 6. Quick Phase Questions

Use these questions when routing is unclear:

1. **DEFINE:** Do we know what outcome, non-goals, and source of truth are?
2. **PLAN:** Can another agent execute the next task without guessing?
3. **BUILD:** Is the pre-code gate satisfied and is the next edit scoped?
4. **VERIFY:** What fresh evidence proves the exact claim?
5. **REVIEW:** Are there unresolved quality, security, design, or scope issues?
6. **SHIP:** Has the user approved commit/push/release, and are risks visible?

If the answer is "no", stay in or return to that phase.
