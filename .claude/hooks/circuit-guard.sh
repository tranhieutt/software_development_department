#!/bin/bash
# Claude Code PreToolUse hook: Circuit Breaker Guard (v2 — per-agent)
# Reads .claude/memory/circuit-state.json; blocks/warns per agent, not globally.
# Part of ADR-004 — Unified Failure State Machine (Phase 2, schema v2).
#
# Exit 0 = allow, Exit 2 = block (message shown to Claude)
# Input: { "tool_name": "Task", "tool_input": { "subagent_type": "<agent>" } }

INPUT=$(cat)

# ─── REQUIRE jq ──────────────────────────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
    echo "[HOOK:CircuitGuard] WARNING: jq not found, circuit guard skipped." >&2
    exit 0
fi

# Only intercept Task tool
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
if [ "$TOOL_NAME" != "Task" ]; then
    exit 0
fi

# ─── DEBUG: dump Task input payload once for schema discovery ─────────────────
DEBUG_FILE="production/session-logs/task-input-sample.json"
if [ ! -f "$DEBUG_FILE" ]; then
    mkdir -p "$(dirname "$DEBUG_FILE")"
    echo "$INPUT" | jq '.' > "$DEBUG_FILE" 2>/dev/null || true
fi

CIRCUIT_FILE=".claude/memory/circuit-state.json"

# ─── Extract agent name from Task input ──────────────────────────────────────
AGENT=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // empty' 2>/dev/null)

# If no agent specified or file missing, allow (fail-open)
if [ -z "$AGENT" ] || [ ! -f "$CIRCUIT_FILE" ]; then
    exit 0
fi

# ─── Auto-init agent entry if not present ────────────────────────────────────
HAS_AGENT=$(jq --arg a "$AGENT" '.agents[$a] // empty' "$CIRCUIT_FILE" 2>/dev/null)
if [ -z "$HAS_AGENT" ]; then
    # Unknown agent — not tracked, allow
    exit 0
fi

STATE=$(jq -r --arg a "$AGENT" '.agents[$a].state // "CLOSED"' "$CIRCUIT_FILE" 2>/dev/null)
OPEN_REASON=$(jq -r --arg a "$AGENT" '.agents[$a].open_reason // "unknown"' "$CIRCUIT_FILE" 2>/dev/null)
LAST_FAIL_TS=$(jq -r --arg a "$AGENT" '.agents[$a].last_fail_ts // ""' "$CIRCUIT_FILE" 2>/dev/null)
FALLBACK=$(jq -r --arg a "$AGENT" '.agents[$a].fallback // "null"' "$CIRCUIT_FILE" 2>/dev/null)

case "$STATE" in
    CLOSED)
        exit 0
        ;;

    HALF_OPEN)
        echo "[HOOK:CircuitGuard] WARNING: Agent '$AGENT' circuit is HALF_OPEN — probing. Monitor carefully." >&2
        exit 0
        ;;

    OPEN)
        # ─── Check TTL: auto-transition to HALF_OPEN after 60 minutes ────────
        SHOULD_TRANSITION=false
        if [ -n "$LAST_FAIL_TS" ] && [ "$LAST_FAIL_TS" != "null" ]; then
            if command -v python3 >/dev/null 2>&1; then
                ELAPSED=$(python3 -c "
import sys, datetime
try:
    ts = datetime.datetime.fromisoformat('${LAST_FAIL_TS}'.replace('Z', '+00:00'))
    now = datetime.datetime.now(datetime.timezone.utc)
    diff = (now - ts).total_seconds() / 60
    print(int(diff))
except:
    print(-1)
" 2>/dev/null)
                if [ "$ELAPSED" -ge 60 ] 2>/dev/null; then
                    SHOULD_TRANSITION=true
                fi
            fi
        fi

        if [ "$SHOULD_TRANSITION" = true ]; then
            jq --arg a "$AGENT" \
                '.agents[$a].state = "HALF_OPEN" | .agents[$a].open_reason = "Auto-transition after 60min TTL"' \
                "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
                && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
            echo "[HOOK:CircuitGuard] Agent '$AGENT': OPEN → HALF_OPEN (60min TTL elapsed)." >&2
            NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
            bash scripts/ledger-append.sh \
                --agent "$AGENT" \
                --task-id "circuit-transition-${NOW}" \
                --request "Circuit TTL auto-reset for agent '$AGENT'" \
                --reasoning "60min TTL elapsed since last failure, transitioning to probe state" \
                --choice "OPEN → HALF_OPEN for agent '$AGENT' (TTL auto-reset)" \
                --outcome "pass" \
                --risk "High" 2>/dev/null || true
            exit 0
        fi

        # Still OPEN — block and suggest fallback
        echo "" >&2
        echo "╔══════════════════════════════════════════════════════════════╗" >&2
        echo "║  [CIRCUIT BREAKER] Agent Task is BLOCKED                     ║" >&2
        echo "╠══════════════════════════════════════════════════════════════╣" >&2
        printf "║  Agent  : %-51s║\n" "$AGENT" >&2
        echo "║  State  : OPEN                                               ║" >&2
        printf "║  Reason : %-51s║\n" "$OPEN_REASON" >&2
        if [ "$FALLBACK" != "null" ] && [ -n "$FALLBACK" ]; then
            printf "║  Fallback: %-50s║\n" "$FALLBACK" >&2
            echo "║  → Route this task to the fallback agent above.             ║" >&2
        else
            echo "║  No fallback configured — surface to user.                  ║" >&2
        fi
        echo "║                                                              ║" >&2
        echo "║  Auto-reset after 60min, or reset manually:                  ║" >&2
        printf "║    jq '.agents[\"%s\"].state=\"CLOSED\"' circuit-state.json\n" "$AGENT" >&2
        echo "╚══════════════════════════════════════════════════════════════╝" >&2
        echo "" >&2
        exit 2
        ;;

    *)
        echo "[HOOK:CircuitGuard] WARNING: Unknown circuit state '$STATE' for agent '$AGENT'. Allowing." >&2
        exit 0
        ;;
esac
