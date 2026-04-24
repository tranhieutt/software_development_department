# API Reference

> Purpose: Implemented API reference for SDD-managed projects.
> Status: Skeleton created for Sprint 0.5. Endpoint inventory is not populated yet.
> Owner: `backend-developer`
> Source of truth: Runtime implementation after review; stable pre-implementation
> contracts must be reflected here after implementation.

---

## 1. Scope

This file documents API surfaces that exist in the implementation. It is not a
proposal document and does not replace feature specs, ADRs, or pre-implementation
contracts.

Use the source-of-truth rule:

```text
Spec explains why.
Contract locks what to build.
API.md documents what exists.
ADR decides what must remain true.
```

## 2. Endpoint Index

| Method | Path | Status | Auth | Request | Response | Owner | Source |
| --- | --- | --- | --- | --- | --- | --- | --- |
| _No implemented endpoints documented yet._ | | | | | | | |

Status values:

| Status | Meaning |
| --- | --- |
| `implemented` | Endpoint exists in reviewed implementation and is safe to consume. |
| `deprecated` | Endpoint still exists but has a replacement or removal path. |
| `removed` | Endpoint no longer exists; keep entry only when removal history matters. |

## 3. Endpoint Template

Use this section template when documenting an implemented endpoint.

````markdown
### METHOD /path

**Status:** implemented | deprecated | removed
**Owner:** backend-developer
**Implemented in:** `path/to/source-file`
**Tests:** `path/to/test-file`
**Related spec:** `design/specs/...`
**Related contract:** `design/contracts/...` or `none`

#### Authentication

[Auth requirement and authorization boundary.]

#### Request

```json
{
  "field": "value"
}
```

#### Response

```json
{
  "field": "value"
}
```

#### Errors

| Status | Code | Meaning |
| --- | --- | --- |
| 400 | `invalid_request` | Request failed validation. |

#### Deprecation

[Replacement endpoint, timeline, or `Not deprecated`.]
````

## 4. Schema Conventions

- Use JSON request and response examples unless the endpoint uses another format.
- Use ISO 8601 UTC timestamps, for example `2026-04-24T00:00:00Z`.
- Use stable field names in `snake_case` or the convention already established by
  the implementation; do not mix conventions within one API surface.
- Document nullable fields explicitly.
- Document pagination, sorting, and filtering parameters in the endpoint section.
- Money values must use the smallest currency unit when applicable.

## 5. Authentication and Authorization

Each endpoint entry must state:

- Whether authentication is required.
- Which actor or role is authorized.
- Whether authorization is enforced server-side.
- Whether any sensitive data is intentionally omitted from the response.

## 6. Error Conventions

Each endpoint entry must document expected client-visible errors.

Recommended shape:

```json
{
  "error": {
    "code": "invalid_request",
    "message": "Request failed validation."
  }
}
```

Do not expose stack traces, SQL errors, tokens, secrets, or internal file paths in
client-visible error examples.

## 7. Deprecation Policy

When an endpoint is deprecated:

1. Mark the endpoint status as `deprecated`.
2. Document the replacement endpoint or migration path.
3. Document the removal condition or review date.
4. Keep implementation, tests, and this reference aligned until removal.

## 8. Update Rules

Update this file when:

- A reviewed implementation adds, changes, deprecates, or removes an endpoint.
- A stable contract moves to `implemented`.
- Runtime behavior differs from this reference after review.

Do not update this file to describe proposed behavior. Proposed API behavior
belongs in `design/specs/*`, `design/contracts/*`, or an ADR depending on scope.
