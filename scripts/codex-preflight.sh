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
SKIP_README_SYNC=0
SKIP_TRACE_CHECK=0
INSTALL_MODE="auto"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-skill-validation) SKIP_SKILL_VALIDATION=1 ;;
    --skip-harness-audit) SKIP_HARNESS_AUDIT=1 ;;
    --skip-readme-sync) SKIP_README_SYNC=1 ;;
    --skip-trace-check) SKIP_TRACE_CHECK=1 ;;
    --install-mode)
      shift
      case "${1:-}" in
        auto|product|sdd-dev) INSTALL_MODE="$1" ;;
        *)
          fail "invalid --install-mode: ${1:-}"
          ;;
      esac
      ;;
    *)
      fail "unknown argument: $1"
      ;;
  esac
  shift
done

detect_install_mode() {
  if [ "$INSTALL_MODE" != "auto" ]; then
    printf '%s\n' "$INSTALL_MODE"
    return
  fi

  if [ -f ".sdd/install.json" ] && command -v node >/dev/null 2>&1; then
    marker_mode="$(node -e "const fs=require('fs');try{const m=JSON.parse(fs.readFileSync('.sdd/install.json','utf8'));if(m.installMode==='Product')console.log('product');else if(m.installMode==='SddDev')console.log('sdd-dev');}catch(e){process.exit(0)}" 2>/dev/null)"
    if [ "$marker_mode" = "product" ] || [ "$marker_mode" = "sdd-dev" ]; then
      printf '%s\n' "$marker_mode"
      return
    fi
  fi

  if [ -f "README_vn.md" ] &&
     [ -f "scripts/validate-readme-sync.js" ] &&
     [ -d "docs/internal/adr" ] &&
     [ -f "docs/technical/CONTROL_PLANE_MAP.md" ]; then
    printf '%s\n' "sdd-dev"
    return
  fi

  printf '%s\n' "product"
}

EFFECTIVE_INSTALL_MODE="$(detect_install_mode)"

printf 'SDD Codex Preflight\n'
printf 'Root: %s\n' "$(pwd)"
printf 'Install mode: %s\n' "$EFFECTIVE_INSTALL_MODE"

section "Required Files"
required_files=(
  "AGENTS.md"
  "CLAUDE.md"
  ".codex/INSTALL.md"
  ".codex/START.md"
  ".codex/CONTEXT.md"
  ".codex/PRE_EDIT_CHECKLIST.md"
  ".codex/COMPLETION_CHECKLIST.md"
  "docs/codex-compatibility.md"
  "docs/technical/SDD_LIFECYCLE_MAP.md"
  ".claude/settings.json"
  ".claude/skills/using-sdd/SKILL.md"
  ".claude/skills/codex-sdd/SKILL.md"
  "scripts/validate-skills.sh"
  "scripts/harness-audit.js"
)

if [ "$EFFECTIVE_INSTALL_MODE" = "sdd-dev" ]; then
  required_files+=(
    "README_vn.md"
    "scripts/validate-readme-sync.js"
    "docs/internal/adr"
    "docs/technical/CONTROL_PLANE_MAP.md"
    "docs/technical/SOURCE_OF_TRUTH_REGISTRY.md"
  )
fi

for path in "${required_files[@]}"; do
  if [ -e "$path" ]; then
    ok "found $path"
  else
    fail "missing $path"
  fi
done

section "Codex Adapter Content"
check_file_contains() {
  path="$1"
  pattern="$2"
  label="$3"
  if [ ! -f "$path" ]; then
    fail "missing $path"
    return
  fi
  if grep -Fq "$pattern" "$path"; then
    ok "$label"
  else
    fail "$label missing expected text"
  fi
}

check_file_contains ".codex/CONTEXT.md" \
  "If this summary disagrees with a Claude source file, the Claude source wins." \
  "CONTEXT.md declares Claude source precedence"
check_file_contains ".codex/PRE_EDIT_CHECKLIST.md" \
  "Pre-code gate: <Fast|Spec|Plan|Interview|Override> satisfied by <evidence>; next edit: <file>; verification: <command/check>." \
  "PRE_EDIT_CHECKLIST.md uses canonical one-line gate"
check_file_contains ".codex/COMPLETION_CHECKLIST.md" \
  "Warnings are fixed, classified, or reported with scope impact." \
  "COMPLETION_CHECKLIST.md classifies warnings"

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

if [ "$EFFECTIVE_INSTALL_MODE" = "product" ]; then
  section "README Sync"
  ok "skipped for Product install mode"
elif [ "$SKIP_README_SYNC" -eq 0 ]; then
  section "README Sync"
  run_checked "README sync" node scripts/validate-readme-sync.js
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
