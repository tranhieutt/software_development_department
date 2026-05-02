---
paths:
  - "src/frontend/**"
  - "src/components/**"
  - "src/pages/**"
  - "src/app/**"
  - "src/views/**"
---

# Frontend Code Standards

> For low-level UI primitives in `src/ui/**`, see also `ui-code.md`.

## Component Design
- Components must be self-contained — no implicit global state dependencies
- Each component has a single, clearly defined responsibility
- Props / component APIs must have TypeScript interfaces
- No inline styles — use design tokens or CSS modules

## State Management
- Fetch and cache server state with a data-fetching library (React Query, SWR, etc.)
- UI state (modals, tabs) lives in component state
- Global app state (auth, user preferences) in the approved state store
- Never store derived data in state — compute it from source

## Accessibility
- Use semantic HTML elements (`<button>`, `<nav>`, `<main>`, not `<div>` for everything)
- All interactive elements must be fully keyboard accessible (Tab, Enter, Escape)
- All images must have meaningful `alt` text (or `alt=""` if decorative)
- Color contrast must meet WCAG 2.1 AA (4.5:1 for normal text)
- Form inputs must have associated labels
- ARIA labels required on all icon-only buttons and form controls
- All animations must be skippable and respect `prefers-reduced-motion` media query
- Scalable text and colorblind-safe design are mandatory, not optional
- Every data-fetching UI must handle three states: loading, error, and empty

## Content & Localization
- All user-facing strings go through the i18n/localization layer
- No hardcoded currency symbols, date formats, or number separators
- RTL layout must be considered for all new UI

## Performance
- Lazy-load routes and heavy components
- No synchronous operations blocking the main thread
- Images must have explicit width/height to prevent layout shift (CLS)
- Avoid re-renders caused by unstable references (useMemo/useCallback where appropriate)
- Test all screens at minimum and maximum supported viewport sizes
