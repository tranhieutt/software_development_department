---
name: backend-patterns
type: reference
description: "Applies production backend patterns: middleware, error handling, auth, database integration, and API design. Use when working with backend service files or when the user mentions Express, Fastify, NestJS, backend patterns, or service architecture."
paths: ["**/*.ts", "**/*.js", "**/server.*", "**/app.*", "**/routes/**"]
effort: 3
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
context: fork
agent: backend-developer
user-invocable: true
when_to_use: "When building Node.js backend services with Express, Fastify, or similar frameworks"
---

# Backend Patterns

## Critical rules (non-obvious)

- **Always handle async errors in Express**: unhandled promise rejections crash the process; use `express-async-errors` or wrap every async handler
- **Never trust `req.body` size**: set `limit` on body-parser; default 100kb is too large for some, too small for others
- **`process.env` access at import time**: if accessed before `dotenv.config()`, value is undefined; call config() first in entry file
- **Connection pool misconfiguration**: default pool size (10) will exhaust under load; set `pool.max` based on `(num_cores * 2) + effective_spindle_count`
- **`res.json()` after `res.send()`**: causes "Cannot set headers after they are sent" — always `return` after sending response

## Express: production setup

```typescript
import express from "express";
import "express-async-errors";  // patches async error handling globally
import helmet from "helmet";
import { rateLimit } from "express-rate-limit";

const app = express();

app.use(helmet());
app.use(express.json({ limit: "10kb" }));
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));

// Routes
app.use("/api/v1/users", userRouter);
app.use("/api/v1/products", productRouter);

// 404 handler — must come after all routes
app.use((req, res) => res.status(404).json({ error: "Not found" }));

// Global error handler — must have 4 params
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  const status = err instanceof AppError ? err.statusCode : 500;
  res.status(status).json({ error: err.message });
});
```

## Repository pattern

```typescript
interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  save(user: User): Promise<User>;
  delete(id: string): Promise<void>;
}

class PgUserRepository implements IUserRepository {
  constructor(private readonly db: Pool) {}

  async findById(id: string) {
    const { rows } = await this.db.query(
      "SELECT * FROM users WHERE id = $1 AND deleted_at IS NULL", [id]
    );
    return rows[0] ?? null;
  }
}
```

## Service layer with error types

```typescript
class AppError extends Error {
  constructor(public message: string, public statusCode: number) { super(message); }
}
class NotFoundError extends AppError { constructor(msg: string) { super(msg, 404); } }
class ForbiddenError extends AppError { constructor(msg: string) { super(msg, 403); } }

class UserService {
  async getUser(id: string, requesterId: string): Promise<User> {
    const user = await this.repo.findById(id);
    if (!user) throw new NotFoundError(`User ${id} not found`);
    if (user.id !== requesterId && !isAdmin(requesterId)) throw new ForbiddenError("Access denied");
    return user;
  }
}
```

## JWT middleware

```typescript
import jwt from "jsonwebtoken";

export function authenticate(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) return res.status(401).json({ error: "No token" });
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET!) as JWTPayload;
    next();
  } catch {
    res.status(401).json({ error: "Invalid token" });
  }
}
```

## Database connection with retry

```typescript
import { Pool } from "pg";

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,              // pool size
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 2_000,
});

// Test connection on startup
async function connectWithRetry(retries = 5, delay = 2000) {
  for (let i = 0; i < retries; i++) {
    try {
      await pool.query("SELECT 1");
      console.log("DB connected");
      return;
    } catch (err) {
      if (i === retries - 1) throw err;
      await new Promise(r => setTimeout(r, delay * (i + 1)));  // exponential backoff
    }
  }
}
```

## Graceful shutdown

```typescript
const server = app.listen(PORT);

async function shutdown(signal: string) {
  console.log(`${signal} received. Shutting down gracefully.`);
  server.close(async () => {
    await pool.end();  // drain DB connections
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10_000);  // force exit after 10s
}

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));
```

## Common pitfalls

| Pitfall | Fix |
|---|---|
| Async handler without try/catch | Use `express-async-errors` package |
| `await` inside `forEach` | Use `Promise.all(array.map(async...))` |
| Logging raw errors to client | Log internally; return sanitized message to client |
| Missing `return` after `res.json()` | Always `return res.json(...)` to stop execution |
| Secrets in `config.js` | Use `process.env` + validation on startup |
