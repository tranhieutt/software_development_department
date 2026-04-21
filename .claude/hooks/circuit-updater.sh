#!/bin/bash
# Claude Code PostToolUse hook: Circuit State Updater (v2 — per-agent)
# Updates per-agent state in .claude/memory/circuit-state.json.
# Part of ADR-004 — Unified Failure State Machine (schema v2).
#
# Event: PostToolUse (matcher: Task)
# Input (stdin): { "tool_name": "Task", "tool_input": { "subagent_type": "<agent>" }, "tool_response": { "exit_code": 0|1|2 } }
#
# State transitions per agent (ADR-004 §Transition Rules):
#   success (exit_code 0) → reset fail_count=0, backoff=0 → CLOSED
#   failure (exit_code != 0):
#     CLOSED:    fail_count++ → if count<3: stay CLOSED, else → HALF_OPEN
#     HALF_OPEN: fail_count++ → if count<4: stay HALF_OPEN, else → OPEN
#   OPEN: refresh timestamp only (TTL handled by circuit-guard.sh read-path)
#
# Exit 0 always (fail-open per Rule 9)

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
    echo "[HOOK:CircuitUpdater] WARNING: jq not found, circuit state NOT updated." >&2
    exit 0
fi

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
if [ "$TOOL_NAME" != "Task" ]; then
    exit 0
fi

CIRCUIT_FILE=".claude/memory/circuit-state.json"
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Extract agent from Task input
AGENT=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // empty' 2>/dev/null)

# Unknown agent or missing file — fail-open
if [ -z "$AGENT" ] || [ ! -f "$CIRCUIT_FILE" ]; then
    exit 0
fi

# Agent not tracked in circuit state — fail-open (don't auto-init to avoid bloat)
HAS_AGENT=$(jq --arg a "$AGENT" '.agents[$a] // empty' "$CIRCUIT_FILE" 2>/dev/null)
if [ -z "$HAS_AGENT" ]; then
    exit 0
fi

EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_response.exit_code // 0' 2>/dev/null)
STATE=$(jq -r --arg a "$AGENT" '.agents[$a].state // "CLOSED"' "$CIRCUIT_FILE" 2>/dev/null)
FAIL_COUNT=$(jq -r --arg a "$AGENT" '.agents[$a].fail_count // 0' "$CIRCUIT_FILE" 2>/dev/null)
STATE="${STATE:-CLOSED}"
FAIL_COUNT="${FAIL_COUNT:-0}"

# ─── Backoff: 2^n seconds, capped at 8 ──────────────────────────────────────
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
    jq --arg a "$AGENT" --arg now "$NOW" \
        '.agents[$a].state = "CLOSED"
        | .agents[$a].fail_count = 0
        | .agents[$a].last_success_ts = $now
        | .agents[$a].open_reason = null
        | .agents[$a].retry_backoff_s = 0' \
        "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
    && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
    echo "[HOOK:CircuitUpdater] Agent '$AGENT' SUCCESS → CLOSED (fail_count reset)" >&2
    exit 0
fi

# ─── FAILURE path ─────────────────────────────────────────────────────────────
NEW_FAIL_COUNT=$((FAIL_COUNT + 1))
BACKOFF=$(_backoff "$NEW_FAIL_COUNT")

