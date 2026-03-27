# Claude Code Software Development Department

Software development managed through specialized Claude Code subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## Technology Stack

- **Language**: [CHOOSE: TypeScript / Python / Go / Java / other]
- **Frontend Framework**: [CHOOSE: React / Vue / Angular / Next.js / none]
- **Backend Framework**: [CHOOSE: Express / FastAPI / NestJS / Rails / other]
- **Database**: [CHOOSE: PostgreSQL / MySQL / MongoDB / other]
- **Deployment**: [CHOOSE: Docker / Kubernetes / Vercel / Railway / other]
- **CI/CD**: [CHOOSE: GitHub Actions / GitLab CI / CircleCI / other]

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
