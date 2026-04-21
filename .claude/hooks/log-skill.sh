#!/bin/bash
# Claude Code UserPromptSubmit hook: Log /skill-name invocations to skill-usage.jsonl
#
# Detects explicit skill invocations in user prompts (e.g. "/plan", "/tdd", "/save-state").
# Limitation: only catches user-typed slash commands, not Claude-autonomous Skill tool calls.
# This is the only reliable interception point — PostToolUse does not fire for Skill tool.
#
# Input:  { "session_id": "...", "prompt": "...", "cwd": "..." }
# Exit 0: always (fail-open per Rule 9)

INPUT=$(cat)
LOG_DIR="production/traces"
JSONL_FILE="$LOG_DIR/skill-usage.jsonl"

# ─── Parse input: prefer jq, fallback to node ────────────────────────────────
if command -v jq >/dev/null 2>&1; then
    PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
elif command -v node >/dev/null 2>&1; then
    PROMPT=$(echo "$INPUT" | node -e "
        let d=''; process.stdin.on('data',c=>d+=c).on('end',()=>{
            try{process.stdout.write(JSON.parse(d).prompt||'')}catch(e){}
        });
    " 2>/dev/null)
    SESSION_ID=$(echo "$INPUT" | node -e "
        let d=''; process.stdin.on('data',c=>d+=c).on('end',()=>{
            try{process.stdout.write(JSON.parse(d).session_id||'unknown')}catch(e){}
        });
    " 2>/dev/null)
else
    exit 0
fi

[ -z "$PROMPT" ] && exit 0

# Extract first /skill-name token (portable grep, no -P)
SKILL_NAME=$(echo "$PROMPT" | grep -o '/[a-zA-Z][a-zA-Z0-9_-]*' | head -1 | sed 's|^/||')
[ -z "$SKILL_NAME" ] && exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null)
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

mkdir -p "$LOG_DIR" 2>/dev/null

# Build JSON line via node (jq not available in this env)
if command -v jq >/dev/null 2>&1; then
    LOG_ENTRY=$(jq -cn \
        --arg ts  "$TIMESTAMP" \
        --arg sid "$SESSION_ID" \
        --arg sk  "$SKILL_NAME" \
        --arg b   "$BRANCH" \
        --arg src "user-prompt" \
        '{timestamp:$ts,session_id:$sid,skill:$sk,branch:$b,source:$src}' 2>/dev/null)
else
    LOG_ENTRY=$(node -e "
        process.stdout.write(JSON.stringify({
            timestamp: '${TIMESTAMP}',
            session_id: '${SESSION_ID}',
            skill: '${SKILL_NAME}',
            branch: '${BRANCH}',
            source: 'user-prompt'
        }));
    " 2>/dev/null)
fi

[ -z "$LOG_ENTRY" ] && exit 0

echo "$LOG_ENTRY" >> "$JSONL_FILE" 2>/dev/null

exit 0
