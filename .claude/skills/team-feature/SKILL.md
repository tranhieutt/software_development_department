---
name: team-feature
description: "Orchestrate a cross-functional feature team: coordinates product-manager, ux-designer, frontend-developer, backend-developer, and qa-tester to deliver a full feature end-to-end from specification to tested implementation."
argument-hint: "[feature description or user story]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---

When this skill is invoked, orchestrate the feature team through a structured delivery pipeline.

**Decision Points:** At each phase transition, use `AskUserQuestion` to present
the user with the subagent's proposals as selectable options. Write the agent's
full analysis in conversation, then capture the decision with concise labels.
The user must approve before moving to the next phase.

## Team Composition
- **product-manager** — Feature scope, user stories, acceptance criteria
- **ux-designer** — User flows, wireframes, interaction design
- **backend-developer** — API design and implementation
- **frontend-developer** — UI components and client-side integration
- **qa-tester** — Test planning and validation

## How to Delegate

Use the Task tool to spawn each team member as a subagent:
- `subagent_type: product-manager`
- `subagent_type: ux-designer`
- `subagent_type: backend-developer`
- `subagent_type: frontend-developer`
- `subagent_type: qa-tester`

Always provide full context in each agent's prompt (feature requirements, existing patterns, API conventions). Launch independent agents in parallel where the pipeline allows (e.g., backend + UX design can proceed in parallel after spec is approved).

## Pipeline

### Phase 1: Feature Specification
Delegate to **product-manager**:
- Write the user story and acceptance criteria
- Define out-of-scope explicitly
- Identify success metrics
- Output: PRD or user story with acceptance criteria

### Phase 2: Design (parallel)
Launch in parallel:
- **ux-designer**: User flow, wireframes, interaction spec for the feature
- **backend-developer**: API contract design (endpoints, request/response schemas)

Both must complete before Phase 3.

### Phase 3: Review Designs
Use `AskUserQuestion` to get approval on:
- UX flow and wireframes
- API contract

Iterate until approved.

### Phase 4: Implementation (parallel where possible)
- **backend-developer**: Implement approved API endpoints and business logic
- **frontend-developer**: Implement UI components (can start with mock data if backend not ready)

Once backend is done, frontend-developer integrates with real API.

### Phase 5: QA
Delegate to **qa-tester**:
- Test against acceptance criteria
- Cross-browser/cross-device testing if relevant
- Regression testing on adjacent features
- Output: Test report with pass/fail per acceptance criterion

### Phase 6: Handoff
- Address QA findings
- Update documentation if needed (delegate to tech-writer)
- Confirm feature is ready for release review (`/gate-check`)

## Output
A summary covering: acceptance criteria coverage, API status, UI status, test results, and any outstanding items.
