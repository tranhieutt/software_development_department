---
name: prisma-expert
type: reference
description: "Provides Prisma ORM patterns for schema design, migrations, query optimization, and relation modeling. Use when working with Prisma schema files (schema.prisma) or when the user mentions Prisma, Prisma migrations, or Prisma queries."
paths: ["**/prisma/**", "**/*.prisma", "**/schema.prisma"]
when_to_use: "When working with Prisma ORM for schema design, migrations, query optimization, or troubleshooting database operations"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
effort: 3
---

# Prisma Expert

## Critical rules (non-obvious)

- **Never use `migrate dev` in production** — use `migrate deploy`; `migrate dev` can reset data
- **Singleton client in serverless** — new `PrismaClient()` per request exhausts connections; use global singleton
- **`include` vs `select`**: `include: { posts: true }` fetches ALL post fields; use `select` to limit
- **`$queryRaw` returns unknown[]** — you must cast with `as` or validate; Prisma can't infer raw query types
- **Missing `@relation` on both sides** causes "The relation is not defined on both sides" runtime error

## Schema: canonical model structure

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  role      Role     @default(USER)
  posts     Post[]   @relation("UserPosts")
  profile   Profile? @relation("UserProfile")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
  @@map("users")
}

model Post {
  id       String  @id @default(cuid())
  title    String
  content  String?
  published Boolean @default(false)
  author   User    @relation("UserPosts", fields: [authorId], references: [id], onDelete: Cascade)
  authorId String

  @@index([authorId])
  @@map("posts")
}

enum Role { USER ADMIN MODERATOR }
```

## Query optimization: N+1 fix

```typescript
// ❌ N+1
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } });
}

// ✅ Include (fetches all post fields)
const users = await prisma.user.findMany({ include: { posts: true } });

// ✅✅ Select (fetch only needed fields — best for performance)
const users = await prisma.user.findMany({
  select: {
    id: true, email: true,
    posts: { select: { id: true, title: true } },
  },
});

// ✅ Complex aggregations → use raw
const result = await prisma.$queryRaw<{ id: string; count: number }[]>`
  SELECT u.id, COUNT(p.id)::int as count
  FROM users u LEFT JOIN posts p ON p.author_id = u.id
  GROUP BY u.id
`;
```

## Transactions

```typescript
// Sequential (auto-atomic, no rollback control)
const [user, profile] = await prisma.$transaction([
  prisma.user.create({ data: userData }),
  prisma.profile.create({ data: profileData }),
]);

// Interactive (full control, rollback on throw)
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData });
  if (user.email.endsWith("@blocked.com")) throw new Error("Blocked domain");
  return tx.profile.create({ data: { ...profileData, userId: user.id } });
}, {
  maxWait: 5000,
  timeout: 10000,
  isolationLevel: "Serializable",  // use ReadCommitted for most cases
});
```

## Singleton client (Next.js / serverless)

```typescript
// lib/prisma.ts
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === "development" ? ["query"] : [],
});

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

## Migration commands

```bash
# Development: creates migration file + applies
npx prisma migrate dev --name add_role_to_users

# Production: apply pending migrations only (safe)
npx prisma migrate deploy

# Check migration status
npx prisma migrate status

# Fix stuck migration
npx prisma migrate resolve --applied "20240115_migration_name"

# Validate schema (no DB connection needed)
npx prisma validate

# Format schema
npx prisma format
```

## Common pitfalls

| Pitfall | Fix |
|---|---|
| `migrate dev` in production | Use `migrate deploy` |
| New `PrismaClient()` per request | Use global singleton |
| `include: { all: true }` on large models | Use `select` to fetch only needed fields |
| P2034 (transaction conflict) | Retry with exponential backoff |
| Shadow database error in dev | Set `shadowDatabaseUrl` or use Neon branching |
| Enum not syncing | Run `migrate dev` after enum changes |
