# SDD Framework Architecture Overview

Hệ thống Software Development Department (SDD) được xây dựng trên nguyên lý **Agentic Harness Patterns**, sử dụng Claude Code làm engine cốt lõi để vận hành một bộ máy phát triển phần mềm tự động, có cấu trúc và có khả năng tích lũy tri thức.

## 1. Core Design Philosophy
SDD không hoạt động như một chatbot đơn lẻ mà là một **Multi-Agent System (MAS)** phân cấp:
- **Separation of Concerns:** Mỗi Agent sở hữu một domain kiến thức và trách nhiệm riêng biệt.
- **Human-in-the-loop:** Mọi quyết định quan trọng đều tuân thủ giao thức: `Question -> Options -> Decision -> Draft -> Approval`.
- **Durable Memory:** Kiến thức không bị mất đi sau mỗi phiên làm việc nhờ hệ thống lưu trữ phân tầng.

## 2. Department Hierarchy (26 Specialized Agents)
Bộ máy nhân sự được chia thành 3 tầng (Tiers):

### Tier 1: Leadership (Strategic)
- `@cto`: Định hướng công nghệ tổng thể.
- `@technical-director`: Kiểm soát thực thi kỹ thuật và ADR.
- `@producer`: Điều phối tiến độ và quản lý rủi ro.

### Tier 2: Leads (Tactical)
- `@product-manager`: Quản lý yêu cầu (PRD, User Stories).
- `@lead-programmer`: Thiết kế API, Code Review hệ thống.
- `@ux-designer`: Thiết kế trải nghiệm và luồng người dùng.
- `@qa-lead`: Chiến lược kiểm thử và tiêu chuẩn chất lượng.
- `@release-manager`: Quy trình đóng gói và triển khai.

### Tier 3: Specialists (Operational)
- Bao gồm các lập trình viên chuyên biệt: `@frontend-developer`, `@backend-developer`, `@data-engineer`, `@security-engineer`, `@devops-engineer`, v.v.

## 3. Tiered Memory System
Kiến thức được quản lý qua 3 tầng để tối ưu context window:
- **Tier 1 (Volatile):** Context hiện tại của session.
- **Tier 2 (Durable Project Memory):** `.claude/memory/MEMORY.md` và các file chuyên gia. Lưu trữ trạng thái dự án, lịch sử nâng cấp và context của từng agent.
- **Tier 3 (Global/Cross-Project):** `mcp_supermemory`, dùng để truy xuất tri thức giữa các dự án khác nhau.

## 4. Operational Workflows
Hệ thống vận hành thông qua các **Process Shields** (Lệnh workflow ngầm):
1. **Explore Phase:** Sử dụng `/map-systems` và `/context` để nắm bắt hiện trạng.
2. **Plan Phase:** Sử dụng `/plan` và `/spec` để thiết kế giải pháp trước khi viết code.
3. **Act Phase:** Thực thi theo phương pháp TDD (`/tdd`) hoặc vertical slicing (`/vertical-slice`).
4. **Review Phase:** Tự động audit qua `/code-review` và `harness-audit.js`.

## 5. MAS Infrastructure Components
- **Circuit Breaker:** Ngăn chặn các lỗi dây chuyền giữa các agent.
- **Decision Ledger:** Nhật ký ghi lại mọi quyết định kỹ thuật quan trọng.
- **A2A Handoff:** Quy trình chuyển giao công việc giữa các agent (ví dụ: PM -> Lead Dev -> Dev).

## 6. Technology Stack
- **Engine:** Claude Code CLI.
- **Language:** Shell (Bash/PowerShell), JavaScript (Node.js).
- **Standards:** Model Context Protocol (MCP).
- **Communication:** Filesystem-based events và Git Hooks.
