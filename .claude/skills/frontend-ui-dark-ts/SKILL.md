---
name: frontend-ui-dark-ts
type: reference
description: "Builds dark-themed TypeScript UIs with accessible color systems, contrast compliance, and responsive design patterns. Use when implementing dark mode or building accessible TypeScript UI components."
paths: ["**/*.tsx", "**/*.ts", "**/*.css", "**/globals.css", "**/tailwind.config.*"]
effort: 3
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
when_to_use: "When implementing dark mode, designing accessible color systems, or building TypeScript UI components"
---

# Frontend UI Dark (TypeScript)

## Critical rules (non-obvious)

- **WCAG contrast minimums**: text on bg requires 4.5:1 (AA) or 7:1 (AAA); UI elements (borders, icons) require 3:1
- **Never use `prefers-color-scheme` media query alone** â€” users need a toggle; sync with `localStorage` to avoid flash on hydration
- **HSL for dark themes**: use `hsl(220 15% 10%)` not `#1a1a2e` â€” HSL lets you programmatically adjust lightness
- **Avoid pure black (`#000`)** for dark backgrounds â€” causes eye strain; use `hsl(220 15% 8%)` instead
- **`color-scheme: dark`** on `:root` makes browser UI (scrollbars, inputs) follow dark theme

## CSS variable token system

```css
/* globals.css */
:root {
  /* HSL values only (no hsl() wrapper) â€” allows opacity modifiers */
  --bg-base:        222 47% 8%;
  --bg-surface:     222 47% 12%;
  --bg-elevated:    222 47% 16%;
  --text-primary:   220 20% 95%;
  --text-secondary: 220 15% 70%;
  --text-muted:     220 10% 50%;
  --brand:          220 90% 60%;
  --brand-hover:    220 90% 65%;
  --border:         220 20% 20%;
  --error:          0 85% 60%;
  --success:        142 70% 45%;

  color-scheme: dark;
}

/* Light mode override */
[data-theme="light"] {
  --bg-base:        0 0% 100%;
  --bg-surface:     220 14% 96%;
  --bg-elevated:    0 0% 100%;
  --text-primary:   222 47% 11%;
  --text-secondary: 220 14% 40%;
  color-scheme: light;
}
```

## Theme provider (React + no flash)

```typescript
// providers/ThemeProvider.tsx
export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<"dark" | "light">(() =>
    typeof window !== "undefined"
      ? (localStorage.getItem("theme") as "dark" | "light") ?? "dark"
      : "dark"
  );

  useEffect(() => {
    document.documentElement.dataset.theme = theme;
    localStorage.setItem("theme", theme);
  }, [theme]);

  return (
    <ThemeContext.Provider value={{ theme, toggle: () => setTheme(t => t === "dark" ? "light" : "dark") }}>
      {children}
    </ThemeContext.Provider>
  );
}

// Prevent flash â€” add to <head> before React hydrates
const themeScript = `
  (function() {
    var t = localStorage.getItem('theme') || 'dark';
    document.documentElement.dataset.theme = t;
  })();
`;
```

## Accessible component patterns

```typescript
// Button with all a11y attributes
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "ghost" | "danger";
  isLoading?: boolean;
}

export function Button({ variant = "primary", isLoading, children, disabled, ...props }: ButtonProps) {
  return (
    <button
      {...props}
      disabled={disabled || isLoading}
      aria-busy={isLoading}
      aria-disabled={disabled || isLoading}
      className={cn(
        "inline-flex items-center gap-2 rounded-md px-4 py-2 font-medium transition-colors",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[hsl(var(--brand))]",
        "disabled:pointer-events-none disabled:opacity-50",
        variant === "primary" && "bg-[hsl(var(--brand))] text-white hover:bg-[hsl(var(--brand-hover))]",
        variant === "ghost" && "hover:bg-[hsl(var(--bg-surface))]",
        variant === "danger" && "bg-[hsl(var(--error))] text-white",
      )}
    >
      {isLoading && <Spinner aria-hidden="true" />}
      {children}
    </button>
  );
}
```

## Color utility function

```typescript
// Use CSS variables with alpha
function token(variable: string, alpha?: number): string {
  return alpha !== undefined
    ? `hsl(var(--${variable}) / ${alpha})`
    : `hsl(var(--${variable}))`;
}

// Usage: token("brand", 0.2) â†’ "hsl(var(--brand) / 0.2)"
```

## Tailwind dark theme config (v3)

```javascript
// tailwind.config.ts
export default {
  darkMode: ["class", '[data-theme="dark"]'],  // class-based, controlled by JS
  theme: {
    extend: {
      colors: {
        bg: {
          base:     "hsl(var(--bg-base) / <alpha-value>)",
          surface:  "hsl(var(--bg-surface) / <alpha-value>)",
          elevated: "hsl(var(--bg-elevated) / <alpha-value>)",
        },
        text: {
          primary:   "hsl(var(--text-primary) / <alpha-value>)",
          secondary: "hsl(var(--text-secondary) / <alpha-value>)",
        },
        brand: "hsl(var(--brand) / <alpha-value>)",
      }
    }
  }
}
```

## Contrast checker utility

```typescript
// Quick WCAG contrast ratio check
function getContrastRatio(fg: string, bg: string): number {
  // parse HSL â†’ luminance â†’ ratio
  // Use online tool: https://webaim.org/resources/contrastchecker/
  // Or: colord(fg).contrast(colord(bg))
}

// Minimum ratios:
// 4.5:1 â†’ AA normal text
// 3.0:1 â†’ AA large text (18pt+ or 14pt bold), UI components
// 7.0:1 â†’ AAA normal text
```

## Common pitfalls

| Pitfall | Fix |
|---|---|
| Flash of wrong theme on page load | Add inline script to `<head>` before hydration |
| Using `opacity` for text variants | Use separate CSS token with correct contrast ratio |
| Dark text (`gray-900`) on dark bg | Always test contrast; use `--text-primary` token |
| Hover states not visible in dark mode | Ensure hover has â‰¥3:1 contrast vs default state |
| `currentColor` for icons | Verify icon color passes 3:1 contrast vs background |
