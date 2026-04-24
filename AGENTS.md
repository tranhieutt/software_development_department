# SDD for Codex

This repository is the Software Development Department (SDD) harness.

The canonical source of truth remains Claude-native:

- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/agents/`
- `.claude/skills/`
- `.claude/hooks/`
- `.claude/memory/`

Codex support is an adapter layer. Do not change Claude runtime behavior to make
Codex work.

## Operating Rule

Before any non-trivial software-development response, review:

1. `.claude/skills/using-sdd/SKILL.md`
2. `docs/technical/SDD_LIFECYCLE_MAP.md`
3. The specific SDD skill that matches the task

Use SDD's six-phase map:

```text
DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP
```

For implementation work, state the pre-code gate before the first production
edit:

```text
Pre-code gate: <Fast|Spec|Plan|Interview|Override> satisfied by <evidence>; next edit: <file>; verification: <command/check>.
```

## Codex Runtime Notes

Claude Code hooks in `.claude/settings.json` do not run automatically in Codex.
Codex must manually honor the same gates through instructions, file inspection,
and verification commands.

Preserve these boundaries:

- Do not move or rename `.claude/skills`.
- Do not move or rename `.claude/agents`.
- Do not weaken `.claude/settings.json` permissions.
- Do not replace Claude hooks with Codex-specific behavior.
- Do not claim work is done without fresh evidence.
- Do not commit or push unless the user explicitly asks.

## Quick Start In Codex

Codex does not have Claude slash commands, so the closest equivalent to
Claude's `/start` is to begin the session with the prompt in:

- `.codex/START.md`

That prompt tells Codex to:

1. use the Codex adapter in `.claude/skills/codex-sdd/SKILL.md`
2. route through `.claude/skills/using-sdd/SKILL.md`
3. follow `.claude/skills/start/SKILL.md`
4. ask the same onboarding question Claude would ask before any edits

If you do not want to open the file, paste this directly into Codex:

```text
Use codex-sdd, then route through using-sdd, then run the start workflow for this repo.
```

## Tool Mapping

| Claude-style tool | Codex equivalent |
| --- | --- |
| `Read` | Shell read commands or direct file inspection |
| `Glob` | `rg --files` or shell file listing |
| `Grep` | `rg` |
| `Write` | `apply_patch` for new files |
| `Edit` | `apply_patch` for edits |
| `Bash` | `shell_command` |
| `RunCommand` | `shell_command` |
| `Task` | `spawn_agent` only when explicitly authorized by the user or workflow |
| `TodoWrite` | `update_plan` |
| `AskUserQuestion` | Concise direct user question |
| `WebSearch` | Web search only when required or explicitly requested |

## Verification

For SDD repo changes, prefer these checks:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1
powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1
node scripts\harness-audit.js --compact
```

If a change affects runtime hooks, permissions, agents, memory, or release
behavior, also inspect the changed files directly and state any unverified
Claude-only behavior.

## Completion Discipline

Before saying a task is complete:

- Report the files changed.
- Report the verification commands and results.
- Report any skipped or unavailable checks.
- Mention unrelated untracked files only if they matter to the user's next step.
