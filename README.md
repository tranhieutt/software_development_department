<p align="center">
  <h1 align="center">Claude Code Software Development Department</h1>
  <p align="center">
    A structured agentic system that transforms a single Claude Code session<br />
    into a coordinated software engineering organization.
    <br /><br />
    28 agents - 126 context-optimized skills - 10/12 agentic harness patterns - MAS Infrastructure - Steel-discipline enforcement - Runtime-proven harness
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-28-blueviolet" alt="28 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-126-green" alt="126 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-29-orange" alt="29 Hook Files"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-13-red" alt="13 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
</p>

---

## Prerequisites (Platform Parity)

- **Claude Code**: `npm install -g @anthropic-ai/claude-code`
- **Codex**: Supported through the additive adapter in `AGENTS.md` and `docs/codex-compatibility.md`.
- **Git**: Mandatory for version control and hooks.
- **Windows Users**: Requires **Git Bash 2.40+** OR **WSL2**. CMD/PowerShell are supported for most commands, but the automated validation hooks require a POSIX-compliant shell.
- **jq** (recommended): Used by validation hooks for JSON parsing.
- **Python 3** (recommended): Used by skill evaluation and audit scripts.

## Codex Compatibility

SDD remains Claude-native. Codex support is provided as an adapter layer that
does not change Claude Code runtime behavior.

- Start with `AGENTS.md` when using Codex in this repo.
- Install/discover SDD skills through `.codex/INSTALL.md`.
- Use `.codex/START.md` as the recommended first prompt when you want the
  Codex equivalent of Claude's `/start` workflow.
- Use `docs/codex-compatibility.md` for the Claude-to-Codex tool mapping,
  manual hook equivalents, and verification checklist.
- Run `powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1`
  before risky Codex work or completion claims.

### Codex Session Start

Codex does not support Claude slash commands directly. The closest equivalent
to `/start` is the adapter prompt in `.codex/START.md`.

Recommended flow:

1. Open Codex in this repository.
2. Paste the prompt from `.codex/START.md`.
3. Let Codex route through `codex-sdd` -> `using-sdd` -> `start`.
4. Answer the onboarding A/B/C/D question.
5. Confirm the next workflow before Codex edits anything.

Short form prompt:

```text
Use codex-sdd, then route through using-sdd, then run the start workflow for this repo.
```

## The Problem

An AI session without structure behaves like a junior engineer without oversight: it ships, but it skips the design doc, ignores edge cases, accumulates silent technical debt, and has no one to push back when the scope creeps.

The fundamental constraint is not model capability — it's organizational entropy. A single-session AI has no department boundaries, no escalation path, no domain authority, no memory across concerns. It answers every question but owns nothing.

**Claude Code Software Development Department** is an architectural solution to that problem.

---

## What This System Is

SDD is a **governed multi-agent harness** built natively on Claude Code's agentic primitives. It is not a wrapper. It is not a prompt library. It is an organizational structure that imposes the coordination patterns of a real engineering department on top of a Claude Code session.

The result is a system where:

- **Authority is scoped**: agents own domains and don't cross boundaries without explicit delegation
- **Process is enforced**: spec before implementation, plan before code, tests before merge — enforced via hooks and verification gates, not suggestions
- **Memory persists**: a 5-layer durable memory architecture (Tier 1 index → Tier 2 topic files → Tier 3 cold archive → MCP Supermemory semantic store) survives across sessions (**Privacy-first: Bring Your Own Brain**)
- **Context is surgical**: incremental loading with a 3-Question Relevance Gate prevents context stuffing; max 3 Tier 2 files per session
- **Routing is precise**: 126 skills with `paths:` triggers, `when_to_use:` semantics, and `effort:` scores let the AI self-route without human navigation
- **Visual Intelligence**: Automated Technical Diagramming (SVG/PNG) for architectures, sequence flows, and process models via `/visualize`. 

---

## Architecture

### Department Hierarchy

Three tiers. Clear escalation paths. No ambiguous authority.

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

| Pattern | Behavior |
|---|---|
| Vertical delegation | CTO → leads → specialists. Decisions flow down; blockers escalate up. |
| Horizontal consultation | Same-tier agents advise but cannot make binding cross-domain decisions. |
| Conflict resolution | Strategic conflicts → `cto`. Technical conflicts → `technical-director`. |
| Cross-department changes | Coordinated exclusively by `producer`. |
| Domain isolation | Agents cannot modify files outside their domain without explicit delegation. |

### Agentic Harness Coverage

