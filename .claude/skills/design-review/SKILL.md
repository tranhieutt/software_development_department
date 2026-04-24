---
name: design-review
type: workflow
description: "Reviews UI/UX designs, wireframes, and design systems for usability, accessibility, consistency, and implementation feasibility. Use when reviewing design specs or when the user mentions design review, UX review, or design feedback."
argument-hint: "[path-to-design-doc]"
user-invocable: true
allowed-tools: Read, Glob, Grep
context: fork
agent: ux-designer
effort: 2
when_to_use: "When reviewing a design or feature specification document for completeness, consistency, and implementability"
---

When this skill is invoked:

1. **Read the target design document** in full.

2. **Read the master CLAUDE.md** to understand project context and standards.

3. **Read related design documents** referenced or implied by the target doc
   (check `design/docs/` for related systems).

4. **Evaluate against the Design Document Standard checklist**:
   - [ ] Has Overview section (one-paragraph summary)
   - [ ] Has User Fantasy section (intended feeling)
   - [ ] Has Detailed Rules section (unambiguous mechanics)
   - [ ] Has Formulas section (all math defined with variables)
   - [ ] Has Edge Cases section (unusual situations handled)
   - [ ] Has Dependencies section (other systems listed)
   - [ ] Has Tuning Knobs section (configurable values identified)
   - [ ] Has Acceptance Criteria section (testable success conditions)

5. **Check for internal consistency**:
   - Do the formulas produce values that match the described behavior?
   - Do edge cases contradict the main rules?
   - Are dependencies bidirectional (does the other system know about this one)?

6. **Check for implementability**:
   - Are the rules precise enough for a programmer to implement without guessing?
   - Are there any "hand-wave" sections where details are missing?
   - Are performance implications considered?

7. **Check for cross-system consistency**:
   - Does this conflict with any existing mechanic?
   - Does this create unintended interactions with other systems?
   - Is this consistent with the product's established tone and pillars?

8. **Output the review** in this format:

```
## Design Review: [Document Title]

### Completeness: [X/8 sections present]
[List missing sections]

### Consistency Issues
[List any internal or cross-system contradictions]

### Implementability Concerns
[List any vague or unimplementable sections]

### Balance Concerns
[List any obvious balance risks]

### Recommendations
[Prioritized list of improvements]

### Verdict: [APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED]
```

9. **Contextual next step recommendations**:
   - If the document being reviewed is `product-concept.md` or `product-pillars.md`:
     - Check if `design/docs/systems-index.md` exists
     - If it does NOT exist, add to Recommendations:
       > "This concept is ready for systems decomposition. Run `/map-systems`
       > to break it down into individual systems with dependencies and priorities,
       > then write per-system PRDs."
   - If the document is an individual system PRD:
     - Check if the systems index references this system
     - If verdict is APPROVED: suggest "Update the systems index status for
       this system to 'Approved'."
     - If verdict is NEEDS REVISION or MAJOR REVISION NEEDED: suggest "Update
       the systems index status for this system to 'In Review'."
     - Note: This skill is read-only. The user (or `/design-system`) must
       perform the actual status update in the systems index.

## Protocol

- **Question**: Auto-starts from argument (path to design doc)
- **Options**: Skip — single review path
- **Decision**: Skip — verdict is advisory
- **Draft**: Full review shown in conversation only
- **Approval**: Skip — read-only; this skill never writes files

## Output

Deliver exactly:

- **Completeness score** (X/8 required sections present)
- **Consistency issues** — contradictions or undefined terms (or "None")
- **Implementability concerns** — sections too vague to build from (or "None")
- **Verdict**: `APPROVED` / `NEEDS REVISION` / `MAJOR REVISION NEEDED`
- **Next skill** — one recommended follow-up (e.g., `/map-systems`, update systems index)
