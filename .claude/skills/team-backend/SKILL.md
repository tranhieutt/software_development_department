---
name: team-backend
description: "Orchestrate the backend team: coordinates technical-director, backend-developer, data-engineer, and security-engineer to design, implement, and review a backend system or API end-to-end."
argument-hint: "[backend feature or system description]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---

When this skill is invoked, orchestrate the backend team through a structured delivery pipeline.

**Decision Points:** At each phase, use `AskUserQuestion` to get user approval before proceeding.

## Team Composition
- **technical-director** — Architecture review and approval
- **backend-developer** — API and service implementation
- **data-engineer** — Schema design and migrations
- **security-engineer** — Security review

## Pipeline

### Phase 1: Architecture Design
Delegate to **technical-director**:
- Review the system requirements
- Propose architecture: service boundaries, data flows, technology choices
- Identify risks and cross-cutting concerns
- Output: Architecture proposal for approval

### Phase 2: Schema Design
Delegate to **data-engineer**:
- Design database schema based on approved architecture
- Write migration scripts (up and down)
- Define indexes and constraints
- Output: Schema design doc + migration files for review

### Phase 3: API Contract Design
Delegate to **backend-developer**:
- Define REST/GraphQL endpoint contracts
- Specify request/response schemas and error codes
- Define authentication requirements per endpoint
- Output: API contract for frontend team to build against

### Phase 4: Implementation
Delegate to **backend-developer**:
- Implement approved endpoints
- Apply approved schema migrations
- Write unit and integration tests
- Output: Implemented and tested backend

### Phase 5: Security Review (parallel with implementation where possible)
Delegate to **security-engineer**:
- Review auth and authorization logic
- Check for injection vulnerabilities, insecure data exposure
- Validate input sanitization
- Output: Security review report

### Phase 6: Integration
- Address security findings
- Confirm API is ready for frontend integration
- Run `/db-review` and `/api-design` checks

## Output
Summary covering: architecture decision, schema status, API contract, test coverage, and security review result.
