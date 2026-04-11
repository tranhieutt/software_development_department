---
name: code-review
description: "Performs architectural and quality code review checking coding standards, SOLID principles, architectural compliance, and common software issues. Use when reviewing a file or directory before merge, or when the user mentions code review, PR review, or quality check."
argument-hint: "[path-to-file-or-directory]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
context: fork
agent: lead-programmer
effort: 2
when_to_use: "When a full architectural and quality review is needed before merging a PR"
---

When this skill is invoked:

1. **Read the target file(s)** in full.

2. **Read the CLAUDE.md** for project coding standards.

3. **Identify the system category** (api, service, repository, component, utility, infrastructure)
   and apply category-specific standards.

4. **Evaluate against coding standards**:
   - [ ] Public methods and classes have doc comments
   - [ ] Cyclomatic complexity under 10 per method
   - [ ] No method exceeds 40 lines (excluding data declarations)
   - [ ] Dependencies are injected (no singletons for business state)
   - [ ] Configuration values loaded from external config, not hardcoded
   - [ ] Systems expose interfaces (not concrete class dependencies)

5. **Check architectural compliance**:
   - [ ] Correct dependency direction (infrastructure ← domain ← application)
   - [ ] No circular dependencies between modules
   - [ ] Proper layer separation (UI does not own business logic)
   - [ ] Events/messages used for cross-service communication
   - [ ] Consistent with established patterns in the codebase

6. **Check SOLID compliance**:
   - [ ] Single Responsibility: Each class has one reason to change
   - [ ] Open/Closed: Extendable without modification
   - [ ] Liskov Substitution: Subtypes substitutable for base types
   - [ ] Interface Segregation: No fat interfaces
   - [ ] Dependency Inversion: Depends on abstractions, not concretions

7. **Check for common web/software issues**:
   - [ ] No N+1 query patterns (use eager loading or joins)
   - [ ] Proper async/await usage (no unhandled promises, no floating async)
   - [ ] Input validation at system boundaries (user input, external APIs)
   - [ ] Proper error handling with meaningful, safe messages (no stack traces exposed)
   - [ ] No secrets or sensitive data hardcoded (API keys, passwords, tokens)
   - [ ] Resource cleanup (DB connections, streams, subscriptions, event listeners)
   - [ ] Thread/concurrency safety where required

8. **Output the review** in this format:

```
## Code Review: [File/System Name]

### Standards Compliance: [X/6 passing]
[List failures with line references]

### Architecture: [CLEAN / MINOR ISSUES / VIOLATIONS FOUND]
[List specific architectural concerns]

### SOLID: [COMPLIANT / ISSUES FOUND]
[List specific violations]

### Web/Software Concerns
[List web and software-specific issues found]

### Positive Observations
[What is done well — always include this section]

### Required Changes
[Must-fix items before approval]

### Suggestions
[Nice-to-have improvements]

### Verdict: [APPROVED / APPROVED WITH SUGGESTIONS / CHANGES REQUIRED]
```

## Protocol

- **Question**: Auto-starts from argument (file or directory path); no clarification needed
- **Options**: Skip — single review path
- **Decision**: Skip — verdict is advisory
- **Draft**: Full review shown in conversation only
- **Approval**: Skip — read-only; no files written

## Output

Deliver exactly:

- **Risk Tier** (Low / Medium / High) with one-sentence justification
- **Standards & Architecture compliance** score (X/6, X/5)
- **Blocking issues** — must fix before merge (or "None")
- **Suggestions** — optional improvements, max 3
- **Verdict**: `APPROVED` / `APPROVED WITH SUGGESTIONS` / `CHANGES REQUIRED`
