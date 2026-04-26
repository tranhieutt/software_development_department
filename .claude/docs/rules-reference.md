# Path-Specific Rules

Rules in `.claude/rules/` are automatically enforced when editing files in matching paths:

| Rule File | Path Pattern | Enforces |
| ---- | ---- | ---- |
| `api-code.md` | `src/api/**` | REST/GraphQL conventions, authentication, error format |
| `frontend-code.md` | `src/frontend/**` | Accessibility (WCAG), design tokens, i18n, state management |
| `database-code.md` | `src/db/**`, `src/models/**`, `src/repositories/**`, `migrations/**`, `schema/**` | Schema design, reversible migrations, parameterized queries, indexing, data integrity |
| `data-files.md` | `assets/data/**`, `config/**`, `src/config/**` | JSON validity, schema discipline, naming, versioning, defaults |
| `ui-code.md` | `src/ui/**` | No business logic in UI, localization-ready, keyboard accessible |
| `ai-code.md` | `src/ai/**` | Performance budgets, model params must be configurable, explainability |
| `network-code.md` | `src/networking/**` | WebSocket standards, real-time event streaming |
| `git-push.md` | `git push` workflow | Update history log and both README variants before pushing |
| `secrets-config.md` | `.env*`, `*.config.*`, `config/**`, `infra/**`, `scripts/**`, `src/config/**` | Secret handling, env validation, external config discipline, log scrubbing |
| `src-code.md` | `src/**` | Public symbol blast-radius checks, surgical changes, pre-commit impact review |
| `design-docs.md` | `design/docs/**` | Required PRD sections, clear acceptance criteria |
| `test-standards.md` | `tests/**` | Test naming conventions, coverage requirements, no flaky patterns |
| `prototype-code.md` | `prototypes/**` | Relaxed standards, README required, hypothesis documented |
