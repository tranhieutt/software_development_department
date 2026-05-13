#!/usr/bin/env bash

set -euo pipefail

PATH_ARG=""
INSTALL_MODE="product"
INCLUDE_REFERENCE_DOCS=0
INCLUDE_HARNESS_TESTS=0

while (($#)); do
  case "$1" in
    --install-mode)
      shift
      if [[ "${1:-}" != "product" && "${1:-}" != "sdd-dev" ]]; then
        printf 'Error: --install-mode must be product or sdd-dev\n' >&2
        exit 1
      fi
      INSTALL_MODE="$1"
      ;;
    --include-reference-docs|--full-docs)
      INCLUDE_REFERENCE_DOCS=1
      ;;
    --include-harness-tests)
      INCLUDE_HARNESS_TESTS=1
      ;;
    -h|--help)
      echo "Usage: ./init-sdd.sh [--install-mode product|sdd-dev] [--include-reference-docs] [--include-harness-tests] [target-path]"
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

copy_sdd_item_if_missing() {
  local relative_path="$1"
  local destination_path="${PATH_ARG}/${relative_path}"
  if [[ -e "${destination_path}" ]]; then
    printf ' -> Preserving existing: %s\n' "${relative_path}"
    return
  fi
  copy_sdd_item "${relative_path}"
}

write_product_stub_if_missing() {
  local relative_path="$1"
  local content="$2"
  local destination_path="${PATH_ARG}/${relative_path}"
  local destination_parent

  if [[ -e "${destination_path}" ]]; then
    printf ' -> Preserving existing product doc: %s\n' "${relative_path}"
    return
  fi

  destination_parent="$(dirname "${destination_path}")"
  mkdir -p "${destination_parent}"
  printf ' -> Creating product stub: %s\n' "${relative_path}"
  printf '%s\n' "${content}" > "${destination_path}"
}

write_install_marker() {
  local mode="$1"
  local json_mode="Product"
  local installed_at

  if [[ "${mode}" == "sdd-dev" ]]; then
    json_mode="SddDev"
  fi

  installed_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  mkdir -p "${PATH_ARG}/.sdd"
  cat > "${PATH_ARG}/.sdd/install.json" <<EOF
{
  "installMode": "${json_mode}",
  "installedAt": "${installed_at}",
  "source": "SDD"
}
EOF
  printf ' -> Wrote install marker: .sdd/install.json\n'
}

SOURCE_ITEMS=(
  ".claude"
  ".codex"
  ".tasks"
  ".mcp.json"
  "AGENTS.md"
  "CLAUDE.md"
)

PRODUCT_SCRIPT_ITEMS=(
  "scripts/codex-preflight.ps1"
  "scripts/codex-preflight.sh"
  "scripts/codex-safety-check.py"
  "scripts/harness-audit.js"
  "scripts/ledger-append.sh"
  "scripts/trace-history.sh"
  "scripts/trace-integrity-check.js"
  "scripts/validate-skills.ps1"
  "scripts/validate-skills.sh"
)

SDD_DEV_ROOT_ITEMS=(
  ".gitignore"
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

PRODUCT_DOC_ITEMS=(
  "docs/codex-compatibility.md"
  "docs/technical/SDD_LIFECYCLE_MAP.md"
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
printf 'Install mode: %s\n' "${INSTALL_MODE}"
if [[ "${INSTALL_MODE}" == "product" ]]; then
  printf '%s\n' 'Product mode preserves README.md, PRD.md, TODO.md, and .gitignore when they already exist.'
fi
if [[ "${INSTALL_MODE}" == "sdd-dev" && "${INCLUDE_REFERENCE_DOCS}" -eq 0 ]]; then
  printf '%s\n' 'Using core docs only. Add --include-reference-docs to copy onboarding/reference/archive docs as well.'
fi
if [[ "${INCLUDE_HARNESS_TESTS}" -eq 0 ]]; then
  printf '%s\n' 'Scaffolding tests/.gitkeep only. Add --include-harness-tests to copy the SDD harness test suite.'
fi

for item in "${SOURCE_ITEMS[@]}"; do
  copy_sdd_item "${item}"
done

if [[ "${INSTALL_MODE}" == "product" ]]; then
  for item in "${PRODUCT_SCRIPT_ITEMS[@]}" "${PRODUCT_DOC_ITEMS[@]}"; do
    copy_sdd_item "${item}"
  done
  copy_sdd_item_if_missing ".gitignore"
  write_product_stub_if_missing "README.md" "# Project README

This project uses the SDD harness for agent-assisted development.

Replace this stub with product-specific setup, architecture, and operating notes."
  write_product_stub_if_missing "PRD.md" "# Product Requirements

This file is the human-approved source of truth for product scope.

## Overview

Describe the product outcome here.

## Acceptance Criteria

- [ ] Define product-specific acceptance criteria."
  write_product_stub_if_missing "TODO.md" "# Backlog

Track product work here. Keep items tied to PRD requirements and .tasks/ detail files when work becomes active.

## Up Next

- [ ] Define first product task."
else
  for item in "${SDD_DEV_ROOT_ITEMS[@]}" "${CORE_DOC_ITEMS[@]}"; do
    copy_sdd_item "${item}"
  done
  if [[ "${INCLUDE_REFERENCE_DOCS}" -eq 1 ]]; then
    for item in "${REFERENCE_DOC_ITEMS[@]}"; do
      copy_sdd_item "${item}"
    done
  fi
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

write_install_marker "${INSTALL_MODE}"

printf '\nSDD Environment successfully initialized at: %s\n' "${PATH_ARG}"
printf '%s\n' '--------------------------------------------------------'
printf '%s\n' 'NEXT STEPS:'
printf " 1. Move to the project: cd '%s'\n" "${PATH_ARG}"
printf '%s\n' ' 2. Open with your IDE: code .'
printf '%s\n' ' 3. For Claude Code, read CLAUDE.md then run /start.'
printf '%s\n' ' 4. For Codex, start with AGENTS.md and .codex/START.md.'
if [[ "${INSTALL_MODE}" == "product" ]]; then
  printf '%s\n' ' 5. Replace README.md, PRD.md, and TODO.md stubs with product-specific content.'
fi
if [[ "${INSTALL_MODE}" == "sdd-dev" && "${INCLUDE_REFERENCE_DOCS}" -eq 0 ]]; then
  printf '%s\n' ' 5. Re-run with --include-reference-docs if you want onboarding/reference/archive docs too.'
fi
if [[ "${INCLUDE_HARNESS_TESTS}" -eq 0 ]]; then
  printf '%s\n' ' 6. Re-run with --include-harness-tests if you want the SDD harness tests too.'
fi
printf '%s\n' '--------------------------------------------------------'
