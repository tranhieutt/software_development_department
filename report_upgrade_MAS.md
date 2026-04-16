# SDD Upgrade Report: Multi-Agent Systems (MAS) Infrastructure
**Version:** 1.30.0-proposal
**Date:** 2026-04-16
**Subject:** Nâng cấp hạ tầng SDD dựa trên tiêu chuẩn Multi-Agent Infrastructure (DigitalOcean)

---

## 1. Tổng quan
Báo cáo này phân tích các lỗ hổng (gaps) của hệ thống **Claude Code Software Development Department (SDD)** hiện tại so với tiêu chuẩn hạ tầng Multi-Agent thế giới và đề xuất các hạng mục nâng cấp cụ thể nhằm tăng tính **Tin cậy (Reliability)**, **Khả năng quan sát (Observability)** và **Phối hợp (Orchestration)**.

---

## 2. Phân tích Khoảng cách (Gap Analysis)

| Trụ cột hạ tầng | Trạng thái hiện tại (v1.28.0) | Khoảng cách & Rủi ro | Đề xuất Nâng cấp |
| :--- | :--- | :--- | :--- |
| **Orchestration** | Wave-based (Tuần tự/Phẳng) | Khó xử lý các task có vòng lặp hoặc phụ thuộc chéo phức tạp. | Chuyển sang **Graph-based Workflows**. |
| **Shared Memory** | Tiered Memory chung (5 lớp) | Rủi ro "Context Pollution" (nhiễu ngữ cảnh) giữa các tier. | **Namespace Isolation** & **Consensus Agent**. |
| **Fault Tolerance** | Script-level Resume | Nếu 1 agent crash, khó khôi phục trạng thái nhận thức (cognitive state). | **Atomic Checkpointing** cho từng task. |
| **Observability** | History Log (Manual/Markdown) | Khó truy vết "Lý do tại sao" một quyết định sai lầm được đưa ra. | **Decision Tracing Ledger** (JSON-based). |
| **Compute Scaling** | Model Tiering thủ công | Chưa tối ưu hóa token/cost tự động dựa trên độ khó công việc. | **Dynamic Vertical Scaling Rules**. |
| **Agent Communication** | Prose-based handoff | Mất thông tin khi chuyển giao giữa agents, không có contract chuẩn. | **A2A Handoff Schema**. |
| **Fault Isolation** | Retry × 3 rồi escalate | Không có cơ chế cô lập agent lỗi, retry vô hạn làm tốn token. | **Circuit Breaker Pattern**. |

---

## 3. Chi tiết các hạng mục nâng cấp (Action Plan)

### 🚀 Upgrade #1: Fault Tolerance — Atomic Checkpointing
- **Mục tiêu:** Cho phép hệ thống resume ngay lập tức tại điểm lỗi mà không cần chạy lại toàn bộ wave.
- **Hành động:**
    - Cập nhật skill `/save-state` để ghi lại `task_id`, `agent_id`, và `output_snapshot` vào `.tasks/checkpoints/`.
    - Bổ sung lệnh `/resume-from [Task_ID]` để khôi phục nhanh.

### 🧠 Upgrade #2: Shared Memory — Namespace Isolation
- **Mục tiêu:** Giảm 40% nhiễu ngữ cảnh cho các Specialist Agents.
- **Hành động:**
    - Triển khai cấu trúc memory: `.claude/memory/specialists/[agent_name].md`.
    - Chỉ nạp memory của specialist liên quan trực tiếp đến task hiện tại.
    - Dùng `@technical-director` làm "Consensus Hub" để hợp nhất tri thức vào `MEMORY.md`.

### 🔍 Upgrade #3: Observability — Decision Tracing Ledger
- **Mục tiêu:** Tạo bản đồ tư duy máy (Machine Thought Map) để debug logic.
- **Hành động:**
    - Tạo tập tin `production/traces/decision_ledger.jsonl`.
    - Ghi lại: `[Timestamp] Agent_ID -> Request -> Reasoning -> Choice -> Outcome`.
    - Tích hợp skill `/trace-history` để xem timeline các quyết định quan trọng.

