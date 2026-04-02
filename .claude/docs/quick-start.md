# Software Development Department — Quick Start Guide

## What Is This?

A complete Claude Code agent architecture for software development. It organizes 26 specialized AI agents into a department hierarchy that mirrors real software teams — with defined responsibilities, delegation rules, and coordination protocols. Agents cover product management, engineering (frontend, backend, fullstack), data, security, DevOps, QA, design, and more.

## How to Use

### 1. Understand the Hierarchy

There are three tiers of agents:

- **Tier 1 (Opus)**: Leadership who make high-level decisions
  - `cto` — technical vision, architecture strategy, technology decisions
  - `technical-director` — system architecture, ADRs, cross-system integration
  - `producer` — scheduling, coordination, risk management

- **Tier 2 (Sonnet)**: Department leads who own their domain
  - `product-manager`, `lead-programmer`, `ux-designer`, `qa-lead`, `release-manager`

- **Tier 3 (Sonnet/Haiku)**: Specialists who execute within their domain
  - Developers, engineers, researchers, testers, writers

### 2. Pick the Right Agent for the Job

Ask yourself: "What role would handle this in a real software team?"

| I need to... | Use this agent |
|-------------|---------------|
| Define product requirements | `product-manager` |
| Make an architecture decision | `technical-director` |
| Review technical strategy | `cto` |
| Design a REST/GraphQL API | `lead-programmer` + `/api-design` |
| Build a React component | `frontend-developer` |
| Write a backend service | `backend-developer` |
| Design a database schema | `data-engineer` + `/db-review` |
| Set up CI/CD | `devops-engineer` |
| Review code quality | `lead-programmer` |
| Write test cases | `qa-tester` |
| Run a security review | `security-engineer` |
| Check accessibility compliance | `accessibility-specialist` |
| Write API or developer docs | `tech-writer` |
| Conduct user research | `ux-researcher` |
| Fix a performance problem | `performance-analyst` |
| Manage a release | `release-manager` |
| Plan a sprint | `producer` |
| Test a technical idea quickly | `prototyper` |
| Write user-facing release notes | `community-manager` |
| Resolve a technical conflict | `technical-director` |
| Understand what breaks if I change X | `lead-programmer` + `/gitnexus-impact-analysis` |
| Review a PR for missed callers | `lead-programmer` + `/gitnexus-pr-review` |
| Safely rename across many files | `lead-programmer` + `/gitnexus-refactoring` |

### 3. Use Slash Commands for Common Tasks

| Command | What it does |
|---------|-------------|
| `/start` | First-time onboarding — asks where you are, guides you to the right workflow |
| `/sprint-plan` | Plan, update, or review a sprint |
| `/milestone-review` | Review milestone progress |
| `/estimate` | Produce effort estimations |
| `/retrospective` | Run a sprint or milestone retrospective |
| `/code-review` | Review code for quality and architecture |
| `/design-review` | Review a design document or PRD |
| `/api-design` | Design and review REST/GraphQL API contracts |
| `/db-review` | Review database schema and migrations |
| `/architecture-decision` | Create an Architecture Decision Record (ADR) |
| `/scope-check` | Detect scope creep against the original plan |
| `/tech-debt` | Scan, track, and prioritize technical debt |
| `/perf-profile` | Performance profiling and bottleneck identification |
| `/gate-check` | Validate phase readiness (PASS / CONCERNS / FAIL) |
| `/project-stage-detect` | Analyze project state, detect stage, identify gaps |
| `/brainstorm` | Guided product or feature ideation from scratch |
| `/prototype` | Scaffold a throwaway proof-of-concept |
| `/bug-report` | File a structured bug report |
| `/hotfix` | Emergency fix with audit trail |
| `/release-checklist` | Validate pre-release checklist |
| `/launch-checklist` | Complete launch readiness validation |
| `/changelog` | Generate changelog from git history |
| `/patch-notes` | Generate user-facing release notes |
| `/onboard` | Generate onboarding documentation for a role |
| `/reverse-document` | Generate design/architecture docs from existing code |
| `/map-systems` | Decompose a product concept into systems and dependencies |
| `/design-system` | Guided design authoring for a single feature system |
| `/localize` | Localization scan, extract, validate |
| `/team-feature` | Orchestrate full feature team pipeline (backend + frontend + QA) |
| `/team-backend` | Orchestrate backend team pipeline |
| `/team-frontend` | Orchestrate frontend team pipeline |
| `/team-ui` | Orchestrate UI implementation pipeline |
| `/team-release` | Orchestrate full release pipeline |
| `/gitnexus-impact-analysis` | Blast-radius check before editing a symbol |
| `/gitnexus-pr-review` | Risk-assessed PR review with call graph |
| `/gitnexus-refactoring` | Safe multi-file rename and extract via knowledge graph |
| `/gitnexus-exploring` | Understand architecture and trace execution flows |
| `/gitnexus-guide` | GitNexus concepts and tool reference |
| `/orchestrate` | Wave-based multi-agent execution — analyzes dependencies, runs agents in parallel/sequential waves |

### 4. Use Templates for New Documents

Templates are in `.claude/docs/templates/`:

