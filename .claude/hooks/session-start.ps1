# Claude Code SessionStart hook: Load project context at session start (PowerShell)
# Outputs context information that Claude sees when a session begins

Write-Host "=== Claude Code Software Development Department — Session Context (PS) ==="

# SDD Router
$usingSddSkill = ".claude/skills/using-sdd/SKILL.md"
if (Test-Path $usingSddSkill) {
    Write-Host ""
    Write-Host "=== SDD ROUTER ==="
    Write-Host "Required workflow router: $usingSddSkill"
    Write-Host "Before any task action, route the request through using-sdd and follow the matching SDD skill gates."
    Write-Host "=== END SDD ROUTER ==="
}

# Current branch
$branch = git rev-parse --abbrev-ref HEAD 2>$null
if ($branch) {
    Write-Host "Branch: $branch"

    # Recent commits
    Write-Host ""
    Write-Host "Recent commits:"
    git log --oneline -5 2>$null | ForEach-Object {
        Write-Host "  $_"
    }
}

# Current sprint (find most recent sprint file)
$latestSprint = Get-ChildItem "production/sprints/sprint-*.md" 2>$null | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestSprint) {
    Write-Host ""
    Write-Host "Active sprint: $($latestSprint.BaseName)"
}

# Current milestone
$latestMilestone = Get-ChildItem "production/milestones/*.md" 2>$null | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestMilestone) {
    Write-Host "Active milestone: $($latestMilestone.BaseName)"
}

# Open bug count
$bugCount = 0
$targetDirs = @("tests/playtest", "production")
foreach ($dir in $targetDirs) {
    if (Test-Path $dir) {
        $count = (Get-ChildItem -Path $dir -Filter "BUG-*.md" -Recurse 2>$null).Count
        if ($null -eq $count) { $count = 0 }
        $bugCount += $count
    }
}
if ($bugCount -gt 0) {
    Write-Host "Open bugs: $bugCount"
}

# Code health quick check
if (Test-Path "src") {
    $todoCount = (Select-String -Path "src/*" -Pattern "TODO" -Recurse 2>$null).Count
    $fixmeCount = (Select-String -Path "src/*" -Pattern "FIXME" -Recurse 2>$null).Count
    if ($null -eq $todoCount) { $todoCount = 0 }
    if ($null -eq $fixmeCount) { $fixmeCount = 0 }
    
    if ($todoCount -gt 0 -or $fixmeCount -gt 0) {
        Write-Host ""
        Write-Host "Code health: $todoCount TODOs, $fixmeCount FIXMEs in src/"
    }
}

# --- Active session state recovery / bootstrap ---
$stateDir = "production/session-state"
$stateFile = "$stateDir/active.md"
if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force 2>$null | Out-Null
}

if (Test-Path $stateFile) {
    Write-Host ""
    Write-Host "=== ACTIVE SESSION STATE DETECTED ==="
    Write-Host "A previous session left state at: $stateFile"
    Write-Host "Read this file to recover context and continue where you left off."
    Write-Host ""
    Write-Host "Quick summary:"
    Get-Content $stateFile -TotalCount 20 2>$null
    $totalLines = (Get-Content $stateFile 2>$null).Count
    if ($totalLines -gt 20) {
        Write-Host "  ... ($totalLines total lines — read the full file to continue)"
    }
    Write-Host "=== END SESSION STATE PREVIEW ==="
} else {
    # Bootstrap a fresh active.md template
    $now = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    $curBranch = if ($branch) { $branch } else { "main" }
    $template = @"
---
session: init
branch: $curBranch
tags: []
started: $now
lastActive: $now
---

# Active Session State

> Live checkpoint for the current Claude Code session. The **file is the memory,
> not the conversation**. Append a new ``<!-- STATUS -->`` block at the end on
> every milestone or compaction; the last block wins.

## Current Task

_No active task — waiting for user direction._

## Progress Checklist

- [ ] _Fill in as work begins_

## Key Decisions Made

_None yet._

## Files This Session

| File | Action | Timestamp |
|---|---|---|
| _(none)_ | _(none)_ | _(none)_ |

## Partial Reads This Session

_None._

## Cached Decisions (may be stale)

_None._

## Subagent Log

| Timestamp | Agent | Task | Outcome |
|---|---|---|---|
| _(none)_ | _(none)_ | _(none)_ | _(none)_ |

## Open Questions / Blockers

_None._

---

<!-- STATUS: $now | Task: session initialized -->
Fresh session-state bootstrap by session-start.ps1. No work in progress.
<!-- /STATUS -->
"@
    Set-Content -Path $stateFile -Value $template -Encoding UTF8 2>$null
    Write-Host ""
    Write-Host "=== ACTIVE SESSION STATE BOOTSTRAPPED ==="
    Write-Host "Created fresh $stateFile (no prior session detected)."
    Write-Host "=== END STATE BOOTSTRAP ==="
}

# --- GitNexus indexed repos ---
$npxPath = Get-Command npx -ErrorAction SilentlyContinue
if ($npxPath) {
    $gnList = npx --no gitnexus list 2>$null
    if ($gnList) {
        Write-Host ""
        Write-Host "GitNexus indexed repos:"
        $gnList | ForEach-Object { Write-Host "  $_" }
        Write-Host "  (run 'npx gitnexus status' to check freshness)"
    }
}

Write-Host "==================================="
exit 0