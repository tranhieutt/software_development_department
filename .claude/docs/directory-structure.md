# Directory Structure

```text
/
├── CLAUDE.md                    # Master configuration
├── PRD.md                       # Product requirements (source of truth — human-editable only)
├── TODO.md                      # Living backlog (governed by @producer)
├── .claude/                     # Agent definitions, skills, hooks, rules, docs
├── .tasks/                      # Task detail files (NNN-short-title.md — one per TODO item)
├── src/                         # Application source code (api, frontend, backend, ai, networking, ui, tools)
├── design/                      # Design files (wireframes, research, design specs)
├── docs/                        # Technical documentation
│   ├── onboarding/              # User guides, landing pages, and quick-start docs
│   ├── technical/               # Architecture, decisions, API, database spec
│   ├── reference/               # Command lists, templates, and examples
│   ├── internal/                # Audit reports, report history, and CHANGELOG.md
│   └── archived/                # Retired docs and older prototypes
├── tests/                       # Test suites (unit, integration, e2e, performance)
├── infra/                       # Infrastructure as code (docker, terraform, k8s)
├── scripts/                     # Build, migration, and utility scripts
├── prototypes/                  # Throwaway prototypes (isolated from src/)
└── production/                  # Production management (sprints, milestones, releases)
    ├── session-state/           # Ephemeral session state (active.md — gitignored)
    └── session-logs/            # Session audit trail (gitignored)
```
