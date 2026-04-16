#!/bin/bash
# Claude Code Stop hook: Archive session state + stats summary
# Reads JSONL agent log to compute session stats before archiving.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
else
    SESSION_ID=$(echo "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | \
        sed 's/"session_id"[[:space:]]*:[[:space:]]*"//;s/"$//')
    [ -z "$SESSION_ID" ] && SESSION_ID="unknown"
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SESSION_LOG_DIR="production/session-logs"
mkdir -p "$SESSION_LOG_DIR" 2>/dev/null

# ─── Compute session stats from JSONL agent log ───────────────────────────────
AGENTS_INVOKED=0
AGENT_NAMES=""
JSONL_LOG="$SESSION_LOG_DIR/agent-audit.jsonl"

if [ -f "$JSONL_LOG" ]; then
    if command -v jq >/dev/null 2>&1; then
        AGENTS_INVOKED=$(jq -r --arg sid "$SESSION_ID" \
            'select(.session_id == $sid) | .agent_name' \
            "$JSONL_LOG" 2>/dev/null | wc -l | tr -d ' ')
        AGENT_NAMES=$(jq -r --arg sid "$SESSION_ID" \
            'select(.session_id == $sid) | .agent_name' \
            "$JSONL_LOG" 2>/dev/null | sort | uniq | tr '\n' ',' | sed 's/,$//')
    else
        AGENTS_INVOKED=$(grep -c "\"session_id\":\"$SESSION_ID\"" "$JSONL_LOG" 2>/dev/null || echo 0)
    fi
fi

# ─── Git activity this session ────────────────────────────────────────────────
RECENT_COMMITS=$(git log --oneline --since="8 hours ago" 2>/dev/null)
MODIFIED_FILES=$(git diff --name-only 2>/dev/null)
COMMIT_COUNT=$(echo "$RECENT_COMMITS" | grep -c . 2>/dev/null || echo 0)
[ "$RECENT_COMMITS" = "" ] && COMMIT_COUNT=0

# ─── Archive active session state ─────────────────────────────────────────────
STATE_FILE="production/session-state/active.md"
if [ -f "$STATE_FILE" ]; then
    {
        echo "## Archived Session State: $TIMESTAMP"
        echo "Session ID: $SESSION_ID"
        cat "$STATE_FILE"
        echo "---"
        echo ""
    } >> "$SESSION_LOG_DIR/session-log.md" 2>/dev/null
    rm "$STATE_FILE" 2>/dev/null
fi

# ─── Write session summary to log ─────────────────────────────────────────────
{
    echo "## Session End: $TIMESTAMP"
    echo "Session ID: $SESSION_ID"
    echo ""
    echo "### Stats"
    echo "Agents invoked : $AGENTS_INVOKED"
    [ -n "$AGENT_NAMES" ] && echo "Agent names    : $AGENT_NAMES"
    echo "Commits made   : $COMMIT_COUNT"

    if [ -n "$RECENT_COMMITS" ]; then
        echo ""
        echo "### Commits"
        echo "$RECENT_COMMITS"
    fi
    if [ -n "$MODIFIED_FILES" ]; then
        echo ""
        echo "### Uncommitted Changes"
        echo "$MODIFIED_FILES"
    fi

    # Files written this session (from writes.jsonl — more accurate than git diff)
    WRITES_LOG="$SESSION_LOG_DIR/writes.jsonl"
    if [ -f "$WRITES_LOG" ] && command -v jq >/dev/null 2>&1; then
        WRITTEN_FILES=$(jq -r --arg sid "$SESSION_ID" \
            'select(.session_id == $sid) | .file' \
            "$WRITES_LOG" 2>/dev/null | sort -u)
        if [ -n "$WRITTEN_FILES" ]; then
            echo ""
            echo "### Files Written This Session"
            echo "$WRITTEN_FILES" | while read -r f; do echo "  - $f"; done
        fi
    fi

    echo "---"
    echo ""
} >> "$SESSION_LOG_DIR/session-log.md" 2>/dev/null

# ─── Tier 3: Archive session summary into .claude/memory/archive/sessions/ ───
ARCHIVE_SESSION_DIR=".claude/memory/archive/sessions"
mkdir -p "$ARCHIVE_SESSION_DIR" 2>/dev/null

ARCHIVE_FILENAME="$ARCHIVE_SESSION_DIR/$(date +%Y-%m-%d_%H-%M)_session.md"
{
    echo "# Session Summary: $(date '+%Y-%m-%d %H:%M')"
    echo "Session ID: $SESSION_ID"
    echo ""
    echo "## Stats"
    echo "- Agents invoked: $AGENTS_INVOKED"
    [ -n "$AGENT_NAMES" ] && echo "- Agent names: $AGENT_NAMES"
    echo "- Commits made: $COMMIT_COUNT"
    if [ -n "$RECENT_COMMITS" ]; then
        echo ""
        echo "## Commits"
        echo "$RECENT_COMMITS"
    fi
    if [ -n "$MODIFIED_FILES" ]; then
        echo ""
        echo "## Uncommitted Files"
        echo "$MODIFIED_FILES"
    fi

    # Files written this session (from writes.jsonl)
    WRITES_LOG="$SESSION_LOG_DIR/writes.jsonl"
    if [ -f "$WRITES_LOG" ] && command -v jq >/dev/null 2>&1; then
        WRITTEN_FILES=$(jq -r --arg sid "$SESSION_ID" \
            'select(.session_id == $sid) | .file' \
            "$WRITES_LOG" 2>/dev/null | sort -u)
        if [ -n "$WRITTEN_FILES" ]; then
            echo ""
            echo "## Files Written This Session"
            echo "$WRITTEN_FILES" | while read -r f; do echo "  - $f"; done
        fi
    fi
} > "$ARCHIVE_FILENAME" 2>/dev/null

# ─── Update Tier 1: Write "Last session" line into MEMORY.md ─────────────────
MEMORY_FILE=".claude/memory/MEMORY.md"
if [ -f "$MEMORY_FILE" ]; then
    # Update the "Last session" line in place
    sed -i "s|^- Last session:.*|- Last session: $(date '+%Y-%m-%d %H:%M') · agents=$AGENTS_INVOKED · commits=$COMMIT_COUNT|" "$MEMORY_FILE" 2>/dev/null
fi

# ─── Auto-Dream: Smart trigger ───────────────────────────────────────────────
# Runs auto-dream.sh automatically when any of these conditions are met:
#   1. MEMORY.md exceeds 40 lines (approaching the 50-line limit)
#   2. Every 5th session (periodic maintenance — archives accumulate)
#   3. More than 3 topic files exist not accessed in last 7 days

MEMORY_FILE=".claude/memory/MEMORY.md"
MEMORY_LINES=$(wc -l < "$MEMORY_FILE" 2>/dev/null | tr -d ' ')
AUTO_DREAM_HOOK=".claude/hooks/auto-dream.sh"
DREAM_TRIGGERED=false
DREAM_REASON=""

# Condition 1: Index is bloated
if [ "$MEMORY_LINES" -gt 40 ] 2>/dev/null; then
    DREAM_TRIGGERED=true
    DREAM_REASON="MEMORY.md is ${MEMORY_LINES} lines (limit: 50)"
fi

# Condition 2: Periodic — every 5 sessions
if [ "$DREAM_TRIGGERED" = false ]; then
    SESSION_COUNT=$(find ".claude/memory/archive/sessions" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    REMAINDER=$((SESSION_COUNT % 5))
    if [ "$REMAINDER" -eq 0 ] && [ "$SESSION_COUNT" -gt 0 ] 2>/dev/null; then
        DREAM_TRIGGERED=true
        DREAM_REASON="Periodic maintenance (session #${SESSION_COUNT})"
    fi
fi

# Condition 3: Stale topic files accumulating
if [ "$DREAM_TRIGGERED" = false ]; then
    STALE=$(find ".claude/memory" -maxdepth 1 -name "*.md" \
        ! -name "MEMORY.md" -mtime +7 2>/dev/null | wc -l | tr -d ' ')
    if [ "$STALE" -gt 3 ] 2>/dev/null; then
        DREAM_TRIGGERED=true
        DREAM_REASON="$STALE topic files not updated in 7+ days"
    fi
fi

# Execute auto-dream if triggered
DREAM_OUTPUT=""
if [ "$DREAM_TRIGGERED" = true ] && [ -f "$AUTO_DREAM_HOOK" ]; then
    DREAM_OUTPUT=$(bash "$AUTO_DREAM_HOOK" 2>/dev/null)
fi

# ─── Print summary to stdout (visible in Claude's context) ───────────────────
echo "=== Session Complete ==="
echo "Agents invoked : $AGENTS_INVOKED"
[ -n "$AGENT_NAMES" ] && echo "Agents         : $AGENT_NAMES"
echo "Commits        : $COMMIT_COUNT"
echo "Archived to    : $ARCHIVE_FILENAME"
if [ "$DREAM_TRIGGERED" = true ]; then
    echo ""
    echo "🌙 Auto-Dream triggered: $DREAM_REASON"
    [ -n "$DREAM_OUTPUT" ] && echo "$DREAM_OUTPUT"
fi
echo "========================"

exit 0
