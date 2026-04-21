<p align="center">
  <h1 align="center">Claude Code Software Development Department</h1>
  <p align="center">
    Hệ thống agentic có cấu trúc — biến một session Claude Code đơn lẻ<br />
    thành một software engineering organization thực sự.
    <br /><br />
    31 agents · 116 context-optimized skills · 10/12 agentic harness patterns · MAS Infrastructure · Steel Discipline · Runtime-proven harness
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-31-blueviolet" alt="31 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-116-green" alt="116 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-20-orange" alt="20 Hooks"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-13-red" alt="13 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
</p>

---

## Yêu cầu hệ thống (Platform Parity)

- **Claude Code**: `npm install -g @anthropic-ai/claude-code`
- **Git**: Bắt buộc để quản lý phiên bản và chạy hooks.
- **Người dùng Windows**: Yêu cầu **Git Bash 2.40+** HOẶC **WSL2**. CMD/PowerShell có thể dùng cho hầu hết các lệnh, nhưng các automated validation hooks yêu cầu môi trường POSIX-compliant shell để hoạt động chính xác.
- **jq** (khuyến nghị): Được dùng bởi các validation hooks để parse JSON.
- **Python 3** (khuyến nghị): Được dùng bởi các script đánh giá skill và audit.


## Vấn đề

Một AI session không có structure hoạt động như kỹ sư trẻ không có oversight: nó ship được, nhưng bỏ qua design doc, bỏ qua edge cases, tích lũy technical debt âm thầm, và không có ai phản biện khi scope phình ra.

Điểm nghẽn không nằm ở năng lực model — mà ở **organizational entropy**. Một session AI đơn lẻ không có domain boundaries, không có escalation path, không có memory liên tục. Nó trả lời mọi câu hỏi nhưng không sở hữu gì cả.

**Claude Code Software Development Department** là giải pháp kiến trúc cho vấn đề đó.

---

## Hệ thống này là gì

SDD là một **governed multi-agent harness** xây dựng trực tiếp trên các agentic primitives của Claude Code. Không phải wrapper. Không phải prompt library. Đây là một cấu trúc tổ chức áp đặt các coordination patterns của một engineering department thực sự lên trên Claude Code session.

Kết quả:

- **Authority được scoped**: Agents sở hữu domain và không vượt ranh giới nếu không có explicit delegation
- **Process được enforced**: Spec trước implementation, plan trước code, tests trước merge — thực thi qua hooks và verification gates, không phải lời khuyên
- **Memory tồn tại liên tục**: 5-layer durable memory architecture (Tier 1 index → Tier 2 topic files → Tier 3 cold archive → MCP Supermemory semantic store) sống qua từng session
- **Context được dùng chính xác**: Incremental loading với 3-Question Relevance Gate ngăn chặn context stuffing; tối đa 3 Tier 2 files mỗi session
- **Routing chính xác**: 117 skills với `paths:` triggers, `when_to_use:` semantics, và `effort:` scores cho phép AI tự route mà không cần người dùng điều hướng thủ công

---

## Kiến trúc

### Department Hierarchy

Ba tầng. Escalation path rõ ràng. Không có authority mơ hồ.

```
Tier 1 — Executive (Opus)
  cto                 technical-director    producer

Tier 2 — Leads (Sonnet)
  product-manager     lead-programmer       ux-designer
  qa-lead             release-manager

Tier 3 — Specialists (Sonnet / Haiku)
  frontend-developer  backend-developer     fullstack-developer
  mobile-developer    ai-programmer         network-programmer
  tools-programmer    ui-programmer         data-engineer
  analytics-engineer  ux-researcher         tech-writer
  prototyper          performance-analyst   devops-engineer
  security-engineer   qa-tester             accessibility-specialist
  community-manager
```

### Coordination Model

| Pattern | Hành vi |
|---|---|
| Vertical delegation | CTO → leads → specialists. Quyết định đi xuống; blocker escalate lên. |
| Horizontal consultation | Cùng tầng có thể tư vấn nhau nhưng không được ra quyết định binding ngoài domain. |
| Conflict resolution | Conflict kỹ thuật → `technical-director`. Conflict chiến lược → `cto`. |
| Cross-department changes | Chỉ được điều phối qua `producer`. |
| Domain isolation | Agent không được sửa file ngoài domain của mình nếu không có explicit delegation. |

### Agentic Harness Coverage

SDD triển khai **10 trong 12** patterns từ kiến trúc agentic harness nội bộ của Claude Code:

