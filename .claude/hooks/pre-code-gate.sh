#!/bin/bash
# Claude Code PreToolUse hook: SDD pre-code gate — Ground Truth enforcement
# Fires on Write|Edit for implementation-like files.
#
# Behavior:
#   Simple task  → pass-through (agent declared Assumption Log, user confirmed)
#   Medium/Complex → BLOCK if no approved spec file found, or spec missing
#                    required Ground Truth sections (Data Model, Business Rules,
#                    Acceptance Criteria, Out-of-Scope)
#
# Input schema (PreToolUse for Write/Edit):
# { "tool_name": "Write|Edit", "tool_input": { "file_path": "...", ... } }

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

FILE_PATH=${FILE_PATH//\\//}

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# ── Skip non-production paths ────────────────────────────────────────────────
# Docs, skills, and hook files have their own review workflows.
case "$FILE_PATH" in
    *.md|*.mdx|docs/*|*/docs/*|.claude/skills/*|.claude/hooks/*|.claude/memory/*)
        exit 0
        ;;
esac

# RED test files are governed by the TDD skill — skip gate here.
if echo "$FILE_PATH" | grep -qiE '(^|/)(tests?|__tests__|specs?)/|(\.test|\.spec)\.(js|jsx|ts|tsx|py|go|rs|java|cs)$'; then
    exit 0
fi

# ── Only enforce on implementation-like files ────────────────────────────────
IS_IMPL=$(echo "$FILE_PATH" | grep -ciE '(^|/)(src|app|lib|services|components|pages|packages|scripts|infra|infrastructure|migrations|landing-page)/|(\.js|\.jsx|\.ts|\.tsx|\.py|\.go|\.rs|\.java|\.cs|\.php|\.rb|\.sh|\.ps1|\.sql|\.html|\.css|\.scss)$')

if [ "$IS_IMPL" -eq 0 ]; then
    exit 0
fi

# ── Ground Truth Gate check ──────────────────────────────────────────────────
# Look for an approved spec file in design/specs/ or .tasks/.
# A spec is considered present if any .md file in those dirs contains all four
# required Ground Truth section headings.

SPEC_FOUND=0
MISSING_SECTIONS=""

check_spec_file() {
    local f="$1"
    local has_data_model has_business_rules has_acceptance has_out_of_scope
    has_data_model=$(grep -ci '## Data Model' "$f" 2>/dev/null || echo 0)
    has_business_rules=$(grep -ci '## Business Rules' "$f" 2>/dev/null || echo 0)
    has_acceptance=$(grep -ci '## Acceptance Criteria\|Given.*When.*Then\|AC-[0-9]' "$f" 2>/dev/null || echo 0)
    has_out_of_scope=$(grep -ci 'Out of scope\|Out-of-scope\|## Out' "$f" 2>/dev/null || echo 0)

    local missing=""
    [ "$has_data_model" -eq 0 ]    && missing="${missing} [Data Model]"
    [ "$has_business_rules" -eq 0 ] && missing="${missing} [Business Rules]"
    [ "$has_acceptance" -eq 0 ]    && missing="${missing} [Acceptance Criteria]"
    [ "$has_out_of_scope" -eq 0 ]  && missing="${missing} [Out-of-Scope]"

    if [ -z "$missing" ]; then
        SPEC_FOUND=1
    else
        MISSING_SECTIONS="$missing"
    fi
}

# Search design/specs/ then .tasks/ for spec files
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

for dir in "$REPO_ROOT/design/specs" "$REPO_ROOT/.tasks"; do
    if [ -d "$dir" ]; then
        while IFS= read -r spec_file; do
            check_spec_file "$spec_file"
            [ "$SPEC_FOUND" -eq 1 ] && break 2
        done < <(find "$dir" -name "*.md" -newer "$REPO_ROOT/.claude/hooks/pre-code-gate.sh" 2>/dev/null | head -5)
    fi
done

# ── Gate decision ────────────────────────────────────────────────────────────
if [ "$SPEC_FOUND" -eq 1 ]; then
    # Approved spec with all Ground Truth sections exists — allow.
    exit 0
fi

# No valid spec found. Determine message based on whether a spec exists but is incomplete.
if [ -n "$MISSING_SECTIONS" ]; then
    cat >&2 <<EOF
╔══ SDD Ground Truth Gate: BLOCKED ══════════════════════════════════════════╗
║  File: $FILE_PATH
║
║  A spec file was found but is missing required Ground Truth sections:
║    $MISSING_SECTIONS
║
║  Complete these sections in design/specs/ before writing implementation code.
║  See: .claude/skills/spec-driven-development/SKILL.md → Ground Truth Gate
╚════════════════════════════════════════════════════════════════════════════╝
EOF
else
    cat >&2 <<EOF
╔══ SDD Ground Truth Gate: BLOCKED ══════════════════════════════════════════╗
║  File: $FILE_PATH
║
║  No approved spec found in design/specs/ or .tasks/.
║
║  For Medium/Complex tasks, create a spec with all four Ground Truth sections
║  before writing implementation code:
║    □ ## Data Model      — entities, fields, types, constraints
║    □ ## Business Rules  — if/then/else conditions (no vague language)
║    □ ## Acceptance Criteria — Given/When/Then (independently testable)
║    □ Out-of-Scope       — what this feature does NOT do
║
║  For Simple tasks (1 file, unambiguous intent), state the Assumption Log
║  (≤ 3 items) and get user confirmation — no spec file required.
║
║  See: .claude/skills/spec-driven-development/SKILL.md
╚════════════════════════════════════════════════════════════════════════════╝
EOF
fi

exit 2

