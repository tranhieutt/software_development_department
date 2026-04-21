#!/bin/bash
# Claude Code PostToolUse hook: Log skill invocations to skill-usage.jsonl
# Triggers on: Skill tool
# Exit 0: always (fail-open per Rule 9)
#
# Input: { "tool_name": "Skill", "tool_input": { "skill": "...", "args": "..." }, ... }

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
    exit 0
fi

SKILL_NAME=$(echo "$INPUT" | jq -r '.tool_input.skill // "unknown"' 2>/dev/null)
SKILL_ARGS=$(echo "$INPUT" | jq -r '.tool_input.args  // ""'        2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id       // "unknown"' 2>/dev/null)

[ "$SKILL_NAME" = "unknown" ] && exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
LOG_DIR="production/traces"
JSONL_FILE="$LOG_DIR/skill-usage.jsonl"

mkdir -p "$LOG_DIR" 2>/dev/null

LOG_ENTRY=$(jq -n \
    --arg ts  "$TIMESTAMP" \
    --arg sid "$SESSION_ID" \
    --arg sk  "$SKILL_NAME" \
    --arg sa  "$SKILL_ARGS" \
    --arg b   "$BRANCH" \
    '{timestamp: $ts, session_id: $sid, skill: $sk, args: $sa, branch: $b}' \
    --compact-output 2>/dev/null)

if command -v flock >/dev/null 2>&1; then
    (
        flock -x 200
        echo "$LOG_ENTRY" >> "$JSONL_FILE"
    ) 200>"${JSONL_FILE}.lock" 2>/dev/null
else
    echo "$LOG_ENTRY" >> "$JSONL_FILE" 2>/dev/null
fi

exit 0
