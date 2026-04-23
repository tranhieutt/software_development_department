#!/usr/bin/env bash
set -u

FAILURES=0
WARNINGS=0

section() {
  printf '\n== %s ==\n' "$1"
}

ok() {
  printf 'OK    %s\n' "$1"
}

warn() {
  WARNINGS=$((WARNINGS + 1))
  printf 'WARN  %s\n' "$1"
}

fail() {
  FAILURES=$((FAILURES + 1))
  printf 'FAIL  %s\n' "$1"
}

run_checked() {
  label="$1"
  shift
  printf '\n> %s\n' "$*"
  "$@"
  exit_code=$?
  if [ "$exit_code" -ne 0 ]; then
    fail "$label failed with exit code $exit_code"
  else
    ok "$label passed"
  fi
}

SKIP_SKILL_VALIDATION=0
SKIP_HARNESS_AUDIT=0
SKIP_TRACE_CHECK=0

for arg in "$@"; do
  case "$arg" in
    --skip-skill-validation) SKIP_SKILL_VALIDATION=1 ;;
    --skip-harness-audit) SKIP_HARNESS_AUDIT=1 ;;
    --skip-trace-check) SKIP_TRACE_CHECK=1 ;;
    *)
      fail "unknown argument: $arg"
      ;;
  esac
done

printf 'SDD Codex Preflight\n'
printf 'Root: %s\n' "$(pwd)"

section "Required Files"
required_files=(
  "AGENTS.md"
  "CLAUDE.md"
  ".codex/INSTALL.md"
  "docs/codex-compatibility.md"
  "docs/technical/SDD_LIFECYCLE_MAP.md"
  ".claude/settings.json"
  ".claude/skills/using-sdd/SKILL.md"
  ".claude/skills/codex-sdd/SKILL.md"
  "scripts/validate-skills.sh"
  "scripts/harness-audit.js"
)

for path in "${required_files[@]}"; do
  if [ -e "$path" ]; then
    ok "found $path"
  else
    fail "missing $path"
  fi
done

section "Git Status"
if command -v git >/dev/null 2>&1; then
  git_status="$(git status --short 2>/tmp/sdd-codex-git-status.err)"
  git_exit=$?
  if [ "$git_exit" -ne 0 ]; then
    warn "git status returned exit code $git_exit"
    sed 's/^/      /' /tmp/sdd-codex-git-status.err 2>/dev/null || true
  elif [ -n "$git_status" ]; then
    warn "working tree has uncommitted changes"
    printf '%s\n' "$git_status" | sed 's/^/      /'
  else
    ok "working tree clean"
  fi
else
  warn "git unavailable"
fi

section "Circuit State"
if [ -f ".claude/memory/circuit-state.json" ]; then
  if command -v node >/dev/null 2>&1; then
    node -e "const fs=require('fs');const s=JSON.parse(fs.readFileSync('.claude/memory/circuit-state.json','utf8'));if(s._version!==2||!s.agents)process.exit(2);" >/dev/null 2>&1
    circuit_exit=$?
    if [ "$circuit_exit" -eq 0 ]; then
      ok "circuit-state.json schema v2 readable"
    else
      fail "circuit-state.json does not match schema v2"
    fi
  else
    warn "node unavailable; cannot parse circuit-state.json"
  fi
else
  fail "missing .claude/memory/circuit-state.json"
fi

if [ "$SKIP_SKILL_VALIDATION" -eq 0 ]; then
  section "Skill Validation"
  run_checked "skill validation" bash scripts/validate-skills.sh
fi

if [ "$SKIP_HARNESS_AUDIT" -eq 0 ]; then
  section "Harness Audit"
  run_checked "harness audit" node scripts/harness-audit.js --compact
fi

if [ "$SKIP_TRACE_CHECK" -eq 0 ]; then
  section "Trace Integrity"
  if [ -f "scripts/trace-integrity-check.js" ]; then
    run_checked "trace integrity" node scripts/trace-integrity-check.js
  else
    warn "trace integrity script not found"
  fi
fi

section "Summary"
printf 'Failures: %s\n' "$FAILURES"
printf 'Warnings: %s\n' "$WARNINGS"

if [ "$FAILURES" -gt 0 ]; then
  printf '\nPreflight failed. Fix failures before claiming Codex/SDD readiness.\n'
  exit 1
fi

printf '\nPreflight passed. Review warnings before risky edits or completion claims.\n'
exit 0
