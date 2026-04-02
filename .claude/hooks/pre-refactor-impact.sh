#!/bin/bash
# Claude Code PreToolUse hook: GitNexus pre-refactor impact reminder
# Fires on Write|Edit to src/** — reminds agents to check blast radius
# Exit 0 = allow (always), Exit 2 = block (never used here — warn only)
#
# Input schema (PreToolUse for Write/Edit):
# { "tool_name": "Write|Edit", "tool_input": { "file_path": "...", ... } }

INPUT=$(cat)

# Parse file_path
if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

# Normalize backslashes to forward slashes
FILE_PATH=$(echo "$FILE_PATH" | sed 's|\|/|g')

# Only check files in src/ — skip config, tests, docs, hooks, etc.
if ! echo "$FILE_PATH" | grep -qE '(^|/)src/'; then
    exit 0
fi

# Skip if GitNexus not available
if ! command -v npx >/dev/null 2>&1; then
    exit 0
fi

# Skip if no index exists for this repo
GN_STATUS=$(npx --no gitnexus status 2>/dev/null | grep -iE "indexed|up.to.date" | head -1)
if [ -z "$GN_STATUS" ]; then
    exit 0
fi

# Warn — never block
FILE_NAME=$(basename "$FILE_PATH")
echo "GitNexus: editing src file '$FILE_NAME' — run /gitnexus-impact-analysis to check blast radius before large changes." >&2

exit 0
