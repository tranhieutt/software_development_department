# History Update Log

Tài liệu này ghi lại lịch sử cập nhật tài liệu và source code của **Software Development Department** template.

---

## 🗓️ Lịch sử cập nhật

### [v1.54.0] - 2026-04-23

**Chu de:** Shared-state adoption layer - source-of-truth governance before Coordination Engineering

Dot cap nhat nay chap nhan Tier 2 Shared State Adoption lam buoc tiep theo
cua SDD, uu tien consolidation/adoption truoc khi build Coordination
Engineering day du.

#### Added - Source-of-truth registry

- Them `docs/technical/SOURCE_OF_TRUTH_REGISTRY.md`.
- Dang ky authority cho runtime, coordination policy, ADR, specs, UI specs,
  API docs, database docs, tasks, handoffs, ledger, memory, Codex adapter,
  `.claude/agents/*.md`, va `.claude/skills/*/SKILL.md`.
- Them authority levels moi: `agent-definition` va `runtime-state`.
- Danh dau `docs/technical/API.md`, `docs/technical/DATABASE.md`, va
  `docs/ui-spec/*` la planned/missing de tranh over-claim hien trang.
- Khoa rule conflict cho spec vs contract, contract vs implemented API,
  memory vs repo, va Codex adapter vs Claude runtime.

#### Added - Sprint 0.5 API reference skeleton

- Them `docs/technical/API.md` lam implemented API reference skeleton.
- Dinh nghia endpoint index, endpoint template, schema conventions,
  auth/authorization, error conventions, deprecation policy, va update rules.
- Cap nhat `SOURCE_OF_TRUTH_REGISTRY.md` de danh dau `API.md` la skeleton exists,
  endpoint inventory pending thay vi planned/missing.

#### Accepted - ADR-006 Shared State Adoption

- Them `docs/internal/adr/ADR-006-shared-state-adoption.md` voi status
  `Accepted`.
- Chon Tier 2 Shared State Adoption & Source-of-Truth Consolidation thay vi
  nhay thang sang Tier 3 Coordination Engineering.
- Giu shared state la read layer, khong phai decide layer; decision authority
  van theo human/producer/technical-director va Rule 3 escalation.
- Dinh nghia trigger de chi xem xet Tier 3 khi co du lieu thuc te ve conflict,
  negotiation, hoac orchestrator complexity.

#### Changed - Sprint 1 ledger read-gate adoption

- Cap nhat `.claude/skills/architecture-decision-records/SKILL.md` de dung
  `docs/internal/adr/` va bat buoc `/trace-history --risk High --last 20`
  truoc khi draft ADR.
- Cap nhat `.claude/docs/coordination-rules.md` voi read gate cho coordination
  policy changes, high-risk retry, va protocol removal/weaken.
- Cho phep ledger extension fields `prior_blocked_query` va
  `prior_failed_query` cho High-risk retry entries.
- Them SHOULD-tier ledger consult vao `.claude/skills/api-design/SKILL.md` va
  `.claude/skills/spec-evolution/SKILL.md`.
- Them checklist coordination policy vao `.github/PULL_REQUEST_TEMPLATE.md`.

#### Fixed - ADR governance drift

- Them ADR-006 vao `docs/technical/DECISIONS.md`.
- Sua ADR documentation references tu `docs/architecture/` / `docs/adr/` sang
  `docs/internal/adr/` va `docs/technical/DECISIONS.md`.

#### Documentation - analysis and rebuttal

- Them `docs/internal/harness-to-coordination-engineering.md` Revision 2.
- Them `docs/internal/harness-to-coordination-engineering-rebuttal.md`.
- Sua cac risk da review: contract store source of truth, trace-history factual
  gap, authority boundary, readiness over-claim, va premature audit tooling.
- Hoan `coordination-audit.js` cho den khi Tier 2 adoption va drift data du
  de justify automation.

#### Verification

- `git diff --check` pass cho package shared-state.
- `scripts/validate-skills.ps1` pass: 126/126, 57 warning nen.
- `scripts/harness-audit.js --compact` pass: 120/120, readiness warning nen.
- `scripts/trace-integrity-check.js` pass: 23 ledger entries, 1 agent metric,
  11 skill usage entries.

---

### [v1.53.0] - 2026-04-23

**Chu de:** Codex compatibility adapter - additive SDD support without Claude runtime changes

Dot cap nhat nay them lop adapter de SDD co the duoc dung trong Codex trong khi
van giu `.claude/` va `CLAUDE.md` la source of truth cho Claude Code.

#### Added - Phase 1 Codex adapter

- Them `AGENTS.md` lam entrypoint cho Codex.
- Them `.codex/INSTALL.md` huong dan tao junction skill discovery toi
  `.claude/skills`.
- Them `docs/codex-compatibility.md` voi parity matrix, tool mapping, manual
  hook equivalents, va verification checklist.

#### Added - Phase 2 `codex-sdd`

- Them `.claude/skills/codex-sdd/SKILL.md`.
- Route cac tinh huong Codex/Codex setup/Claude-to-Codex mapping tu
  `using-sdd` sang `codex-sdd`.
- Cap nhat `.claude/docs/skills-reference.md`.

#### Added - Phase 3 Codex preflight

- Them `scripts/codex-preflight.ps1`.
- Them `scripts/codex-preflight.sh`.
- Preflight kiem tra required files, git visibility, circuit-state schema,
  skill validation, harness audit, va trace integrity.

#### Enhanced - Phase 4 core metadata

- Them metadata backward-compatible cho `save-state`.
- Validator giam warning tu `58` xuong `57`.

#### Documentation - Phase 5

- Cap nhat `README.md` voi Codex compatibility section.
- Cap nhat README stats theo repo hien tai: `28` agents, `126` skills,
  `29` hook files.
- Bo sung Phase 5 checklist vao `docs/codex-compatibility.md`.

---

### [v1.52.0] - 2026-04-23

**Chu de:** Agent Skills synthesis - source verification, simplification, and lifecycle navigation

Dot cap nhat nay hap thu cac pattern cot loi tu bo Agent Skills theo cach
additive, khong thay doi Claude Code runtime path hien co.

#### New - `source-driven-development`

- Them `.claude/skills/source-driven-development/SKILL.md`.
- Dinh nghia workflow kiem chung technical decisions bang tai lieu chinh thuc
  cho framework, library, external API, platform behavior, migration, va
  deprecation.
- Xac lap ranh gioi voi `spec-driven-development`: spec quyet dinh "xay gi",
  source-driven-development kiem chung "pattern ky thuat co dung theo source
  chinh thuc hay khong".
- Khi official docs mau thuan voi approved spec, route sang `spec-evolution`
  thay vi tu sua spec/code am tham.

#### New - `code-simplification`

- Them `.claude/skills/code-simplification/SKILL.md`.
- Dinh nghia workflow behavior-preserving cleanup: giam complexity, cai thien
  readability, giu nguyen input/output/error/side-effect behavior.
- Them preconditions: target scope ro rang, behavior contract ro, verification
  path ro, va khong drive-by refactor.
- Neu cleanup lam thay doi behavior/public contract thi dung va route sang
  `spec-evolution` hoac workflow implementation phu hop.

#### New - `docs/technical/SDD_LIFECYCLE_MAP.md`

- Them lifecycle map 6 pha de dieu huong SDD hang ngay:
  `DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP`.
- Map tung pha sang skill chinh, exit evidence, va forbidden actions.
- Them cac path mau cho new feature, bug fix, review feedback, va
  documentation/ADR work.
- Tai lieu nay la navigation layer; `CONTROL_PLANE_MAP.md`, runtime hooks, va
  skill files van la source of truth chi tiet.

#### Integration - `using-sdd` and skills reference

- Cap nhat `.claude/skills/using-sdd/SKILL.md` de route:
  - latest/official/best-practice/version-sensitive technical decisions sang
    `source-driven-development`.
  - behavior-preserving cleanup/readability refactor sang
    `code-simplification`.
- Them lifecycle map reference vao `using-sdd`.
- Cap nhat `.claude/docs/skills-reference.md` voi hai skill moi.

---

### [v1.51.0] - 2026-04-23

**Chủ đề:** Harness Audit — Readiness Diagnostics Engine

#### Enhanced - `scripts/harness-audit.js`

- Thêm module `buildReadinessDiagnostics()` vào harness audit output.
- Thêm các hàm chẩn đoán chuyên biệt: `diagnoseHooks()`, `diagnoseSkillsAndAgents()`,
  `diagnoseMcp()`, `diagnosePermissions()`.
- Audit giờ trả về trường `readiness` với level (`ready | warning | blocked`),
  summary counts, và chi tiết issues theo từng category.
- Format `text` và `compact` hiển thị readiness level và danh sách issues.
- Helpers `issue()`, `maxReadinessLevel()`, `parseJsonFile()`, `extractHookScriptRefs()`
  được tách riêng để dễ test và mở rộng.

#### Added - `report_upgrade_for_codex_v1.md`

- Kế hoạch nâng cấp SDD để tương thích Codex (mục tiêu: dùng được cả Claude Code
  và Codex mà không làm yếu runtime path hiện tại).

---

### [v1.50.0] - 2026-04-22

**Chu de:** SDD systematic debugging - root cause before fixes

Dot cap nhat nay them workflow debugging co ky luat de ngan fix doan mo. Moi bug,
failing test, build failure, CI failure, performance regression, hoac unexpected
behavior phai qua root-cause investigation truoc khi de xuat/sua code.

#### New - `systematic-debugging`

- Them `.claude/skills/systematic-debugging/SKILL.md`.
- Dinh nghia Iron Law: khong fix truoc khi co root-cause investigation.
- Them 9-phase workflow: capture symptom, reproduce/bound failure, check recent
  changes, trace failure boundary, compare working patterns, form one
  falsifiable hypothesis, minimally test hypothesis, implement after confirmed
  cause, va close with evidence.
- Dinh nghia escalation sang `diagnose` khi root cause van unclear, intermittent,
  unfamiliar, hoac repeated fixes failed.

#### Integration - `using-sdd`

- Route bug/failing test/build/CI/performance/unexpected behavior sang
  `systematic-debugging`.
- Giu `diagnose` cho complex/intermittent/unfamiliar/repeated-failure bugs.
- Them default bug-fix chain:
  `systematic-debugging` -> `test-driven-development` ->
  `verification-before-completion`.

#### Documentation

- Cap nhat `docs/reference/DANH_SACH_LENH.md` de them slash command moi.

---

### [v1.49.0] - 2026-04-22

**Chu de:** SDD review feedback discipline - receiving code review workflow

Dot cap nhat nay them workflow xu ly feedback sau code review de ngan agent sua
tat ca comment mot cach may moc, bo qua blocker, hoac mark resolved khi chua co
bang chung verify.

#### New - `receiving-code-review`

- Them `.claude/skills/receiving-code-review/SKILL.md`.
- Bat buoc normalize tung finding voi severity, category, va disposition:
  `fix`, `reject`, `defer`, `needs-clarification`, hoac
  `route-to-spec-evolution`.
- Dinh nghia response plan truoc khi edit va yeu cau verification rieng cho
  tung finding da fix.
- Route spec/acceptance-criteria conflicts sang `spec-evolution`, behavior fixes
  sang `test-driven-development`, va completion claims sang
  `verification-before-completion`.

#### Integration - `using-sdd` and `subagent-driven-development`

- Route review comments, PR feedback, reviewer questions, va
  `CHANGES_REQUIRED` verdict sang `receiving-code-review`.
- Them review feedback discipline vao review/release workflow order.
- `subagent-driven-development` dung `receiving-code-review` de triage multi-item
  review feedback truoc khi gui fix instructions cho implementer.

#### Documentation

- Cap nhat `docs/reference/DANH_SACH_LENH.md` de them slash command moi.

---

### [v1.48.0] - 2026-04-22

**Chu de:** SDD spec evolution - spec readiness review and drift resolution

Dot cap nhat nay them hai workflow de giu spec la source of truth song: review
spec truoc khi lap plan/implementation, va xu ly co kiem soat khi spec khong
con khop voi code, test, review finding, user feedback, hoac platform reality.

#### New - `review-spec`

- Them `.claude/skills/review-spec/SKILL.md`.
- Review spec theo readiness matrix: objective, scope, behavior, contracts,
  architecture, dependencies, verification, rollback, va handoff readiness.
- Them verdict contract: `APPROVED`, `APPROVED WITH NOTES`,
  `CHANGES REQUIRED`, `ROUTE TO SPEC-EVOLUTION`.

#### New - `spec-evolution`

- Them `.claude/skills/spec-evolution/SKILL.md`.
- Dinh nghia spec evolution gate: dung execution khi approved spec va evidence
  thuc te mau thuan.
- Phan loai mismatch: Spec Gap, Spec Error, Code Drift, Reality Change, Scope
  Change, Architecture Drift.
- Bat buoc de xuat options va xin approval truoc khi sua spec/code/plan neu
  mismatch anh huong behavior, architecture, data, security, release policy, hoac
  acceptance criteria.

#### Integration - `using-sdd`

- Route existing spec readiness review sang `review-spec`.
- Route spec/code/test/review/user-feedback/platform mismatch sang
  `spec-evolution`.
- Them Spec Review Gate va Spec Evolution Gate vao pre-code gate matrix.
- Cap nhat default workflow cho work from existing spec va drift resolution.

#### Documentation

- Cap nhat `docs/reference/DANH_SACH_LENH.md` de them slash command moi.

---

### [v1.47.0] - 2026-04-22

**Chu de:** SDD completion discipline - verification-before-completion gate

Dot cap nhat nay tach completion verification thanh workflow rieng de ngan
false-completion claims. Agent phai co fresh evidence truoc khi noi task done,
fixed, passing, ready, clean, merge-ready, hoac truoc khi commit/PR/advance task.

#### New - `verification-before-completion`

- Them `.claude/skills/verification-before-completion/SKILL.md`.
- Dinh nghia Iron Law: khong claim complete neu khong co fresh verification
  evidence trong completion context hien tai.
- Them claim-to-proof matrix cho tests, build, lint, bug fix, regression test,
  requirements, agent completion, merge/PR readiness, docs, va manual/visual
  outcomes.
- Them verdict contract: `VERIFIED`, `PARTIAL`, `NOT VERIFIED`, `FAILED`.

#### Integration - `using-sdd`

- Route cac completion/success claims sang `verification-before-completion`.
- Cap nhat review/release workflow order de chay verification gate truoc code
  review, gate-check, va release checks khi claim readiness.

#### Documentation

- Cap nhat `docs/reference/DANH_SACH_LENH.md` de them slash command moi.

---

### [v1.46.0] - 2026-04-21

**Chu de:** SDD workflow discipline - using-sdd router, pre-code gates, agent-ready planning, subagent-driven execution

Dot cap nhat nay dua cac bai hoc tu Superpowers vao SDD theo huong behavior-shaping: agent phai route request qua workflow dung, khong viet code truoc gate, plan phai du kha nang giao cho worker, va approved multi-task plan co workflow thuc thi rieng voi review gates.

#### New - `using-sdd` workflow router

- Them `.claude/skills/using-sdd/SKILL.md` lam router/discipline layer cho moi request phat trien phan mem.
- Dinh tuyen tu natural language sang cac workflow SDD phu hop: `brainstorm`, `deep-interview`, `spec-driven-development`, `planning-and-task-breakdown`, `test-driven-development`, `subagent-driven-development`, `orchestrate`, `fork-join`, `code-review`, `gate-check`, va release skills.
- Them ma tran pre-code gates: Fast Gate, Spec Gate, Plan Gate, Interview Gate, Override Gate.
- Them mau bat buoc truoc production edit: `Pre-code gate: ...; next edit: ...; verification: ...`.
- `session-start.sh` hien thi SDD router reminder moi dau session de tranh agent bo qua skill routing.

#### New - Pre-code gate hooks

- Them `.claude/hooks/pre-code-gate.ps1` va `.claude/hooks/pre-code-gate.sh`.
- `settings.json` dang ky hook `Write|Edit`, uu tien Windows PowerShell va fallback Bash.
- Hook canh bao khi agent sap sua implementation-like files ma chua state gate va verification check.
- Hook bo qua docs/skill edits de tranh noise khi bao tri workflow docs.

#### Rewrite - `planning-and-task-breakdown` thanh agent-ready plan

