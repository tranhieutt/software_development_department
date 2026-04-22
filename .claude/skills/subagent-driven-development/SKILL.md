---
name: subagent-driven-development
type: workflow
description: "Executes an approved implementation plan task-by-task with a fresh implementer subagent per task and two review gates. Use when a plan is approved, tasks are mostly sequential, and quality gates are needed without full orchestrate/fork-join overhead."
argument-hint: "[approved-plan-file-or-task-list]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, TodoWrite, Task
context: main
effort: 4
agent: lead-programmer
when_to_use: "When executing an approved planning-and-task-breakdown plan that has multiple implementation tasks, mostly sequential dependencies, and needs per-task review loops before proceeding."
---

# Subagent-Driven Development

## Purpose

Execute an approved implementation plan by dispatching one fresh implementer
subagent per task, then running two review gates before moving to the next task:

1. Spec compliance review: did the task implement exactly the plan?
2. Code quality review: is the implementation maintainable, tested, and safe?

The controller does not implement code directly. The controller curates context,
dispatches focused subagents, verifies outputs, and blocks progression when a
review gate fails.

## Position in SDD

Use this workflow after:

`spec-driven-development` -> `planning-and-task-breakdown` -> user approval

Use it instead of:

- `test-driven-development` inline when the plan has multiple tasks and review
  checkpoints would reduce risk
- `orchestrate` when the work does not need multiple specialist domain waves
- `fork-join` when tasks are not safe to run in parallel or share files

## Preconditions

All must be true:

- [ ] A concrete implementation plan exists.
- [ ] The user explicitly approved executing the plan.
- [ ] Tasks list exact files, acceptance criteria, and verification commands.
- [ ] The current branch/worktree is appropriate for implementation.
- [ ] Existing unrelated worktree changes are understood and will not be
      overwritten.

If any precondition is missing, stop and route back to
`planning-and-task-breakdown`, `using-sdd`, or the user.

Before the first implementation subagent, state:

```text
Pre-code gate: Plan satisfied by user approval; execution mode: subagent-driven-development; Task 1 owner: fresh implementer subagent.
```

## When Not to Use

- Single tiny task: use inline `test-driven-development`.
- Multiple independent branches: use `fork-join`.
- Cross-domain specialist sequencing: use `orchestrate`.
- Vague requirements: use `deep-interview` or `spec-driven-development`.
- Missing tests or verification strategy: update the plan first.

## Controller Workflow

### 1. Load the Plan Once

Read the approved plan once. Extract:

- Goal and source of truth
- File responsibility map
- All tasks with full text
- Dependencies
- Verification commands
- Risks and rollback notes

Do not make subagents read the whole plan. Give each subagent the exact task
text and only the context it needs.

### 2. Create Tracking Items

Use one tracking item per plan task:

```text
[ ] Task N - <atomic outcome>
```

Only mark a task complete after both review gates approve and verification
evidence is fresh.

### 3. Execute Each Task Sequentially

For each task:

1. Dispatch a fresh implementer subagent.
2. If the implementer asks for context, answer or re-dispatch with the missing
   context.
3. Require TDD evidence or the plan's explicit non-code verification.
4. Inspect changed files and command output.
5. Run spec compliance review.
6. Fix spec issues before code quality review.
7. Run code quality review.
8. Fix quality issues and re-review until approved.
9. Mark task complete.

Do not dispatch multiple implementation subagents in parallel from this workflow.
Parallel implementation belongs to `fork-join`.

Before marking any task complete or moving to the next task, use
`verification-before-completion` with the task's acceptance criteria, implementer
summary, changed files, verification output, and both review-gate verdicts.

### 4. Final Verification

After all tasks pass:

- Run the plan's cross-task verification commands.
- Run or request `code-review` for the full changed surface.
- Report changed files, verification evidence, open risks, and recommended next
  integration action.

## Implementer Prompt Contract

Pass this structure to every implementer subagent:

