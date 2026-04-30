---
name: fastapi-pro
type: reference
description: "Production FastAPI patterns — async endpoints, SQLAlchemy 2.0 async, Pydantic V2, dependency injection, JWT auth, testing. Use for Python 3.11+ FastAPI backends. NOT for Django (→ `django-patterns`) or Node.js (→ `backend-patterns`)."
paths: ["**/*.py", "**/requirements*.txt", "**/pyproject.toml", "**/main.py", "**/app/**/*.py"]
effort: 3
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
when_to_use: "When building async FastAPI APIs with SQLAlchemy 2.0 async + Pydantic V2 — endpoints, auth, DB session handling, testing, deployment"
---

# FastAPI Production Patterns

## Critical rules (non-obvious)

- **`async def` endpoint blocking sync DB call** → blocks entire event loop. Either use `async` DB driver (asyncpg/aiomysql) throughout OR switch endpoint to plain `def` (FastAPI runs it in threadpool).
- **Pydantic V2 `model_config = ConfigDict(...)` replaces V1 `class Config`**. Forgetting this silently loses settings like `from_attributes=True` needed for ORM → DTO conversion.
- **`Depends()` caches per-request**: same dependency called twice in one request returns same instance. Don't rely on this for cross-request state — use app state / Redis instead.
- **SQLAlchemy 2.0 async session must not leak across requests**: always scope via `Depends` with `async with AsyncSession(...)` — raw module-level session causes `GreenletError` under load.
- **`BackgroundTasks` runs AFTER response sent in the same worker process**: if worker dies mid-task the work is lost. For durable background jobs use Celery / Dramatiq / ARQ.
- **Uvicorn `--workers N` forks processes — can't share in-memory state**. Use Redis or DB for any shared state (rate-limit counters, cache).

## Project layout

```
app/
├── main.py               # FastAPI() instance + lifespan
├── api/
│   ├── deps.py           # shared Depends (get_db, get_current_user)
│   └── v1/
│       ├── users.py      # APIRouter
│       └── products.py
├── core/
│   ├── config.py         # Pydantic Settings
│   ├── security.py       # JWT encode/decode, password hashing
│   └── db.py             # engine + AsyncSession factory
├── models/               # SQLAlchemy ORM models
├── schemas/              # Pydantic DTOs (Request/Response)
├── services/             # business logic (no framework coupling)
└── tests/
```

## Pydantic V2 settings + config

```python
# app/core/config.py
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="APP_")

    database_url: str = Field(..., description="postgresql+asyncpg://...")
    jwt_secret: str = Field(..., min_length=32)
    jwt_algorithm: str = "HS256"
    jwt_exp_minutes: int = 30
    cors_origins: list[str] = Field(default_factory=list)

settings = Settings()  # fails fast at import if required vars missing
```

## SQLAlchemy 2.0 async session (per-request)

```python
# app/core/db.py
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

engine = create_async_engine(
    settings.database_url,
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,          # reconnect on stale conns (LB idle timeout)
    echo=False,
)
SessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

# app/api/deps.py
from typing import AsyncIterator
from fastapi import Depends

async def get_db() -> AsyncIterator[AsyncSession]:
    async with SessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        # close is automatic via `async with`
```

## Lifespan + startup/shutdown

```python
# app/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: warm caches, test DB
    async with engine.begin() as conn:
        await conn.execute(text("SELECT 1"))
    yield
    # Shutdown: drain connections
    await engine.dispose()

app = FastAPI(title="My API", lifespan=lifespan)
```

## JWT auth with OAuth2PasswordBearer

```python
# app/core/security.py
from datetime import datetime, timedelta, timezone
from jose import jwt, JWTError
from passlib.context import CryptContext

pwd = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(p: str) -> str: return pwd.hash(p)
def verify_password(p: str, h: str) -> bool: return pwd.verify(p, h)

def create_access_token(sub: str) -> str:
    exp = datetime.now(timezone.utc) + timedelta(minutes=settings.jwt_exp_minutes)
    return jwt.encode({"sub": sub, "exp": exp}, settings.jwt_secret, settings.jwt_algorithm)

# app/api/deps.py
from fastapi import HTTPException, status
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        user_id: str = payload.get("sub")
    except JWTError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid token")
    user = await db.get(User, user_id)
    if not user:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "User not found")
    return user
```

## Endpoint pattern (thin controller, service below)

