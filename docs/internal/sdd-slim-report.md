# SDD Slim Report — Tiến độ tinh gọn hệ thống

> **Ngày cập nhật:** 2026-05-15
> **Base audit:** báo cáo slim ban đầu cùng ngày
> **Repo state:** `main` đã sync `origin/main` tại `8c863b5`
> **Mục đích:** Theo dõi phần đã lược bớt, phần đã merge, phần còn lại nên xử lý.
> **Lưu ý:** File này là báo cáo trạng thái, không phải lệnh thực thi.

---

## Tóm tắt mới nhất

| Chỉ số | Trước audit | Hiện tại | Thay đổi | Target |
|---|---:|---:|---:|---:|
| Tổng skills | 128 | 116 | -12 | ≤ 90 trước mắt / ~51 dài hạn |
| Hook files | 28 | 26 | -2 | 25 nếu bỏ tiếp `file-history.sh` |
| Hook dead-path đã bỏ | 0/3 | 2/3 | +2 | 3/3 |
| Skills đã merge vào canonical target | 0 | 5 | +5 | — |
| Script phụ đã bỏ | 0 | 1 | +1 | — |
| README inventory | 128 skills / 28 hooks | 116 skills / 26 hooks | synced | synced |

**Kết luận:** Đã hoàn thành phase slim đầu tiên: giảm 12 skills, bỏ 2 dead hooks, merge 5 skills vào 3 canonical skills, xóa 1 script không thuộc hạ tầng SDD. Chưa đạt target trong report ban đầu vì `file-history.sh`, `log-skill.sh` whitelist, team skills còn lại, stack-specific skills, và duplicate skills vẫn chưa xử lý.

---

## Phần 1: Đã lược bớt

### 1A — Hooks đã xóa

| Hook | Trạng thái | Ghi chú |
|---|---|---|
| `pre-refactor-impact.sh` | Đã xóa | Warn-only, phụ thuộc GitNexus, bị `pre-code-gate.sh` bao phủ tốt hơn |
| `validate-assets.sh` | Đã xóa | Domain-specific cho `assets/`, không universal cho SDD template |

`settings.json` đã gỡ references tương ứng. Hook count hiện tại: `26`.

### 1B — Skills đã merge vào canonical targets

| Skill cũ | Target mới | Trạng thái |
|---|---|---|
| `patch-notes` | `changelog` | Đã merge patch notes style section |
| `backend-security-coder` | `security-audit` | Đã merge secure coding reference |
| `frontend-security-coder` | `security-audit` | Đã merge secure coding reference |
| `deployment-engineer` | `devops-deploy` | Đã merge pipeline design |
| `deployment-procedures` | `devops-deploy` | Đã merge runbook principles |

### 1C — Skills đã xóa

Nhóm mobile stack chưa active đã bị xóa:

- `team-mobile`
- `mobile-developer`
- `ios-developer`
- `flutter-expert`
- `compose-multiplatform-patterns`
- `react-native-architecture`
- `mobile-review`

### 1D — Script đã xóa

- `scripts/auto_resume_claude.ps1` — AFK keystroke automation, không phải SDD infrastructure.

---

## Phần 2: Chưa xong so với report ban đầu

### 2A — Dead hook còn lại

| Hook | Trạng thái | Việc còn lại |
|---|---|---|
| `file-history.sh` | Vẫn còn | Xóa file và gỡ reference trong `.claude/settings.json` |

Hiện `.claude/settings.json` vẫn có command:

```json
"command": "bash .claude/hooks/file-history.sh"
```

Lý do report ban đầu đề xuất bỏ: hook chạy trên mọi Read, nhưng tự skip phần lớn file nhỏ; giá trị thấp so với overhead.

### 2B — Telemetry skill chưa được sửa

`log-skill.sh` vẫn capture token dạng `/word` mà chưa whitelist skill tồn tại trong `.claude/skills`.

Việc còn lại:

```bash
SKILL_DIR=".claude/skills"
if [ ! -d "$SKILL_DIR/$SKILL_NAME" ]; then
    exit 0
fi
```

Sau fix, cần thu telemetry sạch ít nhất 14 ngày trước khi cull dựa trên usage.

### 2C — Team orchestration còn 5 skills

Đã xóa `team-mobile`, còn:

- `team-backend`
- `team-feature`
- `team-frontend`
- `team-release`
- `team-ui`

Đây vẫn là candidates low-risk nếu repo tiếp tục dùng solo/small-team flow.

### 2D — Stack-specific skills còn nhiều

Các skill theo stack chưa được chọn vẫn còn, ví dụ:

- `angular-best-practices`
- `springboot-patterns`
- `nestjs-expert`
- `django-patterns`
- `fastapi-pro`
- `dotnet-backend-patterns`
- `laravel-patterns`
- `nextjs-patterns`
- `drizzle-orm-expert`
- `prisma-expert`
- `postgres-patterns`
- `nosql-expert`
- `sql-optimization-patterns`
- `tailwind-patterns`
- `radix-ui-design-system`
- `shadcn`
- `aws-serverless`
- `cloud-architect`
- `hybrid-cloud-architect`
- `cloud-run-puppeteer`
- `kubernetes-architect`
- `gitlab-ci-patterns`
- `docker-patterns`
- `vector-database-engineer`
- `event-sourcing-architect`
- `microservices-patterns`

