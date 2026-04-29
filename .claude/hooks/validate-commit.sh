#!/bin/bash
# Claude Code PreToolUse hook: Validates git commit commands
# Receives JSON on stdin with tool_input.command
# Exit 0 = allow, Exit 2 = block (stderr shown to Claude)
#
# Input schema (PreToolUse for Bash):
# { "tool_name": "Bash", "tool_input": { "command": "git commit -m ..." } }

INPUT=$(cat)

# ─── REQUIRE jq ─────────────────────────────────────────────────────────────
# Regex fallback is a bypass vector for commands with quotes or escape sequences.
if ! command -v jq >/dev/null 2>&1; then
    echo "[HOOK:ValidateCommit] ERROR: jq is required but not installed. Install jq to proceed." >&2
    exit 1
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# ─── M2 FIX: Self-timeout guard (25s < 30s Claude Code hook timeout) ─────────
# Makes fail-open explicit and visible instead of a silent SIGKILL bypass.
SELF_PID=$$
(sleep 25 && kill -TERM "$SELF_PID" 2>/dev/null) &
WATCHDOG_PID=$!
trap 'echo "[HOOK:ValidateCommit] WARN: Validation timed out (25s) — commit allowed (fail-open). Consider splitting large commits or increasing timeout." >&2; kill "$WATCHDOG_PID" 2>/dev/null; exit 0' TERM
trap 'kill "$WATCHDOG_PID" 2>/dev/null' EXIT

# Only process git commit commands
if ! echo "$COMMAND" | grep -qE '^git[[:space:]]+commit'; then
    exit 0
fi

# Get staged files
STAGED=$(git diff --cached --name-only 2>/dev/null)
if [ -z "$STAGED" ]; then
    exit 0
fi

WARNINGS=""

# Returns 0 when file starts with YAML frontmatter block, otherwise 1.
has_frontmatter() {
    local file="$1"
    [ -f "$file" ] || return 1
    local first_line
    first_line=$(head -n 1 "$file" 2>/dev/null)
    [ "$first_line" = "---" ] || return 1
    awk 'NR>1 { if ($0=="---") { found=1; exit } } END { exit found?0:1 }' "$file"
}

# Check design documents for required sections
DESIGN_FILES=$(echo "$STAGED" | grep -E '^design/specs/')
if [ -n "$DESIGN_FILES" ]; then
    while IFS= read -r file; do
        if [[ "$file" == *.md ]] && [ -f "$file" ]; then
            if ! has_frontmatter "$file"; then
                echo "BLOCKED: $file missing YAML frontmatter. Add frontmatter with stage, tier, spec_id before commit." >&2
                exit 2
            fi

            FRONTMATTER=$(awk 'BEGIN{in=0} NR==1 && $0=="---" {in=1; next} in==1 && $0=="---" {exit} in==1 {print}' "$file")
            for key in stage tier spec_id; do
                if ! echo "$FRONTMATTER" | grep -qiE "^[[:space:]]*$key[[:space:]]*:[[:space:]]*.+"; then
                    echo "BLOCKED: $file frontmatter missing required field '$key'." >&2
                    exit 2
                fi
            done

            for bdd in "Given" "When" "Then"; do
                if ! grep -qiE "^[[:space:]]*[-*]?[[:space:]]*$bdd\b" "$file"; then
                    echo "BLOCKED: $file missing BDD keyword '$bdd' in acceptance criteria." >&2
                    exit 2
                fi
            done

            for section in "Overview" "User Value" "Detailed" "Formulas" "Edge Cases" "Dependencies" "Configuration" "Acceptance Criteria"; do
                if ! grep -qi "$section" "$file"; then
                    WARNINGS="$WARNINGS\nDESIGN: $file missing required section: $section"
                fi
            done
        fi
    done <<< "$DESIGN_FILES"
fi

# Validate JSON data files -- block invalid JSON
DATA_FILES=$(echo "$STAGED" | grep -E '^assets/data/.*\.json$')
if [ -n "$DATA_FILES" ]; then
    # Find a working Python command
    PYTHON_CMD=""
    for cmd in python python3 py; do
        if command -v "$cmd" >/dev/null 2>&1; then
            PYTHON_CMD="$cmd"
            break
        fi
    done

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if [ -n "$PYTHON_CMD" ]; then
                if ! "$PYTHON_CMD" -m json.tool "$file" > /dev/null 2>&1; then
                    echo "BLOCKED: $file is not valid JSON" >&2
                    exit 2
                fi
            else
                echo "WARNING: Cannot validate JSON (python not found): $file" >&2
            fi
        fi
    done <<< "$DATA_FILES"
