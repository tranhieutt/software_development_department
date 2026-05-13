<p align="center">
  <h1 align="center">Claude Code Software Development Department</h1>
  <p align="center">
    A governed multi-agent harness for Claude Code.
    <br /><br />
    28 agents - 128 context-optimized skills - 28 hook files - 15 rules
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-28-blueviolet" alt="28 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-128-green" alt="128 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-28-orange" alt="28 Hook Files"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-15-red" alt="15 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
</p>

---

## What This Is

Software Development Department (SDD) turns one Claude Code workspace into a
small engineering organization: agents own domains, skills route work through
repeatable workflows, hooks enforce gates, and memory preserves operating
context across sessions.

SDD is Claude-native. Codex support is an adapter layer through `AGENTS.md`,
`.codex/`, and `docs/codex-compatibility.md`; it does not change Claude runtime
behavior.

## Why It Exists

Single-agent coding tends to skip process: unclear specs, broad edits, weak
verification, and forgotten decisions. SDD adds control-plane structure around
Claude Code so implementation work has explicit routing, scoped ownership,
approval gates, and fresh evidence before completion claims.

## Unique Technical Capabilities

| Capability | Implementation |
|---|---|
| Structured Agent Definitions | 28 agents with role, model, ownership, escalation path, and tool scope |
| Skill Routing | 128 skills with `when_to_use`, `allowed-tools`, effort hints, and workflow gates |
| Lifecycle Map | `DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP` across all non-trivial work |
| Verification Gates | Pre-code gate, TDD workflow, review gates, completion evidence, and Codex preflight |
| Path-Scoped Rules | 15 rules applied by file area: API, UI, DB, AI, config, tests, docs, and source code |
| Runtime Hooks | 28 hook files for bash guard, trace logging, skill telemetry, circuit state, and validation |
| Durable Memory | Tiered memory from `MEMORY.md` index to topic files, archive, and optional semantic recall |
| Circuit Breaker | Per-agent failure state with fallback routing and auditable transitions |
| Fork-Join Execution | Git worktree workflow for independent, reviewable parallel workstreams |
| Agent-Style Review | Portable `agent-style` skill bundle for opt-in technical prose review |

## Quick Start

### Existing Product Repo

Clone SDD once, then install the harness into your product folder:

```powershell
git clone https://github.com/tranhieutt/software_development_department E:\SDD-Upgrade
cd E:\SDD-Upgrade
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-sdd.ps1 E:\BeeGroup_v1.0
```

This default path uses Product mode and runs preflight after install. Product
mode preserves existing product files: `README.md`, `PRD.md`, `TODO.md`, and
`.gitignore`.

Open the product folder after install:

```powershell
cd E:\BeeGroup_v1.0
```

For Claude Code, read `CLAUDE.md` and run `/start`.

For Codex, read `AGENTS.md` and `.codex/START.md`, or paste:

```text
Use codex-sdd, then route through using-sdd, then run the start workflow for this repo.
```

## Prerequisites

- Claude Code: `npm install -g @anthropic-ai/claude-code`
- Git
- Git Bash 2.40+ or WSL2 on Windows for hook-compatible shell behavior
- `jq` and Python 3 recommended for validation and audit scripts

## Install Into A Product

Use Product mode when applying SDD to another repository. It installs the
harness without overwriting product identity files such as `README.md`, `PRD.md`,
`TODO.md`, and `.gitignore`.

Recommended Windows command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-sdd.ps1 E:\MyProduct
```

Lower-level initializer:

```powershell
.\init-sdd.ps1 -Path E:\MyProduct -InstallMode Product
```

Mac/Linux:

```bash
./init-sdd.sh --install-mode product /path/to/my-product
```

Use SddDev mode only for a workspace that should contain full SDD repository
documentation and validators.

```powershell
.\init-sdd.ps1 -Path E:\SomeSddWorkspace -InstallMode SddDev
```

## Codex Adapter

For Codex, open this repository and use `.codex/START.md` as the `/start`
equivalent. Codex must manually honor SDD gates because Claude Code hooks do not
run automatically in Codex.

Recommended check before risky Codex work:

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

1. Route request through `using-sdd`.
2. Choose the governing skill: spec, plan, TDD, review, release, or specialist workflow.
3. State the pre-code gate before production edits.
4. Keep changes scoped to the approved task.
5. Verify with a fresh command or inspection before claiming completion.
6. Preserve Claude as source of truth; keep Codex as adapter.

Common entry points:

| Situation | Command |
|---|---|
| Start session | `/start` |
| Explore idea | `/brainstorm` |
| Write spec | `/spec` |
| Break down work | `/plan` |
| Implement approved task | `/tdd` |
| Coordinate agents | `/orchestrate` |
| Review code | `/code-review` |
| Review prose | `/style-review` |
| Prepare release | `/release-checklist` |

Type `/` in Claude Code to see relevant workflows; SDD exposes 128 workflows but
expects agents to load only the skill needed for the current task.

## Included

| Category | Count | Purpose |
|---|---:|---|
| **Agents** | 28 | Domain ownership and escalation |
| **Skills** | 128 | Workflow routing and specialist procedures |
| **Hooks** | 28 | Guardrails, telemetry, validation, and lifecycle checks |
| **Rules** | 15 | Path-scoped standards |
| **Templates** | 22+ | Specs, ADRs, plans, reports, and release artifacts |

## Project Layout

```text
CLAUDE.md                           # Claude-native constitution
AGENTS.md                           # Codex adapter instructions
.codex/                             # Codex adapter prompts and checklists
.claude/
  settings.json                     # Permissions and hook registration
  agents/                           # 28 agent definitions
  skills/                           # 128 skills
  hooks/                            # 28 hook scripts
  rules/                            # 15 path-scoped rules
  memory/                           # Durable memory system
docs/                               # Technical docs, ADRs, compatibility notes
scripts/                            # Validators, reports, and utility scripts
production/traces/                  # Decision, skill, and agent telemetry
```

## Validation

```powershell
powershell -ExecutionPolicy Bypass -File scripts\codex-preflight.ps1
powershell -ExecutionPolicy Bypass -File scripts\validate-skills.ps1
node scripts\harness-audit.js --compact
node scripts\validate-readme-sync.js
```

## License

MIT. See [LICENSE](LICENSE).

Based on [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)
by Donchitos; adapted for software engineering organizations.