- `product-requirements-document.md` — PRD template (problem, users, goals, specs)
- `api-design-document.md` — API contract (endpoints, auth, error handling)
- `database-schema-design.md` — Schema design (ERD, indexes, migration plan)
- `user-story.md` — User story with acceptance criteria
- `system-architecture.md` — System design (C4 model)
- `architecture-decision-record.md` — Template for ADRs
- `technical-design-document.md` — Per-feature technical design
- `test-plan.md` — Feature test plan
- `sprint-plan.md` — Sprint planning document
- `milestone-definition.md` — Milestone definition and criteria
- `post-mortem.md` — Project/incident retrospectives
- `incident-response.md` — Live incident response playbook
- `release-checklist-template.md` — Release validation checklist
- `changelog-template.md` — Changelog entry structure
- `release-notes.md` — User-facing release notes
- `pitch-document.md` — Pitching a feature or product to stakeholders
- `risk-register-entry.md` — Risk tracking entry
- `design-doc-from-implementation.md` — Reverse-document code into design doc
- `architecture-doc-from-code.md` — Reverse-document code into architecture doc

### 5. Follow the Coordination Rules

1. Work flows down the hierarchy: Leadership → Leads → Specialists
2. Conflicts escalate up the hierarchy
3. Cross-department work is coordinated by `producer`
4. Agents do not modify files outside their domain without explicit delegation
5. All architectural decisions must be documented as ADRs

## First Steps for a New Project

**Don't know where to begin?** Run `/start`. It asks where you are and routes you to the right workflow.

### Path A: "I have a product idea but no code"

1. **Run `/brainstorm`** — Explore what to build: core user problem, key flows, constraints
2. **Fill out `PRD.md`** — `product-manager` populates the root `PRD.md` with FR-numbered requirements
3. **Design the system** — Run `/map-systems` to decompose into components
4. **Make architecture decisions** — Run `/architecture-decision` to document key choices
5. **Set up technical preferences** — Fill out `CLAUDE.md` with your stack (Language, Framework, Database, etc.)
6. **Build the backlog** — `producer` creates `TODO.md` items + `.tasks/NNN-*.md` files from the PRD
7. **Define the first milestone** — Use `milestone-definition.md`
8. **Plan the first sprint** — Run `/sprint-plan new`
9. **Orchestrate** — Run `/orchestrate <task>` to execute multi-agent waves

### Path B: "I know exactly what I want to build"

1. **Fill out `CLAUDE.md`** with your stack (Language, Framework, Database, Deployment, CI/CD)
2. **Fill out `PRD.md`** with FR-numbered requirements
3. **Design APIs and schemas** — Run `/api-design` and `/db-review`
4. **Create the first ADR** — Run `/architecture-decision`
5. **Build the backlog** — `producer` creates `TODO.md` items + `.tasks/NNN-*.md` files
6. **Create the first milestone** in `production/milestones/`
7. **Plan the first sprint** — Run `/sprint-plan new`
8. Start building

### Path C: "I have an existing project"

1. **Run `/start`** (or `/project-stage-detect`) — analyzes what exists, identifies gaps
2. **Fill out `CLAUDE.md`** stack if not already configured
3. **Validate phase readiness** — Run `/gate-check`
4. **Plan the next sprint** — Run `/sprint-plan new`

## File Structure Reference

```
CLAUDE.md                          -- Master config (technology stack, project name)
PRD.md                             -- Product requirements (source of truth — human-editable only)
TODO.md                            -- Living backlog (governed by @producer)
.tasks/                            -- Task detail files (NNN-short-title.md — one per TODO item)
  TASK_TEMPLATE.md                 -- Template for creating new task files
.claude/
  settings.json                    -- Claude Code hooks and project settings
  agents/                          -- 27 agent definitions (YAML frontmatter)
  skills/                          -- Slash command definitions
  hooks/                           -- Hook scripts (.sh) wired by settings.json
  rules/                           -- 10 path-specific coding standard files
  docs/
    quick-start.md                 -- This file
    technical-preferences.md       -- Project-specific standards and conventions
    coding-standards.md            -- Coding standards overview
    coordination-rules.md          -- Agent coordination rules
    context-management.md          -- Context budgets and compaction instructions
    review-workflow.md             -- Review and sign-off process
    directory-structure.md         -- Project directory layout
    agent-roster.md                -- Full agent list with tiers and domains
    skills-reference.md            -- All slash commands reference
    rules-reference.md             -- Path-specific rules reference
    hooks-reference.md             -- Active hooks reference
    agent-coordination-map.md      -- Full delegation and workflow patterns
    setup-requirements.md          -- System prerequisites
    settings-local-template.md     -- Personal settings.local.json guide
    templates/                     -- Document templates
src/                               -- Application source code
docs/                              -- Technical documentation and ADRs
  technical/                       -- Architecture, decisions, API, database specs
    ARCHITECTURE.md                -- System architecture (C4 model)
    DECISIONS.md                   -- ADR log (append-only)
    API.md                         -- API reference
    DATABASE.md                    -- Schema documentation
  user/                            -- User-facing documentation
    USER_GUIDE.md                  -- End-user guide
tests/                             -- Test suites
infra/                             -- Infrastructure as code
scripts/                           -- Build and utility scripts
design/                            -- Wireframes, design specs, research docs
production/                        -- Sprint plans, milestones, release tracking
prototypes/                        -- Throwaway PoC code (never imported by src/)
```
