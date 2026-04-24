# Codex Compatibility

> Status: Adapter baseline implemented; metadata hardening and warning reduction remain in progress.
> Source of truth: `CLAUDE.md` and `.claude/`.
> Constraint: Codex support must not change Claude Code runtime behavior.

---

## 1. Compatibility Model

SDD is built natively for Claude Code. Codex can still use SDD by reading the
same source files and following an adapter contract:

```text
Claude Code
  CLAUDE.md
  .claude/settings.json
  .claude/agents
  .claude/skills
  .claude/hooks

Codex
  AGENTS.md
  .codex/INSTALL.md
  docs/codex-compatibility.md
  optional junction: ~/.agents/skills/sdd -> .claude/skills
```

Claude remains the runtime owner. Codex is a compatible client.

---

## 2. Status Labels

| Label | Meaning |
| --- | --- |
| Native | Works directly in Codex without extra setup. |
| Adapter | Works through `AGENTS.md`, this document, or skill mapping. |
| Manual | Requires explicit command or manual verification in Codex. |
| Claude-only | Intentionally remains Claude Code runtime behavior. |

---

## 3. Parity Matrix

| SDD capability | Claude Code | Codex | Status |
| --- | --- | --- | --- |
| Root instructions | `CLAUDE.md` | `AGENTS.md` | Adapter |
| Skill source files | `.claude/skills` | Same directory, optionally via junction | Adapter |
| Agent definitions | `.claude/agents` | Readable as reference | Manual |
| Hook registration | `.claude/settings.json` | Not executed automatically | Claude-only |
| Permission model | Claude settings and hooks | Codex sandbox and approvals | Adapter |
| Pre-code gate | Hook + skill discipline | Stated manually before edits | Manual |
| Skill validation | `scripts/validate-skills.*` | Same scripts | Native |
| Harness audit | `scripts/harness-audit.js` | Same script | Native |
| Codex preflight | Not required | `scripts/codex-preflight.*` | Manual |
| Memory files | `.claude/memory` | Readable as project files | Manual |
| Circuit breaker | Hooks read/write circuit state | Manual inspection today | Manual |
| Verification before completion | Skill discipline | Same discipline through `AGENTS.md` | Adapter |
| Commit/push flow | User-approved | User-approved | Native |

---

## 4. Codex Operating Contract

Codex should:

1. Treat `.claude/` as the canonical SDD system.
2. Use `.claude/skills/codex-sdd/SKILL.md` for Codex-specific adaptation.
3. Read `.claude/skills/using-sdd/SKILL.md` before non-trivial work.
4. Use `docs/technical/SDD_LIFECYCLE_MAP.md` for phase orientation.
5. State the pre-code gate before implementation edits.
6. Use `apply_patch` for edits.
7. Use fresh verification before completion claims.
8. Preserve unrelated user changes and untracked files.
9. Avoid changing Claude runtime files for Codex-only reasons.

Codex should not:

- Assume Claude hooks have run.
- Claim Claude runtime behavior was verified unless it was checked in Claude.
- Move or rename `.claude/skills`, `.claude/agents`, or hooks.
- Weaken `.claude/settings.json`.

---

## 5. Tool Mapping

| Claude-style name | Codex equivalent |
| --- | --- |
| `Read` | Shell read commands or direct file inspection |
| `Glob` | `rg --files` |
| `Grep` | `rg` |
| `Write` | `apply_patch` |
| `Edit` | `apply_patch` |
| `Bash` | `shell_command` |
| `RunCommand` | `shell_command` |
| `Task` | `spawn_agent` only when explicitly authorized |
| `TodoWrite` | `update_plan` |
| `AskUserQuestion` | Concise direct question |
| `WebSearch` | Web search only when required or requested |

---

## 6. Manual Hook Equivalents

| Claude hook behavior | Codex equivalent today |
| --- | --- |
| Session bootstrap | Read `AGENTS.md`, `using-sdd`, lifecycle map, and relevant memory. |
| Prompt context injection | Manually inspect relevant `.claude/memory` files when needed. |
| Bash safety | Follow Codex sandbox and escalation rules. |
| Pre-code gate | State the gate line before edits. |
| File history | Use `git log -- <file>` when history matters. |
| Write logging | Use git diff/status and final changed-file summary. |
| Asset validation | Run explicit validation commands when assets are affected. |
| Circuit guard | Inspect `.claude/memory/circuit-state.json` before subagent workflows. |
| Session archive | Use `save-state` discipline or manual summary when needed. |

---

## 7. Verification Checklist

After adapter changes:

```powershell
Test-Path AGENTS.md
Test-Path .codex\INSTALL.md
Test-Path docs\codex-compatibility.md
Test-Path scripts\codex-preflight.ps1
powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1
node scripts\harness-audit.js --compact
```

Codex preflight:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1
```

After installing the optional skill junction:

```powershell
Test-Path "$env:USERPROFILE\.agents\skills\sdd"
Get-ChildItem "$env:USERPROFILE\.agents\skills\sdd" | Select-Object -First 5
```

Manual Codex behavior check:

1. Start Codex in the SDD repo.
2. Ask for a non-trivial software-development task.
3. Confirm Codex routes through `using-sdd`.
4. Confirm Codex states a pre-code gate before edits.
5. Confirm Codex uses `apply_patch` for file edits.
6. Confirm Codex reports fresh verification before completion.

Manual Claude regression check:

1. Start Claude Code in the SDD repo.
2. Confirm `CLAUDE.md` loads.
3. Confirm `.claude/settings.json` is unchanged.
4. Confirm core workflows such as `/plan`, `/spec`, `/tdd`, and `/context`
   still route as before.

---

## 8. Current Adapter Status

The additive Codex adapter baseline is already present in the repo:

- `AGENTS.md`
- `.codex/INSTALL.md`
- `docs/codex-compatibility.md`
- `.claude/skills/codex-sdd/SKILL.md`
- `scripts/codex-preflight.ps1`
- `scripts/codex-preflight.sh`
- README guidance for Codex users

This means Codex now has:

- a repo entrypoint,
- a documented skill discovery path,
- Claude-to-Codex tool mapping,
- manual replacements for Claude hook behavior,
- and a single preflight command for risky work and completion claims.

These changes are additive and do not require changing `.claude/settings.json`,
hook wiring, skill names, or Claude workflow command semantics.

## 9. Remaining Backlog

The remaining work is hardening rather than missing baseline functionality:

1. Reduce schema and audit warnings so Codex skill discovery has cleaner
   metadata.
2. Keep the status docs in sync with the actual repo state as the adapter
   evolves.
3. Preserve the current boundary that Claude hooks remain Claude-only and Codex
   continues to use manual/preflight checks.
4. Treat optional user-local setup such as the `~/.agents/skills/sdd` junction
   as install-time work, not a repo-enforced runtime dependency.

## 10. Ongoing Verification Contract

After Codex adapter changes, run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1
powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1
node scripts\harness-audit.js --compact
git diff --check
```

Manual verification still matters for:

- Codex behavior inside an actual Codex session
- Claude-native hook execution inside Claude Code
- the optional local skill junction under `~/.agents/skills/sdd`
