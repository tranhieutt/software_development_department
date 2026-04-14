param(
    [Parameter(Mandatory=$false, HelpMessage="Path to the new project directory")]
    [string]$Path
)

# 1. Input Validation
if (-not $Path) {
    Write-Host "--- SDD PROJECT INITIALIZER ---" -ForegroundColor Blue
    $Path = Read-Host "Enter the path for the new project (e.g., D:\MyNewApp)"
}

if (-not $Path) {
    Write-Host "Error: No path provided." -ForegroundColor Red
    exit
}

# 2. Create directory if it doesn't exist
if (-not (Test-Path $Path)) {
    Write-Host "Creating directory: $Path..." -ForegroundColor Gray
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

$SddRoot = Get-Location
$SourceFiles = @(".claude", "CLAUDE.md", "PRD.md", "TODO.md", ".tasks", ".gitignore", "HUONG_DAN_NHANH.md", "DANH_SACH_LENH.md", "docs", "scripts")

# 3. Copy core files
Write-Host ""
Write-Host "🚀 Initializing SDD Architectural Framework..." -ForegroundColor Cyan

foreach ($item in $SourceFiles) {
    $SourcePath = Join-Path $SddRoot $item
    if (Test-Path $SourcePath) {
        Write-Host " -> Copying: $item" -ForegroundColor Gray
        Copy-Item -Path $SourcePath -Destination $Path -Recurse -Force
    }
}

# 4. Completion Message
Write-Host ""
Write-Host "✅ SDD Environment successfully initialized at: $Path" -ForegroundColor Green
Write-Host "--------------------------------------------------------"
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host " 1. Move to the project: cd '$Path'"
Write-Host " 2. Open with your IDE: code ."
Write-Host " 3. Launch Claude Code in the terminal"
Write-Host " 4. Type command: /start to begin!" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------"
