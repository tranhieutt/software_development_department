#!/bin/bash
# Claude Code PreToolUse hook: SDD pre-code gate reminder
# Fires on Write|Edit for implementation-like files. Warns only.
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

# Non-production documentation and skill edits are governed by their own review
# workflows, not the implementation pre-code gate.
case "$FILE_PATH" in
    *.md|*.mdx|docs/*|*/docs/*|.claude/skills/*)
        exit 0
        ;;
esac

# RED tests are part of TDD execution. They still need an approved gate, but the
# TDD skill carries the enforcement details, so keep this reminder focused on
# production-like edits.
if echo "$FILE_PATH" | grep -qiE '(^|/)(tests?|__tests__|specs?)/|(\.test|\.spec)\.(js|jsx|ts|tsx|py|go|rs|java|cs)$'; then
    exit 0
fi

if echo "$FILE_PATH" | grep -qiE '(^|/)(src|app|lib|services|components|pages|packages|scripts|infra|infrastructure|migrations|landing-page|\.claude/hooks)/|(\.js|\.jsx|\.ts|\.tsx|\.py|\.go|\.rs|\.java|\.cs|\.php|\.rb|\.sh|\.ps1|\.sql|\.html|\.css|\.scss|\.json|\.ya?ml)$'; then
    echo "SDD Pre-Code Gate: before editing '$FILE_PATH', state the satisfied gate from .claude/skills/using-sdd/SKILL.md and the verification command/check." >&2
fi

exit 0