fi

# Check for hardcoded magic numbers in source code
# Uses grep -E (POSIX extended) instead of grep -P (Perl) for cross-platform compatibility
CODE_FILES=$(echo "$STAGED" | grep -E '^src/')
if [ -n "$CODE_FILES" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if grep -nE '[[:space:]]=[[:space:]]*[0-9]{4,}' "$file" 2>/dev/null; then
                WARNINGS="$WARNINGS\nCODE: $file may contain hardcoded magic numbers. Use config files."
            fi
        fi
    done <<< "$CODE_FILES"
fi

# Check for TODO/FIXME without assignee -- uses grep -E instead of grep -P
SRC_FILES=$(echo "$STAGED" | grep -E '^src/')
if [ -n "$SRC_FILES" ]; then
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if grep -nE '(TODO|FIXME|HACK)[^(]' "$file" 2>/dev/null; then
                WARNINGS="$WARNINGS\nSTYLE: $file has TODO/FIXME without owner tag. Use TODO(name) format."
            fi
        fi
    done <<< "$SRC_FILES"
fi

# ─── Auto-lint: ruff check on staged Python files ────────────────────────────
PY_FILES=$(echo "$STAGED" | grep -E '\.py$')
if [ -n "$PY_FILES" ]; then
    PYTHON_CMD=""
    for cmd in python python3 py; do
        if command -v "$cmd" >/dev/null 2>&1; then
            PYTHON_CMD="$cmd"
            break
        fi
    done

    RUFF_AVAILABLE=false
    run_ruff() {
        return 127
    }

    if command -v ruff >/dev/null 2>&1; then
        RUFF_AVAILABLE=true
        run_ruff() {
            ruff "$@"
        }
    elif [ -n "$PYTHON_CMD" ] && "$PYTHON_CMD" -m ruff --version >/dev/null 2>&1; then
        RUFF_AVAILABLE=true
        run_ruff() {
            "$PYTHON_CMD" -m ruff "$@"
        }
    fi

    if [ "$RUFF_AVAILABLE" = true ]; then
        LINT_OUTPUT=""
        while IFS= read -r pyfile; do
            [ -f "$pyfile" ] || continue
            RESULT=$(run_ruff check "$pyfile" 2>&1)
            if [ -n "$RESULT" ]; then
                LINT_OUTPUT="$LINT_OUTPUT\n  $pyfile:\n$(echo "$RESULT" | head -5 | sed 's/^/    /')"
            fi
        done <<< "$PY_FILES"

        if [ -n "$LINT_OUTPUT" ]; then
            WARNINGS="$WARNINGS\nLINT: ruff found issues in staged Python files:$LINT_OUTPUT"
        fi
    fi
fi

# Print warnings (non-blocking) and allow commit
if [ -n "$WARNINGS" ]; then
    echo -e "=== Commit Validation Warnings ===$WARNINGS\n================================" >&2
fi
# exit 0  # REWARD: Removed to allow GitNexus check to run

# --- GitNexus: pre-commit blast-radius check ---
if command -v npx >/dev/null 2>&1; then
    GN_STATUS=$(npx --no gitnexus status 2>/dev/null | grep -iE "indexed|up.to.date" | head -1)
    if [ -n "$GN_STATUS" ]; then
        BLAST=$(npx --no gitnexus detect-changes --scope staged --format json 2>/dev/null)
        if [ -n "$BLAST" ]; then
            RISK=$(echo "$BLAST" | grep -oE '"risk"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"risk"[[:space:]]*:[[:space:]]*"//;s/"$//')
            PROCS=$(echo "$BLAST" | grep -oE '"affectedProcessCount"[[:space:]]*:[[:space:]]*[0-9]+' | head -1 | grep -oE '[0-9]+')
            if [ -n "$RISK" ]; then
                echo "" >&2
                echo "=== GitNexus Blast Radius ===" >&2
                echo "Risk level : $RISK" >&2
                [ -n "$PROCS" ] && echo "Affected flows: $PROCS" >&2
                if echo "$RISK" | grep -qiE "^(HIGH|CRITICAL)$"; then
                    echo "WARNING: $RISK risk — run /gitnexus-impact-analysis before merging." >&2
                fi
                echo "=============================" >&2
            fi
        fi
    fi
fi
