#!/bin/bash
# Claude Code UserPromptSubmit hook: Memory-aware context injection
# Reads keywords from the incoming prompt → finds relevant .claude/memory/ topic files
# → injects content as additionalContext so Claude adapts per-prompt, not just per-session.
#
# Input:  { "session_id": "...", "prompt": "...", "cwd": "..." }
# Output: { "additionalContext": "..." }  OR  nothing (exit 0 silently)
# Exit 0: always (must not block user workflow)

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
else
    PROMPT=$(echo "$INPUT" | grep -oE '"prompt":"[^"]*"' | sed 's/"prompt":"//;s/"$//')
    SESSION_ID="unknown"
fi

[ -z "$PROMPT" ] && exit 0

MEMORY_DIR=".claude/memory"
[ ! -d "$MEMORY_DIR" ] && exit 0

# Extract keywords from prompt: words > 4 chars, lowercase, deduplicated
KEYWORDS=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]' | \
    grep -oE '[a-z]{4,}' | sort -u | head -10)

[ -z "$KEYWORDS" ] && exit 0

MATCHED_FILES=""

for keyword in $KEYWORDS; do
    # Match by filename
    FILE_MATCH=$(find "$MEMORY_DIR" -maxdepth 1 -name "*.md" \
        ! -name "MEMORY.md" -iname "*${keyword}*" 2>/dev/null | head -2)
    # Match by content
    CONTENT_MATCH=$(grep -rl "$keyword" "$MEMORY_DIR" 2>/dev/null | \
        grep "\.md$" | grep -v "MEMORY\.md" | head -2)
    for f in $FILE_MATCH $CONTENT_MATCH; do
        if ! echo "$MATCHED_FILES" | grep -qF "$f"; then
            MATCHED_FILES="$MATCHED_FILES $f"
        fi
    done
done

FILE_COUNT=0
CONTEXT_PARTS=""

for f in $MATCHED_FILES; do
    [ "$FILE_COUNT" -ge 3 ] && break
    [ ! -f "$f" ] && continue
    TOPIC=$(basename "$f" .md)
    CONTENT=$(head -50 "$f" 2>/dev/null)
    CONTEXT_PARTS="${CONTEXT_PARTS}\n\n### Memory: ${TOPIC}\n${CONTENT}"
    FILE_COUNT=$((FILE_COUNT + 1))
done

[ "$FILE_COUNT" -eq 0 ] && exit 0

CONTEXT_TEXT="## Relevant Memory Context\n_Auto-injected from .claude/memory/ based on prompt keywords_${CONTEXT_PARTS}"

# Output valid JSON with escaped content
printf '{"additionalContext":"%s"}' \
    "$(printf '%s' "$CONTEXT_TEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n')"

exit 0
