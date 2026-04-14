# Report & Plan: `create-sdd` npm Package + CLI

**Date:** 2026-04-14  
**Author:** tranhieutt  
**Status:** Planning  
**Target repo:** https://github.com/tranhieutt/sdd-cli

---

## 1. Tổng quan

Bộ SDD (Software Development Department) hiện là một Claude Code configuration framework thuần file-based. Mục tiêu là đóng gói thành **npm package** có thể cài đặt qua một lệnh duy nhất:

```bash
npx create-sdd my-project
```

---

## 2. Phân tích SDD hiện tại

| Thành phần | Số lượng | Mô tả |
|---|---|---|
| `.claude/agents/` | 27 files | Agent definitions (backend, frontend, QA, v.v.) |
| `.claude/skills/` | 115 files | Slash command skills |
| `.claude/rules/` | 13 files | Domain coding rules |
| `.claude/hooks/` | 11 files | Bash lifecycle hooks |
| `.claude/docs/` | 12 files | Internal documentation |
| `.claude/memory/` | 6 files | Memory system templates |
| `settings.json` | 1 file | Claude Code permissions + hook wiring |
| `CLAUDE.md` | 1 file | Master configuration |

**Tổng:** ~186 files cần bundle vào package.

---

## 3. Architectural Decisions

| Quyết định | Lựa chọn đã chốt | Lý do |
|---|---|---|
| Package name | `create-sdd` | Tương thích `npx create-*` convention của npm |
| Language | TypeScript | Type safety cho file ops, dễ maintain |
| Template storage | Bundled trong package | Offline-first, không phụ thuộc network khi install |
| Interactive library | `@clack/prompts` | UX đẹp hơn inquirer, bundle nhỏ hơn |
| File operations | `fs-extra` | Promise-based, cross-platform (Win/Mac/Linux) |
| Upgrade mechanism | Fetch từ GitHub releases | Templates luôn latest mà không cần publish lại npm |
| Monorepo | Single package (Phase 1) | YAGNI — tách ra nếu traction tốt |

---

## 4. Cấu trúc Package

```
create-sdd/
├── package.json              # name: "create-sdd", bin: {create-sdd, sdd}
├── tsconfig.json
├── .gitignore
├── README.md
├── src/
│   ├── index.ts              # CLI entry: route create-sdd vs sdd subcommands
│   ├── commands/
│   │   ├── create.ts         # npx create-sdd (tạo project mới)
│   │   ├── init.ts           # sdd init (thêm vào project có sẵn)
│   │   ├── upgrade.ts        # sdd upgrade (cập nhật templates)
│   │   └── add.ts            # sdd add <module> (thêm module lẻ)
│   ├── prompts/
│   │   ├── stack.ts          # Hỏi Language, Framework, DB
│   │   └── modules.ts        # Checkbox: skills/rules/hooks/memory/agents
│   ├── template/
│   │   ├── engine.ts         # Replace {{PLACEHOLDERS}} trong CLAUDE.md
│   │   └── installer.ts      # Copy files, detect conflicts, merge settings
│   └── utils/
│       ├── version.ts        # SDD version tracking trong target project
│       └── github.ts         # Fetch latest release cho sdd upgrade
├── templates/                # Bundled SDD files (copy từ SDD repo)
│   ├── CLAUDE.md.template    # Với {{LANGUAGE}}, {{FRAMEWORK}} placeholders
│   ├── .claude/
│   │   ├── agents/
│   │   ├── skills/
│   │   ├── rules/
│   │   ├── hooks/
│   │   ├── docs/
│   │   └── memory/
│   └── settings.json.template
└── dist/                     # Compiled output (gitignored)
```

---

## 5. CLI Commands Design

```bash
# ── Tạo project mới ──────────────────────────────
npx create-sdd my-project       # interactive setup
npx create-sdd .                # current directory
npx create-sdd my-project --stack ts-nextjs    # preset, bỏ qua prompts
npx create-sdd my-project --minimal            # chỉ CLAUDE.md + core rules

# ── Trong project có sẵn ─────────────────────────
sdd init                        # interactive setup
sdd init --stack py-fastapi     # preset stack
sdd init --minimal              # install tối giản

# ── Thêm module lẻ ───────────────────────────────
sdd add skills                  # install/update toàn bộ skills
sdd add hooks                   # install hooks
sdd add memory                  # install memory system
sdd add agents                  # install agent definitions
sdd add rules                   # install coding rules

# ── Upgrade ──────────────────────────────────────
sdd upgrade                     # fetch + merge latest templates
sdd upgrade --dry-run           # preview changes, không write
sdd upgrade --module skills     # upgrade chỉ 1 module

# ── Info ─────────────────────────────────────────
sdd status                      # show installed version, modules
sdd list skills                 # list available skills
```

---

## 6. Preset Stacks

