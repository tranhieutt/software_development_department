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
VALID_TYPES=("workflow" "reference" "agent")
MIN_BODY_LINES=30

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
  frontmatter=$(sed $'1s/^\xef\xbb\xbf//;s/\r$//' "$skill_file" | awk '/^---$/{found++; if(found==2) exit; next} found==1 { print }')
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

  # --- NEW CHECKS ---
  extra_warnings=()

  # Check 1: Type values valid
  type_valid=0
  for vt in "${VALID_TYPES[@]}"; do
    [[ "$skill_type" == "$vt" ]] && type_valid=1 && break
  done
  if [[ $type_valid -eq 0 ]]; then
    extra_warnings+=("invalid type '$skill_type' (expected: ${VALID_TYPES[*]})")
  fi

  # Check 2: Boilerplate detection
  if grep -qE "Working on .+ tasks or workflows" "$skill_file"; then
    extra_warnings+=("generic boilerplate header detected")
  fi

  # Check 3: Broken references - find /skill-name patterns outside code blocks
  # Some slash commands are command aliases for canonical skill directories.
  no_code=$(sed '/^```/,/^```/d' "$skill_file" | sed 's/`[^`]*`//g')
  while IFS= read -r ref_name; do
    [[ -z "$ref_name" ]] && continue
    [[ "$ref_name" == "$skill_name" ]] && continue
    case "$ref_name" in
      plan) alias_name="planning-and-task-breakdown" ;;
      spec) alias_name="spec-driven-development" ;;
      tdd) alias_name="test-driven-development" ;;
      *) alias_name="" ;;
    esac
    if [[ -n "$alias_name" && -d "$SKILLS_DIR/$alias_name" ]]; then
      continue
    fi
    ref_dir="$SKILLS_DIR/$ref_name"
    if [[ ! -d "$ref_dir" ]]; then
      extra_warnings+=("broken reference: /$ref_name (directory not found)")
    fi
  done < <(echo "$no_code" | grep -oP '(?<=^|[\s(])/([a-z][a-z0-9-]+[a-z0-9])(?=[\s).,;:!?]|$)' | sed 's|^/||' | sort -u)

  # Check 4: Minimum content length
  body_lines=$(sed '1,/^---$/d' "$skill_file" | sed '1,/^---$/d' | sed '/^[[:space:]]*$/d' | wc -l)
  if [[ $body_lines -lt $MIN_BODY_LINES ]]; then
    extra_warnings+=("thin content: $body_lines non-empty lines (min: $MIN_BODY_LINES)")
  fi

  # --- REPORT ---
  if [[ $skill_failed -eq 1 ]]; then
    echo -e "${RED}✗ $skill_name${NC}"
    echo -e "  Missing required: ${missing_required[*]}"
    failed=$((failed + 1))
  elif [[ ${#missing_optional[@]} -gt 0 || ${#extra_warnings[@]} -gt 0 ]]; then
    all_warns=("${missing_optional[@]/#/optional missing: }" "${extra_warnings[@]}")
    echo -e "${YELLOW}△ $skill_name${NC} — ${all_warns[*]}"
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
