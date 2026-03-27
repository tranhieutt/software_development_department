# API Design Document

**API Name**: [Name of API or feature]
**Author**: [Your name]
**Status**: Draft | In Review | Approved
**Version**: v1
**Date**: [YYYY-MM-DD]

---

## Overview

[1-2 sentences: What does this API do? What system does it belong to?]

## Base URL

```
/api/v1/[resource]
```

## Authentication

- **Method**: [Bearer JWT / API Key / OAuth2 / None]
- **Header**: `Authorization: Bearer <token>`

---

## Endpoints

### GET /[resource]

**Description**: [What this endpoint returns]

**Auth required**: Yes / No

**Query Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | integer | No | 1 | Page number |
| `limit` | integer | No | 20 | Items per page |
| `sort` | string | No | `created_at` | Sort field |

**Success Response** `200 OK`:
```json
{
  "data": [
    {
      "id": "uuid",
      "field": "value",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

**Error Responses**:

| Status | Code | Description |
|--------|------|-------------|
| 401 | `UNAUTHORIZED` | Missing or invalid token |
| 403 | `FORBIDDEN` | Insufficient permissions |

---

### POST /[resource]

**Description**: [What this endpoint creates]

**Auth required**: Yes / No

**Request Body**:
```json
{
  "field": "value"
}
```

**Validation**:
- `field`: required, string, max 255 chars

**Success Response** `201 Created`:
```json
{
  "data": {
    "id": "uuid",
    "field": "value",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

---

## Error Format

All errors follow RFC 7807 Problem Details:

```json
{
  "type": "https://api.example.com/errors/validation-error",
  "title": "Validation Error",
  "status": 400,
  "detail": "The 'email' field must be a valid email address."
}
```

## Rate Limiting

| Tier | Limit |
|------|-------|
| Default | 100 req/min |
| Authenticated | 1000 req/min |

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| v1 | [Date] | Initial design |
