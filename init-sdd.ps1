param(
    [Parameter(Mandatory = $false, HelpMessage = "Path to the new project directory")]
    [string]$Path
)

$ErrorActionPreference = "Stop"

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

$SourceFiles = @(
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
    "docs",
    "scripts"
)

Write-Host ""
Write-Host "Initializing SDD Architectural Framework..." -ForegroundColor Cyan

foreach ($item in $SourceFiles) {
    $SourcePath = Join-Path $SddRoot $item
    if (Test-Path -LiteralPath $SourcePath) {
        Write-Host " -> Copying: $item" -ForegroundColor Gray
        Copy-Item -LiteralPath $SourcePath -Destination $Path -Recurse -Force
    } else {
        Write-Host " -> Skipping missing source: $item" -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "SDD Environment successfully initialized at: $Path" -ForegroundColor Green
Write-Host "--------------------------------------------------------"
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host " 1. Move to the project: cd '$Path'"
Write-Host " 2. Open with your IDE: code ."
Write-Host " 3. For Claude Code, read CLAUDE.md then run /start."
Write-Host " 4. For Codex, start with AGENTS.md and .codex/START.md."
Write-Host "--------------------------------------------------------"
