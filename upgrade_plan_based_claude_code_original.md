# Upgrade Plan: SDD dựa trên Claude Code Source Code Analysis

> Nguồn: Phân tích 512K lines source code Claude Code tại `D:\Claude Source Code Original`
> Ngày lập: 2026-04-01
> Trạng thái: Chờ thực hiện

---

## Bối cảnh

Sau khi phân tích sâu source code Claude Code (phần bị lộ qua npm source map 31/3/2026),
phát hiện ra nhiều cơ chế internal có thể tận dụng để nâng cấp bộ SDD hiện tại.

**Số liệu hiện trạng:**
- Tổng skills: **98 SKILL.md files**
- Skills có `paths:` frontmatter: **0** (gitlab-ci-patterns dùng `paths:` trong nội dung YAML CI, không phải frontmatter)
- Skills có `context: fork`: **0**
- Skills có `effort:`: **1**
- Memory files: **2** (chỉ có QuickFly project + language preference)
- Skills còn game references: **code-review** (ít nhất 1 file xác nhận)

---

## Phase 1 — Quick Wins (1–2 ngày)

### Task 1.1: Fix Game References trong `code-review` Skill

**File:** `.claude/skills/code-review/SKILL.md`

**Vấn đề:** Skill còn chứa game-specific checks không phù hợp với SDD:
- "Identify the system category (engine, gameplay, AI, networking, UI, tools)"
- "Dependencies are injected (no static singletons for **game state**)"
- "Correct dependency direction (engine ← gameplay, not reverse)"
- "Proper layer separation (UI does not own **game state**)"
- "Check for common **game development** issues"
- "Frame-rate independence (delta time usage)"
- "No allocations in hot paths (update loops)"

**Thay thế bằng:**

```markdown
3. **Identify the system category** (api, service, repository, component, utility, infrastructure)
   and apply category-specific standards.

4. **Evaluate against coding standards**:
   - [ ] Public methods and classes have doc comments
   - [ ] Cyclomatic complexity under 10 per method
   - [ ] No method exceeds 40 lines (excluding data declarations)
   - [ ] Dependencies are injected (no singletons for business state)
   - [ ] Configuration values loaded from external config
   - [ ] Systems expose interfaces (not concrete class dependencies)

5. **Check architectural compliance**:
   - [ ] Correct dependency direction (infrastructure ← domain ← application)
   - [ ] No circular dependencies between modules
   - [ ] Proper layer separation (UI does not own business logic)
   - [ ] Events/messages used for cross-service communication
   - [ ] Consistent with established patterns in the codebase

7. **Check for common web/software issues**:
   - [ ] No N+1 query patterns (use eager loading or joins)
   - [ ] Proper async/await (no unhandled promises)
   - [ ] Input validation at system boundaries
   - [ ] Proper error handling with meaningful messages
   - [ ] Resource cleanup (connections, streams, subscriptions)
   - [ ] No secrets or sensitive data hardcoded

8. **Output the review** format: (thay "Game-Specific Concerns" → "Web/Software Concerns")
```

**Effort:** 30 phút | **Impact:** Cao — correctness

---

### Task 1.2: Thêm Memory Files cơ bản

**Thư mục:** `~/.claude/projects/d--Development-Software-Department/memory/`

Tạo các memory files sau (nội dung điền dần qua các sessions thực tế):

**`feedback_skill_patterns.md`** — Patterns nào hiệu quả:
```markdown
---
name: Effective Skill Patterns
description: Skills và patterns được xác nhận hiệu quả trong SDD — dùng làm baseline
type: feedback
---
[Điền khi có trải nghiệm thực tế]
```

**`feedback_code_review_findings.md`** — Findings lặp lại trong code review:
```markdown
---
name: Recurring Code Review Issues
description: Lỗi code hay gặp lại trong các project — cần check proactively
type: feedback
---
[Điền sau 3-5 code review sessions]
```