```python
# app/api/v1/users.py
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter(prefix="/users", tags=["users"])

@router.post("", response_model=UserOut, status_code=status.HTTP_201_CREATED)
async def create_user(
    payload: UserCreate,
    db: AsyncSession = Depends(get_db),
) -> UserOut:
    try:
        user = await user_service.create(db, payload)
    except DuplicateEmailError:
        raise HTTPException(status.HTTP_409_CONFLICT, "Email taken")
    return UserOut.model_validate(user)   # V2 from-attributes

@router.get("/{user_id}", response_model=UserOut)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current: User = Depends(get_current_user),
) -> UserOut:
    user = await db.get(User, user_id)
    if not user:
        raise HTTPException(status.HTTP_404_NOT_FOUND)
    if user.id != current.id and not current.is_admin:
        raise HTTPException(status.HTTP_403_FORBIDDEN)
    return UserOut.model_validate(user)
```

## Pydantic V2 schemas with `from_attributes`

```python
from pydantic import BaseModel, ConfigDict, EmailStr, Field

class UserBase(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    email: EmailStr
    full_name: str = Field(min_length=1, max_length=100)

class UserCreate(UserBase):
    password: str = Field(min_length=8, max_length=128)

class UserOut(UserBase):
    id: int
    created_at: datetime
```

## Global exception handler

```python
# app/main.py
from fastapi import Request
from fastapi.responses import JSONResponse

class AppError(Exception):
    def __init__(self, msg: str, status_code: int = 400):
        self.msg, self.status_code = msg, status_code

@app.exception_handler(AppError)
async def app_error_handler(req: Request, exc: AppError):
    return JSONResponse(status_code=exc.status_code, content={"error": exc.msg})

@app.exception_handler(Exception)
async def unhandled(req: Request, exc: Exception):
    logger.exception("Unhandled error", extra={"path": req.url.path})
    return JSONResponse(status_code=500, content={"error": "Internal server error"})
```

## Testing with pytest-asyncio

```python
# tests/conftest.py
import pytest_asyncio
from httpx import AsyncClient, ASGITransport

@pytest_asyncio.fixture
async def client():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c

@pytest_asyncio.fixture
async def db_session():
    async with SessionLocal() as s:
        yield s
        await s.rollback()  # isolate test

# tests/test_users.py
@pytest.mark.asyncio
async def test_create_user(client: AsyncClient):
    r = await client.post("/api/v1/users", json={"email": "a@b.com", "full_name": "A", "password": "pw12345678"})
    assert r.status_code == 201
    assert r.json()["email"] == "a@b.com"
```

## Production deployment (Uvicorn + Gunicorn)

```bash
# Dockerfile CMD — recommended for production
gunicorn app.main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --timeout 60 \
  --keep-alive 5 \
  --access-logfile -
```

Workers = `(2 × CPU) + 1` for CPU-bound; lower for IO-heavy async (async workers share event loop already).

## Common pitfalls

| Pitfall | Fix |
|---|---|
| `async def` + sync `psycopg2`/`pymysql` | Use `asyncpg` / `aiomysql` OR drop `async` on endpoint |
| `BaseSettings` V1 pattern (`class Config`) | V2 uses `model_config = SettingsConfigDict(...)` |
| `from_attributes=True` missing → validation error from ORM instance | Add to `ConfigDict` on every DTO reading from ORM |
| Forgetting `await` on SQLAlchemy 2.0 async query | Linter — use `sqlalchemy[asyncio]` type stubs + mypy |
| Returning ORM object → leaks relationships (N+1 on serialize) | Always `model_validate(orm_obj)` to scoped Pydantic DTO |
| `BackgroundTasks` for durable work | Switch to Celery / Dramatiq / ARQ |
| `CORSMiddleware` added AFTER auth middleware | CORS must be OUTERMOST — added first |
| `response_model` + return extra fields → silently stripped | Use `response_model_exclude_unset=True` consciously |

## Observability hooks

```python
# Structured logging
import structlog
logger = structlog.get_logger()

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start = time.monotonic()
    response = await call_next(request)
    logger.info("http_request",
        method=request.method, path=request.url.path,
        status=response.status_code,
        duration_ms=(time.monotonic() - start) * 1000,
    )
    return response
```

- Add `prometheus-fastapi-instrumentator` for `/metrics`.
- Health check: GET `/healthz` returns `{"status": "ok"}` + DB `SELECT 1`.
- Request ID: `X-Request-ID` header middleware → bind to contextvars for logging.
