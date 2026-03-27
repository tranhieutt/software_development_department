---
name: feature-spec
description: "Guided, section-by-section feature specification authoring for a single software feature or module. Gathers context from existing docs, walks through each required section collaboratively, cross-references dependencies, and writes incrementally to file."
argument-hint: "<feature-name> (e.g., 'user-authentication', 'payment-processing', 'notification-service')"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion, TodoWrite
---

When this skill is invoked:

## 1. Parse Arguments & Validate

A feature name argument is **required**. If missing, fail with:
> "Usage: `/feature-spec <feature-name>` — e.g., `/feature-spec user-authentication`
> Run `/brainstorm` first to generate a product concept, then use this skill
> to write individual feature specifications."

Normalize the feature name to kebab-case for the filename (e.g., "user authentication"
becomes `user-authentication`).

---

## 2. Gather Context (Read Phase)

Read all relevant context **before** asking the user anything. This is the skill's
primary advantage over ad-hoc writing — it arrives informed.

### 2a: Required Reads

- **Product concept**: Read `design/docs/product-concept.md` — fail if missing:
  > "No product concept found. Run `/brainstorm` first."
- **Systems index**: Read `design/docs/systems-index.md` — warn if missing:
  > "No systems index found. Consider running `/map-systems` to map your features.
  > Continuing without it — you'll need to define dependencies manually."
- **Target feature**: Find the feature in the index. If not listed, warn:
  > "[feature-name] is not in the systems index. Would you like to add it, or
  > spec it as a standalone feature?"

### 2b: Dependency Reads

From the systems index, identify:
- **Upstream dependencies**: Features/services this one depends on. Read their specs if they
  exist (these contain contracts this feature must respect).
- **Downstream dependents**: Features/services that depend on this one. Read their specs if
  they exist (these contain expectations this feature must satisfy).

For each dependency spec that exists, extract and hold in context:
- API contracts (endpoints, request/response schemas)
- Data models shared between features
- Auth/permission requirements
- Error handling contracts

### 2c: Optional Reads

- **Product pillars**: Read `design/docs/product-pillars.md` if it exists
- **Existing spec**: Read `design/docs/specs/[feature-name].md` if it exists (resume, don't
  restart from scratch)
- **Related specs**: Glob `design/docs/specs/*.md` and read any that are thematically related
  (e.g., if speccing "notifications", also read "user-preferences" if it exists)
- **CLAUDE.md**: Read to understand the current tech stack (language, framework, database)

### 2d: Present Context Summary

Before starting spec work, present a brief summary to the user:

> **Specifying: [Feature Name]**
> - Priority: [from index] | Epic: [parent epic from index]
> - Depends on: [list, noting which have specs vs. unspecced]
> - Depended on by: [list, noting which have specs vs. unspecced]
> - Existing contracts to respect: [key constraints from dependency specs]
> - Tech stack: [from CLAUDE.md — affects technical design choices]

If any upstream dependencies are unspecced, warn:
> "[dependency] doesn't have a spec yet. We'll need to make assumptions about
> its interface. Consider speccing it first, or we can define the expected
> contract and flag it as provisional."

Use `AskUserQuestion`:
- "Ready to start speccing [feature-name]?"
  - Options: "Yes, let's go", "Show me more context first", "Spec a dependency first"

---

## 3. Create File Skeleton

Once the user confirms, **immediately** create the spec file with empty section
headers. This ensures incremental writes have a target.

```markdown
# [Feature Name]

> **Status**: In Design
> **Author**: [user + agents]
> **Last Updated**: [today's date]
> **Priority**: [from index or TBD]
> **Implements Pillar**: [from context]

## Overview

[To be specified]

## User Stories

[To be specified]

## Acceptance Criteria

[To be specified]

## Technical Design

### API Contracts

[To be specified]

### Data Models

[To be specified]

### State & Flow

[To be specified]

### Business Rules

[To be specified]

## Edge Cases & Error Handling

[To be specified]

## Dependencies

[To be specified]

## Configuration & Feature Flags

[To be specified]

## Non-Functional Requirements

[To be specified]

## Security Considerations

[To be specified]

## Testing Strategy

[To be specified]

## Open Questions

[To be specified]
```

Ask: "May I create the skeleton file at `design/docs/specs/[feature-name].md`?"