| Pattern | Trạng thái | Triển khai |
|---|---|---|
| #1 Structured Agent Definitions | ✅ | 31 agents với YAML frontmatter + domain ownership |
| #2 Path-Scoped Rules | ✅ | 13 rules tự động enforce theo file path |
| #3 Tiered Memory | ✅ | 5 tầng: MEMORY.md → topic files → archive → Supermemory |
| #4 Dream Consolidation | ✅ | `auto-dream.sh` — 5-phase consolidation tự động |
| #6 Context: Fork | ✅ | 10 analysis skills nặng chạy trong subagent context độc lập |
| #7 Skill Routing | ✅ | 117 skills với metadata `paths:`, `when_to_use:`, `effort:` |
| #8 Fork-Join Parallelism | ✅ | `fork-join.sh` — git worktree lifecycle manager |
| #10 Least Privilege Tools | ✅ | `allowed-tools:` per skill + 22-entry permission allow-list |
| #11 Bash Guard | ✅ | `bash-guard.sh` chặn RCE patterns và các lệnh nguy hiểm |
| #12 Annotation System | ✅ | Skill `/annotate` + `annotations.md` lưu gotchas vĩnh viễn |
| #5 Multi-Stage Context Compaction | ⚠️ | Cần platform-level control (HISTORY_SNIP, Microcompact, CONTEXT_COLLAPSE, Autocompact) — không thể thực hiện từ project scope |
| #9 Progressive Tool Expansion | ⚠️ | Cần harness-level tool activation logic — default tool set do Claude Code platform quyết định, không configure được từ project |

---

## Runtime Observability (v1.45.0)

Chu kỳ architecture gần nhất nâng SDD từ **artifact-complete** lên **runtime-proven** — mọi thành phần harness đều có telemetry, audit trail, và health reporting.

### Per-Agent Circuit Breaker

Circuit breaker được refactor từ global kill-switch sang per-agent state machine (`circuit-state.json` schema v2):

```json
{
  "agents": {
    "qa-engineer": { "state": "OPEN", "fail_count": 4, "fallback": "fullstack-developer" },
    "backend-developer": { "state": "CLOSED", "fail_count": 0, "fallback": "fullstack-developer" }
  }
}
```

- `circuit-guard.sh` đọc `subagent_type` từ Task input — chỉ block agent đang fail, không block toàn bộ harness
- `circuit-updater.sh` ghi state theo agent key — mỗi transition CLOSED→HALF_OPEN→OPEN được log vào `decision_ledger.jsonl` với `risk_tier: High`
- Tự động reset sau 60 phút TTL: OPEN→HALF_OPEN để probe

### Agent Health Report

```bash
node scripts/agent-health.js           # bảng per-agent: state, fail count, fallback, last transition
node scripts/agent-health.js --open    # chỉ hiện OPEN/HALF_OPEN
node scripts/agent-health.js --json    # output JSON cho automation
```

### Skill Usage Telemetry

`log-skill.sh` (UserPromptSubmit hook) ghi lại các lần gọi `/skill-name` vào `production/traces/skill-usage.jsonl`. Usage data cho phép phân tích evidence-based:

```bash
node scripts/skill-usage-report.js              # full report: used / never-used / cull candidates
node scripts/skill-usage-report.js --cull-only  # 48 candidates theo domain cluster
node scripts/skill-usage-report.js --days 7     # lọc N ngày gần nhất
```

Không cull skills cho đến khi có ≥7 ngày data thực.

---

## Steel Discipline (v1.26.0)

Chu kỳ architecture gần nhất đưa vào **Steel Discipline** — một bộ process shields ngăn chặn bốn failure mode phổ biến nhất của AI.

### Anti-Rationalization Gates

Mọi skill template giờ đều có section `## Anti-Rationalizations` — gọi tên và chặn rõ những lý do AI hay dùng để né tránh process:

> *"Tôi sẽ viết test sau để tiết kiệm thời gian."* → Blocked. TDD không phải tùy chọn.  
> *"Spec đã đủ rõ từ context rồi."* → Blocked. Blueprint bắt buộc trước khi tạo file.  
> *"Tôi sẽ refactor luôn khi đang ở đây."* → Blocked. Surgical changes only.

### Verification Gates

Mọi multi-step task phải khai báo tiêu chí verify trước khi thực thi:

```
[Step] → verify: [tiêu chí cụ thể, testable]
```

`"trông ổn"` và `"nên hoạt động"` không được chấp nhận là tiêu chí verify.

### Implicit Workflow Commands

Bốn lệnh trong `CLAUDE.md` được inject như mandatory process checkpoints:

| Lệnh | Gate được enforce |
|---|---|
| `/spec` | Blueprint + approval trước khi tạo bất kỳ file nào |
| `/plan` | Chia nhỏ task atomic trước khi bắt đầu implementation |
| `/tdd` | Red → Green → Refactor với terminal log thực tế bắt buộc |
| `/context` | Diagnose context state; recall từ Supermemory trước khi research |

### Surgical Changes Rule (src-code.md)

