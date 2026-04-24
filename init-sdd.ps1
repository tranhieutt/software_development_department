param(
    [Parameter(Mandatory = $false, HelpMessage = "Path to the new project directory")]
    [string]$Path,

    [Parameter(Mandatory = $false, HelpMessage = "Copy onboarding/reference/archive docs in addition to core SDD docs")]
    [switch]$IncludeReferenceDocs,

    [Parameter(Mandatory = $false, HelpMessage = "Copy the SDD harness test suite instead of scaffolding an empty tests directory")]
    [switch]$IncludeHarnessTests
)

$ErrorActionPreference = "Stop"

function Copy-SddItem {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,
        [Parameter(Mandatory = $true)]
        [string]$DestinationRoot,
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $SourcePath = Join-Path $SourceRoot $RelativePath
    if (-not (Test-Path -LiteralPath $SourcePath)) {
        Write-Host " -> Skipping missing source: $RelativePath" -ForegroundColor DarkYellow
        return
    }

    $DestinationPath = Join-Path $DestinationRoot $RelativePath
    $DestinationParent = Split-Path -Parent $DestinationPath
    if ($DestinationParent -and -not (Test-Path -LiteralPath $DestinationParent)) {
        New-Item -ItemType Directory -Path $DestinationParent -Force | Out-Null
    }

    Write-Host " -> Copying: $RelativePath" -ForegroundColor Gray
    Copy-Item -LiteralPath $SourcePath -Destination $DestinationParent -Recurse -Force
}

if (-not $Path) {
    Write-Host "--- SDD PROJECT INITIALIZER ---" -ForegroundColor Blue
    $Path = Read-Host "Enter the path for the new project (e.g., D:\MyNewApp)"
}

if (-not $Path) {
    Write-Host "Error: No path provided." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Host "Creating directory: $Path..." -ForegroundColor Gray
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

$SddRoot = $PSScriptRoot
if (-not $SddRoot) {
    $SddRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$SourceItems = @(
    ".claude",
    ".codex",
    ".tasks",
    ".gitignore",
    ".mcp.json",
    "AGENTS.md",
    "CLAUDE.md",
    "PRD.md",
    "README.md",
    "README_vn.md",
    "TODO.md",
    "scripts"
)

$CoreDocItems = @(
    "docs\codex-compatibility.md",
    "docs\technical",
    "docs\internal\adr"
)

$ReferenceDocItems = @(
    "docs\archived",
    "docs\hooks_visual_report.html",
    "docs\internal\CHANGELOG.md",
    "docs\internal\hooks-system-report.md",
    "docs\internal\portal-data.js",
    "docs\internal\requests",
    "docs\onboarding",
    "docs\reference"
)

$HarnessTestItems = @(
    "tests"
)

$ScaffoldTestItems = @(
    "tests\.gitkeep"
)

if ($IncludeReferenceDocs) {
    $SourceItems += $CoreDocItems + $ReferenceDocItems
} else {
    $SourceItems += $CoreDocItems
}

if ($IncludeHarnessTests) {
    $SourceItems += $HarnessTestItems
} else {
    $SourceItems += $ScaffoldTestItems
}

Write-Host ""
Write-Host "Initializing SDD Architectural Framework..." -ForegroundColor Cyan
if (-not $IncludeReferenceDocs) {
    Write-Host "Using core docs only. Add -IncludeReferenceDocs to copy onboarding/reference/archive docs as well." -ForegroundColor DarkYellow
}
if (-not $IncludeHarnessTests) {
    Write-Host "Scaffolding tests/.gitkeep only. Add -IncludeHarnessTests to copy the SDD harness test suite." -ForegroundColor DarkYellow
}

foreach ($item in $SourceItems) {
    Copy-SddItem -SourceRoot $SddRoot -DestinationRoot $Path -RelativePath $item
}

Write-Host ""
Write-Host "SDD Environment successfully initialized at: $Path" -ForegroundColor Green
Write-Host "--------------------------------------------------------"
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host " 1. Move to the project: cd '$Path'"
Write-Host " 2. Open with your IDE: code ."
Write-Host " 3. For Claude Code, read CLAUDE.md then run /start."
Write-Host " 4. For Codex, start with AGENTS.md and .codex/START.md."
if (-not $IncludeReferenceDocs) {
    Write-Host " 5. Re-run with -IncludeReferenceDocs if you want onboarding/reference/archive docs too."
}
if (-not $IncludeHarnessTests) {
    Write-Host " 6. Re-run with -IncludeHarnessTests if you want the SDD harness tests too."
}
Write-Host "--------------------------------------------------------"
