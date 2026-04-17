# 🏛️ SDD-Upgrade v1.31.0 — Audit Toàn Diện

> **Reviewer:** Anthropic Chief Architect (Claude Opus 4.7)
> **Date:** 2026-04-17
> **Method:** 4 chuyên gia chạy song song (Architecture · Security · QA · Documentation)
> **Scope:** Toàn bộ harness `.claude/` + governance docs + hooks + memory + skills

---

## ⚖️ VERDICT TỔNG

**❌ NOT READY** để phân phối cho team khác.

Bốn audit độc lập hội tụ về cùng một chẩn đoán:

> **Harness có thiết kế xuất sắc trên giấy, nhưng tầng thực thi & sự thật chưa theo kịp.**
> Các rule, contract, ledger được định nghĩa rất chuyên nghiệp, nhưng không có runtime enforcement; số liệu badge không khớp thực tế; và `src/` của chính harness (`.claude/hooks/`) chứa **code chết che giấu enforcement giả**.

**Phân loại hiện tại:** Personal scaffold quality (~4/10), chưa phải shipped product.

---

## 📊 SCORECARD TỔNG HỢP

| Lĩnh vực | Điểm | Ghi chú |
|----------|------|---------|
| Testability | **2/10** | Chỉ 1 test file, 0 hook test |
| CI Maturity | **4/10** | Có `audit.yml` nhưng thiếu shellcheck, JSON-schema validation, `validate-skills.sh` |
| PRD Completeness | **2/10** | 7/9 sections vẫn là template placeholder |
| Doc Truthfulness | **5/10** | Badge count drift toàn project (118/123/125/137) |
| Doc Cohesion | **5.2/10** | 33+ file trộn lẫn trong `docs/` |
| Architectural Coherence | **6/10** | Thiết kế tốt, enforcement yếu |
| Security Posture | **4/10** | Dead-code bypass + MCP @latest + bypass-able denies |

**Trung bình trọng số: ~4/10**

---

## 🔴 CRITICAL — 5 phát hiện chặn ship

### C1. `validate-commit.sh:137` — Secret scan là DEAD CODE

`validate-commit.sh` có `exit 0` ở line 137 rồi mới đến block GitNexus blast-radius scan (lines 138-158). Vì bash exit ngay đó, **toàn bộ secret-scan block không bao giờ chạy**. Cùng pattern bug ở `session-start.sh:75`.

- **Tác động:** `git commit` chứa hardcoded `sk-ant-*` key sẽ pass `validate-commit.sh` âm thầm. Chỉ còn `validate-push.sh` là last line of defence.
- **Phát hiện chéo:** Architecture audit + Security audit độc lập confirm.
- **Files:** `.claude/hooks/validate-commit.sh:137`, `.claude/hooks/session-start.sh:75`
- **Fix effort:** 5 phút (xóa `exit 0` thừa)

### C2. `.mcp.json:6` — `gitnexus@latest` với `-y` = RCE supply chain

Mỗi session, npx silently pull whatever `latest` trỏ tới trên npmjs.com. Không lockfile, không SRI, không version pin, không audit trail.

- **Tác động:** Compromised hoặc typosquatted package → arbitrary code execution trong Claude sandbox.
- **File:** `.mcp.json:6`
- **Fix:** Pin `gitnexus@<exact-version>`, có thể thêm `npm-shrinkwrap` cho MCP deps.

### C3. Permission deny patterns dễ bypass

`.claude/settings.json` có deny rules trông an toàn nhưng bypass được:

| Deny rule | Bypass |
|-----------|--------|
| `Bash(rm -rf *)` | `rm  -rf /` (double space) · `rm -r -f /` · `rm -fr /` · `/bin/rm -rf /` |
| `Bash(*>.env*)` | `tee .env` · `tee -a .env` · `printf 'KEY=v' \| tee .env` · `python -c "open('.env','w')..."` |
| `Bash(cat *.env*)` | Không cover `.env.production` đọc qua tool khác |

- **File:** `.claude/settings.json:42-50`
- **Fix:** Bổ sung pattern variants vào `bash-guard.sh` (regex sâu hơn, không phụ thuộc glob match).

### C4. PRD v1.31.0 vẫn là TEMPLATE

7/9 sections của `PRD.md` chứa placeholder:
- §4 Personas: `[Name, e.g., "Alex the Admin"]`
- §6 NFRs: `[e.g., API response time < 200ms]`
- §7 Out of Scope: `[Feature A]`, `[Feature B]`, `[Feature C]`
- §8 Open Questions: placeholder Stripe/SSO
- §9 Revision History: `[YYYY-MM-DD] | [Name] | Initial draft`
- §Approvals: cả 3 sign-offs `Pending`, không tên, không ngày

Status được đánh `Active`. **Vi phạm chính governance "HUMAN APPROVAL REQUIRED" của harness.**

