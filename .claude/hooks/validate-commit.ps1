# Claude Code PreToolUse hook: Validates git commit commands (PowerShell)
# Synced with validate-commit.sh features: frontmatter, BDD, ruff, GitNexus.
#
# Exit 0 = allow, Exit 2 = block
# Input: JSON on stdin { "tool_name": "Bash", "tool_input": { "command": "..." } }

$ErrorActionPreference = 'Continue'

$jsonInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhitespace($jsonInput)) { exit 0 }

try {
    $data = $jsonInput | ConvertFrom-Json
}
catch {
    exit 0
}

# Only process git commit commands
$command = $data.tool_input.command
if ($command -notmatch '^git\s+commit') { exit 0 }

# Get staged files
$staged = git diff --cached --name-only 2>$null
if ([string]::IsNullOrWhitespace($staged)) { exit 0 }

$stagedFiles = $staged -split "`n" | Where-Object { $_ }
$warnings = @()

# Helper: check if file starts with YAML frontmatter
function Test-Frontmatter {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) { return $false }
    $lines = Get-Content $FilePath -TotalCount 2 2>$null
    if ($lines.Count -lt 2) { return $false }
    return ($lines[0].Trim() -eq "---")
}

# Helper: extract YAML frontmatter body (between first and second ---)
function Get-FrontmatterBody {
    param([string]$FilePath)
    $content = Get-Content $FilePath 2>$null
    $inFront = $false
    $body = @()
    foreach ($line in $content) {
        if ($line.Trim() -eq "---") {
            if ($inFront) { break }
            $inFront = $true
            continue
        }
        if ($inFront) { $body += $line }
    }
    return ($body -join "`n")
}

# ─── Check design documents for required sections + frontmatter + BDD ─────────
$designFiles = $stagedFiles | Where-Object { $_ -match '^design/specs/' }
if ($designFiles) {
    foreach ($file in $designFiles) {
        if ($file -match '\.md$' -and (Test-Path $file)) {
            # YAML frontmatter check
            if (-not (Test-Frontmatter $file)) {
                [Console]::Error.WriteLine("BLOCKED: $file missing YAML frontmatter. Add frontmatter with stage, tier, spec_id before commit.")
                exit 2
            }

            # Required frontmatter fields
            $fmBody = Get-FrontmatterBody $file
            foreach ($key in @('stage', 'tier', 'spec_id')) {
                if ($fmBody -notmatch "(?i)^\s*${key}\s*:\s*.+") {
                    [Console]::Error.WriteLine("BLOCKED: $file frontmatter missing required field '$key'.")
                    exit 2
                }
            }

            # BDD keyword validation
            $content = Get-Content $file -Raw 2>$null
            foreach ($bdd in @('Given', 'When', 'Then')) {
                if ($content -notmatch "(?m)^\s*[-*]?\s*${bdd}\b") {
                    [Console]::Error.WriteLine("BLOCKED: $file missing BDD keyword '$bdd' in acceptance criteria.")
                    exit 2
                }
            }

            # Required sections (warning only)
            $requiredSections = @("Overview", "User Value", "Detailed", "Formulas", "Edge Cases", "Dependencies", "Configuration", "Acceptance Criteria")
            foreach ($section in $requiredSections) {
                if ($content -notmatch "(?i)$section") {
                    $warnings += "DESIGN: $file missing required section: $section"
                }
            }
        }
    }
}

# ─── Validate JSON data files ────────────────────────────────────────────────
$dataFiles = $stagedFiles | Where-Object { $_ -match '^assets/data/.*\.json$' }
if ($dataFiles) {
    foreach ($file in $dataFiles) {
        if (Test-Path $file) {
            try {
                Get-Content $file -Raw | ConvertFrom-Json | Out-Null
            }
            catch {
                [Console]::Error.WriteLine("BLOCKED: $file is not valid JSON")
                exit 2
            }
        }
    }
}

