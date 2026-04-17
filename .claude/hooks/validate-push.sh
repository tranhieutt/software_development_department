#!/bin/bash
# Claude Code PreToolUse hook: Validates git push commands
# Warns on pushes to protected branches
# Exit 0 = allow, Exit 2 = block
#
# Input schema (PreToolUse for Bash):
# { "tool_name": "Bash", "tool_input": { "command": "git push origin main" } }

INPUT=$(cat)

# Parse command -- use jq if available, fall back to grep
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
else
    COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# Only process git push commands
if ! echo "$COMMAND" | grep -qE '^git[[:space:]]+push'; then
    exit 0
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
MATCHED_BRANCH=""

# Check if pushing to a protected branch
for branch in develop main master; do
    if [ "$CURRENT_BRANCH" = "$branch" ]; then
        MATCHED_BRANCH="$branch"
        break
    fi
    # Also check if pushing to a protected branch explicitly (quote branch name for safety)
    if echo "$COMMAND" | grep -qE "[[:space:]]${branch}([[:space:]]|$)"; then
        MATCHED_BRANCH="$branch"
        break
    fi
done

if [ -n "$MATCHED_BRANCH" ]; then
    echo "Push to protected branch '$MATCHED_BRANCH' detected." >&2
    echo "Reminder: Ensure build passes, unit tests pass, and no S1/S2 bugs exist." >&2
fi

# ─── SECRET SCAN: block if staged diff contains secrets ───────────────────
# Patterns that indicate real credentials being committed
SECRET_PATTERNS=(
    'ANTHROPIC_API_KEY\s*=\s*sk-ant-[A-Za-z0-9]'
    'OPENAI_API_KEY\s*=\s*sk-[A-Za-z0-9]'
    'sk-ant-[A-Za-z0-9\-]{20,}'
    'sk-[A-Za-z0-9]{48}'
    'ghp_[A-Za-z0-9]{36}'
    'github_pat_[A-Za-z0-9_]{80,}'
    'xox[baprs]-[A-Za-z0-9\-]{10,}'
    '-----BEGIN (RSA|EC|OPENSSH|PGP) PRIVATE KEY'
    'password\s*=\s*["\x27][^"\x27]{8,}["\x27]'
    'secret\s*=\s*["\x27][^"\x27]{8,}["\x27]'
    'DATABASE_URL\s*=\s*postgresql://[^:]+:[^@]+@'
    'AWS_ACCESS_KEY_ID\s*=\s*(AKIA|ASIA)[0-9A-Z]{16}'
    '(AKIA|ASIA)[0-9A-Z]{16}'
    'Bearer\s+[A-Za-z0-9\-._~+/]{40,}'
    'AIza[0-9A-Za-z\\-_]{35}'
    'AccountKey=[A-Za-z0-9+/=]{88}'
)

STAGED_DIFF=$(git diff --cached 2>/dev/null)

if [ -n "$STAGED_DIFF" ]; then
    for pattern in "${SECRET_PATTERNS[@]}"; do
        MATCH=$(echo "$STAGED_DIFF" | grep -E "^\+" | grep -E "$pattern" 2>/dev/null | head -1)
        if [ -n "$MATCH" ]; then
            echo "" >&2
            echo "BLOCKED: Potential secret detected in staged changes." >&2
            echo "Pattern matched: $pattern" >&2
            echo "Line: $(echo "$MATCH" | cut -c1-120)" >&2
            echo "" >&2
            echo "Fix: Remove the secret, add to .gitignore, and use .env instead." >&2
            echo "If this is a false positive, commit manually with: git commit --no-verify" >&2
            exit 2
        fi
    done
fi

exit 0
