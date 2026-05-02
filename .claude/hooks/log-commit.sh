#!/bin/bash
# Claude Code PostToolUse hook: Log git commits to decision ledger
# Fires after Bash tool completes. Matches `git commit` commands only.
# Appends 1 entry to production/traces/decision_ledger.jsonl per Rule 15.
#
# Input schema (PostToolUse for Bash):
# { "tool_name": "Bash",
#   "tool_input":    { "command": "git commit -m ..." },
#   "tool_response": { "exit_code": 0, "stdout": "...", "stderr": "..." } }
#
# Fail-open: any error in this hook exits 0 silently — ledger writes must
# never block or surface noise to the user (Rule 9).

set -u
_HOOK_ERR_LOG="production/session-logs/hook-errors.log"
mkdir -p "$(dirname "$_HOOK_ERR_LOG")" 2>/dev/null
exec 2>>"$_HOOK_ERR_LOG"  # redirect stderr to log file instead of /dev/null

INPUT=$(cat)

# ─── Detect JSON tool (jq preferred, node fallback) ──────────────────────────
if command -v jq >/dev/null 2>&1; then
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_response.exit_code // 0')
elif command -v node >/dev/null 2>&1; then
    read_json() {
        node -e "
            let d=''; process.stdin.on('data',c=>d+=c).on('end',()=>{
                try { const o=JSON.parse(d); const p='$1'.split('.').slice(1);
                    let v=o; for(const k of p) v = v && v[k];
                    process.stdout.write(v==null?'':String(v));
                } catch(e){}
            });
        " <<< "$INPUT"
    }
    CMD=$(read_json '.tool_input.command')
    EXIT_CODE=$(read_json '.tool_response.exit_code')
    [ -z "$EXIT_CODE" ] && EXIT_CODE=0
else
    exit 0  # no parser, silent skip
fi

# ─── Only process git commit ─────────────────────────────────────────────────
case "$CMD" in
    "git commit"*|*" git commit"*) ;;
    *) exit 0 ;;
esac

# ─── Gather commit info ──────────────────────────────────────────────────────
SHA=$(git log -1 --format='%h' 2>/dev/null)
SUBJECT=$(git log -1 --format='%s' 2>/dev/null)
FILES=$(git log -1 --name-only --format='' 2>/dev/null)
FILE_COUNT=$(echo "$FILES" | grep -c . || echo 0)

[ -z "$SHA" ] && exit 0  # no commit to log

# ─── Classify risk from file patterns ────────────────────────────────────────
RISK="Medium"  # default

# High-risk patterns: anything that changes agent behavior or security surface
if echo "$FILES" | grep -qE '^(\.claude/hooks/|\.claude/agents/|\.claude/settings|src/auth/|migrations/|infra/|scripts/)' ; then
    RISK="High"
# Low-risk patterns: docs-only changes
elif ! echo "$FILES" | grep -qvE '^(docs/|README|CHANGELOG|\.md$|^$)' ; then
    # Every file matched the low-risk allowlist (grep -v found nothing that didn't match)
    RISK="Low"
fi

# ─── Determine outcome from exit code ────────────────────────────────────────
if [ "$EXIT_CODE" = "0" ]; then
    OUTCOME="pass"
else
    OUTCOME="fail"
fi

# ─── Append ledger entry (fail-open) ─────────────────────────────────────────
bash scripts/ledger-append.sh \
    --agent "git-commit" \
    --task-id "commit-$SHA" \
    --request "git commit (${FILE_COUNT} files)" \
    --reasoning "Committed via Bash tool by current session" \
    --choice "$SUBJECT" \
    --outcome "$OUTCOME" \
    --risk "$RISK" \
    >/dev/null 2>&1

exit 0
