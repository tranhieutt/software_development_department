# Claude + Codex Operating Model

> Purpose: Daily operating model for using both Claude and Codex in the same
> SDD-governed product repository.
>
> Scope: CRM, SaaS, and AI Agent product development.
>
> Governing decision: `docs/internal/adr/ADR-007-shared-sdd-core-dual-execution-lanes.md`

---

## 1. Core Principle

Use **one shared SDD core** and **two execution lanes**:

```text
Claude = control plane
Codex  = execution plane
```

Do not treat these as two separate frameworks.

Shared core artifacts:

- `PRD.md`
- `design/specs/*`
- `TODO.md`
- `.tasks/NNN-*.md`
- `docs/internal/adr/ADR-*.md`
- verification evidence in tests, diffs, and runtime checks

If Claude and Codex disagree, the repo artifacts win over chat memory.

---

## 2. Role Split by SDD Phase

| SDD phase | Primary runtime | Secondary runtime | Notes |
| --- | --- | --- | --- |
| DEFINE | Claude | Codex for repo inspection only | Claude owns ambiguity reduction, product framing, and architecture shaping. |
| PLAN | Claude | Codex for bounded repo evidence | Claude owns task breakdown and approval gates. |
| BUILD | Codex | Claude optional on high-risk implementation questions | Codex owns scoped implementation once the gate is approved. |
| VERIFY | Codex for local task checks; Claude for claim-level review on risky work | Both | Codex proves the patch; Claude verifies the claim boundary when risk is Medium/High. |
| REVIEW | Claude | Codex for fix follow-up | Claude is the default final reviewer for risky or cross-domain changes. |
| SHIP | Either, with explicit human approval | Either | Commit/push/release still require user approval. |

---

## 3. Default Usage Pattern

### New feature

1. Claude runs onboarding, clarification, `/spec`, and `/plan`.
2. Scope is written into shared artifacts.
3. Codex receives one approved task at a time.
4. Codex implements and verifies locally.
5. Claude reviews the result against spec and architecture.
6. Codex applies follow-up fixes if needed.
7. Human approves commit/push.

### Bug fix

1. Claude or Codex reproduces the issue.
2. If the root cause is unclear or scope may expand, Claude owns diagnosis.
3. Codex implements the fix and regression test.
4. Claude reviews only when the bug touches shared or high-risk surfaces.

### Review cycle

1. Claude reviews.
2. Findings are converted into discrete follow-up tasks.
3. Codex executes those tasks.
4. Claude re-reviews only the affected claim area.

---

## 4. Ownership Rules

### Single-decider rule

At any given time for a task:

- one runtime is the **decision owner**
- one runtime is the **execution owner**

Do not let both runtimes define scope at once.

### Single-writer rule for a concern

Do not have Claude and Codex editing the same concern in parallel unless:

- the files are disjoint
- the spec is already locked
- the integration owner is named
- the merge path is obvious

Good parallelism:

- Codex implements backend task `A`
- Claude writes or reviews spec for upcoming frontend task `B`

Bad parallelism:

- Claude revises feature scope while Codex is already building the same slice
- both runtimes edit the same spec, task file, or implementation area

---

## 5. Handoff Contract

Use this minimum handoff template between Claude and Codex:

```text
Task: <task-id or task name>
Decision owner: <Claude|Codex>
Execution owner: <Claude|Codex>
Source of truth: <PRD/spec/task/ADR paths>
Allowed scope: <files or bounded module>
Verification: <exact command/check>
Open risks: <none or list>
```

Minimum repo artifacts that should be current before handoff:

- `.tasks/NNN-*.md` or equivalent task note
- the approved spec or ADR if the task depends on one
- current git diff context when relevant

Reusable template:

- `.tasks/handoffs/HANDOFF_TEMPLATE.md`

---

## 6. Runtime Startup

### Claude startup

Use Claude when you need:

- `/start`
- `/brainstorm`
- `/spec`
- `/plan`
- `/code-review`
- architectural conflict resolution

### Codex startup

Use Codex when you need:

- execution of an already-approved task
- terminal-heavy debugging
- patching and verification
- mechanical follow-up fixes

Recommended Codex first prompt:

```text
Use codex-sdd, then route through using-sdd, then run the start workflow for this repo.
```

Or use `.codex/START.md`.

---

## 7. Recommended Product-Specific Split

### CRM / SaaS

Claude should lead:

- workflow design
- RBAC and permission model decisions
- billing, tenancy, and boundary decisions
- acceptance criteria for business workflows

Codex should lead:

- CRUD implementation
- API handlers
- form/state plumbing
- test fixes and local debugging

### AI Agent products

Claude should lead:

- agent workflow design
- prompt contract design
- evaluation strategy
- failure-mode review

Codex should lead:

- SDK integration
- tool wiring
- local eval harness fixes
- logging, patching, and iteration on execution paths

---

## 8. When to Escalate Back to Claude

Return a task from Codex to Claude when:

- the spec is missing or ambiguous
- implementation reveals architecture drift
- the task expands across domains
- the review finding changes product behavior rather than code only
- the verification result conflicts with the approved claim

Codex should not silently resolve these by inventing scope.

---

## 9. When Codex Can Stay Autonomous

Codex can continue without bouncing back to Claude when:

- the task is already approved
- the file scope is narrow
- acceptance criteria are explicit
- the verification command is known
- the implementation does not change architecture or product behavior

---

## 10. Operating Anti-Patterns

Avoid these patterns:

- Claude plans in chat, Codex implements from memory, and no repo artifact is updated.
- Codex changes scope because the implementation path feels convenient.
- Claude and Codex both review and both decide, but nobody owns execution.
- Parallel work starts before the spec and contract are stable.
- Review findings are passed as prose only, not as bounded tasks.

---

## 11. Minimal Daily Loop

For most work, use this loop:

1. Claude defines or refines the task.
2. Task state is written to repo artifacts.
3. Codex executes one bounded task.
4. Codex verifies locally.
5. Claude reviews if the change is risky, cross-domain, or architectural.
6. Human authorizes ship actions.

This is the default operating model unless a task is trivial enough for one
runtime to own end-to-end.
