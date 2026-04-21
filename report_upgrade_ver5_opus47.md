# 🏛️ AUDIT KIẾN TRÚC SDD — Báo cáo v5

> **Reviewer:** Anthropic Chief Architect (Claude Opus 4.7)
> **Ngày:** 2026-04-21
> **Phiên bản dự án:** SDD v1.42+ (commit `970771e`)
> **So với:** `report_upgrade_ver4_opus47.md` (2026-04-17)

## 📌 Changelog báo cáo

| Ngày       | Hành động                                   | Chi tiết                                                               |
| ---------- | ------------------------------------------- | ---------------------------------------------------------------------- |
| 2026-04-21 | 📋 Audit mới sau 4 ngày từ v4               | 5 P0 mới, verify 8/10 A-items từ v4 đã landed                         |

---

## 0. Phạm vi khảo sát

| Hạng mục                  | Số lượng |
| ------------------------- | -------- |
| Skills                    | **118**  |
| Agents                    | **31**   |
| Hooks (sh + ps1)          | **23**   |
| Coordination rules        | **16**   |
| Memory tier files         | **4**    |
| Decision ledger entries   | **8**    |
| Handoff contracts         | **0**    |
| Memory Tier 2 stubs       | **4/6**  |

---

## 1. ✅ Items v4 đã landing thật sự

| Item | Evidence |
|---|---|
| Dream loop fix (A1–A3) | `archive/dreams/` = 0 files hiện tại; cooldown tại [session-stop.sh:177-184](.claude/hooks/session-stop.sh) |
| MEMORY.md <40 dòng (A8) | 38 dòng hiện tại ✅ |
| Circuit breaker enforcement (A6) | [circuit-guard.sh](.claude/hooks/circuit-guard.sh) + [circuit-updater.sh](.claude/hooks/circuit-updater.sh) registered in settings.json |
| Decision ledger writer | [decision-ledger-writer.sh](.claude/hooks/decision-ledger-writer.sh) hoạt động; 8 entries trong `production/traces/decision_ledger.jsonl` |
| ADR-004 / ADR-005 | Written; Rule 14/15 có source-of-truth, không còn aspirational |
| jq required (A4) | [bash-guard.sh](.claude/hooks/bash-guard.sh) exit 1 khi thiếu jq |
| Deny-list expanded (A5) | settings.json: `cat .env*`, `Read(**/.env)`, `rm -rf ./` explicit |
| fastapi-pro / diagnose rewrite (A9, A10) | Content thật ~295 / ~170 dòng |

**Enforcement score** đã nhảy từ 3/10 → **7/10** — đây là cải thiện lớn nhất.

---

## 2. 🔴 P0 — Phải fix trước

### P0-1. Skill bloat QUAY LẠI — net +1 sau cam kết cắt

**Bằng chứng:**
- v4 cam kết "cắt ~15 skills trùng". Thực tế: xóa 1 (`nodejs-backend-patterns`), thêm mới 2+ (`skill-technical-document`, `visual-engineer`). Net: **+1** (117 → 118).
- Chưa có telemetry `skill-usage.jsonl` như cam kết Week 3 #12.
- **5 frontend orchestrators** chưa dedupe: `frontend-ui-dark-ts`, `senior-frontend`, `frontend-design`, `frontend-patterns`, `team-frontend`.
- `templates/` vẫn còn trong skills dir (không phải skill thực).

**Fix:**
1. Chạy `/skill-health` để đánh giá usage thực.
2. Thêm `skill-invocation.jsonl` log trong `log-agent.sh` trước khi thêm skill mới.
3. Target: **118 → ≤ 90 skills** trong 2 tuần.

---

### P0-2. Rule 16 (A2A Handoff) vẫn aspirational sau 4 ngày

**Bằng chứng:**
- `.tasks/handoffs/` **rỗng**. Không có handoff contract nào.
- Không có `/handoff` skill handler, không hook enforce.
- Báo cáo v4 §4 Week 3 #9 yêu cầu "quyết định binary: implement hoặc downgrade" — **chưa thực hiện**.