```text
You are the implementer for Task N of an approved SDD plan.

You are not alone in the codebase. Other work may exist. Do not revert or
overwrite changes outside your task scope.

Goal:
<overall plan goal>

Task:
<full task text, including files, acceptance criteria, RED/GREEN steps,
verification commands, and commit message>

Relevant context:
<only files, patterns, decisions, and prior task outputs needed for this task>

Rules:
- Work only on the files listed for this task unless you must stop and ask.
- Use test-driven-development for behavior changes.
- Do not broaden scope beyond the task.
- Run the exact verification commands from the plan.
- Self-review before reporting back.
- Commit only if the plan explicitly requires a commit and the worktree policy
  allows it.

Report one status:
- DONE
- DONE_WITH_CONCERNS
- NEEDS_CONTEXT
- BLOCKED

Include:
- Files changed
- Tests/commands run with results
- Any deviations from the plan
- Commit SHA if committed
```

## Spec Compliance Review Gate

After implementer reports DONE or DONE_WITH_CONCERNS, dispatch a fresh reviewer
or perform a separate review pass using this contract:

```text
Review Task N for spec compliance only.

Inputs:
- Task text from the approved plan
- Implementer summary
- Changed files / diff
- Verification output

Check:
- Every acceptance criterion is satisfied.
- Required files were created/modified/tested.
- No requested behavior is missing.
- No extra behavior or scope was added.
- Verification matches the plan.

Return:
- APPROVED, or
- CHANGES_REQUIRED with exact gaps and file references.
```

If spec compliance fails, send the exact gaps back to the implementer. Re-run
this gate after fixes. Do not start code quality review until spec compliance
passes.

When the gaps include spec ambiguity or implementation reality contradicts the
approved plan/spec, pause the task and route through `spec-evolution` before
asking the implementer to change behavior.

## Code Quality Review Gate

After spec compliance approves, dispatch a fresh code quality reviewer or use
`code-review` with focused context:

```text
Review Task N for code quality only.

Inputs:
- Task text
- Changed files / diff
- Verification output
- Project standards

Check:
- Tests are meaningful and not just implementation mirrors.
- Code follows existing architecture and naming patterns.
- Error handling and boundaries are appropriate.
- No secrets, unsafe config, or unrelated refactors were introduced.
- Complexity is justified and YAGNI is respected.

Return:
- APPROVED, or
- CHANGES_REQUIRED with severity and exact file references.
```

If quality review fails, send the findings back to the implementer. Re-run the
quality gate after fixes.

Use `receiving-code-review` to triage multi-item review feedback before sending
fix instructions back to the implementer. Do not forward unclassified comments
as a vague "address review feedback" task.

## Status Handling

| Implementer status | Controller action |
| --- | --- |
| DONE | Inspect summary, then run spec compliance review |
| DONE_WITH_CONCERNS | Read concerns; resolve scope/correctness concerns before review |
| NEEDS_CONTEXT | Provide missing context and re-dispatch the same task |
| BLOCKED | Diagnose blocker; add context, split task, escalate model/agent, or ask user |

Never force the same failed prompt to retry unchanged. A blocker means the
controller must change context, scope, or routing.

## Required Evidence

For each completed task record:

- Task number and outcome
- Files changed
- RED/GREEN or non-code verification output
- Spec compliance verdict
- Code quality verdict
- Commit SHA if applicable

No evidence means the task is not complete.

## Red Flags

- Starting without user approval of the plan
- Letting subagents read the entire plan instead of giving curated task text
- Running implementers in parallel in this workflow
- Moving to code quality review before spec compliance passes
- Accepting "mostly done" or "close enough"
- Ignoring DONE_WITH_CONCERNS
- Letting implementer self-review replace independent review
- Marking tasks complete without fresh verification evidence
- Continuing after reviewer finds blocking issues

## Output Format

When complete, report:

```markdown
## Subagent-Driven Development Complete

**Plan:** [plan/source]
**Tasks completed:** [N/N]
**Changed files:** [short list]
**Verification:** [commands and pass/fail]
**Review gates:** spec compliance [pass], code quality [pass]
**Open risks:** [none or list]
**Next integration step:** [commit/PR/gate-check/release/etc.]
```

If blocked, report the blocker, evidence, and the exact decision needed from the
user.

## Related Skills

- `using-sdd` - Routes approved implementation plans into this workflow.
- `planning-and-task-breakdown` - Produces the plan this workflow executes.
- `test-driven-development` - Required for implementer behavior changes.
- `verification-before-completion` - Required before marking each task complete
  and before the final completion claim.
- `code-review` - Used for the code quality gate or final review.
- `orchestrate` - Use instead for cross-domain specialist waves.
- `fork-join` - Use instead for independent parallel workstreams.