- **File:** `PRD.md:19-169`
- **Fix:** Hoặc human điền + ký approvals; hoặc bỏ lock và downgrade Status thành `Draft`.

### C5. ZERO hook regression coverage

`tests/` chỉ có 1 file: `tests/skills/validate-frontmatter.test.js` (kiểm YAML frontmatter của memory files).

- **Không test nào** cho 18 shell scripts trong `.claude/hooks/` — bao gồm các security hooks (`bash-guard.sh`, `validate-commit.sh`, `validate-push.sh`).
- Bump v1.31.0 → v1.32.0 không có safety net. Regression sẽ chỉ phát hiện qua "live session feels wrong".
- **File:** `tests/skills/`
- **Fix:** Smoke test cho block/warn paths của `bash-guard.sh`, `validate-commit.sh`. Wire `shellcheck` vào CI.

---

## 🟠 HIGH — 4 rủi ro kiến trúc

### H1. Skill catalog metastasis (118 vs 123 vs 125 vs 137)

Số liệu drift toàn project:
- `README.md:7` → "118 skills"
- `README_vn.md:7` → "123 skills"
- `harness-audit.js` thực đếm → 125+
- `find .claude/skills -type d` → 137 directories
- `History_Update.md:27` → "118 Skills" (entry v1.31.2 ghi tương lai)

**Worse:** Skill registry overlap với agent system:
- 6 "*-architect" skills (`cloud-architect`, `hybrid-cloud-architect`, `kubernetes-architect`, `backend-architect`, `database-architect`, `event-sourcing-architect`) duplicate @technical-director / @backend-developer / @data-engineer mandates
- 6 "team-*" skills (`team-backend`, `team-frontend`, `team-feature`, `team-mobile`, `team-release`, `team-ui`) overlap @producer
- 13+ stack-specific skills (`*-patterns`, framework experts) cho stack chưa cấu hình (`[not configured]` trong `technical-preferences.md:5`)

→ Skills bị dùng như **agent class song song**, làm loãng identity model.

**Fix:** Skill audit + collapse overlaps. Target ≤40 skills, mỗi skill có proof of non-overlap.

### H2. Coordination Rules 14/15/16 chỉ là contract, không enforcement

Rules 14 (Circuit Breaker) và 15 (Decision Ledger) reference state files:
- `production/session-state/circuit-state.json` — không tồn tại
- `production/traces/decision_ledger.jsonl` — không tồn tại

**Verification:**
- Không hook nào append ledger entries
- Không agent prompt instruction nào enforce ledger writes
- `/trace-history` chỉ là skill stub (`.claude/skills/trace-history`)
- Rule 16 (A2A Handoff) yêu cầu `.tasks/handoffs/<from>-to-<to>-<task_id>.json` — directory không có pattern test

**Tác động:** Rules có vẻ professional nhưng agent sẽ "quên" tuân thủ dưới context pressure → governance theater.

**Fix:** Convert rules thành hooks. PostToolUse hook auto-append ledger khi `risk_tier: High`. SessionStop hook check missing handoff contracts.

### H3. Bash-first hooks chạy trên Windows

Environment báo `win32` nhưng `settings.json:62-71` hardcode `bash .claude/hooks/*.sh`. Các `.ps1` mirrors (`bash-guard.ps1`, `session-start.ps1`, `validate-commit.ps1`) tồn tại nhưng **chưa bao giờ được gọi**.

**Concrete bugs:**
- `pre-refactor-impact.sh:19` — `sed 's|\|/|g'` broken: `|` không escaped trong alt delimiter → path normalization fail trên Windows
- Tất cả hooks **fail-open silent** khi missing `jq`/`npx` → agent assume protection đang chạy nhưng không

**Fix:** Hoặc settings.json branch theo OS, hoặc rewrite hooks bằng Node/Python (đã required cho GitNexus).

### H4. Tier 2.5 namespace isolation không thể enforce

`context-management.md:267-278` claim "Maximum 1 specialist file per session turn." Nhưng:

1. Active agent xác định bởi Claude invocation, **không có deterministic loader**
2. Không hook nào gate file `specialists/*.md` nào được load
3. `MEMORY.md:27-34` đã expose 8 specialist namespaces ngay Tier 1 → poisoning surface
4. Cross-agent handoffs cần `consensus/merged-decisions.md` (rule 16), nhưng technical-director phải nhớ merge tay → không automated

→ "Isolation by convention" — chỉ work khi mọi agent đọc rule và chọn tuân thủ. Compliance sẽ degrade dưới load.

---

## 🟡 MEDIUM — 6 issue bổ sung

### M1. `log-writes.sh:30` — Log injection qua filename