### 📈 Upgrade #4: Orchestration — Dynamic Workflow Graph
- **Mục tiêu:** Hỗ trợ quy trình phát triển lặp (Iterative Development).
- **Hành động:**
    - Định nghĩa schema workflow mới trong `docs/templates/workflow-graph.md`.
    - Thêm skill `/map-workflow` cho phép `@producer` thiết lập 4 patterns: Sequential, Parallel Fan-out, Hierarchical, Iterative Loop.

```text
Pattern A: Sequential    → @producer → @backend → @frontend → @qa-tester
Pattern B: Parallel      → @producer → [@backend + @frontend] → merge → @qa-tester
Pattern C: Hierarchical  → @producer → @lead-programmer → [@backend, @frontend, @qa]
Pattern D: Iterative     → @qa-tester → [FAIL] → @backend → @qa-tester (retry)
```

### 🔌 Upgrade #5: Fault Isolation — Circuit Breaker Pattern

- **Mục tiêu:** Tự động cô lập agent lỗi, tránh retry vô hạn gây tốn token.
- **Hành động:**
    - Thêm rule Circuit Breaker vào `coordination-rules.md` với 3 trạng thái:
        - `CLOSED` → Agent hoạt động bình thường.
        - `OPEN` → Agent fail 3+ lần liên tiếp → bypass, route đến fallback agent.
        - `HALF-OPEN` → Sau 10 phút, thử lại 1 lần để kiểm tra recovery.
    - Log trạng thái vào `production/session-state/circuit-state.json`.
    - Định nghĩa fallback pairs: `@backend-developer` ↔ `@fullstack-developer`, `@frontend-developer` ↔ `@fullstack-developer`.
    - Kết hợp **exponential backoff**: retry sau 2s → 4s → 8s trước khi OPEN.

### 🤝 Upgrade #6: Agent Communication — A2A Handoff Schema

- **Mục tiêu:** Chuẩn hóa giao tiếp giữa agents, không mất context khi chuyển giao.
- **Hành động:**
    - Định nghĩa Handoff Contract schema trong `.claude/docs/handoff-schema.md`.
    - Mỗi handoff ghi rõ: `from`, `to`, `artifact`, `acceptance_criteria`, `context_snapshot`, `risk_tier`.
    - Thêm skill `/handoff [from] [to] [artifact]` để tự động generate contract.

```jsonc
// Ví dụ handoff contract
{
  "from": "backend-developer",
  "to": "qa-tester",
  "artifact": "src/api/auth.ts",
  "acceptance_criteria": ["POST /auth returns 201", "Invalid token returns 401"],
  "context_snapshot": ".tasks/checkpoints/auth-api-v1.md",
  "risk_tier": "Medium"
}
```

### 📊 Upgrade #7: Observability — Per-Agent Performance Registry

- **Mục tiêu:** Theo dõi hiệu suất từng agent để phát hiện bottleneck sớm.
- **Hành động:**
    - Tạo `production/traces/agent-metrics.jsonl` ghi metrics mỗi task.
    - Fields: `date`, `agent`, `tasks_completed`, `tasks_failed`, `avg_tokens`, `error_rate`.
    - Thêm skill `/agent-health` để hiển thị bảng tóm tắt hiệu suất trong session.

---

## 4. Dự kiến kết quả

1. **Tăng độ ổn định:** Giảm thời gian recovery sau crash xuống dưới 30 giây.
2. **Tối ưu chi phí:** Giảm 25% token waste nhờ Memory Isolation.
3. **Khả năng kiểm chứng:** 100% các quyết định quan trọng của agent được trace-back.
4. **Giảm token lãng phí do retry:** Circuit Breaker cắt vòng lặp lỗi sau 3 lần, tiết kiệm ước tính 15% token/session.
5. **Zero context loss giữa agents:** A2A Handoff Schema đảm bảo 100% handoff có contract chuẩn.
6. **Phát hiện bottleneck sớm:** Per-Agent Metrics cho phép xác định agent yếu kém trong vòng 1 session.

---

## 5. Kết luận
Việc chuyển đổi SDD từ một bộ khung điều phối đơn giản sang một **Hạ tầng Multi-Agent (MAS Infrastructure)** đầy đủ là bước đi tất yếu để xử lý các dự án phần mềm có quy mô doanh nghiệp (Enterprise-scale).

**Người đề xuất:** Antigravity AI Engineer
**Tình trạng:** Sẵn sàng thực hiện (Drafting Phase)
