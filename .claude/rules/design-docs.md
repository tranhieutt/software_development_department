---
paths:
  - "design/specs/**"
---

# Design Document Rules

- Every design document MUST contain these 8 sections: Overview, User Value, Detailed Requirements, Formulas / Algorithms, Edge Cases, Dependencies, Configuration Parameters, Acceptance Criteria
- Formulas and algorithms must include variable definitions, expected value ranges, and example calculations
- Edge cases must explicitly state what happens, not just "handle gracefully"
- Dependencies must be bidirectional — if system A depends on B, B's doc must mention A
- Configuration parameters must specify safe ranges and what system behavior they affect
- Acceptance criteria must be testable — a QA tester must be able to verify pass/fail
- No hand-waving: "the system should feel good" is not a valid specification
- All configurable values must link to their source rationale
- Design documents MUST be written incrementally: create skeleton first, then fill
  each section one at a time with user approval between sections. Write each
  approved section to the file immediately to persist decisions and manage context
