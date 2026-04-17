#!/bin/bash
# Claude Code PreToolUse hook: Validates git commit commands
# Receives JSON on stdin with tool_input.command
# Exit 0 = allow, Exit 2 = block (stderr shown to Claude)
#
# Input schema (PreToolUse for Bash):
# { "tool_name": "Bash", "tool_input": { "command": "git commit -m ..." } }

INPUT=$(cat)

# Parse command -- use jq if available, fall back to grep
if command -v jq >/dev/null 2>&1; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
else
    COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

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

# Check design documents for required sections
DESIGN_FILES=$(echo "$STAGED" | grep -E '^design/specs/')
if [ -n "$DESIGN_FILES" ]; then
    while IFS= read -r file; do
        if [[ "$file" == *.md ]] && [ -f "$file" ]; then
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
    if command -v ruff >/dev/null 2>&1; then
        RUFF_AVAILABLE=true
    elif [ -n "$PYTHON_CMD" ] && "$PYTHON_CMD" -m ruff --version >/dev/null 2>&1; then
        RUFF_AVAILABLE=true
        alias ruff="$PYTHON_CMD -m ruff"
    fi

    if [ "$RUFF_AVAILABLE" = true ]; then
        LINT_OUTPUT=""
        while IFS= read -r pyfile; do
            [ -f "$pyfile" ] || continue
            RESULT=$(ruff check "$pyfile" 2>&1)
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