SDD implements **10 of 12** patterns from Claude Code's internal agentic harness architecture:

| Pattern | Status | Implementation |
|---|---|---|
| #1 Structured Agent Definitions | ✅ | 28 agents with YAML frontmatter + domain ownership |
| #2 Path-Scoped Rules | ✅ | 13 rules auto-enforced by file path |
| #3 Tiered Memory | ✅ | 5-layer: MEMORY.md → topic files → archive → Supermemory |
| #4 Dream Consolidation | ✅ | `auto-dream.sh` — 5-phase automated consolidation |
| #6 Context: Fork | ✅ | 10 heavy analysis skills run in isolated subagent context |
| #7 Skill Routing | ✅ | 126 skills with `paths:`, `when_to_use:`, `effort:` metadata |
| #8 Fork-Join Parallelism | ✅ | `fork-join.sh` — git worktree lifecycle manager |
| #10 Least Privilege Tools | ✅ | `allowed-tools:` per skill + 22-entry permission allow-list |
| #11 Bash Guard | ✅ | `bash-guard.sh` blocks RCE patterns, destructive commands |
| #12 Annotation System | ✅ | `/annotate` skill + `annotations.md` persistent gotcha store |
| #5 Multi-Stage Context Compaction | ⚠️ | Requires platform-level conversation control (HISTORY_SNIP, Microcompact, CONTEXT_COLLAPSE, Autocompact) — not accessible from project scope |
| #9 Progressive Tool Expansion | ⚠️ | Requires harness-level tool activation logic — the default tool set is determined by the Claude Code platform, not configurable per-project |

---

## Runtime Observability (v1.45.0)

The most recent architecture cycle upgraded SDD from **artifact-complete** to **runtime-proven** — every harness component now has telemetry, audit trails, and health reporting.

### Per-Agent Circuit Breaker

Circuit breaker migrated from global kill-switch to per-agent state machine (`circuit-state.json` schema v2):

```json
{
  "agents": {
    "qa-engineer": { "state": "OPEN", "fail_count": 4, "fallback": "fullstack-developer" },
    "backend-developer": { "state": "CLOSED", "fail_count": 0, "fallback": "fullstack-developer" }
  }
}
```

- `circuit-guard.sh` reads `subagent_type` from Task input — only blocks the failing agent, not the entire harness
- `circuit-updater.sh` writes state per agent key — CLOSED→HALF_OPEN→OPEN transitions log to `decision_ledger.jsonl` with `risk_tier: High`
- Auto-reset after 60-minute TTL transitions OPEN→HALF_OPEN for probe

### Agent Health Report

```bash
node scripts/agent-health.js           # per-agent circuit table + fallback + last transition
node scripts/agent-health.js --open    # only OPEN/HALF_OPEN agents
node scripts/agent-health.js --json    # machine-readable output
```

### Skill Usage Telemetry

`log-skill.sh` (UserPromptSubmit hook) captures `/skill-name` invocations into `production/traces/skill-usage.jsonl`. Usage data feeds the skill usage report:

```bash
node scripts/skill-usage-report.js              # full report: used / never-used / cull candidates
node scripts/skill-usage-report.js --cull-only  # 48 domain-cluster cull candidates identified
node scripts/skill-usage-report.js --days 7     # filter to last N days
```

Cull decisions are evidence-based — no skills removed until ≥7 days of real usage data.

---

## Process Enforcement (v1.27.0)

The earlier architecture cycle introduced **Steel Discipline**.

### Anti-Rationalization Gates

Every skill template now includes an `## Anti-Rationalizations` section that explicitly names and blocks the excuses an AI uses to skip process:

> *"I'll write the test after to save time."* → Blocked. TDD is not optional.  
> *"The spec is clear enough from context."* → Blocked. Blueprint required before file creation.  
> *"I'll refactor this while I'm here."* → Blocked. Surgical changes only.

### Verification Gates

Multi-step tasks must declare a verifiable check before execution:

```
[Step] → verify: [specific, testable criterion]
```

`"looks good"` and `"should work"` are not accepted criteria.

### Implicit Workflow Commands

Four commands in `CLAUDE.md` are now injected as mandatory process checkpoints:

| Command | Gate enforced |
|---|---|
| `/spec` | Blueprint + approval before any file is created |
| `/plan` | Atomic task breakdown before implementation begins |
| `/tdd` | Red → Green → Refactor cycle with terminal log required |
| `/context` | Diagnose context state; recall from Supermemory before any research |

### Surgical Changes Rule (src-code.md)

