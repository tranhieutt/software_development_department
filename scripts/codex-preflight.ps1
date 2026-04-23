param(
    [switch]$SkipSkillValidation,
    [switch]$SkipHarnessAudit,
    [switch]$SkipTraceCheck
)

$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "== $Title =="
}

function Add-Failure {
    param([string]$Message)
    $script:Failures += $Message
    Write-Host "FAIL  $Message" -ForegroundColor Red
}

function Add-Warning {
    param([string]$Message)
    $script:Warnings += $Message
    Write-Host "WARN  $Message" -ForegroundColor Yellow
}

function Add-Ok {
    param([string]$Message)
    Write-Host "OK    $Message" -ForegroundColor Green
}

function Invoke-Checked {
    param(
        [string]$Label,
        [string]$Command,
        [string[]]$Arguments
    )

    Write-Host ""
    Write-Host "> $Command $($Arguments -join ' ')"
    & $Command @Arguments
    $exit = $LASTEXITCODE
    if ($exit -ne 0) {
        Add-Failure "$Label failed with exit code $exit"
    } else {
        Add-Ok "$Label passed"
    }
}

$Failures = @()
$Warnings = @()

Write-Host "SDD Codex Preflight"
Write-Host "Root: $(Get-Location)"

Write-Section "Required Files"
$required = @(
    "AGENTS.md",
    "CLAUDE.md",
    ".codex/INSTALL.md",
    "docs/codex-compatibility.md",
    "docs/technical/SDD_LIFECYCLE_MAP.md",
    ".claude/settings.json",
    ".claude/skills/using-sdd/SKILL.md",
    ".claude/skills/codex-sdd/SKILL.md",
    "scripts/validate-skills.ps1",
    "scripts/harness-audit.js"
)

foreach ($path in $required) {
    if (Test-Path $path) {
        Add-Ok "found $path"
    } else {
        Add-Failure "missing $path"
    }
}

Write-Section "Git Status"
try {
    $gitStatus = git status --short
    if ($LASTEXITCODE -ne 0) {
        Add-Warning "git status returned exit code $LASTEXITCODE"
    } elseif ($gitStatus) {
        Add-Warning "working tree has uncommitted changes"
        $gitStatus | ForEach-Object { Write-Host "      $_" }
    } else {
        Add-Ok "working tree clean"
    }
} catch {
    Add-Warning "git status unavailable: $($_.Exception.Message)"
}

Write-Section "Circuit State"
$circuitPath = ".claude/memory/circuit-state.json"
if (Test-Path $circuitPath) {
    try {
        $circuit = Get-Content $circuitPath -Raw | ConvertFrom-Json
        if ($circuit._version -eq 2 -and $null -ne $circuit.agents) {
            Add-Ok "circuit-state.json schema v2 readable"
        } else {
            Add-Failure "circuit-state.json does not match schema v2"
        }
    } catch {
        Add-Failure "circuit-state.json parse failed: $($_.Exception.Message)"
    }
} else {
    Add-Failure "missing $circuitPath"
}

if (-not $SkipSkillValidation) {
    Write-Section "Skill Validation"
    Invoke-Checked "skill validation" "powershell" @("-ExecutionPolicy", "Bypass", "-File", "scripts\validate-skills.ps1")
}

if (-not $SkipHarnessAudit) {
    Write-Section "Harness Audit"
    Invoke-Checked "harness audit" "node" @("scripts\harness-audit.js", "--compact")
}

if (-not $SkipTraceCheck) {
    Write-Section "Trace Integrity"
    if (Test-Path "scripts/trace-integrity-check.js") {
        Invoke-Checked "trace integrity" "node" @("scripts\trace-integrity-check.js")
    } else {
        Add-Warning "trace integrity script not found"
    }
}

Write-Section "Summary"
Write-Host "Failures: $($Failures.Count)"
Write-Host "Warnings: $($Warnings.Count)"

if ($Failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Preflight failed. Fix failures before claiming Codex/SDD readiness." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Preflight passed. Review warnings before risky edits or completion claims." -ForegroundColor Green
exit 0