After writing, update `production/session-state/active.md` with:
- Task: Speccing [feature-name]
- Current section: Starting (skeleton created)
- File: design/docs/specs/[feature-name].md

---

## 4. Section-by-Section Specification

Walk through each section in order. For **each section**, follow this cycle:

### The Section Cycle

```
Context → Questions → Options → Decision → Draft → Approval → Write
```

1. **Context**: State what this section needs to contain, and surface any relevant
   decisions from dependency specs that constrain it.

2. **Questions**: Ask clarifying questions specific to this section. Use
   `AskUserQuestion` for constrained questions, conversational text for open-ended
   exploration.

3. **Options**: Where the section involves design choices (not just documentation),
   present 2-4 approaches with pros/cons. Explain reasoning in conversation text,
   then use `AskUserQuestion` to capture the decision.

4. **Decision**: User picks an approach or provides custom direction.

5. **Draft**: Write the section content in conversation text for review. Flag any
   provisional assumptions about unspecced dependencies.

6. **Approval**: Ask "Approve this section, or would you like changes?"

7. **Write**: Use the Edit tool to replace the `[To be specified]` placeholder with
   the approved content. Confirm the write.

After writing each section, update `production/session-state/active.md` with the
completed section name.

### Section-Specific Guidance

---

### Section A: Overview

**Goal**: One paragraph a new team member could read and understand without context.

**Questions to ask**:
- What does this feature do in one sentence?
- Who uses it? (Internal users, end users, other services, admins?)
- Why does this feature exist — what problem does it solve?
- What would the product lose without this feature?

**Cross-reference**: Check that the description aligns with how the systems index
describes it. Flag discrepancies.

---

### Section B: User Stories

**Goal**: Structured "As a [role], I want [action], so that [outcome]" statements
covering all user types and key scenarios.

**Questions to ask**:
- Who are all the roles that interact with this feature? (End user, admin, service?)
- For each role, what's their primary goal?
- What are the secondary or edge-case user goals?

**Format to use**:
```
As a [role], I want to [action], so that [outcome].

Acceptance Criteria:
- Given [context], when [action], then [expected result]
- Given [edge case], when [action], then [expected result]
```

**Agent delegation**: For complex user-facing features, use the Task tool to delegate
to `ux-designer` for user flow analysis before writing user stories.

---

### Section C: Acceptance Criteria

**Goal**: Unambiguous, testable conditions that prove the feature works as specified.
QA should be able to write tests directly from these.

**Questions to ask**:
- What's the minimum set of behaviors that prove this feature is working?
- What does "done" look like for each user story?
- What are the performance benchmarks? (Response time, throughput)
- What security behaviors must be verified?

**Format to use**:
```
[ ] Given [precondition], when [action], then [result]
[ ] Error case: when [invalid condition], system returns [specific error]
[ ] Performance: [endpoint] responds in < [N]ms under [load]
```

---

### Section D: Technical Design

**Goal**: Enough technical detail that developers can implement without ambiguity.
Split into sub-sections:

#### API Contracts

- Endpoints (method, path, auth required)
- Request schema (body, query params, headers)
- Response schema (success and error shapes)
- Rate limiting rules

**Questions to ask**:
- Is this REST, GraphQL, or internal RPC?
- What authentication/authorization is required?
- What's the error response format?

#### Data Models

- Entity definitions with field names, types, constraints
- Database table/collection structure
- Indexes required for query performance
- Relationships to other entities

**Questions to ask**:
- What data needs to be persisted?
- What are the cardinality relationships? (one-to-many, many-to-many)
- What fields need indexes based on query patterns?

#### State & Flow

- State machine diagram if the feature has states
- Happy path walk-through step by step
- Async flows (background jobs, webhooks, events)

**Questions to ask**:
- Does this feature have states? (e.g., pending/active/expired)
- Are there async operations? (email sending, background processing)
- What events does this feature emit that other features might consume?

#### Business Rules

- Validation rules with specific constraints
- Calculation logic with formulas
- Authorization rules (who can do what)
- Rate limits, quotas, or throttling rules

**Agent delegation**: For complex business rules, use the Task tool to delegate to
`product-manager` for requirements clarification, or `backend-developer` for
feasibility assessment.

**Cross-reference**: For each API contract listed, verify it matches what dependency
specs expect. If a dependency spec says "user ID is a UUID" and this feature
assumes integer IDs, flag the conflict.

---

### Section E: Edge Cases & Error Handling