Every line of code modified must trace directly to a user requirement. No opportunistic refactoring, no dead code removal "while you're at it", no docstrings added to untouched code. Enforced for all files matching `src/**`.

---

## Memory Architecture

```
Tier 1  MEMORY.md                    — 50-line index, keyword triggers, session pointers
Tier 2  .claude/memory/*.md          — Topic files: annotations, tech decisions, role context
Tier 3  .claude/memory/archive/      — Cold storage: sessions, decisions, dreams
Tier 4  MCP Supermemory              — Semantic recall across all sessions (external)
Tier 5  CLAUDE.md @include chain     — Static universal context, always in prompt
```

**Incremental Loading Protocol**: Before loading any Tier 2 file, the agent passes a 3-Question Relevance Gate (actual need / timing / subset sufficiency). Hard limits: max 3 files per session, stop loading if context < 30%.

---

## Skill System

### 126 Skills Across 7 Domains

| Domain | Representative Skills |
|---|---|
| Core Workflow | `/start` `/brainstorm` `/orchestrate` `/dream` `/save-state` `/gate-check` |
| Engineering Reviews | `/code-review` `/design-review` `/api-design` `/db-review` `/security-audit` |
| Process | `/sprint-plan` `/retrospective` `/milestone-review` `/estimate` `/tech-debt` |
| **New: Visuals** | `/visualize` skills to generate SVG/PNG diagrams following Claude Official styles |
| Release | `/release-checklist` `/launch-checklist` `/changelog` `/hotfix` `/patch-notes` |
| Process Shields | `/spec` `/plan` `/tdd` `/context` `/annotate` `/fork-join` |
| Team Orchestration | `/team-feature` `/team-backend` `/team-frontend` `/team-ui` `/team-release` |
| Technology Frameworks | `fastapi-pro` `kubernetes-architect` `nextjs-app-router-patterns` `prisma-expert` `rag-engineer` `aws-serverless` + 70 more |

### Context-Aware Routing

Skills activate conditionally based on the files you have open:

```
Editing *.tsx, next.config.*  → ~20 Next.js / React / Tailwind skills available
Editing *.py, manage.py       → Django, FastAPI, ML skills surface
Editing Dockerfile, *.tf      → DevOps, Kubernetes, AWS skills activate
```

Type `/` in Claude Code — you see what's relevant, not all 123.

---

## What's Included

| Category | Count | Description |
|---|---|---|
| **Agents** | 31 | Specialized subagents across product, engineering, design, QA, data, and operations |
| **Skills** | 126 | Core workflows and technology frameworks with context-aware routing |
| **Hooks** | 20 | Automated validation: commits, pushes, asset changes, session lifecycle, circuit breaker, skill telemetry, decision ledger, bash guard, fork-join |
| **Rules** | 13 | Path-scoped coding standards enforced automatically by file location |
| **Templates** | 22+ | PRDs, API designs, system architecture, ADRs, mobile, incident response, postmortem |

---

