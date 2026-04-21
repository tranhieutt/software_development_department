#!/bin/bash
# Claude Code PreToolUse hook: Circuit Breaker Guard
# Reads .claude/memory/circuit-state.json; blocks Task tool if circuit is OPEN.
# Part of ADR-004 — Unified Failure State Machine (Phase 2).
#
# Exit 0 = allow, Exit 2 = block (message shown to Claude)
# Input: { "tool_name": "Task", "tool_input": { ... } }
#
# State machine: CLOSED → HALF_OPEN → OPEN
# OPEN state blocks all Task tool invocations until 60min TTL or /reset-circuit

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

# If state file doesn't exist, auto-create with CLOSED (non-blocking)
if [ ! -f "$CIRCUIT_FILE" ]; then
    jq -n '{
        "state": "CLOSED",
        "fail_count": 0,
        "last_fail_ts": null,
        "last_success_ts": null,
        "open_reason": null,
        "retry_backoff_s": 0,
        "_comment": "Auto-created by circuit-guard.sh — see ADR-004"
    }' > "$CIRCUIT_FILE" 2>/dev/null
    exit 0
fi

STATE=$(jq -r '.state // "CLOSED"' "$CIRCUIT_FILE" 2>/dev/null)
OPEN_REASON=$(jq -r '.open_reason // "unknown"' "$CIRCUIT_FILE" 2>/dev/null)
LAST_FAIL_TS=$(jq -r '.last_fail_ts // ""' "$CIRCUIT_FILE" 2>/dev/null)

case "$STATE" in
    CLOSED)
        # Normal operation — allow
        exit 0
        ;;

    HALF_OPEN)
        # Allow 1 probe request through, but warn
        echo "[HOOK:CircuitGuard] WARNING: Circuit is HALF_OPEN — probing. Monitor this task carefully." >&2
        exit 0
        ;;

    OPEN)
        # ─── Check TTL: auto-transition to HALF_OPEN after 60 minutes ───────
        SHOULD_TRANSITION=false
        if [ -n "$LAST_FAIL_TS" ] && [ "$LAST_FAIL_TS" != "null" ]; then
            # Calculate elapsed minutes since last failure
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
            # Auto-transition OPEN → HALF_OPEN
            jq '.state = "HALF_OPEN" | .open_reason = "Auto-transition after 60min TTL"' \
                "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
                && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
            echo "[HOOK:CircuitGuard] Circuit transitioned OPEN → HALF_OPEN (60min TTL elapsed)." >&2
            exit 0
        fi

        # Still OPEN — block
        echo "" >&2
        echo "╔══════════════════════════════════════════════════════════════╗" >&2
        echo "║  [CIRCUIT BREAKER] Task tool is BLOCKED                      ║" >&2
        echo "╠══════════════════════════════════════════════════════════════╣" >&2
        echo "║  State  : OPEN                                               ║" >&2
        printf "║  Reason : %-51s║\n" "$OPEN_REASON" >&2
        echo "║                                                              ║" >&2
        echo "║  The circuit will auto-reset after 60 minutes, OR           ║" >&2
        echo "║  reset manually:                                             ║" >&2
        echo "║    jq '.state=\"CLOSED\"|.fail_count=0|.open_reason=null' \\  ║" >&2
        echo "║      .claude/memory/circuit-state.json > /tmp/cs.json &&    ║" >&2
        echo "║    mv /tmp/cs.json .claude/memory/circuit-state.json        ║" >&2
        echo "╚══════════════════════════════════════════════════════════════╝" >&2
        echo "" >&2
        exit 2
        ;;

    *)
        # Unknown state — allow but warn
        echo "[HOOK:CircuitGuard] WARNING: Unknown circuit state '$STATE'. Allowing." >&2
        exit 0
        ;;
esac
