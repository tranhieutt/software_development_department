# Claude Code PreToolUse hook: Bash Guard (PowerShell)
# Blocks dangerous commands not covered by settings.json deny list.
#
# Exit 0 = allow, Exit 2 = block
# Input: JSON on stdin { "tool_name": "Bash", "tool_input": { "command": "..." } }

$jsonInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($jsonInput)) { exit 0 }

try {
    $data = $jsonInput | ConvertFrom-Json
}
catch {
    exit 0
}

if ($data.tool_name -ne "Bash") { exit 0 }

$command = $data.tool_input.command
if ([string]::IsNullOrWhiteSpace($command)) { exit 0 }

function Block-IfMatch {
    param(
        [string]$pattern,
        [string]$reason
    )

    if ($command -match $pattern) {
        Write-Error "[HOOK:BashGuard] BLOCKED: $reason"
        Write-Error "[HOOK:BashGuard] Command: $command"
        exit 2
    }
}

# Hard blocks
Block-IfMatch ':\s*\(\s*\)\s*\{' "Fork bomb pattern detected: :(){ :|:& };:"

Block-IfMatch 'rm\s+(-r\s*-f|-f\s*-r|-rf|-fr)\s+/' "rm -rf on root is forbidden"
Block-IfMatch 'rm\s+(-r\s*-f|-f\s*-r|-rf|-fr)\s+\*' "rm -rf on all files (*) is forbidden via BashGuard"
Block-IfMatch 'rm\s+(-r\s*-f|-f\s*-r|-rf|-fr)\s+\.(\/|$)' "rm -rf on current directory (./ or .) is forbidden"

Block-IfMatch 'tee\s+.*\.env' "Overwriting .env files via tee is forbidden"
Block-IfMatch '>\s*\.env' "Direct redirection to .env is forbidden"

Block-IfMatch 'mkfs\.' "Disk formatting is forbidden (mkfs.*)"
Block-IfMatch '>\s*/dev/sd[a-z]' "Direct disk write is forbidden (> /dev/sdX)"
Block-IfMatch 'dd\s+if=/dev/zero' "Disk wipe is forbidden (dd if=/dev/zero)"
Block-IfMatch 'dd\s+if=/dev/random' "Disk overwrite is forbidden (dd if=/dev/random)"

Block-IfMatch 'crontab\s+-r' "Deleting all cron jobs is forbidden (crontab -r)"
Block-IfMatch '^twine\s+upload' "PyPI publish requires explicit user confirmation"

# Soft warnings
$warnings = @()

function Add-GuardWarning {
    param(
        [string]$pattern,
        [string]$message
    )

    if ($command -match $pattern) {
        $script:warnings += "  [WARN] $message"
    }
}

Add-GuardWarning 'DROP\s+TABLE' "SQL DROP TABLE detected - verify this is intentional"
Add-GuardWarning 'DELETE\s+FROM' "SQL DELETE FROM detected - ensure WHERE clause is correct"
Add-GuardWarning 'TRUNCATE\s+(TABLE\s+)?' "SQL TRUNCATE detected - this permanently removes all rows"
Add-GuardWarning 'git\s+reset\s+--hard' "git reset --hard discards uncommitted changes permanently"
Add-GuardWarning 'git\s+clean\s+-fd?' "git clean -f removes untracked files permanently"
Add-GuardWarning 'docker\s+volume\s+rm' "docker volume rm deletes persistent data"
Add-GuardWarning 'DROP\s+DATABASE' "SQL DROP DATABASE detected - this destroys the entire database"

if ($warnings.Count -gt 0) {
    Write-Host "[HOOK:BashGuard] Warnings for command review:"
    $warnings | ForEach-Object { Write-Host $_ }
}

exit 0
