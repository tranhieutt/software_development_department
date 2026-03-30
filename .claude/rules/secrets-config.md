# Secrets & Configuration Standards

Applies to: `.env*`, `*.config.*`, `config/**`, `infra/**`, `scripts/**`, `src/config/**`

## Secret Management

- Secrets (API keys, tokens, passwords, private keys) MUST never be hardcoded in source code
- Secrets MUST never be committed to version control — add `.env*` to `.gitignore`
- Use environment variables for all secrets; reference them by name in code (`process.env.API_KEY`)
- Provide a `.env.example` file with all required variable names and placeholder values — no real secrets
- Rotate any secret that has been accidentally committed immediately; treat it as compromised

## Environment Variables

- Use a single source of truth for environment variable names — see **`.env.example`** at the project root for the canonical list of required variables
- Validate all required environment variables at application startup — fail fast with a clear error message
- Group variables by concern: `DATABASE_*`, `AUTH_*`, `SMTP_*`, etc.
- Use `NODE_ENV` / `APP_ENV` to control environment-specific behavior; default to the most restrictive setting

```
# .env.example — safe to commit, shows required keys with no real values
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
AUTH_JWT_SECRET=change-me-in-production
SMTP_API_KEY=
STRIPE_SECRET_KEY=
```

## Configuration Files

- External configuration (timeouts, feature flags, limits) belongs in config files — not scattered as magic numbers in code
- Config files loaded at startup; application code reads from a single config module, never from `process.env` directly
- Sensitive config values (even non-secret ones) must not be logged at startup
- Different config files per environment (`config/development.ts`, `config/production.ts`) — no runtime `if (env === 'prod')` branches in business logic

## Infrastructure & Deployment Secrets

- CI/CD pipeline secrets stored in the CI provider's secret store (GitHub Actions Secrets, GitLab CI Variables), never in YAML files
- Infrastructure credentials (cloud provider keys, Terraform state backend) use IAM roles / workload identity where possible — avoid long-lived static keys
- Docker images must not embed secrets; use runtime environment injection or secret mounts
- Kubernetes: use Secrets resources (not ConfigMaps) for sensitive values; enable encryption at rest

## Forbidden Patterns

- `const API_KEY = "sk-abc123..."` — hardcoded secret in source
- `console.log(process.env.DATABASE_URL)` — logging secrets
- Secrets in URL query parameters (`?token=abc123`)
- Committing real `.env` files (only `.env.example` is allowed)
- Storing secrets in `localStorage` or `sessionStorage` on the frontend
- Passing secrets as CLI arguments (visible in process list)

## Logging & Observability

- Logging middleware must scrub known secret patterns before writing to any log sink
- Scrub headers: `Authorization`, `X-Api-Key`, `Cookie`
- Scrub body fields: `password`, `token`, `secret`, `key`, `credential`
- Audit logs for secret access (who accessed what, when) in production environments
