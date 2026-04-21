# Claude Code PreToolUse hook: Validates git push commands (PowerShell)
# Warns on pushes to protected branches, blocks if secrets detected in staged diff.
# Exit 0 = allow, Exit 2 = block
#
# Input: JSON on stdin { "tool_name": "Bash", "tool_input": { "command": "..." } }

$jsonInput = @($input) | Out-String
if ([string]::IsNullOrWhitespace($jsonInput)) { exit 0 }

try { $data = $jsonInput | ConvertFrom-Json } catch { exit 0 }

$command = $data.tool_input.command
if ([string]::IsNullOrWhitespace($command)) { exit 0 }
if ($command -notmatch '^\s*git\s+push') { exit 0 }

# ─── Protected branch warning ────────────────────────────────────────────────
$currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
$protectedBranches = @('main', 'master', 'develop')
$matchedBranch = $null

foreach ($branch in $protectedBranches) {
    if ($currentBranch -eq $branch -or $command -match "\s$branch(\s|$)") {
        $matchedBranch = $branch
        break
    }
}

if ($matchedBranch) {
    Write-Host "[HOOK:ValidatePush] Push to protected branch '$matchedBranch' detected."
    Write-Host "[HOOK:ValidatePush] Reminder: Ensure build passes, tests pass, and no S1/S2 bugs exist."
}

# ─── Secret scan ─────────────────────────────────────────────────────────────
$secretPatterns = @(
    'ANTHROPIC_API_KEY\s*=\s*sk-ant-[A-Za-z0-9]',
    'OPENAI_API_KEY\s*=\s*sk-[A-Za-z0-9]',
    'sk-ant-[A-Za-z0-9\-]{20,}',
    'sk-[A-Za-z0-9]{48}',
    'ghp_[A-Za-z0-9]{36}',
    'github_pat_[A-Za-z0-9_]{80,}',
    'xox[baprs]-[A-Za-z0-9\-]{10,}',
    '-----BEGIN (RSA|EC|OPENSSH|PGP) PRIVATE KEY',
    'password\s*=\s*["''][^"'']{8,}["'']',
    'secret\s*=\s*["''][^"'']{8,}["'']',
    'DATABASE_URL\s*=\s*postgresql://[^:]+:[^@]+@',
    'AWS_ACCESS_KEY_ID\s*=\s*(AKIA|ASIA)[0-9A-Z]{16}',
    '(AKIA|ASIA)[0-9A-Z]{16}',
    'Bearer\s+[A-Za-z0-9\-._~+/]{40,}',
    'AIza[0-9A-Za-z\-_]{35}',
    'AccountKey=[A-Za-z0-9+/=]{88}'
)

$stagedDiff = git diff --cached 2>$null
if ($stagedDiff) {
    $addedLines = $stagedDiff | Where-Object { $_ -match '^\+' }
    foreach ($pattern in $secretPatterns) {
        $match = $addedLines | Where-Object { $_ -match $pattern } | Select-Object -First 1
        if ($match) {
            Write-Error ""
            Write-Error "[HOOK:ValidatePush] BLOCKED: Potential secret detected in staged changes."
            Write-Error "[HOOK:ValidatePush] Pattern matched: $pattern"
            Write-Error "[HOOK:ValidatePush] Line: $($match.Substring(0, [Math]::Min(120, $match.Length)))"
            Write-Error ""
            Write-Error "[HOOK:ValidatePush] Fix: Remove the secret, add to .gitignore, and use .env instead."
            Write-Error "[HOOK:ValidatePush] If false positive, commit manually with: git commit --no-verify"
            exit 2
        }
    }
}

exit 0
