<p align="center">
  <h1 align="center">Claude Code Software Development Department</h1>
  <p align="center">
    Turn a single Claude Code session into a full software development department.
    <br />
    26 agents. 33 workflows. One coordinated AI team.
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-26-blueviolet" alt="26 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-33-green" alt="33 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-8-orange" alt="8 Hooks"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-11-red" alt="11 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
</p>

---

## Why This Exists

Building software solo with AI is powerful — but a single chat session has no structure. No one stops you from skipping design docs, writing inconsistent APIs, failing security reviews, or accumulating untracked technical debt. There's no peer review, no architecture oversight, no QA pass.

**Claude Code Software Development Department** solves this by giving your AI session the structure of a real department. Instead of one general-purpose assistant, you get 26 specialized agents organized into a department hierarchy — a CTO who guards technical vision, department leads who own their domains, and specialists who do the hands-on work. Each agent has defined responsibilities, escalation paths, and quality gates.

The result: you still make every decision, but now you have a team that asks the right questions, catches mistakes early, and keeps your project organized from first spec to launch.

---

## What's Included

| Category | Count | Description |
|----------|-------|-------------|
| **Agents** | 26 | Specialized subagents across product, engineering, design, QA, data, and operations |
| **Skills** | 33 | Slash commands for common workflows (`/start`, `/sprint-plan`, `/code-review`, `/api-design`, etc.) |
| **Hooks** | 8 | Automated validation on commits, pushes, asset changes, session lifecycle, agent audit, and gap detection |
| **Rules** | 11 | Path-scoped coding standards for API, frontend, backend, database, UI, network, test code, and more |
| **Templates** | 22 | Document templates for PRDs, API designs, system architecture, user stories, ADRs, and more |

## Department Hierarchy

Agents are organized into three tiers:

```
Tier 1 — Leadership (Opus)
  cto              technical-director    producer

Tier 2 — Department Leads (Sonnet)
  product-manager  lead-programmer       ux-designer
  qa-lead          release-manager

Tier 3 — Specialists (Sonnet/Haiku)
  frontend-developer  backend-developer    fullstack-developer
  ai-programmer       network-programmer   tools-programmer
  ui-programmer       data-engineer        analytics-engineer
  ux-researcher       tech-writer          prototyper
  performance-analyst devops-engineer      security-engineer
  qa-tester           accessibility-specialist community-manager
```

## Slash Commands

Type `/` in Claude Code to access all 33 skills:

**Reviews & Analysis**
`/design-review` `/code-review` `/api-design` `/db-review` `/scope-check` `/perf-profile` `/tech-debt`

**Production**
`/sprint-plan` `/milestone-review` `/estimate` `/retrospective` `/bug-report`

**Project Management**
`/start` `/project-stage-detect` `/reverse-document` `/gate-check` `/map-systems` `/design-system`

**Release**
`/release-checklist` `/launch-checklist` `/changelog` `/patch-notes` `/hotfix`

**Creative & Research**
`/brainstorm` `/prototype` `/onboard` `/localize`

**Team Orchestration** (coordinate multiple agents on a single feature)
`/team-feature` `/team-backend` `/team-frontend` `/team-ui` `/team-release`

## Getting Started

### Prerequisites

- [Git](https://git-scm.com/)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- **Recommended**: [jq](https://jqlang.github.io/jq/) (for hook validation) and Python 3 (for JSON validation)

### Setup

1. **Clone or use as template**:
   ```bash
   git clone https://github.com/tranhieutt/software_development_department.git my-project
   cd my-project
   ```

2. **Open Claude Code** and start a session:
   ```bash
   claude
   ```

3. **Run `/start`** — the system asks where you are (new idea, existing project, or specific task) and guides you from there.

   Or jump directly to a specific skill:
   - `/brainstorm` — explore product ideas from scratch
   - `/project-stage-detect` — analyze an existing project
   - `/sprint-plan` — plan a sprint if you already have a backlog

## Project Structure

```
CLAUDE.md                           # Master configuration
.claude/
  settings.json                     # Hooks, permissions, safety rules
  agents/                           # 26 agent definitions (markdown + YAML frontmatter)
  skills/                           # 33 slash commands (subdirectory per skill)
  hooks/                            # 8 hook scripts (bash, cross-platform)
  rules/                            # 11 path-scoped coding standards
  docs/
    quick-start.md                  # Detailed usage guide
    agent-roster.md                 # Full agent table with domains
    agent-coordination-map.md       # Delegation and escalation paths
    templates/                      # 22 document templates
src/                                # Application source code
docs/                               # Technical documentation and ADRs
tests/                              # Test suites
infra/                              # Infrastructure as code
scripts/                            # Build and utility scripts
design/                             # Wireframes, design specs, research docs
production/                         # Sprint plans, milestones, release tracking
```

## How It Works

### Agent Coordination

Agents follow a structured delegation model:

1. **Vertical delegation** — CTO delegates to leads, leads delegate to specialists
2. **Horizontal consultation** — same-tier agents consult each other but can't make binding cross-domain decisions
3. **Conflict resolution** — disagreements escalate to the shared parent (`cto` for strategic, `technical-director` for technical)
4. **Change propagation** — cross-department changes are coordinated by `producer`
5. **Domain boundaries** — agents don't modify files outside their domain without explicit delegation

### Collaborative, Not Autonomous

This is **not** an auto-pilot system. Every agent follows a strict collaboration protocol:

1. **Ask** — agents ask questions before proposing solutions
2. **Present options** — agents show 2-4 options with pros/cons
3. **You decide** — the user always makes the call
4. **Draft** — agents show work before finalizing
5. **Approve** — nothing gets written without your sign-off

You stay in control. The agents provide structure and expertise, not autonomy.

### Path-Scoped Rules

Coding standards are automatically enforced based on file location:

| Path | Enforces |
|------|----------|
| `src/api/**` | REST/GraphQL conventions, auth, error format |
| `src/frontend/**` | Accessibility, design tokens, i18n, state management |
| `src/**db**` | Migrations, parameterized queries, indexing |
| `src/ui/**` | No business logic, localization-ready, accessibility |
| `src/ai/**` | Performance budgets, debuggability, data-driven parameters |
| `design/docs/**` | Required PRD sections, acceptance criteria |
| `tests/**` | Test naming, coverage requirements, fixture patterns |
| `prototypes/**` | Relaxed standards, README required, hypothesis documented |

## Customization

This is a **template**, not a locked framework. Everything is meant to be customized:

- **Add/remove agents** — delete agent files you don't need, add new ones for your stack
- **Edit agent prompts** — tune agent behavior, add project-specific knowledge
- **Modify skills** — adjust workflows to match your team's process
- **Add rules** — create new path-scoped rules for your directory structure
- **Tune hooks** — adjust validation strictness, add new checks

## Platform Support

Tested on **Windows 10** with Git Bash. All hooks use POSIX-compatible patterns and include fallbacks for missing tools. Works on macOS and Linux without modification.

## License

MIT License. See [LICENSE](LICENSE) for details.

---

*Based on [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) by Donchitos — adapted for software development teams.*

*Author: [tranhieutt](https://github.com/tranhieutt)*
