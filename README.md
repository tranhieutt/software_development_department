<p align="center">
  <h1 align="center">Claude Code Software Development Department</h1>
  <p align="center">
    Bộ harness đa tác tử có quản trị cho Claude Code.
    <br /><br />
    28 agents - 116 context-optimized skills - 26 hook files - 15 rules
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-28-blueviolet" alt="28 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-116-green" alt="116 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-26-orange" alt="26 Hook Files"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-15-red" alt="15 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
</p>

---

## Đây Là Gì

Software Development Department (SDD) biến một workspace Claude Code thành một tổ chức kỹ thuật nhỏ: agents sở hữu domain, skills điều hướng công việc qua workflow lặp lại được, hooks thực thi cổng kiểm soát, memory lưu ngữ cảnh vận hành xuyên phiên.

SDD native cho Claude. Hỗ trợ Codex là lớp adapter qua `AGENTS.md`, `.codex/`, và `docs/codex-compatibility.md`; lớp này không thay đổi hành vi runtime của Claude.

## Vì Sao Tồn Tại

Lập trình với một agent thường bỏ qua quy trình: spec mơ hồ, edit quá rộng, xác minh yếu, quyết định bị quên. SDD thêm cấu trúc control-plane quanh Claude Code để công việc triển khai có routing rõ, ownership giới hạn, approval gates, và bằng chứng mới trước khi tuyên bố hoàn tất.

## Năng Lực Kỹ Thuật Nổi Bật

| Năng lực | Triển khai |
|---|---|
| Structured Agent Definitions | 28 agents với role, model, ownership, escalation path, và tool scope |
| Skill Routing | 128 skills với `when_to_use`, `allowed-tools`, effort hints, và workflow gates |
| Lifecycle map | `DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP` cho mọi việc không tầm thường |
| Verification gates | Pre-code gate, TDD workflow, review gates, completion evidence, và Codex preflight |
| Rules theo phạm vi đường dẫn | 15 rules áp theo vùng file: API, UI, DB, AI, config, tests, docs, và source code |
| Runtime hooks | 28 hook files cho bash guard, trace logging, skill telemetry, circuit state, và validation |
| Durable memory | Memory phân tầng từ index `MEMORY.md` tới topic files, archive, và semantic recall tùy chọn |
| Circuit breaker | Trạng thái lỗi theo từng agent với fallback routing và transition có audit |
| Fork-join execution | Git worktree workflow cho các workstream song song, độc lập, review được |
| Agent-style review | Gói skill `agent-style` portable cho technical prose review opt-in |

## Khởi Động Nhanh

### Product Repo Sẵn Có

Clone SDD một lần, rồi cài harness vào thư mục product:

```powershell
git clone https://github.com/tranhieutt/software_development_department [Your folder clone's path]
cd [Your folder clone's path]
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-sdd.ps1 [Your folder project's path]
```

Đường dẫn mặc định này dùng Product mode và chạy preflight sau khi cài. Product mode giữ nguyên file product hiện có: `README.md`, `PRD.md`, `TODO.md`, và `.gitignore`.

Mở thư mục product sau khi cài:

```powershell
cd [Your folder project's path]
```

Với Claude Code, đọc `CLAUDE.md` và chạy `/start`.

Với Codex, đọc `AGENTS.md` và `.codex/START.md`, hoặc paste:

```text
Use codex-sdd, then route through using-sdd, then run the start workflow for this repo.
```

## Điều Kiện Cần

- Claude Code: `npm install -g @anthropic-ai/claude-code`
- Git
- Git Bash 2.40+ hoặc WSL2 trên Windows để hook tương thích với shell
- Khuyến nghị có `jq` và Python 3 cho validation và audit scripts

## Codex Adapter

Với Codex, mở repository này và dùng `.codex/START.md` như bản tương đương `/start`. Codex phải tự tuân thủ SDD gates vì Claude Code hooks không tự chạy trong Codex.

Kiểm tra khuyến nghị trước công việc Codex rủi ro:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1
```

### Department Hierarchy

```
Tier 1; Executive
  cto                 technical-director    producer

Tier 2; Leads
  product-manager     lead-programmer       ux-designer
  qa-engineer         release-manager

Tier 3; Specialists
  frontend-developer  backend-developer     fullstack-developer
  mobile-developer    ai-programmer         network-programmer
  tools-programmer    ui-programmer         data-engineer
  analytics-engineer  ux-researcher         tech-writer
  prototyper          performance-analyst   devops-engineer
  security-engineer   diagnostics           accessibility-specialist
  community-manager   ui-spec-designer
```

## Mô Hình Vận Hành

1. Route request qua `using-sdd`.
2. Chọn skill điều phối: spec, plan, TDD, review, release, hoặc specialist workflow.
3. Nêu pre-code gate trước khi edit production.
4. Giữ thay đổi đúng phạm vi task đã duyệt.
5. Xác minh bằng lệnh hoặc inspection mới trước khi báo hoàn tất.
6. Giữ Claude làm source of truth; giữ Codex làm adapter.

Entry points thường dùng:

| Tình huống | Command |
|---|---|
| Bắt đầu phiên | `/start` |
| Khám phá ý tưởng | `/brainstorm` |
| Viết spec | `/spec` |
| Chia nhỏ kế hoạch | `/plan` |
| Triển khai task đã duyệt | `/tdd` |
| Điều phối agents | `/orchestrate` |
| Review code | `/code-review` |
| Review văn phong | `/style-review` |
| Chuẩn bị release | `/release-checklist` |

Gõ `/` trong Claude Code để xem workflow liên quan; SDD cung cấp 128 workflows nhưng kỳ vọng agents chỉ load skill cần cho task hiện tại.

## Bao Gồm

| Danh mục | Số lượng | Mục đích |
|---|---:|---|
| **Agents** | 28 | Domain ownership và escalation |
| **Skills** | 128 | Workflow routing và specialist procedures |
| **Hooks** | 28 | Guardrails, telemetry, validation, và lifecycle checks |
| **Rules** | 15 | Standards theo phạm vi đường dẫn |
| **Templates** | 22+ | Specs, ADRs, plans, reports, và release artifacts |

## Cấu Trúc Dự Án

```text
CLAUDE.md                           # Hiến pháp Claude-native
AGENTS.md                           # Hướng dẫn adapter cho Codex
.codex/                             # Adapter prompts và checklists cho Codex
.claude/
  settings.json                     # Permissions và hook registration
  agents/                           # 28 agent definitions
  skills/                           # 128 skills
  hooks/                            # 28 hook scripts
  rules/                            # 15 path-scoped rules
  memory/                           # Durable memory system
docs/                               # Technical docs, ADRs, compatibility notes
scripts/                            # Validators, reports, utility scripts
production/traces/                  # Decision, skill, agent telemetry
```

## Validation

```powershell
powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1
powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1
node scripts\harness-audit.js --compact
node scripts\validate-readme-sync.js
```

## License

MIT. Xem [LICENSE](LICENSE).

Dựa trên [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) của Donchitos; được điều chỉnh cho tổ chức kỹ thuật phần mềm.
