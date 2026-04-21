#!/bin/bash
# TEMPORARY debug hook: capture PostToolUse tool_name values for schema discovery.
# Remove after 1 session once tool_name list is confirmed.
# Exit 0: always (fail-open)

INPUT=$(cat)
if ! command -v jq >/dev/null 2>&1; then exit 0; fi

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null)
LOG="production/session-logs/posttooluse-names.log"

mkdir -p "$(dirname "$LOG")" 2>/dev/null
echo "$TIMESTAMP $TOOL_NAME" >> "$LOG" 2>/dev/null

exit 0