**Goal**: Explicitly handle unusual situations so they don't become production bugs.

**Questions to ask**:
- What happens with empty/null inputs?
- What happens at rate limits or quota boundaries?
- What happens when a dependency is unavailable?
- What happens with concurrent requests for the same resource?
- What data inconsistencies could occur and how are they resolved?

**Format to use**:
```
| Scenario | Input Condition | Expected Behavior |
|---|---|---|
| Empty input | [field] is null | Return 400 with message "..." |
| Rate limited | > N requests/min | Return 429 with Retry-After header |
| Dep unavailable | [service] times out | Return 503, log error, alert |
```

**Agent delegation**: For security-sensitive edge cases, delegate to `security-engineer`
via the Task tool.

**Cross-reference**: Check edge cases against dependency specs. If an upstream service
can return a specific error, this feature must handle it.

---

### Section F: Dependencies

**Goal**: Map every service, library, and feature connection with direction and nature.

This section is partially pre-filled from the context gathering phase. Present the
known dependencies and ask:
- Are there dependencies not captured in the systems index?
- For each dependency, what's the specific contract (API, events, shared DB)?
- Which dependencies are hard (feature cannot work without it) vs. soft
  (degraded experience, but functional)?

**Cross-reference**: This section must be bidirectionally consistent. If this feature
depends on "AuthService", then the AuthService spec should list this feature as a
dependent. Flag one-directional dependencies.

---

### Section G: Configuration & Feature Flags

**Goal**: Every environment-specific value and feature toggle, with safe defaults.

**Questions to ask**:
- What values should be different between dev/staging/prod?
- Should this feature be behind a feature flag for gradual rollout?
- What configuration would you want to change without a code deploy?
- For each config value, what's the impact of setting it too high? Too low?

**Format to use**:
```
| Config Key | Type | Default | Description |
|---|---|---|---|
| FEATURE_ENABLED | bool | false | Gates entire feature |
| TIMEOUT_MS | int | 3000 | Upstream call timeout |
| MAX_RETRIES | int | 3 | Retry attempts on failure |
```

---

### Section H: Non-Functional Requirements

**Goal**: Measurable quality targets beyond "it works".

**Questions to ask**:
- What's the target response time (p50, p95, p99)?
- What requests per second must it handle?
- What's the acceptable error rate in production?
- What are the data retention or compliance requirements?
- What availability SLA does this feature need? (99.9%? 99.99%?)

**Agent delegation**: Delegate to `performance-analyst` for performance requirements
and `security-engineer` for security/compliance requirements.

---

### Section I: Security Considerations

**Goal**: Explicit security requirements so they aren't afterthoughts.

**Questions to ask**:
- What user data does this feature handle? (PII, payment data, credentials?)
- What are the authorization rules? (Who can read/write/delete?)
- Are there injection risks? (SQL, command, template injection)
- Does this feature log sensitive data? (Must not log passwords, tokens, PII)
- What audit trail is needed?

**Agent delegation**: Always delegate to `security-engineer` for this section on
any feature involving authentication, payments, or user data.

---

### Section J: Testing Strategy

**Goal**: Testable plan covering what types of tests are needed and at what level.

**Questions to ask**:
- What are the critical paths that need unit tests?
- What integration tests are needed to verify dependency contracts?
- Are there scenarios that need end-to-end tests?
- What load/performance tests are needed?

**Format to use**:
```
| Test Type | What to Cover | Tool |
|---|---|---|
| Unit | Business logic, validations | Jest/Pytest/... |
| Integration | API contracts, DB queries | Supertest/... |
| E2E | Critical user journeys | Playwright/... |
| Load | Peak throughput scenarios | k6/... |
```

---

### Optional Section: Open Questions

Capture anything unresolved during speccing. Each question should have:
- The question itself
- Who owns answering it
- Target resolution date

---

## 5. Post-Specification Validation

After all sections are written:

### 5a: Self-Check

Read back the complete spec from file (not from conversation memory — the file is
the source of truth). Verify:
- All required sections have real content (not placeholders)
- API contracts are complete (method, path, request, response, errors)
- Acceptance criteria are testable as written
- Edge cases have explicit resolutions
- Dependencies are listed bidirectionally
- Security section is not empty for user-facing features

### 5b: Offer Design Review

Present a completion summary:

