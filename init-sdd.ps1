param(
    [Parameter(Mandatory = $false, HelpMessage = "Path to the new project directory")]
    [string]$Path,

    [Parameter(Mandatory = $false, HelpMessage = "Install mode: Product preserves product identity; SddDev copies full SDD repo docs")]
    [ValidateSet("Product", "SddDev")]
    [string]$InstallMode = "Product",

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

function Copy-SddItemIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,
        [Parameter(Mandatory = $true)]
        [string]$DestinationRoot,
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $DestinationPath = Join-Path $DestinationRoot $RelativePath
    if (Test-Path -LiteralPath $DestinationPath) {
        Write-Host " -> Preserving existing: $RelativePath" -ForegroundColor DarkYellow
        return
    }

    Copy-SddItem -SourceRoot $SourceRoot -DestinationRoot $DestinationRoot -RelativePath $RelativePath
}

function New-ProductStubIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DestinationRoot,
        [Parameter(Mandatory = $true)]
        [string]$RelativePath,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Lines
    )

    $DestinationPath = Join-Path $DestinationRoot $RelativePath
    if (Test-Path -LiteralPath $DestinationPath) {
        Write-Host " -> Preserving existing product doc: $RelativePath" -ForegroundColor DarkYellow
        return
    }

    $DestinationParent = Split-Path -Parent $DestinationPath
    if ($DestinationParent -and -not (Test-Path -LiteralPath $DestinationParent)) {
        New-Item -ItemType Directory -Path $DestinationParent -Force | Out-Null
    }

    Write-Host " -> Creating product stub: $RelativePath" -ForegroundColor Gray
    Set-Content -LiteralPath $DestinationPath -Value $Lines -Encoding UTF8
}

function Write-InstallMarker {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DestinationRoot,
        [Parameter(Mandatory = $true)]
        [string]$Mode
    )

    $MarkerDir = Join-Path $DestinationRoot ".sdd"
    if (-not (Test-Path -LiteralPath $MarkerDir)) {
        New-Item -ItemType Directory -Path $MarkerDir -Force | Out-Null
    }

    $Marker = [ordered]@{
        installMode = $Mode
        installedAt = (Get-Date).ToUniversalTime().ToString("o")
        source = "SDD"
    }
    $Marker | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $MarkerDir "install.json") -Encoding UTF8
    Write-Host " -> Wrote install marker: .sdd\install.json" -ForegroundColor Gray
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
    ".mcp.json",
    "AGENTS.md",
    "CLAUDE.md"
)

$ProductScriptItems = @(
    "scripts\codex-preflight.ps1",
    "scripts\codex-preflight.sh",
    "scripts\codex-safety-check.py",
    "scripts\harness-audit.js",
    "scripts\ledger-append.sh",
    "scripts\trace-history.sh",
    "scripts\trace-integrity-check.js",
    "scripts\validate-skills.ps1",
    "scripts\validate-skills.sh"
)

$SddDevRootItems = @(
    ".gitignore",
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

$ProductDocItems = @(
    "docs\codex-compatibility.md",
    "docs\technical\SDD_LIFECYCLE_MAP.md"
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

if ($IncludeHarnessTests) {
    $SourceItems += $HarnessTestItems
} else {
    $SourceItems += $ScaffoldTestItems
}

Write-Host ""
Write-Host "Initializing SDD Architectural Framework..." -ForegroundColor Cyan
Write-Host "Install mode: $InstallMode" -ForegroundColor Cyan
if ($InstallMode -eq "Product") {
    Write-Host "Product mode preserves README.md, PRD.md, TODO.md, and .gitignore when they already exist." -ForegroundColor DarkYellow
}
if ($InstallMode -eq "SddDev" -and -not $IncludeReferenceDocs) {
    Write-Host "Using core docs only. Add -IncludeReferenceDocs to copy onboarding/reference/archive docs as well." -ForegroundColor DarkYellow
}
if (-not $IncludeHarnessTests) {
    Write-Host "Scaffolding tests/.gitkeep only. Add -IncludeHarnessTests to copy the SDD harness test suite." -ForegroundColor DarkYellow
}

foreach ($item in $SourceItems) {
    Copy-SddItem -SourceRoot $SddRoot -DestinationRoot $Path -RelativePath $item
}

if ($InstallMode -eq "Product") {
    foreach ($item in $ProductScriptItems + $ProductDocItems) {
        Copy-SddItem -SourceRoot $SddRoot -DestinationRoot $Path -RelativePath $item
    }

    Copy-SddItemIfMissing -SourceRoot $SddRoot -DestinationRoot $Path -RelativePath ".gitignore"

    New-ProductStubIfMissing -DestinationRoot $Path -RelativePath "README.md" -Lines @(
        "# Project README",
        "",
        "This project uses the SDD harness for agent-assisted development.",
        "",
        "Replace this stub with product-specific setup, architecture, and operating notes."
    )
    New-ProductStubIfMissing -DestinationRoot $Path -RelativePath "PRD.md" -Lines @(
        "# Product Requirements",
        "",
        "This file is the human-approved source of truth for product scope.",
        "",
        "## Overview",
        "",
        "Describe the product outcome here.",
        "",
        "## Acceptance Criteria",
        "",
        "- [ ] Define product-specific acceptance criteria."
    )
    New-ProductStubIfMissing -DestinationRoot $Path -RelativePath "TODO.md" -Lines @(
        "# Backlog",
        "",
        "Track product work here. Keep items tied to PRD requirements and `.tasks/` detail files when work becomes active.",
        "",
        "## Up Next",
        "",
        "- [ ] Define first product task."
    )
} else {
    $DevItems = $SddDevRootItems + $CoreDocItems
    if ($IncludeReferenceDocs) {
        $DevItems += $ReferenceDocItems
    }

    foreach ($item in $DevItems) {
        Copy-SddItem -SourceRoot $SddRoot -DestinationRoot $Path -RelativePath $item
    }
}

Write-InstallMarker -DestinationRoot $Path -Mode $InstallMode

Write-Host ""
Write-Host "SDD Environment successfully initialized at: $Path" -ForegroundColor Green
Write-Host "--------------------------------------------------------"
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host " 1. Move to the project: cd '$Path'"
Write-Host " 2. Open with your IDE: code ."
Write-Host " 3. For Claude Code, read CLAUDE.md then run /start."
Write-Host " 4. For Codex, start with AGENTS.md and .codex/START.md."
if ($InstallMode -eq "Product") {
    Write-Host " 5. Replace README.md, PRD.md, and TODO.md stubs with product-specific content."
}
if ($InstallMode -eq "SddDev" -and -not $IncludeReferenceDocs) {
    Write-Host " 5. Re-run with -IncludeReferenceDocs if you want onboarding/reference/archive docs too."
}
if (-not $IncludeHarnessTests) {
    Write-Host " 6. Re-run with -IncludeHarnessTests if you want the SDD harness tests too."
}
Write-Host "--------------------------------------------------------"
