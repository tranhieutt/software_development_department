# Example Session: Designing a User Authentication API

**Context:** Starting a new API feature. PRD exists in `design/docs/user-auth-prd.md`.

**Goal:** Design the authentication API endpoints.

---

> **User:** Ask the lead-programmer agent to design the authentication API for our app. The requirements are in design/docs/user-auth-prd.md.

**Agent (lead-programmer):**
> I've read `design/docs/user-auth-prd.md`. Before finalizing the API design, I have a few questions:
>
> 1. **Token strategy**: JWT (stateless) or server-side sessions? Each has tradeoffs:
>    - JWT: Easy to scale, harder to revoke immediately
>    - Sessions: Easy to revoke, requires session store (Redis)
>
> 2. **Refresh token rotation**: Should refresh tokens rotate on each use (more secure) or be long-lived?
>
> 3. **OAuth providers**: The PRD mentions "future OAuth support". Should we design the endpoints to be OAuth-compatible from the start, or keep it simple for now?

> **User:** JWT with refresh token rotation. Keep OAuth for later but design with it in mind.

**Agent (lead-programmer):**
> Here's the authentication API design:
>
> **POST /api/v1/auth/register**
> ```
> Request:  { email: string, password: string, name: string }
> Response 201: { user: { id, email, name, createdAt }, accessToken, refreshToken }
> Response 409: { error: "EMAIL_ALREADY_EXISTS" }
> Response 422: { error: "VALIDATION_ERROR", fields: {...} }
> ```
>
> **POST /api/v1/auth/login**
> ```
> Request:  { email: string, password: string }
> Response 200: { user: { id, email, name }, accessToken, refreshToken }
> Response 401: { error: "INVALID_CREDENTIALS" }
> Response 429: { error: "RATE_LIMIT_EXCEEDED", retryAfter: number }
> ```
>
> **POST /api/v1/auth/refresh**
> ```
> Request:  { refreshToken: string }
> Response 200: { accessToken, refreshToken }  ← new refresh token (rotation)
> Response 401: { error: "INVALID_REFRESH_TOKEN" }
> ```
>
> **POST /api/v1/auth/logout**
> ```
> Headers:  Authorization: Bearer <accessToken>
> Response 200: { success: true }
> ```
>
> **GET /api/v1/auth/me**
> ```
> Headers:  Authorization: Bearer <accessToken>
> Response 200: { user: { id, email, name, createdAt } }
> Response 401: { error: "UNAUTHORIZED" }
> ```
>
> **OAuth readiness:** The `/api/v1/auth/` prefix is designed to accommodate future OAuth endpoints like `/api/v1/auth/oauth/google/callback`.
>
> All error responses follow: `{ error: string, message?: string, fields?: Record<string, string> }`
>
> May I write this to `docs/api/auth-service.md`?

> **User:** Yes, write it.

**Agent (lead-programmer):**
> ✅ Created `docs/api/auth-service.md`
>
> Suggested next steps:
> 1. Run `/db-review` to design the users and refresh_tokens tables
> 2. Ask `security-engineer` to review the auth design for OWASP vulnerabilities
> 3. Ask `backend-developer` to implement the endpoints against this contract

---

**Files created this session:**
- `docs/api/auth-service.md` (API contract with all endpoints)
