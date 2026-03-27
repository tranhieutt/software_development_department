# Directory Structure

```text
/
├── CLAUDE.md                    # Master configuration
├── .claude/                     # Agent definitions, skills, hooks, rules, docs
├── src/                         # Application source code (api, frontend, backend, ai, networking, ui, tools)
├── design/                      # Design files (wireframes, research, design specs)
├── docs/                        # Technical documentation (architecture, ADRs, api-references)
├── tests/                       # Test suites (unit, integration, e2e, performance)
├── infra/                       # Infrastructure as code (docker, terraform, k8s)
├── scripts/                     # Build, migration, and utility scripts
├── prototypes/                  # Throwaway prototypes (isolated from src/)
└── production/                  # Production management (sprints, milestones, releases)
    ├── session-state/           # Ephemeral session state (active.md — gitignored)
    └── session-logs/            # Session audit trail (gitignored)
```