# ─── Check for hardcoded magic numbers ──────────────────────────────────────
$codeFiles = $stagedFiles | Where-Object { $_ -match '^src/' }
if ($codeFiles) {
    foreach ($file in $codeFiles) {
        if (Test-Path $file) {
            $magicMatch = Select-String -Path $file -Pattern '[[:space:]]=[[:space:]]*[0-9]{4,}' 2>$null
            if ($magicMatch) {
                $warnings += "CODE: $file may contain hardcoded magic numbers. Use config files."
            }
        }
    }
}

# ─── TODO/FIXME without owner tag ────────────────────────────────────────────
if ($codeFiles) {
    foreach ($file in $codeFiles) {
        if (Test-Path $file) {
            $todoMatch = Select-String -Path $file -Pattern '(TODO|FIXME|HACK)[^(]' 2>$null
            if ($todoMatch) {
                $warnings += "STYLE: $file has TODO/FIXME without owner tag. Use TODO(name) format."
            }
        }
    }
}

# ─── Auto-lint: ruff check on staged Python files ───────────────────────────
$pyFiles = $stagedFiles | Where-Object { $_ -match '\.py$' }
if ($pyFiles) {
    $ruffAvailable = $false
    $ruffCmd = $null

    if (Get-Command ruff -ErrorAction SilentlyContinue) {
        $ruffAvailable = $true
        $ruffCmd = "ruff"
    } else {
        # Try via python module
        foreach ($cmd in @('python', 'python3', 'py')) {
            $testResult = & $cmd -m ruff --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                $ruffAvailable = $true
                $ruffCmd = "$cmd -m ruff"
                break
            }
        }
    }

    if ($ruffAvailable) {
        $lintOutput = @()
        foreach ($pyfile in $pyFiles) {
            if (Test-Path $pyfile) {
                if ($ruffCmd -eq "ruff") {
                    $result = ruff check $pyfile 2>&1 | Out-String
                } else {
                    $parts = $ruffCmd -split ' '
                    $result = & $parts[0] $parts[1] check $pyfile 2>&1 | Out-String
                }
                if ($result.Trim()) {
                    $lines = ($result -split "`n") | Select-Object -First 5 | ForEach-Object { "    $_" }
                    $lintOutput += "  ${pyfile}:`n" + ($lines -join "`n")
                }
            }
        }
        if ($lintOutput.Count -gt 0) {
            $warnings += "LINT: ruff found issues in staged Python files:`n" + ($lintOutput -join "`n")
        }
    }
}

# ─── Print warnings (non-blocking) ──────────────────────────────────────────
if ($warnings.Count -gt 0) {
    [Console]::Error.WriteLine("=== Commit Validation Warnings ===")
    $warnings | ForEach-Object { [Console]::Error.WriteLine($_) }
    [Console]::Error.WriteLine("================================")
}

# ─── GitNexus: pre-commit blast-radius check ────────────────────────────────
$npxPath = Get-Command npx -ErrorAction SilentlyContinue
if ($npxPath) {
    $gnStatus = npx --no gitnexus status 2>$null | Select-String -Pattern '(?i)(indexed|up.to.date)' | Select-Object -First 1
    if ($gnStatus) {
        $blast = npx --no gitnexus detect-changes --scope staged --format json 2>$null | Out-String
        if ($blast.Trim()) {
            $riskMatch = [regex]::Match($blast, '"risk"\s*:\s*"([^"]*)"')
            $procsMatch = [regex]::Match($blast, '"affectedProcessCount"\s*:\s*(\d+)')
            if ($riskMatch.Success) {
                $risk = $riskMatch.Groups[1].Value
                [Console]::Error.WriteLine("")
                [Console]::Error.WriteLine("=== GitNexus Blast Radius ===")
                [Console]::Error.WriteLine("Risk level : $risk")
                if ($procsMatch.Success) {
                    [Console]::Error.WriteLine("Affected flows: $($procsMatch.Groups[1].Value)")
                }
                if ($risk -match '^(HIGH|CRITICAL)$') {
                    [Console]::Error.WriteLine("WARNING: $risk risk — run /gitnexus-impact-analysis before merging.")
                }
                [Console]::Error.WriteLine("=============================")
            }
        }
    }
}

exit 0