`FILE_PATH` và `SESSION_ID` interpolate trực tiếp vào JSONL không sanitize. Filename chứa `","event":"malicious` sẽ inject fabricated audit events.

### M2. `prompt-context.sh:50-56` — Content-triggered prompt injection

Hook reads tới 50 lines của bất kỳ `.md` file nào có content match prompt keyword và inject vào `additionalContext`. Attacker write được `.claude/memory/` (qua compromised subagent hoặc malicious MCP) → reroute Claude's next action.

### M3. `validate-push.sh:46-58` — Secret regex thiếu

Patterns hiện tại miss: AWS `AKIA[0-9A-Z]{16}`/`ASIA*`, generic `Bearer [A-Za-z0-9\-._~+/]{40,}`, Azure/GCP credential formats, password ngắn (<8 chars), YAML-format passwords.

### M4. `.gitignore` không cover production env files

Chỉ ignore `.env`, `.env.local`, `.env.*.local`. **Không ignore:** `.env.production`, `.env.staging`, `.env.test`, `.env.development` → có thể bị tracked vô ý.

### M5. `docs/technical/ARCHITECTURE.md` chưa commit

Trạng thái git `??`. Đây là **TD's primary owned artifact** mà chưa từng được commit. CODEMAP.md chỉ 79 lines cho 167+ harness files. → Harness ship product mà không có own architecture documentation.

### M6. `History_Update.md` ghi entry tương lai

File 57KB ở root có entry v1.31.2 trong khi commit cuối là v1.31.0 (a35690f). → Changelog không reliable, được viết speculatively. Vừa de-duplicate khỏi `docs/` nhưng vẫn churn.

### M7. `secrets-config.md` log scrubbing là aspirational

Rule mandate "scrub Authorization, Cookie, password, token, secret in logs" nhưng **không hook/script nào implement**. `log-writes.sh` log raw paths; `log-agent.sh` log raw agent names.

### M8. `session-start.sh:66` dump `head -20` của `active.md`

Nếu `active.md` chứa sensitive context (API keys paste khi debug, partial secrets) → echo unfiltered vào Claude context.

### M9. `validate-commit.sh:14-16` regex parser fragile

Fallback regex parser (jq-absent path) stops ở first `"`. Command chứa double quote (e.g., `git commit -m "fix \"auth\""`) bị truncate → security check pass khi nên block.

---

## 🟢 ĐIỂM MẠNH (xứng đáng giữ & nhân rộng)

### S1. `coordination-rules.md` là tài liệu mạnh nhất dự án

16 rules thể hiện tư duy distributed-systems hiếm thấy ở agent harness:
- Rule 6 (Layered Recovery)
- Rule 7 (Concurrency Classification)
- Rule 9 (Fail-Open for Optional Agents)
- Rule 14 (Circuit Breaker với backoff + fallback table)
- Rule 16 (A2A Handoff Contracts)

→ Nếu enforce được runtime → industry-leading.

### S2. Memory tier model có shape đúng

- `MEMORY.md` 50-line hard cap với auto-`/dream` consolidation
- 3-Question Relevance Gate (`context-management.md:215-231`)
- Load Decision Matrix
- Tier 2.5 namespace isolation (về mặt thiết kế)

→ Real anti-context-poisoning controls; phần lớn project không có gì tương đương.

### S3. Ownership topology rõ ràng

Split owned/read-only/forbidden documents (`CLAUDE.md:1-50`):
- Agents own `docs/technical/DECISIONS.md`, `ARCHITECTURE.md`, `CODEMAP.md`
- `PRD.md` read-only
- `.claude/agents/**` forbidden

→ Write-boundary clarity hiếm thấy.

### S4. Push-time multi-pattern secret scan + gitignored production state

`validate-push.sh` scan multi-pattern regex trên full staged diff (không chỉ filename) — đúng nơi để gate. `production/session-logs/` và `production/session-state/` gitignored → blast radius limited.

### S5. `pre-refactor-impact.sh` warn-only

Exit 0 trong all paths, không block legitimate writes. Avoid anti-pattern "security hook breaks workflow".

---

## 🎯 ACTION PLAN ƯU TIÊN

### P0 — Phải fix trước khi ship (1-2 ngày)

| # | Action | Files | Effort |
|---|--------|-------|--------|
| 1 | Xóa `exit 0` thừa ở `validate-commit.sh:137` và `session-start.sh:75` | 2 files | 5 phút |
| 2 | Pin `gitnexus@<exact-version>` trong `.mcp.json` | 1 file | 10 phút |
| 3 | Siết deny patterns trong `bash-guard.sh` cho `rm -rf` variants + `tee .env` | 1 file | 30 phút |
| 4 | Quyết định identity: "personal scaffold" vs "shipped product" | Strategic | Cuộc họp |
| 5 | Nếu (4) = shipped → human điền PRD §4, §6, §7, §8, §9 + ký approvals | `PRD.md` | 2-4 giờ |
| 6 | Sync badge counts: thêm `scripts/sync-badges.sh` chạy trong CI | New file + `audit.yml` | 1-2 giờ |

