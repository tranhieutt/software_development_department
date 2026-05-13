param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Path to the product project directory")]
    [string]$Path,

    [Parameter(Mandatory = $false, HelpMessage = "Install SddDev mode instead of Product mode")]
    [switch]$SddDev,

    [Parameter(Mandatory = $false, HelpMessage = "Copy onboarding/reference/archive docs too")]
    [switch]$IncludeReferenceDocs,

    [Parameter(Mandatory = $false, HelpMessage = "Copy the SDD harness test suite")]
    [switch]$IncludeHarnessTests,

    [Parameter(Mandatory = $false, HelpMessage = "Skip codex preflight after install")]
    [switch]$SkipPreflight
)

$ErrorActionPreference = "Stop"

$SddRoot = $PSScriptRoot
if (-not $SddRoot) {
    $SddRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$InstallMode = if ($SddDev) { "SddDev" } else { "Product" }
$InitScript = Join-Path $SddRoot "init-sdd.ps1"

if (-not (Test-Path -LiteralPath $InitScript)) {
    throw "Cannot find init-sdd.ps1 next to install-sdd.ps1. Run this script from the SDD repository."
}

$InitArgs = @(
    "-Path", $Path,
    "-InstallMode", $InstallMode
)

if ($IncludeReferenceDocs) {
    $InitArgs += "-IncludeReferenceDocs"
}

if ($IncludeHarnessTests) {
    $InitArgs += "-IncludeHarnessTests"
}

Write-Host "Installing SDD harness..." -ForegroundColor Cyan
Write-Host "Source: $SddRoot" -ForegroundColor Gray
Write-Host "Target: $Path" -ForegroundColor Gray
Write-Host "Mode:   $InstallMode" -ForegroundColor Gray
Write-Host ""

& powershell -NoProfile -ExecutionPolicy Bypass -File $InitScript @InitArgs
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

if ($SkipPreflight) {
    Write-Host ""
    Write-Host "Skipped preflight." -ForegroundColor DarkYellow
    exit 0
}

$ResolvedPath = (Resolve-Path -LiteralPath $Path).Path
$PreflightScript = Join-Path $ResolvedPath "scripts\codex-preflight.ps1"

if (-not (Test-Path -LiteralPath $PreflightScript)) {
    Write-Host ""
    Write-Host "Preflight script not found at target. Install completed, but validation was skipped." -ForegroundColor DarkYellow
    exit 0
}

Write-Host ""
Write-Host "Running $InstallMode preflight..." -ForegroundColor Cyan
Push-Location $ResolvedPath
try {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $PreflightScript -InstallMode $InstallMode
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
