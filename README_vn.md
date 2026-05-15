<p align="center">
  <h1 align="center">Claude Code Software Development Department</h1>
  <p align="center">
    Harness multi-agent có kiểm soát cho Claude Code.
    <br /><br />
    28 agents · 116 context-optimized skills · 26 hook files · 15 rules
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

## Đây là gì

Software Development Department (SDD) biến một workspace Claude Code thành một
tổ chức kỹ thuật nhỏ: agents sở hữu domain, skills route công việc qua workflow
lặp lại được, hooks enforce gate, và memory giữ lại context vận hành qua nhiều
session.

SDD là Claude-native. Codex chỉ là adapter qua `AGENTS.md`, `.codex/`, và
`docs/codex-compatibility.md`; adapter này không thay đổi runtime behavior của
Claude.

## Vì sao cần

Một coding agent đơn lẻ dễ bỏ qua process: spec mơ hồ, edit quá rộng, verify
yếu, decision thất lạc. SDD thêm control plane quanh Claude Code để mỗi việc
triển khai có routing rõ, ownership có scope, approval gate, và evidence mới
trước khi claim hoàn thành.

## Unique technical

| Năng lực | Triển khai |
|---|---|
| Structured Agent Definitions | 28 agents có role, model, ownership, escalation path, và tool scope |
| Skill Routing | 116 skills có `when_to_use`, `allowed-tools`, effort hints, và workflow gates |
| Lifecycle Map | `DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP` cho mọi việc non-trivial |
| Verification Gates | Pre-code gate, TDD workflow, review gates, completion evidence, và Codex preflight |
| Path-Scoped Rules | 15 rules theo vùng file: API, UI, DB, AI, config, tests, docs, source code |
| Runtime Hooks | 26 hook files cho bash guard, trace logging, skill telemetry, circuit state, validation |
| Durable Memory | Memory nhiều tầng từ `MEMORY.md` index tới topic files, archive, semantic recall tùy chọn |
| Circuit Breaker | Per-agent failure state với fallback routing và transition có audit |
| Fork-Join Execution | Git worktree workflow cho các workstream độc lập, dễ review |
| Agent-Style Review | Skill `agent-style` portable cho review prose kỹ thuật theo rule pack pin version |

## Hướng dẫn sử dụng cực nhanh

### Dự án sản phẩm đã có sẵn

Clone SDD một lần, rồi cài harness vào folder dự án:

```powershell
git clone https://github.com/tranhieutt/software_development_department E:\SDD-Upgrade
cd E:\SDD-Upgrade
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-sdd.ps1 E:\BeeGroup_v1.0
```

Lệnh này mặc định dùng Product mode và chạy preflight sau khi cài. Product mode
giữ nguyên file nhận diện của dự án nếu đã có: `README.md`, `PRD.md`, `TODO.md`,
và `.gitignore`.

Sau khi cài, mở folder dự án:

```powershell
cd E:\BeeGroup_v1.0
```

Với Claude Code, đọc `CLAUDE.md` rồi chạy `/start`.

Với Codex, đọc `AGENTS.md` và `.codex/START.md`, hoặc paste:

```text
Use codex-sdd, then route through using-sdd, then run the start workflow for this repo.
```

## Yêu cầu

- Claude Code: `npm install -g @anthropic-ai/claude-code`
- Git
- Git Bash 2.40+ hoặc WSL2 trên Windows để hooks chạy đúng shell behavior
- Khuyến nghị có `jq` và Python 3 cho validation/audit scripts

## Cài vào dự án thật

Dùng Product mode khi apply SDD vào repo sản phẩm. Mode này cài harness nhưng
không ghi đè file identity của sản phẩm như `README.md`, `PRD.md`, `TODO.md`,
và `.gitignore`.

Lệnh Windows khuyến nghị:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-sdd.ps1 E:\MyProduct
```

Lệnh initializer cấp thấp:

```powershell
.\init-sdd.ps1 -Path E:\MyProduct -InstallMode Product
```

Mac/Linux:

```bash
./init-sdd.sh --install-mode product /path/to/my-product
```

Chỉ dùng SddDev mode cho workspace cần chứa đầy đủ docs và validators của chính
SDD repo.

```powershell
.\init-sdd.ps1 -Path E:\SomeSddWorkspace -InstallMode SddDev
```

## Codex Adapter

Với Codex, mở repo này và dùng `.codex/START.md` như bản tương đương của
`/start`. Codex phải tự honor SDD gates vì Claude Code hooks không tự chạy trong
Codex.

Check khuyến nghị trước khi làm việc rủi ro bằng Codex:

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

## Operating Model

1. Route request qua `using-sdd`.
2. Chọn skill điều khiển: spec, plan, TDD, review, release, hoặc specialist workflow.
3. Nêu pre-code gate trước production edit.
4. Giữ thay đổi đúng scope task đã duyệt.
5. Verify bằng command hoặc inspection mới trước khi claim hoàn thành.
6. Giữ Claude là source of truth; Codex chỉ là adapter.

Entry points hay dùng:

| Tình huống | Command |
|---|---|
| Bắt đầu session | `/start` |
| Khai phá ý tưởng | `/brainstorm` |
| Viết spec | `/spec` |
| Chia task | `/plan` |
| Implement task đã duyệt | `/tdd` |
| Điều phối agents | `/orchestrate` |
| Review code | `/code-review` |
| Review prose | `/style-review` |
| Chuẩn bị release | `/release-checklist` |

Gõ `/` trong Claude Code để thấy workflow phù hợp; SDD có 116 workflows nhưng
agent chỉ nên load skill cần thiết cho task hiện tại.

## Thành phần

| Category | Count | Purpose |
|---|---:|---|
| **Agents** | 28 | Domain ownership và escalation |
| **Skills** | 116 | Workflow routing và specialist procedures |
| **Hooks** | 26 | Guardrails, telemetry, validation, lifecycle checks |
| **Rules** | 15 | Path-scoped standards |
| **Templates** | 22+ | Specs, ADRs, plans, reports, release artifacts |

## Project Layout

```text
CLAUDE.md                           # Claude-native constitution
AGENTS.md                           # Codex adapter instructions
.codex/                             # Codex adapter prompts và checklists
.claude/
  settings.json                     # Permissions và hook registration
  agents/                           # 28 agent definitions
  skills/                           # 116 skills
  hooks/                            # 26 hook scripts
  rules/                            # 15 path-scoped rules
  memory/                           # Durable memory system
docs/                               # Technical docs, ADRs, compatibility notes
scripts/                            # Validators, reports, utility scripts
production/traces/                  # Decision, skill, agent telemetry
```

## Verification

```powershell
powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1
powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1
node scripts\harness-audit.js --compact
node scripts\validate-readme-sync.js
```

## License

MIT. Xem [LICENSE](LICENSE).

Dựa trên [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)
by Donchitos; adapted for software engineering organizations.
