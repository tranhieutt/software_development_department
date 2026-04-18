---
name: senior-frontend
type: reference
description: "Next.js App Router specific patterns — Server Components, Client Components boundary, parallel fetching, bundle analysis, a11y. Use ONLY for Next.js 13+ App Router projects. For generic React/Vue patterns, use `frontend-patterns` instead."
paths: ["**/app/**/*.tsx", "**/app/**/*.jsx", "**/next.config.*", "**/app/layout.tsx"]
when_to_use: "When building Next.js 13+ App Router applications with Server Components, NOT for generic React/Vue (see `frontend-patterns`)"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
effort: 3
---

# Senior Frontend

## Critical rules (non-obvious)

- **Always `return` in server components before client boundary** — mixing async server + client state without boundaries causes hydration mismatches
- **`priority` on LCP images only** — adding `priority` everywhere defeats preload budgets
- **`use client` at the leaf, not the root** — push client boundary as deep as possible to maximize RSC tree
- **Parallel data fetching in Server Components**: use `Promise.all([...])` at the page level, not sequential awaits
- **Bundle heavy deps**: `moment` (290KB) → `dayjs` (2KB); `lodash` → `lodash-es` with tree-shaking; `axios` → native `fetch`

## Next.js: server vs client boundary

```tsx
// Server Component (default) — fetch directly, no hooks
async function ProductPage({ params }: { params: { id: string } }) {
  const [product, reviews] = await Promise.all([  // parallel fetch
    getProduct(params.id),
    getReviews(params.id),
  ]);
  return (
    <div>
      <h1>{product.name}</h1>
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews productId={params.id} />  {/* can defer slow queries */}
      </Suspense>
      <AddToCartButton productId={product.id} />  {/* client boundary at leaf */}
    </div>
  );
}

// Client Component — only where interactivity needed
"use client";
function AddToCartButton({ productId }: { productId: string }) {
  const [adding, setAdding] = useState(false);
  return <button onClick={() => addToCart(productId)}>Add to Cart</button>;
}
```

## Next.js: config essentials

```js
// next.config.js
const nextConfig = {
  images: {
    remotePatterns: [{ hostname: "cdn.example.com" }],
    formats: ["image/avif", "image/webp"],
  },
  experimental: {
    optimizePackageImports: ["lucide-react", "@heroicons/react"],  // tree-shake icon libs
  },
};
```

## Component: TypeScript patterns

```tsx
// Generic list component
function List<T extends { id: string }>({ items, renderItem }: {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
}) {
  return <ul>{items.map(item => <li key={item.id}>{renderItem(item)}</li>)}</ul>;
}

// Props extending HTML element
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "ghost" | "danger";
  isLoading?: boolean;
}

export function Button({ variant = "primary", isLoading, children, ...props }: ButtonProps) {
  return (
    <button {...props} disabled={props.disabled || isLoading} aria-busy={isLoading}
      className={cn("px-4 py-2 rounded font-medium focus-visible:ring-2",
        variant === "primary" && "bg-blue-600 text-white hover:bg-blue-700",
        variant === "danger" && "bg-red-600 text-white",
        (props.disabled || isLoading) && "opacity-50 cursor-not-allowed"
      )}>
      {isLoading && <Spinner aria-hidden />}
      {children}
    </button>
  );
}
```

## Performance: bundle analysis

Common heavy deps to replace:

| Package | Size | Alternative |
|---|---|---|
| moment | 290KB | `dayjs` (2KB) or `date-fns` (12KB) |
| lodash | 71KB | `lodash-es` (tree-shakeable) |
| axios | 14KB | native `fetch` or `ky` (3KB) |
| @mui/material | Large | shadcn/ui or Radix UI |

```bash
# Analyze bundle
npx @next/bundle-analyzer  # or
npx vite-bundle-visualizer
```

## Accessibility essentials

```tsx
// Skip link — place before main nav
<a href="#main-content" className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4">
  Skip to main content
</a>

// Icon button — always label
<button type="button" aria-label="Close dialog" className="focus-visible:ring-2">
  <XIcon aria-hidden="true" />
</button>

// Minimum contrast: 4.5:1 for text, 3:1 for UI components
```

## Project structure (Next.js App Router)

```
app/
├── layout.tsx          # Root layout: fonts, providers, metadata
├── page.tsx
├── (auth)/             # Route group — no URL segment
│   ├── login/page.tsx
│   └── register/page.tsx
└── api/
    └── [route]/route.ts
components/
├── ui/                 # Button, Input, Card (reusable primitives)
└── features/           # Domain-specific composites
hooks/                  # useDebounce, useLocalStorage, useMediaQuery
lib/
├── utils.ts            # cn(), formatDate()
└── api.ts              # API client
types/                  # Shared TypeScript types
```
