# User Guide — Software Development Department

> **Author:** [tranhieutt](https://github.com/tranhieutt)
> **Version:** 1.19.0 | **Updated:** 2026-04-03

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-27-blueviolet" alt="27 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-98-green" alt="98 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-8-orange" alt="8 Hooks"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-12-red" alt="12 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
</p>
---

## Mục lục

1. [Tổng quan](#1-tổng-quan)
2. [Cài đặt](#2-cài-đặt)
3. [Kiến trúc hệ thống](#3-kiến-trúc-hệ-thống)
4. [Tài nguyên bổ sung](#4-tài-nguyên-bổ-sung)
5. [Các thành phần chính](#5-các-thành-phần-chính)
6. [Bắt đầu sử dụng](#6-bắt-đầu-sử-dụng)
7. [Slash Commands (Skills)](#7-slash-commands-skills)
8. [Agents — Đội ngũ AI](#8-agents--đội-ngũ-ai)
9. [Rules — Coding Standards](#9-rules--coding-standards)
10. [Hooks — Automated Checks](#10-hooks--automated-checks)
11. [Luồng làm việc thực tế](#11-luồng-làm-việc-thực-tế)
12. [Nguyên tắc cốt lõi](#12-nguyên-tắc-cốt-lõi)
13. [Tùy chỉnh template](#13-tùy-chỉnh-template)

---

## 1. Tổng quan

**Software Development Department** biến một session Claude Code đơn lẻ thành một **phòng ban phát triển phần mềm đầy đủ** với 27 AI agents chuyên biệt và gần 100 chuyên môn Framework/Hệ thống (như AWS, Kubernetes, Next.js, FastAPI, v.v.).

Thay vì một AI đa năng làm mọi thứ với kiến thức thông thường, bạn có:

- **CTO** giữ tầm nhìn kiến trúc (kể cả Cloud/Hybrid-Cloud).
- **Product Manager** quản lý requirements với các check-list chuẩn của PM quy mô lớn.
- **Lead Programmer** giám sát chất lượng code (Clean Code, TDD).
- **QA & Security** đảm bảo chất lượng và bảo vệ hệ thống khỏi OWASP vulnerabilities.
- ... và 22 specialists khác được "vũ trang" các best-practices cập nhật nhất.

Bạn vẫn là người ra quyết định cuối cùng. AI team cung cấp cấu trúc, chuyên môn và sự kiểm soát cực kỳ mạnh mẽ cho mọi tech-stack mong muốn.

---

## 2. Cài đặt

### Yêu cầu

- [Node.js](https://nodejs.org/) v18+ (để cài Claude Code CLI)
- [Git](https://git-scm.com/)
- Tài khoản [Anthropic](https://console.anthropic.com/) với API key

### Các bước

**Bước 1 — Clone repository:**

```bash
git clone https://github.com/tranhieutt/software_development_department.git my-project
cd my-project
```

**Bước 2 — Cài Claude Code CLI:**

```bash
# Windows (cmd.exe)
npm install -g @anthropic-ai/claude-code

# macOS / Linux
npm install -g @anthropic-ai/claude-code
```

**Bước 3 — Khởi động AI (Antigravity hoặc Claude Code):**

*Option A: Nền tảng Antigravity (Khuyên dùng cho trải nghiệm đa tác vụ)*
- Mở thư mục dự án bằng Antigravity Agentic IDE/Environment.
- Antigravity sẽ tự động nhận diện toàn bộ thư mục `.claude` và kích hoạt ngay lập tức 98 workflows/frameworks chuyên biệt. Bạn chỉ cần chat tự nhiên để tương tác và giao việc.

*Option B: Claude Code CLI*
```bash
claude
```

**Bước 4 — Khởi chạy:**

```
/start
```

---

## 3. Kiến trúc hệ thống

```
Bạn (User — người ra quyết định)
        │
        ▼
Claude Code Session
        │
        ├── .claude/agents/     ← 27 AI agents chuyên biệt
        ├── .claude/skills/     ← 98 slash commands (workflows & platform skills)
        ├── .claude/hooks/      ←  8 automated validation scripts
        ├── .claude/rules/      ← 12 path-scoped coding standards
        ├── .claude/docs/       ← Templates, references, guides
        └── .claude/docs/context-management-guide.md  ← Deep-dive patterns (không inject)
```

### Cấu trúc thư mục dự án

```
my-project/
├── CLAUDE.md                    # Cấu hình chính — định nghĩa tech stack
├── PRD.md                       # Product requirements document
├── TODO.md                      # Living backlog
├── .claude/                     # Cấu hình AI team, skills, rules
├── .claude/memory/              # Hệ thống 5-layer Native Memory System
├── .tasks/                      # Task detail files (mỗi file một TODO)
├── src/                         # Source code ứng dụng
├── tests/                       # Test suites
├── docs/                        # Tài liệu kỹ thuật, ADRs
├── design/                      # PRDs, wireframes, research
├── infra/                       # Infrastructure as code
├── scripts/                     # Build & utility scripts
└── production/                  # Sprint plans, milestones, release tracking
```

---

## 4. Tài nguyên bổ sung

| File | Mô tả |
|------|-------------|
| [`report_new_capacity_sdd_with_gitnexus.md`](report_new_capacity_sdd_with_gitnexus.md) | Báo cáo đánh giá năng lực SDD khi kết hợp với GitNexus (Code Knowledge Graph) |
| [`plan_upgrade.md`](plan_upgrade.md) | Roadmap nâng cấp chi tiết và so sánh với các frameworks khác |
| [`compare_department_orchestrated.md`](compare_department_orchestrated.md) | So sánh: Cách tiếp cận multi-agent orchestration vs AI truyền thống |
| [`infographic.html`](infographic.html) | Sơ đồ trực quan đồ họa tương tác mô tả cấu trúc phòng ban |
| [`UPGRADING.md`](UPGRADING.md) | Hướng dẫn cách cập nhật template từ thượng nguồn (upstream) |
| [`History_Update.md`](History_Update.md) | Toàn bộ lịch sử thay đổi từ phiên bản v1.0.0 đến nay |

---

## 5. Các thành phần chính

### 5.1 CLAUDE.md — File cấu hình chủ

File quan trọng nhất. Định nghĩa:

- **Tech Stack** — Language, Framework, Database của dự án
- **Project Name & Description**
- **Status Line** — phase hiện tại của dự án
- **Team structure** — ai làm gì

Khi bắt đầu project mới, chạy `/start` để hệ thống giúp bạn điền file này.

### 5.2 Agents

27 AI agents được tổ chức theo 3 tầng:

```
Tier 1 — Leadership (model: Opus — thông minh nhất)
  cto • technical-director • producer

Tier 2 — Department Leads (model: Sonnet)
  product-manager • lead-programmer • ux-designer
  qa-lead • release-manager

Tier 3 — Specialists (model: Sonnet / Haiku)
  frontend-developer • backend-developer • fullstack-developer
  mobile-developer • ai-programmer • network-programmer • tools-programmer
  ui-programmer • data-engineer • analytics-engineer
  ux-researcher • tech-writer • prototyper
  performance-analyst • devops-engineer • security-engineer
  qa-tester • accessibility-specialist • community-manager
```

### 5.3 Skills (Slash Commands & Frameworks)

98 workflows và framework skills được đóng gói thành hệ thống. Gõ `/` trong Claude Code để xem danh sách.

### 5.4 Rules

12 coding standards tự động áp dụng theo đường dẫn file. Không cần nhớ — hệ thống tự enforce.

### 5.5 Hooks

8 scripts chạy tự động tại các điểm quan trọng (commit, push, session start, v.v.).

---

## 6. Bắt đầu sử dụng

### Lần đầu tiên

```
/start
```

Hệ thống sẽ hỏi bạn đang ở đâu:

| Lựa chọn | Mô tả | Bước tiếp theo |
|---|---|---|
| **A** Chưa có ý tưởng | Muốn khám phá xem làm gì | `/brainstorm` |
| **B** Ý tưởng mơ hồ | Có hướng nhưng chưa cụ thể | `/brainstorm [hint]` |
| **C** Concept rõ ràng | Biết muốn làm gì | `/sprint-plan` hoặc `/design-review` |
| **D** Có sẵn code/docs | Muốn tổ chức lại | `/project-stage-detect` |

### Quay lại project đang làm

```
/project-stage-detect
```

Phân tích tự động: bạn đang ở phase nào, còn thiếu gì, bước tiếp theo là gì.

---

## 7. Slash Commands (Skills)

### Khởi đầu & Phân tích

| Command | Mô tả |
|---|---|
| `/start` | Onboarding — xác định bạn đang ở đâu và định hướng tiếp theo |
| `/project-stage-detect` | Phân tích project hiện tại, xác định phase |
| `/gate-check` | Kiểm tra readiness để chuyển sang phase tiếp theo |
| `/orchestrate` | Wave-based multi-agent execution — phân tích task, chạy agents theo thứ tự |
| `/save-state` | Lưu working context vào `production/session-state/active.md` trước khi reset |
| `/update-codemap` | Cập nhật `docs/technical/CODEMAP.md` sau khi merge feature lớn |
| `/dream` | Dọn dẹp & hợp nhất bộ nhớ (Consolidate Auto-Memory) |

### Design & Planning

| Command | Mô tả |
|---|---|
| `/brainstorm` | Khám phá ý tưởng sản phẩm có cấu trúc |
| `/design-system` | Thiết kế một system/module có hướng dẫn từng bước |
| `/map-systems` | Phân rã product concept thành danh sách systems |
| `/prototype` | Tạo prototype nhanh để test hypothesis |
| `/reverse-document` | Tạo design docs từ code đã có |

### Code & Review

| Command | Mô tả |
|---|---|
| `/code-review` | Review code với checklist chuẩn |
| `/mobile-review` | Review code mobile: performance, platform standards, security, offline, accessibility |
| `/api-design` | Thiết kế REST/GraphQL API |
| `/db-review` | Review database schema & queries |
| `/perf-profile` | Phân tích performance bottlenecks |
| `/tech-debt` | Đánh giá và lên kế hoạch xử lý technical debt |
| `/architecture-decision` | Đưa ra các quyết định kiến trúc (ADRs) |

### Sprint & Release

| Command | Mô tả |
|---|---|
| `/sprint-plan` | Lên kế hoạch sprint với tasks, estimates, dependencies |
| `/milestone-review` | Đánh giá tiến độ milestone |
| `/estimate` | Ước lượng effort cho features |
| `/retrospective` | Retrospective sau sprint |
| `/release-checklist` | Checklist release đầy đủ |
| `/changelog` | Tạo changelog từ commits |
| `/patch-notes` | Tạo patch notes thân thiện với người dùng |
| `/hotfix` | Quy trình xử lý lỗi khẩn cấp |
| `/sync-template` | Cập nhật, sync template với upstream |

### Team Orchestration

Những commands mạnh nhất — tự động phối hợp nhiều agents:

| Command | Mô tả |
|---|---|
| `/team-feature` | Toàn bộ team làm một feature từ đầu đến cuối |
| `/team-backend` | Backend team thiết kế và implement API |
| `/team-frontend` | Frontend team implement UI |
| `/team-mobile` | Mobile team: platform strategy → UX → implement → QA → store release |
| `/team-ui` | UI team: UX design → implement → review |
| `/team-release` | Release team: build → test → deploy |

### Mở rộng công nghệ năng lực cực lớn

Ngoài ra, hệ thống đã được cập nhật **kho tàng gần 60 skills framework & kiến trúc mới** giúp các Agents hiểu sâu về:
- Các ngôn ngữ & framework như `java-pro`, `fastapi-pro`, `nextjs-best-practices`, `flutter-expert`.
- Cơ sở dữ liệu và Cloud backend `postgres-patterns`, `aws-serverless`, `kubernetes-architect`.
- AI & Vector DB `rag-engineer`, `llm-app-patterns`.
- SDLC Processes `architecture-decision-records`, `postmortem-writing`, `tdd-workflow`.

---

## 8. Agents — Đội ngũ AI

### Gọi agent trực tiếp

```
@cto Review kiến trúc microservices này có phù hợp không?
@security-engineer Audit authentication flow này
@qa-lead Tạo test plan cho payment feature
@tech-writer Viết API documentation cho endpoints này
```

### Delegation chain

Agents tự động phối hợp theo hierarchy:

```
Bạn → CTO → Technical Director → Lead Programmer → Backend Developer
                                                  → Frontend Developer
            → Product Manager → UX Designer
                              → UX Researcher
```

### Escalation rules

- **Conflicts kỹ thuật** → escalate lên `technical-director`
- **Conflicts strategic** → escalate lên `cto`
- **Scope/timeline** → escalate lên `producer`
- **Quality gates** → qua `qa-lead`

---

## 9. Rules — Coding Standards

Rules tự động enforce theo **đường dẫn file**. Không cần nhớ, không cần cấu hình thêm.

| Path | Standards Áp dụng |
|---|---|
| `src/api/**` | REST/GraphQL conventions, authentication, error format chuẩn |
| `src/frontend/**` | Accessibility (WCAG), design tokens, i18n, state management |
| `src/**db**` | Migrations, parameterized queries, indexing |
| `src/ui/**` | No business logic in UI, localization-ready, keyboard accessible |
| `src/ai/**` | Performance budgets, model params phải configurable, explainability |
| `src/networking/**` | Các chuẩn cho WebSocket, real-time event streaming |
| `config/**` | Schema validation, no hardcoded secrets, version when breaking change |
| `design/docs/**` | PRD sections bắt buộc, acceptance criteria rõ ràng |
| `tests/**` | Test naming conventions, coverage requirements, no flaky patterns |
| `prototypes/**` | Relaxed standards, README bắt buộc, hypothesis phải document |

---

## 10. Hooks — Automated Checks

Scripts chạy tự động, không cần nhớ:

| Hook | Khi nào | Tác dụng |
|---|---|---|
| `pre-commit-code-quality` | Mỗi `git commit` | Lint, hardcoded values, TODO format |
| `pre-push-test-gate` | Mỗi `git push` | Chạy test suite, block push nếu fail |
| `post-merge-asset-validation` | Sau merge | Validate assets, naming conventions |
| `session-start-context-loader` | Mở Claude Code | Load project context tự động |
| `post-tool-agent-coordination-audit` | Sau mỗi tool call | Đảm bảo agents không vượt domain |

---

## 11. Luồng làm việc thực tế

### Xây dựng feature mới

```
1. Bạn: "Muốn thêm feature user authentication"
         │
2.  /team-feature authentication
         │
3.  product-manager → phân tích requirements → hỏi clarifying questions
         │
4.  Bạn trả lời → product-manager viết mini-PRD
         │
5.  ux-designer → thiết kế user flow, wireframes
         │
6.  technical-director → quyết định architecture (JWT vs Session vs OAuth)
         │
7.  backend-developer + frontend-developer → implement song song
         │
8.  security-engineer → security review
         │
9.  qa-lead → viết test cases
         │
10. Bạn approve từng bước → nothing written without your OK
```

### Code review

```
Bạn:   /code-review src/api/auth.ts
         │
         ├── lead-programmer: Architecture review
         ├── security-engineer: Security audit
         └── qa-tester: Testability assessment
         │
         └── Tổng hợp: Issues + Recommendations + Priority
```

### Sprint planning

```
Bạn:   /sprint-plan
         │
product-manager: Lấy backlog từ design/docs/
         │
producer: Ước lượng effort, xác định dependencies, phân công
         │
Output: Sprint plan với tasks, owners, estimates, acceptance criteria
```

---

## 12. Nguyên tắc cốt lõi

### Collaborative, KHÔNG Autonomous

Mọi agent đều follow một protocol cố định:

```
1. HỎI    — agent đặt câu hỏi clarification trước
2. OPTIONS — đề xuất 2-4 phương án với pros/cons
3. QUYẾT  — BẠN chọn phương án
4. DRAFT  — agent show work, không viết ngay
5. APPROVE — BẠN OK → agent mới write file
```

**Không có agent nào tự ý:**
- Write file mà không hỏi
- Đưa ra quyết định kiến trúc
- Override quyết định của bạn
- Làm việc ngoài domain của mình

### Bạn luôn là người quyết định cuối

Agents là **advisor và executor**, không phải **decision maker**.

---

## 13. Tùy chỉnh template

Template được thiết kế để tùy chỉnh thoải mái:

### Thêm/xóa agents

```bash
# Xóa agent không cần
rm .claude/agents/community-manager.md

# Thêm agent mới
cp .claude/agents/backend-developer.md .claude/agents/mobile-developer.md
# Chỉnh sửa nội dung cho phù hợp
```

### Thêm rules mới

Tạo file mới trong `.claude/rules/`:

```markdown
---
paths:
  - "src/mobile/**"
---

# Mobile Code Rules

- All screens must support both portrait and landscape
- ...
```

### Sửa agent behavior

Mở file agent bất kỳ trong `.claude/agents/` và chỉnh sửa:
- **Description** — khi nào agent được gọi
- **Key Responsibilities** — agent làm gì
- **What This Agent Must NOT Do** — ranh giới domain

### Cập nhật tech stack

Chỉnh sửa `CLAUDE.md`:

```markdown
## Technology Stack
- **Language**: TypeScript
- **Framework**: Next.js 14
- **Database**: PostgreSQL + Prisma
- **Deployment**: Vercel
```

Agents sẽ tự động adjust recommendations theo tech stack.

---

## Ghi chú

- Template này dựa trên [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) by Donchitos
- Adapted for software development teams by [tranhieutt](https://github.com/tranhieutt)
- Licensed under MIT

---

*Chúc bạn build được sản phẩm tuyệt vời! 🚀*