**Fix (binary — chọn 1):**
- **Option A:** Implement `/handoff` skill + hook enforce (Medium effort, 1 ngày)
- **Option B:** Downgrade Rule 16 từ MUST → SHOULD trong [.claude/docs/coordination-rules.md](.claude/docs/coordination-rules.md)

---

### P0-3. Tier 2 memory vẫn EMPTY STUBS sau 4 ngày

**Bằng chứng:**
```
feedback_rules.md:       12 lines (frontmatter + placeholder)
project_tech_decisions.md: 8 lines
user_role.md:              7 lines
consensus/merged-decisions.md: 46 lines (header only)
```
`annotations.md` (73 dòng) là ngoại lệ tốt. 4 file còn lại vẫn stub.

**Hệ quả:** 250 dòng context-management.md vẫn đang dạy LLM chọn 3-trong-0 file rỗng.

**Fix:**
1. Viết `PostToolUse` hook tự động extract quyết định từ tool result → append vào Tier 2 files.
2. Hoặc: seed thủ công tối thiểu 3 facts thực vào mỗi file Tier 2.

---

### P0-4. Portal mới chưa có governance

**Bằng chứng:**
- [docs/internal/portal.html](docs/internal/portal.html) + `portal-data.js` thêm vào commit `970771e`.
- `portal-data.js` có `M` (modified) trong git status → auto-update pipeline đang ghi vào file versioned.
- Không có ADR, không có JSON schema, không có ownership.

**Rủi ro:** Portal hiển thị số liệu sai → mất tin cậy framework với user.

**Fix:**
1. Viết ADR-006: Portal governance (owner, data contract, update frequency).
2. Tạo `docs/internal/portal-schema.json` schema validate `portal-data.js`.
3. Xem xét gitignore `portal-data.js` nếu auto-generated.

---

### P0-5. 3 file deleted chưa commit (git working tree bẩn)

**Bằng chứng (git status):**
```
D .claude/memory/archive/dreams/2026-04-19_10-26_dream.md
D landing-page/assets/ai_orchestration.png
D landing-page/assets/hero_bg.png
```

**Rủi ro:** `landing-page/assets/*.png` bị xóa → có thể broken link trong landing page.

**Fix:** Xác nhận xóa có chủ đích hay nhầm → commit hoặc restore.

---

## 3. 🟡 P1 — Kiến trúc dài hạn

| #  | Vấn đề                                                                                     | File ảnh hưởng                                                                                      | Khuyến nghị                                                             |
| -- | ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| 6  | 31 agents / 118 skills → ratio 1:3.8, agents thành "thin routers"                         | `.claude/agents/`                                                                                    | Merge `qa-lead`+`qa-tester`; merge `investigator`+`verifier`+`solver`  |
| 7  | 23 hooks, không có contract test                                                           | `.claude/hooks/`                                                                                     | Thêm `tests/hooks/*.bats` trong CI                                     |
| 8  | CLAUDE.md 73 dòng + 9 `@import` = ~1.5k dòng luôn-load                                    | [CLAUDE.md](CLAUDE.md)                                                                               | Lazy-load rules theo file glob pattern                                  |
| 9  | Không có observability cho circuit state transitions                                       | [.claude/memory/circuit-state.json](.claude/memory/circuit-state.json)                              | Expose qua portal; alert khi state OPEN >1h                            |
| 10 | `.claude/memory/specialists/` — 7 file stub                                                | `.claude/memory/specialists/`                                                                        | Xóa stubs; tạo on-write-only khi agent lần đầu persist                 |
| 11 | Windows native không có PS1 counterpart cho 5 hook critical (M3 từ v4 vẫn open)           | `.claude/hooks/`                                                                                     | Viết `bash-guard.ps1`, `validate-commit.ps1`, `validate-push.ps1`      |
| 12 | `validate-push.sh` chỉ scan staged diff — secret committed trước đó lọt qua (M5 từ v4)   | [.claude/hooks/validate-push.sh](.claude/hooks/validate-push.sh)                                   | Dùng `gitleaks` quét toàn branch diff                                  |

---

## 4. 📊 Scorecard

