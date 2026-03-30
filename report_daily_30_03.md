# Báo cáo cập nhật ngày 30/03/2026

> **Dự án:** Claude Code Software Development Department
> **Ngày:** 2026-03-30
> **Phiên bản:** v1.5.1 → **v1.6.0**
> **Tổng file thay đổi:** 53 files (27 agents + 5 skills + 7 docs + 6 rules/templates + 8 files mới)

---

## Tóm tắt

Phiên làm việc hôm nay thực hiện **so sánh chuyên sâu** với [orchestrated-project-template](https://github.com/josipjelic/orchestrated-project-template), sau đó **tích hợp 6 phase** các tính năng tốt nhất vào harness hiện tại, và **tối ưu hóa thêm 4 hạng mục** theo kế hoạch riêng. Kết quả: hệ thống trưởng thành hơn đáng kể — từ một tập hợp agents độc lập thành một **department có document ownership, backlog system, và session state management** hoàn chỉnh.

---

## 1. Phân tích & Lập kế hoạch

### 1.1 So sánh với orchestrated-project-template

- **File tạo mới:** [`compare_department_orchestrated.md`](compare_department_orchestrated.md)
- So sánh toàn diện hai hệ thống: Department (27 agents, 37 skills) vs Template (structured orchestration, document ownership, PRD/TODO system)
- Xác định 6 điểm mạnh của template cần tích hợp

### 1.2 Kế hoạch tích hợp

- **File tạo mới:** [`plan_upgrade.md`](plan_upgrade.md) — 6-phase integration roadmap
- **File tạo mới:** [`plan_optimization.md`](plan_optimization.md) — 4-item optimization plan (v1.6.x)

---

## 2. Phase 1 — Document Ownership System

**Vấn đề giải quyết:** Agents không biết file nào mình được phép sửa → xung đột domain, sửa nhầm file.

### Thay đổi:

Tất cả **27 agent files** trong `.claude/agents/` được bổ sung 3 sections mới:

```markdown
## Documents You Own
## Documents You Read (Read-Only)
## Documents You Never Modify
```

- Mỗi agent giờ có ranh giới file rõ ràng
- `producer.md` — thêm `## TODO.md Governance Protocol` với bảng sync rules
- `technical-director.md` — thêm `docs/technical/CODEMAP.md` vào Documents You Own

**Files thay đổi:** 27 agent files

---

## 3. Phase 2 — PRD & Backlog System

**Vấn đề giải quyết:** Không có nguồn sự thật duy nhất cho requirements và task tracking.

### Thêm mới:

| File | Mô tả |
|------|-------|
| [`PRD.md`](PRD.md) | Template Product Requirements Document — FR-numbered requirements, WARNING banner, Approvals table (Product Manager, Technical Director, CTO) |
| [`TODO.md`](TODO.md) | Living backlog governed by `@producer` — 14 area tags (mobile, security, analytics, network, ai, v.v.) |
| [`.tasks/TASK_TEMPLATE.md`](.tasks/TASK_TEMPLATE.md) | Task detail file template với YAML frontmatter: `id`, `status`, `area`, `agent`, `prd_refs`, `blocks`, `blocked_by` |
| [`docs/technical/DECISIONS.md`](docs/technical/DECISIONS.md) | Compact ADR log, append-only, với Decision Index table |

### Phân công ownership:

- `@product-manager` owns `PRD.md`
- `@producer` owns `TODO.md` + `.tasks/`
- `@technical-director` owns `docs/technical/DECISIONS.md`

---

## 4. Phase 3 — Wave-Based Orchestration Skill

**Vấn đề giải quyết:** Không có cơ chế phối hợp nhiều agents song song cho một feature lớn.

### Thêm mới:

- **[`.claude/skills/orchestrate/SKILL.md`](.claude/skills/orchestrate/SKILL.md)** — Wave-based multi-agent execution
  - 8 phases: context analysis → wave planning → backlog registration → branch creation → wave execution → QA → merge → CODEMAP update
  - Routing table cho 21 agents
  - Adapted `@project-manager` (template) → `@producer` (Department)
  - Slash command: `/orchestrate`

---

## 5. Phase 4 — Sync Template Skill

**Vấn đề giải quyết:** Không có cách cập nhật `.claude/` từ upstream template mà không mất customization.

### Thêm mới:

- **[`.claude/skills/sync-template/SKILL.md`](.claude/skills/sync-template/SKILL.md)**
  - Show diff trước khi apply
  - Confirm flow — không tự động ghi đè
  - Chỉ update new/modified files, giữ nguyên customization
  - Slash command: `/sync-template`

---

## 6. Phase 5 — ADR Dual-Track System

**Vấn đề giải quyết:** Hai ADR systems tồn tại song song mà không liên kết nhau.

### Thay đổi:

- **[`.claude/skills/architecture-decision/SKILL.md`](.claude/skills/architecture-decision/SKILL.md)** — Thêm Step 6: cross-post ADR summary sang `docs/technical/DECISIONS.md`

### Dual-track approach:

| Track | File | Dùng cho |
|-------|------|----------|
| Compact | `docs/technical/DECISIONS.md` | Quick reads trong `/orchestrate`, overview |
| Detailed | `docs/architecture/adr-NNNN-*.md` | Full context, rationale, alternatives |

---

## 7. Phase 6 — Model Cost Optimization

**Vấn đề giải quyết:** `tech-writer` dùng Sonnet cho tác vụ doc-heavy — lãng phí cost.

### Thay đổi:

- **`.claude/agents/tech-writer.md`** — `model: sonnet` → `model: haiku`
- **`.claude/docs/agent-roster.md`** — Cập nhật model tier cho tech-writer

**Lý do:** Tech-writer chủ yếu format/structure text, không cần reasoning phức tạp. Haiku đủ mạnh, tiết kiệm ~70% cost cho agent này.

---

## 8. Tối ưu hóa thêm (plan_optimization.md)

### 8.1 Directory Scaffolding

Tạo `.gitkeep` để git track các thư mục trống:

- `src/.gitkeep`
- `tests/.gitkeep`
- `infra/.gitkeep`
- `scripts/.gitkeep`
- `docs/user/.gitkeep`

Agents giờ có thể tham chiếu đến các thư mục này mà không bị lỗi "path not found".

### 8.2 Secrets Management Template

- **[`.env.example`](.env.example)** — Template environment variables được nhóm theo concern:
  - `APP_*` — Application settings
  - `DATABASE_*` — Database connection
  - `AUTH_*` — Authentication (JWT, OAuth)
  - `SMTP_*` — Email service
  - `STORAGE_*` — File storage
  - `AI_*` — AI/LLM API keys
  - `FEATURE_*` — Feature flags

- **`.claude/rules/secrets-config.md`** — Reference đến `.env.example` là canonical source

### 8.3 Session State Management

- **[`.claude/skills/save-state/SKILL.md`](.claude/skills/save-state/SKILL.md)**
  - Slash command: `/save-state`
  - Ghi context vào `production/session-state/active.md`
  - Integrate với hook `session-start.sh` (read) và `pre-compact.sh` (inject)
  - Giải quyết vấn đề mất context sau `/clear` hoặc session crash

### 8.4 CODEMAP Navigation System

- **[`docs/technical/CODEMAP.md`](docs/technical/CODEMAP.md)** — AI navigation map với 5 sections:
  - Application Modules
  - API Endpoints
  - Shared Utilities
  - Data Models / Schemas
  - External Integrations
  + Revision History table

- **[`.claude/skills/update-codemap/SKILL.md`](.claude/skills/update-codemap/SKILL.md)**
  - Slash command: `/update-codemap`
  - Scan codebase và update CODEMAP sau mỗi feature merge lớn
  - Cảnh báo: "A stale CODEMAP is worse than none"

---

## 9. Cập nhật Documentation

| File | Thay đổi |
|------|----------|
| `.claude/docs/skills-reference.md` | Thêm `/orchestrate`, `/sync-template`, `/save-state`, `/update-codemap` |
| `.claude/docs/directory-structure.md` | Thêm `PRD.md`, `TODO.md`, `.tasks/`, `docs/technical/`, `docs/user/` |
| `.claude/docs/quick-start.md` | Thêm `/orchestrate`, cập nhật onboarding paths A & B |
| `.claude/docs/agent-coordination-map.md` | Thêm Pattern 0: Multi-Agent Orchestration |
| `design/README.md` | Hướng dẫn thư mục design (wireframes, specs, research, flows) |
| `README.md` | Version → 1.6.0, skills badge 37 → **41** |
| `README_en.md` | Version → 1.6.0, skills badge 37 → **41** |
| `History_Update.md` | Thêm entry [v1.6.0], fix lint warnings |

---

## 10. Số liệu tổng kết

| Hạng mục | Trước | Sau | Thay đổi |
|----------|-------|-----|----------|
| Agents | 27 | 27 | Không đổi (chỉ cập nhật nội dung) |
| Skills (slash commands) | 37 | **41** | +4 |
| Files mới tạo | — | — | **+14 files** |
| Files cập nhật | — | — | **+39 files** |
| Agents có document ownership | 0 | **27** | +27 |

### 4 Skills mới:

| Skill | Command | Mô tả |
|-------|---------|-------|
| Orchestrate | `/orchestrate` | Wave-based multi-agent execution |
| Sync Template | `/sync-template` | Sync `.claude/` từ upstream |
| Save State | `/save-state` | Lưu session context |
| Update Codemap | `/update-codemap` | Cập nhật navigation map |

---

## 11. Những vấn đề đã giải quyết

| Vấn đề | Giải pháp |
|--------|-----------|
| Agents sửa file ngoài domain | Document ownership sections trong tất cả 27 agents |
| Không có nguồn sự thật cho requirements | PRD.md + TODO.md + .tasks/ system |
| Không thể chạy nhiều agents song song | `/orchestrate` wave-based execution |
| Mất context sau /clear hoặc crash | `/save-state` → `production/session-state/active.md` |
| Agents không biết codebase structure | CODEMAP.md + `/update-codemap` |
| Secrets hardcoded trong code | `.env.example` + `secrets-config.md` rule |
| Không thể cập nhật template từ upstream | `/sync-template` skill |
| Two ADR systems không liên kết | Dual-track: compact DECISIONS.md + detailed adr-NNNN |
| tech-writer tốn cost Sonnet | Downgrade → Haiku model |

---

*Báo cáo được tổng hợp vào cuối phiên làm việc ngày 2026-03-30.*