### P1 — Quality gates trước v1.32.0 (1 tuần)

| # | Action | Files |
|---|--------|-------|
| 7 | Wire `validate-skills.sh` vào `.github/workflows/audit.yml` | `audit.yml` |
| 8 | Thêm `shellcheck` step vào CI cho 18 hooks | `audit.yml` |
| 9 | Thêm JSON-schema validation cho `settings.json` vào CI | `audit.yml` |
| 10 | Smoke test cho `bash-guard.sh` block/warn paths | `tests/hooks/` (new) |
| 11 | Sanitize `log-writes.sh:30` JSONL injection | `log-writes.sh` |
| 12 | Mở rộng secret regex trong `validate-push.sh` (AWS, Bearer, Azure, GCP) | `validate-push.sh` |
| 13 | `.gitignore` thêm `.env.production/.staging/.test/.development` | `.gitignore` |

### P2 — Architecture hygiene (2 tuần)

| # | Action | Files |
|---|--------|-------|
| 14 | Skill catalog audit: collapse `*-architect`, `team-*`, stack-specific overlaps | `.claude/skills/` |
| 15 | Convert Rules 14/15/16 thành runtime hooks (PostToolUse ledger writer, SessionStop handoff checker) | New hooks |
| 16 | Cross-platform hook strategy: chọn Bash-only (drop .ps1) hoặc rewrite Node/Python | `settings.json` + hooks |
| 17 | Commit `docs/technical/ARCHITECTURE.md` + viết ADR-0001 capture v1.31.0 design | `docs/technical/` |
| 18 | Reorganize `docs/` thành `onboarding/`, `technical/`, `reference/`, `internal/`, `archived/` | `docs/` |
| 19 | Tạo `docs/onboarding/QUICKSTART.md` với 5-minute time-to-value path | New file |
| 20 | Move `History_Update.md` → `docs/internal/CHANGELOG.md`, fix entry tương lai | Move + edit |

### P3 — Strategic (sau v1.32.0)

- Implement `prompt-context.sh` allowlist để chống content-triggered injection (M2)
- Build automated merge tool cho `consensus/merged-decisions.md` (Rule 16)
- Vietnamese-native skill metadata nếu user base Vietnamese-first

---

## 📁 PHỤ LỤC — FILE INDEX

**Critical files cần đọc lại:**
- `PRD.md` (lines 19-169) — incomplete sections
- `.claude/hooks/validate-commit.sh:137` — dead code bypass
- `.claude/hooks/session-start.sh:75` — same dead code pattern
- `.claude/hooks/pre-refactor-impact.sh:19` — broken sed delimiter
- `.claude/settings.json:42-50` — bypass-able deny patterns
- `.mcp.json:6` — unpinned MCP
- `.claude/docs/coordination-rules.md` — contracts cần enforcement
- `.claude/docs/context-management.md:215-278` — Tier 2.5 isolation rules
- `.claude/memory/MEMORY.md` — Tier 1 index
- `tests/skills/validate-frontmatter.test.js` — duy nhất test file
- `.github/workflows/audit.yml` — CI cần expand
- `scripts/harness-audit.js` — rubric calibration
- `scripts/validate-skills.sh` — chưa wire vào CI
- `docs/technical/ARCHITECTURE.md` — chưa commit (`??`)
- `History_Update.md` — entry tương lai

**Skills overlap (candidate cho consolidation):**
- `cloud-architect`, `hybrid-cloud-architect`, `kubernetes-architect`, `backend-architect`, `database-architect`, `event-sourcing-architect`
- `team-backend`, `team-frontend`, `team-feature`, `team-mobile`, `team-release`, `team-ui`
- `*-patterns` family (13+ stack-specific)

---

## 🧭 GHI CHÚ CHO PROCESS DẦN

Đề xuất thứ tự xử lý từ rủi ro thấp / impact cao:

1. **Tuần 1:** P0 items #1, #2, #3 (mỗi cái <1 giờ, fix bug rõ ràng, không cần quyết định strategic)
2. **Tuần 1-2:** P0 #4 (identity decision) — block các P1/P2 phụ thuộc
3. **Tuần 2:** P0 #5, #6 sau khi #4 xong
4. **Tuần 3-4:** P1 batch (CI hardening)
5. **Tháng 2:** P2 batch (architecture hygiene, skill consolidation)

Mỗi P0/P1 item có thể trigger một `/spec` riêng để có verifiable plan trước khi thực thi.

---

**End of report.** Nếu cần đào sâu bất kỳ finding nào hoặc spawn `/spec` cho action cụ thể, báo lại.