## Getting Started

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — `npm install -g @anthropic-ai/claude-code`
- [Git](https://git-scm.com/)
- [jq](https://jqlang.github.io/jq/) *(recommended — used by validation hooks)*
- Python 3 *(recommended — used by skill evaluation scripts)*

### Setup

```bash
git clone https://github.com/tranhieutt/software_development_department.git my-project
cd my-project
claude
```

Run `/start` — the system asks where you are (new concept, existing codebase, or specific task) and guides you from there.

**Antigravity Platform**: Open the directory in Antigravity. The `.claude/` architecture loads automatically. All 123 workflows are available immediately — just assign tasks.

### Setup (Codex)

```powershell
git clone https://github.com/tranhieutt/software_development_department.git my-project
cd my-project
```

Optional local skill discovery:

```powershell
$repo = (Get-Location).Path
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\sdd" "$repo\.claude\skills"
```

Then start Codex in the repo and paste the prompt from `.codex/START.md`.
That gives you the Codex equivalent of `/start`: adapter bootstrap, repo-state
inspection, the onboarding A/B/C/D question, and a routed next workflow
without automatic edits.

### Entry Points

| Situation | Command |
|---|---|
| Starting from an idea | `/brainstorm` |
| Joining an existing project | `/project-stage-detect` |
| Planning work from a backlog | `/sprint-plan` |
| Coordinating multiple agents on a feature | `/orchestrate` |
| Unsure where to begin | `/start` |

For Codex, use the `.codex/START.md` prompt for the `/start` equivalent.

---

## Project Structure

```
CLAUDE.md                           # Master configuration + @include chain
PRD.md                              # Product requirements document
TODO.md                             # Living backlog (governed by @producer)
.claude/
  settings.json                     # Permissions, deny rules, hook registration
  agents/                           # 31 agent definitions with domain ownership
  skills/                           # 126 skills (one subdirectory each)
  hooks/                            # 15 hook scripts
  rules/                            # 13 path-scoped coding standards
  memory/                           # 5-layer durable memory system
  docs/
    quick-start.md
    agent-roster.md
    context-management.md           # Rules file — injected into system prompt
    context-management-guide.md     # Reference only — NOT injected
    agent-coordination-map.md
    llm-coding-behavior.md          # Karpathy principles: surgical, goal-driven
    utility-prompts.md
    templates/                      # 22+ document templates
.tasks/                             # Task detail files (one per backlog item)
src/                                # Application source code
tests/                              # Test suites
infra/                              # Infrastructure as code
scripts/                            # Build and utility scripts
docs/                               # Technical documentation and ADRs
design/                             # Wireframes, specs, research
production/                         # Sprint plans, milestones, release tracking
```

---

## Path-Scoped Rules

Coding standards are enforced automatically based on file path — no manual invocation required.

| Path | Standard enforced |
|---|---|
| `src/api/**` | REST/GraphQL conventions, auth patterns, error format |
| `src/frontend/**` | Accessibility, design tokens, i18n, state management |
| `src/**db**` | Migrations, parameterized queries, indexing strategy |
| `src/ui/**` | No business logic, localization-ready, accessibility |
| `src/ai/**` | Performance budgets, debuggability, data-driven parameters |
| `src/networking/**` | WebSocket, event streaming, real-time standards |
| `config/**` | No hardcoded secrets, schema validation required |
| `design/docs/**` | PRD sections required, acceptance criteria mandatory |
| `tests/**` | Naming conventions, coverage floors, fixture patterns |
| `src/**` | Surgical changes — every edit traces to a user requirement |

---

## Collaborative, Not Autonomous

This system does not take actions without your approval. Every agent follows a five-step collaboration protocol:

1. **Ask** — clarify intent before proposing solutions
2. **Options** — present 2–4 alternatives with trade-offs
3. **Decide** — you make the call
4. **Draft** — agent shows the work before committing
5. **Approve** — nothing is written without explicit sign-off

You remain the decision-maker. The agents provide structure, domain expertise, and process enforcement — not autonomy.

---

## Customization

This is a template, not a locked framework. Customize freely:

- **Add or remove agents** — delete what you don't need, add role-specific agents for your stack
- **Edit agent prompts** — tune behavior, inject project-specific context
- **Modify skills** — adjust workflows to match your team's process
- **Add rules** — create new path-scoped standards for your directory layout
- **Tune hooks** — adjust validation strictness, add new automated checks

See [`UPGRADING.md`](UPGRADING.md) for pulling upstream changes without overwriting your customizations.

---

## Additional Resources

| Resource | Purpose |
|---|---|
| [`docs/internal/CHANGELOG.md`](docs/internal/CHANGELOG.md) | Internal changelog and release history for architectural and repository updates |
| [`report_new_capacity_sdd_with_gitnexus.md`](report_new_capacity_sdd_with_gitnexus.md) | SDD + GitNexus Knowledge Graph integration capabilities |
| [`plan_upgrade.md`](plan_upgrade.md) | Upgrade roadmap comparing SDD to competing frameworks |
| [`compare_department_orchestrated.md`](compare_department_orchestrated.md) | Side-by-side: orchestrated multi-agent vs traditional single-session |
| [`infographic.html`](infographic.html) | Interactive visual overview of the department structure |
| [`UPGRADING.md`](UPGRADING.md) | Cherry-picking upstream improvements into your fork |

---

## Platform

Tested on **Windows 10/11** with Git Bash. All hooks use POSIX-compatible patterns with fallbacks for missing tools. Works on macOS and Linux without modification.

---

## Version

**v1.45.0** — 2026-04-21

See [`docs/internal/CHANGELOG.md`](docs/internal/CHANGELOG.md) for release history.

---

[![Star History Chart](https://api.star-history.com/svg?repos=tranhieutt/software_development_department&type=Date)](https://star-history.com/#tranhieutt/software_development_department&Date)

## License

MIT. See [LICENSE](LICENSE).

---

*Based on [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) by Donchitos — adapted for software engineering organizations.*

*Author: [tranhieutt](https://github.com/tranhieutt)*
