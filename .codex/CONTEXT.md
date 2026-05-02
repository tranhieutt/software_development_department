# Codex Session Context

> This file contains the critical context that Claude Code auto-injects via
> `@.claude/` syntax but Codex cannot. Read this file at the start of every
> Codex session in this repository.
>
> Full source files are listed below — consult them when depth is needed.

---

## 1. Coding Standards (from `.claude/docs/coding-standards.md`)

- All code must include doc comments on public APIs
- Every system must have a corresponding architecture decision record in `docs/architecture/`
- Configuration values must be data-driven (external config files), never hardcoded
- Secrets and environment variables follow `.claude/rules/secrets-config.md`
- All public methods must be unit-testable (dependency injection over singletons)
- Commits must reference the relevant design document or task ID
- **Verification-driven development**: Write tests first when adding new features or systems.
  For UI changes, verify with screenshots. Compare expected output to actual output
  before marking work complete.
- **Defensive external API calls**: Every call to an external service MUST be wrapped
  in `try/catch` with a meaningful fallback or retry. Never assume external APIs will
  return the expected shape.
- **ESM/CJS compatibility check**: Before adding any npm dependency, verify its module
  system matches the project. Pin exact versions for core libraries.

### Design Document Standards

- All design docs use Markdown
- Each feature or system has a dedicated spec in `design/specs/`
- Documents must include 8 required sections: Overview, User Value, Detailed
  Requirements, Formulas/Algorithms, Edge Cases, Dependencies, Configuration
  Parameters, Acceptance Criteria

### Fullstack Development Patterns

- **Vertical Slice First**: Implement the smallest functional slice first.
- **Contract Enforcement**: Define interface between frontend and backend before writing code.
- **E2E Integration Verification**: Task is "Integration Complete" only when data flows
  correctly from database to UI.

---

## 2. Coordination Rules (from `.claude/docs/coordination-rules.md`)

### Agent Roles

- **Coordinator**: Orchestrates tasks, delegates to specialist agents, merges results.
- **Specialist Agents**: Each owns a domain (frontend, backend, infra, testing, docs).
  Stay in lane — don't modify files outside your domain.

### Handoff Protocol

1. Before starting work, check if another agent is touching overlapping files.
2. After completing a task, commit with a descriptive message and update shared status.
3. Before merging, run conflict checks against other agents' recent commits.

### Conflict Resolution

- **File conflicts**: Last-write-wins by default; coordinator arbitrates if both agents need the same file.
- **Scope conflicts**: Coordinator defines explicit file ownership per task.
- Never force-push or rebase another agent's branch.

---

## 3. Technical Preferences (from `.claude/docs/technical-preferences.md`)

### Code Style

- **Language defaults**: TypeScript (strict mode), Python 3.10+, Go 1.21+
- **Formatting**: Prettier for JS/TS, Black for Python, gofmt for Go
- **Naming**: camelCase for variables/functions, PascalCase for classes/interfaces, kebab-case for files
- **Error handling**: Never swallow exceptions silently. Log context and propagate meaningful errors.
- **Import ordering**: External packages first, then internal modules, then relative imports

### Architecture Preferences

- Prefer composition over inheritance
- Use dependency injection for testability
- Prefer immutable data structures where practical
- Keep functions small and focused (single responsibility)
- Prefer explicit over implicit behavior
- Database: use parameterized queries, never raw string interpolation

### Git Conventions

- Commit messages: conventional commits format (`feat:`, `fix:`, `docs:`, `refactor:`)
- Branch naming: `<type>/<short-description>` (e.g., `feat/user-auth`, `fix/login-bug`)
- PR descriptions must link to the relevant task or spec
- No direct commits to main — always use a branch and PR

---

## 4. Durable Memory (from `.claude/memory/MEMORY.md`)

> MEMORY.md is a living file. The full version at `.claude/memory/MEMORY.md`
> should be consulted for current state. This section captures the stable
> structure only.

### Memory Architecture

- **Tier 1**: `MEMORY.md` — 50-line index, keyword triggers, session pointers
- **Tier 2**: `.claude/memory/*.md` — Topic files (annotations, tech decisions, role context)
- **Tier 3**: `.claude/memory/archive/` — Cold storage (sessions, decisions, dreams)
- **Tier 4**: MCP Supermemory — Semantic recall across all sessions (external)
- **Tier 5**: `CLAUDE.md` @include chain — Static universal context, always in prompt

### Loading Protocol

- Before loading any Tier 2 file, pass a 3-Question Relevance Gate:
  1. Actual need?
  2. Timing right?
  3. Subset sufficient?
- Hard limits: max 3 files per session, stop loading if context < 30%

---

## 5. SDD Lifecycle Quick Reference (from `docs/technical/SDD_LIFECYCLE_MAP.md`)

| Phase | Goal | Primary Skills | Exit Evidence |
|---|---|---|---|
| DEFINE | Decide what to build | `brainstorm`, `spec-driven-development`, `deep-interview` | Approved intent or spec |
| PLAN | Turn intent into tasks | `planning-and-task-breakdown`, `vertical-slicing` | Task list with acceptance criteria |
| BUILD | Make the approved change | `test-driven-development`, domain skills | RED/GREEN evidence |
| VERIFY | Prove the exact claim | `verification-before-completion`, `systematic-debugging` | Fresh test/build/lint evidence |
| REVIEW | Check quality and safety | `code-review`, `security-audit`, `design-review` | Findings classified and resolved |
| SHIP | Package and release safely | `commit`, `pr-writer`, `changelog` | User-approved commit/push |

---

## References

- Full coding standards: `.claude/docs/coding-standards.md`
- Full coordination rules: `.claude/docs/coordination-rules.md`
- Full technical preferences: `.claude/docs/technical-preferences.md`
- Full memory state: `.claude/memory/MEMORY.md`
- Full lifecycle map: `docs/technical/SDD_LIFECYCLE_MAP.md`
- Claude-Codex operating model: `docs/technical/CLAUDE_CODEX_OPERATING_MODEL.md`