case "$STATE" in

    CLOSED)
        if [ "$NEW_FAIL_COUNT" -ge 3 ]; then
            jq --arg a "$AGENT" --arg now "$NOW" \
                --argjson fc "$NEW_FAIL_COUNT" --argjson bo "$BACKOFF" \
                '.agents[$a].state = "HALF_OPEN"
                | .agents[$a].fail_count = $fc
                | .agents[$a].last_fail_ts = $now
                | .agents[$a].retry_backoff_s = $bo
                | .agents[$a].open_reason = "3 consecutive failures in CLOSED state"' \
                "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
            && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
            echo "[HOOK:CircuitUpdater] Agent '$AGENT' FAIL #${NEW_FAIL_COUNT} → CLOSED → HALF_OPEN (3 strikes)" >&2
            bash scripts/ledger-append.sh \
                --agent "$AGENT" \
                --task-id "circuit-transition-${NOW}" \
                --request "Task agent '$AGENT' failed" \
                --reasoning "3 consecutive failures in CLOSED state triggered HALF_OPEN transition" \
                --choice "CLOSED → HALF_OPEN for agent '$AGENT'" \
                --outcome "blocked" \
                --risk "High" 2>/dev/null || true
        else
            jq --arg a "$AGENT" --arg now "$NOW" \
                --argjson fc "$NEW_FAIL_COUNT" --argjson bo "$BACKOFF" \
                '.agents[$a].fail_count = $fc
                | .agents[$a].last_fail_ts = $now
                | .agents[$a].retry_backoff_s = $bo' \
                "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
            && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
            echo "[HOOK:CircuitUpdater] Agent '$AGENT' FAIL #${NEW_FAIL_COUNT} — backoff=${BACKOFF}s (still CLOSED)" >&2
        fi
        ;;

    HALF_OPEN)
        if [ "$NEW_FAIL_COUNT" -ge 4 ]; then
            REASON="4 consecutive failures: HALF_OPEN probe failed"
            jq --arg a "$AGENT" --arg now "$NOW" --arg reason "$REASON" \
                --argjson fc "$NEW_FAIL_COUNT" --argjson bo "$BACKOFF" \
                '.agents[$a].state = "OPEN"
                | .agents[$a].fail_count = $fc
                | .agents[$a].last_fail_ts = $now
                | .agents[$a].retry_backoff_s = $bo
                | .agents[$a].open_reason = $reason' \
                "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
            && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
            echo "[HOOK:CircuitUpdater] Agent '$AGENT' FAIL #${NEW_FAIL_COUNT} → HALF_OPEN → OPEN (circuit blown)" >&2
            bash scripts/ledger-append.sh \
                --agent "$AGENT" \
                --task-id "circuit-transition-${NOW}" \
                --request "Task agent '$AGENT' failed during HALF_OPEN probe" \
                --reasoning "4 consecutive failures: HALF_OPEN probe failed, circuit blown" \
                --choice "HALF_OPEN → OPEN for agent '$AGENT'" \
                --outcome "blocked" \
                --risk "High" 2>/dev/null || true
            FALLBACK=$(jq -r --arg a "$AGENT" '.agents[$a].fallback // "null"' "$CIRCUIT_FILE" 2>/dev/null)
            if [ "$FALLBACK" != "null" ] && [ -n "$FALLBACK" ]; then
                echo "[HOOK:CircuitUpdater] ⚠️  Route future '$AGENT' tasks to fallback: '$FALLBACK'" >&2
            else
                echo "[HOOK:CircuitUpdater] ⚠️  No fallback for '$AGENT' — surface to user." >&2
            fi
        else
            jq --arg a "$AGENT" --arg now "$NOW" \
                --argjson fc "$NEW_FAIL_COUNT" --argjson bo "$BACKOFF" \
                '.agents[$a].fail_count = $fc
                | .agents[$a].last_fail_ts = $now
                | .agents[$a].retry_backoff_s = $bo' \
                "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
            && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
            echo "[HOOK:CircuitUpdater] Agent '$AGENT' FAIL #${NEW_FAIL_COUNT} — still HALF_OPEN, backoff=${BACKOFF}s" >&2
        fi
        ;;

    OPEN)
        jq --arg a "$AGENT" --arg now "$NOW" \
            '.agents[$a].last_fail_ts = $now' \
            "$CIRCUIT_FILE" > "${CIRCUIT_FILE}.tmp" 2>/dev/null \
        && mv "${CIRCUIT_FILE}.tmp" "$CIRCUIT_FILE" 2>/dev/null
        echo "[HOOK:CircuitUpdater] Agent '$AGENT' FAIL — circuit already OPEN, timestamp refreshed." >&2
        ;;

    *)
        echo "[HOOK:CircuitUpdater] WARNING: Unknown state '$STATE' for agent '$AGENT'. No update." >&2
        ;;
esac

exit 0
