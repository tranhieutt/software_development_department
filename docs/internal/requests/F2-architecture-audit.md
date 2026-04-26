# F2 — SDD Architectural Audit (Tier-Coherence Review)

**Date:** 2026-04-26
**Reviewer:** technical-director (acting as Anthropic chief architect)
**Scope:** Audit kiến trúc tầng cao của SDD — coherence giữa 4 layer (CLAUDE.md ↔ skills ↔ agents ↔ rules), tìm contradictions, ghost references, drift.
**Method:** Static cross-reference analysis trên `main` (HEAD `c3d4c66`). Không chạy runtime test.
**Continuation of:** F1 (archived in commit `a54e216`).

---

## Executive Summary

SDD ở trạng thái **functional nhưng có drift đáng kể** giữa documentation layer và runtime layer. 4 vấn đề H-risk có thể gây subagent dispatch failure trong production. 3 vấn đề M-risk gây sai lệch khi session mới onboard.

**Verdict:** `CHANGES_REQUIRED` — cần 1 sprint cleanup (~4-6h work) trước khi gọi SDD là production-stable.

| Risk | Finding | Files affected | Fix effort |
|------|---------|----------------|------------|
| **H1** | Ghost agent `qa-lead` vẫn còn trong 4 skills + 1 agent + 3 docs | 8 | 30 min |
| **H2** | Ghost agents `backend-architect`, `frontend-designer`, `product-strategist` trong skill frontmatter | 3 | 15 min |
| **H3** | Rule 14 còn legacy fallback `investigator` dù ADR-005 đã supersede | 1 | 10 min |
| **H4** | `agent-roster.md` lệch hoàn toàn với `.claude/agents/` (5 ghost, 3 missing) | 1 | 20 min |
| **M1** | `rules-reference.md` lệch với `.claude/rules/` (2 ghost, 5 missing) | 1 | 15 min |
| **M2** | `skills-reference.md` chỉ document 47/126 skills (~63% undocumented) | 1 | 1-2 h |
| **M3** | ARCHITECTURE.md Mermaid diagrams reference `qa-lead` | 1 | 10 min |
| **L1** | `directory-structure.md` bỏ qua `tools/` và `scratch/` top-level | 1 | 5 min |
| **L2** | CLAUDE.md không `@-include` `skills-precedence.md` | 1 | 5 min |

**Total cleanup:** ~3-4 hours (excluding M2 which is bigger).

---

## Layer Inventory

| Layer | Artifacts | Count |
|-------|-----------|-------|
| L1 — CLAUDE.md anchors | `CLAUDE.md` + 8 `@`-includes | 9 |
| L2 — Coordination | `coordination-rules.md` (16 rules) + 4 ADRs | 5 |
| L3 — Permissions/Hooks | `settings.json` + 29 hook scripts (22 declared) | 30 |
| L4 — Skills | `.claude/skills/*/SKILL.md` | 126 |
| L5 — Agents | `.claude/agents/*.md` | 28 |
| L6 — Rules | `.claude/rules/*.md` | 13 |

CLAUDE.md `@`-include integrity: **9/9 OK** ✅

---

## H1 — Ghost agent `qa-lead` (HIGH)

`qa-lead` does NOT exist in `.claude/agents/`. Actual agent is `qa-engineer` (per merger noted in agent file: *"Replaces qa-lead + qa-tester"*).

**Active ghost references:**

| File | Line(s) | Usage |
|------|---------|-------|
| `.claude/skills/verification-before-completion/SKILL.md` | 10 | `agent: qa-lead` (frontmatter) |
| `.claude/skills/team-release/SKILL.md` | 4, 21, 29, 54, 65, 81 | `subagent_type: qa-lead` |
| `.claude/skills/orchestrate/SKILL.md` | 52, 90 | Routing table |
| `.claude/skills/test-driven-development/SKILL.md` | (mentioned) | Doc reference |
| `.claude/agents/ui-spec-designer.md` | 73 | `@qa-lead` collaboration ref |
| `.claude/docs/technical/ARCHITECTURE.md` | 20, 56 | Mermaid diagram |
| `.claude/docs/agent-roster.md` | (row) | Listed as roster member |
| `.claude/docs/skills-precedence.md` | — | Mentioned in resolution example |

