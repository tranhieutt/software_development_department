# Optimization & Upgrade Plan (v1.6.x)

Tài liệu này tổng hợp các đề xuất tối ưu hóa kiến trúc và quy trình cho **Software Development Department** template. Mục tiêu của đợt nâng cấp này là hoàn thiện trải nghiệm AI-Driven Development, đặc biệt bù đắp các điểm mù về khôi phục luồng làm việc (context preservation) và định hướng cây mã nguồn (repository scaffolding).

---

## 1. Hoàn thiện Bộ khung Thư mục rỗng (Directory Scaffolding)

**Vấn đề:** 
Các thư mục cốt lõi của một dự án phần mềm như `src/`, `tests/`, `infra/`, `scripts/`, `design/` tuy có ghi trong sơ đồ `README`, nhưng lại chưa thực sự tồn tại trong Git tree (do Git bỏ qua thư mục rỗng). Khi agent bắt đầu code, chúng có xu hướng nhét file lung tung hoặc tự tạo lại cấu trúc thay vì theo quy chuẩn có sẵn.

**Giải pháp:**
Tạo sẵn các thư mục mỏ neo và đặt file `.gitkeep` hoặc `README.md` nhỏ gọn bên trong.

**Danh sách công việc (Checklist):**
- [ ] Thêm `src/.gitkeep`
- [ ] Thêm `tests/.gitkeep`
- [ ] Thêm `infra/.gitkeep`
- [ ] Thêm `scripts/.gitkeep`
- [ ] Thêm `design/README.md` (Hướng dẫn lưu trữ PRD, Wireframe ở đây)
- [ ] Cập nhật command `/sync-template` hoặc init process để giữ các thư mục này chuẩn mực.

---

## 2. Tiêu chuẩn hóa Quản lý .env (Secrets & Environment Config)

**Vấn đề:**
Rule `.claude/rules/secrets-config.md` đã có nhưng còn thiếu file mẫu gốc làm "kim chỉ nam". Nếu không có, Dev, DevOps, và Security agents vẫn có thể tranh cãi về cách đặt tên biến môi trường.

**Giải pháp:**
Cung cấp một file `.env.example` mặc định để các config (Database, API Keys, Tokens) tuân thủ theo.

**Danh sách công việc (Checklist):**
- [ ] Tạo file `.env.example` tại thư mục root.
- [ ] Bổ sung các biến môi trường mẫu, ví dụ: 
  ```env
  # Application config
  PORT=3000
  NODE_ENV=development

  # Database config
  DATABASE_URL=postgres://user:password@localhost:5432/dbname

  # Third-party APIs
  ANTHROPIC_API_KEY=your_api_key_here
  ```
- [ ] Cập nhật `.claude/rules/secrets-config.md` để trỏ trực tiếp đến `.env.example` cho context agents.

---

## 3. Persistent Session State (Bộ nhớ dài hạn cho AI)

**Vấn đề:**
Khi token chạm ngưỡng Maximum Context Window, hoặc terminal bị tắt đi bật lại, Claude Code sẽ "quên" mạch quy trình hiện tại (quên task nào đang làm dở, quyết định nào chốt hôm qua). Thư mục thư mục `production/session-state/` đã được lên kịch bản, nhưng thiếu công cụ đẩy dữ liệu vào.

**Giải pháp:**
Tạo Slash Command (Skill) mới để Force Dump ký ức trước khi Context bị reset. 

**Danh sách công việc (Checklist):**
- [ ] Tạo skill mới: `.claude/skills/save-state/`
- [ ] Phát triển workflow `/save-state`: Yêu cầu Content-agent tóm tắt bối cảnh đang thao tác (What was done, What's blocked, What to do next) vào file `production/session-state/active.md`.
- [ ] Tạo Hook `session-start-context-loader`: Kiểm tra xem file `active.md` có đang chứa tóm tắt của lần làm việc trước không, nếu có thì tự động nạp nó vào não bộ (System prompt/Context) ngay khi gọi `claude`.

---

## 4. Rõ ràng hóa Cấu trúc Kiến trúc (Codebase Navigation)

**Vấn đề:**
Khi dự án lớn lên (hàng trăm API, hàm dùng chung), làm sao AI biết "Auth system" hay "Hàm format DateTime" đang nằm ở đâu để tái sử dụng mà không đẻ nhánh mới? Codebase càng lớn, Search Token càng đắt hoặc dễ bị Hallucination.

**Giải pháp:**
Sử dụng kiến trúc CODEMAP để làm la bàn định hướng cho AI (và CTO Agent).

**Danh sách công việc (Checklist):**
- [ ] Thêm file `docs/technical/CODEMAP.md` nhằm lập bản đồ vị trí thực tế của Code blocks quan trọng.
- [ ] Tạo workflow `/update-codemap`: Cho phép Technical Director/Lead Programmer update cây thư mục Logic/Components sau mỗi feature lớn lên file `CODEMAP.md`.
- [ ] Agent CTO có thể đọc lướt `CODEMAP.md` để quyết định thay vì bắt nó đọc 100 file Typescript cùng lúc.

---

## Các Bước Triển Khai (Dự kiến)

1. Review lại Plan trên (bởi Lead Engineering / Maintainer Template).
2. Quyết định các feature có độ ưu tiên cao nhất, đưa vào Jira hoặc đánh dấu TODO trực tiếp.
3. Thực thi Task 1 & 2 trước do độ phức tạp kỹ thuật thấp nhưng hiệu quả ngay.
4. Phát triển Custom Skill `/save-state` và `CODEMAP.md` như một bản Release lớn v1.6.0.
