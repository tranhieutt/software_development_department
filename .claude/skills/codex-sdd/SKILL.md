---
name: codex-sdd
type: workflow
description: "Adapts SDD for Codex while preserving Claude Code behavior. Use when working in Codex, setting up Codex compatibility, mapping Claude tools to Codex tools, or explaining how SDD should run outside Claude Code."
argument-hint: "[codex-task-or-compatibility-question]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
context: main
effort: 2
agent: technical-director
when_to_use: "Use at the start of Codex sessions in this repo, before Codex implementation work governed by SDD, and whenever the task mentions Codex compatibility, AGENTS.md, .codex, or Claude-to-Codex workflow mapping."
---

# Codex SDD

`codex-sdd` is the Codex adapter for the Software Development Department.

It does not replace Claude Code behavior. It helps Codex follow the existing
SDD contract without changing the Claude-native runtime.

## Core Rule

Treat these files as the SDD source of truth:

1. `CLAUDE.md`
2. `.claude/skills/using-sdd/SKILL.md`
3. `docs/technical/SDD_LIFECYCLE_MAP.md`
4. `.claude/settings.json` for Claude-only runtime behavior

Use `using-sdd` for routing. Use this skill only for Codex-specific adaptation.

## Non-Impact Boundary

Do not change these for Codex-only reasons:

- `.claude/settings.json`
- `.claude/hooks/`
- existing skill names or directories
- existing agent names or files
- Claude workflow semantics for `/plan`, `/spec`, `/tdd`, `/context`, or other
  SDD commands

Codex compatibility must be additive unless the user explicitly approves a
broader Claude regression-tested change.

## Codex Session Start

At the start of a Codex session in SDD:

1. Read `AGENTS.md`.
2. Read `.claude/skills/using-sdd/SKILL.md`.
3. Use `docs/technical/SDD_LIFECYCLE_MAP.md` for phase orientation.
4. Select the governing SDD skill for the user request.
5. Remember that Claude hooks do not auto-run in Codex.

## Tool Mapping

| Claude-style tool | Codex equivalent |
| --- | --- |
| `Read` | shell read commands or direct file inspection |
| `Glob` | `rg --files` or shell listing |
| `Grep` | `rg` |
| `Write` | `apply_patch` |
| `Edit` | `apply_patch` |
| `Bash` | `shell_command` |
| `RunCommand` | `shell_command` |
| `Task` | `spawn_agent` only when explicitly authorized |
| `TodoWrite` | `update_plan` |
| `AskUserQuestion` | concise direct user question |
| `WebSearch` | web search only when required or explicitly requested |

## Manual Hook Equivalents

Claude Code hooks in `.claude/settings.json` do not run automatically in Codex.
Use manual equivalents:

| Claude behavior | Codex behavior |
| --- | --- |
| Session bootstrap | Read `AGENTS.md`, `using-sdd`, lifecycle map, and relevant memory. |
| Pre-code gate | State the SDD pre-code gate before edits. |
| Bash safety | Follow Codex sandbox and escalation rules. |
| File history | Use `git log -- <file>` when needed. |
| Write logging | Use git diff/status and final changed-file summary. |
| Circuit guard | Inspect `.claude/memory/circuit-state.json` before subagent workflows. |
| Completion gate | Use `verification-before-completion` before success claims. |

## Pre-Code Gate

Before implementation edits, state:

```text
Pre-code gate: <Fast|Spec|Plan|Interview|Override> satisfied by <evidence>; next edit: <file>; verification: <command/check>.
```

If the gate is not satisfied, stop and ask for the missing approval or
clarification.

## Verification

For SDD repo changes, run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1
```

If verification cannot be run, say exactly what was skipped and why.

For narrower checks, use:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1
node scripts\harness-audit.js --compact
```

## References

- `AGENTS.md`
- `.codex/INSTALL.md`
- `docs/codex-compatibility.md`
- `.claude/skills/using-sdd/SKILL.md`
- `docs/technical/SDD_LIFECYCLE_MAP.md`
