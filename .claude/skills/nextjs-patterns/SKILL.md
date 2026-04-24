---
name: nextjs-patterns
type: reference
description: "Comprehensive Next.js development patterns for App Router, Server Components, TypeScript, and Tailwind CSS. Covers foundational principles, data fetching, routing, performance, and an 8-phase development workflow. Also includes Server Actions and Metadata patterns."
paths: ["**/*.tsx", "**/*.jsx", "**/next.config.*", "**/app/**/*.ts", "**/tailwind.config.*"]
when_to_use: "Building or optimizing Next.js 14+ / 15+ applications with App Router, Server Components, streaming, or Server Actions."
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
effort: 3
---

# Next.js Development Patterns

Comprehensive patterns and best practices for Next.js 14+ / 15+ App Router architecture, Server Components, and modern full-stack React development.

---

## 1. Foundational Principles

### Server vs Client Components
- **Server (Default):** Use for data fetching, layouts, and static content.
- **Client ('use client'):** Use for interactivity (useState, useEffect), event handlers, and browser-only APIs.
- **Decision Rule:** Stay on the server as long as possible. Split components so the interactive "leaf nodes" are client-side while the data-heavy "branch nodes" remain on the server.

### Routing & Organization
- **App Router:** Use the `app/` directory for file-based routing.
- **Route Groups:** `(group-name)` for organization without affecting URL structure.
- **Special Files:** `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`.
- **Advanced Routing:** Parallel routes (`@slot`) and Intercepting routes (`(.)`).

---

## 2. Data Fetching & Caching

### Strategy Matrix
| Pattern | Use Case | Implementation |
|---------|----------|----------------|
| **Static** | Blog posts, marketing | Cached at build time |
| **ISR** | Products, news | `revalidate: 60` |
| **Dynamic** | User dashboards, search | `no-store` or `force-dynamic` |

### Patterns
- **Server Fetching:** Fetch data directly in Server Components using `async/await`.
- **Streaming:** Use `Suspense` and `loading.tsx` to stream UI to the client.
- **Server Actions:** Perform mutations with `use server` functions. Validate with Zod.

---

## 3. 8-Phase Development Workflow

### Phase 1: Project Setup
Scaffold with `@app-builder`, configure TypeScript, and set up ESLint/Prettier.

### Phase 2: Component Architecture
Design hierarchy and implement base layout components using `@frontend-developer` and `@react-patterns`.

### Phase 3: Styling & Design
Configure Tailwind CSS v4 and design tokens using `@tailwind-patterns` and `@frontend-design`.

### Phase 4: Data Fetching
Implement Server Component data fetching and set up React Query/SWR if client-side fetching is needed.

### Phase 5: Routing & Navigation
Set up file-based routing, dynamic routes, and handle redirects/guards.

### Phase 6: Forms & Validation
Use React Hook Form and Zod for robust, type-safe data entry.

### Phase 7: Testing
Write unit/integration tests with Vitest and E2E flows with `@playwright-skill`.

### Phase 8: Optimization & Deploy
Analyze bundle size, optimize images with `next/image`, and deploy to Vercel/similar.

---

## 4. Performance & Metadata

- **Images:** Always use `next/image`. Set `priority` for LCP elements.
- **Dynamic Imports:** Use for heavy client-side libraries.
- **Metadata API:** Use `generateMetadata` for dynamic SEO tags per route.

---

## Resources & Anti-Patterns

- **implementation-playbook.md:** Detailed code examples for every pattern.
- **Anti-Pattern:** Using `'use client'` at the top level of every file.
- **Anti-Pattern:** Fetching data inside `useEffect` for information available on first load.

> **Guidance:** If you need deeper walkthroughs, refer to the `resources/` folder within this skill.
