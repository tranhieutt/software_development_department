# History Update Log

Tài liệu này ghi lại lịch sử cập nhật tài liệu và source code của **Software Development Department** template.

---

## 🗓️ Lịch sử cập nhật

---

### [v1.5.0] - 2026-03-28

**Chủ đề:** Dọn sạch game references trong toàn bộ `.claude/agents/`

**Dọn game references — SEVERE (5 agents):**

- `.claude/agents/accessibility-specialist.md` — Description: "game is playable" → "software is accessible"; xóa gamepad/Xbox/PlayStation/Switch/Pause lines; "quest reminders" → "Key action shortcuts"
- `.claude/agents/ai-programmer.md` — Description: "game AI / NPC behavior" → "intelligent system features / LLM integrations"; "NPCs, enemies" → "recommendations, predictions"; "player time to react" → "explainable and auditable"
- `.claude/agents/analytics-engineer.md` — Description: "player behavior tracking" → "user behavior tracking"; event examples `game.level.started`, `game.combat.enemy_killed` → `user.session.started`, `user.action.completed`; "game design decisions" → "product decisions"
- `.claude/agents/performance-analyst.md` — Description: "profiles game performance / frame time" → "profiles application performance / response time"; "Gameplay Logic" → "Business Logic"; "game state" → "application state"
- `.claude/agents/network-programmer.md` — Description: "multiplayer / netcode / matchmaking" → "real-time / WebSocket / event streaming"; "gameplay state" → "application state"; "entity interpolation" → "state interpolation"

**Dọn game references — MODERATE (5 agents):**

- `.claude/agents/producer.md` — "how other games handled" → "how other products handled"; "game design changes" → "product design changes"
- `.claude/agents/technical-director.md` — "how other games handled" → "how other products handled"
- `.claude/agents/qa-lead.md` — "Playtest Coordination" → "User Testing Coordination"; "gameplay impact" → "user impact"
- `.claude/agents/release-manager.md` — "player-facing messaging" → "user-facing messaging"
- `.claude/agents/security-engineer.md` — "multiplayer security" → "real-time and distributed system security"

---

### [v1.4.0] - 2026-03-28

**Chủ đề:** Review tổng thể lần 3 — Sửa số đếm, Mobile templates, Secrets rule, Dọn sạch game references

**Tính năng mới:**

- `.claude/docs/templates/mobile-architecture.md` — Template kiến trúc ứng dụng mobile (layers, navigation, state, offline, push notifications, security, testing)
- `.claude/docs/templates/app-store-submission-checklist.md` — Checklist submit App Store/Play Store (iOS + Android riêng biệt, legal, sign-offs)
- `.claude/rules/secrets-config.md` — Rule quản lý secrets & config (env vars, CI/CD secrets, forbidden patterns, logging scrubbing)

**Sửa số đếm trong docs:**

- `README.md`, `README_en.md` — Cập nhật đúng: 27 agents, 35 skills, 10 rules
- `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`, `.claude/docs/quick-start.md`, `.claude/docs/agent-roster.md` — Đồng bộ số đếm
- `.claude/docs/coding-standards.md` — Thêm cross-reference đến `secrets-config.md`

**Dọn game references — SEVERE (viết lại hoàn toàn):**

- `.claude/docs/templates/pitch-document.md` — "Game Pitch" → "Product Pitch", xóa "Audio Identity", "Player Fantasy" → "User Value Proposition", Steam/Console → Web/Mobile/SaaS
- `.claude/docs/templates/systems-index.md` — `design/gdd/` → `design/specs/`, "Gameplay" → "Business Logic", xóa category Audio, thêm Integrations

**Dọn game references — MODERATE:**

- `.claude/docs/templates/release-checklist-template.md` — FPS → API response time, xóa Xbox/PlayStation, Console section → Mobile section, ESRB/PEGI → generic
- `.claude/docs/templates/project-stage-report.md` — "Polish" → "Hardening", `design/levels/` → `design/specs/`
- `.claude/docs/templates/design-doc-from-implementation.md` — "Player-Facing" → "User-Facing", "Balance and Tuning" → "Configuration and Tuning", `/balance-check` → `/perf-profile`
- `.claude/docs/templates/architecture-doc-from-code.md` — "60 FPS" → "sub-100ms response time"

**Dọn game references — MINOR (9 files):**

