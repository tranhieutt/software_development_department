#!/bin/bash
# Claude Code PostToolUse hook: Decision Ledger Writer (UFSM Phase 2)
# Appends a decision entry to production/traces/decision_ledger.jsonl
# for every Task tool invocation, per ADR-004 and coordination-rules Rule 15.
#
# Event: PostToolUse (matcher: Task)
# Input (stdin): {
#   "tool_name": "Task",
#   "tool_input":    { "description": "...", "prompt": "..." },
#   "tool_response": { "exit_code": 0|1|2, "output": "..." }
# }
#
# Schema: ledger/v1 (matches ledger-append.sh output format)
# Risk classification:
#   exit_code 0  → outcome "pass"
#   exit_code 2  → outcome "blocked"
#   exit_code != 0,2 → outcome "fail"
#
# Fail-open per Rule 9 — always exit 0, never block caller.

INPUT=$(cat)

# ─── Require jq (fail-open) ──────────────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
    exit 0
fi

# Only handle Task tool
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
if [ "$TOOL_NAME" != "Task" ]; then
    exit 0
fi

LEDGER_FILE="production/traces/decision_ledger.jsonl"
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
SESSION=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# ─── Extract fields from hook input ─────────────────────────────────────────
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_response.exit_code // 0' 2>/dev/null)
TASK_DESCRIPTION=$(echo "$INPUT" | jq -r '.tool_input.description // ""' 2>/dev/null)
TASK_PROMPT=$(echo "$INPUT" | jq -r '.tool_input.prompt // ""' 2>/dev/null)
TASK_OUTPUT=$(echo "$INPUT" | jq -r '.tool_response.output // ""' 2>/dev/null)

# Build a stable task_id from session + short hash of description
TASK_HASH=$(echo "${TASK_DESCRIPTION}${NOW}" | head -c 64 | \
    { command -v sha256sum >/dev/null 2>&1 && sha256sum || \
      command -v shasum   >/dev/null 2>&1 && shasum -a 256; } 2>/dev/null | \
    cut -c1-8)
TASK_HASH="${TASK_HASH:-$(date +%s | tail -c 8)}"
TASK_ID="task-${SESSION}-${TASK_HASH}"

# ─── Outcome classification ───────────────────────────────────────────────────
case "$EXIT_CODE" in
    0)  OUTCOME="pass" ;;
    2)  OUTCOME="blocked" ;;
    *)  OUTCOME="fail" ;;
esac

# ─── Risk classification from task content ────────────────────────────────────
# Mirror the same logic used in log-commit.sh
RISK="Medium"  # default
COMBINED_TEXT="${TASK_DESCRIPTION}${TASK_PROMPT}"

# High risk: touches sensitive infrastructure, auth, migrations, scripts
if echo "$COMBINED_TEXT" | grep -qiE \
    '(auth|security|secret|migration|database schema|infra|production|deploy|circuit|hooks?|settings\.json|rm -rf|credentials)'; then
    RISK="High"
# Low risk: documentation-only tasks
elif echo "$COMBINED_TEXT" | grep -qiE \
    '^(docs?|readme|changelog|explain|describe|summarize|analysis|report)'; then
    RISK="Low"
fi

# ─── Build request / reasoning / choice fields ────────────────────────────────
REQUEST=$(echo "$TASK_DESCRIPTION" | head -c 200)
[ -z "$REQUEST" ] && REQUEST="(no description provided)"

# Extract first meaningful line of output as the "choice" made
CHOICE=$(echo "$TASK_OUTPUT" | grep -v '^$' | head -1 | head -c 200)
[ -z "$CHOICE" ] && CHOICE="Task completed with exit_code=${EXIT_CODE}"

REASONING="Auto-logged by decision-ledger-writer.sh (PostToolUse hook) — agent_id derived from session context"

# ─── Ensure ledger file exists ───────────────────────────────────────────────
mkdir -p "$(dirname "$LEDGER_FILE")" 2>/dev/null
[ -f "$LEDGER_FILE" ] || : > "$LEDGER_FILE"

# ─── Build JSON line and append ──────────────────────────────────────────────
LINE=$(jq -cn \
    --arg schema     "ledger/v1" \
    --arg ts         "$NOW" \
    --arg session    "$SESSION" \
    --arg agent_id   "task-agent" \
    --arg task_id    "$TASK_ID" \
    --arg request    "$REQUEST" \
    --arg reasoning  "$REASONING" \
    --arg choice     "$CHOICE" \
    --arg outcome    "$OUTCOME" \
    --arg risk_tier  "$RISK" \
    --argjson exit_code "${EXIT_CODE:-0}" \
    '{
        schema:     $schema,
        ts:         $ts,
        session:    $session,
        agent_id:   $agent_id,
        task_id:    $task_id,
        request:    $request,
        reasoning:  $reasoning,
        choice:     $choice,
        outcome:    $outcome,
        risk_tier:  $risk_tier,
        exit_code:  $exit_code
    }' 2>/dev/null)

if [ -n "$LINE" ]; then
    printf '%s\n' "$LINE" >> "$LEDGER_FILE"
fi

exit 0