> **Spec Complete: [Feature Name]**
> - Sections written: [list]
> - Provisional assumptions: [list any assumptions about unspecced dependencies]
> - Cross-spec conflicts found: [list or "none"]
> - Security review needed: [yes/no with reason]

Use `AskUserQuestion`:
- "Run `/design-review` now to validate the spec?"
  - Options: "Yes, run review now", "I'll review it myself first", "Skip — move to sprint planning"

### 5c: Update Systems Index

After the spec is complete (and optionally reviewed):

- Read the systems index
- Update the target feature's row:
  - Status → "Specced" / "In Review" / "Approved"
  - Spec: link to `design/docs/specs/[feature-name].md`
- Update the Progress Tracker counts

Ask: "May I update the systems index at `design/docs/systems-index.md`?"

### 5d: Update Session State

Update `production/session-state/active.md` with:
- Task: [feature-name] spec
- Status: Complete (or In Review)
- File: design/docs/specs/[feature-name].md
- Next: [suggest next feature from priority order]

### 5e: Suggest Next Steps

Use `AskUserQuestion`:
- "What's next?"
  - Options:
    - "Spec next feature ([next-in-priority])" — if unspecced features remain
    - "Fix review findings" — if design-review flagged issues
    - "Plan sprint for this feature" — run `/sprint-plan`
    - "Start implementation" — delegate to `lead-programmer`
    - "Stop here for this session"

---

## 6. Specialist Agent Routing

This skill delegates to specialist agents for domain expertise. The main session
orchestrates the overall flow; agents provide expert content.

| Feature Category | Primary Agent | Supporting Agent(s) |
|---|---|---|
| REST API, backend service | `backend-developer` | `security-engineer` (auth), `technical-director` (architecture) |
| User-facing UI feature | `frontend-developer` | `ux-designer` (flows), `accessibility-specialist` (a11y) |
| Full-stack feature | `fullstack-developer` | `ux-designer` (UX), `security-engineer` (security) |
| Auth, permissions, security | `security-engineer` | `backend-developer` (implementation), `technical-director` (strategy) |
| Data pipeline, analytics | `data-engineer` | `analytics-engineer` (metrics), `backend-developer` (API) |
| ML/AI feature | `ai-programmer` | `backend-developer` (serving), `data-engineer` (pipeline) |
| Performance-critical path | `performance-analyst` | `backend-developer`, `devops-engineer` (infra) |
| DevOps, CI/CD, infra | `devops-engineer` | `technical-director` (architecture), `security-engineer` |
| User research, UX flows | `ux-designer` | `ux-researcher` (validation), `product-manager` (requirements) |

**When delegating via Task tool**:
- Provide: feature name, product concept summary, dependency spec excerpts, the specific
  section being worked on, and what question needs expert input
- The agent returns analysis/proposals to the main session
- The main session presents the agent's output to the user via `AskUserQuestion`
- The user decides; the main session writes to file
- Agents do NOT write to files directly — the main session owns all file writes

---

## 7. Recovery & Resume

If the session is interrupted (compaction, crash, new session):

1. Read `production/session-state/active.md` — it records the current feature and
   which sections are complete
2. Read `design/docs/specs/[feature-name].md` — sections with real content are done;
   sections with `[To be specified]` still need work
3. Resume from the next incomplete section — no need to re-discuss completed ones

This is why incremental writing matters: every approved section survives any disruption.

---

## Collaborative Protocol

This skill follows the collaborative design principle at every step:

1. **Question → Options → Decision → Draft → Approval** for every section
2. **AskUserQuestion** at every decision point (Explain → Capture pattern):
   - Phase 2: "Ready to start, or need more context?"
   - Phase 3: "May I create the skeleton?"
   - Phase 4 (each section): Clarifying questions, approach options, draft approval
   - Phase 5: "Run design review? Update systems index? What's next?"
3. **"May I write to [filepath]?"** before the skeleton and before each section write
4. **Incremental writing**: Each section is written to file immediately after approval
5. **Session state updates**: After every section write
6. **Cross-referencing**: Every section checks existing specs for conflicts
7. **Specialist routing**: Complex sections get expert agent input, presented to
   the user for decision — never written silently

**Never** auto-generate the full spec and present it as a fait accompli.
**Never** write a section without user approval.
**Never** contradict an existing approved spec without flagging the conflict.
**Always** show where decisions come from (dependency specs, pillars, user choices).
