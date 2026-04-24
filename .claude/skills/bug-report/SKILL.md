---
name: bug-report
type: workflow
description: "Creates a structured bug report with reproduction steps, expected vs actual behavior, environment details, and severity assessment. Use when a bug or defect is found and needs to be formally documented."
argument-hint: "[description]
/bug-report analyze [path-to-file]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
effort: 1
when_to_use: "When reporting a bug, creating a structured bug report, or analyzing code to identify potential defects"
---

When invoked with a description:

1. **Parse the description** for key information.

2. **Search the codebase** for related files using Grep/Glob to add context.

3. **Generate the bug report**:

```markdown
# Bug Report

## Summary
**Title**: [Concise, descriptive title]
**ID**: BUG-[NNNN]
**Severity**: [S1-Critical / S2-Major / S3-Minor / S4-Trivial]
**Priority**: [P1-Immediate / P2-Next Sprint / P3-Backlog / P4-Wishlist]
**Status**: Open
**Reported**: [Date]
**Reporter**: [Name]

## Classification
- **Category**: [Business / UI / Audio / Visual / Performance / Crash / Network]
- **System**: [Which product system is affected]
- **Frequency**: [Always / Often (>50%) / Sometimes (10-50%) / Rare (<10%)]
- **Regression**: [Yes/No/Unknown -- was this working before?]

## Environment
- **Build**: [Version or commit hash]
- **Platform**: [OS, hardware if relevant]
- **Scene/Level**: [Where in the product]
- **Product State**: [Relevant state -- inventory, quest progress, etc.]

## Reproduction Steps
**Preconditions**: [Required state before starting]

1. [Exact step 1]
2. [Exact step 2]
3. [Exact step 3]

**Expected Result**: [What should happen]
**Actual Result**: [What actually happens]

## Technical Context
- **Likely affected files**: [List of files based on codebase search]
- **Related systems**: [What other systems might be involved]
- **Possible root cause**: [If identifiable from the description]

## Evidence
- **Logs**: [Relevant log output if available]
- **Visual**: [Description of visual evidence]

## Related Issues
- [Links to related bugs or design documents]

## Notes
[Any additional context or observations]
```

When invoked with `analyze`:

1. **Read the target file(s)**.
2. **Identify potential bugs**: null references, off-by-one errors, race
   conditions, unhandled edge cases, resource leaks, incorrect state
   transitions.
3. **For each potential bug**, generate a bug report with the likely trigger
   scenario and recommended fix.

## Protocol

- **Question**: Parses description argument; asks for clarification if reproduction steps or severity are missing
- **Options**: Skip — single report format (or `analyze` mode for static code scan)
- **Decision**: Skip
- **Draft**: Structured report shown in conversation before saving
- **Approval**: "May I write BUG-[NNN] to `[filepath]`?"

## Output

Deliver exactly:

- **Bug report** with: title, severity (Critical/High/Medium/Low), reproduction steps, expected vs actual behavior, environment, and suggested fix
- **`/bug-report analyze` mode**: list of potential bugs found with file:line, trigger scenario, and recommended fix per issue
