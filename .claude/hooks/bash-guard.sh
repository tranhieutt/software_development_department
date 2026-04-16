#!/bin/bash
# Claude Code PreToolUse hook: Bash Guard
# Blocks dangerous commands not covered by settings.json deny list.
# deny list handles: rm -rf, sudo, curl|bash, wget|bash, chmod 777, git push --force
# This hook handles: fork bombs, disk operations, SQL destructive, variants
#
# Exit 0 = allow, Exit 2 = block (message shown to Claude)
# Input: JSON on stdin { "tool_name": "Bash", "tool_input": { "command": "..." } }

INPUT=$(cat)

# Parse command
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
else
    COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | \
        sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# Only process Bash tool
TOOL_NAME=$(echo "$INPUT" | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | \
    sed 's/"tool_name"[[:space:]]*:[[:space:]]*"//;s/"$//')
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

[ -z "$COMMAND" ] && exit 0

# ─── HARD BLOCKS ─────────────────────────────────────────────────────────────
# Patterns NOT already in deny list

block_if_match() {
    local pattern="$1"
    local reason="$2"
    if echo "$COMMAND" | grep -qE "$pattern"; then
        echo "[HOOK:BashGuard] BLOCKED: $reason" >&2
        echo "[HOOK:BashGuard] Command: $COMMAND" >&2
        exit 2
    fi
}

# Fork bomb variants
block_if_match ':\s*\(\s*\)\s*\{' \
    "Fork bomb pattern detected: :(){ :|:& };:"

# Disk formatting
block_if_match 'mkfs\.' \
    "Disk formatting is forbidden (mkfs.*)"

# Direct disk write
block_if_match '>\s*/dev/sd[a-z]' \
    "Direct disk write is forbidden (> /dev/sdX)"

block_if_match 'dd\s+if=/dev/zero' \
    "Disk wipe is forbidden (dd if=/dev/zero)"

block_if_match 'dd\s+if=/dev/random' \
    "Disk overwrite is forbidden (dd if=/dev/random)"

# Crontab wipe
block_if_match 'crontab\s+-r' \
    "Deleting all cron jobs is forbidden (crontab -r)"

# Python/Node package publish without confirmation (accidental publish)
block_if_match '^twine\s+upload' \
    "PyPI publish requires explicit user confirmation — do not run automatically"

# ─── SOFT WARNINGS ───────────────────────────────────────────────────────────
# Allow but inject warning into Claude's context

WARNINGS=""

warn_if_match() {
    local pattern="$1"
    local msg="$2"
    if echo "$COMMAND" | grep -qiE "$pattern"; then
        WARNINGS="$WARNINGS\n  [WARN] $msg"
    fi
}

warn_if_match 'DROP\s+TABLE' \
    "SQL DROP TABLE detected — verify this is intentional and has a rollback plan"

warn_if_match 'DELETE\s+FROM' \
    "SQL DELETE FROM detected — ensure WHERE clause is correct"

warn_if_match 'TRUNCATE\s+(TABLE\s+)?' \
    "SQL TRUNCATE detected — this permanently removes all rows"

warn_if_match 'git\s+reset\s+--hard' \
    "git reset --hard discards uncommitted changes permanently"

warn_if_match 'git\s+clean\s+-fd?' \
    "git clean -f removes untracked files permanently"

warn_if_match 'docker\s+volume\s+rm' \
    "docker volume rm deletes persistent data"

warn_if_match 'DROP\s+DATABASE' \
    "SQL DROP DATABASE detected — this destroys the entire database"

if [ -n "$WARNINGS" ]; then
    printf "[HOOK:BashGuard] Warnings for command review:%b\n" "$WARNINGS"
fi

exit 0