| Preset key | Language | Framework | DB |
|---|---|---|---|
| `ts-nextjs` | TypeScript | Next.js | PostgreSQL |
| `ts-react` | TypeScript | React + Vite | - |
| `py-fastapi` | Python | FastAPI | PostgreSQL |
| `py-django` | Python | Django | PostgreSQL |
| `go-gin` | Go | Gin | PostgreSQL |
| `js-express` | JavaScript | Express | MongoDB |

---

## 7. Implementation Plan

### Phase 1: Package Foundation
- [ ] **1.1** Khởi tạo `create-sdd/` với `package.json`, `tsconfig.json`, `.gitignore`
- [ ] **1.2** Cài dependencies: `@clack/prompts`, `fs-extra`, `chalk`, `commander`
- [ ] **1.3** Cấu hình `bin` field: `{"create-sdd": "./dist/index.js", "sdd": "./dist/index.js"}`
- [ ] **1.4** Viết `src/index.ts` — router điều hướng `create-sdd` vs `sdd <subcommand>`
- [ ] **1.5** Setup build pipeline: `tsc` → `dist/`, add `prepublish` script

### Phase 2: Template System
- [ ] **2.1** Copy toàn bộ `.claude/` từ SDD repo vào `templates/.claude/`
- [ ] **2.2** Tạo `CLAUDE.md.template` — thay hardcoded values bằng `{{PLACEHOLDERS}}`
- [ ] **2.3** Tạo `settings.json.template` — parametric hooks config
- [ ] **2.4** Viết `template/engine.ts` — replace placeholders, conditional blocks `{{#if FEATURE}}`
- [ ] **2.5** Viết `template/installer.ts` — copy files, detect conflicts, merge thay vì overwrite

### Phase 3: Interactive Prompts
- [ ] **3.1** Viết `prompts/stack.ts` — hỏi Language, Framework, DB, CI/CD
- [ ] **3.2** Viết `prompts/modules.ts` — checkbox chọn modules
- [ ] **3.3** Map stack answers → CLAUDE.md placeholder values
- [ ] **3.4** Thêm preset stacks (ts-nextjs, py-fastapi, go-gin, ...)

### Phase 4: `create` Command
- [ ] **4.1** Viết `commands/create.ts` — validate dir, run prompts, install templates
- [ ] **4.2** Inject SDD version vào `.claude/sdd-version.json` sau khi install
- [ ] **4.3** Detect existing git, cảnh báo nếu có file conflict
- [ ] **4.4** In success message với next steps

### Phase 5: `init` Command
- [ ] **5.1** Viết `commands/init.ts` — detect existing `.claude/`, offer merge vs overwrite
- [ ] **5.2** Merge `settings.json` thông minh (append hooks, không xóa user settings)
- [ ] **5.3** Không overwrite `MEMORY.md` nếu đã có nội dung user

### Phase 6: `upgrade` Command
- [ ] **6.1** Viết `utils/github.ts` — fetch latest release từ GitHub API
- [ ] **6.2** Viết `commands/upgrade.ts` — so sánh version, liệt kê files thay đổi
- [ ] **6.3** `--dry-run` mode: in diff, không write
- [ ] **6.4** Preserve user customizations qua checksum detection

### Phase 7: `add` Command
- [ ] **7.1** Viết `commands/add.ts` — install/update single module
- [ ] **7.2** Module registry: map module name → template subfolder
- [ ] **7.3** Idempotent: chạy lại không duplicate files

### Phase 8: Publish
- [ ] **8.1** Viết `README.md` cho npm package
- [ ] **8.2** Setup GitHub Actions: test → build → publish on tag
- [ ] **8.3** `npm publish --dry-run` kiểm tra package contents
- [ ] **8.4** Publish lên npmjs.com
- [ ] **8.5** Tạo GitHub Release với changelog

---

## 8. Dependency List

```json
{
  "dependencies": {
    "@clack/prompts": "^0.9.x",
    "chalk": "^5.x",
    "commander": "^12.x",
    "fs-extra": "^11.x"
  },
  "devDependencies": {
    "@types/fs-extra": "^11.x",
    "@types/node": "^20.x",
    "typescript": "^5.x"
  }
}
```

---

## 9. Roadmap

```
Phase 1-3: Foundation + Templates + Prompts
  → Deliverable: npx create-sdd chạy được locally

Phase 4-5: create + init commands
  → Deliverable: End-to-end install flow hoạt động

Phase 6-7: upgrade + add commands
  → Deliverable: Full CLI feature set

Phase 8: Publish
  → Deliverable: Live trên npmjs.com
```

---

## 10. Ghi chú kỹ thuật

- `settings.json` merge cần cẩn thận: `hooks` array phải được **append**, không **replace**
- Trên Windows, bash hooks cần check `git-bash` / `wsl` availability
- `templates/` directory cần exclude `.claude/memory/archive/` — đây là runtime data, không phải template
- SDD version tracking: lưu vào `.claude/sdd-version.json` với format `{"version": "1.x.x", "installedAt": "ISO date", "modules": [...]}`