- Rewrite `.claude/skills/planning-and-task-breakdown/SKILL.md` tu checklist cap cao thanh implementation plan co the giao cho agent thuc thi.
- Them Scope Check, File Responsibility Map, Dependency Mapping, No Placeholders, Self-Review, Execution Handoff.
- Moi task bat buoc co purpose, dependencies, exact files, acceptance criteria, RED/GREEN/REFACTOR steps, command, expected output, review step, va commit message.
- Execution Mode Recommendation gio ho tro: Inline TDD, `subagent-driven-development`, `orchestrate`, `fork-join`.

#### New - `subagent-driven-development`

- Them `.claude/skills/subagent-driven-development/SKILL.md`.
- Workflow thuc thi approved plan theo tung task tuan tu: fresh implementer subagent -> spec compliance review -> code quality review -> fix loop -> next task.
- Dinh nghia prompt contract cho implementer, spec reviewer, va code quality reviewer.
- Dinh nghia status contract: `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED`.
- Phan biet ro voi `orchestrate` (multi-domain waves) va `fork-join` (parallel disjoint workstreams).

#### Hardening - Spec and TDD gates

- `spec-driven-development`: bat spec output phai co Pre-Code Gate, Verification Method, va approval ro truoc khi TDD/code.
- `test-driven-development`: RED test khong con la duong vong de bat dau execution khi plan/spec chua duoc approve.
- `using-sdd`: them execution-mode selection table cho approved plans.

#### Verification

- `scripts/validate-skills.ps1`: PASS 118/118 skills, 0 required metadata failures.
- `settings.json`: JSON parse OK.
- `pre-code-gate.ps1`: verified warning for `landing-page/index.html` and silent skip for `.claude/skills/using-sdd/SKILL.md`.

---

### [v1.45.0] - 2026-04-21

**Chủ đề:** P0-1 per-agent circuit breaker, skill telemetry fix, agent-health report, skill usage report

Đợt cập nhật này đóng toàn bộ P0-1 và P0-3 từ audit v6, đồng thời hoàn thành Week 2 roadmap: per-agent circuit breaker (schema v2), ledger entries cho state transitions, agent-health CLI, skill usage report, và cull candidates list.

#### Fix - P0-1: Circuit breaker refactored sang per-agent model

- `circuit-state.json` migrate lên schema v2: `agents.<name>.{state, fail_count, fallback, ...}` thay vì flat global state.
- 5 agents tracked với fallback pairs từ coordination-rules: `backend-developer`, `frontend-developer`, `qa-engineer`, `data-engineer`, `diagnostics`.
- `circuit-guard.sh` v2: đọc `subagent_type` từ Task input, chỉ block/warn agent đang OPEN, hiển thị fallback agent để route.
- `circuit-updater.sh` v2: ghi success/fail vào đúng agent key, không ghi global.
- Mỗi state transition (CLOSED→HALF_OPEN, HALF_OPEN→OPEN, OPEN→HALF_OPEN TTL) tự động ghi entry vào `decision_ledger.jsonl` với `risk_tier: High`.

#### Fix - P0-3: Skill telemetry chuyển sang UserPromptSubmit hook

- Root cause xác nhận: Claude Code không fire `PostToolUse` cho `Skill` tool (internal harness construct, không đi qua tool lifecycle).
- `log-skill.sh` rewrite: chuyển từ PostToolUse sang `UserPromptSubmit` hook, detect `/skill-name` pattern từ user prompt.
- `settings.json` cập nhật: remove `Skill` matcher khỏi PostToolUse, thêm `log-skill.sh` vào UserPromptSubmit.
- `production/traces/skill-usage.jsonl` giờ được tạo và ghi data.
- Giới hạn đã ghi nhận: chỉ catch user-typed slash commands, không catch Claude-autonomous skill calls.

#### New - `scripts/agent-health.js` — per-agent circuit status report

- CLI report đọc `circuit-state.json` v2 và in table per-agent: state, fail count, last fail time, fallback agent.
- Tự động hiển thị `↳ Last transition` từ `decision_ledger.jsonl` nếu có.
- Flags: `--open` (chỉ OPEN/HALF_OPEN), `--json` (raw JSON output).

#### New - `scripts/skill-usage-report.js` — skill usage analysis + cull candidates

- Report đọc `skill-usage.jsonl` + scan `.claude/skills/` directory, phân loại: used / never-used / cull candidates.
- Cull heuristics: name token similarity ≥70%, domain cluster ≥4 members đều never-used.
- Tự động ghi `production/traces/skill-cull-candidates.md` — 48 candidates identified (heuristic, chưa có usage data thực).
- Flags: `--cull-only`, `--days N`, `--json`.
- **Lưu ý:** Không cull skills cho đến khi có ≥7 ngày usage data thực.

---

### [v1.44.0] - 2026-04-21

**Chủ đề:** Runtime diagnostics — P0 audit v6 (GPT-5.4 cross-review), trace integrity, schema discovery hooks

Đợt cập nhật này xử lý 3 trong 5 P0 findings từ audit v6: sửa corruption UTF-16 trong `agent-metrics.jsonl`, thêm `trace-integrity-check.js`, và cài debug hooks để discover Task/Skill tool input schema trước khi implement per-agent circuit breaker. P0-1 (per-agent circuit breaker) tạm dừng chờ schema verification.

#### Fix - `agent-metrics.jsonl` UTF-16 encoding corruption

- Dòng 2 bị UTF-16 LE encoding (NUL bytes xen kẽ) — không parseable bởi jq/Node/Python.
- Cleaned: giữ dòng schema header (UTF-8 OK), xóa dòng corrupt (data thủ công từ 2026-04-17, không có giá trị runtime).

#### New - `scripts/trace-integrity-check.js` — JSONL trace validator

- Script mới validate tất cả JSONL files trong `production/traces/`: check UTF-8 clean, no NUL bytes, one valid JSON object per line.
- Exit 0 = clean, exit 1 = failures. Candidate cho CI gate.
- Covers: `decision_ledger.jsonl`, `agent-metrics.jsonl`, `skill-usage.jsonl`.

#### New - Debug hooks for schema discovery (temporary)

- `debug-posttooluse.sh` + catch-all PostToolUse matcher trong `settings.json`: log `tool_name` của mọi PostToolUse event vào `production/session-logs/posttooluse-names.log` để verify xem `Skill` matcher có fire không.
- `circuit-guard.sh`: thêm one-shot dump Task input payload vào `production/session-logs/task-input-sample.json` để verify `subagent_type` field tồn tại trước khi implement per-agent circuit breaker.
- Cả 2 là temporary — sẽ remove sau khi có data.

#### Blocked - P0-1 per-agent circuit breaker

- Plan đã reviewed bởi CTO + Technical Director (session 2026-04-21).
- Consensus: per-agent schema đúng hướng, nhưng agent detection strategy cần verify trước — `subagent_type` field trong Task input chưa được confirm.
- Unblocks khi `task-input-sample.json` có data.

---

### [v1.43.0] - 2026-04-21

**Chủ đề:** Governance hardening — P0 audit remediation, agent consolidation, cross-platform hooks

Đợt cập nhật này đóng toàn bộ 5 P0 gaps từ audit v5 (2026-04-21): khôi phục deleted files, downgrade Rule 16 MUST→SHOULD, thêm PostToolUse decision extractor, skill telemetry, và xóa Governance Portal không có governance. Tiếp theo consolidate 5 agents thành 2, và hoàn thiện cross-platform hook support cho Windows PowerShell.

#### Fix - Git working tree cleanup

- Restore 5 accidentally-deleted files: `landing-page/assets/ai_orchestration.png`, `landing-page/assets/hero_bg.png`, `.claude/memory/archive/dreams/2026-04-19_10-26_dream.md`, `Software Development Department.code-workspace`, `report_upgrade_ver4_opus47.md`.

#### Fix - Rule 16 A2A Handoff downgraded MUST→SHOULD

- `.claude/docs/coordination-rules.md`: Rule 16 downgraded từ MUST → SHOULD. 0 handoff contracts được tạo sau nhiều sessions — full protocol quá friction. Lightweight text summary thay thế, không cần tooling.

#### New - `extract-decisions.sh` — PostToolUse decision extractor

- Hook mới trigger PostToolUse/Write|Edit: quét content được write cho decision markers (`## Decision`, `**Decision:**`, `> **Note:**`, `// NOTE:`, `// GOTCHA:`, `// WORKAROUND:`, `# FEEDBACK:`) và tự động append vào Tier 2 memory files.
- Fail-open per Rule 9.

#### New - `log-skill.sh` — skill invocation telemetry

- Hook mới trigger PostToolUse/Skill: log mỗi skill invocation vào `production/traces/skill-usage.jsonl`.
- Prerequisite cho skill cull decisions trong tương lai — telemetry trước, cull sau.

#### Chore - Seed Tier 2 memory với data thực

- `user_role.md`: profile user (Vietnamese, owner/architect, Git Bash on Windows, approves before implement).
- `project_tech_decisions.md`: stack constraints, governance decisions (circuit breaker, ledger, Rule 16 downgrade, skill telemetry, git branch policy).
- `feedback_rules.md`: rules từ audit sessions (telemetry trước expansion, MUST cần hook, options trước implement, commit thường xuyên).

#### Chore - Remove SDD Governance Portal

- Xóa `docs/internal/portal.html`, `docs/internal/portal-data.js`, `scripts/portal-update.sh` — portal không có ADR, không có schema, pipeline ghi vào file versioned.
- Xóa portal-update trigger khỏi `scripts/ledger-append.sh`.

#### Refactor - Agent consolidation: 31 → 28 agents

- `qa-lead` + `qa-tester` → `qa-engineer`: unified agent, tự chọn lead/tester mode dựa trên task.
- `investigator` + `verifier` + `solver` → `diagnostics`: 3-phase pipeline (Investigate → Verify → Solve) enforce tuần tự, không thể skip phase.
- Xóa 2 empty specialist stubs: `.claude/memory/specialists/investigator.md`, `.claude/memory/specialists/qa-tester.md`.
- Update Circuit Breaker fallback table và Tier 2.5 specialist registry.

#### Chore - Skills cleanup: 118 → 116

- Xóa `_SKILL_TEMPLATE.md` và `templates/SKILL.md.tmpl` (non-skill files không invoke được).
- Target ≤90 skills revised — không phù hợp với universal framework (SDD build software ở mọi stack).

#### Feat - B8: Cross-platform hook dispatch (Windows PowerShell support)

- `validate-push.ps1`: PS1 counterpart mới cho `validate-push.sh` — protected branch warning + 16 secret patterns scan.
- `bash-guard.ps1`: thêm `rm -rf ./` pattern; fix `Warn-IfMatch` → `Add-Warning` (PSUseApprovedVerbs).
- `settings.json`: tất cả 3 guard hooks dùng `pwsh ... || bash ...` dispatch — PS1 trên Windows native, bash fallback trên Git Bash/Unix.

---

### [v1.42.0] - 2026-04-19

**Chủ đề:** SDD Governance Portal — dashboard ledger trực quan và tích hợp portal-update vào ledger-append

Đợt cập nhật này bổ sung Governance Portal (HTML dashboard) hiển thị decision ledger dưới dạng bảng tương tác, kèm script tự động cập nhật portal-data.js mỗi khi có entry mới được append vào ledger. Đồng thời dọn dẹp 5 file retrospective cũ không còn được tham chiếu.

#### New - `docs/internal/portal.html` - SDD Governance Portal dashboard

- Dashboard HTML hiển thị toàn bộ decision ledger (`decision_ledger.jsonl`) dưới dạng bảng lọc được theo agent, risk tier, outcome, và date range.
- Giao diện tiếng Việt, dark-mode-ready, dùng JetBrains Mono cho data rows.

#### New - `docs/internal/portal-data.js` - ledger data snapshot cho portal

- File JS inject `window.LEDGER_DATA` array — được portal.html load trực tiếp không cần backend.
- Được sinh ra tự động bởi `scripts/portal-update.sh` / `scripts/portal-update.ps1`.

#### New - `scripts/portal-update.sh` / `scripts/portal-update.ps1` - auto-regenerate portal data

- Script đọc `production/traces/decision_ledger.jsonl`, parse từng entry, và ghi lại `docs/internal/portal-data.js`.
- Chạy fail-open trong background sau mỗi lần `ledger-append.sh` được gọi.

#### Fix - `scripts/ledger-append.sh` - tích hợp portal-update trigger

- Thay block verbose logging bằng trigger gọi `portal-update.ps1` (Windows) hoặc `portal-update.sh` (Unix) sau mỗi append.
- Chạy background (`&`), fail-open — không block luồng chính.

#### Chore - xóa 5 file retrospective cũ

- Xóa `report_new_capacity_sdd_with_gitnexus.md`, `report_upgrade_MAS.md`, `report_upgrade_claude_mem.md`, `report_upgrade_claude_mem_final.md`, `report_upgrade_claude_mem_other.md` khỏi `docs/internal/retrospectives/`.
- Các file này không còn được tham chiếu và đã được thay thế bởi session logs trong `.claude/memory/archive/`.

---

### [v1.40.0] - 2026-04-19

**Chủ đề:** Audit remediation cho skill layer - sửa routing `/ui-spec`, khôi phục template `brainstorm`, và rewrite release-gating sang ngữ cảnh software delivery

Đợt cập nhật này đóng 3 vấn đề thực tế trong hệ skill: tên skill `/ui-spec` bị lệch so với thư mục và control plane, `brainstorm` tham chiếu tới template không tồn tại, và bộ skill release-gating (`gate-check`, `launch-checklist`, `release-checklist`) vẫn còn nghiêng mạnh về game production thay vì phần mềm/web/api/app delivery. Sau patch này, routing nhất quán hơn, luồng brainstorm không còn vỡ ngay ở bước tạo output, và release governance phản ánh đúng operational reality của Software Development Department.

#### Fix - `.claude/skills/ui-spec/SKILL.md` - chuẩn hóa skill name

- Đổi frontmatter `name: ui-spec-creation` -> `name: ui-spec` để khớp với thư mục `.claude/skills/ui-spec/`, invocation `/ui-spec`, và các tài liệu điều phối.
- Loại bỏ nguy cơ routing fail hoặc chọn sai capability dù file skill vẫn tồn tại trên đĩa.

#### New - `.claude/docs/templates/product-concept.md` - khôi phục template nguồn cho `brainstorm`

- Tạo mới template `product-concept.md` tại đúng path mà `.claude/skills/brainstorm/SKILL.md` tham chiếu.
- Template cover các phần cốt lõi cho concept synthesis: problem/why now, chosen concept, target users, core flow, product pillars, MVP scope, technical considerations, open questions, và next steps.
- Kết quả: `brainstorm` có thể tạo concept document theo workflow đã mô tả thay vì dừng ở bước tham chiếu tài liệu thiếu.

#### Rewrite - `.claude/skills/gate-check/SKILL.md` - phase gate cho software delivery

- Rewrite toàn bộ phase definition từ tư duy game loop / playtest / certification sang software lifecycle: requirements, stack setup, CI/CD, environments, QA/UAT, observability, rollback, support readiness.
- Thay các quality gates như "core loop", "playtest", "levels/assets complete" bằng acceptance criteria, release evidence, logs/metrics/error reporting, deployment script, và release runbook.
- Follow-up actions cũng được cập nhật để trỏ sang skill phù hợp với hệ software hiện tại.

#### Rewrite - `.claude/skills/launch-checklist/SKILL.md` - go-live checklist cho sản phẩm phần mềm

- Thay các mục game/platform-specific như anti-cheat, achievements, ESRB/PEGI, target FPS, multiplayer server checks bằng launch checks phù hợp cho software: migrations, feature flags, telemetry, support playbooks, launch comms, incident escalation, rollout and rollback readiness.
- Sign-off model được đổi sang Product / Engineering / QA / Release / Security / Support thay cho các vai trò production/game-oriented.
- Checklist giờ usable cho web app, backend platform, SaaS feature launch, mobile app, và desktop software.

#### Rewrite - `.claude/skills/release-checklist/SKILL.md` - pre-release validation theo surface