- `changelog-template.md` — "player-visible" → "user-visible", "Healing potions" → API latency, "Thank you for playing!" → fixed
- `release-notes.md` — "players" → "users", "saved games" → "large datasets", "Thank you for playing!" → fixed
- `incident-response.md` — "player perspective/report" → "user perspective/report", "XP boost" → "service credit"
- `milestone-definition.md` — "Vertical Slice" → "Working Demo", "Gold" → "Release Candidate", FPS → API response time
- `technical-design-document.md` — "game design doc" → "product/feature spec"
- `test-plan.md` — "save files" → "test data, user accounts"
- `collaborative-protocols/implementation-agent-protocol.md` — "damage calculation" → "payment processing", `design/gdd/` → `design/specs/`
- `collaborative-protocols/design-agent-protocol.md` — "crafting system" → "notification system", "game design theory" → "UX/product design theory"
- `collaborative-protocols/leadership-agent-protocol.md` — "game-designer/crafting" → "product-manager/onboarding", "Hades" → "Basecamp"

---

### [v1.3.0] - 2026-03-28

**Chủ đề:** Bổ sung Mobile Development & Collaborative Design Principle

#### 📄 Tài liệu cập nhật
- `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` — Bổ sung nguyên tắc thiết kế cộng tác cho phát triển phần mềm; cập nhật ví dụ từ game design sang software engineering (auth API, JWT, database schema)
- `README.md` — Cập nhật nội dung hướng dẫn sử dụng template bằng tiếng Việt
- `README_en.md` — Cập nhật nội dung hướng dẫn sử dụng template bằng tiếng Anh
- `.claude/docs/agent-roster.md` — Cập nhật danh sách agent
- `.claude/docs/quick-start.md` — Cập nhật hướng dẫn bắt đầu nhanh

#### ✨ Tính năng mới
- `feat(mobile)`: Thêm **mobile-developer** agent và các mobile skills
- `.claude/docs/templates/app-store-submission-checklist.md` — Template checklist submit lên App Store
- `.claude/docs/templates/mobile-architecture.md` — Template kiến trúc ứng dụng mobile
- `.claude/rules/secrets-config.md` — Quy tắc quản lý secrets và config bảo mật

---

### [v1.2.0] - 2026-03-27

**Chủ đề:** Cải thiện Skills — Feature Spec & Brainstorming

#### 📄 Tài liệu cập nhật
- `fix(feature-spec)`: Viết lại skill **design-system** để phù hợp với feature specification phần mềm
- `fix(brainstorm)`: Viết lại skill **brainstorm** cho ngữ cảnh phát triển sản phẩm phần mềm

---

### [v1.1.0] - 2026-03-27

**Chủ đề:** Hoàn thiện Documentation & Hướng dẫn người dùng

#### 📄 Tài liệu cập nhật
- `docs`: Đổi tên `README` → `README_en` và `user_guide` → `README`
  (Hướng dẫn tiếng Việt trở thành README chính)
- `docs`: Thêm `user_guide.md` (README tiếng Việt) — hướng dẫn đầy đủ về cách sử dụng template
- `docs`: Cập nhật `README.md` — thêm URL clone chính xác và thông tin tác giả
- `LICENSE` — Cập nhật tên tác giả bản quyền

---

### [v1.0.0] - 2026-03-27

**Chủ đề:** Ra mắt — Chuyển đổi từ Game Studio → Software Department

#### 📄 Tài liệu khởi tạo
- `init`: Khởi tạo **Claude Code Software Development Department** template
- `cleanup`: Xóa toàn bộ tài liệu tham chiếu các game engine (Godot, Unity, Unreal Engine)
- `chore`: Chuyển đổi template từ "Game Studio" sang "Software Department":
  - Thay thế các vai trò game (Game Designer, Level Designer, VFX Artist) bằng vai trò phần mềm (CTO, Product Manager, Frontend/Backend/Fullstack Developer, Data Engineer, UX Researcher)
  - Cập nhật tất cả skills, workflows, và agent definitions sang ngữ cảnh software engineering
  - Cập nhật WORKFLOW-GUIDE.md với ví dụ thực tế về phát triển phần mềm

---

## 📌 Ghi chú

- **Versioning**: Theo [Semantic Versioning](https://semver.org/) — `MAJOR.MINOR.PATCH`
- **Format**: Mỗi entry ghi rõ ngày, chủ đề, và danh sách file thay đổi cụ thể
- **Mục đích**: Giúp team theo dõi tiến độ cập nhật tài liệu và hiểu lý do thay đổi

---

Last Updated: 2026-03-28 — v1.5.0