**`project_tech_decisions.md`** — Stack decisions đã confirm:
```markdown
---
name: Technology Decisions
description: Stack và library đã được approve cho các loại project khác nhau
type: project
---
[Điền khi stack cho project cụ thể được confirm]
```

**Effort:** 15 phút tạo skeleton | **Impact:** Cao — tích lũy context qua sessions

---

## Phase 2 — Conditional Skills với `paths:` (3–5 ngày)

### Task 2.1: Phân loại 98 skills theo nhóm công nghệ

Dựa trên source code phân tích, `paths:` frontmatter dùng gitignore-style glob matching — skill chỉ visible khi user đang làm việc với file matching pattern.

**Nhóm A — Frontend/React/Next.js** (thêm paths ngay):

| Skill | paths: |
| --- | --- |
| `react-nextjs-development` | `["**/*.tsx", "**/*.jsx", "**/next.config.*"]` |
| `nextjs-app-router-patterns` | `["**/*.tsx", "**/app/**", "**/next.config.*"]` |
| `nextjs-best-practices` | `["**/*.tsx", "**/next.config.*"]` |
| `react-native-architecture` | `["**/*.tsx", "**/app.json", "**/metro.config.*"]` |
| `tailwind-patterns` | `["**/*.tsx", "**/tailwind.config.*", "**/*.css"]` |
| `radix-ui-design-system` | `["**/*.tsx", "**/package.json"]` |
| `shadcn` | `["**/*.tsx", "**/components.json"]` |
| `frontend-ui-dark-ts` | `["**/*.tsx", "**/*.css"]` |
| `angular-best-practices` | `["**/*.ts", "**/angular.json"]` |
| `senior-frontend` | `["**/*.tsx", "**/*.ts", "**/*.vue"]` |
| `frontend-design` | `["**/*.tsx", "**/*.css", "**/figma*"]` |
| `frontend-patterns` | `["**/*.tsx", "**/*.ts"]` |
| `frontend-security-coder` | `["**/*.tsx", "**/*.ts"]` |

**Nhóm B — Backend Node.js/NestJS** (thêm paths ngay):

| Skill | paths: |
| --- | --- |
| `nestjs-expert` | `["**/nest-cli.json", "**/src/**/*.ts", "**/package.json"]` |
| `nodejs-backend-patterns` | `["**/package.json", "**/*.ts", "**/src/**"]` |
| `backend-patterns` | `["**/src/**/*.ts", "**/src/**/*.js"]` |
| `backend-architect` | `["**/src/**", "**/package.json"]` |
| `prisma-expert` | `["**/prisma/**", "**/*.prisma", "**/schema.prisma"]` |
| `drizzle-orm-expert` | `["**/drizzle.config.*", "**/db/**/*.ts"]` |
| `backend-security-coder` | `["**/src/**/*.ts", "**/middlewares/**"]` |

**Nhóm C — Python** (thêm paths ngay):

| Skill | paths: |
| --- | --- |
| `fastapi-pro` | `["**/*.py", "**/requirements*.txt", "**/pyproject.toml"]` |
| `django-pro` | `["**/*.py", "**/manage.py", "**/settings.py"]` |
| `django-patterns` | `["**/*.py", "**/manage.py"]` |
| `ml-engineer` | `["**/*.py", "**/requirements*.txt", "**/*.ipynb"]` |
| `mlops-engineer` | `["**/*.py", "**/Dockerfile", "**/requirements*.txt"]` |
| `rag-engineer` | `["**/*.py", "**/requirements*.txt"]` |

**Nhóm D — Mobile** (thêm paths ngay):

| Skill | paths: |
| --- | --- |
| `flutter-expert` | `["**/*.dart", "**/pubspec.yaml"]` |
| `ios-developer` | `["**/*.swift", "**/*.xib", "**/Info.plist"]` |
| `mobile-developer` | `["**/*.dart", "**/*.swift", "**/*.kt"]` |
| `compose-multiplatform-patterns` | `["**/*.kt", "**/build.gradle*"]` |

