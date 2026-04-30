---
name: planning-and-task-breakdown
type: workflow
description: "When dealing with a complex issue, epic, or multi-step feature request, break it down into executable, testable, agent-ready tasks before writing code."
argument-hint: "[epic-description-or-issue-url]"
user-invocable: true
allowed-tools: Read, Glob, Grep
context: fork
effort: 3
agent: lead-programmer
when_to_use: "When starting a complex project, receiving an epic or vague large-scale request, turning an approved spec into implementation tasks, or when the user invokes /plan."
---

# Planning and Task Breakdown

## Purpose

Turn approved requirements into an implementation plan that another agent can
execute task by task without guessing. The plan must lock down scope, file
ownership, dependencies, test strategy, and verification before any code changes.

This is a Plan Gate under `using-sdd`. A plan is not permission to execute. The
user must approve the plan before RED tests, production edits, or implementation
subagents begin.

Prefer tracer-bullet vertical slices: each task should deliver the thinnest
complete path that is independently verifiable. Avoid horizontal tasks that only
build one layer unless that layer is a prerequisite contract, migration, or
bounded infrastructure step with its own verification.

## Workflow

### 1. Establish Inputs

- Identify the source of truth: user request, spec file, issue, PRD, bug report,
  or prior conversation summary.
- Read only the files needed to understand scope, architecture boundaries, and
  existing patterns.
- Identify the applicable pre-code gate from `using-sdd`.
- If requirements are vague, stop and route to `deep-interview` or
  `spec-driven-development` before planning.

### 2. Scope Check

Before tasking, decide whether this is one plan or multiple plans.

Split into separate plans when the request contains independent subsystems, such
as billing plus analytics plus auth, or mobile plus backend plus release
automation. Each plan must produce working, testable value on its own.

If the request is too broad for one plan, present the split and ask which plan to
write first.

### 3. File Responsibility Map

Before defining tasks, map the files or modules that will be created or modified.

For each file, capture:

- Purpose
- Owner task
- Whether it is created, modified, or tested
- Verification command/check that exercises it

Prefer small files with clear responsibilities. Follow existing codebase
patterns. Do not add unrelated refactors. If an existing file is too large and
the requested change touches its tangled area, include a scoped split task and
explain why it is necessary.

### 4. Task Decomposition

Break work into atomic tasks. Each task should be small enough to execute and
verify independently.

A valid task:

- Touches one logical behavior or one infrastructure step
- Delivers a tracer-bullet vertical slice when user-facing behavior crosses
  multiple layers
- Lists exact files, or a bounded discovery step if the exact file is unknown
- Includes TDD RED/GREEN/REFACTOR steps for behavior changes
- Includes exact commands and expected outcomes
- Has clear acceptance criteria
- Can be reviewed independently
- Is marked `AFK` when an agent can execute it without more human judgment, or
  `HITL` when it requires human approval, design choice, external access, manual
  review, or unresolved tradeoff

Invalid tasks:

- "Build the backend"
- "Add validation and error handling"
- "Write tests for the above"
- "Implement similar logic"
- Any task spanning DB, API, UI, docs, and deployment at once
- Any horizontal slice that cannot be demonstrated or verified without a later
  task, unless it is explicitly a contract or setup task

### 4a. AFK/HITL Classification

Classify each task before presenting the plan:

| Classification | Meaning | Typical examples |
| --- | --- | --- |
| `AFK` | Agent-ready. Requirements, files, acceptance criteria, and verification are clear enough to execute without more human decisions. | Narrow bug fix, approved behavior slice, mechanical docs update, isolated test coverage |
| `HITL` | Human-in-the-loop. Work is blocked on judgment, access, design approval, or a durable tradeoff. | Architecture choice, UX decision, credentials, release approval, ADR acceptance |

Default to `HITL` when the task contains unresolved product, security, release,
or architecture judgment. Do not hide uncertainty inside an `AFK` task.

### 5. Dependency Mapping

Order tasks by dependency:

1. Contracts and interfaces before consumers
2. Schema/data changes before API code
3. API behavior before UI integration
4. Implementation before docs
5. Tests and verification at every task boundary

Mark tasks as sequential unless they touch disjoint files and have no input
dependency. If parallel execution is genuinely safe, say whether to use
`fork-join` or `orchestrate`.

### 6. Create Plan and Request Approval

Output the plan in the required format below. End by asking for explicit approval
to execute Task 1. Do not create tests, edit production files, or spawn
implementation agents before approval.

## Required Plan Format

Use this structure exactly. Keep it concise, but do not omit required fields.

````markdown
# [Feature/Epic Name] Implementation Plan

**Goal:** [One sentence describing the working outcome]
**Source of Truth:** [spec/issue/request path or short description]
**Pre-Code Gate:** Plan Gate required because [multi-step / multi-file / cross-domain reason]
**Approval Required Before:** RED tests, production edits, implementation subagents
**Execution Mode Recommendation:** [Inline TDD | subagent-driven-development | orchestrate | fork-join] because [reason]
**Slice Strategy:** [Tracer-bullet vertical slices | Contract/setup tasks first, then vertical slices] because [reason]

## Architecture Summary

[2-4 sentences describing approach, boundaries, data/control flow, and how this
fits existing patterns.]

## File Responsibility Map

| File | Action | Responsibility | Owner Task | Verification |
| --- | --- | --- | --- | --- |
| `exact/path/file.ext` | Create/Modify/Test | [purpose] | Task N | `[command/check]` |

