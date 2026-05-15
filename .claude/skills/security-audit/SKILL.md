---
name: security-audit
type: workflow
description: "Conducts a comprehensive security audit covering web application vulnerabilities, API security, OWASP Top 10, and security hardening recommendations. Use when auditing a codebase for security or when the user mentions security audit, penetration testing, or vulnerability scan."
context: fork
agent: security-engineer
when_to_use: "When performing security audits, vulnerability scanning, penetration testing, or hardening web applications and APIs"
allowed-tools: Read, Glob, Grep, Bash
argument-hint: "[target: api|frontend|backend|infra|full]"
user-invocable: true
effort: 5
---

# Security Auditing Workflow

Systematic security review using static analysis tools available in the codebase.
Covers OWASP Top 10, secrets exposure, auth patterns, and dependency risk.

## Phase 1: Reconnaissance — Map the Attack Surface

1. **Identify entry points** — list all routes/controllers:

   ```bash
   grep -rn "app\.\(get\|post\|put\|delete\|patch\)\|@app\.route\|router\." src/ --include="*.{js,ts,py}" | head -60
   ```

2. **Identify auth middleware** — check which routes are protected:

   ```bash
   grep -rn "auth\|middleware\|guard\|require_login\|jwt\|bearer" src/ -i --include="*.{js,ts,py}" | head -40
   ```

3. **Map external dependencies** — check package files for known-risky libs:

   ```bash
   cat package.json 2>/dev/null || cat requirements.txt 2>/dev/null || cat go.mod 2>/dev/null
   ```

4. **Note findings** — list: total endpoints found, unprotected routes, third-party auth libs.

---

## Phase 2: Secrets & Sensitive Data Exposure

1. **Scan for hardcoded secrets**:

   ```bash
   grep -rn "password\s*=\s*['\"][^'\"]\|api_key\s*=\s*['\"][^'\"]\|secret\s*=\s*['\"][^'\"]" src/ -i | grep -v ".example" | head -30
   ```

2. **Scan for tokens/keys in source**:

   ```bash
   grep -rEn "(sk-|AIza|AKIA|ghp_|xox[baprs]-)[A-Za-z0-9]+" src/ | head -20
   ```

3. **Check .env files are gitignored**:

   ```bash
   cat .gitignore | grep -i "\.env" ; ls -la .env* 2>/dev/null
   ```

4. **Check for secrets in logs**:

   ```bash
   grep -rn "console\.log.*password\|logger.*token\|print.*secret" src/ -i | head -20
   ```

**Flag:** any hardcoded credential or unignored `.env` file is a P0 finding.

---

## Phase 3: Injection & Input Validation

1. **SQL injection risk** — look for string concatenation in queries:

   ```bash
   grep -rn "query.*+\|execute.*f\"\|raw.*%s\|SELECT.*\$\{" src/ --include="*.{js,ts,py}" | head -30
   ```

2. **Command injection risk** — shell execution with user input:

   ```bash
   grep -rn "exec(\|spawn(\|subprocess\|os\.system\|child_process" src/ --include="*.{js,ts,py}" | head -20
   ```

3. **XSS risk** — unescaped HTML rendering:

   ```bash
   grep -rn "innerHTML\|dangerouslySetInnerHTML\|v-html\|\.html(" src/ --include="*.{js,ts,jsx,tsx,vue}" | head -20
   ```

4. **Check for input validation middleware** — is there a schema validator at boundaries?

   ```bash
   grep -rn "joi\|zod\|yup\|pydantic\|cerberus\|marshmallow" src/ --include="*.{js,ts,py}" | head -10
   ```

---

## Phase 4: Authentication & Authorization

1. **JWT / token handling** — check for weak configs:

   ```bash
   grep -rn "algorithm.*HS256\|expiresIn\|verify\|decode" src/ --include="*.{js,ts,py}" | head -20
   ```

2. **Password hashing** — confirm bcrypt/argon2, not MD5/SHA1:

   ```bash
   grep -rn "md5\|sha1\|hashSync\|bcrypt\|argon2\|pbkdf2" src/ -i --include="*.{js,ts,py}" | head -20
   ```

3. **CORS config** — check for wildcard origins:

   ```bash
   grep -rn "cors\|Access-Control-Allow-Origin\|\*" src/ --include="*.{js,ts,py}" | head -20
   ```

4. **Authorization checks** — look for missing ownership checks in update/delete:

   ```bash
   grep -rn "findById\|findOne\|get_object_or_404" src/ --include="*.{js,ts,py}" | head -20
   ```

   Review each — does the handler verify `resource.userId === req.user.id`?

---

## Phase 5: Security Headers & Config

