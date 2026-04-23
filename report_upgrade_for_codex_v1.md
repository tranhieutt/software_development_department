# Report: SDD Codex Compatibility Upgrade Plan v1

**Project:** `E:\SDD-Upgrade`  
**Goal:** Make SDD usable in both Claude Code and Codex while preserving the existing Claude workflow.  
**Non-negotiable constraint:** Do not weaken, rename, relocate, or rewire the current Claude Code runtime path.

---

## 1. Executive Summary

SDD is currently optimized for Claude Code. Its source of truth is the `.claude/` tree, with native Claude Code support for `CLAUDE.md`, `.claude/settings.json`, agents, skills, hooks, permissions, and lifecycle events.

Codex can already use SDD manually by reading the files, but it does not currently discover the SDD skills automatically and does not execute Claude Code hooks. To support Codex safely, the right approach is **adapter-first compatibility**:

- Keep `.claude/` unchanged as the Claude-native source of truth.
- Add a Codex-facing adapter layer beside it.
- Map Claude tool names and lifecycle assumptions to Codex behavior.
- Provide manual/preflight equivalents for Claude hook enforcement where Codex has no hook event.
- Avoid modifying the Claude Code control plane unless a change is fully backward-compatible.

This preserves Claude behavior while giving Codex enough structure to follow SDD workflows.

---

## 2. Current State

### 2.1 Claude-Native Assets

Current SDD assets:

- `CLAUDE.md` - main Claude Code instruction file.
- `.claude/settings.json` - permissions, status line, and hook registration.
- `.claude/skills/` - 123 skill directories.
- `.claude/agents/` - 28 agent definitions.
- `.claude/hooks/` - 29 hook scripts.
- `.claude/rules/` - 13 path-scoped rule files.
- `.claude/memory/` - durable memory, archive, circuit state, specialist memory.
- `scripts/harness-audit.js` - deterministic harness audit.
- `scripts/validate-skills.ps1` and `scripts/validate-skills.sh` - skill validation.

Recent checks:

- `node scripts\harness-audit.js --compact` reports `120/120`, `0 blocked`, warnings only.
- `powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1` reports `123 pass`, `0 fail`, `58 warnings`.

### 2.2 Codex Compatibility Gaps

The repo currently lacks:

- Root `AGENTS.md` for Codex instructions.
- `.codex/INSTALL.md` for Codex installation/discovery.
- `.agents/` or documented symlink/junction strategy.
- Codex tool mapping for Claude tool names.
- Codex equivalent for Claude lifecycle hooks.
- Codex-specific compatibility documentation.

Codex can read and follow SDD manually, but it will not automatically reproduce Claude Code's native hook-driven enforcement.

---

## 3. Compatibility Principle

Use this architecture:

```text
SDD core source of truth
  .claude/
  CLAUDE.md

Claude runtime
  reads CLAUDE.md
  loads .claude/settings.json
  runs hooks and permissions natively
  loads .claude/agents and .claude/skills

Codex runtime
  reads AGENTS.md
  discovers skills through ~/.agents/skills/sdd -> .claude/skills
  follows Codex adapter instructions
  uses manual/preflight checks where Claude hooks are unavailable
```

This keeps Claude native behavior untouched and adds Codex support as an overlay.

---

## 4. Non-Impact Rules for Claude Code

These rules must be enforced throughout the upgrade:

1. Do not move `.claude/skills`.
2. Do not rename existing skill directories.
3. Do not rename existing agent files.
4. Do not change `.claude/settings.json` for Codex compatibility.
5. Do not weaken permission deny rules in `.claude/settings.json`.
6. Do not replace Claude hook registration with Codex-specific logic.
7. Do not remove `CLAUDE.md` include references.
8. Do not change hook exit-code semantics unless verified in Claude Code.
9. Do not change the workflow meaning of `/plan`, `/spec`, `/tdd`, `/context`, `/diagnose`, `/vertical-slice`, or `/ui-spec`.
10. Any skill frontmatter cleanup must be backward-compatible with Claude Code.

---

## 5. Proposed Upgrade Scope

### Phase 1 - Codex Adapter Skeleton

Add files only:

```text
AGENTS.md
.codex/INSTALL.md
docs/codex-compatibility.md
```

Purpose:

- Tell Codex how to use SDD.
- Keep `.claude/` as source of truth.
- Document skill discovery through `~/.agents/skills`.
- Document runtime limitations.

No existing Claude file changes required.

### Phase 2 - Codex Skill Entry Point

Add one adapter skill:

```text
.claude/skills/codex-sdd/SKILL.md
```

Purpose:

- Provide Codex-specific tool mapping.
- Explain that Claude hooks are not auto-fired in Codex.
- Route all software-development requests to `using-sdd`.
- Define manual replacements for hook gates.

