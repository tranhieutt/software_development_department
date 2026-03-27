# Frontend Code Standards

Applies to: `src/frontend/**`, `src/components/**`, `src/pages/**`, `src/app/**`, `src/views/**`

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
- All interactive elements must be keyboard-operable
- All images must have meaningful `alt` text (or `alt=""` if decorative)
- Color contrast must meet WCAG 2.1 AA (4.5:1 for normal text)
- Form inputs must have associated labels

## Content & Localization
- All user-facing strings go through the i18n/localization layer
- No hardcoded currency symbols, date formats, or number separators
- RTL layout must be considered for all new UI

## Performance
- Lazy-load routes and heavy components
- No synchronous operations blocking the main thread
- Images must have explicit width/height to prevent layout shift (CLS)
- Avoid re-renders caused by unstable references (useMemo/useCallback where appropriate)
