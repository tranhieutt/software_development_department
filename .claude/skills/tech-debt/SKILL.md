---
name: tech-debt
description: "Scans the codebase for technical debt indicators, categorizes and prioritizes findings, and maintains a debt register with repayment recommendations. Use when assessing codebase health, planning refactoring, or when the user mentions technical debt or code quality."
argument-hint: "[scan|add|prioritize|report]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
context: fork
agent: technical-director
effort: 3
when_to_use: "Use when assessing codebase health, planning a refactoring sprint, or when the user mentions technical debt, code quality, cleanup, or wants to prioritize remediation work."
---
When this skill is invoked:

1. **Parse the subcommand** from the argument:
   - `scan` — Scan the codebase for tech debt indicators
   - `add` — Add a new tech debt entry manually
   - `prioritize` — Re-prioritize the existing debt register
   - `report` — Generate a summary report of current debt status

2. **For `scan`**:
   - Search the codebase for debt indicators:
     - `TODO` comments (count and categorize)
     - `FIXME` comments (these are bugs disguised as debt)
     - `HACK` comments (workarounds that need proper solutions)
     - `@deprecated` markers
     - Duplicated code blocks (similar patterns in multiple files)
     - Files over 500 lines (potential god objects)
     - Functions over 50 lines (potential complexity)
   - Categorize each finding:
     - **Architecture Debt**: Wrong abstractions, missing patterns, coupling issues
     - **Code Quality Debt**: Duplication, complexity, naming, missing types
     - **Test Debt**: Missing tests, flaky tests, untested edge cases
     - **Documentation Debt**: Missing docs, outdated docs, undocumented APIs
     - **Dependency Debt**: Outdated packages, deprecated APIs, version conflicts
     - **Performance Debt**: Known slow paths, unoptimized queries, memory issues
   - Update the debt register at `docs/tech-debt-register.md`

3. **For `add`**:
   - Prompt for: description, category, affected files, estimated fix effort, impact if left unfixed
   - Append to the debt register

4. **For `prioritize`**:
   - Read the debt register
   - Score each item by: `(impact_if_unfixed * frequency_of_encounter) / fix_effort`
   - Re-sort the register by priority score
   - Recommend which items to include in the next sprint

5. **For `report`**:
   - Read the debt register
   - Generate summary statistics:
     - Total items by category
     - Total estimated fix effort
     - Items added vs resolved since last report
     - Trending direction (growing / stable / shrinking)
   - Flag any items that have been in the register for more than 3 sprints
   - Output the report

### Debt Register Format

```markdown
## Technical Debt Register
Last updated: [Date]
Total items: [N] | Estimated total effort: [T-shirt sizes summed]

| ID | Category | Description | Files | Effort | Impact | Priority | Added | Sprint |
|----|----------|-------------|-------|--------|--------|----------|-------|--------|
| TD-001 | [Cat] | [Description] | [files] | [S/M/L/XL] | [Low/Med/High/Critical] | [Score] | [Date] | [Sprint to fix or "Backlog"] |
```

### Rules
- Tech debt is not inherently bad — it is a tool. The register tracks conscious decisions.
- Every debt entry must explain WHY it was accepted (deadline, prototype, missing info)
- "Scan" should run at least once per sprint to catch new debt
- Items older than 3 sprints without action should either be fixed or consciously accepted with a documented reason

## Protocol

- **Question**: Reads mode from argument (`scan` / `add` / `prioritize` / `report`); `add` mode prompts for debt details
- **Options**: Skip — mode drives execution path
- **Decision**: `add` mode — user provides description, category, effort estimate, and justification (why accepted)
- **Draft**: Changes shown in conversation before updating register
- **Approval**: "May I update `docs/technical/tech-debt.md`?"

## Output

Deliver exactly:

- **`scan`**: debt register updated at `docs/technical/tech-debt.md` + count of new items found by category
- **`add`**: new TD-[NNN] entry appended to register with effort, impact, and WHY it was accepted
- **`prioritize`**: ranked list of top 5 items by impact/effort score with recommended sprint to fix
- **`report`**: summary table — total items, effort distribution (S/M/L/XL), critical items count
