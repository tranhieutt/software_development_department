#!/bin/bash
# Claude Code PostToolUse hook: Log file writes/edits to JSONL immediately
# Gives session-stop.sh an accurate per-file timeline instead of relying on git diff,
# which misses committed files and lacks timestamps.
#
# Input: { "session_id": "...", "tool_name": "Write|Edit", "tool_input": { "path": "..." } }
# Exit 0: always (logging is best-effort, must not block workflow)

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // ""')
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
else
    TOOL_NAME=$(echo "$INPUT" | grep -oE '"tool_name":"[^"]*"' | sed 's/"tool_name":"//;s/"$//')
    FILE_PATH=$(echo "$INPUT" | grep -oE '"path":"[^"]*"' | sed 's/"path":"//;s/"$//')
    [ -z "$FILE_PATH" ] && FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path":"[^"]*"' | sed 's/"file_path":"//;s/"$//')
    SESSION_ID=$(echo "$INPUT" | grep -oE '"session_id":"[^"]*"' | sed 's/"session_id":"//;s/"$//')
    [ -z "$SESSION_ID" ] && SESSION_ID="unknown"
fi

[ -z "$FILE_PATH" ] && exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
LOG_DIR="production/session-logs"
mkdir -p "$LOG_DIR" 2>/dev/null

# Create safe JSON entry
if command -v jq >/dev/null 2>&1; then
    LOG_ENTRY=$(jq -n \
        --arg ev "$TOOL_NAME" \
        --arg ts "$TIMESTAMP" \
        --arg sid "$SESSION_ID" \
        --arg f "$FILE_PATH" \
        --arg b "$BRANCH" \
        '{event: $ev, timestamp: $ts, session_id: $sid, file: $f, branch: $b}' \
        --compact-output)
else
    # Fallback: Minimal escaping for double quotes and backslashes
    ESCAPED_PATH=$(echo "$FILE_PATH" | sed 's/\\/\\\\/g; s/"/\\"/g')
    ESCAPED_TOOL=$(echo "$TOOL_NAME" | sed 's/\\/\\\\/g; s/"/\\"/g')
    LOG_ENTRY="{\"event\":\"$ESCAPED_TOOL\",\"timestamp\":\"$TIMESTAMP\",\"session_id\":\"$SESSION_ID\",\"file\":\"$ESCAPED_PATH\",\"branch\":\"$BRANCH\"}"
fi

echo "$LOG_ENTRY" >> "$LOG_DIR/writes.jsonl" 2>/dev/null

exit 0
