# Report: Upgrade Skills & Agents — 30/03/2026

## 1. Rà soát Skills Mới

Phát hiện **8 skills mới** (untracked) trong `.claude/skills/`, tất cả được thêm ngày 2026-02-27:

| Skill | Source | Nhận xét |
|---|---|---|
| `architecture-decision-records` | community | Framework đầy đủ cho ADR lifecycle |
| `code-review-checklist` | community | Checklist có cấu trúc 6 bước cho PR review |
| `commit` | — | Conventional commit format (có Sentry refs cần làm sạch) |
| `deployment-procedures` | community | Nguyên tắc deployment an toàn, dạy tư duy |
| `postmortem-writing` | community | Blameless postmortem sau incident |
| `pr-writer` | — | Tạo PR theo format chuẩn (có Sentry refs cần làm sạch) |
| `security-audit` | personal | Workflow bundle kiểm tra bảo mật toàn diện |
| `tdd-workflow` | community | RED-GREEN-REFACTOR cycle (trùng marketplace) |

---

## 2. Các Thay Đổi Đã Thực Hiện

### 2.1 Xóa Duplicate

- **Xóa** `.claude/skills/tdd-workflow/SKILL.md` — nội dung 100% giống với marketplace plugin `antigravity-awesome-skills`, không có giá trị bổ sung.

### 2.2 Làm Sạch `commit/SKILL.md`

Loại bỏ các Sentry-specific references:

| Trước | Sau |
|---|---|
| "Creates commits following Sentry conventions" | "Creates commits with proper conventional commit format" |
| Dependency `create-branch` skill (không tồn tại) | Xóa dependency |
| `Fixes SENTRY-1234`, `Fixes SENTRY-5678`, `Fixes SENTRY-9999` | `Fixes #1234`, `Fixes #5678`, `Fixes #9999` |
| Link `develop.sentry.dev/...` | Link `conventionalcommits.org` |

### 2.3 Làm Sạch `pr-writer/SKILL.md`

Loại bỏ các Sentry-specific references:

| Trước | Sau |
|---|---|
| "Follows Sentry conventions for PR titles" | "Follows conventional commit format for PR titles" |
| "Create pull requests following Sentry's engineering practices" | "Create pull requests following conventional engineering practices" |
| `sentry-skills:commit` skill reference | `commit` skill reference |
| `Refs SENTRY-1234`, `Fixes SENTRY-5678`, v.v. | `Refs #1234`, `Fixes #5678`, v.v. |
| `Fixes SENTRY-1234` trong issue ref table | `Fixes #1234` |
| Links `develop.sentry.dev/...` (×2) | Link `conventionalcommits.org` + GitHub CLI docs |

---

## 3. Update Agents

**16 agents** được cập nhật với skills mới. Phân loại theo nhóm:

### Workflow Skills (tất cả coding agents)
`commit`, `pr-writer` → backend, frontend, fullstack, mobile, lead, ui, tools

### Code Quality
`code-review-checklist` → backend, frontend, fullstack, mobile, data, lead, qa-lead

### Architecture
`architecture-decision-records` → technical-director, cto, lead-programmer

### Security
`security-audit`, `backend-security-coder`, `frontend-security-coder` → security-engineer

### Deployment & Operations
`deployment-procedures` → devops-engineer, release-manager
`postmortem-writing` → devops-engineer, producer

### Tech-Specific Skills (từ marketplace plugins)

| Agent | Skills thêm |
|---|---|
| `backend-developer` | backend-architect, microservices-patterns, nodejs-backend-patterns, nestjs-expert, fastapi-pro, django-patterns, springboot-patterns, docker-patterns, postgres-patterns, sql-optimization-patterns, backend-security-coder, aws-serverless |
| `frontend-developer` | senior-frontend, react-nextjs-development, nextjs-app-router-patterns, nextjs-best-practices, angular-best-practices, tailwind-patterns, shadcn, radix-ui-design-system, frontend-design, frontend-security-coder, frontend-ui-dark-ts |
| `fullstack-developer` | react-nextjs-development, nextjs-app-router-patterns, nextjs-best-practices, prisma-expert, drizzle-orm-expert |
| `mobile-developer` | flutter-expert, ios-developer, react-native-architecture, compose-multiplatform-patterns |
| `data-engineer` | database-architect, postgres-patterns, nosql-expert, sql-optimization-patterns, vector-database-engineer, drizzle-orm-expert, prisma-expert, event-sourcing-architect |
| `devops-engineer` | docker-patterns, kubernetes-architect, gitlab-ci-patterns, aws-serverless, hybrid-cloud-architect, cloud-architect, deployment-engineer, devops-deploy |
| `technical-director` | microservices-patterns, event-sourcing-architect, cloud-architect, hybrid-cloud-architect |
| `cto` | cloud-architect, hybrid-cloud-architect |
| `ai-programmer` | ml-engineer, mlops-engineer, rag-engineer, llm-app-patterns, llm-application-dev-ai-assistant, gemini-api-integration, vector-database-engineer |
| `ui-programmer` | radix-ui-design-system, shadcn, tailwind-patterns, frontend-ui-dark-ts |

---

## 4. Tổng Kết

| Hạng mục | Số lượng |
|---|---|
| Skills mới rà soát | 8 |
| Skills bị xóa (duplicate) | 1 |
| Skills được làm sạch | 2 |
| Agents được update | 16 |
| Agents không thay đổi | 11 |

**Skills không thay đổi** (đã đầy đủ hoặc không có skills phù hợp): `accessibility-specialist`, `analytics-engineer`, `community-manager`, `network-programmer`, `performance-analyst`, `product-manager`, `prototyper`, `qa-tester`, `tech-writer`, `ux-designer`, `ux-researcher`.