**Risk:** Khi agent dispatch chạy `subagent_type: qa-lead` → Task tool returns error "agent not found". `verification-before-completion` (mandatory gate per using-sdd) sẽ fail-open hoặc fail-hard tùy harness.

**Fix:** Replace tất cả `qa-lead` → `qa-engineer`. Commit `a41c3a2 fix(skills): replace ghost agent refs` đã claim fix nhưng miss 8 vị trí trên.

---

## H2 — Ghost agents trong skill frontmatter (HIGH)

3 skills declare `agent:` field pointing to non-existent agents:

| Skill | Frontmatter `agent:` | Real agent should be |
|-------|----------------------|----------------------|
| `backend-patterns/SKILL.md:9` | `backend-architect` | `backend-developer` |
| `frontend-design/SKILL.md:11` | `frontend-designer` | `ux-designer` or `frontend-developer` |
| `brainstorm/SKILL.md:9` | `product-strategist` | `product-manager` |

**Risk:** Tùy harness implementation, frontmatter `agent:` field có thể auto-route skill tới agent đó. Nếu dispatch fails, fallback path (Rule 14) chưa cover các skills này.

**Fix:** Update frontmatter để dùng agent thật.

---

## H3 — Rule 14 legacy fallback (HIGH)

`coordination-rules.md:106`:
```
| `diagnostics` | `investigator` *(legacy fallback — use `diagnostics` directly)* |
```

`investigator` không tồn tại như agent file. Comment "legacy fallback" tự thừa nhận điều này, nhưng row vẫn nằm trong fallback table — gây ambiguity cho agent đọc rule.

**ADR-005** (Status: Accepted, 2026-04-18) đã supersede phần này nhưng Rule 14 chưa được clean.

**Fix:** Xóa hàng `diagnostics → investigator` (vì diagnostics đã tự đứng vững — không cần fallback). Hoặc replace bằng `fullstack-developer` nếu muốn fallback path.

---

## H4 — `agent-roster.md` lệch hoàn toàn với runtime (HIGH)

| Roster (30 agents) | Actual `.claude/agents/` (28 agents) |
|----|----|
| ✅ 25 matches | |
| ❌ Lists ghost: `investigator`, `qa-lead`, `qa-tester`, `solver`, `verifier` (5) | |
| ❌ Missing real: `diagnostics`, `mobile-developer`, `qa-engineer` (3) | |

**Risk:** New session reading agent-roster sẽ try delegate đến ghost agents. Không có cross-validation hook để catch.

**Fix:** Regenerate roster từ `ls .claude/agents/`. Suggest hook idea: pre-commit check that `agent-roster.md` matches `ls .claude/agents/`.

---

## M1 — `rules-reference.md` ↔ `.claude/rules/` drift (MEDIUM)

| Rules-reference declares | Actual rules/ |
|---|---|
| ❌ `db-code.md` (ghost) | ✅ `database-code.md` |
| ❌ `config-code.md` (ghost) | (no equivalent) |
| (not listed) | ✅ `data-files.md` |
| (not listed) | ✅ `git-push.md` |
| (not listed) | ✅ `secrets-config.md` |
| (not listed) | ✅ `src-code.md` |

**Risk:** Khi agent muốn apply per-domain coding standard, lookup theo reference doc sẽ miss 5 rule files (incl. quan trọng `secrets-config.md` và `git-push.md`).

**Fix:** Sync table trong `rules-reference.md` với output của `ls .claude/rules/`.

---

## M2 — `skills-reference.md` coverage gap (MEDIUM)

47 skills documented / 126 actual = **62.7% undocumented**.

Skills critical missing:
- `using-sdd` (the router itself!)
- `source-driven-development`
- `spec-evolution`
- `codex-sdd`
- `verification-before-completion`
- `code-simplification`
- `receiving-code-review`
- `gate-check`
- ... (~80 more)

**Risk:** Skills-reference là entry point để agent biết skills nào available + boundary giữa skills overlap. Gap 63% nghĩa là phần lớn skills không được lookup-able.

**Fix:** 1-2h work — generate reference từ skill frontmatter. Có thể tự động hóa qua hook.

---

## M3 — ARCHITECTURE.md Mermaid diagrams (MEDIUM)

Lines 20, 56 hard-code `qa-lead` trong agent topology diagrams. Khi reader render diagram để hiểu kiến trúc, họ học sai naming.