This is additive. Claude Code may see the skill, but it does not affect existing Claude workflows unless explicitly invoked.

### Phase 3 - Manual Hook Equivalents

Add scripts:

```text
scripts/codex-preflight.ps1
scripts/codex-preflight.sh
```

Suggested checks:

- `git status --short`
- `node scripts/harness-audit.js --compact`
- `scripts/validate-skills.ps1` or `.sh`
- check `.claude/memory/circuit-state.json`
- check existence of required SDD files
- optionally run `scripts/trace-integrity-check.js`

Purpose:

- Provide a single command Codex can run before implementation or completion.
- Approximate Claude hook enforcement in a Codex-friendly way.

This does not replace Claude hooks.

### Phase 4 - Skill Metadata Hardening

Fix warnings incrementally:

- Add missing `type` fields to the 58 warning skills.
- Improve `description` triggers for Codex discovery.
- Keep existing `allowed-tools`, `user-invocable`, `effort`, `agent`, and `when_to_use` fields.

Priority skills:

1. `using-sdd`
2. `planning-and-task-breakdown`
3. `spec-driven-development`
4. `test-driven-development`
5. `verification-before-completion`
6. `subagent-driven-development`
7. `systematic-debugging`
8. `code-review`
9. `commit`
10. `save-state`

### Phase 5 - Documentation and Verification

Update documentation only after adapter exists:

- Add a short section to `README.md` linking to `docs/codex-compatibility.md`.
- Keep Claude-first README framing intact unless intentionally rebranded later.
- Add a verification checklist for Claude and Codex.

---

## 6. Codex Tool Mapping

Codex adapter should define this mapping:

| Claude-style tool name | Codex equivalent |
|---|---|
| `Read` | shell read commands, direct file inspection through available tools |
| `Glob` | `rg --files`, shell file listing |
| `Grep` | `rg` |
| `Write` | `apply_patch` for new files |
| `Edit` | `apply_patch` for edits |
| `Bash` | `shell_command` |
| `RunCommand` | `shell_command` |
| `Task` | `spawn_agent` when user explicitly allows subagents or workflow requires available multi-agent execution |
| `TodoWrite` | `update_plan` |
| `AskUserQuestion` | concise direct user question |
| `WebSearch` | `web.run` only when browsing is required or explicitly requested |

Important Codex note:

- Codex does not automatically execute Claude Code `PreToolUse` / `PostToolUse` hooks.
- Codex must manually honor the gates described in SDD skills.
- Codex should use `scripts/codex-preflight.*` before risky work.

---

## 7. Claude Hook Equivalents in Codex

| Claude hook behavior | Current Claude implementation | Codex strategy |
|---|---|---|
| Session bootstrap | `session-start.sh`, `detect-gaps.sh` | `AGENTS.md` tells Codex to read `using-sdd` and relevant memory |
| Prompt context injection | `prompt-context.sh`, `persist-memory.sh` | manual read of relevant memory via `using-sdd` and `context-engineering` |
| Skill telemetry | `log-skill.sh` | optional future script; initially not required |
| Bash safety | `bash-guard.ps1` / `bash-guard.sh` | Codex follows sandbox/escalation rules plus optional preflight checks |
| Pre-code gate | `pre-code-gate.ps1` / `.sh` | Codex must state pre-code gate before edits |
| File history | `file-history.sh` | optional manual `git log -- <file>` |
| Write logging | `log-writes.sh` | optional future Codex trace script |
| Asset validation | `validate-assets.sh` | manual command when relevant |
| Decision extraction | `extract-decisions.sh` | manual `/annotate` or future script |
| Task circuit guard | `circuit-guard.sh` | read `.claude/memory/circuit-state.json` before subagent work |
| Circuit update | `circuit-updater.sh` | future Codex task wrapper, not Phase 1 |
| Stop/session archive | `session-stop.sh` | manual `save-state` skill |

---

## 8. Proposed File Details

### 8.1 `AGENTS.md`

Purpose:

- Codex entrypoint.
- State that `CLAUDE.md` and `.claude/` remain source of truth.
- Instruct Codex to use `.claude/skills/using-sdd/SKILL.md` before non-trivial work.
- Explain that Claude hooks do not auto-run.
- Provide tool mapping.
- Require evidence before completion claims.

Suggested sections:

```markdown
# SDD for Codex

This repository is SDD. The canonical source of truth is `.claude/`.

Before any non-trivial response, read/use `.claude/skills/using-sdd/SKILL.md`.

Codex runtime notes:
- Claude hooks in `.claude/settings.json` do not auto-run here.
- Preserve all Claude-native behavior.
- Use Codex tool equivalents...
```

### 8.2 `.codex/INSTALL.md`

Purpose:

- Let Codex discover SDD skills natively.

