---
name: sprint-plan
type: workflow
description: "Generates or updates sprint plans with task breakdowns, capacity estimates, dependencies, and risk flags based on milestone goals and past velocity. Use when starting a new sprint, updating sprint progress, or checking sprint status."
argument-hint: "[new|update|status]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit
context: |
  !ls production/sprints/ 2>/dev/null
effort: 3
when_to_use: "Use when starting a new sprint, updating sprint progress mid-sprint, or checking current sprint status against milestone goals."
---

When this skill is invoked:

1. **Read the current milestone** from `production/milestones/`.

2. **Read the previous sprint** (if any) from `production/sprints/` to
   understand velocity and carryover. Use `Glob("production/sprints/*.md")`
   then read the file with the highest sprint number.

3. **Scan design documents** in `design/` for features tagged as ready
   for implementation.

4. **Check the risk register** at `production/risk-register/` if it exists.

For `new`:

1. **Determine sprint number** — count existing files in `production/sprints/`
   and increment by 1. Sprint N = number of existing sprint files + 1.

2. **Generate a sprint plan** following this format, then **save to
   `production/sprints/sprint-{N}.md`** (confirm path with user before writing):

```markdown
# Sprint [N] -- [Start Date] to [End Date]

## Sprint Goal
[One sentence describing what this sprint achieves toward the milestone]

## Capacity
- Total days: [X]
- Buffer (20%): [Y days reserved for unplanned work]
- Available: [Z days]

## Tasks

### Must Have (Critical Path)
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|

### Should Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|

### Nice to Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|

## Carryover from Previous Sprint
| Task | Reason | New Estimate |
|------|--------|-------------|

## Risks
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|

## Dependencies on External Factors
- [List any external dependencies]

## Definition of Done for this Sprint
- [ ] All Must Have tasks completed
- [ ] All tasks pass acceptance criteria
- [ ] No S1 or S2 bugs in delivered features
- [ ] Design documents updated for any deviations
- [ ] Code reviewed and merged
```

For `update`:

1. **Identify the current sprint file** — find the latest file in
   `production/sprints/` (highest sprint number). Read it.

2. **Ask the user** which task(s) to update: task ID, new status
   (`done` / `in-progress` / `blocked`), and any notes or blocker details.

3. **Edit the sprint file in place** using the Edit tool:
   - Move completed tasks to the "Completed" section if tracking status inline
   - Add blocker info to the Blocked table
   - Update `% Done` estimates for in-progress tasks

4. **Append a brief update log** at the bottom of the file:

   ```markdown
   ## Update Log
   - [YYYY-MM-DD]: [Summary of changes made]
   ```

5. **Confirm** the edit to the user: "Sprint {N} updated — {X} task(s) changed."

For `status`:

1. **Generate a status report**:

```markdown
# Sprint [N] Status -- [Date]

## Progress: [X/Y tasks complete] ([Z%])

### Completed
| Task | Completed By | Notes |
|------|-------------|-------|

### In Progress
| Task | Owner | % Done | Blockers |
|------|-------|--------|----------|

### Not Started
| Task | Owner | At Risk? | Notes |
|------|-------|----------|-------|

### Blocked
| Task | Blocker | Owner of Blocker | ETA |
|------|---------|-----------------|-----|

## Burndown Assessment
[On track / Behind / Ahead]
[If behind: What is being cut or deferred]

## Emerging Risks
- [Any new risks identified this sprint]
```

### Agent Consultation

For comprehensive sprint planning, consider consulting:

- `producer` agent for capacity planning, risk assessment, and cross-department coordination
- `product-manager` agent for feature prioritization and design readiness assessment

## Protocol

- **Question**: Reads mode from argument (`new` / `update` / `status`); `update` mode asks which tasks changed
- **Options**: Skip — mode drives execution path
- **Decision**: `update` mode — user specifies task IDs, new status, and blocker details
- **Draft**: Plan or status report shown in conversation before writing
- **Approval**: "May I write to `production/sprints/sprint-[N].md`?"

## Output

Deliver exactly:

- **`new`**: Sprint file saved to `production/sprints/sprint-[N].md` with Must Have / Should Have / Nice to Have tasks, estimates, and risks
- **`update`**: In-place edit to current sprint file + update log entry appended
- **`status`**: Status report with progress %, completed/in-progress/blocked tables, and burndown assessment
- **Next action**: One sentence on what the team should do immediately
