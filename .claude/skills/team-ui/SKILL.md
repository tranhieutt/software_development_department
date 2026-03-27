---
name: team-ui
description: "Orchestrate the UI team: coordinates ux-designer and ui-programmer to design, implement, and polish a user interface feature from wireframe to final."
argument-hint: "[UI feature description]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---
When this skill is invoked, orchestrate the UI team through a structured pipeline.

**Decision Points:** At each phase transition, use `AskUserQuestion` to present
the user with the subagent's proposals as selectable options. Write the agent's
full analysis in conversation, then capture the decision with concise labels.
The user must approve before moving to the next phase.

## Team Composition
- **ux-designer** — User flows, wireframes, accessibility, interaction patterns
- **ui-programmer** — UI framework, screens, components, data binding, implementation

## How to Delegate

Use the Task tool to spawn each team member as a subagent:
- `subagent_type: ux-designer` — User flows, wireframes, accessibility, interaction patterns
- `subagent_type: ui-programmer` — UI framework, screens, components, data binding

Always provide full context in each agent's prompt (feature requirements, existing UI patterns, platform targets). Launch independent agents in parallel where the pipeline allows it (e.g., Phase 4 review agents can run simultaneously).

## Pipeline

### Phase 1: UX Design
Delegate to **ux-designer**:
- Define the user flow for this feature (entry points, states, exit points)
- Create wireframes for each screen/state
- Specify interaction patterns: how does keyboard/mouse AND gamepad navigate this?
- Define accessibility requirements: text sizes, contrast, colorblind safety
- Identify data the UI needs to display (what game state does it read?)
- Output: UX spec with wireframes and interaction map

### Phase 2: Visual Design
Delegate to **ui-programmer** (styling phase):
- Review wireframes and translate to design tokens (colors, typography, spacing)
- Define visual treatment following the product design system
- Specify any assets needed (icons, illustrations)
- Ensure consistency with existing UI screens
- Output: visual design spec with style notes

### Phase 3: Implementation
Delegate to **ui-programmer**:
- Implement the UI following the UX spec and visual design
- Ensure UI NEVER owns or modifies application state — display only, events for actions
- All text through i18n/localization system — no hardcoded strings
- All interactive elements must be keyboard accessible
- Implement WCAG 2.1 AA accessibility (ARIA labels, focus management, contrast)
- Wire up data binding to application state
- Output: implemented UI feature

### Phase 4: Review (parallel)
Delegate in parallel:
- **ux-designer**: Verify implementation matches wireframes and interaction spec. Test keyboard-only navigation. Verify WCAG 2.1 AA accessibility.
- **ui-programmer**: Verify component quality, code review, edge cases (empty state, error state, loading state).

### Phase 5: Polish
- Address review feedback
- Verify animations respect `prefers-reduced-motion`
- Test all three data states: loading, error, empty
- Test at all supported viewport sizes and breakpoints

## Output
A summary report covering: UX spec status, visual design status, implementation status, accessibility compliance, and any outstanding issues.