**Fix:** Replace `qa-lead` → `qa-engineer` trong cả 2 diagram blocks.

---

## L1 — `directory-structure.md` thiếu directories (LOW)

- Top-level thực tế có `tools/` và `scratch/`, không declare trong directory-structure.md
- `src/` declare 7 subdirs (api, frontend, backend, ai, networking, ui, tools) nhưng thực tế trống — đây là placeholder hợp lý nếu intentional, cần note rõ.

**Fix:** Add 2 dòng cho `tools/` (build/utility scripts) và `scratch/` (transient experiments). Note trên `src/` rằng subdirs là placeholder.

---

## L2 — CLAUDE.md không `@-include` skills-precedence (LOW)

CLAUDE.md có dòng tham chiếu `[skills-precedence.md](...)` nhưng không `@-include`, nghĩa là content không tự load vào session context. Khi precedence conflict xảy ra, agent phải tự tìm doc → fragile.

**Fix:** Add `@.claude/docs/skills-precedence.md` vào CLAUDE.md (sau context-management hoặc thay thế).

**Tradeoff:** Mỗi `@`-include tăng token cost cho mọi session. Skills-precedence chỉ cần khi có conflict — không phải mỗi turn. Có thể giữ as-link thay vì auto-load.

---

## Cross-Layer Coherence Check

| L1 ↔ L2 | ✅ CLAUDE.md CRITICAL RULES không mâu thuẫn coordination-rules |
| L2 ↔ L4 | ⚠️ Rule 14 (coordination) vs ADR-005 (supersedes) — partially resolved |
| L4 ↔ L5 | ❌ 4 skills point to ghost agents (H1, H2) |
| L4 ↔ L6 | ✅ Skills không direct-reference rules; OK |
| L5 ↔ docs | ❌ agent-roster, ARCHITECTURE.md drift (H4, M3) |
| L6 ↔ docs | ❌ rules-reference drift (M1) |
| Hooks ↔ settings | ✅ 22 declared hooks all exist; 7 extra hook files (auto-dream, fork-join, sync hooks) called by other hooks |

---

## Recommended Cleanup Sprint

**Phase 1 — Ghost elimination (60 min):**
- [ ] H1: sed-replace `qa-lead` → `qa-engineer` across 8 files; verify with `grep -r qa-lead .claude/`
- [ ] H2: Fix 3 skill frontmatters
- [ ] H3: Remove or rename diagnostics fallback row in Rule 14
- [ ] H4: Regenerate `agent-roster.md` from `.claude/agents/`

**Phase 2 — Doc resync (30 min):**
- [ ] M1: Sync `rules-reference.md` with `.claude/rules/`
- [ ] M3: Fix ARCHITECTURE.md Mermaid blocks
- [ ] L1: Add tools/ and scratch/ to directory-structure.md

**Phase 3 — Skills coverage (1-2 h, separate sprint):**
- [ ] M2: Generate skills-reference từ skill frontmatter, có thể tự động qua script

**Phase 4 — Preventive (optional):**
- [ ] Add hook `validate-agent-refs.sh` — pre-commit check ngăn ghost references mới
- [ ] L2: Decide on `@-include` of skills-precedence (yes/no based on token budget)

---

## What this audit did NOT cover

- Runtime stress-test (Option B): chạy thử user-journey end-to-end để xem gates có hoạt động không
- Codex compatibility (Option C): verify `.codex/` mirror SDD logic
- Hook execution correctness: chỉ check declaration, không exec
- Skill content quality: chỉ check ghost refs, không review skill body
- F1 findings continuity: F1 archived ở `a54e216`; chưa diff so với F2

---

## Verification

- Inventory: `ls .claude/{skills,agents,rules,hooks,docs}` — 126/28/13/29/25 confirmed
- Ghost search: `grep -r qa-lead .claude/` returned 8 files; `grep -r investigator .claude/docs/coordination-rules.md` returned 1 line
- Roster diff: `diff <(ls .claude/agents/) <(grep ... agent-roster.md)` — 5 ghosts, 3 missing
- Rules diff: `diff <(ls .claude/rules/) <(grep ... rules-reference.md)` — 2 ghosts, 5 missing
- Skills count: `ls .claude/skills/ | wc -l` = 126 vs `grep -c ... skills-reference.md` = 47
