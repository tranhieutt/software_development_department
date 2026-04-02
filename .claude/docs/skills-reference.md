# Available Skills (Slash Commands)

| Command | Purpose |
|---------|---------|
| `/start` | First-time onboarding — asks where you are, then guides you to the right workflow |
| `/save-state` | Save current working context to `production/session-state/active.md` — run before `/clear`, context resets, or ending a session |
| `/design-review` | Review a design document, PRD, or specification for completeness and consistency |
| `/code-review` | Architectural code review for a file or changeset |
| `/api-design` | Design and review REST/GraphQL API contracts, endpoint schemas, and error handling |
| `/db-review` | Review database schema, migrations, indexing strategy, and query performance |
| `/sprint-plan` | Generate or update a sprint plan |
| `/bug-report` | Create a structured bug report |
| `/architecture-decision` | Create an Architecture Decision Record (ADR) |
| `/milestone-review` | Review milestone progress and generate status report |
| `/onboard` | Generate onboarding context for a new contributor or agent |
| `/prototype` | Scaffold a throwaway proof-of-concept to validate a technical approach |
| `/release-checklist` | Generate and validate a pre-release checklist |
| `/changelog` | Auto-generate changelog from git commits and sprint data |
| `/retrospective` | Run a structured sprint or milestone retrospective |
| `/estimate` | Produce a structured effort estimate with complexity and risk breakdown |
| `/hotfix` | Emergency fix workflow with audit trail, bypassing normal sprint process |
| `/tech-debt` | Scan, track, prioritize, and report on technical debt across the codebase |
| `/scope-check` | Analyze feature or sprint scope against original plan, flag scope creep |
| `/localize` | Localization workflow: scan for hardcoded strings, extract, validate translations |
| `/perf-profile` | Structured performance profiling with bottleneck identification and recommendations |
| `/project-stage-detect` | Automatically analyze project state, detect stage, identify gaps, and recommend next steps |
| `/update-codemap` | Update `docs/technical/CODEMAP.md` by scanning codebase — run after feature merges or refactors |
| `/reverse-document` | Generate design or architecture documents from existing implementation |
| `/orchestrate` | Wave-based multi-agent execution — analyzes task dependencies, builds parallel/sequential wave plan, registers work in backlog via @producer, creates feature branch, executes agents wave by wave, synthesizes result |
| `/team-feature` | Orchestrate feature team: backend-developer + frontend-developer + qa-tester |
| `/team-backend` | Orchestrate backend team: lead-programmer + backend-developer + data-engineer + qa-tester |
| `/team-frontend` | Orchestrate frontend team: ux-designer + frontend-developer + ui-programmer + qa-tester |
| `/team-ui` | Orchestrate UI team: ux-designer + ui-programmer + accessibility-specialist |
| `/team-release` | Orchestrate release team: release-manager + qa-lead + devops-engineer + producer |
| `/launch-checklist` | Complete launch readiness validation across all departments |
| `/patch-notes` | Generate user-facing release notes from git history and internal data |
| `/sync-template` | Sync `.claude/` from an upstream template repo — shows diff, confirms, applies new/modified files without deleting local customizations |
| `/brainstorm` | Guided product or feature ideation |
| `/gate-check` | Validate readiness to advance between development phases (PASS/CONCERNS/FAIL) |
| `/map-systems` | Decompose a product concept into systems and dependencies |
| `/design-system` | Guided, section-by-section design authoring for a single feature system |

## GitNexus Code Intelligence

> Requires a GitNexus index for the target repo. Run `npx gitnexus analyze` from the repo root first.
> Check `.claude/memory/gitnexus-registry.md` for the list of currently indexed repos.

| Command | Purpose |
|---------|---------|
| `/gitnexus-guide` | Learn GitNexus concepts, tools, and graph schema — start here if unfamiliar |
| `/gitnexus-exploring` | Navigate and understand code architecture via the knowledge graph |
| `/gitnexus-impact-analysis` | Blast radius: what callers break if you change symbol X |
| `/gitnexus-pr-review` | Risk-assessed PR review — maps diff to affected flows, flags missing caller updates |
| `/gitnexus-refactoring` | Safe rename, extract, move via call graph — never use find-and-replace for multi-file renames |
| `/gitnexus-debugging` | Trace bugs and errors through execution flows |
| `/gitnexus-cli` | CLI reference: analyze, status, clean, wiki, list commands |
