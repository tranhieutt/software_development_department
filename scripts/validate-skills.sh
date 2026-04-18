#!/usr/bin/env bash
# validate-skills.sh — Kiểm tra tất cả SKILL.md trong .claude/skills/
# Usage: bash scripts/validate-skills.sh
# Output: danh sách skills thiếu fields, exit 1 nếu có lỗi

set -euo pipefail

SKILLS_DIR=".claude/skills"
# Fields bắt buộc cho mọi skill
REQUIRED_FIELDS=("name" "description" "user-invocable" "allowed-tools" "effort")
# Fields bắt buộc thêm cho type=workflow (không áp dụng cho type=reference)
WORKFLOW_FIELDS=("argument-hint")
# Recommended: warn nếu thiếu, không fail (backward compat với 100 skills cũ chưa có type)
RECOMMENDED_FIELDS=("type")
OPTIONAL_FIELDS=("agent" "when_to_use" "context")

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'

total=0; passed=0; failed=0; warnings=0

echo "═══════════════════════════════════════════"
echo "  SDD Skill Validator"
echo "═══════════════════════════════════════════"
echo ""

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill_dir")

  # Bỏ qua thư mục templates
  [[ "$skill_name" == "templates" ]] && continue

  skill_file="$skill_dir/SKILL.md"
  total=$((total + 1))

  if [[ ! -f "$skill_file" ]]; then
    echo -e "${RED}✗ $skill_name${NC} — SKILL.md không tồn tại"
    failed=$((failed + 1)); continue
  fi

  # Extract frontmatter (giữa hai dòng ---)
  frontmatter=$(awk '/^---/{found++; if(found==2) exit} found==1 && !/^---/' "$skill_file")
  skill_failed=0; missing_required=(); missing_optional=()

  # Đọc type (mặc định là workflow nếu không có — backward compat)
  skill_type=$(echo "$frontmatter" | grep "^type:" | awk '{print $2}' | tr -d '"' || true)
  [[ -z "$skill_type" ]] && skill_type="workflow"

  for field in "${REQUIRED_FIELDS[@]}"; do
    if ! echo "$frontmatter" | grep -q "^${field}:"; then
      missing_required+=("$field"); skill_failed=1
    fi
  done

  # argument-hint chỉ bắt buộc với type=workflow
  if [[ "$skill_type" == "workflow" ]]; then
    for field in "${WORKFLOW_FIELDS[@]}"; do
      if ! echo "$frontmatter" | grep -q "^${field}:"; then
        missing_required+=("$field"); skill_failed=1
      fi
    done
  fi

  # Recommended fields → warn, không fail
  for field in "${RECOMMENDED_FIELDS[@]}"; do
    if ! echo "$frontmatter" | grep -q "^${field}:"; then
      missing_optional+=("$field")
    fi
  done

  if [[ $skill_failed -eq 1 ]]; then
    echo -e "${RED}✗ $skill_name${NC}"
    echo -e "  Missing required: ${missing_required[*]}"
    failed=$((failed + 1))
  elif [[ ${#missing_optional[@]} -gt 0 ]]; then
    echo -e "${YELLOW}△ $skill_name${NC} — optional missing: ${missing_optional[*]}"
    passed=$((passed + 1)); warnings=$((warnings + 1))
  else
    echo -e "${GREEN}✓ $skill_name${NC}"
    passed=$((passed + 1))
  fi
done

echo ""
echo "═══════════════════════════════════════════"
echo -e "  Total: $total | ${GREEN}Pass: $passed${NC} | ${RED}Fail: $failed${NC} | ${YELLOW}Warn: $warnings${NC}"
echo "═══════════════════════════════════════════"

[[ $failed -eq 0 ]] && exit 0 || exit 1
