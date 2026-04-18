#!/bin/bash
# Claude Code PostToolUse hook: Circuit State Updater (UFSM Phase 3)
# Updates .claude/memory/circuit-state.json on Task tool success or failure.
# Part of ADR-004 — Unified Failure State Machine.
#
# Event: PostToolUse (matcher: Task)
# Input (stdin): { "tool_name": "Task", "tool_response": { "exit_code": 0|1|2, ... } }
#
# State transitions (ADR-004 §Transition Rules):
#   success (exit_code 0) → reset fail_count=0, backoff=0 → CLOSED
#   failure (exit_code != 0):
#     CLOSED:    fail_count++ → if count<3: stay CLOSED, else → HALF_OPEN
#     HALF_OPEN: fail_count++ → if count<4: stay HALF_OPEN, else → OPEN
#   OPEN: no transition here (TTL handled by circuit-guard.sh read-path)
#
# Exit 0 always (fail-open per Rule 9 — never block on a PostToolUse hook)

INPUT=$(cat)

# ─── Require jq (fail-open) ──────────────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
    echo "[HOOK:CircuitUpdater] WARNING: jq not found, circuit state NOT updated." >&2
    exit 0
fi

# Only handle Task tool
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
if [ "$TOOL_NAME" != "Task" ]; then
    exit 0
fi

CIRCUIT_FILE=".claude/memory/circuit-state.json"
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Auto-create if missing (mirrors circuit-guard.sh behavior)
if [ ! -f "$CIRCUIT_FILE" ]; then
    jq -n \
        --arg now "$NOW" \
        '{
            "state": "CLOSED",
            "fail_count": 0,
            "last_fail_ts": null,
            "last_success_ts": $now,
            "open_reason": null,
            "retry_backoff_s": 0,
            "_comment": "Auto-created by circuit-updater.sh — see ADR-004"
        }' > "$CIRCUIT_FILE" 2>/dev/null
    exit 0
fi

# ─── Read tool response ───────────────────────────────────────────────────────
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_response.exit_code // 0' 2>/dev/null)

# ─── Read current state ───────────────────────────────────────────────────────
STATE=$(jq -r '.state // "CLOSED"' "$CIRCUIT_FILE" 2>/dev/null)
FAIL_COUNT=$(jq -r '.fail_count // 0' "$CIRCUIT_FILE" 2>/dev/null)

# Fallback to integers
STATE="${STATE:-CLOSED}"
FAIL_COUNT="${FAIL_COUNT:-0}"

# ─── Compute backoff (2^fail_count seconds, capped at 8) ─────────────────────
_backoff() {
    local n=$1
    if   [ "$n" -ge 3 ]; then echo 8
    elif [ "$n" -eq 2 ]; then echo 4
    elif [ "$n" -eq 1 ]; then echo 2
    else echo 0
    fi
}

# ─── SUCCESS path ─────────────────────────────────────────────────────────────
if [ "$EXIT_CODE" = "0" ]; then
    jq \
        --arg now "$NOW" \
        '.state = "CLOSED"
        | .fail_count = 0
        | .last_success_ts = $now
        | .open_reason = null
        | .retry_backoff_s = 0' \
        "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
    && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
    # Silently log to stderr (debug level)
    echo "[HOOK:CircuitUpdater] Task SUCCESS → CLOSED (fail_count reset)" >&2
    exit 0
fi

# ─── FAILURE path ─────────────────────────────────────────────────────────────
NEW_FAIL_COUNT=$((FAIL_COUNT + 1))
BACKOFF=$(_backoff "$NEW_FAIL_COUNT")

case "$STATE" in

    CLOSED)
        if [ "$NEW_FAIL_COUNT" -ge 3 ]; then
            # CLOSED → HALF_OPEN
            jq \
                --arg now "$NOW" \
                --argjson fc "$NEW_FAIL_COUNT" \
                --argjson bo "$BACKOFF" \
                '.state = "HALF_OPEN"
                | .fail_count = $fc
                | .last_fail_ts = $now
                | .retry_backoff_s = $bo
                | .open_reason = "3 consecutive failures in CLOSED state"' \
                "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
            && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
            echo "[HOOK:CircuitUpdater] Task FAIL #${NEW_FAIL_COUNT} → CLOSED → HALF_OPEN (3 strikes)" >&2
        else
            # Stay CLOSED, increment fail_count
            jq \
                --arg now "$NOW" \
                --argjson fc "$NEW_FAIL_COUNT" \
                --argjson bo "$BACKOFF" \
                '.fail_count = $fc
                | .last_fail_ts = $now
                | .retry_backoff_s = $bo' \
                "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
            && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
            echo "[HOOK:CircuitUpdater] Task FAIL #${NEW_FAIL_COUNT} — backoff=${BACKOFF}s (still CLOSED)" >&2
        fi
        ;;

    HALF_OPEN)
        if [ "$NEW_FAIL_COUNT" -ge 4 ]; then
            # HALF_OPEN → OPEN
            REASON="4 consecutive failures: HALF_OPEN probe failed"
            jq \
                --arg now "$NOW" \
                --argjson fc "$NEW_FAIL_COUNT" \
                --argjson bo "$BACKOFF" \
                --arg reason "$REASON" \
                '.state = "OPEN"
                | .fail_count = $fc
                | .last_fail_ts = $now
                | .retry_backoff_s = $bo
                | .open_reason = $reason' \
                "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
            && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
            echo "[HOOK:CircuitUpdater] Task FAIL #${NEW_FAIL_COUNT} → HALF_OPEN → OPEN (circuit blown)" >&2
            echo "[HOOK:CircuitUpdater] ⚠️  All Task tool calls are now blocked for 60min or until /reset-circuit." >&2
        else
            # Stay HALF_OPEN
            jq \
                --arg now "$NOW" \
                --argjson fc "$NEW_FAIL_COUNT" \
                --argjson bo "$BACKOFF" \
                '.fail_count = $fc
                | .last_fail_ts = $now
                | .retry_backoff_s = $bo' \
                "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
            && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
            echo "[HOOK:CircuitUpdater] Task FAIL #${NEW_FAIL_COUNT} — still HALF_OPEN, backoff=${BACKOFF}s" >&2
        fi
        ;;

    OPEN)
        # Already OPEN — just update timestamp, don't increment further
        jq \
            --arg now "$NOW" \
            '.last_fail_ts = $now' \
            "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
        && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
        echo "[HOOK:CircuitUpdater] Task FAIL — circuit already OPEN, timestamp refreshed." >&2
        ;;

    *)
        echo "[HOOK:CircuitUpdater] WARNING: Unknown circuit state '$STATE'. No update." >&2
        ;;
esac

exit 0
