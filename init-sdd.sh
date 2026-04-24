#!/usr/bin/env bash

set -euo pipefail

PATH_ARG=""
INCLUDE_REFERENCE_DOCS=0
INCLUDE_HARNESS_TESTS=0

while (($#)); do
  case "$1" in
    --include-reference-docs|--full-docs)
      INCLUDE_REFERENCE_DOCS=1
      ;;
    --include-harness-tests)
      INCLUDE_HARNESS_TESTS=1
      ;;
    -h|--help)
      echo "Usage: ./init-sdd.sh [--include-reference-docs] [--include-harness-tests] [target-path]"
      exit 0
      ;;
    *)
      if [[ -z "${PATH_ARG}" ]]; then
        PATH_ARG="$1"
      else
        printf 'Error: unexpected argument: %s\n' "$1" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if [[ -z "${PATH_ARG}" ]]; then
  printf '%s\n' '--- SDD PROJECT INITIALIZER ---'
  read -r -p "Enter the path for the new project (e.g., /mnt/d/MyNewApp): " PATH_ARG
fi

if [[ -z "${PATH_ARG}" ]]; then
  printf '%s\n' 'Error: No path provided.' >&2
  exit 1
fi

if [[ ! -e "${PATH_ARG}" ]]; then
  printf 'Creating directory: %s...\n' "${PATH_ARG}"
  mkdir -p "${PATH_ARG}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy_sdd_item() {
  local relative_path="$1"
  local source_path="${SCRIPT_DIR}/${relative_path}"
  local destination_path="${PATH_ARG}/${relative_path}"
  local destination_parent

  if [[ ! -e "${source_path}" ]]; then
    printf ' -> Skipping missing source: %s\n' "${relative_path}"
    return
  fi

  destination_parent="$(dirname "${destination_path}")"
  mkdir -p "${destination_parent}"
  printf ' -> Copying: %s\n' "${relative_path}"
  cp -R "${source_path}" "${destination_parent}/"
}

SOURCE_ITEMS=(
  ".claude"
  ".codex"
  ".tasks"
  ".gitignore"
  ".mcp.json"
  "AGENTS.md"
  "CLAUDE.md"
  "PRD.md"
  "README.md"
  "README_vn.md"
  "TODO.md"
  "scripts"
)

CORE_DOC_ITEMS=(
  "docs/codex-compatibility.md"
  "docs/technical"
  "docs/internal/adr"
)

REFERENCE_DOC_ITEMS=(
  "docs/archived"
  "docs/hooks_visual_report.html"
  "docs/internal/CHANGELOG.md"
  "docs/internal/hooks-system-report.md"
  "docs/internal/portal-data.js"
  "docs/internal/requests"
  "docs/onboarding"
  "docs/reference"
)

HARNESS_TEST_ITEMS=(
  "tests"
)

SCAFFOLD_TEST_ITEMS=(
  "tests/.gitkeep"
)

printf '\n%s\n' 'Initializing SDD Architectural Framework...'
if [[ "${INCLUDE_REFERENCE_DOCS}" -eq 0 ]]; then
  printf '%s\n' 'Using core docs only. Add --include-reference-docs to copy onboarding/reference/archive docs as well.'
fi
if [[ "${INCLUDE_HARNESS_TESTS}" -eq 0 ]]; then
  printf '%s\n' 'Scaffolding tests/.gitkeep only. Add --include-harness-tests to copy the SDD harness test suite.'
fi

for item in "${SOURCE_ITEMS[@]}"; do
  copy_sdd_item "${item}"
done

for item in "${CORE_DOC_ITEMS[@]}"; do
  copy_sdd_item "${item}"
done

if [[ "${INCLUDE_REFERENCE_DOCS}" -eq 1 ]]; then
  for item in "${REFERENCE_DOC_ITEMS[@]}"; do
    copy_sdd_item "${item}"
  done
fi

if [[ "${INCLUDE_HARNESS_TESTS}" -eq 1 ]]; then
  for item in "${HARNESS_TEST_ITEMS[@]}"; do
    copy_sdd_item "${item}"
  done
else
  for item in "${SCAFFOLD_TEST_ITEMS[@]}"; do
    copy_sdd_item "${item}"
  done
fi

printf '\nSDD Environment successfully initialized at: %s\n' "${PATH_ARG}"
printf '%s\n' '--------------------------------------------------------'
printf '%s\n' 'NEXT STEPS:'
printf " 1. Move to the project: cd '%s'\n" "${PATH_ARG}"
printf '%s\n' ' 2. Open with your IDE: code .'
printf '%s\n' ' 3. For Claude Code, read CLAUDE.md then run /start.'
printf '%s\n' ' 4. For Codex, start with AGENTS.md and .codex/START.md.'
if [[ "${INCLUDE_REFERENCE_DOCS}" -eq 0 ]]; then
  printf '%s\n' ' 5. Re-run with --include-reference-docs if you want onboarding/reference/archive docs too.'
fi
if [[ "${INCLUDE_HARNESS_TESTS}" -eq 0 ]]; then
  printf '%s\n' ' 6. Re-run with --include-harness-tests if you want the SDD harness tests too.'
fi
printf '%s\n' '--------------------------------------------------------'
