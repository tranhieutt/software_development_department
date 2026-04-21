#!/usr/bin/env bash
# ledger-append.sh — Append 1 decision entry vào production/traces/decision_ledger.jsonl
# Schema: coordination-rules.md Rule 15 (ledger/v1)
#
# Usage:
#   bash scripts/ledger-append.sh \
#       --agent <agent-id> \
#       --task-id <task-id> \
#       --choice "<decision made>" \
#       --outcome <pass|fail|blocked|skipped> \
#       --risk <High|Medium|Low> \
#       [--request "<what was asked>"] \
#       [--reasoning "<why this choice>"] \
#       [--duration-s <N>] \
#       [--ts <ISO8601>]      # override timestamp (default: now UTC)
#       [--session <name>]    # override session (default: git branch)
#
# Exit codes:
#   0 = appended OK
#   1 = invalid args (missing required, bad outcome/risk value)
#   2 = jq missing (fail-open per Rule 9 — warning to stderr, no append)
#
# Concurrency: uses O_APPEND via `>>`. Safe for writes < PIPE_BUF (~4KB) which
# covers any realistic ledger line. For parallel hook calls writing >4KB lines,
# wrap caller with flock if available.

set -euo pipefail

LEDGER_FILE="production/traces/decision_ledger.jsonl"

# ─── Defaults (auto-populated) ───────────────────────────────────────────────
TS=""
SESSION=""
AGENT=""
TASK_ID=""
REQUEST=""
REASONING=""
CHOICE=""
OUTCOME=""
RISK=""
DURATION_S=0

# ─── Parse args ──────────────────────────────────────────────────────────────
while [ $# -gt 0 ]; do
    case "$1" in
        --ts)         TS="$2"; shift 2 ;;
        --session)    SESSION="$2"; shift 2 ;;
        --agent)      AGENT="$2"; shift 2 ;;
        --task-id)    TASK_ID="$2"; shift 2 ;;
        --request)    REQUEST="$2"; shift 2 ;;
        --reasoning)  REASONING="$2"; shift 2 ;;
        --choice)     CHOICE="$2"; shift 2 ;;
        --outcome)    OUTCOME="$2"; shift 2 ;;
        --risk)       RISK="$2"; shift 2 ;;
        --duration-s) DURATION_S="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,25p' "$0"; exit 0 ;;
        *)
            echo "[ledger-append] ERROR: unknown arg: $1" >&2
            exit 1 ;;
    esac
done

# ─── Detect JSON tool (prefer jq, fallback to node) ──────────────────────────
# Fail-open per Rule 9: if neither available, warn and skip (don't block caller).
JSON_TOOL=""
if command -v jq >/dev/null 2>&1; then
    JSON_TOOL="jq"
elif command -v node >/dev/null 2>&1; then
    JSON_TOOL="node"
else
    echo "[ledger-append] WARNING: neither jq nor node found; ledger entry skipped (fail-open)." >&2
    exit 2
fi

# ─── Validate required fields ────────────────────────────────────────────────
missing=()
[ -z "$AGENT" ]    && missing+=("--agent")
[ -z "$TASK_ID" ]  && missing+=("--task-id")
[ -z "$CHOICE" ]   && missing+=("--choice")
[ -z "$OUTCOME" ]  && missing+=("--outcome")
[ -z "$RISK" ]     && missing+=("--risk")

if [ ${#missing[@]} -gt 0 ]; then
    echo "[ledger-append] ERROR: missing required args: ${missing[*]}" >&2
    exit 1
fi

# ─── Validate enum values ────────────────────────────────────────────────────
case "$OUTCOME" in
    pass|fail|blocked|skipped) ;;
    *) echo "[ledger-append] ERROR: --outcome must be one of pass|fail|blocked|skipped (got: $OUTCOME)" >&2; exit 1 ;;
esac

case "$RISK" in
    High|Medium|Low) ;;
    *) echo "[ledger-append] ERROR: --risk must be one of High|Medium|Low (got: $RISK)" >&2; exit 1 ;;
esac

# ─── Auto-populate ts and session ────────────────────────────────────────────
if [ -z "$TS" ]; then
    # ISO8601 UTC with seconds precision (portable across GNU/BSD date)
    TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
fi

if [ -z "$SESSION" ]; then
    SESSION="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')"
fi

# ─── Ensure ledger file & dir exist ──────────────────────────────────────────
mkdir -p "$(dirname "$LEDGER_FILE")"
[ -f "$LEDGER_FILE" ] || : > "$LEDGER_FILE"

# ─── Build JSON line (safe escaping) ─────────────────────────────────────────
if [ "$JSON_TOOL" = "jq" ]; then
    LINE="$(jq -cn \
        --arg schema "ledger/v1" \
        --arg ts "$TS" \
        --arg session "$SESSION" \
        --arg agent_id "$AGENT" \
        --arg task_id "$TASK_ID" \
        --arg request "$REQUEST" \
        --arg reasoning "$REASONING" \
        --arg choice "$CHOICE" \
        --arg outcome "$OUTCOME" \
        --arg risk_tier "$RISK" \
        --argjson duration_s "${DURATION_S:-0}" \
        '{schema:$schema, ts:$ts, session:$session, agent_id:$agent_id, task_id:$task_id, request:$request, reasoning:$reasoning, choice:$choice, outcome:$outcome, risk_tier:$risk_tier, duration_s:$duration_s}')"
else
    # Node fallback — pass values via env to avoid arg-escaping pitfalls.
    LINE="$(
        LA_SCHEMA="ledger/v1" \
        LA_TS="$TS" LA_SESSION="$SESSION" \
        LA_AGENT="$AGENT" LA_TASK="$TASK_ID" \
        LA_REQ="$REQUEST" LA_REASON="$REASONING" \
        LA_CHOICE="$CHOICE" LA_OUTCOME="$OUTCOME" \
        LA_RISK="$RISK" LA_DUR="${DURATION_S:-0}" \
        node -e '
            const o = {
                schema: process.env.LA_SCHEMA,
                ts: process.env.LA_TS,
                session: process.env.LA_SESSION,
                agent_id: process.env.LA_AGENT,
                task_id: process.env.LA_TASK,
                request: process.env.LA_REQ,
                reasoning: process.env.LA_REASON,
                choice: process.env.LA_CHOICE,
                outcome: process.env.LA_OUTCOME,
                risk_tier: process.env.LA_RISK,
                duration_s: Number(process.env.LA_DUR) || 0
            };
            process.stdout.write(JSON.stringify(o));
        '
    )"
fi

# ─── Atomic append (O_APPEND is atomic for <PIPE_BUF writes) ─────────────────
printf '%s\n' "$LINE" >> "$LEDGER_FILE"

exit 0