- Đổi argument model từ `platform: pc|console|mobile|all` sang `surface: web|api|desktop|mobile|all`.
- Bổ sung các section surface-specific mới:
  - `web`: browser coverage, responsive verification, security headers, CDN/cache behavior
  - `api`: versioning, compatibility, webhook/auth/rate limit validation, migration safety
  - `desktop`: installer/signing/auto-update/install-upgrade-uninstall flows
  - `mobile`: app-store compliance, permissions, background behavior, deep links, purchases
- Store/distribution section được đổi thành release assets + deployment readiness + incident communication theo chuẩn software release.

#### Tác động

- **Skill routing reliability** tăng cho `/ui-spec`: invocation path giờ thống nhất với filesystem và docs.
- **Brainstorm workflow completeness** được khôi phục: không còn tham chiếu template rỗng/missing ở đường dẫn chuẩn.
- **Release governance fit** tăng rõ rệt cho SDD context: các verdict từ `gate-check`, `launch-checklist`, `release-checklist` giờ phản ánh software delivery thay vì tạo false blockers/noise kiểu game production.
- **Validator status** không phát sinh fail mới; fail duy nhất còn lại sau patch vẫn là `skill-technical-document` (vấn đề độc lập đã được tách riêng).

---

### [v1.39.0] - 2026-04-19

**Chủ đề:** P1 Đợt 1 remediation từ Architecture Audit 2026-04-19 — structural integrity cho Role layer + Governance precedence

Đợt 1 của P1 backlog tập trung vào 3 gap cấu trúc: agent frontmatter không hoàn chỉnh, precedence rule chỉ cover command↔skill (thiếu 4/5 layer), và Control-Plane không được viết ra thành 1 doc duy nhất. Sau patch này, letter-of-the-spec compliance tăng thêm một bậc; phần còn lại của backlog (Đợt 2+) sẽ xử lý ledger orchestrator, Tier 2 description rewrite, và các §15 artifacts còn thiếu.

> **Audit correction (verify trước khi sửa):** audit ban đầu claim 3 agent thiếu delegation/escalation (`accessibility-specialist`, `security-engineer`, `ui-spec-designer`). Khi re-verify, chỉ `ui-spec-designer` thực sự thiếu; 2 agent còn lại đã có Coordination section đầy đủ. Patch này chỉ sửa `ui-spec-designer` và không chạm 2 file kia.

#### Fix — `.claude/agents/ui-spec-designer.md` — complete frontmatter + coordination

- Bổ sung frontmatter fields đang thiếu: `tools: Read, Glob, Grep, Write, Edit`, `model: sonnet`, `maxTurns: 15`, `skills: [ui-spec, spec-driven-development, design-system, frontend-patterns]`.
- Thêm section "Documents You Own / Read / Never Modify" để phân định ranh giới với `ux-designer` (design/) và PRD.md (human-only).
- Thêm Coordination section (cross-agent consultation với `ux-designer`, `product-manager`, `frontend-developer`, `accessibility-specialist`, `qa-lead`) và Escalation ladder (scope → PM, architecture → technical-director, a11y block → producer).
- Kết quả: `ui-spec-designer` giờ hợp lệ theo YAML schema Claude Code expects, và có đường dẫn escalation rõ ràng — khớp luồng với 30 agent còn lại.

#### Fix — `.claude/docs/skills-precedence.md` — expand to 5-layer precedence matrix + English

- Bản cũ chỉ cover Layer 5 (command ↔ skill) và viết bilingual VN/EN.
- Bản mới rewrite hoàn toàn bằng tiếng Anh và mở rộng thành 5-layer ladder: **L1 Critical Rules** (CLAUDE.md §🚨) → **L2 Coordination Rules** (Rules 1–16 + ADRs) → **L3 Permission Lists** (`settings.json`) → **L4 Hook Behaviors** (hook scripts) → **L5 Skill Precedence** (command ↔ skill).
- Bổ sung resolution protocol: higher layer luôn thắng; conflict cùng layer có escalation path cụ thể (L1 → human, L2 → ADR/Rule 3, L3 → JSON merge order, L4 → registration order + shared state orchestrator, L5 → skill-boundary table).
- Thêm 5 cross-layer interaction được document rõ (hooks implement, not invent; settings revoke tool access; critical rules block hook writes; multiple hooks on same file need orchestrator; memory precedence).
- Closes audit §14.5 "Rule precedence not explicit" — trước chỉ partially resolved, giờ resolved fully.

#### New — `docs/technical/CONTROL_PLANE_MAP.md`

- Single-doc map theo §15.1 của Architecture Spec: task-type → stage (command) → primary skill → owning agent → exit criteria → fallback → state update.
- Cover 6-stage fullstack ladder (`/plan` → `/spec` → `/vertical-slice` → `/tdd` → review → merge), 4-stage incident path (`/diagnose` investigator → verifier → solver → TDD), task-type routing table (10 task types), fallback & escalation ladder (Rule 6 → Rule 14 → Rule 3 → human), state update points table (7 canonical state files), và human-vs-AI decision rights table.
- Ghi rõ 4 Open Items còn lại: ledger orchestrator (P1), Hook Responsibility Matrix (P2, §15.4), Memory Retrieval Map (P2, §15.5), Stage Transition State Machine (P2, §15.3).
- Kết quả: khi một agent mới vào hệ thống, 1 file này trả lời được 4 câu "where am I / which skill+agent / exit criteria / fallback" mà không phải grep nhiều doc rời rạc.

#### Tác động

- **Spec compliance** ước tính tăng từ ~85% lên ~88%: đóng P1 items 1, 2, 3, 4, 6. Còn P1 item 5 (ledger orchestrator — cần test plan) và P1 item 7 (Tier 2 descriptions) cho các đợt sau.
- **Role layer score** (audit §3.3) từ 85% → ước tính 95% (30/31 → 31/31 agent hoàn chỉnh frontmatter).
- **Governance score** (audit §3.1) từ 92% → ước tính 97% (skills-precedence giờ cover đủ 5 layer, không còn bilingual drift).

---

### [v1.38.0] - 2026-04-19

**Chủ đề:** P0 remediation từ Architecture Audit 2026-04-19 — đóng 3 spec-breaking gap

Audit toàn hệ thống (`docs/internal/AUDIT_2026-04-19.md`, 6 parallel read-only subagents) phát hiện 3 P0 blocker phá vỡ letter-of-the-spec. Patch này đóng cả 3.

> **Audit correction (cùng session):** một audit stream false-negative báo ADR-004 và ADR-005 *thiếu*; thực tế cả hai file đã tồn tại từ v1.36.0/v1.37.0 với 138/179 dòng content đầy đủ. Audit report đã được sửa và ghi chú ở header. Không có thay đổi nào đối với ADR trong patch này.

#### Fix — `CLAUDE.md:23` — `/ui-spec` skill name

- Đổi reference `ui-spec-creation` → `ui-spec` để khớp với filesystem (`.claude/skills/ui-spec/`).
- Trước: invoke `/ui-spec` sẽ fail vì không tìm thấy skill `ui-spec-creation`.

#### Fix — `.claude/hooks/session-stop.sh` — auto-dream error trap

- `auto-dream.sh` trước đây invoke ngầm bằng `2>/dev/null` → mọi failure bị nuốt silently.
- Patch: capture `$?` sau khi chạy; nếu non-zero → log vào `production/session-logs/hook-errors.log` và surface warning trong session summary.
- Thực thi Coordination Rule 9 (fail-open for optional background agents): auto-dream fail không được block session teardown nhưng phải để lại dấu vết.

#### Fix — `.claude/hooks/session-start.sh` — bootstrap `active.md` template

- `production/session-state/` là thư mục gitignored; sau mỗi `session-stop.sh` (removes `active.md`) hoặc fresh clone, file biến mất → crash recovery contract §5.8 không có gì để recover.
- Patch: nếu `active.md` không tồn tại, `session-start.sh` tự sinh template mới với YAML frontmatter hợp lệ (`session`, `branch`, `tags`, `started`, `lastActive`) và một `<!-- STATUS -->` block khởi tạo.
- Kết quả: live-checkpoint contract luôn được duy trì từ turn đầu tiên.

#### New — `docs/internal/AUDIT_2026-04-19.md`

- Báo cáo audit toàn hệ thống v1.0: 6 stream (governance/runtime/roles/memory/coordination/§14 anomalies), compliance score ~80%, roadmap P0/P1/P2.
- Có ghi chú chỉnh sửa (correction note) ở executive summary sau khi phát hiện subagent false-negative về ADRs.

#### Tác động

- **Spec compliance** tăng từ ~80% (audit sau correction) lên ước tính ~85%: đóng cả 3 P0, còn lại P1/P2 về documentation artifacts (§15 Control-Plane Map, Hook Responsibility Matrix, v.v.).
- **Runtime behavior** không thay đổi với happy path; error path của `auto-dream` giờ observable.
- **Fresh clone experience:** session đầu tiên trên máy mới sẽ có active.md hợp lệ ngay lập tức.

---

### [v1.37.0] - 2026-04-18

**Chủ đề:** UFSM Phase 2+3 — Hoàn thành vòng lặp Circuit Breaker (Sprint A Items 1 & 2)

Phiên bản này đóng nốt 2/3 Phase còn thiếu của ADR-004 Unified Failure State Machine. Trước sprint này, `circuit-guard.sh` chỉ *đọc* trạng thái mà không bao giờ *ghi* — circuit không bao giờ transition sang HALF_OPEN hay OPEN trong thực tế. Sau sprint, toàn bộ vòng lặp UFSM hoạt động đầy đủ: PreToolUse đọc state, PostToolUse ghi state.

#### New — `.claude/hooks/decision-ledger-writer.sh` (Phase 2 — PostToolUse:Task)

- Tự động append 1 entry `ledger/v1` vào `production/traces/decision_ledger.jsonl` sau **mỗi Task tool invocation**, thực thi Rule 15 cho sub-agent calls.
- `task_id` được tạo từ `session + sha256(description + timestamp)` — stable và unique.
- Outcome classification từ `exit_code`: `0 → pass`, `2 → blocked`, `else → fail`.
- Risk classification từ task content (regex matching giống `log-commit.sh`):
  - **High:** auth, security, secret, migration, database schema, infra, production, deploy, circuit, hooks, settings.json, credentials
  - **Low:** docs, readme, changelog, explain, describe, summarize, analysis, report
  - **Medium:** mọi thứ còn lại (default)
- Fail-open tuyệt đối (always exit 0) — không bao giờ block caller.

#### New — `.claude/hooks/circuit-updater.sh` (Phase 3 — PostToolUse:Task)

- Cập nhật `.claude/memory/circuit-state.json` sau mỗi Task tool call theo transition rules trong ADR-004.
- **Success (exit_code 0):** reset `fail_count=0`, `retry_backoff_s=0`, `state=CLOSED`.
- **Failure trong CLOSED:** `fail_count++` → nếu `fail_count >= 3`: chuyển sang `HALF_OPEN`.
- **Failure trong HALF_OPEN:** `fail_count++` → nếu `fail_count >= 4`: chuyển sang `OPEN`.
- **OPEN:** chỉ refresh `last_fail_ts`, không increment thêm (TTL/reset xử lý bởi `circuit-guard.sh` read-path).
- Backoff schedule: Fail 1 → 2s, Fail 2 → 4s, Fail 3+ → 8s.
- Auto-tạo `circuit-state.json` nếu missing (mirrors `circuit-guard.sh` behavior).
- Fail-open tuyệt đối (always exit 0).

#### settings.json — Đăng ký PostToolUse:Task block mới

```json
{
  "matcher": "Task",
  "hooks": [
    { "command": "bash .claude/hooks/decision-ledger-writer.sh", "timeout": 5 },
    { "command": "bash .claude/hooks/circuit-updater.sh",        "timeout": 5 }
  ]
}
```

Thứ tự: `decision-ledger-writer` trước (ghi audit trail trước), `circuit-updater` sau (cập nhật state dựa trên outcome).

#### UFSM State Machine — Trạng thái sau Sprint A Items 1 & 2

```
Task invocation
    │
    ├── PreToolUse ──► circuit-guard.sh     [Phase 1 ✅ v1.33]
    │                  (đọc state, block nếu OPEN)
    │
    └── PostToolUse ─► decision-ledger-writer.sh [Phase 2 ✅ v1.37]
                       (append ledger entry)
                    ─► circuit-updater.sh         [Phase 3 ✅ v1.37]
                       (ghi state transitions)
```

#### Số liệu v1.37.0

- Files mới: **2** (circuit-updater.sh + decision-ledger-writer.sh)
- Files edit: **1** (settings.json — thêm PostToolUse:Task block)
- LOC thêm: ~220 (không tính CHANGELOG)
- Hook inventory: **18 → 20** (+2 PostToolUse Task hooks)
- UFSM completeness: Phase 1 ✅ / Phase 2 ✅ / Phase 3 ✅ — **100% complete**
- ADR-004 status: **CLOSED** (tất cả 3 phases đã implement)

#### Còn lại trong Sprint A (items 3 & 4)

- Item 3: Xóa `production/session-state/circuit-state.json` (legacy nested schema, deprecated)
- Item 4: Viết ADR-005 — chính thức resolve mâu thuẫn Rule 14 (per-agent) vs ADR-004 (global flat)

---

### [v1.36.0] - 2026-04-18

**Chủ đề:** Sprint "SDD Enforcement Closure" — Activate Rule 15 (Decision Ledger) & Memory Tier 2 persistence

Phiên bản này đóng 2/3 enforcement gap đã được xác định qua architecture review (Anthropic CTO perspective). Trước sprint này, các quy tắc governance (Rule 15, Memory Tier 2) chỉ tồn tại dưới dạng *documentation theater* — không có hook/script nào thực sự ghi dữ liệu. Sau sprint, mọi commit tự động log vào decision ledger, và user prompts với explicit markers tự persist vào Tier 2 memory.

Epic 2 (Circuit Runtime) được chủ động **skip** vì phát hiện contradiction giữa `coordination-rules.md` Rule 14 (per-agent fallback) và `ADR-004` (unified flat state) — cần team decision chính thức trước khi implement.

#### Epic 3 — Decision Ledger Writer (Rule 15)

**Fix 1 — UTF-16 encoding corruption (`production/traces/decision_ledger.jsonl`)**
- Entry #2 của ledger bị PowerShell `Out-File` default encoding ghi dưới dạng UTF-16 LE, khiến JSON.parse fail và `file` command báo `data` thay vì `NDJSON`.
- Fix: Node script decode UTF-16 → re-encode UTF-8 no-BOM. 2 entries legacy được preserve nguyên content.

**New — `scripts/ledger-append.sh` (115 LOC)**
- CLI helper append 1 entry vào ledger theo schema `ledger/v1` (Rule 15).
- Flags: `--agent`, `--task-id`, `--choice`, `--outcome`, `--risk`, `--request`, `--reasoning`, `--duration-s`.
- Auto-populate `ts` (ISO UTC), `session` (git branch).
- Validation: enum check cho `outcome` (pass/fail/blocked/skipped) và `risk` (High/Medium/Low).
- JSON construction: prefer `jq`, fallback `node` (cho Windows git bash không có jq).
- Fail-open per Rule 9 (missing deps → warning + exit 2, no block).
- Atomic append qua `>>` (O_APPEND, safe cho <4KB writes).

**New — `.claude/hooks/log-commit.sh` (80 LOC)**
- PostToolUse hook cho Bash matcher: tự động log mọi `git commit` vào ledger.
- Risk classification từ file patterns:
  - **High:** `.claude/hooks/`, `.claude/agents/`, `.claude/settings`, `src/auth/`, `migrations/`, `infra/`, `scripts/`
  - **Low:** docs-only commits (`docs/`, `README*`, `CHANGELOG*`, `*.md`)
  - **Medium:** mọi thứ còn lại (default)
- Outcome từ `tool_response.exit_code` (0 → pass, else fail).
- Fail-open tuyệt đối (suppress stderr, silent skip on parse error).
- Registered vào `settings.json` PostToolUse > matcher: `Bash`, timeout 5s.

**New — `scripts/trace-history.sh` (115 LOC)**
- Backing executable cho skill `/trace-history`.
- Flags: `--agent`, `--risk`, `--task`, `--outcome`, `--since`, `--last`, `--format`.
- Output modes: `pretty` (timeline với risk badges 🔴🟡🟢 + outcome emojis ✅❌⛔⏭️) hoặc `json` (raw array).
- Auto-hint `/resume-from <task_id>` khi có fail/blocked entries.
- Skips legacy entries (pre-`ledger/v1` schema) trong pretty mode, preserve trong json mode.

