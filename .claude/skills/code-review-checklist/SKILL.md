---
name: code-review-checklist
description: "Provides a comprehensive code review checklist for pull requests covering security, performance, maintainability, and testing. Use as a reference during code reviews or when the user asks for a review checklist."
allowed-tools: Read, Glob, Grep, Bash
argument-hint: "[file path or PR number]"
user-invocable: true
effort: 3
when_to_use: "Quick self-check before committing, when a full review is not needed"
---

# Code Review Checklist

## Pre-review (always start here)

- [ ] Read PR description and linked issue — understand the *why*
- [ ] Check CI passes before spending time on review
- [ ] Pull branch locally if logic is complex

## Functionality

- [ ] Solves stated problem and meets acceptance criteria
- [ ] Edge cases: null/empty inputs, concurrent calls, network failure
- [ ] Error handling: errors caught, message doesn't expose internals
- [ ] No off-by-one, loop termination, or race conditions

## Security (block if any fail)

- [ ] No SQL injection — use parameterized queries, not string concat
- [ ] No XSS — escape all user-controlled output in DOM
- [ ] No hardcoded secrets — use environment variables
- [ ] Authentication required on all protected routes
- [ ] Authorization checks presence AND ownership (not just auth)
- [ ] File uploads validated: type, size, content

```javascript
// ❌ SQL injection
const q = `SELECT * FROM users WHERE email = '${email}'`;

// ✅ Parameterized
db.query("SELECT * FROM users WHERE email = $1", [email]);

// ❌ Hardcoded secret
const KEY = "sk_live_abc123";

// ✅ Env variable
const KEY = process.env.API_KEY;
if (!KEY) throw new Error("API_KEY is required");
```

## Performance

- [ ] No N+1 queries — check ORM calls inside loops
- [ ] Database queries use indexes for filter/sort columns
- [ ] No unbounded queries — always paginate or limit
- [ ] No blocking main thread with sync I/O (Node.js)
- [ ] Caching used for repeated expensive operations

## Code quality

- [ ] Names describe intent (`calculateTotalPrice` not `calc`)
- [ ] Functions have single responsibility (< ~30 lines is a signal)
- [ ] No dead code or commented-out blocks
- [ ] DRY — no copy-paste of more than 3 lines
- [ ] Follows existing project conventions and patterns

## Tests

- [ ] New behavior has test coverage
- [ ] Happy path + at least 1 failure/edge case tested
- [ ] Tests use real assertions, not just "doesn't throw"
- [ ] No brittle tests that break on unrelated changes

## Documentation

- [ ] Complex logic has `// why` comment (not `// what`)
- [ ] Public API changes documented
- [ ] Breaking changes documented in CHANGELOG or PR body

## Review comment format

```markdown
**Issue:** [What's wrong]
**Current:** `problematic code`
**Suggested:** `improved code`
**Why:** [reason]
```

## Verdict

- **APPROVED** — all sections pass
- **APPROVED WITH CONDITIONS** — minor items, non-blocking
- **CHANGES REQUIRED** — blocking security, correctness, or test coverage issues

Output: checklist score (X/Y passing) + blocking items with file:line refs + verdict
