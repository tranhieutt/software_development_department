# Claude Code Software Development Department — Complete Workflow Guide

This guide walks through the complete workflow for using the Software Development Department agent architecture from project inception through to production release.

---

## Overview: How the Department Works

The department has **26 specialized agents** organized into three tiers:

- **Tier 1 (Leadership)**: `cto`, `technical-director`, `producer`
- **Tier 2 (Leads)**: `product-manager`, `lead-programmer`, `ux-designer`, `qa-lead`, `release-manager`
- **Tier 3 (Specialists)**: `frontend-developer`, `backend-developer`, `fullstack-developer`, `data-engineer`, `ai-programmer`, `network-programmer`, `tools-programmer`, `ui-programmer`, `ux-researcher`, `tech-writer`, `performance-analyst`, `devops-engineer`, `analytics-engineer`, `security-engineer`, `qa-tester`, `accessibility-specialist`, `prototyper`, `community-manager`

Every agent follows the same collaboration protocol:
1. **Ask** — understand the requirement before proposing
2. **Options** — present 2–4 approaches with trade-offs
3. **Decision** — you decide
4. **Draft** — show work before committing
5. **Approve** — nothing gets written without sign-off

---

## Phase 1: Project Initialization

### Step 1.1: Run `/start`

The `/start` skill detects where you are and routes to the right workflow:
- **New project with an idea** → brainstorm and PRD creation
- **Know what to build** → architecture and sprint planning
- **Existing project** → gap analysis and `/project-stage-detect`

### Step 1.2: Fill Out CLAUDE.md

Open `CLAUDE.md` and fill in the Technology Stack section:
```
Language: TypeScript
Frontend Framework: React / Next.js
Backend Framework: Express / FastAPI / NestJS
Database: PostgreSQL / MongoDB
Deployment: Docker / Vercel / Railway
CI/CD: GitHub Actions
```

This stack configuration is read by agents to give context-appropriate advice.

### Step 1.3: Create the PRD

Ask `product-manager` to create a Product Requirements Document:
```
Ask the product-manager agent to create a PRD for [your product idea],
using the template at .claude/docs/templates/product-requirements-document.md
```

The PRD should cover:
- Problem statement and target users
- Core features and acceptance criteria
- Non-goals and constraints
- Success metrics

---

## Phase 2: Architecture and Design

### Step 2.1: System Decomposition

Run `/map-systems` to decompose your product into components:
```
/map-systems
```

This creates `design/docs/systems-index.md` — a master list of all systems with their dependencies. Use it to understand what needs to be built and in what order.

### Step 2.2: API Design

For each backend service, run `/api-design`:
```
/api-design --service user-auth
```

The `lead-programmer` agent will:
- Define endpoint contracts (method, path, request/response schemas)
- Specify authentication and authorization requirements
- Define error formats and status codes
- Document rate limiting and versioning strategy

Store API contracts in `docs/api/`.

### Step 2.3: Database Schema Design

Run `/db-review` or ask `data-engineer` to design the schema:
```
Ask the data-engineer agent to design the database schema for [feature],
using the template at .claude/docs/templates/database-schema-design.md
```

The schema design should cover:
- Entity relationships (ERD)
- Index strategy
- Migration plan
- Data access patterns

Store schemas in `docs/database/`.

### Step 2.4: Architecture Decisions

For every significant technical decision, create an ADR:
```
/architecture-decision
```

The `technical-director` agent asks structured questions and produces an ADR in `docs/architecture/decisions/`. ADRs capture:
- The decision context and forces
- Options considered
- Decision made and rationale
- Consequences

---

## Phase 3: Sprint Planning

### Step 3.1: First Sprint

Once the PRD and architecture are in place, run:
```
/sprint-plan new
```

The `producer` agent:
1. Reviews the PRD and architecture docs
2. Creates user stories (using `user-story.md` template)
3. Estimates effort for each story
4. Creates `production/sprints/sprint-01.md` with assignments

### Step 3.2: Daily Sprint Management

```
/sprint-plan status
```

