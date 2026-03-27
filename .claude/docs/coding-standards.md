# Coding Standards

- All code must include doc comments on public APIs
- Every system must have a corresponding architecture decision record in `docs/architecture/`
- Configuration values must be data-driven (external config files), never hardcoded
- All public methods must be unit-testable (dependency injection over singletons)
- Commits must reference the relevant design document or task ID
- **Verification-driven development**: Write tests first when adding new features or systems.
  For UI changes, verify with screenshots. Compare expected output to actual output
  before marking work complete. Every implementation should have a way to prove it works.

# Design Document Standards

- All design docs use Markdown
- Each feature or system has a dedicated spec in `design/specs/`
- Documents must include these 8 required sections:
  1. **Overview** -- one-paragraph summary
  2. **User Value** -- intended user benefit and experience
  3. **Detailed Requirements** -- unambiguous functional requirements
  4. **Formulas / Algorithms** -- all math or logic defined with variables
  5. **Edge Cases** -- unusual situations handled
  6. **Dependencies** -- other systems listed
  7. **Configuration Parameters** -- configurable values with safe ranges identified
  8. **Acceptance Criteria** -- testable success conditions
- All configurable values must link to their source rationale
