# Claude Code Software Development Department

Software development managed through specialized Claude Code subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## 🚨 CRITICAL RULES (Must obey on every turn)
- **NO AUTOPILOT:** Every task follows **Question -> Options -> Decision -> Draft -> Approval**.
- **NEVER WRITE/EDIT DIRECTLY:** MUST ask "May I write this to [filepath]?" before using Write/Edit tools.
- **NO COMMITS WITHOUT PERMISSION:** Multi-file changes require explicit approval for the full changeset.
- **GIT SNAPSHOT WARNING:** The Internal Git status is a STALE SNAPSHOT! You MUST run `git status` or `git diff` via BashTool before making git operations or tracking git state.
- **SAFETY TIERS & RISK ASSESSMENT:** Before editing code or executing commands, assign a Risk Tier (Low: reversible; Medium: shared code, needs rollback plan; High: destructive/prod, requires explicit approval).
- **TOOL CONSTRAINTS (READ BEFORE WRITE/EDIT):** You MUST read a file's contents before writing to or editing it. For edits, strictly adhere to string replacement uniqueness constraints.
- **ANNOTATION PROTOCOL:** When you discover unexpected API behavior, undocumented caveats, version bugs, or non-obvious workarounds — **immediately** add a dated entry to `.claude/memory/annotations.md` via `/annotate`. Do NOT wait to be asked. Knowledge that is not persisted is lost.

## 🧭 Implicit Workflow Commands (Process Shields)
If the user invokes these short commands, or if the task context implies them, YOU MUST trigger the corresponding skill:
- **`/plan`**: ALWAYS trigger the `planning-and-task-breakdown` skill first for complex epics. Output an atomic markdown task checklist. **Do NOT write code yet.**
- **`/spec`**: ALWAYS trigger the `spec-driven-development` skill before writing logic for a task. Secure explicit blueprint/architecture approval from the user.
- **`/tdd`**: ALWAYS trigger the `test-driven-development` skill when writing the source. Write failing tests, check CMD outputs (🔴 RED), implement, and pass (🟢 GREEN). **Never claim success without terminal test logs.**

## Project Durable Memory

@.claude/memory/MEMORY.md

## Technology Stack

<!-- Replace each [not configured] line with your chosen value after running /start -->
- **Language**: [not configured] <!-- e.g. TypeScript / Python / Go / Java -->
- **Frontend Framework**: [not configured] <!-- e.g. React / Vue / Angular / Next.js / none -->
- **Backend Framework**: [not configured] <!-- e.g. Express / FastAPI / NestJS / Rails -->
- **Database**: [not configured] <!-- e.g. PostgreSQL / MySQL / MongoDB -->
- **Deployment**: [not configured] <!-- e.g. Docker / Kubernetes / Vercel / Railway -->
- **CI/CD**: [not configured] <!-- e.g. GitHub Actions / GitLab CI / CircleCI -->

> **First session?** If no stack has been configured yet, run `/start` to begin
> the guided onboarding flow.

## Project Structure

@.claude/docs/directory-structure.md

## Technical Preferences

@.claude/docs/technical-preferences.md

## Coordination Rules

@.claude/docs/coordination-rules.md

## Coding Standards

@.claude/docs/coding-standards.md

## Output & UX Utilities

@.claude/docs/utility-prompts.md

## Context Management

@.claude/docs/context-management.md

<!-- Deep-dive examples, misconceptions table, and startup order diagram:
     .claude/docs/context-management-guide.md (NOT injected — reference only) -->

## LLM Coding Behavior

@.claude/docs/llm-coding-behavior.md