To update sprint progress, blockers, and remaining work.

---

## Phase 4: Feature Development

### Step 4.1: Full Feature Pipeline

For a complete feature from design to deployment:
```
/team-feature --feature "user authentication"
```

This orchestrates:
1. `product-manager` — confirms acceptance criteria from PRD
2. `lead-programmer` — designs API contracts and architecture
3. `ux-designer` — creates UI/UX flows (if UI involved)
4. `backend-developer` — implements API and business logic
5. `frontend-developer` — implements UI components
6. `qa-tester` — writes and executes test cases
7. `devops-engineer` — deploys to staging

### Step 4.2: Backend-Only Feature

```
/team-backend --feature "payment processing"
```

Orchestrates: `lead-programmer` + `backend-developer` + `data-engineer` + `security-engineer` + `qa-tester`

### Step 4.3: Frontend-Only Feature

```
/team-frontend --feature "dashboard redesign"
```

Orchestrates: `ux-designer` + `frontend-developer` + `ui-programmer` + `accessibility-specialist` + `qa-tester`

### Step 4.4: Individual Agent Work

You can always call agents directly:
```
Ask the backend-developer agent to implement an endpoint POST /api/v1/users
that creates a new user account. The spec is in docs/api/user-service.md.
```

---

## Phase 5: Code Review and Quality

### Step 5.1: Code Review

```
/code-review src/api/users.ts
```

The `lead-programmer` agent reviews for:
- Architecture and SOLID principles
- Security vulnerabilities
- Performance issues
- Test coverage
- Code style and standards

### Step 5.2: Security Review

```
Ask the security-engineer agent to review the authentication implementation
in src/api/auth/ for OWASP Top 10 vulnerabilities.
```

### Step 5.3: Accessibility Check

```
Ask the accessibility-specialist agent to audit the dashboard components
in src/frontend/dashboard/ for WCAG 2.1 AA compliance.
```

### Step 5.4: Performance Profiling

```
/perf-profile --target "API response time for /api/v1/users"
```

The `performance-analyst` agent measures, identifies bottlenecks, and recommends optimizations.

---

## Phase 6: Testing

### Step 6.1: Test Planning

```
Ask the qa-lead agent to create a test plan for the user authentication feature,
using the template at .claude/docs/templates/test-plan.md
```

### Step 6.2: Bug Reporting

When a bug is found:
```
/bug-report
```

The `qa-tester` agent creates a structured report with:
- Steps to reproduce
- Expected vs actual behavior
- Environment details
- Severity and priority

### Step 6.3: Technical Prototype / Spike

When a technical approach is uncertain:
```
/prototype --hypothesis "Can we implement real-time sync with WebSockets under 100ms latency?"
```

The `prototyper` agent builds a minimal throwaway PoC in `prototypes/` and reports findings.

---

## Phase 7: Release

### Step 7.1: Release Checklist

```
/release-checklist
```

The `release-manager` validates:
- All acceptance criteria met
- Tests passing
- Performance benchmarks met
- Security scan clear
- Documentation updated

### Step 7.2: Changelog

```
/changelog
```

The `tech-writer` generates a structured changelog from git history.

### Step 7.3: Release Pipeline

```
/team-release --version v1.0.0
```

Orchestrates:
1. `release-manager` — cuts release branch, validates checklist
2. `qa-lead` — runs final regression
3. `security-engineer` — final security scan
4. `performance-analyst` — confirms benchmarks
5. `devops-engineer` — builds and deploys artifacts
6. `tech-writer` — generates release notes
7. `community-manager` — drafts user-facing announcement

### Step 7.4: Launch Checklist

```
/launch-checklist
```

Comprehensive launch readiness validation covering infrastructure, monitoring, rollback plans, and support readiness.

---

## Phase 8: Post-Launch

### Step 8.1: Monitoring and Analytics

Ask `analytics-engineer`:
```
Ask the analytics-engineer agent to set up event tracking for the new authentication
flow and create a dashboard for key metrics: signup rate, login success rate, session duration.
```

