---
name: systematic-debugging
type: workflow
description: "Investigates bugs, failing tests, build failures, performance issues, and unexpected behavior with root-cause discipline before any fix is proposed or implemented."
argument-hint: "[bug-description-error-output-or-failing-command]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
context: fork
effort: 3
agent: lead-programmer
when_to_use: "Use for any technical issue before proposing fixes: bugs, failing tests, build failures, unexpected behavior, integration failures, performance regressions, flaky behavior, or repeated failed fixes."
---

# Systematic Debugging

## Purpose

`systematic-debugging` prevents guess-and-check fixes. It requires the agent to
understand and verify the root cause before changing code.

Use it for any technical issue before proposing or implementing a fix. If the
issue is complex, intermittent, unfamiliar, or has resisted multiple fixes,
escalate to `diagnose`.

## Iron Law

```text
No fixes before root-cause investigation.
```

Seeing a symptom is not the same as knowing the cause. Do not edit production
code until the root cause is stated, supported by evidence, and tied to a
verification path.

## When To Use

Use for:

- Failing tests
- Build, lint, typecheck, or CI failures
- Runtime bugs and unexpected behavior
- Performance regressions
- Integration failures across API, database, UI, worker, or deployment layers
- Flaky or timing-dependent failures
- Any bug where "just try this" feels tempting

Escalate to `diagnose` when:

- The root cause remains unclear after one systematic investigation pass.
- The issue is intermittent or hard to reproduce.
- Two fix attempts have failed or been reverted.
- Multiple components are involved and the failure boundary is still unknown.
- The suspected fix affects architecture, data, security, or release policy.

## Workflow

### 1. Capture the Symptom

Record the exact observed failure:

- Command, user action, route, job, or test that fails
- Full error message or relevant log excerpt
- Environment: local, CI, staging, production, browser/device, OS, runtime
- Expected behavior vs actual behavior
- Whether the issue is reproducible, intermittent, or one-off

Do not paraphrase away important details such as paths, line numbers, status
codes, exception names, or assertion diffs.

### 2. Reproduce or Bound the Failure

Try the smallest reliable reproduction:

- Re-run the failing command or test if available.
- Reduce to a focused test, route, function, fixture, or input case.
- If it cannot be reproduced, gather more evidence instead of guessing.
- For flaky failures, record frequency and conditions.

If no reproduction or evidence exists, stop and ask for logs, steps, data, or
access needed to investigate.

### 3. Check Recent and Relevant Changes

Inspect the narrow change surface:

- Current diff and recently modified files
- Recent commits if available and relevant
- Dependency, config, environment, schema, data, or test fixture changes
- Existing similar code that still works

Do not assume the most recent edit caused the bug. Use it as one candidate.

### 4. Trace the Failure Boundary

Find where the bad value, failed state, or unexpected behavior first appears.

For multi-component systems, inspect each boundary:

- Input received
- Output produced
- Config/env available
- State before and after the boundary
- Error handling path

Examples of boundaries: browser -> API, API -> service, service -> database,
queue -> worker, CI job -> build script, test harness -> app runtime.

When needed, add temporary diagnostics only if they are safe, scoped, and removed
before completion. Do not leave debug logs in production paths.

### 5. Compare Against Working Patterns

Find a nearby working example in the same codebase or documented standard.

Compare:

- Control flow
- Data shape and validation
- Async/timing behavior
- Dependency injection and config
- Error handling
- Test setup and fixtures

List the meaningful differences. Small differences count until ruled out.

### 6. Form One Hypothesis

State one falsifiable hypothesis:

```text
Hypothesis: <root cause> because <evidence>. It can be falsified by <test/check>.
```

Do not propose a fix until this sentence is specific. Vague examples such as
"state is wrong" or "race condition" are not sufficient.

### 7. Test the Hypothesis Minimally

Use one variable at a time:

- Run a focused command or test.
- Add a temporary assertion/log only if needed.
- Change the smallest thing needed to confirm or refute the hypothesis.

If refuted, update the evidence and form a new hypothesis. Do not stack fixes.

If three hypotheses or fix attempts fail, stop and escalate to `diagnose` or
`architecture-decision-records` if the pattern itself appears wrong.

### 8. Implement Only After Cause Is Confirmed

Once root cause is confirmed:

- Use `test-driven-development` for behavior or regression fixes.
- Add or update a regression test that fails before the fix when possible.
- Implement the smallest fix that addresses the cause, not just the symptom.
- Run targeted verification and any adjacent regression checks.

If the correct behavior conflicts with an approved spec, route to
`spec-evolution` before changing behavior.

### 9. Close With Evidence

Before saying the bug is fixed, use `verification-before-completion` with:

- The original symptom
- Confirmed root cause
- Regression or reproduction evidence
- Commands/checks proving the failure no longer occurs
- Any limits or unverified environments

## Output Format

```markdown
## Systematic Debugging: [Issue]

**Symptom:** [exact failure]
**Reproduction:** [command/steps/frequency]
**Recent Relevant Changes:** [files/commits/config, or "None found"]

### Evidence
- [fact with file/line/command/log reference]

### Working Pattern Comparison
- [working example] differs by [specific difference]

### Hypothesis
[Root cause because evidence; falsifiable by check.]

### Hypothesis Test
- Check: [command/inspection]
- Result: [confirmed/refuted/inconclusive]

### Fix Path
[TDD/regression test/spec-evolution/diagnose/escalation path.]

### Verification Needed
[commands/checks required before completion claim]
```

## Red Flags

Stop and return to investigation if you think:

- "It is probably X; I will fix it."
- "Try this and see."
- "I can change multiple things at once."
- "The error is obvious" but no reproduction or evidence has been captured.
- "I will write the test after confirming the fix manually."
- "One more fix attempt" after two failed fixes.
- "This is flaky, so a sleep should stabilize it."
- "The reviewer/user wants it fixed quickly, so process can wait."

## Anti-Rationalizations

| Thought | Required correction |
| --- | --- |
| "This is simple." | Simple issues still have causes; capture the evidence quickly. |
| "The stack trace tells me the fix." | Stack traces identify symptoms and locations; confirm the cause. |
| "I already know the pattern." | Compare with a working local example before changing code. |
| "A quick patch is faster." | Guessing is slower when the first patch is wrong. |
| "Tests are not needed for this bug." | Use a regression test or document why only manual verification is possible. |
| "I can keep trying fixes." | After repeated failures, escalate to `diagnose`. |

## Integration

- `using-sdd` routes bugs, failures, and unexpected behavior here before fixes.
- `test-driven-development` implements confirmed behavior fixes.
- `diagnose` handles complex, intermittent, unfamiliar, or repeated-failure
  debugging after this workflow cannot establish a cause quickly.
- `spec-evolution` handles cases where the correct behavior differs from the
  approved spec.
- `verification-before-completion` is required before claiming the issue is
  fixed.
