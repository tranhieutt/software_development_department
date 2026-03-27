---
paths:
  - "src/ui/**"
  - "src/components/**"
---

# UI Code Rules

- UI must NEVER own or directly modify application state — display only, use events/callbacks/API calls to request changes
- All UI text must go through the i18n/localization system — no hardcoded user-facing strings
- All interactive elements must be fully keyboard accessible (Tab, Enter, Escape)
- All animations must be skippable and respect `prefers-reduced-motion` media query
- Every data-fetching UI must handle three states: loading, error, and empty
- Scalable text and colorblind-safe design are mandatory, not optional
- Test all screens at minimum and maximum supported viewport sizes
- ARIA labels required on all icon-only buttons and form controls
