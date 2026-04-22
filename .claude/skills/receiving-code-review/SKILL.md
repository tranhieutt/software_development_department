---
name: receiving-code-review
type: workflow
description: "Processes code review feedback systematically by classifying findings, deciding fix or reject with evidence, applying approved fixes, and re-verifying before marking comments resolved."
argument-hint: "[review-comments-or-pr-number]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
context: main
effort: 3
agent: lead-programmer
when_to_use: "Use after receiving code review, PR comments, subagent review findings, or a CHANGES_REQUIRED verdict; also use when deciding which review comments to fix, defer, reject, or route to spec-evolution."
---

# Receiving Code Review

## Purpose

`receiving-code-review` turns review feedback into controlled engineering work.
It prevents agents from blindly applying every suggestion, ignoring blockers, or
quietly expanding scope while "addressing comments."

This workflow is for response and remediation after review. It complements
`code-review`, which produces findings.

## Core Rule

```text
Every review comment must be classified, resolved with evidence, deferred with
an explicit owner, or rejected with a technical reason.
```

Do not mark a comment resolved because code changed nearby. Do not say feedback
is addressed until the specific finding has fresh verification evidence.

## Workflow

### 1. Collect Review Inputs

Gather the review material:

- PR or review comments
- `code-review` or `code-review-checklist` output
- Subagent spec-compliance or code-quality review findings
- The approved spec/plan, if the review refers to requirements
- The changed files or diff relevant to each finding

If the review feedback is missing, ask for it or inspect the available PR/review
source. Do not invent likely comments.

### 2. Normalize Findings

Create one item per distinct finding. Preserve file and line references when
available.

For each finding, record:

- Reviewer concern
- File/line or affected behavior
- Severity: `BLOCKER`, `MUST_FIX`, `SHOULD_FIX`, `NIT`, `QUESTION`
- Category: `correctness`, `security`, `performance`, `test`, `architecture`,
  `maintainability`, `style`, `docs`, `spec-drift`, or `unclear`
- Proposed disposition: `fix`, `reject`, `defer`, `needs-clarification`, or
  `route-to-spec-evolution`

### 3. Decide Disposition

Use these rules:

| Finding | Required disposition |
| --- | --- |
| Security, correctness, data loss, privacy, auth, or broken tests | `fix` unless demonstrably false |
| Missing acceptance criterion or behavior outside approved spec | `route-to-spec-evolution` |
| Ambiguous requirement or reviewer question | `needs-clarification` before code |
| Style or naming issue aligned with project conventions | `fix` if low-risk |
| Suggestion that broadens scope | `defer` or `route-to-spec-evolution` |
| Incorrect comment | `reject` with evidence and code/spec reference |

Do not batch unrelated fixes under one finding. Do not combine review remediation
with opportunistic refactoring.

### 4. Build the Response Plan

Before editing, output a concise response plan:

```markdown
## Review Response Plan

| Finding | Severity | Disposition | Action | Verification |
| --- | --- | --- | --- | --- |
| [file:line or summary] | BLOCKER | fix | [exact change] | [command/check] |
```

If any item changes behavior, data, architecture, or acceptance criteria, pause
and route through `spec-evolution` before implementation.

### 5. Apply Fixes With the Right Gate

For each `fix` item:

- Use `test-driven-development` for behavior, bug, validation, security, or
  regression changes.
- Use the existing plan/spec gate if the fix is part of an approved task.
- Use a Fast Gate only for small mechanical review fixes such as naming,
  comments, formatting, or docs.
- Run the verification named for that finding.

For `reject` items:

- Cite the exact code, spec, test, or command output proving the comment does
  not apply.
- Keep tone factual.
- Do not change code just to satisfy an incorrect comment.

For `defer` items:

- Name the follow-up issue/spec/owner if available.
- Explain why it is not required for the current review gate.

### 6. Re-Review and Close the Loop

After fixes:

- Re-run the specific verification for each fixed finding.
- Run broader tests/checks if the fix touched shared behavior.
- Re-read the changed diff against the original review findings.
- Use `verification-before-completion` before saying comments are addressed.

If any reviewer finding remains open, report it plainly. Do not claim review is
fully addressed.

## Output Format

```markdown
## Receiving Code Review: [PR/Task/Scope]

### Findings Triage
| Finding | Severity | Category | Disposition | Reason |
| --- | --- | --- | --- | --- |

### Fix Plan
| Finding | Files | Gate | Verification |
| --- | --- | --- | --- |

### Responses
- [Finding]: fixed/rejected/deferred/needs clarification because [evidence].

### Verification
- [Command/check]: [result]

### Remaining Items
- [Open item, or "None"]
```

## Anti-Rationalizations

| Thought | Required correction |
| --- | --- |
| "I'll just apply all suggestions." | Suggestions can be wrong or out of scope. Classify first. |
| "This comment is minor; no verification needed." | Every fix needs at least a targeted check. |
| "The reviewer probably meant X." | Ask or state the assumption; do not guess silently. |
| "I'll resolve the thread after pushing." | Verify the specific finding first. |
| "This review comment implies a new feature." | Route scope changes to `spec-evolution`. |
| "The comment is wrong, so ignore it." | Reject with evidence; do not leave it unaccounted for. |

## Integration

- Use after `code-review`, `code-review-checklist`, PR comments, or subagent
  review gates return findings.
- Route spec or acceptance-criteria conflicts to `spec-evolution`.
- Route behavior fixes to `test-driven-development`.
- Use `verification-before-completion` before marking review comments resolved.
