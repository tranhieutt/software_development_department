#!/bin/bash
# Claude Code SessionStart hook: Load project context at session start
# Outputs context information that Claude sees when a session begins
#
# Input schema (SessionStart): No stdin input

echo "=== Claude Code Software Development Department — Session Context ==="

USING_SDD_SKILL=".claude/skills/using-sdd/SKILL.md"
if [ -f "$USING_SDD_SKILL" ]; then
    echo ""
    echo "=== SDD ROUTER ==="
    echo "Required workflow router: $USING_SDD_SKILL"
    echo "Before any task action, route the request through using-sdd and follow the matching SDD skill gates."
    echo "=== END SDD ROUTER ==="
fi

# Current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(no git)")
if [ -n "$BRANCH" ]; then
    echo "Branch: $BRANCH"

    # Recent commits
    echo ""
    echo "Recent commits:"
    git log --oneline -5 2>/dev/null | while read -r line; do
        echo "  $line"
    done
fi

# Current sprint (find most recent sprint file)
LATEST_SPRINT=$(find production/sprints -maxdepth 1 -type f -name 'sprint-*.md' -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
if [ -n "$LATEST_SPRINT" ]; then
    echo ""
    echo "Active sprint: $(basename "$LATEST_SPRINT" .md)"
fi

# Current milestone
LATEST_MILESTONE=$(find production/milestones -maxdepth 1 -type f -name '*.md' -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
if [ -n "$LATEST_MILESTONE" ]; then
    echo "Active milestone: $(basename "$LATEST_MILESTONE" .md)"
fi

# Open bug count
BUG_COUNT=0
for dir in tests/playtest production; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "BUG-*.md" 2>/dev/null | wc -l)
        BUG_COUNT=$((BUG_COUNT + count))
    fi
done
if [ "$BUG_COUNT" -gt 0 ]; then
    echo "Open bugs: $BUG_COUNT"
fi

# Code health quick check
if [ -d "src" ]; then
    TODO_COUNT=$(grep -r "TODO" src/ 2>/dev/null | wc -l)
    FIXME_COUNT=$(grep -r "FIXME" src/ 2>/dev/null | wc -l)
    if [ "$TODO_COUNT" -gt 0 ] || [ "$FIXME_COUNT" -gt 0 ]; then
        echo ""
        echo "Code health: ${TODO_COUNT} TODOs, ${FIXME_COUNT} FIXMEs in src/"
    fi
fi

# --- Active session state recovery / bootstrap ---
STATE_DIR="production/session-state"
STATE_FILE="$STATE_DIR/active.md"
mkdir -p "$STATE_DIR" 2>/dev/null

if [ -f "$STATE_FILE" ]; then
    echo ""
    echo "=== ACTIVE SESSION STATE DETECTED ==="
    echo "A previous session left state at: $STATE_FILE"
    echo "Read this file to recover context and continue where you left off."
    echo ""
    echo "Quick summary:"
    head -20 "$STATE_FILE" 2>/dev/null
    TOTAL_LINES=$(wc -l < "$STATE_FILE" 2>/dev/null)
    if [ "$TOTAL_LINES" -gt 20 ]; then
        echo "  ... ($TOTAL_LINES total lines — read the full file to continue)"
    fi
    echo "=== END SESSION STATE PREVIEW ==="
else
    # Bootstrap a fresh active.md template so the live-checkpoint contract
    # (spec §5.8, context-management.md) is satisfied from the first turn.
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    CUR_BRANCH=${BRANCH:-main}
    cat > "$STATE_FILE" <<EOF
---
session: init
branch: $CUR_BRANCH
tags: []
started: $NOW
lastActive: $NOW
---

# Active Session State

> Live checkpoint for the current Claude Code session. The **file is the memory,
> not the conversation**. Append a new \`<!-- STATUS -->\` block at the end on
> every milestone or compaction; the last block wins.

## Current Task

_No active task — waiting for user direction._

## Progress Checklist

- [ ] _Fill in as work begins_

## Key Decisions Made

_None yet._

## Files This Session

| File | Action | Timestamp |
|---|---|---|
| _(none)_ | _(none)_ | _(none)_ |

## Partial Reads This Session

_None._

## Cached Decisions (may be stale)

_None._

## Subagent Log

| Timestamp | Agent | Task | Outcome |
|---|---|---|---|
| _(none)_ | _(none)_ | _(none)_ | _(none)_ |

## Open Questions / Blockers

_None._

---

<!-- STATUS: $NOW | Task: session initialized -->
Fresh session-state bootstrap by session-start.sh. No work in progress.
<!-- /STATUS -->
EOF
    echo ""
    echo "=== ACTIVE SESSION STATE BOOTSTRAPPED ==="
    echo "Created fresh $STATE_FILE (no prior session detected)."
    echo "=== END STATE BOOTSTRAP ==="
fi

# exit 0 # REWARD: Removed to allow GitNexus check to run

# --- GitNexus indexed repos ---
if command -v npx >/dev/null 2>&1; then
    GN_LIST=$(npx --no gitnexus list 2>/dev/null)
    if [ -n "$GN_LIST" ]; then
        echo ""
        echo "GitNexus indexed repos:"
        echo "$GN_LIST" | while IFS= read -r line; do
            echo "  $line"
        done
        echo "  (run 'npx gitnexus status' to check freshness)"
    fi
fi
