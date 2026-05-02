# Codex Pre-Edit Checklist

> Before ANY code edit, Codex must complete this checklist.
> This replaces Claude's `pre-code-gate` hook which does not run in Codex.

## Gate Check

State the following before the first implementation edit:

```
Pre-code gate: <Fast|Spec|Plan|Interview|Override>
Satisfied by: <evidence — task file, approved spec, user approval, or ADR>
File: <exact path to be edited>
Verification: <exact command or check to prove the change works>
```

If the gate is NOT satisfied, stop and ask for the missing approval or clarification.

## Gate Definitions

| Gate | When to use | Evidence |
|---|---|---|
| Fast | Trivial fix, <10 lines, no behavior change | User says "just fix it" |
| Spec | New feature, behavior change, or API addition | Approved spec in `design/specs/` |
| Plan | Multi-file or multi-task work | Approved task list in `.tasks/` or `TODO.md` |
| Interview | Ambiguous requirement, need clarification | User answers structured questions |
| Override | User explicitly approves bypassing gates | User says "skip the gate" or equivalent |

## Pre-Edit Safety Check

Before executing any command, verify it is NOT in the blocked list in `AGENTS.md`.

## Pre-Edit Scope Check

- [ ] File is within the approved scope
- [ ] No other agent/task is touching overlapping files
- [ ] Change traces directly to a user requirement
- [ ] No drive-by refactors or scope expansion
