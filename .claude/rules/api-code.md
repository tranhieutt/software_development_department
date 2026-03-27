# API Code Standards

Applies to: `src/api/**`, `src/routes/**`, `src/controllers/**`, `src/handlers/**`

## Endpoint Design
- Resource names must be nouns in plural form (`/users`, not `/getUser`)
- HTTP methods must match semantics: GET (read), POST (create), PUT/PATCH (update), DELETE (remove)
- Endpoints nested no more than 3 levels deep
- Query parameters for filtering, sorting, pagination — not path parameters

## Request Validation
- ALL incoming input must be validated before processing
- Reject unknown fields (strict schema validation)
- Return 400 with a descriptive error if validation fails
- Log validation failures for observability

## Response Format
- Consistent JSON envelope: `{ data, error, meta }` (or project-standard format)
- HTTP status codes must be correct: 200/201/204 for success, 4xx for client errors, 5xx for server errors
- Errors follow RFC 7807 Problem Details: `{ type, title, status, detail }`
- Never expose stack traces, SQL errors, or internal paths in error responses

## Authentication & Authorization
- Every route must explicitly declare its auth requirement
- Authorization checked server-side on EVERY request — never trust client-side state
- API keys and tokens never logged in plaintext

## Versioning
- Breaking changes require a new API version (`/v2/...`)
- Deprecate endpoints before removing them
- Provide migration path in deprecation notice
