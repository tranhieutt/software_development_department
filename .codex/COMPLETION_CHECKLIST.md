# Codex Completion Checklist

> Before claiming work is done, Codex must complete this checklist.
> This replaces Claude's `verification-before-completion` hook discipline.

## Required Steps

### 1. Fresh Verification

Run the verification command declared in the pre-code gate:

```text
Verification: <exact command from pre-code gate>
```

- [ ] Command executed successfully
- [ ] Output shows expected results (pass, build success, lint clean)
- [ ] No warnings left unaddressed

### 2. Changed Files Summary

Report all files changed:

```text
Files changed:
- <file 1>: <what changed>
- <file 2>: <what changed>
```

### 3. Verification Commands and Results

```text
Commands run:
- <command>: <pass/fail + key output>
```

### 4. Scope Compliance

- [ ] All changes are within the approved scope
- [ ] No drive-by refactors
- [ ] No extra behavior not in the spec/task
- [ ] Every line traces to a user requirement

### 5. Risk Assessment

| Risk | Status |
|---|---|
| Breaking existing tests | <none/fixed/pending> |
| API compatibility | <unchanged/needs migration> |
| Security impact | <none/reviewed> |
| Performance impact | <none/benchmarked> |

### 6. Unreported Items

- [ ] Report any skipped or unavailable checks (with reason)
- [ ] Mention unrelated untracked files only if they matter

## Blocked Completion Claims

Do NOT claim completion if:

- Verification command was not run or failed
- "Looks good" or "should work" is the only evidence
- A previous run's output is reused without checking freshness
- Warnings, skipped tests, or partial failures are ignored