**Nhóm E — Database** (thêm paths ngay):

| Skill | paths: |
| --- | --- |
| `sql-optimization-patterns` | `["**/*.sql", "**/migrations/**", "**/schema.*"]` |
| `postgres-patterns` | `["**/*.sql", "**/migrations/**"]` |
| `nosql-expert` | `["**/*.json", "**/collections/**"]` |
| `vector-database-engineer` | `["**/*.py", "**/*.ts", "**/embeddings/**"]` |

**Nhóm F — Infrastructure/DevOps** (thêm paths ngay):

| Skill | paths: |
| --- | --- |
| `docker-patterns` | `["**/Dockerfile*", "**/docker-compose*", "**/.dockerignore"]` |
| `kubernetes-architect` | `["**/*.yaml", "**/k8s/**", "**/helm/**"]` |
| `gitlab-ci-patterns` | `["**/.gitlab-ci.yml", "**/ci/**"]` |
| `aws-serverless` | `["**/serverless.yml", "**/template.yaml", "**/cdk/**"]` |
| `cloud-architect` | `["**/terraform/**", "**/pulumi/**", "**/infra/**"]` |
| `devops-deploy` | `["**/Dockerfile*", "**/k8s/**", "**/infra/**"]` |
| `deployment-procedures` | `["**/Dockerfile*", "**/deploy/**"]` |

**Nhóm G — .NET/Java** (thêm paths ngay):

| Skill | paths: |
| --- | --- |
| `dotnet-backend-patterns` | `["**/*.cs", "**/*.csproj", "**/appsettings*.json"]` |
| `springboot-patterns` | `["**/*.java", "**/pom.xml", "**/application*.yml"]` |
| `laravel-patterns` | `["**/*.php", "**/artisan", "**/composer.json"]` |

**Nhóm H — AI/LLM** (thêm paths ngay):

| Skill | paths: |
| --- | --- |
| `llm-app-patterns` | `["**/*.py", "**/*.ts", "**/openai*", "**/anthropic*"]` |
| `llm-application-dev-ai-assistant` | `["**/*.py", "**/*.ts"]` |
| `claude-api` | `["**/*.ts", "**/*.py", "**/anthropic*"]` |
| `gemini-api-integration` | `["**/*.ts", "**/*.py", "**/google*"]` |

**Skills KHÔNG thêm `paths:` (luôn visible — workflow skills):**
- `code-review`, `design-review`, `db-review`, `mobile-review`
- `bug-report`, `hotfix`, `postmortem-writing`
- `sprint-plan`, `estimate`, `scope-check`, `milestone-review`
- `commit`, `pr-writer`, `changelog`, `patch-notes`
- `security-audit`, `architecture-decision-records`, `architecture-decision`
- `launch-checklist`, `release-checklist`, `gate-check`
- `retrospective`, `onboard`, `brainstorm`, `start`
- `save-state`, `update-codemap`, `orchestrate`, `sync-template`

**Effort:** 2–3 ngày (batch edit) | **Impact:** Rất cao — 60+ skills filter tự động

---

### Task 2.2: Cách thực hiện batch edit

Thực hiện theo nhóm, mỗi nhóm update cùng lúc. Thêm vào frontmatter của mỗi SKILL.md:

```markdown
---
name: nestjs-expert
description: "..."
# ... existing fields ...
paths: ["**/nest-cli.json", "**/src/**/*.ts", "**/package.json"]   ← THÊM DÒNG NÀY
---
```

Kiểm tra sau khi thêm: Mở một file `.prisma` → gõ `/` → chỉ thấy `prisma-expert`, không thấy `nestjs-expert`, `flutter-expert`...

---

## Phase 3 — Fork Context cho Heavy Skills (1 ngày)

### Task 3.1: Thêm `context: fork` vào analysis skills nặng

Theo source code: `context: fork` tạo sub-agent với isolated context, chạy độc lập, trả kết quả về parent mà không làm bẩn conversation history.