| Trục                              | v4 (2026-04-17) | v5 (2026-04-21) | Delta   | Ghi chú                                    |
| --------------------------------- | --------------- | --------------- | ------- | ------------------------------------------ |
| Vision & Documentation            | 8/10            | 8/10            | —       | Portal là +, nhưng chưa có governance      |
| Architecture coherence            | 4/10            | **5/10**        | **+1**  | ADR-004/005 landed                         |
| Enforcement (hook → rule binding) | 3/10            | **7/10**        | **+4**  | Circuit + Ledger = real enforcement now    |
| Security posture                  | 5/10            | 6/10            | +1      | A4/A5 done; M5/M3/H2 vẫn open             |
| Memory effectiveness              | 2/10            | **2/10**        | 0       | Stubs unchanged sau 4 ngày                 |
| Skill ecosystem health            | 5/10            | **4/10**        | **-1**  | Bloat tăng net; không có telemetry         |
| Cross-platform (Windows)          | 3/10            | 3/10            | —       | PS1 counterparts vẫn thiếu                 |
| **Tổng trung bình**               | **4.3/10**      | **5.0/10**      | **+0.7** |                                            |

---

## 5. 💡 Insight kiến trúc sư

**Tiến bộ thật sự:** Dự án đã vượt qua "documentation theater". Enforcement 3→7 trong 4 ngày là bước nhảy quan trọng. Circuit breaker + decision ledger cho dự án một "immune system" thật sự.

**Anti-pattern đang tái phát:**
> Bạn đang **thêm** (portal, skill-technical-document, visual-engineer) nhanh hơn **cắt**.
> Mỗi chu kỳ audit sinh thêm artifact thay vì consolidate.
> `skill-technical-document` v2 rebuild nghĩa là đang đầu tư sâu vào skills mà chưa chứng minh được skill nào đang được dùng.

**Nguyên tắc cần áp dụng:**
- Telemetry trước, expansion sau.
- Mỗi skill mới yêu cầu 1 skill cũ bị archive.
- Mỗi rule MUST yêu cầu 1 hook enforce tương ứng.

---

## 6. 📋 Action Items (cần chốt)

| #   | Action                                                                              | Risk   | Reversible? | Priority |
| --- | ----------------------------------------------------------------------------------- | ------ | ----------- | -------- |
| B1  | Commit/restore 3 deleted files (landing assets + dream)                             | Low    | Yes         | 🔴 P0    |
| B2  | Binary decision: implement `/handoff` handler OR downgrade Rule 16 MUST→SHOULD      | Low    | Yes         | 🔴 P0    |
| B3  | PostToolUse hook: auto-extract decisions → Tier 2 memory files                      | Medium | Yes         | 🔴 P0    |
| B4  | Skill telemetry: log `skill-invocation.jsonl` trong `log-agent.sh`                  | Low    | Yes         | 🔴 P0    |
| B5  | ADR-006: Portal governance + JSON schema cho `portal-data.js`                       | None   | Yes         | 🔴 P0    |
| B6  | Skill cull: chạy `/skill-health`, target 118 → ≤ 90                                | Medium | Yes (git)   | 🟡 P1    |
| B7  | Merge agents: QA (2→1), Investigator+Verifier+Solver (3→1) → 31→27 agents           | Medium | Yes (git)   | 🟡 P1    |
| B8  | PS1 counterparts cho `bash-guard`, `validate-commit`, `validate-push` (M3 v4)       | Low    | Yes         | 🟡 P1    |

---

## 7. Roadmap 2 tuần

### Week 1 — Đóng P0 gaps
1. B1: Git cleanup
2. B2: Rule 16 binary decision
3. B3: PostToolUse decision extractor
4. B4: Skill telemetry hook
5. B5: Portal ADR + schema

### Week 2 — Consolidate
6. B6: Skill cull xuống ≤ 90
7. B7: Agent merge (QA, Investigator trio)
8. B8: PS1 counterparts
9. Release SDD v1.43.0 với CHANGELOG đầy đủ

---

*Báo cáo tiếp theo nên được trigger sau khi B1–B5 hoàn thành, hoặc sau 1 tuần.*
