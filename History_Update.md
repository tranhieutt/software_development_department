# History Update Log

Tài liệu này ghi lại lịch sử cập nhật tài liệu và source code của **Software Development Department** template.

---

## 🗓️ Lịch sử cập nhật

### [v1.25.1] - 2026-04-11

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

| Skills | Trước | Sau | Ghi chú |
|---|---|---|---|
| `senior-frontend` | 495 | ~149 | Bỏ scaffolding scripts, giữ actionable patterns |
| `code-review-checklist` | 466 | ~94 | Bỏ explanations thừa, giữ checklist items |
| `architecture-decision-records` | 452 | ~127 | Bỏ verbose templates, giữ 1 MADR template |
| `postmortem-writing` | 413 | ~132 | Bỏ ví dụ dài, giữ templates + core concepts |
| `prisma-expert` | 365 | ~148 | Bỏ diagnostic scripts, giữ critical rules |
| `backend-architect` | 337 | ~95 | Bỏ 200-line capability list, thêm decision matrix |
| `aws-serverless` | 332 | ~168 | Fix truncated code snippets, remove broken tables |
| `devops-deploy` | 295 | ~197 | Fix broken YAML frontmatter, remove boilerplate |
| `database-architect` | 270 | ~120 | Bỏ bullet list, thêm SQL patterns + decision matrix |
| `frontend-design` | 281 | ~90 | Rút gọn DFI framework, thêm operator checklist |
| `mlops-engineer` | 225 | ~177 | Bỏ 150-line capability list, thêm tool matrix + 5 code patterns |

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

| Nhóm | Skills | Ví dụ trigger |
| --- | --- | --- |
| Frontend / React / Next.js | 13 | `*.tsx`, `next.config.*`, `tailwind.config.*` |
| Backend Node.js / NestJS | 7 | `*.module.ts`, `nest-cli.json`, `schema.prisma` |
| Python | 6 | `*.py`, `manage.py`, `requirements.txt` |
| Mobile (Flutter / iOS / KMP) | 4 | `*.dart`, `*.swift`, `pubspec.yaml` |
| Database (SQL / NoSQL / Vector) | 4 | `*.sql`, `migrations/**`, `*.prisma` |
| Infrastructure / DevOps | 7 | `Dockerfile*`, `k8s/**`, `*.tf`, `.gitlab-ci.yml` |
| .NET / Java / PHP | 3 | `*.cs`, `*.java`, `*.php`, `pom.xml` |
| AI / LLM | 4 | `*anthropic*`, `*langchain*`, `*gemini*` |

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

| Agent | Skills mới |
|---|---|
| `backend-developer` | code-review-checklist, commit, pr-writer, backend-architect, microservices-patterns, nodejs-backend-patterns, nestjs-expert, fastapi-pro, django-patterns, springboot-patterns, docker-patterns, postgres-patterns, sql-optimization-patterns, backend-security-coder, aws-serverless |
| `frontend-developer` | code-review-checklist, commit, pr-writer, senior-frontend, react-nextjs-development, nextjs-app-router-patterns, nextjs-best-practices, angular-best-practices, tailwind-patterns, shadcn, radix-ui-design-system, frontend-design, frontend-security-coder, frontend-ui-dark-ts |
| `fullstack-developer` | code-review-checklist, commit, pr-writer, react-nextjs-development, nextjs-app-router-patterns, nextjs-best-practices, prisma-expert, drizzle-orm-expert |
| `mobile-developer` | code-review-checklist, commit, pr-writer, flutter-expert, ios-developer, react-native-architecture, compose-multiplatform-patterns |
| `data-engineer` | code-review-checklist, database-architect, postgres-patterns, nosql-expert, sql-optimization-patterns, vector-database-engineer, drizzle-orm-expert, prisma-expert, event-sourcing-architect |
| `lead-programmer` | code-review-checklist, architecture-decision-records, commit, pr-writer |
| `devops-engineer` | commit, deployment-procedures, postmortem-writing, docker-patterns, kubernetes-architect, gitlab-ci-patterns, aws-serverless, hybrid-cloud-architect, cloud-architect, deployment-engineer, devops-deploy |
| `security-engineer` | security-audit, backend-security-coder, frontend-security-coder |
| `technical-director` | architecture-decision-records, microservices-patterns, event-sourcing-architect, cloud-architect, hybrid-cloud-architect |
| `cto` | architecture-decision-records, cloud-architect, hybrid-cloud-architect |
| `ai-programmer` | ml-engineer, mlops-engineer, rag-engineer, llm-app-patterns, llm-application-dev-ai-assistant, gemini-api-integration, vector-database-engineer |
| `ui-programmer` | commit, pr-writer, radix-ui-design-system, shadcn, tailwind-patterns, frontend-ui-dark-ts |
| `tools-programmer` | commit, pr-writer |
| `producer` | postmortem-writing |
| `release-manager` | deployment-procedures |
| `qa-lead` | code-review-checklist |

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
- `.claude/skills/sync-template/SKILL.md` — Sync `.claude/` từ upstream repo với diff/confirm flow
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
- `.claude/agents/technical-director.md` — "how other games handled" → "how other products handled"
- `.claude/agents/qa-lead.md` — "Playtest Coordination" → "User Testing Coordination"; "gameplay impact" → "user impact"
- `.claude/agents/release-manager.md` — "player-facing messaging" → "user-facing messaging"
- `.claude/agents/security-engineer.md` — "multiplayer security" → "real-time and distributed system security"

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

Last Updated: 2026-04-11 — v1.25.0
