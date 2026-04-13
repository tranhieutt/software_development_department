#!/bin/bash
# auto-dream.sh — Automatic memory consolidation for SDD
# Triggered automatically by session-stop.sh when conditions are met.
# Purpose: Keep MEMORY.md lean, archive old files, merge duplicates.
# This is the "autoDream" equivalent from Claude Code's leaked source.

MEMORY_DIR=".claude/memory"
MEMORY_INDEX="$MEMORY_DIR/MEMORY.md"
ARCHIVE_DREAMS="$MEMORY_DIR/archive/dreams"

# ─── Guard: Only run if memory directory exists ───────────────────────────────
[ -d "$MEMORY_DIR" ] || exit 0

mkdir -p "$ARCHIVE_DREAMS" 2>/dev/null

TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
DREAM_LOG="$ARCHIVE_DREAMS/$TIMESTAMP_dream.md"

echo "🌙 Auto-Dream triggered at $(date '+%Y-%m-%d %H:%M')"

# ─── Phase 1: Orient — assess current memory health ──────────────────────────
TOTAL_FILES=$(find "$MEMORY_DIR" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
INDEX_LINES=$(wc -l < "$MEMORY_INDEX" 2>/dev/null | tr -d ' ')
INDEX_BYTES=$(wc -c < "$MEMORY_INDEX" 2>/dev/null | tr -d ' ')

echo "Memory health check:"
echo "  Index size     : $INDEX_LINES lines / $INDEX_BYTES bytes"
echo "  Topic files    : $TOTAL_FILES"

# ─── Phase 2: Detect stale/large files needing consolidation ─────────────────
STALE_COUNT=0
LARGE_COUNT=0
STALE_FILES=""

for f in "$MEMORY_DIR"/*.md; do
    [ "$f" = "$MEMORY_INDEX" ] && continue
    [ -f "$f" ] || continue

    FILE_LINES=$(wc -l < "$f" 2>/dev/null | tr -d ' ')
    FILE_BYTES=$(wc -c < "$f" 2>/dev/null | tr -d ' ')

    # Flag files older than 30 days with minimal content (< 5 lines)
    if [ "$FILE_LINES" -lt 5 ] 2>/dev/null; then
        FILE_AGE=$(find "$f" -mtime +30 2>/dev/null | wc -l | tr -d ' ')
        if [ "$FILE_AGE" -gt 0 ]; then
            STALE_COUNT=$((STALE_COUNT + 1))
            STALE_FILES="$STALE_FILES $f"
        fi
    fi

    # Flag oversized files (> 50 lines)
    if [ "$FILE_LINES" -gt 50 ] 2>/dev/null; then
        LARGE_COUNT=$((LARGE_COUNT + 1))
        echo "  ⚠️  Large file: $f ($FILE_LINES lines)"
    fi
done

# ─── Phase 3: Archive old empty/stub files → decisions archive ───────────────
ARCHIVED=0
for f in $STALE_FILES; do
    BASENAME=$(basename "$f")
    ARCHIVE_TARGET="$ARCHIVE_DREAMS/$(date +%Y-%m-%d)_archived_$BASENAME"
    mv "$f" "$ARCHIVE_TARGET" 2>/dev/null && ARCHIVED=$((ARCHIVED + 1))
    echo "  📦 Archived stale file: $BASENAME"
done

# ─── Phase 4: Prune MEMORY.md — remove broken links ─────────────────────────
PRUNED=0
if [ -f "$MEMORY_INDEX" ]; then
    # Remove lines pointing to files that no longer exist in memory dir
    TMP=$(mktemp)
    while IFS= read -r line; do
        # Extract filename from markdown link: [Title](filename.md)
        LINKED_FILE=$(echo "$line" | grep -oE '\([^)]+\.md\)' | tr -d '()')
        if [ -n "$LINKED_FILE" ]; then
            TARGET="$MEMORY_DIR/$LINKED_FILE"
            if [ ! -f "$TARGET" ]; then
                echo "  🗑️  Pruned broken link: $LINKED_FILE"
                PRUNED=$((PRUNED + 1))
                continue  # Skip this line — don't write to output
            fi
        fi
        echo "$line"
    done < "$MEMORY_INDEX" > "$TMP"
    mv "$TMP" "$MEMORY_INDEX" 2>/dev/null
fi

# ─── Phase 5: Write dream log to archive ─────────────────────────────────────
{
    echo "# Auto-Dream Log: $(date '+%Y-%m-%d %H:%M')"
    echo ""
    echo "## Actions"
    echo "- Files assessed: $TOTAL_FILES"
    echo "- Stale files archived: $ARCHIVED"
    echo "- Oversize files flagged: $LARGE_COUNT"
    echo "- Broken links pruned: $PRUNED"
    echo ""
    echo "## Memory State After"
    echo "- Index: $(wc -l < "$MEMORY_INDEX" 2>/dev/null | tr -d ' ') lines"
    [ "$LARGE_COUNT" -gt 0 ] && echo "- ⚠️ $LARGE_COUNT large files still need manual /dream (Consider storing deeply in MCP Supermemory)"
} > "$ARCHIVE_DREAMS/${TIMESTAMP}_dream.md" 2>/dev/null

# ─── Summary output ───────────────────────────────────────────────────────────
echo ""
echo "✅ Auto-Dream complete:"
echo "   Archived: $ARCHIVED files | Pruned: $PRUNED broken links"
echo "   🌐 Tip: For deep historical knowledge, use the mcp_supermemory_memory tool to save space!"
[ "$LARGE_COUNT" -gt 0 ] && \
    echo "   ⚠️  $LARGE_COUNT file(s) too large — run /dream to deep consolidate or save to MCP Supermemory"
[ "$ARCHIVED" -eq 0 ] && [ "$PRUNED" -eq 0 ] && \
    echo "   Memory is healthy — nothing to consolidate"

exit 0
