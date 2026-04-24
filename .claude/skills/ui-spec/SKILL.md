---
name: ui-spec
type: workflow
description: "Guidelines and procedures for creating comprehensive UI Specifications from PRDs and prototypes."
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
effort: 3
argument-hint: "[prd, prototype, or feature name]"
when_to_use: "Use when translating a PRD, prototype, or feature brief into a concrete UI specification with components, states, and interactions."
---

# Skill: /ui-spec

Use this skill when moving from a PRD (Requirements) to a technical UI design. This skill bridges the gap between wireframes and code.

## The UI Spec Lifecycle

### 1. Analysis Phase
- **Map ACs**: Map every Acceptance Criterion from the PRD to a UI screen or interaction.
- **Prototype Ingestion**: If prototype code exists (e.g., from `prototyper`), read it to understand components and states.

### 2. Decomposition Phase
- Define the **Component Tree**.
- Identify which components can be reused from the existing codebase vs. which need to be new.

### 3. Specification Phase
Fill out the `ui-spec-template` including:
- **State Matrix**: Explicitly define what the user sees during `Loading`, `Error`, and `Empty` states.
- **Interactions**: Use EARS format (Condition-Trigger-Response) for all interactive elements.

### 4. Integration Phase
- Link the UI Spec in the feature's [Design Doc].
- Use the UI Spec as the checklist for the `frontend-developer`.

## The State x Display Matrix
Every component MUST define behavior for these 5 states:
1. **Default**: The "Happy Path".
2. **Loading**: Bone skeletal screens or spinners.
3. **Empty**: Context-aware messages when no data exists.
4. **Error**: User-friendly error messages with recovery actions (Retry/Reset).
5. **Partial**: Behavior when some data is missing or loading.

## Accessibility (A11y) Rules
- Every interaction must have a keyboard equivalent.
- Every interactive element must have an ARIA role and label.
- Color contrast ratios must meet WCAG 2.1 Level AA (4.5:1 for normal text).