### Step 8.2: Incident Response

If something goes wrong in production:
```
/hotfix --severity P0 --description "Authentication service returning 500 errors"
```

The emergency fix workflow bypasses normal sprint process with full audit trail.

For incident documentation:
```
Ask the technical-director agent to create an incident response doc
using the template at .claude/docs/templates/incident-response.md
```

### Step 8.3: Retrospective

```
/retrospective
```

The `producer` facilitates a structured retrospective capturing what worked, what didn't, and action items.

### Step 8.4: Tech Debt

```
/tech-debt
```

The `lead-programmer` scans the codebase for tech debt, classifies it, and produces a prioritized report.

---

## Collaboration Protocol Examples

### Example 1: Product Manager Defining a Feature

```
You: Ask the product-manager agent to write a user story for "password reset flow"

Agent: Before writing the user story, let me ask a few questions:
1. Should we support email-only reset, or also phone/SMS?
2. What is the token expiry time? (Common: 1 hour, 24 hours)
3. Do we need to invalidate all sessions on password reset?
4. Are there specific security requirements (e.g., rate limiting attempts)?

You: Email only, 1-hour expiry, invalidate all sessions, yes rate limit to 5 attempts per hour.

Agent: Here's the draft user story:

**User Story: Password Reset**
As a registered user who has forgotten my password,
I want to receive a secure reset link via email,
So that I can regain access to my account without contacting support.

**Acceptance Criteria:**
- [ ] User can request reset from login page with their email address
- [ ] System sends reset email within 30 seconds if email is registered
- [ ] Reset link expires after 1 hour and is single-use
- [ ] System rate-limits to 5 reset attempts per email per hour
- [ ] All existing sessions are invalidated upon successful password reset
- [ ] Reset link leads to a form requiring new password (min 8 chars, complexity rules)

May I write this to production/backlog/user-story-password-reset.md?
```

### Example 2: Lead Programmer Designing an API

```
You: Ask the lead-programmer agent to design the API for user authentication.

Agent: I'll design the authentication API. Before starting, I need to confirm:
1. Are we using JWTs or session cookies?
2. Should we support OAuth providers (Google, GitHub)?
3. What are the token expiry requirements?

You: JWTs with refresh tokens, no OAuth for now, access token 15 min, refresh token 7 days.

Agent: Here's the authentication API design:

**POST /api/v1/auth/register**
Request: { email, password, name }
Response 201: { user: { id, email, name }, accessToken, refreshToken }
Response 409: { error: "EMAIL_ALREADY_EXISTS" }

**POST /api/v1/auth/login**
Request: { email, password }
Response 200: { user: { id, email, name }, accessToken, refreshToken }
Response 401: { error: "INVALID_CREDENTIALS" }

**POST /api/v1/auth/refresh**
Request: { refreshToken }
Response 200: { accessToken, refreshToken }
Response 401: { error: "INVALID_REFRESH_TOKEN" }

**POST /api/v1/auth/logout**
Headers: Authorization: Bearer <accessToken>
Response 200: { success: true }

All responses use consistent error format: { error: string, message?: string }

May I write this to docs/api/auth-service.md?
```

---

## Quick Reference: Agent Selection

| Task | Primary Agent |
|------|--------------|
| Product requirements | `product-manager` |
| Architecture decisions | `technical-director` |
| Sprint planning | `producer` |
| API design | `lead-programmer` |
| Frontend components | `frontend-developer` |
| Backend services | `backend-developer` |
| Database schema | `data-engineer` |
| CI/CD pipelines | `devops-engineer` |
| Security review | `security-engineer` |
| Test strategy | `qa-lead` |
| Test execution | `qa-tester` |
| Performance analysis | `performance-analyst` |
| UX flows and wireframes | `ux-designer` |
| User research | `ux-researcher` |
| API documentation | `tech-writer` |
| Technical PoC | `prototyper` |
| Release management | `release-manager` |
| Analytics and metrics | `analytics-engineer` |
| Accessibility | `accessibility-specialist` |
| User communications | `community-manager` |
