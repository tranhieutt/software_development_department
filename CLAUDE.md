# Claude Code Software Development Department

Software development managed through specialized Claude Code subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

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

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

## Coding Standards

@.claude/docs/coding-standards.md

## Context Management

@.claude/docs/context-management.md