Mọi dòng code thay đổi phải trace trực tiếp về một yêu cầu của user. Không opportunistic refactoring, không xóa dead code "tiện thể", không thêm docstrings vào code không được chỉnh sửa. Áp dụng cho toàn bộ `src/**`.

---

## Memory Architecture

```
Tier 1  MEMORY.md                    — Index 50 dòng, keyword triggers, session pointers
Tier 2  .claude/memory/*.md          — Topic files: annotations, tech decisions, role context
Tier 3  .claude/memory/archive/      — Cold storage: sessions, decisions, dreams
Tier 4  MCP Supermemory              — Semantic recall xuyên sessions (external)
Tier 5  CLAUDE.md @include chain     — Static universal context, luôn trong prompt
```

**Incremental Loading Protocol**: Trước khi load bất kỳ Tier 2 file nào, agent phải qua 3-Question Relevance Gate (thực sự cần / đúng timing / subset đủ dùng chưa). Hard limits: tối đa 3 files mỗi session, dừng load nếu context < 30%.

---

## Skill System

### 116 Skills trên 7 Domain

| Domain | Skills tiêu biểu |
|---|---|
| Core Workflow | `/start` `/brainstorm` `/orchestrate` `/dream` `/save-state` `/gate-check` |
| Engineering Reviews | `/code-review` `/design-review` `/api-design` `/db-review` `/security-audit` |
| Process | `/sprint-plan` `/retrospective` `/milestone-review` `/estimate` `/tech-debt` |
| Release | `/release-checklist` `/launch-checklist` `/changelog` `/hotfix` `/patch-notes` |
| Process Shields | `/spec` `/plan` `/tdd` `/context` `/annotate` `/fork-join` |
| Team Orchestration | `/team-feature` `/team-backend` `/team-frontend` `/team-ui` `/team-release` |
| Technology Frameworks | `fastapi-pro` `kubernetes-architect` `nextjs-app-router-patterns` `prisma-expert` `rag-engineer` `aws-serverless` + 60 nữa |

### Context-Aware Routing

Skills activate có điều kiện dựa trên file bạn đang mở:

```
Đang edit *.tsx, next.config.*  → ~20 skills Next.js / React / Tailwind xuất hiện
Đang edit *.py, manage.py       → Skills Django, FastAPI, ML surface lên
Đang edit Dockerfile, *.tf      → Skills DevOps, Kubernetes, AWS activate
```

Gõ `/` trong Claude Code — bạn thấy cái relevant, không phải cả 123.

---

## Thành phần hệ thống

| Thành phần | Số lượng | Mô tả |
|---|---|---|
| **Agents** | 31 | Agents chuyên biệt cho product, engineering, design, QA, data, operations |
| **Skills** | 116 | Core workflows và technology frameworks với context-aware routing |
| **Hooks** | 20 | Automated validation: commits, pushes, asset changes, session lifecycle, circuit breaker, skill telemetry, decision ledger, bash guard, fork-join |
| **Rules** | 13 | Coding standards tự động enforce theo file path |
| **Templates** | 22+ | PRDs, API designs, system architecture, ADRs, mobile, incident response, postmortem |

---

## Bắt đầu

