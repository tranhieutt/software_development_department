---
name: verification-before-completion
type: workflow
description: "Requires fresh verification evidence before claiming work is complete, fixed, passing, safe, ready, merged, or clean. Use before completion claims, commits, PRs, merge readiness, or moving to the next task."
argument-hint: "[claim-or-task-being-completed]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
context: main
effort: 2
agent: qa-lead
when_to_use: "Use before any completion or success claim, before committing, before opening or updating a PR, before marking a task done, and before moving from one implementation task to the next."
---

# Verification Before Completion

## Purpose

Prevent false completion claims. A task is not done because the code looks right,
an agent reported success, or a previous command passed. A task is done only when
fresh evidence verifies the exact claim being made.

This is a completion gate, not an implementation workflow. It runs after the
relevant work and before any statement that implies success.

## Iron Law

```text
No completion claim without fresh verification evidence.
```

Do not say the work is done, fixed, passing, safe, ready, merged, clean, or
complete unless the current turn contains evidence from the relevant command,
file check, diff review, or manual verification note.

## Trigger Phrases

Use this skill before saying or implying:

- "done", "complete", "finished"
- "fixed", "resolved", "working"
- "tests pass", "build passes", "lint is clean"
- "ready", "safe", "clean", "merge-ready"
- "implemented", "task complete", "all set"
- "the agent completed it"
- "I can commit", "I opened the PR", "ready to merge"

If the wording suggests success, this gate applies.

## Workflow

### 1. Identify the Claim

Write the claim as a concrete sentence:

```text
Claim: <specific completion or success statement>
```

Examples:

- `Claim: Task 2 satisfies all approved acceptance criteria.`
- `Claim: The regression test proves the checkout hydration bug is fixed.`
- `Claim: The skill metadata validates with zero required failures.`

### 2. Choose the Proof

Map the claim to the smallest sufficient proof:

| Claim type | Required proof |
| --- | --- |
| Tests pass | Fresh test command output and exit status |
| Build passes | Fresh build or typecheck output and exit status |
| Lint clean | Fresh lint output and exit status |
| Bug fixed | Reproduction or regression test proving the original symptom no longer occurs |
| Regression test valid | RED/GREEN evidence, or equivalent proof that the test fails without the fix |
| Requirements met | Checklist against the approved spec/plan, with any gaps called out |
| Agent completed work | Inspect changed files or diff, then run the plan's verification |
| Merge/PR ready | Tests/build required by project plus review of changed-file scope |
| Documentation updated | File exists, relevant sections changed, links or generated indexes verified |
| Manual/visual outcome | Exact manual check, environment, viewport/artifact, and observed result |

When multiple claims are being made, verify each claim or narrow the final
statement to only the verified claim.

### 3. Run or Inspect Fresh Evidence

Run the full command when a command is available. Read the output. Check the exit
code and failure count. Do not rely on memory, prior sessions, subagent reports,
or partial output.

If the proof is a file or diff check, inspect the relevant file or diff in the
current turn.

If verification requires credentials, network access, a running service, a GUI,
or user-only context, do not assume success. State the blocked verification
plainly.

### 4. Compare Against the Claim

Before reporting, decide:

- `VERIFIED`: evidence proves the claim.
- `PARTIAL`: evidence proves only part of the claim.
- `NOT VERIFIED`: evidence is missing, blocked, stale, or failed.
- `FAILED`: evidence contradicts the claim.

If the result is not `VERIFIED`, change the final wording so it does not imply
more success than the evidence supports.

### 5. Report With Evidence

Use this output shape:

```markdown
## Verification Before Completion

**Claim:** [specific claim]
**Evidence:** [command/check and key result]
**Verdict:** VERIFIED | PARTIAL | NOT VERIFIED | FAILED
**Limits:** [anything not checked, or "None"]
```

For normal final responses, keep this compact. The important requirement is that
the success claim and the evidence appear together.

## Completion Gate Matrix

| Situation | Required action |
| --- | --- |
| About to mark a plan task complete | Re-read task acceptance criteria, verify each criterion, then report gaps or completion |
| About to move to next subagent task | Verify current task output and both review gates first |
| About to commit | Run project-relevant tests/checks or state exactly why not run |
| About to open a PR | Verify tests/build and summarize changed scope |
| About to say a bug is fixed | Verify the original reproduction path or regression test |
| About to claim docs are updated | Check the changed docs and any generated command list/index if applicable |

## Anti-Rationalizations

| Thought | Required correction |
| --- | --- |
| "It should pass." | Run the command or state it was not verified. |
| "The agent said it passed." | Inspect and verify independently. |
| "I ran tests earlier." | Use fresh evidence from the current completion point. |
| "Only docs changed, no verification needed." | Verify the docs file, link/index, or validator relevant to the docs. |
| "The change is obvious." | Obvious is not evidence. |
| "I don't want to bother the user with details." | Report the shortest useful evidence, not confidence. |
| "Partial checks are enough." | Say exactly which claims are partial and what remains unchecked. |

## Red Flags

Stop and verify before proceeding if:

- You are about to use "done", "fixed", "passing", "ready", or similar wording.
- You are about to commit, push, open a PR, merge, or mark a task complete.
- A subagent reports `DONE` but you have not inspected changed files.
- Verification failed but the wording still sounds successful.
- The command output contains warnings, skipped tests, or partial failures you
  have not accounted for.

## Integration

- `using-sdd` routes completion claims to this skill.
- `test-driven-development` provides RED/GREEN evidence for implementation
  claims.
- `subagent-driven-development` uses this gate before marking each task complete
  and again after cross-task verification.
- `commit`, `pr-writer`, `code-review`, `gate-check`, `release-checklist`, and
  `launch-checklist` should use this gate before success or readiness claims.