**Refactor — `.claude/skills/trace-history/SKILL.md`**
- Bỏ 60 LOC boilerplate (manual parsing instructions cho LLM).
- Skill giờ delegate hoàn toàn sang `scripts/trace-history.sh $ARGUMENTS`.
- Deterministic output thay vì LLM-tokenized rendering per query.

#### Epic 1 — Memory Tier 2 Persistence

**New — `.claude/docs/memory-write-schema.md` (110 lines)**
- Định nghĩa explicit markers deterministic (không LLM classify) để extract insights từ user prompts.
- Bilingual triggers: EN (`feedback:`, `don't`, `from now on`, `we chose`, `I prefer`) + VN (`từ giờ`, `đừng`, `quyết định:`, `chọn dùng`, `tôi là`, `tôi dùng`, `tôi thích`).
- 4-file routing: `feedback_rules.md` / `project_tech_decisions.md` / `user_role.md` / `reference_links.md`.
- Size bounds: body 10-400 chars (reject noise + paste dumps).
- Dedup: case-insensitive exact substring match trước append.
- Size guard: 300-line warning (non-blocking, gợi ý `/dream`).
- Fail-open tuyệt đối per Rule 9.

**New — `.claude/hooks/persist-memory.sh` (130 LOC)**
- UserPromptSubmit hook implement schema trên.
- First-match-wins scanning với 15 regex markers (ưu tiên explicit labels → imperative sentences → Vietnamese).
- Auto-tạo target file với frontmatter nếu chưa tồn tại.
- Append block format: `## YYYY-MM-DD — <auto-title>\n**Trigger:** "..."\n**Source:** user-prompt\n<body>`.
- Ledger tie-in: marker type `feedback|project` với body chứa `security|migrate|break|prod|critical` → auto-append 1 ledger entry risk=High (tránh spam cho insights thường).
- Errors log vào `production/session-logs/memory-write-errors.log` (không expose UI).
- Registered vào `settings.json` UserPromptSubmit, timeout 5s.

#### Cleanup

**Deleted — `docs/technical/sdd-architecture.{png,svg}` + `sdd_architecture{,_en}.html`**
- 4 file architecture diagram legacy (~200 KB) được thay thế bởi `docs/hooks_visual_report.html` từ v1.35.
- Decision pending từ v1.34 refactor, clear trong sprint này.

#### Skipped — Epic 2 (Circuit Runtime)

- Phát hiện **doc-vs-ADR contradiction:**
  - `coordination-rules.md` Rule 14 spec **per-agent** fallback pairs (backend→fullstack, qa-tester→qa-lead)
  - `ADR-004` spec **global flat** unified state (và đã được `circuit-guard.sh` implement)
- Không phải bug code — là governance mismatch cần ADR-005 để chính thức deprecate 1 trong 2.
- Legacy file `production/session-state/circuit-state.json` (2033 bytes, nested schema, không hook nào dùng) an toàn xoá sau khi ADR quyết định.

#### Số liệu v1.36.0

- Files mới: **5** (2 hooks + 2 scripts + 1 schema doc)
- Files edit: **2** (settings.json, trace-history SKILL.md)
- Files xoá: **4** (legacy architecture diagrams)
- LOC thêm: ~450 (không tính CHANGELOG)
- Hook inventory: **16 → 18** (PostToolUse Bash + UserPromptSubmit persist-memory)
- Rule enforcement mới: **Rule 15 active** (decision ledger), **Tier 2 persistence active**
- Test coverage: 24 fixture tests (5 Phase 3.2 + 3 Phase 3.3 + 8 Phase 3.4 + 8 Phase 1.2) — all pass

---

### [v1.35.0] - 2026-04-18

**Chủ đề:** Hooks Visual Report — Redesign chuẩn Anthropic Technical Docs

Phiên bản này tập trung hoàn toàn vào chất lượng tài liệu kỹ thuật. File `hooks_visual_report.html` được viết lại từ đầu — từ phong cách editorial/magazine sang chuẩn technical documentation của Anthropic, kèm nội dung song ngữ (mô tả tiếng Việt, thuật ngữ kỹ thuật giữ nguyên tiếng Anh).

#### Redesign: `docs/hooks_visual_report.html` — Anthropic Technical Standard

**Thay đổi cấu trúc:**
- Bỏ layout full-width editorial → chuyển sang shell 2 cột: sidebar navigation cố định + main content area
- Sidebar sticky với active-link highlighting qua `IntersectionObserver`
- Font stack: `Inter` (body) + `JetBrains Mono` (code/identifiers) thay vì `Archivo` + `Source Serif 4`

**Thay đổi design system:**
- Loại bỏ card grid (`hook-grid`) — thay bằng `hook-table` (bảng tham chiếu kỹ thuật chuẩn)
- Scroll reveal animation bị xóa (không phù hợp tài liệu kỹ thuật)
- Color palette giữ nguyên Anthropic warm cream (`#F7F4EF`) nhưng tông trung tính hơn
- Thêm `callout` component cho warning block (Security Layer)
- `priority-list` layout: grid 3 cột (index + body + badge) thay vì card

**Thay đổi nội dung:**
- Toàn bộ mô tả dịch sang tiếng Việt tự nhiên
- Giữ nguyên tiếng Anh: tên hook, event names, CLI flags, file paths, code identifiers, thuật ngữ kỹ thuật (`audit trail`, `idempotent`, `CIA triad`, `JSONL`...)
- Eyebrow path: "SDD Framework / Tài liệu nội bộ / Hook System"
- Section `§ 00` bổ sung diagram ASCII với syntax highlighting (`.hl` / `.dim` spans)

**Files thay đổi:**
- `docs/hooks_visual_report.html` — rewrite hoàn toàn (~1,200 dòng)

#### Số liệu v1.35.0:

- Files rewritten: 1 (`hooks_visual_report.html`)
- Components mới: sidebar nav, hook-table, callout, priority-list
- Nội dung: 100% bilingual (VI mô tả + EN technical terms)

---

### [v1.34.0] - 2026-04-18

**Chủ đề:** Dream Loop Termination — Sửa vòng lặp vô hạn & chuẩn hóa Skills/Commands Boundary

Phiên bản này giải quyết triệt để 2 pathologies đã được phát hiện qua phân tích thực tế: (1) vòng lặp dream vô hạn do `auto-dream.sh` luôn tạo archive file ngay cả khi không có gì thay đổi, (2) filename bug khiến dream log bị ghi sai tên. Đồng thời chuẩn hóa ranh giới Commands vs Skills và nâng cấp 2 skills quan trọng.

#### Fix 1 — Dream Loop: No-op Guard (`auto-dream.sh`)

- **Vấn đề:** `auto-dream.sh` luôn ghi file `*_dream.md` vào archive sau mỗi lần chạy, dù không archive/prune/flag gì cả. Điều này khiến `session-stop.sh` đếm archive files ngày càng tăng → Condition 1 (MEMORY.md > 40 lines hoặc archive count) luôn đúng → dream kích hoạt mỗi session → vòng lặp vô hạn.
- **Fix:** Thêm guard: chỉ ghi `$DREAM_LOG` nếu `ARCHIVED > 0 || PRUNED > 0 || LARGE_COUNT > 0`. No-op run → print thông báo skip, không tạo file.

#### Fix 2 — Filename Bug (`auto-dream.sh`)

- **Vấn đề:** `DREAM_LOG="$ARCHIVE_DREAMS/$TIMESTAMP_dream.md"` — biến `$TIMESTAMP` bị concatenate trực tiếp với `_dream` tạo thành tên biến mới (`$TIMESTAMP_dream`) → không defined → filename rỗng → file được ghi vào thư mục sai.
- **Fix:** `DREAM_LOG="$ARCHIVE_DREAMS/${TIMESTAMP}_dream.md"` — dùng `${}` để tách rõ tên biến.

#### Fix 3 — Dream Cooldown Guard (`session-stop.sh`)

- **Vấn đề:** Ngay cả khi `auto-dream.sh` được fix, Condition 1 (`MEMORY.md > 40 lines`) vẫn có thể luôn đúng vì `auto-dream.sh` không thể tự thu nhỏ `MEMORY.md`. Mỗi session ở state này sẽ re-trigger dream.
- **Fix:** Sau khi xác định `DREAM_TRIGGERED=true`, kiểm tra xem có `*_dream.md` file nào được tạo trong 60 phút qua không. Nếu có → reset `DREAM_TRIGGERED=false` với reason `"Cooldown active — last dream < 60min ago"`.

#### Fix 4 — Archive Cleanup (90+ stale files)

- Xóa toàn bộ 39 `*_dream.md` và 39 `*_session.md` empty/no-op files từ ngày 2026-04-16 đến 2026-04-17 — những file này được tạo ra bởi bug filename + no-op loop trên.
- Kết quả: archive folder sạch, chỉ chứa meaningful dream logs từ nay.

#### Governance — Commands vs Skills Precedence

- Tạo mới `.claude/docs/skills-precedence.md`: Tài liệu chính thức phân biệt ranh giới giữa **Workflow Commands** (gates xác định stage) và **Skills** (domain expertise cung cấp content). Commands CHỨA skills, không thay thế.
- Cập nhật `CLAUDE.md`: Thêm callout `> **Commands vs Skills precedence:**` với link đến `skills-precedence.md`.

#### Skills: backend-developer Agent Refactor

- `backend-developer.md`: Thay thế `nodejs-backend-patterns` → `backend-patterns` (generic hơn, không bị lock vào Node.js-only).
- Xóa skill `nodejs-backend-patterns/` (obsolete — nội dung đã được merge vào `backend-patterns`).

#### Skills: Major Overhaul — `diagnose` & `fastapi-pro`

- **`diagnose/SKILL.md`** (+282 lines): Nâng cấp toàn diện — thêm structured diagnostic report format, root cause analysis matrix, và integration với MAS agents (`investigator`, `verifier`, `solver`).
- **`fastapi-pro/SKILL.md`** (refactor hoàn toàn): Chuyển từ capability-list sang execution-patterns — async patterns, Pydantic v2, dependency injection, production deployment với Uvicorn + Gunicorn.

#### Docs: Hooks Visual Report

- Thêm `docs/hooks_visual_report.html`: Báo cáo trực quan toàn bộ kiến trúc hook system — timeline, event coverage map, dependency graph, và security layer visualization.

#### Số liệu v1.34.0:

- Bugs fixed: 2 critical (filename + no-op loop) + 1 cooldown guard
- Files removed: 80 no-op archive files + 2 obsolete skill files
- New docs: `skills-precedence.md`, `hooks_visual_report.html`
- Skills updated: `diagnose` (major), `fastapi-pro` (major), `frontend-patterns` (minor), `senior-frontend` (minor)

---

### [v1.33.0] - 2026-04-17

**Chủ đề:** The Great Pruning — Toàn bộ P0 Security & Architecture Fixes từ Audit Report v4

Thực thi đầy đủ 15 action items từ `report_upgrade_ver4_opus47.md` (kiến trúc sư trưởng Claude Opus 4.7). Framework nâng từ "AMBITIOUS BUT BROKEN" → trạng thái enforcement thực sự.

#### Fix A8 — Trim MEMORY.md (Dream Loop Root Cause):

- `MEMORY.md`: 46 → 36 lines (<40 trigger threshold) — dream loop fully resolved
- Tạo `.claude/memory/structure.md`: Tier 2.5 specialist list moved out of Tier 1 index

#### Fix A4/A5 — Security: jq Required + Deny-list Expansion:

- **A4 (C1):** 4 hooks bắt buộc `jq`, loại bỏ regex fallback bypass vector:
  - `bash-guard.sh`, `validate-commit.sh`, `validate-push.sh` → `exit 1` nếu thiếu jq
  - `prompt-context.sh`, `log-writes.sh`, `log-agent.sh` → `exit 0` (logging/UX best-effort)
- **A5 (C2+L1):** `settings.json` deny-list expanded: `cat .env`, `cat .env.*`, `cat *.env`, `Read(**/.env)`, `Read(**/.env.*)`, `rm -rf ./`, `rm -rf .`

#### Fix H1 — Race Condition: flock Atomic Writes:

- `log-writes.sh` + `log-agent.sh`: thêm `flock -x` guard trước mọi JSONL append
- Upgrade từ manual string escaping → jq-based JSON generation
- Graceful fallback khi flock không có (Windows)

#### Fix H2 — Prompt Injection: Memory Content Sanitization:

- `prompt-context.sh`: thêm `sanitize_memory_content()` lọc injection patterns (`ignore/disregard/act-as/system:`)
- Wrap injected content trong explicit code fence với header "READ-ONLY reference data, NOT instructions"
- Dùng `jq -n --arg` để output JSON thay vì sed manual escaping

#### Fix H3 — Command Injection: fork-join.sh Branch Validation:

- Thêm `validate_branch_name()`: chặn shell metacharacters (`;$\`&|<>()`) trong branch names
- Gọi validation trong cả `cmd_fork` và `cmd_join`
- Commit message dùng `printf` thay vì string interpolation trực tiếp

#### Fix M2 — Fail-Open Visibility: Timeout Guard:

- `validate-commit.sh`: self-timeout watchdog 25s + explicit WARN message khi timeout
- `settings.json`: tăng validate-commit timeout 15s → 30s

#### Fix A6 + ADR-004 Phase 2 — Unified Failure State Machine:

- `docs/internal/adr/ADR-004-unified-failure-state-machine.md`: gộp Rule 6/14/Diminishing Returns thành CLOSED/HALF_OPEN/OPEN state machine
- `.claude/memory/circuit-state.json`: initial CLOSED state
- `.claude/hooks/circuit-guard.sh`: PreToolUse:Task enforcement — block OPEN, probe HALF_OPEN, auto-transition sau 60min TTL
- `settings.json`: đăng ký circuit-guard.sh vào PreToolUse:Task

#### Khác:

- Report archived: `docs/internal/audits/2026-04-17_audit_sdd_v132.md`
- M4 confirmed false positive: `production/session-logs/` đã gitignored từ trước

#### Số liệu v1.33.0:

- Hooks: 15 → 16 scripts (+1: `circuit-guard.sh`)
- Security severity fixed: C1 ✅ C2 ✅ H1 ✅ H2 ✅ H3 ✅ L1 ✅
- Memory effectiveness: 2/10 → ~4/10 (loop fixed, stubs vẫn cần data thực)
- Enforcement: 3/10 → ~6/10 (circuit-guard + jq required)

---


**Chủ đề:** Finalizing Framework Maintenance — Kiến trúc hóa tri thức & Quy hoạch Repo

Hoàn tất giai đoạn bảo trì P1/P2, tập trung vào việc kiến trúc hóa toàn bộ hệ thống tri thức và làm sạch repo để đạt trạng thái "Production Ready".

#### Upgrade #1 — Tái cấu trúc thư mục Tài liệu (Knowledge Reorganization):

