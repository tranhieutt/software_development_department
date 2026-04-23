# Installing SDD Skills for Codex

SDD remains Claude-native. Codex compatibility is provided by a lightweight
adapter that points Codex at the existing `.claude/skills` directory.

## Recommended Windows Setup

Run from any PowerShell session:

```powershell
$repo = "E:\SDD-Upgrade"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\sdd" "$repo\.claude\skills"
```

Verify:

```powershell
Test-Path "$env:USERPROFILE\.agents\skills\sdd"
Get-ChildItem "$env:USERPROFILE\.agents\skills\sdd" | Select-Object -First 5
```

## Portable Template

If the repository lives somewhere else:

```powershell
$repo = "<absolute-path-to-sdd-repo>"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\sdd" "$repo\.claude\skills"
```

## Uninstall

Remove only the junction, not the source skills:

```powershell
Remove-Item "$env:USERPROFILE\.agents\skills\sdd"
```

## Notes

- The junction makes Codex discover the same skills Claude uses.
- Do not copy the skill files unless you intentionally want a detached fork.
- Do not modify `.claude/settings.json` for Codex installation.
- Claude Code hooks do not run automatically in Codex; use `AGENTS.md` and
  `docs/codex-compatibility.md` for the adapter contract.