**Files cần update:**

```markdown
# security-audit/SKILL.md
---
context: fork
agent: security-engineer
effort: 5
---
```

```markdown
# architecture-decision-records/SKILL.md
---
context: fork
agent: technical-director
effort: 4
---
```

```markdown
# architecture-decision/SKILL.md
---
context: fork
agent: cto
effort: 4
---
```

```markdown
# perf-profile/SKILL.md
---
context: fork
agent: performance-analyst
effort: 3
---
```

```markdown
# tech-debt/SKILL.md
---
context: fork
agent: lead-programmer
effort: 3
---
```

```markdown
# map-systems/SKILL.md
---
context: fork
agent: technical-director
effort: 3
---
```

**Effort:** 2 giờ | **Impact:** Trung bình — conversation history sạch hơn

---

## Phase 4 — Thêm `effort:` cho tất cả skills (1 ngày)

### Task 4.1: Effort scale

```
1 = < 30 giây  (lookup, snippet, quick check)
2 = 1–2 phút   (standard task)
3 = 5–10 phút  (moderate analysis)
4 = 15–30 phút (complex design/review)
5 = 30+ phút   (full audit/architecture)
```

**Skills effort = 1** (quick):
`commit`, `changelog`, `patch-notes`, `bug-report`, `estimate`, `localize`

**Skills effort = 2** (standard):
`code-review`, `design-review`, `db-review`, `pr-writer`, `hotfix`,
`frontend-patterns`, `backend-patterns`, `docker-patterns`, `postgres-patterns`

**Skills effort = 3** (moderate):
`sprint-plan`, `scope-check`, `gate-check`, `release-checklist`, `launch-checklist`,
`retrospective`, `tech-debt`, `perf-profile`, `security-audit` (quick scan),
`nestjs-expert`, `fastapi-pro`, `prisma-expert`, `drizzle-orm-expert`

**Skills effort = 4** (complex):
`architecture-decision`, `microservices-patterns`, `event-sourcing-architect`,
`kubernetes-architect`, `hybrid-cloud-architect`, `mlops-engineer`,
`react-native-architecture`, `mobile-developer`

**Skills effort = 5** (heavy):
`architecture-decision-records`, `security-audit` (full), `map-systems`,
`cloud-architect`, `database-architect`, `backend-architect`

**Effort:** 1 ngày | **Impact:** Trung bình — model tự chọn thinking mode phù hợp

---

## Phase 5 — CLAUDE.md Optimization (2–3 ngày)

### Task 5.1: Tách coding-standards.md thành domain files

**Vấn đề:** Hiện tại `@.claude/docs/coding-standards.md` inject tất cả rules vào mọi API call — cả frontend rules khi đang làm backend, cả database rules khi đang viết UI.

**Kế hoạch tổ chức:**

```
.claude/docs/coding-standards.md   ← Chỉ giữ UNIVERSAL rules
                                      (naming conventions, commit format,
                                       doc comments, secret management)

.claude/rules/
├── api-code.md          ← Đã có — REST/GraphQL standards
├── database-code.md     ← Đã có — Schema, migration, query standards
├── frontend-code.md     ← Đã có — Component, state, accessibility
├── secrets-config.md    ← Đã có — Secret management
└── [thêm mới nếu cần]
```

**CLAUDE.md project chỉ @include universal standards:**
```markdown
@.claude/docs/coding-standards.md   ← universal only, ~200 tokens
```

Domain rules (api, database, frontend) chỉ được inject khi skill liên quan chạy — thông qua skill content tự reference hoặc Claude đọc khi context đòi hỏi.

**Effort:** 2–3 ngày (careful refactor) | **Impact:** Trung bình — tiết kiệm token

---

### Task 5.2: Thêm `when_to_use:` cho workflow skills

Skills hay bị nhầm nhau (code-review vs code-review-checklist, architecture-decision vs architecture-decision-records):

