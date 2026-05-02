# Codex Pre-Edit Checklist

> Before implementation edits, Codex must complete this checklist. This replaces
> Claude's `pre-code-gate` hook, which does not run automatically in Codex.

## Gate Check

State this single line before the first implementation edit:

```text
Pre-code gate: <Fast|Spec|Plan|Interview|Override> satisfied by <evidence>; next edit: <file>; verification: <command/check>.
```

If the gate is not satisfied, stop and ask for the missing approval or
clarification.

## Gate Definitions

| Gate | When to use | Evidence |
|---|---|---|
| Fast | Small, explicit, low-risk edit; one obvious file; no behavior ambiguity | Exact user request, clear local evidence, and known verification |
| Spec | New feature, behavior change, UI flow, API change, data change, or unclear side effects | Approved spec, task, ADR, or explicit user approval |
| Plan | Multi-file work, multi-task work, cross-domain change, or epic | Approved task list or explicit user approval for the next task |
| Interview | Ambiguous requirement or hidden assumptions | User answers structured questions |
| Override | User explicitly approves bypassing gates after risk is stated | User says "skip the gate" or equivalent |

## Safety Check

Before executing commands or editing files:

- Confirm command is not blocked by `AGENTS.md`.
- Assign risk tier: Low, Medium, or High.
- Ask explicit approval for destructive, production, or cross-domain actions.

## Scope Check

- [ ] File is within approved scope.
- [ ] No known overlapping task owns the same file.
- [ ] Change traces directly to user request, approved spec, or approved task.
- [ ] No drive-by refactors or scope expansion.
