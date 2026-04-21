---
name: project-tech-decisions
description: What architecture decisions and stack constraints must survive context resets?
type: project
---

## Stack & Infrastructure

- **Ngôn ngữ chính:** Bash (hooks), JavaScript/Node.js (hook scripts), PowerShell (Windows compat)
- **Runtime:** Node.js (dùng trong hook scripts via inline heredoc), Git Bash trên Windows
- **Database:** Filesystem (Markdown/JSONL) + Supermemory MCP cho long-term semantic storage
- **Deployment:** Shell install scripts (`init-sdd.sh`, `init-sdd.ps1`)

## Governance Decisions

- **2026-04-17 — Circuit Breaker enforced:** ADR-004 unified Rule 6/14/Diminishing Returns thành 1 state machine. Source of truth: `.claude/memory/circuit-state.json`. Hooks: `circuit-guard.sh` (PreToolUse/Task) + `circuit-updater.sh` (PostToolUse/Task).
- **2026-04-17 — Decision Ledger enforced:** Rule 15 có `decision-ledger-writer.sh` PostToolUse/Task. Ledger: `production/traces/decision_ledger.jsonl`.
- **2026-04-21 — Rule 16 Handoff downgraded MUST→SHOULD:** 0 handoff contracts sau nhiều sessions → full protocol quá friction. Lightweight text summary thay thế. Không cần tooling.
- **2026-04-21 — Skill telemetry added:** `log-skill.sh` PostToolUse/Skill → `production/traces/skill-usage.jsonl`. Prerequisite trước khi expand skill count thêm.
- **2026-04-17 — Skills precedence rule:** Commands = workflow gates (stage); Skills = domain expertise (content). Commands CHỨA skills, không thay thế. Xem `.claude/docs/skills-precedence.md`.
- **Git branch:** Main branch (`main`) — không dùng feature branches cho SDD governance work.

## Constraints

- **Skill count target:** ≤ 90 (hiện tại 118 — cần cull)
- **MEMORY.md hard limit:** 50 lines (trigger `/dream` nếu vượt 40)
- **Hook timeout budget:** 5s default, 10s max cho validate hooks
- **jq required:** Tất cả hook parse JSON phải require jq (exit 1 nếu thiếu); không dùng regex fallback