```markdown
# code-review/SKILL.md
---
when_to_use: "Khi cần full architectural + quality review trước khi merge PR"
---

# code-review-checklist/SKILL.md
---
when_to_use: "Quick self-check trước khi commit, không cần full review"
---

# architecture-decision/SKILL.md
---
when_to_use: "Khi cần ra quyết định công nghệ, ghi lại reasoning"
---

# architecture-decision-records/SKILL.md
---
when_to_use: "Khi cần tạo formal ADR document với full context và alternatives"
---
```

**Effort:** 1 ngày | **Impact:** Thấp-Trung — model invoke đúng skill hơn

---

## Checklist Tổng thể

### Phase 1 — Quick Wins
- [x] **1.1** Fix game references trong `code-review/SKILL.md` ✓ 2026-04-01
- [x] **1.2** Tạo 3 memory file skeletons trong `~/.claude/projects/.../memory/` ✓ 2026-04-01

### Phase 2 — Conditional Skills
- [x] **2.1a** Thêm `paths:` cho Nhóm A — Frontend/React (13 skills) ✓ 2026-04-01
- [x] **2.1b** Thêm `paths:` cho Nhóm B — Backend Node.js (7 skills) ✓ 2026-04-01
- [x] **2.1c** Thêm `paths:` cho Nhóm C — Python (6 skills) ✓ 2026-04-01
- [x] **2.1d** Thêm `paths:` cho Nhóm D — Mobile (4 skills) ✓ 2026-04-01
- [x] **2.1e** Thêm `paths:` cho Nhóm E — Database (4 skills) ✓ 2026-04-01
- [x] **2.1f** Thêm `paths:` cho Nhóm F — Infrastructure (7 skills) ✓ 2026-04-01
- [x] **2.1g** Thêm `paths:` cho Nhóm G — .NET/Java/PHP (3 skills) ✓ 2026-04-01
- [x] **2.1h** Thêm `paths:` cho Nhóm H — AI/LLM (4 skills) ✓ 2026-04-01

### Phase 3 — Fork Context
- [ ] **3.1** Thêm `context: fork` + `agent:` cho 6 heavy analysis skills

### Phase 4 — Effort Hints
- [ ] **4.1** Thêm `effort:` (1–5) cho tất cả 98 skills

### Phase 5 — CLAUDE.md Optimization
- [ ] **5.1** Tách coding-standards.md → universal only
- [ ] **5.2** Thêm `when_to_use:` cho 10–15 workflow skills hay nhầm

---

## Ước tính Tổng thời gian

| Phase | Task | Effort |
| --- | --- | --- |
| 1 | Quick wins | 1–2 giờ |
| 2 | paths: cho 48 skills | 2–3 ngày |
| 3 | context: fork | 2 giờ |
| 4 | effort: hints | 1 ngày |
| 5 | CLAUDE.md optimization | 2–3 ngày |
| **Tổng** | | **~7–10 ngày** |

---

## ROI kỳ vọng

| Upgrade | Kết quả đo được |
| --- | --- |
| `paths:` filtering | Từ 98 → ~15 skills visible tại một thời điểm |
| `context: fork` | Conversation history sạch hơn sau analysis tasks |
| Fix code-review | Không còn game-specific false positives trong review |
| Memory files | Context tích lũy qua các sessions, không setup lại |
| `effort:` hints | Model dùng thinking mode đúng chỗ hơn |

---

## Nguồn tham khảo

Upgrade plan này dựa trực tiếp trên phân tích source code tại:

- `D:\Claude Source Code Original\reports\REPORT-skills-plugin-system.md` — `paths:`, `context: fork`, `effort:` mechanics
- `D:\Claude Source Code Original\reports\REPORT-context-building.md` — CLAUDE.md hierarchy, `@include`, token optimization
- `D:\Claude Source Code Original\reports\REPORT-memory-system.md` — Memory file ROI, description quality
- `D:\Claude Source Code Original\reports\REPORT-lessons-learned.md` — Tổng hợp bài học thực tiễn
