#!/bin/bash
# Claude Code PreToolUse hook: Inject git history for files being read
# Helps Claude understand WHY a file looks the way it does — last author, recent changes.
# Inspired by claude-mem file-context handler pattern.
#
# Input:  { "tool_name": "Read", "tool_input": { "path": "..." } }
# Output: { "additionalContext": "..." }  OR  nothing (exit 0 silently)
# Exit 0: always (must not block reads)

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // ""')
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"path":"[^"]*"' | sed 's/"path":"//;s/"$//')
fi

[ -z "$FILE_PATH" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# File size gate: skip files < 1KB (overhead > benefit for tiny files)
FILE_SIZE=$(wc -c < "$FILE_PATH" 2>/dev/null | tr -d ' ')
[ "${FILE_SIZE:-0}" -lt 1024 ] && exit 0

# Git history for this file (requires file to be tracked)
GIT_LOG=$(git log --oneline -5 -- "$FILE_PATH" 2>/dev/null)
[ -z "$GIT_LOG" ] && exit 0  # Untracked file — no history to inject

LAST_AUTHOR=$(git log -1 --pretty="%an" -- "$FILE_PATH" 2>/dev/null)
LAST_DATE=$(git log -1 --pretty="%ar" -- "$FILE_PATH" 2>/dev/null)

FORMATTED_LOG=$(echo "$GIT_LOG" | while read -r line; do echo "  - $line"; done)

CONTEXT="## File History: $(basename "$FILE_PATH")
_Last modified: $LAST_DATE by ${LAST_AUTHOR}_

Recent commits touching this file:
$FORMATTED_LOG"

printf '{"additionalContext":"%s"}' \
    "$(printf '%s' "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n')"

exit 0
