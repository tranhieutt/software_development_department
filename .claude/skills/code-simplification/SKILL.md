---
name: code-simplification
type: workflow
description: "Simplifies working code while preserving exact behavior. Use after tests pass, during review feedback, or when code is harder to read, maintain, or verify than it needs to be without changing product behavior."
argument-hint: "[path-or-review-finding]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
context: fork
effort: 3
agent: lead-programmer
when_to_use: "Use for behavior-preserving cleanup after implementation is green, when review flags readability or complexity, or when the user asks to simplify/refactor without changing behavior."
---

# Code Simplification

## Purpose

`code-simplification` reduces code complexity while preserving exact behavior.
It is not a feature workflow, not a bug fix workflow, and not permission for
drive-by refactors.

The goal is code that is easier to read, review, test, and maintain with the
smallest safe diff.

```text
Same behavior.
Less cognitive load.
Fresh verification evidence.
```

## When to Use

Use this workflow when:

- The implementation is working and relevant tests pass.
- Code review flags readability, complexity, naming, duplication, or avoidable
  abstraction.
- The user asks to simplify, clean up, reduce complexity, or refactor without
  changing behavior.
- A recently changed area has nested logic, long functions, unclear names, or
  repeated conditionals that make future changes risky.

Do not use this workflow when:

- Behavior must change. Use `spec-driven-development`, `test-driven-development`,
  or `spec-evolution`.
- The code is not understood well enough to preserve behavior.
- There is no verification path.
- The cleanup would touch unrelated files.
- The work is a hotfix where cleanup is not required for the fix.

## Position in SDD

Preferred placement:

```text
test-driven-development -> code-simplification -> verification-before-completion
```

Review feedback placement:

```text
code-review -> receiving-code-review -> code-simplification
-> verification-before-completion
```

Technical-debt placement:

```text
tech-debt identifies issue -> user approves focused cleanup
-> code-simplification
```

If a simplification requires changing externally visible behavior, API shape,
data model, error behavior, timing, permissions, or user flow, stop and route to
`spec-evolution`.

## Preconditions

Before editing, all must be true:

- [ ] Target scope is explicit: file(s), function(s), or review finding.
- [ ] Intended behavior is known.
- [ ] Relevant tests, build, lint, typecheck, or manual verification are known.
- [ ] The current worktree state has been checked.
- [ ] The simplification is within the approved scope.

State the gate before edits:

```text
Pre-code gate: Fast satisfied for behavior-preserving simplification of <scope>; verification: <command/check>.
```

For cleanup attached to an approved task:

```text
Pre-code gate: Plan satisfied by approved Task N; simplification scope: <scope>; verification: <command/check>.
```

## Workflow

### 1. Understand Before Touching

Read the smallest necessary context and answer:

- What does this code do?
- Who calls it, and what does it call?
- What inputs, outputs, errors, side effects, and ordering matter?
- Which tests or checks prove behavior?
- Does git history or nearby code explain why it exists?

If you cannot answer, do not simplify yet. Gather context or ask.

### 2. Identify Concrete Simplification Targets

Only act on specific signals:

| Signal | Typical simplification |
| --- | --- |
| Deep nesting | Guard clauses or named predicates |
| Long function with mixed responsibilities | Extract focused helper(s) |
| Nested ternaries | Readable conditional or lookup |
| Boolean flag parameters | Options object or separate functions when warranted |
| Repeated conditionals | Named predicate |
| Generic names | Names that describe domain meaning |
| Duplicate logic | Shared helper, if it reduces real duplication |
| Unused wrapper | Inline only if the wrapper has no semantic value |
| Comments explaining obvious "what" | Remove or replace with clearer code |

Keep comments that explain why, tradeoffs, gotchas, or external constraints.

### 3. Apply One Safe Change at a Time

For each simplification:

1. Make the smallest behavior-preserving edit.
2. Run the relevant verification if cheap and available.
3. If verification fails, revert or diagnose before continuing.
4. Stop when further cleanup would broaden scope.

Do not batch unrelated simplifications. Do not modernize adjacent code just
because it is nearby.

### 4. Verify Behavior Preservation

Use the strongest available proof:

- Unit/regression tests for pure logic.
- Integration tests for boundaries.
- Typecheck/build/lint for structural cleanup.
- Manual or visual check for UI-only simplification.
- Diff review when no automated command exists, with limits stated plainly.

Before claiming completion, use `verification-before-completion`.

## Output Format

```markdown
## Code Simplification: [Scope]

**Target:** [files/functions/review finding]
**Behavior contract:** [what must remain unchanged]
**Changes made:** [short list]
**Verification:** [commands/checks and key result]
**Verdict:** VERIFIED | PARTIAL | NOT VERIFIED | FAILED
**Limits:** [anything not checked]
```

## Anti-Rationalizations

| Thought | Required correction |
| --- | --- |
| "Shorter means simpler." | Simpler means easier to understand while preserving behavior. |
| "This nearby cleanup is harmless." | If it is outside scope, note it instead of editing it. |
| "The tests should still pass." | Run the check or state it was not verified. |
| "This abstraction might be useful later." | Keep only abstractions earning their complexity now. |
| "I can simplify while adding the feature." | Separate behavior changes from cleanup unless the plan explicitly couples them. |
| "This changes behavior only slightly." | That is not simplification. Route to `spec-evolution` or TDD. |

## Stop Conditions

Stop and ask or reroute when:

- You discover the code has intentional complexity you do not understand.
- Simplification would alter behavior or public contracts.
- Tests are missing and the code is high risk.
- Cleanup would touch unrelated files.
- The diff is becoming too large to review safely.

## Integration

- `using-sdd` routes cleanup/refactor-without-behavior-change here.
- `code-review` may recommend this for readability and complexity findings.
- `receiving-code-review` classifies review feedback before this workflow fixes
  it.
- `tech-debt` tracks broad debt; this workflow performs one focused cleanup.
- `verification-before-completion` is required before claiming the cleanup is
  complete.
