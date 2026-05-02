# Installing SDD Skills for Codex

SDD remains Claude-native. Codex compatibility is provided by a lightweight
adapter that points Codex at the existing `.claude/skills` directory.

## Windows Setup (Recommended)

Run from the repository root in PowerShell:

```powershell
$repo = (Get-Location).Path
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\sdd" "$repo\.claude\skills"
```

Verify:

```powershell
Test-Path "$env:USERPROFILE\.agents\skills\sdd"
Get-ChildItem "$env:USERPROFILE\.agents\skills\sdd" | Select-Object -First 5
```

## macOS / Linux Setup

```bash
REPO="/path/to/sdd-repo"
mkdir -p "$HOME/.agents/skills"
ln -sf "$REPO/.claude/skills" "$HOME/.agents/skills/sdd"
```

Verify:

```bash
ls -la "$HOME/.agents/skills/sdd" | head -5
```

## First Session In Codex

After the junction is installed, start Codex in this repository and use the
prompt in:

```text
.codex/START.md
```

That file gives Codex the nearest equivalent to Claude's `/start` workflow:
adapter bootstrap -> context reading -> `using-sdd` routing -> `start` onboarding.

## Session Checklist

At the start of each Codex session:

1. Read `AGENTS.md` (entry point + safety rules)
2. Read `.codex/CONTEXT.md` (critical context summary)
3. Read `.codex/PRE_EDIT_CHECKLIST.md` (before any code edit)
4. Read `.codex/COMPLETION_CHECKLIST.md` (before claiming done)

## Uninstall

Remove only the junction/symlink, not the source skills:

**Windows:**
```powershell
Remove-Item "$env:USERPROFILE\.agents\skills\sdd"
```

**macOS/Linux:**
```bash
rm "$HOME/.agents/skills/sdd"
```

## Notes

- The junction/symlink makes Codex discover the same skills Claude uses.
- `.codex/START.md` is the recommended first prompt for Codex onboarding.
- Do not copy the skill files unless you intentionally want a detached fork.
- Do not modify `.claude/settings.json` for Codex installation.
- Claude Code hooks do not run automatically in Codex; use `AGENTS.md` and
  `docs/codex-compatibility.md` for the adapter contract.
