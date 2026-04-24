---
name: api-design
description: "Defines REST and GraphQL API contracts including endpoints, request/response schemas, auth flows, and versioning strategy. Use when designing a new API, reviewing an API spec, or when the user mentions API design, OpenAPI, or endpoint contracts."
argument-hint: "[path-to-api-spec-or-route-files]"
user-invocable: true
allowed-tools: Read, Glob, Grep, WebSearch
effort: 3
when_to_use: "When designing or reviewing REST/GraphQL API contracts, endpoint naming, schemas, or versioning"
---

When this skill is invoked:

1. **Read the target API spec or route files** in full.

   For API design in an existing domain, SHOULD also inspect
   `docs/technical/API.md`, related `design/specs/*`, related
   `design/contracts/*` if present, and recent relevant ledger entries via
   `/trace-history`. This is advisory unless the change is an ADR,
   coordination-rule change, high-risk retry, or protocol removal.

2. **Identify the API type** (REST, GraphQL, WebSocket) and apply appropriate standards.

3. **Evaluate REST design quality** (if REST):
   - [ ] Resources use nouns, not verbs (`/users`, not `/getUsers`)
   - [ ] Correct HTTP methods (GET=read, POST=create, PUT/PATCH=update, DELETE=remove)
   - [ ] Consistent plural resource naming (`/users`, `/orders`)
   - [ ] Nested resources have max 2-3 levels of depth
   - [ ] Query parameters used for filtering, sorting, pagination (not in path)

4. **Evaluate request/response schemas**:
   - [ ] All inputs are validated and typed
   - [ ] Responses are consistent in structure (envelope format if used)
   - [ ] Pagination is consistent (cursor or page-based, not mixed)
   - [ ] Timestamps in ISO 8601 (UTC)
   - [ ] Money values in smallest currency unit (cents), not floats

5. **Evaluate authentication & authorization**:
   - [ ] Every endpoint has explicit auth requirement documented
   - [ ] Authorization is checked server-side, not just on the client
   - [ ] Sensitive data not leaked in error messages

6. **Evaluate error responses**:
   - [ ] Consistent error format (RFC 7807 Problem Details recommended)
   - [ ] HTTP status codes used correctly (400 for client errors, 500 for server)
   - [ ] Error messages are user-safe (no stack traces, SQL errors)

7. **Evaluate versioning & backward compatibility**:
   - [ ] Breaking changes require a version bump
   - [ ] Deprecation policy documented
   - [ ] Clients can negotiate API version

8. **Output the review**:

```
## API Design Review: [API/Endpoint Name]

### REST Design: [CLEAN / ISSUES FOUND]
[List specific issues with examples]

### Schema Quality: [CLEAN / ISSUES FOUND]
[List schema inconsistencies or problems]

### Auth & Security: [SECURE / ISSUES FOUND]
[List authentication and authorization issues]

### Error Handling: [CONSISTENT / ISSUES FOUND]
[List error response problems]

### Versioning: [HANDLED / UNADDRESSED]
[Notes on breaking change risk]

### Positive Observations
[What is well-designed]

### Required Changes
[Must-fix items before shipping]

### Suggestions
[Nice-to-have improvements]

### Verdict: [APPROVED / APPROVED WITH SUGGESTIONS / CHANGES REQUIRED]
```

## Protocol

- **Question**: Auto-starts from argument (path to API spec or route files); no clarification needed
- **Options**: Skip — single review path
- **Decision**: Skip — verdict is advisory
- **Draft**: Full review report shown in conversation only
- **Approval**: Skip — read-only; no files written

## Output

Deliver exactly:

- **Endpoint compliance score** (X/Y checks passing across naming, methods, validation, errors)
- **Security issues** with severity — CRITICAL / HIGH / MEDIUM (or "None")
- **Required changes** — must fix before shipping (or "None")
- **Verdict**: `APPROVED` / `APPROVED WITH SUGGESTIONS` / `CHANGES REQUIRED`