Windows junction:

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\sdd" "E:\SDD-Upgrade\.claude\skills"
```

Portable template:

```powershell
$repo = "E:\SDD-Upgrade"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\sdd" "$repo\.claude\skills"
```

Uninstall:

```powershell
Remove-Item "$env:USERPROFILE\.agents\skills\sdd"
```

### 8.3 `docs/codex-compatibility.md`

Purpose:

- Explain supported and unsupported behavior.
- Track parity matrix.
- Provide verification checklist.

Suggested status labels:

- `Native` - works directly in Codex.
- `Adapter` - works through `AGENTS.md` or skill mapping.
- `Manual` - requires explicit command/check.
- `Claude-only` - intentionally remains Claude-native.

### 8.4 `.claude/skills/codex-sdd/SKILL.md`

Purpose:

- Make Codex compatibility discoverable as a skill.
- Route to `using-sdd`.
- Teach the tool mapping.

This skill should be short. It should not duplicate all SDD rules.

---

## 9. Validation Plan

### 9.1 Claude Regression Checks

Run after any compatibility changes:

```powershell
node scripts\harness-audit.js --compact
powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1
```

Manual Claude checks:

- Open Claude Code in `E:\SDD-Upgrade`.
- Confirm `CLAUDE.md` still loads.
- Confirm `/plan`, `/spec`, `/tdd`, `/context` still route correctly.
- Confirm `.claude/settings.json` hook registration remains unchanged.
- Confirm no hook file paths changed.

Pass criteria:

- Harness audit remains `120/120`.
- Skill validator has `0 fail`.
- No existing Claude workflow command is renamed or removed.

### 9.2 Codex Checks

After adding Codex adapter:

```powershell
Test-Path AGENTS.md
Test-Path .codex\INSTALL.md
Test-Path docs\codex-compatibility.md
```

After installing skill junction:

```powershell
Test-Path "$env:USERPROFILE\.agents\skills\sdd"
Get-ChildItem "$env:USERPROFILE\.agents\skills\sdd" | Select-Object -First 5
```

Behavior checks:

- Start Codex in `E:\SDD-Upgrade`.
- Ask a non-trivial software task.
- Confirm Codex routes through `using-sdd`.
- Confirm Codex states pre-code gate before edits.
- Confirm Codex uses `update_plan` for task tracking.
- Confirm Codex uses `apply_patch` for edits.
- Confirm Codex does not claim completion without fresh evidence.

---

## 10. Risk Register

| Risk | Impact | Mitigation |
|---|---|---|
| Codex adapter changes Claude behavior | High | Add files only in Phase 1; do not edit `.claude/settings.json` |
| Skill routing becomes noisy in Codex due to 123 skills | Medium | Add `codex-sdd` and strengthen core skill descriptions |
| Codex assumes Claude hooks ran | High | `AGENTS.md` explicitly says hooks do not auto-run |
| Tool names confuse Codex | Medium | Add tool mapping in `AGENTS.md` and `codex-sdd` |
| Skill metadata cleanup breaks Claude | Medium | Only add backward-compatible fields; run Claude regression checks |
| MCP assumptions fail in Codex | Medium | Mark MCP as separately configured; provide fallback local workflows |
| Subagent workflows behave differently | Medium | Require explicit multi-agent availability and fallback to inline execution |

---

## 11. Recommended Implementation Order

1. Add `AGENTS.md`.
2. Add `.codex/INSTALL.md`.
3. Add `docs/codex-compatibility.md`.
4. Run Claude regression checks.
5. Add `.claude/skills/codex-sdd/SKILL.md`.
6. Run skill validator and harness audit.
7. Add `scripts/codex-preflight.ps1` and `.sh`.
8. Test Codex skill discovery through `~/.agents/skills/sdd`.
9. Harden metadata for the 10 core skills.
10. Add a small README pointer to Codex documentation.

---

## 12. Acceptance Criteria

The upgrade is complete when:

- Claude Code behavior remains unchanged.
- `node scripts\harness-audit.js --compact` remains `120/120`.
- `scripts\validate-skills.ps1` reports `0 fail`.
- Codex has a root `AGENTS.md` entrypoint.
- Codex install instructions exist under `.codex/INSTALL.md`.
- Codex can discover SDD skills via `~/.agents/skills/sdd`.
- Codex has a documented tool mapping for all SDD tool names.
- Codex has documented replacements for Claude hook behavior.
- Codex can execute the SDD core flow:
  - route through `using-sdd`
  - plan/spec before implementation
  - TDD for code changes
  - verification before completion claims

---

## 13. Final Recommendation

Proceed with an additive Codex adapter. Do not refactor the Claude-native `.claude/` system as part of the first compatibility pass.

The safest strategy is:

```text
Do not make SDD less Claude-native.
Make Codex understand the existing SDD contract.
```

This gives immediate Codex usability while preserving the mature Claude Code harness.
