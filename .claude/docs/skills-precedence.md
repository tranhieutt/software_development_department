# Skills vs Commands — Precedence Rule

> **Áp dụng từ:** SDD v1.32.1 (2026-04-17)
> **Vấn đề giải quyết:** Implicit workflow commands trong `CLAUDE.md` (`/plan`, `/spec`, `/tdd`, `/diagnose`, `/vertical-slice`, `/ui-spec`, `/context`) trùng tên với skills cùng tên trong `.claude/skills/`. Trước đây không có rule nào quy định khi nào invoke command vs skill → LLM có thể bỏ qua cả hai hoặc invoke cả hai (duplicate work).

## Nguyên tắc phân biệt

| Dimension | **Workflow Commands** | **Skills** |
|---|---|---|
| **Vai trò** | Workflow **gate** — đánh dấu giai đoạn | Domain **expertise** — cung cấp kiến thức |
| **Trả lời câu hỏi** | "Đến giai đoạn nào của task?" | "Cần kiến thức gì để làm task?" |
| **Ví dụ** | `/plan`, `/spec`, `/tdd`, `/diagnose` | `/backend-patterns`, `/shadcn`, `/postgres-patterns` |
| **Scope** | Task-level (toàn bộ task) | Content-level (từng step trong task) |
| **Invocation** | User gọi hoặc LLM trigger theo context | LLM auto-invoke khi khớp trigger |
| **Số lần/task** | 1-2 lần (1 gate tại 1 stage) | Nhiều lần (mỗi step có thể dùng skill khác) |

## Precedence rule (thứ tự áp dụng)

**Quy tắc vàng:** **Commands CHỨA Skills, không thay thế.**

```
Task arrives
  ↓
1. Workflow Command (nếu có) → xác định STAGE
     ↓
2. Within stage, skills được invoke → cung cấp CONTENT
     ↓
3. Skills return guidance → Command tiếp tục gate next stage
```

### Ví dụ cụ thể

**Task:** "Thêm API endpoint POST /users với validation"

```
/plan                           ← Command: xác định đây là planning stage
  ↓ LLM output atomic task list
/spec                           ← Command: next stage là spec
  ↓ invoke skill api-design             ← Skill: domain kiến thức API
  ↓ invoke skill backend-patterns       ← Skill: domain kiến thức Express/Node
  ↓ output approved blueprint
/tdd                            ← Command: next stage là TDD
  ↓ invoke skill test-driven-development ← Skill: TDD protocol
  ↓ invoke skill backend-patterns       ← Skill: impl patterns
  ↓ RED → GREEN
```

**Sai pattern:**
```
/plan AND /planning-and-task-breakdown (invoke cùng lúc) ← DUPLICATE
```

**Đúng pattern:**
```
/plan → LLM tự biết cần trigger skill `planning-and-task-breakdown` (skill là implementation của command)
```

## Khi command và skill trùng tên

Trường hợp: `/plan` trong CLAUDE.md ↔ skill `planning-and-task-breakdown`

- **Command là alias** — trigger skill backing có cùng ý nghĩa.
- **Nếu cả 2 cùng tồn tại** → command thắng (user intent rõ hơn); skill được invoke bên trong command flow.

| Command trong CLAUDE.md | Skill backing | Relationship |
|---|---|---|
| `/plan` | `planning-and-task-breakdown` | Command ⊃ Skill |
| `/spec` | `spec-driven-development` | Command ⊃ Skill |
| `/tdd` | `test-driven-development` | Command ⊃ Skill |
| `/context`, `/memory` | `context-engineering` | Command ⊃ Skill |
| `/diagnose` | `diagnose` | Command ⊃ Skill |
| `/vertical-slice` | `vertical-slicing` | Command ⊃ Skill |
| `/ui-spec` | `ui-spec` | Command ⊃ Skill |

## Skill boundary — tránh overlap nội dung

Khi 2 skill có scope chồng lấn, **description phải loại trừ nhau rõ ràng**:

| Skill | Scope ĐÚNG | Scope SAI |
|---|---|---|
| `frontend-patterns` | React/Vue generic, hooks, TanStack Query | Next.js App Router |
| `senior-frontend` | Next.js 13+ App Router, Server Components | Generic React/Vue |
| `backend-patterns` | Node.js Express/Fastify production | FastAPI (→ `fastapi-pro`) |
| `backend-architect` | System architecture (multi-service) | Single-service patterns |

**Checklist khi tạo skill mới:**
- [ ] Description có từ "NOT" hoặc "Use X instead" loại trừ scope khác?
- [ ] Tên skill có prefix rõ domain (nextjs-*, postgres-*, etc.)?
- [ ] Đã grep repo xem có skill tương tự chưa?
- [ ] Trigger pattern (`paths:`) có overlap với skill khác không?

## Audit & Telemetry (future work)

- Hook `log-agent.sh` cần log skill invocations → file `production/session-logs/skill-usage.jsonl`.
- Chạy `node scripts/harness-audit.js skills --unused 30d` định kỳ → flag skill không được invoke trong 30 ngày.
- Dựa trên telemetry: merge hoặc delete skill unused.

## Lịch sử

| Ngày | Thay đổi |
|---|---|
| 2026-04-17 | Tạo doc; xóa `nodejs-backend-patterns` (duplicate của `backend-patterns`); clarify boundary giữa `frontend-patterns` ↔ `senior-frontend` |
