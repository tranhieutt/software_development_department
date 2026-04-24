---
name: frontend-patterns
type: reference
description: "Framework-agnostic React/Vue patterns â€” component composition, hooks, TanStack Query, memoization, error boundaries. Use for generic React/Vue work (Vite, CRA, Storybook). For Next.js App Router / Server Components specifically, use `senior-frontend` instead."
paths: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/components/**"]
effort: 3
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
when_to_use: "When building React/Vue components, hooks, state management, or client-side performance â€” NOT for Next.js App Router (see `senior-frontend`)"
---

# Frontend Patterns

## Critical rules (non-obvious)

- **Stale closure in `useEffect`**: always list all dependencies; use `useRef` for values that shouldn't trigger re-run
- **`useEffect` with `async`**: never make the callback `async` directly â€” create inner async fn and call it
- **Object/array as dependency**: memoize with `useMemo`/`useCallback` or use primitive values; otherwise infinite loop
- **Key prop on lists**: use stable IDs, never `index` when list can reorder or items get deleted
- **`React.memo` is not free**: only wrap components with expensive renders and stable prop references

## Component composition patterns

```tsx
// Compound component with Context
const TabsContext = createContext<{ active: string; setActive: (v: string) => void } | null>(null);

function Tabs({ children, defaultValue }: { children: React.ReactNode; defaultValue: string }) {
  const [active, setActive] = useState(defaultValue);
  return <TabsContext.Provider value={{ active, setActive }}>{children}</TabsContext.Provider>;
}
Tabs.Trigger = function TabsTrigger({ value, children }: { value: string; children: React.ReactNode }) {
  const ctx = useContext(TabsContext)!;
  return <button onClick={() => ctx.setActive(value)} aria-selected={ctx.active === value}>{children}</button>;
};
Tabs.Content = function TabsContent({ value, children }: { value: string; children: React.ReactNode }) {
  const { active } = useContext(TabsContext)!;
  return active === value ? <>{children}</> : null;
};
```

## State management decision

| Scope | Solution |
|---|---|
| Single component | `useState`, `useReducer` |
| Subtree | Context + `useContext` |
| Client global (UI) | Zustand / Jotai |
| Server state (API) | TanStack Query |
| Form state | React Hook Form |
| URL state | `useSearchParams` (Next.js) |

## Data fetching with TanStack Query

```tsx
// Fetch
const { data, isLoading, error } = useQuery({
  queryKey: ["products", filters],   // filters in key â†’ auto-refetch on change
  queryFn: () => api.getProducts(filters),
  staleTime: 5 * 60 * 1000,          // don't refetch for 5 min
});

// Mutate with optimistic update
const mutation = useMutation({
  mutationFn: api.updateProduct,
  onMutate: async (newProduct) => {
    await queryClient.cancelQueries({ queryKey: ["products"] });
    const prev = queryClient.getQueryData(["products"]);
    queryClient.setQueryData(["products"], (old) => old.map(p => p.id === newProduct.id ? newProduct : p));
    return { prev };
  },
  onError: (_, __, ctx) => queryClient.setQueryData(["products"], ctx?.prev),
  onSettled: () => queryClient.invalidateQueries({ queryKey: ["products"] }),
});
```

## Performance: avoid re-renders

```tsx
// Memoize expensive component
const ExpensiveList = memo(({ items }: { items: Item[] }) => (
  <ul>{items.map(item => <li key={item.id}>{item.name}</li>)}</ul>
));

// Stable callback reference
const handleClick = useCallback((id: string) => {
  onSelect(id);
}, [onSelect]);  // only recreate if onSelect changes

// Expensive calculation
const sorted = useMemo(() =>
  items.sort((a, b) => b.score - a.score),
[items]);
```

## Code splitting

```tsx
const HeavyChart = lazy(() => import("./HeavyChart"));

function Dashboard() {
  return (
    <Suspense fallback={<Skeleton />}>
      <HeavyChart data={data} />
    </Suspense>
  );
}
```

## Custom hooks pattern

```tsx
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  return debounced;
}

function useLocalStorage<T>(key: string, initial: T) {
  const [value, setValue] = useState<T>(() => {
    try { return JSON.parse(localStorage.getItem(key) ?? "") ?? initial; }
    catch { return initial; }
  });
  const set = useCallback((v: T) => {
    setValue(v); localStorage.setItem(key, JSON.stringify(v));
  }, [key]);
  return [value, set] as const;
}
```

## Error boundaries

```tsx
class ErrorBoundary extends React.Component<{ fallback: React.ReactNode; children: React.ReactNode }> {
  state = { hasError: false };
  static getDerivedStateFromError() { return { hasError: true }; }
  componentDidCatch(error: Error) { console.error(error); }
  render() { return this.state.hasError ? this.props.fallback : this.props.children; }
}
// Usage: wrap async/complex sections, not entire app
```

## Common pitfalls

| Pitfall | Fix |
|---|---|
| Fetching in `useEffect` without cleanup | Use TanStack Query or abort controller |
| Context causes full tree re-render | Split context by domain; memoize value object |
| `useEffect` runs twice (StrictMode) | Design effects to be idempotent; use cleanup fn |
| Prop drilling > 3 levels | Lift to Context or state manager |
| Missing `loading` / `error` states | Always handle all 3 states: loading, error, data |
