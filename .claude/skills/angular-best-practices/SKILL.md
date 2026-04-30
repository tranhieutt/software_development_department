---
name: angular-best-practices
type: reference
description: "Provides Angular best practices for components, modules, services, and reactive patterns. Use when working with Angular TypeScript files, component templates, NgModules, RxJS observables, or when the user mentions Angular, ng, or Angular CLI."
paths: ["**/*.component.ts", "**/*.service.ts", "**/*.module.ts", "**/angular.json"]
effort: 3
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
when_to_use: "When building Angular applications or working with RxJS streams"
---

# Angular Best Practices

## Critical rules (non-obvious)

- **Always unsubscribe** from Observables in `ngOnDestroy` — use `takeUntilDestroyed()` (Angular 16+) or `Subject` + `takeUntil`
- **`ChangeDetectionStrategy.OnPush`**: component only updates when input reference changes or async pipe emits — use for all leaf components
- **Never mutate input objects/arrays**: OnPush won't detect mutation; create new reference instead
- **`trackBy` is mandatory on `*ngFor`** with dynamic lists — without it, every change re-renders all DOM nodes
- **`async` pipe auto-unsubscribes** — prefer it over manual subscription in templates

## Component with OnPush + signals (Angular 17+)

```typescript
@Component({
  selector: "app-product-list",
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @for (product of products(); track product.id) {
      <app-product-card [product]="product" />
    }
    @if (loading()) { <app-spinner /> }
  `,
})
export class ProductListComponent {
  products = input.required<Product[]>();
  loading = input(false);

  // Computed signal
  total = computed(() => this.products().length);
}
```

## Service with signals store pattern

```typescript
@Injectable({ providedIn: "root" })
export class CartService {
  private _items = signal<CartItem[]>([]);

  items = this._items.asReadonly();
  total = computed(() => this._items().reduce((sum, i) => sum + i.price * i.qty, 0));

  addItem(item: CartItem) {
    this._items.update(items =>
      items.some(i => i.id === item.id)
        ? items.map(i => i.id === item.id ? { ...i, qty: i.qty + 1 } : i)
        : [...items, { ...item, qty: 1 }]
    );
  }
}
```

## HTTP with interceptors

```typescript
// auth interceptor
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthService).token();
  if (!token) return next(req);
  return next(req.clone({ setHeaders: { Authorization: `Bearer ${token}` } })).pipe(
    catchError(err => {
      if (err.status === 401) inject(Router).navigate(["/login"]);
      return throwError(() => err);
    })
  );
};

// Register in app.config.ts
provideHttpClient(withInterceptors([authInterceptor]))
```

## RxJS: key operators (non-obvious behavior)

```typescript
// switchMap: cancels previous — good for search, bad for saves
search$.pipe(
  debounceTime(300),
  distinctUntilChanged(),
  switchMap(term => this.api.search(term))  // cancels in-flight request on new input
)

// exhaustMap: ignores new while processing — good for login button
loginClick$.pipe(
  exhaustMap(() => this.auth.login(credentials))  // prevents double-submit
)

// mergeMap: parallel — good for independent operations
ids$.pipe(mergeMap(id => this.api.fetch(id), 3))  // 3 concurrent max

// combineLatest vs withLatestFrom:
// combineLatest: emits when ANY source emits
// withLatestFrom: emits only when primary source emits, takes latest from secondary
primary$.pipe(withLatestFrom(secondary$))  // common for "take latest filter value on button click"
```

## Auto-unsubscribe pattern

```typescript
// Angular 16+ (preferred)
@Component({...})
export class MyComponent {
  private destroyRef = inject(DestroyRef);

  ngOnInit() {
    this.data$.pipe(takeUntilDestroyed(this.destroyRef)).subscribe(...);
  }
}

// Before Angular 16
export class MyComponent implements OnDestroy {
  private destroy$ = new Subject<void>();
  ngOnInit() { this.data$.pipe(takeUntil(this.destroy$)).subscribe(...); }
  ngOnDestroy() { this.destroy$.next(); this.destroy$.complete(); }
}
```

## Lazy loading + standalone components

```typescript
// app.routes.ts
export const routes: Routes = [
  {
    path: "admin",
    loadChildren: () => import("./admin/admin.routes").then(m => m.ADMIN_ROUTES),
    canMatch: [adminGuard],
  },
];

// Standalone component (Angular 15+)
@Component({
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule],
  template: `...`,
})
export class ProfileComponent {}
```

## Common pitfalls

| Pitfall | Fix |
|---|---|
| Memory leak from unsubscribed Observable | Use `takeUntilDestroyed()` or `async` pipe |
| `ExpressionChangedAfterChecked` error | Defer with `afterNextRender()` or move to signals |
| Heavy computation in template | Move to `computed()` signal or `pipe(map(...))` |
| `*ngIf` with `async` pipe fetches twice | Use `as` syntax: `*ngIf="data$ \| async as data"` |
| Zone.js performance in loops | Use `ChangeDetectionStrategy.OnPush` + signals |
