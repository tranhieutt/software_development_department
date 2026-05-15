<p align="center">
  <h1 align="center">Claude Code Software Development Department</h1>
  <p align="center">
    A governed multi-agent harness for Claude Code.
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

## What Is This

Software Development Department (SDD) turns a Claude Code workspace into a small engineering organization: agents own domains, skills route work through repeatable workflows, hooks enforce control gates, and memory persists operational context across sessions.

SDD is Claude-native. Codex support is an adapter layer via `AGENTS.md`, `.codex/`, and `docs/codex-compatibility.md`; this layer does not change Claude's runtime behavior.

## Why It Exists

Coding with a single agent often skips process: vague specs, overly broad edits, weak verification, forgotten decisions. SDD adds a control-plane structure around Claude Code so that implementation work has clear routing, bounded ownership, approval gates, and fresh evidence before declaring completion.

## Technical Capabilities

| Capability | Implementation |
|---|---|
| Structured Agent Definitions | 28 agents with role, model, ownership, escalation path, and tool scope |
| Skill Routing | 116 skills with `when_to_use`, `allowed-tools`, effort hints, and workflow gates |
| Lifecycle map | `DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP` for all non-trivial work |
| Verification gates | Pre-code gate, TDD workflow, review gates, completion evidence, and Codex preflight |
| Path-scoped rules | 15 rules applied by file zone: API, UI, DB, AI, config, tests, docs, and source code |
| Runtime hooks | 26 hook files for bash guard, trace logging, skill telemetry, circuit state, and validation |
| Durable memory | Tiered memory from `MEMORY.md` index to topic files, archive, and optional semantic recall |
| Circuit breaker | Per-agent failure state with fallback routing and audited transitions |
| Fork-join execution | Git worktree workflow for parallel, isolated, reviewable workstreams |
| Agent-style review | Portable `agent-style` skill package for opt-in technical prose review |

## Quick Start

### Existing Product Repo

Clone SDD once, then install the harness into your product directory:

```powershell
git clone https://github.com/tranhieutt/software_development_department [Your folder clone's path]
cd [Your folder clone's path]
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-sdd.ps1 [Your folder project's path]
```

This defaults to Product mode and runs preflight after install. Product mode preserves existing product files: `README.md`, `PRD.md`, `TODO.md`, and `.gitignore`.

Open your product directory after install:

```powershell
cd [Your folder project's path]
```

With Claude Code, read `CLAUDE.md` and run `/start`.

With Codex, read `AGENTS.md` and `.codex/START.md`, or paste:

```text
Use codex-sdd, then route through using-sdd, then run the start workflow for this repo.
```

## Requirements

- Claude Code: `npm install -g @anthropic-ai/claude-code`
- Git
- Git Bash 2.40+ or WSL2 on Windows for hook shell compatibility
- `jq` and Python 3 recommended for validation and audit scripts

## Codex Adapter

With Codex, open this repository and use `.codex/START.md` as the equivalent of `/start`. Codex must self-enforce SDD gates because Claude Code hooks do not run automatically in Codex.

Run the preflight check before any risky Codex work:

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

1. Route requests through `using-sdd`.
2. Pick a coordination skill: spec, plan, TDD, review, release, or specialist workflow.
3. Pass the pre-code gate before editing production code.
4. Keep changes scoped to the approved task.
5. Verify with a fresh command or inspection before declaring completion.
6. Keep Claude as the source of truth; keep Codex as the adapter.

Common entry points:

| Situation | Command |
|---|---|
| Start a session | `/start` |
| Explore an idea | `/brainstorm` |
| Write a spec | `/spec` |
| Break down a plan | `/plan` |
| Implement an approved task | `/tdd` |
| Coordinate agents | `/orchestrate` |
| Review code | `/code-review` |
| Review prose style | `/style-review` |
| Prepare a release | `/release-checklist` |

Type `/` in Claude Code to browse related workflows; SDD provides 116 workflows but expects agents to load only the skill needed for the current task.

## Included

| Category | Count | Purpose |
|---|---:|---|
| **Agents** | 28 | Domain ownership and escalation |
| **Skills** | 116 | Workflow routing and specialist procedures |
| **Hooks** | 26 | Guardrails, telemetry, validation, and lifecycle checks |
| **Rules** | 15 | Path-scoped standards |
| **Templates** | 22+ | Specs, ADRs, plans, reports, and release artifacts |

## Project Structure

```text
CLAUDE.md                           # Claude-native constitution
AGENTS.md                           # Adapter guide for Codex
.codex/                             # Adapter prompts and checklists for Codex
.claude/
  settings.json                     # Permissions and hook registration
  agents/                           # 28 agent definitions
  skills/                           # 116 skills
  hooks/                            # 26 hook scripts
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

MIT. See [LICENSE](LICENSE).

Based on [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) by Donchitos; adapted for software engineering organizations.