1. **HTTP security headers** — check if helmet/similar is configured:

   ```bash
   grep -rn "helmet\|Content-Security-Policy\|X-Frame-Options\|Strict-Transport" src/ --include="*.{js,ts}" | head -10
   ```

2. **Rate limiting** — check for brute-force protection on auth routes:

   ```bash
   grep -rn "rateLimit\|throttle\|rate_limit\|slowDown" src/ --include="*.{js,ts,py}" | head -10
   ```

3. **HTTPS enforcement** — check redirect config:

   ```bash
   grep -rn "http://\|forceHttps\|redirectToHttps\|SECURE_SSL_REDIRECT" src/ --include="*.{js,ts,py}" | head -10
   ```

---

## Phase 6: Report Findings

For each finding, record:

| Severity | Category | File:Line | Description | Remediation |
|----------|----------|-----------|-------------|-------------|
| P0 Critical | | | | |
| P1 High | | | | |
| P2 Medium | | | | |
| P3 Low / Info | | | | |

**Severity guide:**
- **P0**: Hardcoded credential, remote code execution, auth bypass
- **P1**: SQL injection, XSS, IDOR, broken auth
- **P2**: Missing rate limit, weak hashing, CORS wildcard
- **P3**: Missing security header, verbose errors, info disclosure

Save report to `docs/technical/security-audit-{YYYY-MM-DD}.md`.

---

## Security Checklist

### OWASP Top 10
- [ ] A01 Broken Access Control — ownership checks on every mutation
- [ ] A02 Cryptographic Failures — no hardcoded secrets, strong hashing
- [ ] A03 Injection — parameterized queries, no string concat in SQL/shell
- [ ] A04 Insecure Design — auth required on all sensitive routes
- [ ] A05 Security Misconfiguration — security headers, CORS, HTTPS
- [ ] A06 Vulnerable Components — no known-CVE dependencies
- [ ] A07 Auth & Session — JWT config, expiry, refresh token rotation
- [ ] A08 Integrity Failures — no unverified package installs in CI
- [ ] A09 Logging & Monitoring — no secrets in logs, audit trail exists
- [ ] A10 SSRF — no unvalidated URL-fetch from user input

## Protocol

- **Question**: Reads target scope from argument (`api` / `frontend` / `backend` / `infra` / `full`)
- **Options**: Skip
- **Decision**: Skip — audit is comprehensive; scope from argument
- **Draft**: Findings table shown in conversation before saving report
- **Approval**: "May I write to `docs/technical/security-audit-[YYYY-MM-DD].md`?"

## Output

Deliver exactly:

- **Findings table** with severity (P0–P3), file:line, description, and remediation for each issue
- **OWASP Top 10 checklist** — 10 items marked pass / fail / N/A
- **Report file** saved to `docs/technical/security-audit-{YYYY-MM-DD}.md`
- **Verdict**: `CLEAN` / `LOW RISK` / `MEDIUM RISK` / `HIGH RISK — DO NOT DEPLOY`

## Secure Coding Reference

When the audit finds a vulnerability and the fix requires hands-on secure
coding guidance, apply the following patterns inline (no separate skill needed).

### Backend Secure Coding Patterns
- **Input validation**: allowlist approach — reject anything not explicitly allowed
- **Injection prevention**: parameterized queries only; never string-concat into SQL/shell
- **Auth**: bcrypt or Argon2 for passwords; JWT with expiry + rotation; PKCE for OAuth
- **CORS**: explicit origin allowlist; never `Access-Control-Allow-Origin: *` on credentialed routes
- **CSRF**: HttpOnly + SameSite=Strict cookies; double-submit or synchronizer token for mutations
- **SSRF**: URL allowlist before any server-side fetch; block internal IP ranges
- **Error handling**: never expose stack traces or internal paths to API consumers
- **Secrets**: never hardcode; use env vars + secret manager; rotate on suspected exposure

### Frontend Secure Coding Patterns
- **XSS**: prefer `textContent` over `innerHTML`; sanitize with DOMPurify if HTML is required
- **CSP**: configure `Content-Security-Policy` with nonce-based script restrictions; report-only first
- **Token storage**: HttpOnly cookies over localStorage for session tokens
- **Redirects**: validate destination against allowlist before any client-side navigation
- **SRI**: use `integrity=` attribute on all third-party script/style tags from CDN
- **Clickjacking**: set `X-Frame-Options: DENY` or CSP `frame-ancestors 'none'` at server level
- **Open redirect**: never use raw query params as redirect destinations; use identifier mapping

## Related Skills

- `code-review` — line-by-line review with security lens
- `guard` — freeze check before deploying a fix
