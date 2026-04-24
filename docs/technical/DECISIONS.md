# Architecture Decision Log

> **Owner**: @technical-director (implementation ADRs), @cto (strategic ADRs)
> **Format**: Append-only — never delete or overwrite existing entries. Add new ADRs at the bottom.
> **Purpose**: Quick-reference log for all architectural decisions. Read by `/orchestrate` in Phase 1 to understand prior constraints before planning execution.
>
> For full detailed ADRs (with alternatives, migration plans, validation
> criteria), see `docs/internal/adr/ADR-*.md`.
> Both must be kept in sync: when `/architecture-decision-records` creates a
> detailed ADR file, a summary entry is appended here.

---

## ADR Format

```markdown
## ADR-NNN: [Short Title]

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-NNN
**Deciders**: [Name(s) / @agent]
**Detailed ADR**: [docs/internal/adr/ADR-NNN-slug.md](../internal/adr/ADR-NNN-slug.md)

### Context
[One paragraph: what situation or problem prompted this decision.]

### Decision
[One paragraph: what was decided and the primary reason why.]

### Consequences
- **Positive**: [Key benefit]
- **Negative**: [Key trade-off accepted]
```

---

## Decision Index

| ADR | Title | Status | Date | Decider |
| --- | --- | --- | --- | --- |
| 001 | ESM vs CJS Npm Package Compatibility | Accepted | 2026-04-03 | @technical-director |
| 002 | Puppeteer Launch Config for Serverless | Accepted | 2026-04-03 | @devops-engineer |
| 006 | Shared State Adoption as Tier 2 Evolution of SDD Coordination | Accepted | 2026-04-23 | User, @technical-director |
| 007 | Shared SDD Core with Dual Execution Lanes for Claude and Codex | Accepted | 2026-04-24 | User, @technical-director |

---

<!-- ADR entries go below this line, appended in order -->

## ADR-001: ESM vs CJS Npm Package Compatibility

**Date**: 2026-04-03
**Status**: Accepted
**Deciders**: @technical-director, @backend-developer
**Source**: Crawler Webgame — Lesson #3, #4

### Context
Khi dự án Crawler sử dụng `google-spreadsheet@5`, package này phụ thuộc vào `ky` — một thư viện ESM-only. Toàn bộ project viết bằng CommonJS (`require()`), dẫn đến lỗi `ERR_REQUIRE_ESM` không thể khắc phục bằng `npm overrides`. Ngoài ra, API breaking changes giữa các major version (v4 bỏ `useServiceAccountAuth()`) gây mất thời gian debug.

### Decision
1. **Trước khi chọn npm package**, PHẢI kiểm tra tương thích ESM/CJS với hệ thống module hiện tại.
2. **Pin exact version** trong `package.json` cho các thư viện core (database, auth, API clients).
3. **Luôn đọc CHANGELOG** của thư viện khi gặp lỗi `xxx is not a function` — đây thường là dấu hiệu của breaking change giữa major versions.

### Consequences
- **Positive**: Tránh mất hàng giờ debug lỗi module incompatibility; rollback dễ dàng nhờ pin version.
- **Negative**: Cần thêm bước kiểm tra thủ công trước khi `npm install` (chưa tự động hóa).

---

## ADR-002: Puppeteer Launch Config for Serverless (Cloud Run)

**Date**: 2026-04-03
**Status**: Accepted
**Deciders**: @devops-engineer, @backend-developer
**Source**: Crawler Webgame — Lesson #5, #6, #7

### Context
Khi deploy Puppeteer lên Google Cloud Run, gặp 3 vấn đề liên tiếp:
1. **gen1 sandbox (gVisor)** chặn syscall cần thiết cho Chrome → Puppeteer không launch.
2. **Thiếu system dependencies** (`libasound.so.2`, `libgbm1`...) trong Docker image `node:18`.
3. **Cold start timeout** — Puppeteer mặc định 30s không đủ cho môi trường serverless.

### Decision
1. **Bắt buộc `--execution-environment gen2`** cho mọi Cloud Run service cần headless browser.
2. **Sử dụng Dockerfile template chuẩn** tại `infra/templates/Dockerfile.puppeteer` với đầy đủ Chrome dependencies.
3. **Puppeteer launch args chuẩn** cho serverless:
   ```javascript
   { timeout: 60000, args: ['--no-sandbox', '--disable-setuid-sandbox',
     '--disable-dev-shm-usage', '--single-process', '--no-zygote', '--disable-gpu'] }
   ```

### Consequences
- **Positive**: Mọi project cần scraping/automation có template sẵn, deploy xong chạy ngay lần đầu.
- **Negative**: gen2 tốn tài nguyên hơn gen1; image Docker lớn hơn ~200MB do Chrome deps.

---

## ADR-006: Shared State Adoption as Tier 2 Evolution of SDD Coordination

**Date**: 2026-04-23
**Status**: Accepted
**Deciders**: User, @technical-director
**Detailed ADR**: [docs/internal/adr/ADR-006-shared-state-adoption.md](../internal/adr/ADR-006-shared-state-adoption.md)

### Context
SDD completed enough Tier 1 harness infrastructure for agents to exist, route,
recover, and persist state, but shared operational truth remained fragmented
across specs, coordination policy, ledgers, memory, and planned API documents.
The earlier "Coordination Engineering" framing risked over-building autonomous
negotiation before source-of-truth authority and adoption were clear.

### Decision
Adopt Tier 2 Shared State Adoption and Source-of-Truth Consolidation as the next
SDD direction. Create authority clarity first, then adopt existing shared-state
infrastructure, and defer full Coordination Engineering until measurable
thresholds justify it.

### Consequences
- **Positive**: Gives SDD a bounded path from harness infrastructure to shared
  truth without bypassing human, producer, technical-director, or Rule 3
  authority.
- **Negative**: Adds registry/API reference maintenance burden and defers Tier 3
  coordination automation until adoption metrics support it.

---

## ADR-007: Shared SDD Core with Dual Execution Lanes for Claude and Codex

**Date**: 2026-04-24
**Status**: Accepted
**Deciders**: User, @technical-director
**Detailed ADR**: [docs/internal/adr/ADR-007-shared-sdd-core-dual-execution-lanes.md](../internal/adr/ADR-007-shared-sdd-core-dual-execution-lanes.md)

### Context
The intended product-development model is to use both Claude and Codex in the
same SDD-governed repository for CRM, SaaS, and AI Agent work. The challenge is
to exploit each runtime's strengths without creating two divergent process
systems or two competing sources of truth.

### Decision
Operate SDD as one shared core with two lanes: Claude as the default control
plane for DEFINE/PLAN/REVIEW and high-risk escalation, and Codex as the default
execution plane for scoped BUILD work, local verification, and terminal-heavy
implementation.

### Consequences
- **Positive**: Preserves one source of truth while exploiting both runtimes'
  strengths.
- **Negative**: Requires explicit handoff discipline and continued Codex adapter
  maintenance instead of a full native Codex runtime.
