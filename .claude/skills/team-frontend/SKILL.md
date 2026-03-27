---
name: team-frontend
description: "Orchestrate the frontend team: coordinates ux-designer, ux-researcher, frontend-developer, and accessibility-specialist to design, implement, and validate a user interface feature from research to launch."
argument-hint: "[UI feature or screen description]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---

When this skill is invoked, orchestrate the frontend team through a structured delivery pipeline.

**Decision Points:** At each phase, use `AskUserQuestion` to get user approval before proceeding.

## Team Composition
- **ux-researcher** — User insights and validation
- **ux-designer** — User flows, wireframes, interaction design
- **frontend-developer** — Component implementation and integration
- **accessibility-specialist** — Accessibility audit and compliance

## Pipeline

### Phase 1: Research (if needed)
Delegate to **ux-researcher** (skip if sufficient prior research exists):
- Define what user behavior/pain-point this feature addresses
- Review any existing analytics or user feedback
- Output: Research brief with key insights

### Phase 2: UX Design
Delegate to **ux-designer**:
- Define user flow (entry → states → exit)
- Create wireframes for all states (default, loading, error, empty, success)
- Specify interaction patterns and responsive breakpoints
- Define accessibility requirements
- Output: UX spec and wireframes for approval

### Phase 3: Implementation
Delegate to **frontend-developer**:
- Build components following the approved UX spec
- Use design tokens — no hardcoded colors, sizes, or fonts
- Handle all states: loading, error, empty, success
- All user-facing strings through i18n layer
- Write component unit tests
- Output: Implemented UI feature

### Phase 4: Accessibility Audit
Delegate to **accessibility-specialist**:
- Test keyboard navigation (tab order, focus management)
- Verify ARIA roles and labels
- Check color contrast (WCAG AA minimum)
- Test with screen reader if critical flow
- Output: Accessibility report

### Phase 5: Polish & Review
- Address accessibility findings
- Verify responsive behavior at all target breakpoints
- Cross-browser test on target browsers
- **ux-designer** validates final implementation against spec

## Output
Summary covering: research insights used, UX spec status, implementation status, accessibility compliance, and any outstanding issues.