## Plan

### Task 1: [Atomic Outcome]

**Classification:** [AFK | HITL] because [why the agent can proceed alone or what human decision is required]
**Purpose:** [Why this task exists]
**Dependencies:** None / Task N
**Files:**
- Create: `exact/path/new-file.ext`
- Modify: `exact/path/existing-file.ext`
- Test: `exact/path/test-file.ext`

**Acceptance Criteria:**
- [ ] [Concrete observable result]
- [ ] [Edge case or failure behavior]
- [ ] [Independent verification/demo result for this slice]

- [ ] **Step 1: RED - write the failing test**

Describe the exact test to add. Include code when the API or assertion is known:

```ts
it("does the expected behavior", () => {
  // concrete assertion
});
```

- [ ] **Step 2: Run RED verification**

Run: `[exact command]`
Expected: FAIL because `[specific missing behavior or assertion mismatch]`

- [ ] **Step 3: GREEN - implement the minimum code**

Describe the smallest implementation change. Include code only when it is
short, stable, and not likely to conflict with existing patterns.

- [ ] **Step 4: Run GREEN verification**

Run: `[exact command]`
Expected: PASS with `[expected pass count / clean output]`

- [ ] **Step 5: REFACTOR - clean up while staying green**

Allowed cleanup: [naming / duplication / extraction]. No behavior expansion.

- [ ] **Step 6: Task review**

Run: `[task-specific review command/check]`
Expected: [clean result]

- [ ] **Step 7: Commit**

Commit message: `type(scope): concise task result`

### Task 2: [Atomic Outcome]

[Repeat the same complete structure. Do not say "same as Task 1".]

## Cross-Task Verification

- [ ] Run `[full test/build/lint command]`
- [ ] Verify [critical user flow / artifact / docs link]
- [ ] Review changed files against source of truth

## Risks and Rollback

- Risk: [specific risk]. Mitigation: [specific check].
- Rollback: [how to revert or disable safely].

## Approval Request

Plan is ready. Do you approve executing Task 1 using `test-driven-development`?
````

## No Placeholders

The plan must not contain:

- `TBD`, `TODO`, `later`, `fill in`, `etc.`
- "Add appropriate validation"
- "Handle edge cases"
- "Write tests"
- "Similar to previous task"
- Commands without expected outcomes
- File paths that are broad guesses when a bounded discovery step is possible
- Types, functions, routes, or components referenced before they are defined

If exact code is not knowable until implementation, state the interface,
acceptance criteria, and verification command instead of inventing code.

## Self-Review

Before presenting the plan, review it yourself:

- [ ] Every source requirement maps to at least one task
- [ ] Every task is atomic and independently verifiable
- [ ] Every task has files, acceptance criteria, RED/GREEN or explicit non-code
      verification, and expected command output
- [ ] No task mixes unrelated architectural domains
- [ ] Every task is classified `AFK` or `HITL` with a concrete reason
- [ ] User-facing behavior is decomposed into tracer-bullet vertical slices
      unless a contract/setup task is required first
- [ ] No placeholders or vague instructions remain
- [ ] Names, paths, and interfaces are consistent across tasks
- [ ] Execution mode recommendation matches dependencies
- [ ] Plan stops for approval before execution

Fix issues inline before showing the plan.

## Execution Handoff

After approval:

- Use `test-driven-development` for inline execution of one small task.
- Use `subagent-driven-development` for multiple mostly sequential tasks that
  need per-task implementation, spec-compliance review, and code-quality review.
- Use `orchestrate` when tasks require specialist sequencing across domains.
- Use `fork-join` only when tasks are independent and file ownership is disjoint.

Before the first edit after approval, state:

```text
Pre-code gate: Plan satisfied by user approval; next edit is RED test <file>; verification: <failing test command>.
```

## Anti-Rationalizations

| Excuse | Required correction |
| --- | --- |
| "The user asked me to build it, not plan it." | Multi-step work requires Plan Gate. Present the plan first. |
| "I can start Task 1 while waiting for approval." | A plan is not permission. Wait for explicit approval. |
| "The first step is only a test." | RED tests are execution. Approval still comes first. |
| "The task is obvious enough." | If it spans multiple files or behaviors, make it explicit. |
| "Exact commands are tedious." | Commands are the verification contract. Include them. |
| "I'll let the implementer figure out details." | The plan must remove avoidable guessing. |
| "Similar to Task N is concise." | Repeat the needed details; tasks may execute independently. |

## Edge Cases

- **Pure documentation work:** Use the same structure but replace RED/GREEN with
  document checks, link checks, or reviewer checklist.
- **Visual UI work:** Include DOM/component tests when possible. If not, specify
  screenshot/manual visual checks, target viewports, and acceptance criteria.
- **No test framework exists:** Add a setup task or ask whether to install one.
  Do not pretend manual checks are TDD.
- **Discovery required:** Make discovery its own bounded task with exact search
  commands and expected decision output.

## Related Skills

- `using-sdd` - Defines the Plan Gate and pre-code gate line.
- `spec-driven-development` - Produces or validates the source spec before this
  planning skill.
- `test-driven-development` - Executes approved implementation tasks.
- `subagent-driven-development` - Executes approved multi-task sequential plans
  with implementer and reviewer subagents.
- `orchestrate` - Coordinates dependent specialist waves.
- `fork-join` - Executes independent parallel workstreams.