Khuyến nghị: chưa cull hàng loạt cho đến khi `/start` hoặc config stack xác nhận repo template cần giữ mức generic nào.

### 2E — Duplicate / overlap candidates còn lại

Một số overlap vẫn còn:

- `estimate` — conflict với rule no-timeline-estimation
- `milestone-review` → có thể gom vào `gate-check`
- `db-review` → có thể gom vào `code-review` + DB-specific checklist
- `design-review` → có thể gom vào `style-review` hoặc `review-spec`
- `backend-architect` / `backend-patterns`
- `frontend-patterns` / `senior-frontend`
- `database-architect`
- `devops-deploy` — đã được enrich nên không còn là delete-first candidate; cần quyết định có đưa vào router hay giữ Tier B.

---

## Phần 3: Tier phân loại sau slim phase 1

### Tier A — Backbone, giữ

Giữ nguyên các workflow route chính:

```text
using-sdd
codex-sdd
start
brainstorm
deep-interview
spec-driven-development
review-spec
source-driven-development
spec-evolution
planning-and-task-breakdown
vertical-slicing
test-driven-development
systematic-debugging
diagnose
subagent-driven-development
orchestrate
fork-join
frontend-design
ui-spec
api-design
architecture-decision-records
code-review
code-review-checklist
style-review
receiving-code-review
code-simplification
gate-check
verification-before-completion
commit
release-checklist
launch-checklist
context-engineering
learner
annotate
save-state
```

### Tier B — Giữ có điều kiện / giá trị rõ

- `trace-history`
- `changelog`
- `retrospective`
- `prototype`
- `sprint-plan`
- `dream`
- `hotfix`
- `onboard`
- `bug-report`
- `tech-debt`
- `scope-check`
- `freeze`
- `unfreeze`
- `guard`
- `pr-writer`
- `update-codemap`
- `resume-from`
- `postmortem-writing`
- `security-audit`
- `devops-deploy`

`devops-deploy` đã nhận nội dung từ `deployment-engineer` và `deployment-procedures`, nên hiện là canonical deployment skill thay vì candidate xóa trực tiếp.

### Tier C — Candidates còn lại

Tổng candidate sau phase 1 thấp hơn report ban đầu vì 12 skills đã được xử lý. Nhóm còn lại nên xử lý theo thứ tự:

1. `file-history.sh` + `settings.json` reference
2. `log-skill.sh` whitelist
3. 5 `team-*` skills còn lại
4. Duplicate / overlap skills
5. Stack-specific skills sau khi stack policy rõ

---

## Phần 4: Hành động đề xuất tiếp theo

### Phase 2 — Low-risk, nên làm ngay

- [ ] Xóa `file-history.sh`
- [ ] Gỡ `file-history.sh` khỏi `.claude/settings.json`
- [ ] Thêm whitelist vào `log-skill.sh`
- [ ] Chạy:
  - `node scripts\validate-readme-sync.js`
  - `powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1`
  - `node scripts\harness-audit.js --compact`

### Phase 3 — Sau telemetry sạch

- [ ] Cull 5 `team-*` skills còn lại nếu không có usage
- [ ] Cull / merge duplicate review and architecture skills
- [ ] Quyết định stack-specific policy: giữ template rộng hay cắt về stack thực tế

### Phase 4 — Theo điều kiện

- [ ] Bỏ `extract-decisions.sh` nếu sau 30 ngày `consensus/merged-decisions.md` vẫn rỗng
- [ ] Đơn giản hóa `persist-memory.sh` nếu marker usage vẫn không có

---

## Verification mới nhất

Đã kiểm tra sau sync `origin/main`:

```text
README sync check passed (28 agents, 116 skills, 26 hook files, 15 rules).
SDD Skill Validator: Total 116 | Pass 116 | Fail 0 | Warn 0
git rev-list main...origin/main: 0 0
```

Working tree còn untracked, không thuộc upstream sync:

- `.claude/memory/archive/dreams/`
- `.claude/memory/archive/sessions/`
- `docs/internal/sdd-slim-report.md`

---

## Kết quả kỳ vọng nếu hoàn tất Phase 2

| Chỉ số | Hiện tại | Sau Phase 2 |
|---|---:|---:|
| Skills | 116 | 116 |
| Hook files | 26 | 25 |
| Dead hooks còn lại | 1 | 0 |
| Hook calls per Read | 2 | 1 |
| Telemetry accuracy | thấp vì `/word` noise | cao hơn nhờ whitelist |

## Kết quả dài hạn nếu cull tiếp theo report

| Chỉ số | Hiện tại | Sau cull chọn lọc |
|---|---:|---:|
| Skills | 116 | ≤ 90 trước mắt |
| Skills nếu chỉ giữ Tier A + Tier B | 116 | ~51-60 |
| Hook files | 26 | 25 |

**Trạng thái:** Slim phase 1 đã merge vào `main`. Phase 2 còn nhỏ, ít rủi ro, chưa thực hiện.
