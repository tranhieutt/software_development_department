#!/usr/bin/env bash

set -euo pipefail

PATH_ARG="${1:-}"

if [[ "${PATH_ARG}" == "-h" || "${PATH_ARG}" == "--help" ]]; then
  echo "Usage: ./init-sdd.sh [target-path]"
  exit 0
fi

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

SOURCE_FILES=(
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
  "docs"
  "scripts"
)

printf '\n%s\n' 'Initializing SDD Architectural Framework...'

for item in "${SOURCE_FILES[@]}"; do
  source_path="${SCRIPT_DIR}/${item}"
  if [[ -e "${source_path}" ]]; then
    printf ' -> Copying: %s\n' "${item}"
    cp -R "${source_path}" "${PATH_ARG}/"
  else
    printf ' -> Skipping missing source: %s\n' "${item}"
  fi
done

printf '\nSDD Environment successfully initialized at: %s\n' "${PATH_ARG}"
printf '%s\n' '--------------------------------------------------------'
printf '%s\n' 'NEXT STEPS:'
printf " 1. Move to the project: cd '%s'\n" "${PATH_ARG}"
printf '%s\n' ' 2. Open with your IDE: code .'
printf '%s\n' ' 3. For Claude Code, read CLAUDE.md then run /start.'
printf '%s\n' ' 4. For Codex, start with AGENTS.md and .codex/START.md.'
printf '%s\n' '--------------------------------------------------------'
