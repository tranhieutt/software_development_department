# Codex Completion Checklist

> Before claiming work is done, Codex must complete this checklist. This
> preserves `verification-before-completion` discipline outside Claude Code.

## Required Steps

### 1. Fresh Verification

Run the verification command declared in the pre-code gate:

```text
Verification: <exact command from pre-code gate>
```

- [ ] Command executed successfully, or failure is clearly unrelated to the scoped change.
- [ ] Output shows expected result for the claim being made.
- [ ] Warnings are fixed, classified, or reported with scope impact.

### 2. Changed Files Summary

Report all files changed:

```text
Files changed:
- <file 1>: <what changed>
- <file 2>: <what changed>
```

### 3. Verification Commands And Results

```text
Commands run:
- <command>: <pass/fail + key output>
```

### 4. Scope Compliance

- [ ] All changes are within approved scope.
- [ ] No drive-by refactors.
- [ ] No extra behavior outside the spec/task/request.
- [ ] Every material change traces to the user request or approved plan.

### 5. Risk Assessment

| Risk | Status |
|---|---|
| Breaking existing tests | <none/fixed/pending> |
| API compatibility | <unchanged/needs migration> |
| Security impact | <none/reviewed> |
| Performance impact | <none/benchmarked> |

### 6. Unreported Items

- [ ] Report skipped or unavailable checks with reason.
- [ ] Mention unrelated untracked files only if they matter to the next step.

## Blocked Completion Claims

Do not claim completion if:

- Verification command was not run.
- "Looks good" or "should work" is the only evidence.
- A previous run's output is reused without checking freshness.
- Warnings, skipped tests, or partial failures are ignored.

If full verification fails for unrelated existing issues, narrow the completion
claim and report the failing check.
