# Báo cáo Tổng hợp: Kế hoạch Nâng cấp SDD-Upgrade từ Dự án Claude-Mem

## 1. Tầm nhìn mục tiêu
Nâng cấp hệ thống **SDD-Upgrade** từ cơ chế kỷ luật thủ công (Manual Discipline) sang kỷ luật tự động hóa (Automated Discipline) bằng cách tích hợp "hệ thần kinh" của **Claude-Mem**. Mục tiêu là giúp Agent luôn có trí nhớ bền vững, tiết kiệm token và tự động ghi chép tiến độ mà không cần User can thiệp.

---

## 2. Phân tích các "tinh túy" từ Claude-Mem

### A. Tự động hóa Giao thức Ghi chú (Automated Annotation)
*   **Trạng thái hiện tại của SDD:** Agent phải tự nhớ lệnh `/annotate` hoặc `/context` để lưu lại kiến thức. Rất dễ quên khi task phức tạp.
*   **Giải pháp Claude-Mem:** Sử dụng **Lifecycle Hooks** để "chụp ảnh" kết quả của mọi công cụ.
*   **Ứng dụng nâng cấp:**
    *   **Hook `PostToolUse`:** Tự động bắt lỗi terminal và ghi vào `annotations.md`.
    *   **Tracking tự động:** Tự động điền tên các file đã sửa vào danh sách `## Files This Session` trong `active.md`.

### B. Kiến trúc Tìm kiếm 3 Lớp (Token-Efficient Search)
Claude-Mem giải quyết bài toán "tràn bộ nhớ" bằng mô hình **Tiết lộ lũy tiến (Progressive Disclosure)**:
1.  **Lớp Discovery (`search`):** Tìm nhanh danh sách kết quả (ID + Tiêu đề). Siêu rẻ token.
2.  **Lớp Context (`timeline`):** Xem diễn biến 3 bước trước và sau một sự kiện để hiểu logic.
3.  **Lớp Extraction (`get_observations`):** Chỉ nạp code/log chi tiết của ID đã chọn.
*   **Ứng dụng nâng cấp:** Thay thế lệnh `grep` và `mcp_supermemory_recall` hiện tại của SDD bằng quy trình 3 lớp này để Agent tìm "bí kíp" nhanh và chính xác hơn.

### D. Khám phá Code thông minh (Smart AST Discovery)
*   **Cơ chế:** Sử dụng Tree-sitter để Agent có thể:
    *   `smart_outline`: Xem "bản đồ" file (hàm/class) mà không cần load body code.
    *   `smart_unfold`: Chỉ "soi" đúng khối code cần sửa.
*   **Ứng dụng nâng cấp:** Giúp Agent **Backend** và **UI-Spec** xử lý các file lớn trong dự án SDD mà không gây lãng phí ngữ cảnh. Trình đọc file này có thể thay thế `view_file` truyền thống.

### E. Phối hợp với GitNexus (Cấp độ vĩ mô vs Vi mô)
SDD hiện đã cài GitNexus, nhưng bộ công cụ này có vai trò khác biệt và bổ trợ cho Claude-Mem:
*   **GitNexus (Vĩ mô):** Tìm đúng file/logic xuyên suốt hàng trăm repository (Semantic Search cấp độ thư viện).
*   **Smart AST Discovery (Vi mô):** Đọc file đã tìm thấy một cách thông minh bằng cách "gấp" code (Cấp độ cấu trúc hàm/class).
*   **Hướng kết hợp:** Dùng GitNexus để định vị file -> Dùng bộ Smart Reader của Claude-Mem để trích xuất logic. Điều này tạo ra một "chuỗi cung ứng ngữ cảnh" hoàn hảo từ rộng đến sâu.

### F. Cơ chế Knowledge Corpora (Kho tri thức chuyên biệt)
*   **Cơ chế:** Đóng gói kinh nghiệm theo Module (ví dụ: "Corpus về bảo mật", "Corpus về UI Components").
*   **Ứng dụng nâng cấp:** Khi Agent mới tham gia vào dự án SDD, nó chỉ cần `prime_corpus` để sở hữu năng lực của Agent cũ ngay lập tức.

---

## 3. Bản thiết kế nâng cấp kỹ thuật (Technical Blueprint)

### Bước 1: Nâng cấp Hệ thống Hook (.claude/hooks/)
*   **`session-start.sh`:** Tích hợp bộ nén bộ nhớ (Semantic Compression) để mồi ngữ cảnh từ session trước.
*   **`post-tool-use.sh` (Mới):** Tự động hóa việc cập nhật trạng thái Project vào `active.md`.
*   **`summary.sh`:** Tự động tóm tắt các quyết định quan trọng (Architecture Decisions) khi session kết thúc.

### Bước 2: Database hóa Bộ nhớ (Local Registry)
*   Dựng **SQLite local** tại `.claude/memory/sdd.db`.
*   Sử dụng **ChromaDB** qua công cụ `uv` để hỗ trợ tìm kiếm Semantic Search (tìm theo ý nghĩa câu hỏi, không chỉ theo từ khóa).

### Bước 3: Giao diện Giám sát (Web Viewer)
*   Kích hoạt cổng **37777** (giống Claude-Mem) để User có thể giám sát theo thời gian thực:
    *   Agent đang làm bước nào trong `/vertical-slice`?
    *   Lịch sử thay đổi code qua các session.

---

## 4. Lộ trình Triển khai (Roadmap)

| Giai đoạn | Nội dung thực hiện | Kết quả mong đợi |
| :--- | :--- | :--- |
| **P1: Automation** | Cài đặt `post-tool-use.sh` và `session-start.sh`. | Agent tự động cập nhật `active.md` và `annotations.md`. |
| **P2: Brain** | Tích hợp SQLite và bộ nén Semantic của Claude-Mem. | Truy xuất "bài học xương máu" nhanh gấp 10 lần. |
| **P3: Multi-Agent** | Triển khai `build_corpus` cho từng Specialist Agent. | Tăng khả năng phối hợp giữa Architect và Developer. |

---

## 5. Kết luận
Việc kết hợp **Quy trình Kỷ luật của SDD** với **Công nghệ Bộ nhớ của Claude-Mem** sẽ tạo ra một hệ thống phát triển phần mềm AI-Native hoàn chỉnh nhất: **Kỷ luật ở khung xương, thông minh ở hệ thần kinh.**

---
*Báo cáo được tổng hợp bởi Antigravity AI.*
