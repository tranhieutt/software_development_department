# User Guide — Software Development Department

> **Tác giả:** [tranhieutt](https://github.com/tranhieutt)
> **Version:** 1.0 | **Cập nhật:** 2026-03-27

---

## Mục lục

1. [Tổng quan](#1-tổng-quan)
2. [Cài đặt](#2-cài-đặt)
3. [Kiến trúc hệ thống](#3-kiến-trúc-hệ-thống)
4. [Các thành phần chính](#4-các-thành-phần-chính)
5. [Bắt đầu sử dụng](#5-bắt-đầu-sử-dụng)
6. [Slash Commands (Skills)](#6-slash-commands-skills)
7. [Agents — Đội ngũ AI](#7-agents--đội-ngũ-ai)
8. [Rules — Coding Standards](#8-rules--coding-standards)
9. [Hooks — Automated Checks](#9-hooks--automated-checks)
10. [Luồng làm việc thực tế](#10-luồng-làm-việc-thực-tế)
11. [Nguyên tắc cốt lõi](#11-nguyên-tắc-cốt-lõi)
12. [Tùy chỉnh template](#12-tùy-chỉnh-template)

---

## 1. Tổng quan

**Software Development Department** biến một session Claude Code đơn lẻ thành một **phòng ban phát triển phần mềm đầy đủ** với 26 AI agents chuyên biệt.

Thay vì một AI đa năng làm mọi thứ, bạn có:

- **CTO** giữ tầm nhìn kiến trúc
- **Product Manager** quản lý requirements
- **Lead Programmer** giám sát chất lượng code
- **QA Lead** đảm bảo chất lượng sản phẩm
- **Security Engineer** bảo vệ hệ thống
- ... và 21 specialists khác

Bạn vẫn là người ra quyết định cuối cùng. AI team cung cấp cấu trúc, chuyên môn và sự kiểm soát.

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

**Bước 3 — Mở Claude Code:**

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
        ├── .claude/agents/     ← 26 AI agents chuyên biệt
        ├── .claude/skills/     ← 33 slash commands (workflows)
        ├── .claude/hooks/      ←  8 automated validation scripts
        ├── .claude/rules/      ← 11 path-scoped coding standards
        └── .claude/docs/       ← Templates, references, guides
```

### Cấu trúc thư mục dự án

```
my-project/
├── CLAUDE.md                    # Cấu hình chính — định nghĩa tech stack
├── src/                         # Source code ứng dụng
├── tests/                       # Test suites
├── docs/                        # Tài liệu kỹ thuật, ADRs
├── design/                      # PRDs, wireframes, research
├── infra/                       # Infrastructure as code
├── scripts/                     # Build & utility scripts
└── production/                  # Sprint plans, milestones, release tracking
```

---

## 4. Các thành phần chính

### 4.1 CLAUDE.md — File cấu hình chủ

File quan trọng nhất. Định nghĩa:

- **Tech Stack** — Language, Framework, Database của dự án
- **Project Name & Description**
- **Status Line** — phase hiện tại của dự án
- **Team structure** — ai làm gì

Khi bắt đầu project mới, chạy `/start` để hệ thống giúp bạn điền file này.

### 4.2 Agents

26 AI agents được tổ chức theo 3 tầng:

```
Tier 1 — Leadership (model: Opus — thông minh nhất)
  cto • technical-director • producer

Tier 2 — Department Leads (model: Sonnet)
  product-manager • lead-programmer • ux-designer
  qa-lead • release-manager

Tier 3 — Specialists (model: Sonnet / Haiku)
  frontend-developer • backend-developer • fullstack-developer
  ai-programmer • network-programmer • tools-programmer
  ui-programmer • data-engineer • analytics-engineer
  ux-researcher • tech-writer • prototyper
  performance-analyst • devops-engineer • security-engineer
  qa-tester • accessibility-specialist • community-manager
```

### 4.3 Skills (Slash Commands)

33 workflows được đóng gói thành slash commands. Gõ `/` trong Claude Code để xem danh sách.

### 4.4 Rules

11 coding standards tự động áp dụng theo đường dẫn file. Không cần nhớ — hệ thống tự enforce.

### 4.5 Hooks

8 scripts chạy tự động tại các điểm quan trọng (commit, push, session start, v.v.).

---

## 5. Bắt đầu sử dụng

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

## 6. Slash Commands (Skills)

### Khởi đầu & Phân tích

| Command | Mô tả |
|---|---|
| `/start` | Onboarding — xác định bạn đang ở đâu và định hướng tiếp theo |
| `/project-stage-detect` | Phân tích project hiện tại, xác định phase |
| `/gate-check` | Kiểm tra readiness để chuyển sang phase tiếp theo |

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
| `/api-design` | Thiết kế REST/GraphQL API |
| `/db-review` | Review database schema & queries |
| `/perf-profile` | Phân tích performance bottlenecks |
| `/tech-debt` | Đánh giá và lên kế hoạch xử lý technical debt |

### Sprint & Release

| Command | Mô tả |
|---|---|
| `/sprint-plan` | Lên kế hoạch sprint với tasks, estimates, dependencies |
| `/milestone-review` | Đánh giá tiến độ milestone |
| `/estimate` | Ước lượng effort cho features |
| `/retrospective` | Retrospective sau sprint |
| `/release-checklist` | Checklist release đầy đủ |
| `/changelog` | Tạo changelog từ commits |

### Team Orchestration

Những commands mạnh nhất — tự động phối hợp nhiều agents:

| Command | Mô tả |
|---|---|
| `/team-feature` | Toàn bộ team làm một feature từ đầu đến cuối |
| `/team-backend` | Backend team thiết kế và implement API |
| `/team-frontend` | Frontend team implement UI |
| `/team-ui` | UI team: UX design → implement → review |
| `/team-release` | Release team: build → test → deploy |

---

## 7. Agents — Đội ngũ AI

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

## 8. Rules — Coding Standards

Rules tự động enforce theo **đường dẫn file**. Không cần nhớ, không cần cấu hình thêm.

| Path | Standards Áp dụng |
|---|---|
| `src/api/**` | REST/GraphQL conventions, authentication, error format chuẩn |
| `src/frontend/**` | Accessibility (WCAG), design tokens, i18n, state management |
| `src/ui/**` | No business logic in UI, localization-ready, keyboard accessible |
| `src/ai/**` | Performance budgets, model params phải configurable, explainability |
| `config/**` | Schema validation, no hardcoded secrets, version when breaking change |
| `design/docs/**` | PRD sections bắt buộc, acceptance criteria rõ ràng |
| `tests/**` | Test naming conventions, coverage requirements, no flaky patterns |
| `prototypes/**` | Relaxed standards, README bắt buộc, hypothesis phải document |

---

## 9. Hooks — Automated Checks

Scripts chạy tự động, không cần nhớ:

| Hook | Khi nào | Tác dụng |
|---|---|---|
| `pre-commit-code-quality` | Mỗi `git commit` | Lint, hardcoded values, TODO format |
| `pre-push-test-gate` | Mỗi `git push` | Chạy test suite, block push nếu fail |
| `post-merge-asset-validation` | Sau merge | Validate assets, naming conventions |
| `session-start-context-loader` | Mở Claude Code | Load project context tự động |
| `post-tool-agent-coordination-audit` | Sau mỗi tool call | Đảm bảo agents không vượt domain |

---

## 10. Luồng làm việc thực tế

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

## 11. Nguyên tắc cốt lõi

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

## 12. Tùy chỉnh template

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