- **docs/technical/**: Tập trung các tài liệu chuyên sâu về kiến trúc (`ARCHITECTURE.md`), nguyên tắc thiết kế (`COLLABORATIVE-DESIGN-PRINCIPLE.md`), và bộ tiêu chuẩn trực quan (`visual-standards/`).
- **docs/onboarding/**: Chứa các tài liệu hướng dẫn nhanh cho thành viên mới (di chuyển từ `HUONG_DAN_NHANH.md`).
- **docs/internal/**: Lưu trữ các báo cáo audit (`report_audit_ver2_opus47.md`) và kế hoạch phát hành (`report_plan_package_cli.md`).
- **docs/reference/**: Danh sách lệnh (`DANH_SACH_LENH.md`) và các tài liệu tham khảo khác.
- **docs/retrospectives/**: Quy hoạch toàn bộ báo cáo lịch sử nâng cấp MAS và Claude-mem.
- **docs/archived/**: Nơi lưu các tài liệu cũ không còn phù hợp với kiến trúc MAS mới.

#### Upgrade #2 — Automated Testing Integration:

- Mở rộng thư mục `tests/` với các test suites cho **Hooks** và **Skills**.
- **Hook Smoke Tests:** Triển khai 34 test cases cho `bash-guard.sh` và `validate-commit.sh`, verify các lớp bảo mật và routing.
- **Skill Validation:** Tích hợp kiểm tra định dạng tri thức tự động.

#### Upgrade #3 — Hygiene & Governance:

- Dọn dẹp triệt để root folder: Di chuyển `History_Update.md`, `DANH_SACH_LENH.md`, `HUONG_DAN_NHANH.md` vào các folder chức năng trong `docs/`.
- Cập nhật `.gitignore`: Bổ sung các pattern bảo vệ cho `.worktrees/`, `graphify-out/`, và các file tạm từ `Supermemory`.
- **Durable Memory Audit:** Lưu trữ và chỉ mục hóa các phiên "Auto-Dream" và "Session Trace" vào `.claude/memory/archive/`.

---

### [v1.31.3] - 2026-04-17

**Chủ đề:** Security Hardening — P0 Audit Fixes (Opus 4.7)

Ba critical fix từ báo cáo audit `report_audit_ver2_opus47.md`, nhắm vào các lỗ hổng bảo mật thực thi bị che giấu bởi dead code và pattern bypass.

#### Fix C1 — Dead code bypass trong `validate-commit.sh`

- Xóa `exit 0` thừa tại line 137 (nay là comment `# exit 0  # REWARD: Removed to allow GitNexus check to run`)
- **Tác động:** GitNexus blast-radius scan và secret scan block thực sự được thực thi mỗi `git commit`
- Tương tự fix `session-start.sh:75` — cùng dead code pattern

#### Fix C2 — Supply chain RCE risk trong `.mcp.json`

- Pin `gitnexus@latest` → `gitnexus@1.6.1` (exact version)
- **Tác động:** npx không còn silently pull arbitrary latest version mỗi session, loại bỏ risk từ compromised hoặc typosquatted package

#### Fix C3 — Bypass-able deny patterns trong `bash-guard.sh`

- Bổ sung regex cover `rm -rf` variants: `-r -f`, `-f -r`, `-fr`, path `/` và wildcard `*`
- Bổ sung block `tee *.env` và `> .env` (redirect overwrite)
- **Tác động:** Các bypass kiểu double-space, flag reorder, tee redirect bị chặn ở hook level

---

### [v1.31.2] - 2026-04-17

**Chủ đề:** Tối ưu hóa hạ tầng & Hỗ trợ đa nền tảng (Opus 4.7 Audit Fixes)

Đợt bảo trì toàn diện dựa trên báo cáo chẩn đoán Opus 4.7, đưa hệ thống đạt độ trưởng thành **120/120** (max pattern rating). Tập trung vào tính nhất quán của tri thức, trải nghiệm người dùng Windows và quy trình kiểm thử tự động.

#### Upgrade #1 — Hỗ trợ Windows (Platform Parity):

- Triển khai toàn bộ mirror PowerShell (`.ps1`) cho các lifecycle hooks: `bash-guard.ps1`, `session-start.ps1`, `validate-commit.ps1`.
- Đảm bảo các lớp bảo mật (deny rules) và tự động hóa hoạt động đồng nhất trên cả Windows (PowerShell) và Unix (Bash).

#### Upgrade #2 — Dọn dẹp & Quy hoạch Repo (Hygiene):

- **Root Cleanup**: Di chuyển hàng loạt báo cáo rời rạc vào `docs/retrospectives/` và các file nháp prototype vào `docs/prototypes/`.
- **Gitignore Tuning**: Loại bỏ triệt để các tàn dư từ `traces/`, `session-state/`, và các file `npm-debug.log`.

#### Upgrade #3 — Nhất quán Tri thức (Knowledge Consistency):

- **Metrics Sync**: Cập nhật đồng bộ số liệu trên badges tại `README.md` và `README_vn.md`: **31 Agents, 118 Skills, 15 Hooks, 13 Rules**.
- **Frontmatter Audit**: Verify và bổ sung YAML frontmatter chuẩn cho toàn bộ 13 file tri thức Tier-2 và Specialists.
- **Memory Tier 4**: Tích hợp chính thức lớp lưu trữ ngữ cảnh semantic (Supermemory MCP) vào `MEMORY.md`.

#### Upgrade #4 — Automated QA & CI:

- Khởi tạo cấu trúc `tests/` cho framework.
- Thêm test case đầu tiên `validate-frontmatter.test.js` để tự động kiểm tra định dạng tri thức.
- Thiết lập **GitHub Actions CI** (`.github/workflows/audit.yml`) tự động chạy audit pattern và test suites trên mỗi PR/Push.

#### Upgrade #5 — Quản trị & UX:

- **Dogfooding**: Cập nhật PRD/TODO thực tế cho project SDD-Upgrade, xóa bỏ mọi placeholder template.
- **Decision Ledger**: Kích hoạt nhật ký quyết định kiến trúc (`decision_ledger.jsonl`) với entry đầu tiên về Windows Parity.
- **Rule Relaxation**: Nới lỏng quy tắc `NEVER WRITE DIRECTLY` trong `CLAUDE.md` để tối ưu hóa tốc độ làm việc khi user ở chế độ `acceptEdits`.

---

### [v1.31.0] - 2026-04-16

**Chủ đề:** Automated Discipline — Hook Intelligence từ Claude-mem patterns

Nâng cấp hệ thống hooks từ **kỷ luật thủ công** sang **kỷ luật tự động hóa** bằng cách tích hợp các pattern từ Claude-mem v12.x. SDD nay có bộ nhớ thích nghi theo từng prompt, audit trail đầy đủ cho mọi file write, và khả năng phục hồi context thông minh hơn sau compaction.

#### P0: Quick Fixes

**Fix 1 — Stderr leak trong `bash-guard.sh`:**

- Warnings (exit 0) chuyển từ `>&2` sang stdout — loại bỏ error UI đỏ giả trong Claude Code
- Blocks (exit 2) giữ nguyên stderr vì Claude Code feeds stderr to Claude khi exit 2

**Fix 2 — Error handling trong `session-start.sh`:**

- `BRANCH`, `LATEST_SPRINT`, `LATEST_MILESTONE` thêm `|| echo "(no git)"` / `|| true` fallback — tránh crash khi chạy ngoài git repo hoặc thiếu thư mục sprints/milestones

#### P1: Automation — 3 hooks mới + 2 hooks nâng cấp

**Upgrade 1 — UserPromptSubmit: Memory-aware context injection (`prompt-context.sh` mới):**

- Mỗi prompt → trích keyword (words >4 ký tự) → tìm topic files liên quan trong `.claude/memory/` → inject `additionalContext`
- Tối đa 3 files, dedup chính xác, silent exit khi không có match
- Giải quyết Gap G1: context không còn static từ SessionStart mà thích nghi theo từng prompt

**Upgrade 2 — PostToolUse Write|Edit: JSONL write logger (`log-writes.sh` mới):**

- Ghi `event/timestamp/session_id/file/branch` vào `production/session-logs/writes.jsonl` ngay lập tức khi Write/Edit xảy ra
- Chính xác hơn `git diff` (bắt cả committed files, có timestamp)
- Giải quyết Gap G2: audit trail đầy đủ cho mọi file write trong session

**Upgrade 3 — PreToolUse Read: Git history injection (`file-history.sh` mới):**

- File size gate: bỏ qua file <1KB (overhead > benefit)
- Inject 5 commits gần nhất, last author, last date → Claude hiểu tại sao file trông như vậy
- Giải quyết Gap G5: SDD có impact analysis cho Write, nay có lịch sử khi đọc file

**Upgrade 4 — PreCompact: Last intent signal (`pre-compact.sh` nâng cấp):**

- Thêm section "Last Intent Signal": last commit message, staged stat, last file written từ writes.jsonl
- Claude biết đang làm gì ngay lúc compact xảy ra → recovery tốt hơn
- Giải quyết Gap G6: pre-compact không còn mù về intent

**Nâng cấp `session-stop.sh`:**

- Đọc `writes.jsonl` thay vì chỉ `git diff` → "Files Written This Session" chính xác kể cả committed files

**Cập nhật `settings.json`:**

- Đăng ký `UserPromptSubmit` hook với `prompt-context.sh`
- Thêm `PreToolUse Read` với `file-history.sh`
- PostToolUse Write|Edit: `log-writes.sh` chạy trước `validate-assets.sh`

#### Số liệu v1.31.0

- Hooks: 10 → 13 scripts (+3 mới: `prompt-context.sh`, `log-writes.sh`, `file-history.sh`)
- Hook events coverage: SessionStart, UserPromptSubmit *(mới)*, PreToolUse Bash/Write|Edit/Read *(mới)*, PostToolUse Write|Edit, PreCompact, Stop, SubagentStart
- Gaps resolved: G1 (adaptive context), G2 (write logging), G5 (read history), G6 (compact intent)

---

### [v1.30.0] - 2026-04-16

**Chủ đề:** Nâng cấp hạ tầng Multi-Agent Systems (MAS Infrastructure)

SDD được nâng cấp toàn diện từ một bộ khung điều phối đơn giản lên **MAS Infrastructure** đầy đủ, bổ sung 7 upgrade lớn về Fault Tolerance, Observability, Orchestration, và Agent Communication — lấy cảm hứng từ chuẩn Multi-Agent Infrastructure của DigitalOcean.

#### Upgrade #1 — Fault Tolerance: Atomic Checkpointing

- Cập nhật skill `/save-state`: ghi atomic checkpoint per-task vào `.tasks/checkpoints/[task_id].md` với `task_id`, `agent_id`, `output_snapshot`.
- Tạo mới skill `/resume-from [task_id]`: khôi phục ngay tại điểm lỗi, tích hợp exponential backoff (2s → 4s → 8s), tự động tăng `retry_count`.
- Tạo thư mục `.tasks/checkpoints/` làm nơi lưu trữ checkpoint per-task.

#### Upgrade #2 — Shared Memory: Namespace Isolation

- Triển khai cấu trúc `.claude/memory/specialists/[agent_name].md` cho 7 core agents: `backend-developer`, `frontend-developer`, `qa-tester`, `data-engineer`, `fullstack-developer`, `investigator`, `technical-director`.
- Tạo Consensus Hub tại `.claude/memory/consensus/merged-decisions.md` — `@technical-director` hợp nhất tri thức cross-domain định kỳ.
- Thêm Tier 2.5 vào `MEMORY.md` và Namespace Isolation Rules vào `context-management.md`: tối đa 1 specialist file per session turn.

#### Upgrade #3 — Observability: Decision Tracing Ledger

- Tạo `production/traces/decision_ledger.jsonl`: ghi lại `agent_id`, `request`, `reasoning`, `choice`, `outcome`, `risk_tier` cho mọi quyết định Medium/High risk.
- Tạo mới skill `/trace-history`: xem timeline quyết định với filter theo agent, risk tier, task, outcome, date.
- Thêm Rule 15 vào `coordination-rules.md`: bắt buộc ghi ledger với các quyết định quan trọng.

#### Upgrade #4 — Orchestration: Dynamic Workflow Graph

- Tạo `docs/templates/workflow-graph.md`: định nghĩa schema YAML và 4 orchestration patterns: Sequential, Parallel Fan-out, Hierarchical, Iterative Loop.
- Tạo mới skill `/map-workflow`: `@producer` thiết lập graph trước khi dispatch, có bước approval bắt buộc.
- Cập nhật `docs/WORKFLOW-GUIDE.md` với pointer đến template và skill mới.

#### Upgrade #5 — Fault Isolation: Circuit Breaker Pattern

- Thêm Rule 14 vào `coordination-rules.md`: 3 trạng thái CLOSED → OPEN → HALF-OPEN, backoff 2s → 4s → 8s trước khi OPEN, tự động route sang fallback agent.
- Tạo `production/session-state/circuit-state.json`: theo dõi trạng thái 8 agents với fallback pairs (`backend↔fullstack`, `frontend↔fullstack`, `qa-tester↔qa-lead`, v.v.).

#### Upgrade #6 — Agent Communication: A2A Handoff Schema

- Tạo `.claude/docs/handoff-schema.md`: chuẩn hóa contract chuyển giao với fields `from`, `to`, `artifact`, `artifact_status`, `acceptance_criteria`, `context_snapshot`, `risk_tier`.
- Tạo mới skill `/handoff`: tự động generate contract JSON, validate criteria, ghi ledger entry tự động với Medium/High risk.
- Tạo thư mục `.tasks/handoffs/` lưu contracts.
- Thêm Rule 16 vào `coordination-rules.md`: protocol sender/receiver, reject handoff nếu criteria không đạt.

#### Upgrade #7 — Observability: Per-Agent Performance Registry

- Tạo `production/traces/agent-metrics.jsonl`: ghi metrics per agent per session (`tasks_completed`, `tasks_failed`, `avg_tokens_est`, `error_rate`, `circuit_state`).
- Tạo mới skill `/agent-health`: hiển thị bảng tóm tắt hiệu suất, cross-check với circuit breaker state, flag agents có error_rate > 30% hoặc circuit OPEN/HALF-OPEN.

#### Tổng kết thay đổi

- Coordination rules: 13 → 16 rules
- Skills mới: +5 (`/resume-from`, `/trace-history`, `/map-workflow`, `/handoff`, `/agent-health`)
- Skills cập nhật: +1 (`/save-state`)
- Files mới: 20+ files/dirs across `.claude/`, `.tasks/`, `production/`, `docs/`

---

### [v1.28.0] - 2026-04-15

**Chủ đề:** Tích hợp Tier 2 Diagnostic Agents, Vertical Slicing & Chuẩn hóa UI Spec

SDD được nâng cấp với hệ thống chẩn đoán lỗi chuyên sâu và triết lý phát triển "Vertical Slicing" để đảm bảo tính thực thi tuyệt đối.

**Upgrade #1 — Quy trình Chẩn đoán (Tier 2 Diagnostic Agents):**
- Khởi tạo bộ 3 Agent chuyên trách: `investigator` (Truy vết), `verifier` (Phản biện), `solver` (Giải quyết).
- Tích hợp kỹ năng `/diagnose` vào `CLAUDE.md` để tự động hóa quy trình xử lý lỗi phức tạp thông qua các báo cáo chẩn đoán tại `.claude/docs/diagnostics/`.

**Upgrade #2 — Triển khai "Vertical Slicing" (Fullstack):**
- Định nghĩa triết lý phát triển lát cắt chức năng (Vertical Slices) đảm bảo "Working Software" ở mọi giai đoạn.
- Bổ sung kỹ năng `/vertical-slice` giúp định nghĩa Feature Contract giữa Frontend và Backend trước khi code.

**Upgrade #3 — Chuẩn hóa UI Spec (Tier 3 Specialist):**
- Khởi tạo Agent `@ui-spec-designer` và tài liệu `ui-spec-template.md`.
- Ép buộc định nghĩa Matrix 5 trạng thái (Default, Loading, Empty, Error, Partial) và Interaction logic theo chuẩn EARS.

**Upgrade #4 — Visual Architecture Documentation:**
- Tự động hóa bản vẽ kiến trúc bằng `visual-engineer` (Style 6 - Claude Official).
- Kết quả: `docs/sdd-architecture.svg` và bản render high-res `docs/sdd-architecture.png` (sử dụng `sharp-cli` cho hiệu năng và độ sắc nét tối ưu trên Windows).

---

### [v1.27.0] - 2026-04-14

**Chủ đề:** Tích hợp Kỹ năng Visual Engineering & Chuẩn hóa Tài liệu Kiến trúc

SDD được nâng cấp với khả năng tự động hóa việc vẽ sơ đồ kỹ thuật (SVG/PNG) chất lượng sản xuất, trực quan hóa toàn bộ hệ thống Agentic Harness.

**Upgrade #1 — Kỹ năng Visual Engineer (Documentation-as-Visual-Code):**
- Tích hợp skill `visual-engineer/SKILL.md`: Cho phép Agent tự động tạo sơ đồ kiến trúc, sequence flow, và component maps theo ngôn ngữ tự nhiên. Chết độ mặc định: **Style 6 (Claude Official)**.
- Triển khai Semantic Shapes cho SDD: Hexagons (Agents), Diamonds (Phase Gates), Cylinders (Storage), Folded-rects (Code).

**Upgrade #2 — Visual Standards Library:**
- Thiết lập `docs/visual-standards/`: Thư viện tokens, icons, và phong cách trực quan cho toàn bộ dự án SDD.
- Tạo sơ đồ kiến trúc lõi: `docs/visual-standards/sdd-architecture.png` minh họa cấu trúc 3 tầng (Interface, Core Harness, Knowledge Foundation).

**Upgrade #3 — Mở rộng Hệ thống Lệnh (122 Skills):**
- Tối ưu hóa `list-commands.py` sử dụng PyYAML: Khắc phục lỗi parsing, đảm bảo 122 kỹ năng chuyên biệt đều được đăng ký chính xác trong `DANH_SACH_LENH.md`.
- Cập nhật Project Initializer: `init-sdd.ps1` hỗ trợ khởi tạo folder `docs/visual-standards` mặc định.

---

### [v1.26.0] - 2026-04-13

**Chủ đề:** Tích hợp MCP Supermemory & Kỹ năng Kỷ luật thép (Anti-Rationalization)

Dựa trên phân tích repo `addyosmani/agent-skills` và framework Semantic Memory, SDD đã được nâng cấp chiến lược về lưu trữ kiến thức dài hạn và gò AI vào quy trình tác vụ cực đoan.

**Upgrade #1 — Tích hợp MCP Supermemory (Hybrid Memory State):**
- Cập nhật `.claude/docs/context-management.md`: Quy định Agent phải dùng `mcp_supermemory_recall` thay cho search cục bộ thuần túy và `mcp_supermemory_memory` để lưu lessons learned.
- Chỉnh sửa script `.claude/hooks/auto-dream.sh`: Tự động in ra cảnh báo/khuyên dùng Supermemory khi thực hiện gom nhóm (consolidation) các file cục bộ bị tràn (overflow).

**Upgrade #2 — Bổ sung 4 Kỹ năng Process Core (Chống lười & Ảo giác):**
- Chuẩn hóa module `SKILL.md.tmpl` nâng cấp, bổ sung section **Anti-Rationalizations** (Bẻ lý lẽ ngụy biện phổ biến của AI) và **Verification Gates** (Buộc trình bằng chứng).
- Triển khai 4 skill nền tảng (bằng Tiếng Anh chuẩn form SDD):
  - `spec-driven-development/SKILL.md`: Ép vẽ Blueprint và xin phép trước khi tạo file thực thi.
  - `planning-and-task-breakdown/SKILL.md`: Ép chia nhỏ siêu dự án thành atomic Tasks Checklist.
  - `test-driven-development/SKILL.md`: Ép thực hiện test chuẩn TDD (Red-Green-Refactor) đính kèm Terminal Log thực tế.
  - `context-engineering/SKILL.md`: Chẩn đoán và ngăn chặn Context Stuffing, tối ưu hóa R-P-R-I cycle thông qua `mcp_supermemory`.

**Upgrade #3 — Móc nối Implicit Workflow Commands:**
- Cập nhật `CLAUDE.md`: Tiêm `🧭 Implicit Workflow Commands (Process Shields)` để biến các mệnh lệnh `/plan`, `/spec`, `/tdd`, `/context` thành chỉ thị bắt buộc.

---

### [v1.25.3] - 2026-04-13

**Chủ đề:** Tích hợp Andrej Karpathy LLM Coding Behavior principles vào SDD

Dựa trên phân tích so sánh dự án `andrej-karpathy-skill` với SDD, xác định 3 gaps chính về hành vi vi mô của AI khi viết code (chưa được SDD giải quyết ở cấp governance).

**Upgrade #1 — LLM Coding Behavior (`@include` pattern):**

- Tạo file mới `.claude/docs/llm-coding-behavior.md` với 4 nguyên tắc: Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution.
- Thêm section `## LLM Coding Behavior` vào `CLAUDE.md` với `@include` reference — nhất quán với kiến trúc docs hiện tại của SDD.

**Upgrade #2 — Surgical Changes rule (path-scoped):**

- Thêm section `## Surgical Changes` vào `.claude/rules/src-code.md`.
- Quy tắc: mỗi dòng thay đổi phải trace trực tiếp về yêu cầu của user; không refactor code kề bên, không xóa dead code "tiện thể", không thêm comments/docstrings vào code không được chỉnh sửa.
- Enforcement tự động bởi Claude Code khi edit bất kỳ file nào trong `src/**`.

**Upgrade #3 — Verifiable Plan Format (Rule 12):**

- Thêm Rule 12 vào `.claude/docs/coordination-rules.md`.
- Yêu cầu mọi multi-step task phải trình bày plan dạng `[Step] → verify: [check]` trước khi implement.
- Tiêu chí verify phải cụ thể và testable ("tests pass", "endpoint returns 201") — không chấp nhận tiêu chí mờ ("looks good", "should be fine").

---

### [v1.25.2] - 2026-04-11

**Chủ đề:** Tích hợp 21 câu hỏi "Architectural Pre-flight" vào `brainstorm` skill

- Bổ sung Phase 7 (Architectural Pre-flight) vào workflow của `brainstorm` skill.
- Đưa vào 6 phương diện (Business, Functional, Non-Functional, Integration, Data, Operational) cùng các "non-obvious gotchas" để AI challenge project scope trước khi đưa ra quyết định chốt thiết kế.

---

**Chủ đề:** Dịch toàn bộ tiếng Việt còn sót lại trong Skills sang Tiếng Anh

- **Sửa lỗi định tuyến (Routing):** Dịch toàn bộ các trường `description` và `when_to_use` đang dùng tiếng Việt sang tiếng Anh trên 7 files (`architecture-decision`, `architecture-decision-records`, `code-review`, `code-review-checklist`, `freeze`, `guard`, `unfreeze`) để giúp AI routing chính xác hơn.
- **Tiêu chuẩn hóa Workflow Body:** Dịch toàn bộ nội dung hướng dẫn, prompts, Edge Cases và Related Skills của cụm file workflow (`freeze`, `guard`, `unfreeze`) sang 100% tiếng Anh. Đảm bảo toàn bộ repo SDD đồng nhất về một ngôn ngữ.

---

**Chủ đề:** Progressive Disclosure Refactoring — Rút gọn 11 skills lớn, giảm ~2.200 dòng context waste

Dựa trên phân tích so sánh bộ skill SDD với bộ chuẩn Claude Managed Agents (CMA), xác định 2 vấn đề chính cần xử lý: (1) mô tả skill thiếu trigger words → AI định tuyến sai, (2) body skill quá dài do marketing copy và capability bullet list vô dụng.

**Vấn đề 1 — Cải thiện Descriptions & Trigger Words:**
- Rà soát và viết lại `description:` + `when_to_use:` cho toàn bộ skills có mô tả yếu
- Bổ sung trigger keywords cụ thể vào frontmatter để cải thiện độ chính xác routing của agent

**Vấn đề 2 — Progressive Disclosure (4 batches, 11 skills):**

| Skills                          | Trước | Sau  | Ghi chú                                                         |
| ------------------------------- | ----- | ---- | --------------------------------------------------------------- |
| `senior-frontend`               | 495   | ~149 | Bỏ scaffolding scripts, giữ actionable patterns                 |
| `code-review-checklist`         | 466   | ~94  | Bỏ explanations thừa, giữ checklist items                       |
| `architecture-decision-records` | 452   | ~127 | Bỏ verbose templates, giữ 1 MADR template                       |
| `postmortem-writing`            | 413   | ~132 | Bỏ ví dụ dài, giữ templates + core concepts                     |
| `prisma-expert`                 | 365   | ~148 | Bỏ diagnostic scripts, giữ critical rules                       |
| `backend-architect`             | 337   | ~95  | Bỏ 200-line capability list, thêm decision matrix               |
| `aws-serverless`                | 332   | ~168 | Fix truncated code snippets, remove broken tables               |
| `devops-deploy`                 | 295   | ~197 | Fix broken YAML frontmatter, remove boilerplate                 |
| `database-architect`            | 270   | ~120 | Bỏ bullet list, thêm SQL patterns + decision matrix             |
| `frontend-design`               | 281   | ~90  | Rút gọn DFI framework, thêm operator checklist                  |
| `mlops-engineer`                | 225   | ~177 | Bỏ 150-line capability list, thêm tool matrix + 5 code patterns |

**Skills đánh giá nhưng KHÔNG rút gọn (code-dense / justified):**
- `deep-interview` (651), `laravel-patterns` (421), `docker-patterns` (370), `drizzle-orm-expert` (366), `claude-api` (343), `springboot-patterns` (320), `map-systems` / `orchestrate` (307–313): toàn code thực tế, không có padding
- `shadcn` (252), `brainstorm` (236), `launch-checklist` (239), `deployment-procedures` (249): checklist + execution workflows — mỗi dòng đều cần thiết

**Tổng kết:** Giảm ~2.200 dòng, ~60% context waste từ các skills bị ảnh hưởng. Skills đã đạt mật độ thông tin tối ưu: mỗi dòng là rule, pattern, hoặc code thực thi.

---

### [v1.24.0] - 2026-04-07

**Chủ đề:** Tích hợp 2 patterns từ Context Hub (Andrew Ng)

Dựa trên phân tích [Context Hub](https://github.com/andrewyng/context-hub) — một curated API documentation registry do Andrew Ng tạo ra, rút ra 2 patterns áp dụng vào SDD.

**Pattern: Annotation System (persistent gotcha store)**

- Tạo mới `.claude/memory/annotations.md` — Tier 2 memory file lưu trữ gotchas, caveats, và learned lessons theo service/library với định dạng `[YYYY-MM-DD] <mô tả cụ thể> — <workaround>`
- Tạo mới `.claude/skills/annotate/SKILL.md` — Skill `/annotate` 4 phase: Parse → Format (quality check) → Find/Create section → Write + Confirm
- Cập nhật `CLAUDE.md` — Thêm **ANNOTATION PROTOCOL** vào CRITICAL RULES: agent phải ghi gotcha ngay lập tức khi phát hiện, không chờ user nhắc
- Cập nhật `MEMORY.md` — Đăng ký `annotations.md` vào Tier 2 index với trigger keywords: `api, sdk, gotcha, caveat, workaround, integration, version, compatibility`

**Pattern: Incremental Context Loading (fetch only what you need)**

- Viết lại `MEMORY.md` — Comment rõ "keyword match là KHÔNG đủ", max 3 Tier 2 files/session, pointer đến full rules
- Thêm section "Incremental Context Loading" vào `.claude/docs/context-management.md`:
  - **3-Question Relevance Gate** trước khi load bất kỳ Tier 2 file nào (actual need / timing / subset check)
  - **Load Decision Matrix** — 7 loại task với chỉ định file nào load/skip
  - **Loading Sequence** với budget gate (stop nếu context < 30%)
  - **Hard Limits**: max 3 files, subsection line reads, never speculative loading

---

### [v1.23.0] - 2026-04-07

**Chủ đề:** Nâng cấp theo 12 Agentic Harness Patterns từ Claude Code

Dựa trên phân tích bài báo [12 Agentic Harness Patterns from Claude Code](https://generativeprogrammer.com/p/12-agentic-harness-patterns-from) — đối chiếu SDD với mã nguồn Claude Code bị rò rỉ và nâng cấp từ 7/12 lên **10/12 patterns đầy đủ**.

**Pattern #3 — Tiered Memory (nâng cấp):**
- Tái cấu trúc `MEMORY.md` thành Tier 1 index thuần túy (max 50 dòng) với keyword trigger cho Tier 2
- Tạo thư mục `archive/sessions/`, `archive/decisions/`, `archive/dreams/` làm Tier 3 cold storage
- Tạo `archive/README.md` hướng dẫn cách search và promote records giữa các tầng

**Pattern #4 — Dream Consolidation (nâng cấp):**
- Tạo mới `.claude/hooks/auto-dream.sh` — script consolidation 5 phase tự động (Orient → Detect → Archive → Prune → Log)
- Nâng cấp `session-stop.sh` với 3 điều kiện kích hoạt auto-dream: index >40 dòng / mỗi 5 phiên / topic files stale >7 ngày
- Auto-update dòng "Last session" trong MEMORY.md cuối mỗi phiên

**Pattern #8 — Fork-Join Parallelism (mới hoàn toàn):**
- Tạo mới `.claude/hooks/fork-join.sh` — full git worktree lifecycle manager (fork/status/list/join/purge)
- Tạo mới `.claude/skills/fork-join/SKILL.md` — kỹ năng `/fork-join` 7 phase cho parallel agent execution
- Cập nhật `.gitignore` bổ sung `.worktrees/` và temp files từ graphify

**Cập nhật .gitignore:** Thêm rules bảo vệ `.worktrees/`, `graphify-out/`, `.graphify_*`

**Tổng kết nâng cấp:** SDD đạt 10/12 Harness Patterns (83% tương đương Claude Code gốc). 2 pattern còn lại (#5, #9) bị giới hạn bởi platform Anthropic, không thể tự implement từ project level.

---

### [v1.22.0] - 2026-04-05

**Chủ đề:** Nâng cấp hệ thống Validation Workflow & Bash Guard

- **Bash Guard Hook:** Bổ sung script `.claude/hooks/bash-guard.sh` để chặn các lệnh bash nguy hiểm bề sâu cho Agent.
- **Validation Workflow:** Cập nhật các hook script như `log-agent.sh`, `session-stop.sh`, `validate-commit.sh`, `validate-push.sh` và `settings.json` giúp nâng cấp quy trình kiểm duyệt an toàn, log tracking.
- **Nâng cấp version:** Bump version toàn dự án lên 1.22.0.

---

### [v1.21.2] - 2026-04-05

**Chủ đề:** Loại bỏ triệt để các tàn dư Game Studio trong Docs & Hooks

- **Clean up Docs & Hooks:** Dọn dẹp hàng loạt các file template, rules và bash scripts trong `.claude/docs/` (11 files) và `.claude/hooks/` (4 files) bị sót tham chiếu Game Studio (như `game concept`, `player-facing`, `game-designer`, `no engine`).
- **Xác thực toàn dự án:** Xác nhận độ sạch 100% ngữ cảnh Software Engineering trên toàn bộ thư mục `.claude/` và các thư mục cấu trúc (infra, src, design).

---

### [v1.21.1] - 2026-04-05

**Chủ đề:** Loại bỏ triệt để các tàn dư Game Studio trong Workflow Skills

- **Clean up Workflow Skills:** Chạy kịch bản dọn dẹp hàng loạt 19 skills còn sót tham chiếu định dạng Game Studio cũ (như `gdd`, `gameplay`, `game concept`, `player`, `level design`).
- **Nâng cấp version:** Bump version lên 1.21.1, đảm bảo toàn bộ `SKILL.md` thống nhất ngữ cảnh Software Engineering.

---

### [v1.21.0] - 2026-04-04

**Chủ đề:** Tích hợp bộ kỹ năng Khởi nghiệp tinh gọn (The Minimalist Entrepreneur)

- **Business & Strategy Skills:** Nhúng 10 kỹ năng tư duy kinh doanh và định hướng chiến lược từ framework *The Minimalist Entrepreneur* (Sahil Lavingia) vào hệ sinh thái SDD. Cấu trúc tại thư mục `.claude/skills/startup-business/`.
- **Mở rộng năng lực vòng đời dự án:** SDD nay đã bao phủ trọn vẹn cả 4 giai đoạn: Sàng lọc ý tưởng (`/validate-idea`) ➜ Xây dựng phần mềm (SDD Agents) ➜ Bán hàng (`/first-customers`, `/pricing`) ➜ Tăng trưởng (`/marketing-plan`, `/grow-sustainably`).
- **Nâng cấp version:** Nâng tổng số Skills của hệ thống lên **108 Skills**. Bump version lên 1.21.0.

---

### [v1.20.0] - 2026-04-04

**Chủ đề:** Chuẩn hóa định dạng Output cho các Skills quản trị

- **Standardize Skill Outputs:** Bổ sung cấu trúc `## Output` kèm theo chỉ thị `Deliver exactly:` vào 9 skill phân tích và quản trị quan trọng (bao gồm `sprint-plan`, `project-stage-detect`, `tech-debt`, `security-audit`, `scope-check`, `retrospective`, `release-checklist`, `reverse-document`, `prototype`). Thay đổi này giúp ép buộc các tác tử AI sau khi phân tích xong phải trả rà kết quả theo đúng chuẩn định dạng, không trả lời thừa thãi.
- **Nâng cấp version**: Bump version hệ thống lên 1.20.0.

---

### [v1.19.1] - 2026-04-03

**Chủ đề:** Loại bỏ hoàn toàn references Game Studio cũ

- **Clean up Gameplay References:** Rà soát và dọn sạch toàn bộ các từ khóa, concept liên quan đến `gameplay`, `game`, `engine` cũ còn sót lại trong các file rules, skills, và hooks (chẳng hạn như `rules-reference.md`, `detect-gaps.sh`...). Toàn bộ được quy hoạch lại cho ngữ cảnh Business/Software Engineering (API, Business Logic, Backend).
- **Nâng cấp version**: Bump version hệ thống lên 1.19.1.

---

### [v1.19.0] - 2026-04-03

**Chủ đề:** Tích hợp Safety Tiers & Utility Prompts UX

- **Safety Tiers & Risk Assessment:** Bổ sung cơ chế đánh giá rủi ro (Low/Medium/High) trước khi thao tác code, ép buộc kế hoạch rollback hoặc xin phép user.
- **Tool Constraints:** Bắt buộc AI đọc (view_file) trước khi viết đè hoặc sửa đổi để ngăn chặn lỗi "mù" context.
- **Utility Prompts:** Tạo mới file `.claude/docs/utility-prompts.md` tối ưu UX giao tiếp (Tool Summary ngắn gọn, Next Action Suggestion, Away Recap).
- **Nâng cấp version**: Bump version toàn bộ framework lên 1.19.0.

---

### [v1.18.0] - 2026-04-03

**Chủ đề:** Skill Validation & Consistency Enhancement

- **Skill Validation:** Bổ sung tập lệnh `validate-skills.sh` và `eval-skill.py` hỗ trợ đánh giá tự động (LLM-as-a-judge) chất lượng của các file cấu hình SKILL.md.
- **Rules Cập Nhật:** Bổ sung file `.claude/rules/git-push.md` nhắc nhở việc tự động nâng cấp History log và nội dung README trước mỗi khi thao tác lệnh PUSH.
- **Metadata Format:** Cập nhật thuộc tính `type: reference` và `type: workflow` vào YAML frontmatter của toàn bộ thư viện các skill theo tiêu chuẩn xác thực mới.
- **Thư mục Mới:** Tổ chức lại và bổ sung cấu trúc cho `freeze`, `unfreeze`, `guard`, và `templates` hỗ trợ quản lý trạng thái luồng làm việc.
- **Nâng cấp version**: Bump version toàn bộ framework lên 1.18.0 và cập nhật số Rules (12 Rules).

---

### [v1.17.0] - 2026-04-02

**Chủ đề:** Tích hợp Hệ thống GitNexus Knowledge Graph

- **Đánh giá Năng lực**: Lập báo cáo `report_new_capacity_sdd_with_gitnexus.md` (tiếng Anh và tiếng Việt) về những khả năng mới khi cung cấp sơ đồ phân tích mã nguồn cho hệ thống SDD Agent.
- **Cập nhật Tài liệu**: Bổ sung reference vào thư viện tài nguyên của `README.md` (EN) và `README_vn.md` (VN).
- **Nâng cấp version**: Bump version toàn bộ framework lên 1.17.0.

---

### [v1.16.0] - 2026-04-02

**Chủ đề:** Nâng cấp Memory Consolidation Protocol & Cập nhật `.gitignore`

- **Tối ưu hóa Skill `/dream` (`.claude/skills/dream/SKILL.md`)**:
  - Tái cấu trúc quy trình consolidate thành 4 Phase rõ ràng: Orient, Gather recent signal, Consolidate, Prune and index.
  - Cải thiện cách tìm kiếm `MEMORY.md` và các session transcripts (`.jsonl`) để bắt thông tin chuẩn xác.
  - Bổ sung quy trình kiểm tra và tự sửa lỗi thiếu YAML frontmatter.
  - Thêm danh mục nhận diện tín hiệu rõ ràng (Signal categories) thay vì thu thập dữ liệu rác.
- **Cập nhật `.gitignore`**:
  - Thêm `.vercel` nhằm loại trừ file tạm của Vercel.

---

### [v1.15.0] - 2026-04-01

**Chủ đề:** Tool System Optimization — Least Privilege, Allow-list & Argument Hints

- **Idea 3 — Thêm `allowed-tools` cho 58 skills** (tổng 99/99 skills đều có):
  - `Read, Glob, Grep` cho 21 tech reference skills (read-only)
  - `Read, Glob, Grep, Bash` cho 3 analysis skills
  - `Read, Glob, Grep, Write, Edit, Bash` cho 31 tech expert skills
  - `Read, Glob, Grep, Write, Bash` cho 3 git workflow skills
- **Idea 4 — Mở rộng Permission Allow-list** (10 → 22 entries):
  - `cat`, `head`, `tail`, `wc`, `find`, `tree` (file reading)
  - `npm list`, `pip list` (package inspection)
  - `git show`, `git stash list` (git read-only)
  - `npm run build`, `npx tsc --noEmit` (safe build/check)
- **Idea 5 — Thêm `argument-hint` cho 13 key skills:**
  - `commit`, `pr-writer`, `security-audit`, `postmortem-writing`, `code-review-checklist`, `architecture-decision-records`, `database-architect`, `cloud-architect`, `deployment-engineer`, `backend-architect`, `frontend-design`, `ml-engineer`, `devops-deploy`.
- **Idea 6 — Verified:** Tất cả 10 fork skills đều có `agent:` field ✅.

---

### [v1.14.0] - 2026-04-01

**Chủ đề:** Tool System Hardening — Deny Rules & Fork Context cho Heavy Skills

Dựa trên phân tích `REPORT-tool-system.md` (Claude Code source code — 23 BashTool security checks, Permission System, Concurrency Model):

- **Bổ sung 10 deny rules mới vào `settings.json`** (tổng từ 12 → 22):
  - Pipe-to-shell RCE: `curl|sh`, `curl|bash`, `wget|sh`, `wget|bash`
  - Shell config injection: `>.bashrc`, `>.zshrc`, `>.profile`
  - Accidental publish: `npm publish`
  - Container destruction: `docker rm -f`, `docker system prune`
- **Thêm `context: fork` + `agent:` cho 4 heavy analysis skills:**
  - `code-review` → `agent: lead-programmer`
  - `db-review` → `agent: data-engineer`
  - `design-review` → `agent: ux-designer`
  - `mobile-review` → `agent: mobile-developer`
- **Fix `tech-debt` agent:** `lead-programmer` → `technical-director` (strategic concern).
- **Tổng fork skills:** 10 (trước đó 6: architecture-decision, architecture-decision-records, map-systems, perf-profile, security-audit, tech-debt).

---

### [v1.13.0] - 2026-04-01

**Chủ đề:** Skill Format Standardization — Audit & chuẩn hóa 99 skills theo Claude Code source

Dựa trên phân tích `REPORT-skills-plugin-system.md` (Claude Code source code), audit toàn bộ 99 skills:

- **Priority 1 — Thêm `user-invocable: true` cho 16 skills:** `architecture-decision-records`, `code-review-checklist`, `postgres-patterns`, `postmortem-writing`, `pr-writer`, `prisma-expert`, `radix-ui-design-system`, `rag-engineer`, `react-native-architecture`, `react-nextjs-development`, `security-audit`, `senior-frontend`, `springboot-patterns`, `sql-optimization-patterns`, `tailwind-patterns`, `vector-database-engineer`.
- **Priority 2 — Thêm `when_to_use:` cho 15 tech skills:** Mô tả ngữ cảnh routing chi tiết cho 15 technology skills chưa có (cùng danh sách trên, trừ `architecture-decision-records` đã có, thêm `shadcn`).
- **Priority 3 — Dọn 150 dòng non-standard fields từ 49 skills:** Xóa `source:`, `risk:`, `date_added:`, `category:`, `tags:`, `author:` — các fields Claude Code parser bỏ qua. Giữ `origin:` cho provenance tracking.
- **Fix `tools:` → `allowed-tools:` trong `devops-deploy`:** Đúng tên field theo Zod schema của Claude Code.
- **Kết quả audit sau fix:** 99/99 skills ✅ PASS (description, user-invocable, effort, no non-standard fields).

---

### [v1.12.0] - 2026-04-01

**Chủ đề:** Skill Routing Enhancement — Bổ sung `user-invocable` & `when_to_use` cho 59 skills

- **Cập nhật YAML frontmatter cho 59 skill files:** Thêm thuộc tính `user-invocable: true` và/hoặc `when_to_use:` mô tả ngữ cảnh sử dụng chính xác.
- **Mục đích:** Cải thiện khả năng routing của hệ thống — giúp AI agent tự động chọn đúng skill dựa trên mô tả `when_to_use` thay vì chỉ dựa vào tên skill.
- **Phạm vi:** Bao gồm cả core workflow skills (`brainstorm`, `design-system`, `orchestrate`, `gate-check`...) và technology framework skills (`claude-api`, `fastapi-pro`, `kubernetes-architect`, `nextjs-best-practices`...).
- **Tổng thay đổi:** 59 files, 101 insertions.

---

### [v1.11.0] - 2026-04-01

**Chủ đề:** Tối ưu Context Management — Tách Rules & Guide, giảm 75% token/API call

- **Tách `context-management.md` thành 2 file:**
  - `context-management.md` (Rules — 93 dòng, ~5.7KB) — inject vào system prompt qua `CLAUDE.md`. Chỉ chứa luật ngắn gọn, imperative.
  - `context-management-guide.md` (Guide — 251 dòng, ~14KB) — file tham khảo, KHÔNG inject. Chứa toàn bộ ví dụ chi tiết, code blocks, bảng Common Misconceptions, Session Startup Order diagram, CLAUDE.md Writing Style guide, Static vs Dynamic Content Strategy, @include Chain Rules, Stop Hook Taxonomy.
- **Sắp xếp lại thứ tự ưu tiên:** Recovery → Compaction → Session State → Context Budgets → Subagent Delegation → Memory System → Incremental File Writing (quan trọng nhất lên đầu).
- **Thống nhất ngôn ngữ:** Toàn bộ `context-management.md` chuyển sang Tiếng Anh (trước đó trộn Anh-Việt).
- **Giảm code blocks:** Loại bỏ toàn bộ 8 code blocks minh họa khỏi rules file, chuyển sang guide file.
- **Cập nhật `CLAUDE.md`:** Thêm comment chỉ dẫn đến `context-management-guide.md` cho deep-dive patterns.
- **Ước tính tiết kiệm:** ~4,000-4,500 tokens mỗi API call (giảm từ ~6,000 xuống ~1,500).

---

### [v1.10.0] - 2026-04-01

**Chủ đề:** Tích hợp Claude Native 5-Layer Memory System & Skill `/dream`

- **Tạo thư mục Project Memory định tuyến mới**: Thành lập không gian lưu trữ `.claude/memory/` chứa file chỉ mục (`MEMORY.md`) cùng 4 files skeleton (`user_role.md`, `feedback_rules.md`, `project_tech_decisions.md`, và `reference_links.md`) kèm theo YAML frontmatter chuẩn.
- **Nâng cấp Skill `/save-state`**: Thêm step 2 thu thập (Extract) các "Durable Memory" (kinh nghiệm và thay đổi tech stack quan trọng) để lưu trữ vĩnh viễn thông qua các files topic chuẩn trước khi dọn dẹp các session files tạm thời.
- **Bổ sung Skill tự động quy hoạch `/dream`**: Workflow skill phục vụ việc dọn dẹp, tối ưu, nối và nén các files memory bị trùng lặp. Đảm bảo hệ thống AI team luôn có không gian recall ngữ cảnh nhanh nhất.
- **Bổ sung vào `CLAUDE.md` Master Root**: Inject Project Durable Memory framework vào master configuration. 

---

### [v1.9.0] - 2026-04-01

**Chủ đề:** SDD Upgrade dựa trên phân tích Claude Code source code

Nguồn: Phân tích 512K lines source code Claude Code tại `D:\Claude Source Code Original`.
Chi tiết: [upgrade_plan_based_claude_code_original.md](upgrade_plan_based_claude_code_original.md)

**Phase 1 — Quick Wins:**

- `.claude/skills/code-review/SKILL.md` — Fix toàn bộ game references còn sót:
  - Category list: `engine, gameplay` → `api, service, repository, component, utility, infrastructure`
  - Dependency rule: `engine ← gameplay` → `infrastructure ← domain ← application`
  - Section 7: "Game development issues" → "Web/Software issues"
  - Bỏ: frame-rate independence, hot path allocations
  - Thêm: N+1 queries, async/await, input validation, secrets hardcoded, resource cleanup

- Memory files — Tạo 3 skeleton files tại `~/.claude/projects/.../memory/`:
  - `feedback_skill_patterns.md` — Skills & patterns hiệu quả trong SDD
  - `feedback_code_review_findings.md` — Lỗi code hay lặp lại, cần check proactively
  - `project_tech_decisions.md` — Stack đã approve theo loại project

**Phase 2 — Conditional Skills (`paths:` frontmatter):**

Thêm `paths:` vào **48 technology skills** — skills chỉ visible khi mở file phù hợp:

| Nhóm                            | Skills | Ví dụ trigger                                     |
| ------------------------------- | ------ | ------------------------------------------------- |
| Frontend / React / Next.js      | 13     | `*.tsx`, `next.config.*`, `tailwind.config.*`     |
| Backend Node.js / NestJS        | 7      | `*.module.ts`, `nest-cli.json`, `schema.prisma`   |
| Python                          | 6      | `*.py`, `manage.py`, `requirements.txt`           |
| Mobile (Flutter / iOS / KMP)    | 4      | `*.dart`, `*.swift`, `pubspec.yaml`               |
| Database (SQL / NoSQL / Vector) | 4      | `*.sql`, `migrations/**`, `*.prisma`              |
| Infrastructure / DevOps         | 7      | `Dockerfile*`, `k8s/**`, `*.tf`, `.gitlab-ci.yml` |
| .NET / Java / PHP               | 3      | `*.cs`, `*.java`, `*.php`, `pom.xml`              |
| AI / LLM                        | 4      | `*anthropic*`, `*langchain*`, `*gemini*`          |

Kết quả: Gõ `/` khi làm Next.js project → ~20 skills thay vì 98.

**Phase 3–5 — Advanced Settings & Routing:**

- Thêm thuộc tính `context: fork` để chạy độc lập cho 6 analysis skills nặng.
- Thêm `effort:` (1-5) vào toàn bộ 98 skills giúp mô hình AI phân bổ token & tùy chỉnh Thinking Mode.
- Thêm `when_to_use:` cho 4 workflow skills dễ nhầm lẫn.
- Hệ thống hóa CLAUDE.md: chỉ include universal rules, dùng `paths:` cho các domain rules.

---

### [v1.8.0] - 2026-03-30

**Chủ đề:** Nâng cấp Quy mô Skills — Tích hợp hệ thống phân tích, framework và công nghệ gốc từ Global System.

**Đột phá bổ sung gần 60 Global Skills:**
- **SDLC Quyền Trình & Nghiệm thu:** Đã thêm `architecture-decision-records`, `code-review-checklist`, `commit`, `deployment-procedures`, `pr-writer`, `postmortem-writing`, `security-audit`, `tdd-workflow`.
- **Backend & Database:** Thêm hơn 15 skills chuyên sâu gồm `backend-architect`, `django-pro`, `fastapi-pro`, `nestjs-expert`, `postgres-patterns`, `prisma-expert`, v.v...
- **Frontend & Mobile:** Cập nhật 15+ patterns chất lượng từ Vercel & Apple: `nextjs-app-router-patterns`, `tailwind-patterns`, `flutter-expert`, `radix-ui-design-system`, v.v.
- **AI & DevOps:** Mở rộng mảng vận hành MLOps và đám mây với `ml-engineer`, `kubernetes-architect`, `aws-serverless`, `rag-engineer`.

**Rà soát:** Tổng quan thư phòng Skills hiện lên tới **98 Skills** cho Claude Code.

---

### [v1.7.0] - 2026-03-30

**Rà soát & xử lý 8 skills mới:**

- `.claude/skills/tdd-workflow/` — **Xóa** (duplicate 100% với marketplace plugin `antigravity-awesome-skills`, không có giá trị bổ sung)
- `.claude/skills/commit/SKILL.md` — Làm sạch Sentry-specific: bỏ `create-branch` dependency, đổi `SENTRY-xxxx` → `#xxxx`, reference → `conventionalcommits.org`
- `.claude/skills/pr-writer/SKILL.md` — Làm sạch Sentry-specific: bỏ `sentry-skills:commit`, đổi `SENTRY-xxxx` → `#xxxx`, references → GitHub CLI docs + Conventional Commits
- `.claude/skills/architecture-decision-records/` — Giữ nguyên (framework ADR lifecycle đầy đủ, bổ sung tốt cho `architecture-decision`)
- `.claude/skills/code-review-checklist/` — Giữ nguyên (checklist 6 bước có cấu trúc)
- `.claude/skills/deployment-procedures/` — Giữ nguyên (nguyên tắc deployment an toàn)
- `.claude/skills/postmortem-writing/` — Giữ nguyên (blameless postmortem sau incident)
- `.claude/skills/security-audit/` — Giữ nguyên (workflow bundle kiểm tra bảo mật)

**Update skills cho 16 agents:**

| Agent                 | Skills mới                                                                                                                                                                                                                                                                            |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `backend-developer`   | code-review-checklist, commit, pr-writer, backend-architect, microservices-patterns, nodejs-backend-patterns, nestjs-expert, fastapi-pro, django-patterns, springboot-patterns, docker-patterns, postgres-patterns, sql-optimization-patterns, backend-security-coder, aws-serverless |
| `frontend-developer`  | code-review-checklist, commit, pr-writer, senior-frontend, react-nextjs-development, nextjs-app-router-patterns, nextjs-best-practices, angular-best-practices, tailwind-patterns, shadcn, radix-ui-design-system, frontend-design, frontend-security-coder, frontend-ui-dark-ts      |
| `fullstack-developer` | code-review-checklist, commit, pr-writer, react-nextjs-development, nextjs-app-router-patterns, nextjs-best-practices, prisma-expert, drizzle-orm-expert                                                                                                                              |
| `mobile-developer`    | code-review-checklist, commit, pr-writer, flutter-expert, ios-developer, react-native-architecture, compose-multiplatform-patterns                                                                                                                                                    |
| `data-engineer`       | code-review-checklist, database-architect, postgres-patterns, nosql-expert, sql-optimization-patterns, vector-database-engineer, drizzle-orm-expert, prisma-expert, event-sourcing-architect                                                                                          |
| `lead-programmer`     | code-review-checklist, architecture-decision-records, commit, pr-writer                                                                                                                                                                                                               |
| `devops-engineer`     | commit, deployment-procedures, postmortem-writing, docker-patterns, kubernetes-architect, gitlab-ci-patterns, aws-serverless, hybrid-cloud-architect, cloud-architect, deployment-engineer, devops-deploy                                                                             |
| `security-engineer`   | security-audit, backend-security-coder, frontend-security-coder                                                                                                                                                                                                                       |
| `technical-director`  | architecture-decision-records, microservices-patterns, event-sourcing-architect, cloud-architect, hybrid-cloud-architect                                                                                                                                                              |
| `cto`                 | architecture-decision-records, cloud-architect, hybrid-cloud-architect                                                                                                                                                                                                                |
| `ai-programmer`       | ml-engineer, mlops-engineer, rag-engineer, llm-app-patterns, llm-application-dev-ai-assistant, gemini-api-integration, vector-database-engineer                                                                                                                                       |
| `ui-programmer`       | commit, pr-writer, radix-ui-design-system, shadcn, tailwind-patterns, frontend-ui-dark-ts                                                                                                                                                                                             |
| `tools-programmer`    | commit, pr-writer                                                                                                                                                                                                                                                                     |
| `producer`            | postmortem-writing                                                                                                                                                                                                                                                                    |
| `release-manager`     | deployment-procedures                                                                                                                                                                                                                                                                 |
| `qa-lead`             | code-review-checklist                                                                                                                                                                                                                                                                 |

---

### [v1.6.0] - 2026-03-30

**Chủ đề:** Tích hợp orchestrated-project-template & tối ưu hóa harness

**Phase 1–6 — Tích hợp từ [orchestrated-project-template](https://github.com/josipjelic/orchestrated-project-template):**

- `PRD.md` — Template Product Requirements Document với FR-numbered requirements, WARNING banner, Approvals table (Product Manager, Technical Director, CTO)
- `TODO.md` — Living backlog governed by `@producer`, hỗ trợ 14 area tags (mobile, security, analytics, network, ai, v.v.)
- `.tasks/TASK_TEMPLATE.md` — Task detail file template với YAML frontmatter (id, status, area, agent, prd_refs, blocks, blocked_by)
- `docs/technical/DECISIONS.md` — Compact ADR log, append-only, với Decision Index table
- Tất cả 27 `.claude/agents/*.md` — Thêm ba sections ownership: `## Documents You Own`, `## Documents You Read (Read-Only)`, `## Documents You Never Modify`
- `producer.md` — Thêm `## TODO.md Governance Protocol` với sync rules table
- `.claude/skills/orchestrate/SKILL.md` — Wave-based multi-agent orchestration skill (8 phases, routing table cho 21 agents, adapted `@project-manager` → `@producer`)
- `.claude/skills/sync-template/SKILL.md` — Sync `.claude/` từ upstream repo with diff/confirm flow
- `.claude/docs/agent-coordination-map.md` — Thêm Pattern 0: Multi-Agent Orchestration
- `.claude/skills/architecture-decision/SKILL.md` — Thêm cross-post ADR summary sang `docs/technical/DECISIONS.md`

**4 tối ưu hóa (plan_optimization.md):**

- `src/`, `tests/`, `infra/`, `scripts/`, `docs/user/` — Thêm `.gitkeep` để scaffolding thư mục dự án
- `.env.example` — Template environment variables được nhóm theo concern (App, Database, Auth, Email, Storage, AI, Feature Flags)
- `.claude/skills/save-state/SKILL.md` — Skill lưu working context vào `production/session-state/active.md`; tích hợp với `session-start.sh` và `pre-compact.sh`
- `docs/technical/CODEMAP.md` + `.claude/skills/update-codemap/SKILL.md` — Navigation map cho AI agents + skill cập nhật sau mỗi feature merge

**Cập nhật docs:**

- `.claude/docs/skills-reference.md` — Thêm `/orchestrate`, `/sync-template`, `/save-state`, `/update-codemap`
- `.claude/docs/directory-structure.md` — Thêm `PRD.md`, `TODO.md`, `.tasks/`, `docs/technical/`, `docs/user/`
- `.claude/docs/quick-start.md` — Thêm `/orchestrate` vào slash commands, cập nhật onboarding paths A & B
- `.claude/docs/agent-roster.md` — `tech-writer` Sonnet → Haiku
- `.claude/rules/secrets-config.md` — Reference đến `.env.example` là canonical source
- `design/README.md` — Hướng dẫn thư mục design với subfolders (wireframes, specs, research, flows)
- `README.md` & `README_en.md` — Version 1.6.0, skills badge 37 → 41

---

### [v1.5.1] - 2026-03-30

**Chủ đề:** Đồng bộ README và bổ sung tài nguyên mới

**Thay đổi chi tiết:**

- Cập nhật `README.md` & `README_en.md`:
  - Đồng bộ số liệu thực tế: 27 agents, 37 skills, 11 rules, 8 hooks.
  - Thêm banner badges (license, agents, skills, hooks, rules, v.v.) vào đầu file `README.md`.
  - Bổ sung thư mục `.tasks/`, `PRD.md`, `TODO.md` vào phần Cấu trúc thư mục.
  - Thêm phần "Tài nguyên bổ sung" / "Additional Resources" chứa các liên kết cực kỳ hữu ích: `plan_upgrade.md`, `compare_department_orchestrated.md`, `infographic.html`, `UPGRADING.md`, `History_Update.md`.
  - Cập nhật version lên 1.5.1.

---

### [v1.5.0] - 2026-03-28

**Chủ đề:** Dọn sạch game references trong toàn bộ `.claude/agents/`

**Dọn game references — SEVERE (5 agents):**

- `.claude/agents/accessibility-specialist.md` — Description: "game is playable" → "software is accessible"; xóa gamepad/Xbox/PlayStation/Switch/Pause lines; "quest reminders" → "Key action shortcuts"
- `.claude/agents/ai-programmer.md` — Description: "game AI / NPC behavior" → "intelligent system features / LLM integrations"; "NPCs, enemies" → "recommendations, predictions"; "player time to react" → "explainable and auditable"
- `.claude/agents/analytics-engineer.md` — Description: "player behavior tracking" → "user behavior tracking"; event examples `game.level.started`, `game.combat.enemy_killed` → `user.session.started`, `user.action.completed`; "game design decisions" → "product decisions"
- `.claude/agents/performance-analyst.md` — Description: "profiles game performance / frame time" → "profiles application performance / response time"; "Gameplay Logic" → "Business Logic"; "game state" → "application state"
- `.claude/agents/network-programmer.md` — Description: "multiplayer / netcode / matchmaking" → "real-time / WebSocket / event streaming"; "gameplay state" → "application state"; "entity interpolation" → "state interpolation"

**Dọn game references — MODERATE (5 agents):**

- `.claude/agents/producer.md` — "how other games handled" → "how other products handled"; "game design changes" → "product design changes"
- `.claude/agents/technical-director.md" — "how other games handled" → "how other products handled"
- `.claude/agents/qa-lead.md" — "Playtest Coordination" → "User Testing Coordination"; "gameplay impact" → "user impact"
- `.claude/agents/release-manager.md" — "player-facing messaging" → "user-facing messaging"
- `.claude/agents/security-engineer.md" — "multiplayer security" → "real-time and distributed system security"

---

### [v1.4.0] - 2026-03-28

**Chủ đề:** Review tổng thể lần 3 — Sửa số đếm, Mobile templates, Secrets rule, Dọn sạch game references

**Tính năng mới:**

- `.claude/docs/templates/mobile-architecture.md` — Template kiến trúc ứng dụng mobile (layers, navigation, state, offline, push notifications, security, testing)
- `.claude/docs/templates/app-store-submission-checklist.md` — Checklist submit App Store/Play Store (iOS + Android riêng biệt, legal, sign-offs)
- `.claude/rules/secrets-config.md` — Rule quản lý secrets & config (env vars, CI/CD secrets, forbidden patterns, logging scrubbing)

**Sửa số đếm trong docs:**

- `README.md`, `README_en.md` — Cập nhật đúng: 27 agents, 35 skills, 10 rules
- `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`, `.claude/docs/quick-start.md`, `.claude/docs/agent-roster.md` — Đồng bộ số đếm
- `.claude/docs/coding-standards.md` — Thêm cross-reference đến `secrets-config.md`

**Dọn game references — SEVERE (viết lại hoàn toàn):**

- `.claude/docs/templates/pitch-document.md` — "Game Pitch" → "Product Pitch", xóa "Audio Identity", "Player Fantasy" → "User Value Proposition", Steam/Console → Web/Mobile/SaaS
- `.claude/docs/templates/systems-index.md` — `design/gdd/` → `design/specs/`, "Gameplay" → "Business Logic", xóa category Audio, thêm Integrations

**Dọn game references — MODERATE:**

- `.claude/docs/templates/release-checklist-template.md` — FPS → API response time, xóa Xbox/PlayStation, Console section → Mobile section, ESRB/PEGI → generic
- `.claude/docs/templates/project-stage-report.md` — "Polish" → "Hardening", `design/levels/` → `design/specs/`
- `.claude/docs/templates/design-doc-from-implementation.md` — "Player-Facing" → "User-Facing", "Balance and Tuning" → "Configuration and Tuning", `/balance-check` → `/perf-profile`
- `.claude/docs/templates/architecture-doc-from-code.md` — "60 FPS" → "sub-100ms response time"

**Dọn game references — MINOR (9 files):**

- `changelog-template.md` — "player-visible" → "user-visible", "Healing potions" → API latency, "Thank you for playing!" → fixed
- `release-notes.md` — "players" → "users", "saved games" → "large datasets", "Thank you for playing!" → fixed
- `incident-response.md` — "player perspective/report" → "user perspective/report", "XP boost" → "service credit"
- `milestone-definition.md` — "Vertical Slice" → "Working Demo", "Gold" → "Release Candidate", FPS → API response time
- `technical-design-document.md` — "game design doc" → "product/feature spec"
- `test-plan.md` — "save files" → "test data, user accounts"
- `collaborative-protocols/implementation-agent-protocol.md` — "damage calculation" → "payment processing", `design/gdd/` → `design/specs/`
- `collaborative-protocols/design-agent-protocol.md` — "crafting system" → "notification system", "game design theory" → "UX/product design theory"
- `collaborative-protocols/leadership-agent-protocol.md` — "game-designer/crafting" → "product-manager/onboarding", "Hades" → "Basecamp"

---

### [v1.3.0] - 2026-03-28

**Chủ đề:** Bổ sung Mobile Development & Collaborative Design Principle

#### 📄 Tài liệu cập nhật

- `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` — Bổ sung nguyên tắc thiết kế cộng tác cho phát triển phần mềm; cập nhật ví dụ từ game design sang software engineering (auth API, JWT, database schema)
- `README.md` — Cập nhật nội dung hướng dẫn sử dụng template bằng tiếng Việt
- `README_en.md` — Cập nhật nội dung hướng dẫn sử dụng template bằng tiếng Anh
- `.claude/docs/agent-roster.md` — Cập nhật danh sách agent
- `.claude/docs/quick-start.md` — Cập nhật hướng dẫn bắt đầu nhanh

#### ✨ Tính năng mới

- `feat(mobile)`: Thêm **mobile-developer** agent và các mobile skills
- `.claude/docs/templates/app-store-submission-checklist.md` — Template checklist submit lên App Store
- `.claude/docs/templates/mobile-architecture.md` — Template kiến trúc ứng dụng mobile
- `.claude/rules/secrets-config.md` — Quy tắc quản lý secrets và config bảo mật

---

### [v1.2.0] - 2026-03-27

**Chủ đề:** Cải thiện Skills — Feature Spec & Brainstorming

#### 📄 Tài liệu cập nhật

- `fix(feature-spec)`: Viết lại skill **design-system** để phù hợp với feature specification phần mềm
- `fix(brainstorm)`: Viết lại skill **brainstorm** cho ngữ cảnh phát triển sản phẩm phần mềm

---

### [v1.1.0] - 2026-03-27

**Chủ đề:** Hoàn thiện Documentation & Hướng dẫn người dùng

#### 📄 Tài liệu cập nhật

- `docs`: Đổi tên `README` → `README_en` và `user_guide` → `README`
  (Hướng dẫn tiếng Việt trở thành README chính)
- `docs`: Thêm `user_guide.md` (README tiếng Việt) — hướng dẫn đầy đủ về cách sử dụng template
- `docs`: Cập nhật `README.md` — thêm URL clone chính xác và thông tin tác giả
- `LICENSE` — Cập nhật tên tác giả bản quyền

---

### [v1.0.0] - 2026-03-27

**Chủ đề:** Ra mắt — Chuyển đổi từ Game Studio → Software Department

#### 📄 Tài liệu khởi tạo

- `init`: Khởi tạo **Claude Code Software Development Department** template
- `cleanup`: Xóa toàn bộ tài liệu tham chiếu các game engine (Godot, Unity, Unreal Engine)
- `chore`: Chuyển đổi template từ "Game Studio" sang "Software Department":
  - Thay thế các vai trò game (Game Designer, Level Designer, VFX Artist) bằng vai trò phần mềm (CTO, Product Manager, Frontend/Backend/Fullstack Developer, Data Engineer, UX Researcher)
  - Cập nhật tất cả skills, workflows, và agent definitions sang ngữ cảnh software engineering
  - Cập nhật WORKFLOW-GUIDE.md với ví dụ thực tế về phát triển phần mềm

---

## 📌 Ghi chú

- **Versioning**: Theo [Semantic Versioning](https://semver.org/) — `MAJOR.MINOR.PATCH`
- **Format**: Mỗi entry ghi rõ ngày, chủ đề, và danh sách file thay đổi cụ thể
- **Mục đích**: Giúp team theo dõi tiến độ cập nhật tài liệu và hiểu lý do thay đổi

---

Last Updated: 2026-04-17 — v1.31.2
