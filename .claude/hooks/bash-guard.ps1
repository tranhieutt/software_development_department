# Claude Code PreToolUse hook: Bash Guard (PowerShell)
# Blocks dangerous commands not covered by settings.json deny list.

# Capture stdin as JSON string
$jsonInput = @($input) | Out-String
if ([string]::IsNullOrWhitespace($jsonInput)) { exit 0 }

try {
    $data = $jsonInput | ConvertFrom-Json
}
catch {
    # Fallback if not valid JSON
    exit 0
}

# Only process Bash tool
if ($data.tool_name -ne "Bash") { exit 0 }

$command = $data.tool_input.command
if ([string]::IsNullOrWhitespace($command)) { exit 0 }

function Block-IfMatch($pattern, $reason) {
    if ($command -match $pattern) {
        Write-Error "[HOOK:BashGuard] BLOCKED: $reason"
        Write-Error "[HOOK:BashGuard] Command: $command"
        exit 2
    }
}

# --- HARD BLOCKS ---

# Fork bomb variants
Block-IfMatch ':\s*\(\s*\)\s*\{' "Fork bomb pattern detected: :(){ :|:& };:"

# rm -rf variants (Hard blocks for root/all patterns)
Block-IfMatch 'rm\s+(-r\s*-f|-f\s*-r|-rf|-fr)\s+/' "rm -rf on root is forbidden"
Block-IfMatch 'rm\s+(-r\s*-f|-f\s*-r|-rf|-fr)\s+\*' "rm -rf on all files (*) is forbidden via BashGuard"

# tee .env overwrites
Block-IfMatch 'tee\s+.*\.env' "Overwriting .env files via tee is forbidden"
Block-IfMatch '>\s*\.env' "Direct redirection to .env is forbidden"

# Disk formatting
Block-IfMatch 'mkfs\.' "Disk formatting is forbidden (mkfs.*)"

# Direct disk write
Block-IfMatch '>\s*/dev/sd[a-z]' "Direct disk write is forbidden (> /dev/sdX)"
Block-IfMatch 'dd\s+if=/dev/zero' "Disk wipe is forbidden (dd if=/dev/zero)"
Block-IfMatch 'dd\s+if=/dev/random' "Disk overwrite is forbidden (dd if=/dev/random)"

# Crontab wipe
Block-IfMatch 'crontab\s+-r' "Deleting all cron jobs is forbidden (crontab -r)"

# PyPI publish accidental
Block-IfMatch '^twine\s+upload' "PyPI publish requires explicit user confirmation"

# --- SOFT WARNINGS ---
$warnings = @()

function Warn-IfMatch($pattern, $msg) {
    if ($command -match $pattern) {
        $script:warnings += "  [WARN] $msg"
    }
}

Warn-IfMatch 'DROP\s+TABLE' "SQL DROP TABLE detected — verify this is intentional"
Warn-IfMatch 'DELETE\s+FROM' "SQL DELETE FROM detected — ensure WHERE clause is correct"
Warn-IfMatch 'TRUNCATE\s+(TABLE\s+)?' "SQL TRUNCATE detected — this permanently removes all rows"
Warn-IfMatch 'git\s+reset\s+--hard' "git reset --hard discards uncommitted changes permanently"
Warn-IfMatch 'git\s+clean\s+-fd?' "git clean -f removes untracked files permanently"
Warn-IfMatch 'docker\s+volume\s+rm' "docker volume rm deletes persistent data"
Warn-IfMatch 'DROP\s+DATABASE' "SQL DROP DATABASE detected — this destroys the entire database"

if ($warnings.Count -gt 0) {
    Write-Host "[HOOK:BashGuard] Warnings for command review:"
    $warnings | ForEach-Object { Write-Host $_ }
}

exit 0