### Yêu cầu

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — `npm install -g @anthropic-ai/claude-code`
- [Git](https://git-scm.com/)
- [jq](https://jqlang.github.io/jq/) *(khuyến nghị — dùng bởi validation hooks)*
- Python 3 *(khuyến nghị — dùng bởi skill evaluation scripts)*

### Setup

```bash
git clone https://github.com/tranhieutt/software_development_department.git my-project
cd my-project
claude
```

Chạy `/start` — hệ thống hỏi bạn đang ở đâu (ý tưởng mới, codebase có sẵn, hoặc task cụ thể) và hướng dẫn từ đó.

**Antigravity Platform**: Mở thư mục trong Antigravity. Kiến trúc `.claude/` tự động load. Toàn bộ 123 workflows sẵn sàng ngay — chỉ cần giao việc.

### Entry Point phù hợp với từng tình huống

| Tình huống | Lệnh |
|---|---|
| Bắt đầu từ một ý tưởng | `/brainstorm` |
| Tiếp nối project có sẵn | `/project-stage-detect` |
| Lên kế hoạch từ backlog | `/sprint-plan` |
| Chạy nhiều agents trên một feature | `/orchestrate` |
| Không chắc bắt đầu từ đâu | `/start` |

---

## Project Structure

```
CLAUDE.md                           # Master configuration + @include chain
PRD.md                              # Product requirements document
TODO.md                             # Living backlog (quản lý bởi @producer)
.claude/
  settings.json                     # Permissions, deny rules, hook registration
  agents/                           # 31 agent definitions với domain ownership
  skills/                           # 123 skills (mỗi subdirectory một skill)
  hooks/                            # 15 hook scripts
  rules/                            # 13 path-scoped coding standards
  memory/                           # 5-layer durable memory system
  docs/
    quick-start.md
    agent-roster.md
    context-management.md           # Rules file — inject vào system prompt
    context-management-guide.md     # Reference only — KHÔNG inject
    agent-coordination-map.md
    llm-coding-behavior.md          # Karpathy principles: surgical, goal-driven
    utility-prompts.md
    templates/                      # 22+ document templates
.tasks/                             # Task detail files (một file mỗi backlog item)
src/                                # Application source code
tests/                              # Test suites
infra/                              # Infrastructure as code
scripts/                            # Build và utility scripts
docs/                               # Tài liệu kỹ thuật và ADRs
design/                             # Wireframes, specs, research
production/                         # Sprint plans, milestones, release tracking
```

---

## Path-Scoped Rules

Coding standards được enforce tự động theo file path — không cần nhớ, không cần config thêm.

| Path | Standard được enforce |
|---|---|
| `src/api/**` | REST/GraphQL conventions, auth patterns, error format chuẩn |
| `src/frontend/**` | Accessibility, design tokens, i18n, state management |
| `src/**db**` | Migrations, parameterized queries, indexing strategy |
| `src/ui/**` | Không có business logic, sẵn sàng localization, keyboard accessible |
| `src/ai/**` | Performance budgets, debuggability, model params configurable |
| `src/networking/**` | WebSocket, event streaming, real-time standards |
| `config/**` | Không hardcode secrets, schema validation bắt buộc |
| `design/docs/**` | PRD sections bắt buộc, acceptance criteria rõ ràng |
| `tests/**` | Naming conventions, coverage floors, fixture patterns |
| `src/**` | Surgical changes — mỗi thay đổi phải trace về yêu cầu của user |

---

## Collaborative, Not Autonomous

Hệ thống này không thực hiện hành động nào mà không có approval của bạn. Mọi agent đều follow một collaboration protocol 5 bước:

1. **Hỏi** — làm rõ ý định trước khi đề xuất giải pháp
2. **Đề xuất** — trình bày 2–4 options với trade-offs
3. **Quyết định** — bạn chọn
4. **Draft** — agent show work trước khi commit
5. **Approve** — không gì được ghi nếu không có explicit sign-off của bạn

Bạn vẫn là người ra quyết định. Agents cung cấp structure, domain expertise, và process enforcement — không phải autonomy.

---

## Tùy chỉnh

Đây là template, không phải locked framework. Tùy chỉnh thoải mái:

- **Thêm/xóa agents** — xóa những gì không cần, thêm agents theo stack của bạn
- **Sửa agent prompts** — tinh chỉnh behavior, inject project-specific context
- **Sửa skills** — điều chỉnh workflows theo process của team
- **Thêm rules** — tạo path-scoped standards mới cho directory layout của bạn
- **Tinh chỉnh hooks** — điều chỉnh mức validation, thêm automated checks mới

Xem [`UPGRADING.md`](UPGRADING.md) để pull upstream changes mà không overwrite customizations của bạn.

---

## Tài nguyên

| Tài liệu | Mục đích |
|---|---|
| [`docs/internal/CHANGELOG.md`](docs/internal/CHANGELOG.md) | Changelog nội bộ và lịch sử cập nhật kiến trúc của repo |
| [`report_new_capacity_sdd_with_gitnexus.md`](report_new_capacity_sdd_with_gitnexus.md) | Năng lực SDD khi tích hợp với GitNexus Knowledge Graph |
| [`plan_upgrade.md`](plan_upgrade.md) | Upgrade roadmap so sánh SDD với các frameworks cạnh tranh |
| [`compare_department_orchestrated.md`](compare_department_orchestrated.md) | So sánh: orchestrated multi-agent vs single-session truyền thống |
| [`infographic.html`](infographic.html) | Interactive visual overview của department structure |
| [`UPGRADING.md`](UPGRADING.md) | Cherry-pick upstream improvements vào fork của bạn |

---

## Platform

Đã test trên **Windows 10/11** với Git Bash. Toàn bộ hooks dùng POSIX-compatible patterns với fallbacks cho các tools thiếu. Chạy được trên macOS và Linux không cần sửa gì.

---

## Version

**v1.45.0** — 2026-04-21

Xem [`docs/internal/CHANGELOG.md`](docs/internal/CHANGELOG.md) để theo dõi lịch sử cập nhật.

---

[![Star History Chart](https://api.star-history.com/svg?repos=tranhieutt/software_development_department&type=Date)](https://star-history.com/#tranhieutt/software_development_department&Date)

## License

MIT. Xem [LICENSE](LICENSE).

---

*Dựa trên [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) by Donchitos — adapted for software engineering organizations.*

*Author: [tranhieutt](https://github.com/tranhieutt)*
