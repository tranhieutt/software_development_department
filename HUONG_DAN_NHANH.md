# 🚀 Hướng dẫn Sử dụng SDD Hiệu quả (Cho Người Mới)

Chào mừng bạn đã sở hữu **Software Development Department (SDD)**. Đây không chỉ là một bộ folder, mà là một **"Phòng phát triển phần mềm ảo"** với 27 chuyên gia sẵn sàng làm việc cho bạn.

Để sử dụng SDD hiệu quả nhất ngay từ đầu, hãy tuân thủ các bước dưới đây:

---

## 🛠️ Bước 0: Chuẩn bị "Bộ não" (Khuyên dùng)
SDD sử dụng **MCP Supermemory** để giúp Agent ghi nhớ kiến thức vĩnh viễn (tránh ảo giác khi chat quá dài).
1.  Truy cập [supermemory.ai](https://supermemory.ai/) và tạo tài khoản miễn phí.
2.  Cài đặt MCP Supermemory vào Claude Desktop hoặc VS Code của bạn.
3.  Xác thực (Login) theo hướng dẫn trên web của họ.
*Nếu bỏ qua bước này, SDD vẫn chạy được nhưng tính năng "Memory" sẽ bị hạn chế.*

---

## 1. Cách bắt đầu một Dự án mới
Bạn có thể chọn một trong hai cách sau để khởi tạo môi trường SDD cho dự án của mình:

### Cách A: Sử dụng Script tự động (Khuyên dùng)
Đây là cách nhanh nhất và tránh sai sót:
1.  **Mở Terminal** tại thư mục SDD (`E:\SDD`).
2.  **Chạy lệnh:**
    ```powershell
    .\init-sdd.ps1 -Path "D:\Đường_Dẫn_Dự_Án_Mới"
    ```
3.  **Mở folder dự án mới** và chạy Claude Code.
4.  **Gõ lệnh:** `/start`.

### Cách B: Thực hiện Thủ công
Nếu bạn muốn tự kiểm soát các file được copy:
1.  **Tạo folder dự án mới** của bạn.
2.  **Copy các thư mục/file sau** từ folder SDD sang dự án mới:
    *   `.claude/` (Chứa Agents và Skills)
    *   `CLAUDE.md` (Cấu hình stack công nghệ)
    *   `PRD.md` và `TODO.md` (Quản lý yêu cầu)
    *   `.tasks/` (Folder chứa chi tiết task)
3.  **Mở dự án mới** và chạy Claude Code.
4.  **Gõ lệnh:** `/start`.

### 4. 🎨 Tài liệu Trực quan (Diagrams)
SDD hiện hỗ trợ vẽ sơ đồ kiến trúc tự động với chất lượng premium:
- Xem sơ đồ kiến trúc mẫu của hệ thống: `E:\SDD\docs\visual-standards\sdd-architecture.png`.
- Tự vẽ sơ đồ cho tính năng mới bằng lệnh: `/visualize [mô tả sơ đồ]`.

---

## 2. Cách giao tiếp với "Phòng ban" AI
Thay vì nói *"Làm cho tôi cái này"*, hãy gọi đúng chuyên gia. Việc này giúp AI kích hoạt đúng các kỹ năng chuyên biệt (Skills) đã được cài cắm.

**Cú pháp chuẩn:**
> *"Ask **[Tên Agent]** to **[Yêu cầu]**"*

**Ví dụ:**
*   Chưa biết làm gì? ➔ `Ask product-manager to brainstorm core features.`
*   Cần thiết kế Database? ➔ `Ask data-engineer to design the schema for user-auth.`
*   Cần review code? ➔ `Ask lead-programmer to review my auth.ts file.`

---

## 3. Các lệnh "Quyền năng" bạn cần nhớ
SDD đã cài sẵn các phím tắt (Slash Commands) để bạn làm việc cực nhanh:

| Lệnh | Khi nào dùng? |
| :--- | :--- |
| `/start` | Khi vừa mở dự án hoặc muốn Agent hướng dẫn bước tiếp theo. |
| `/brainstorm` | Khi bạn chỉ có một ý tưởng sơ khai và cần đào sâu. |
| `/orchestrate <task>` | **Cực mạnh:** Agent sẽ tự động phân công cho các Agent khác làm việc theo từng đợt (waves). |
| `/context reset` | Khi chat đã quá dài và AI bắt đầu trả lời sai lệch (Hallucination). |
| `/sprint-plan new` | Để lập kế hoạch làm việc cho 1-2 tuần tới. |

---

## 4. Bí kíp: Vệ sinh Ngữ cảnh (Context Engineering)
Sai lầm lớn nhất của người dùng mới là để chat quá dài (Context Stuffing). AI càng đọc nhiều "rác" thì càng kém thông minh.

*   **Quy tắc:** Sau khi hoàn thành một tính năng (ví dụ: xong API Login), hãy yêu cầu Agent: *"Save lessons to memory and reset context"*.
*   AI sẽ lưu các điểm quan trọng vào **MCP Supermemory** và bắt đầu một trang giấy mới với bộ não minh mẫn nhất.

---

## 5. Cấu trúc folder bạn cần biết
*   `PRD.md`: **Cấm AI tự sửa.** Đây là nơi bạn ghi yêu cầu. Nếu muốn sửa, hãy bàn bạc với `product-manager`.
*   `.tasks/`: Nơi chứa chi tiết từng đầu việc. Đừng để AI làm việc mà không có task file tương ứng.
*   `docs/technical/`: Nơi lưu các quyết định quan trọng (ADR) và thiết kế hệ thống.

---
**Lời khuyên cuối cùng:** Hãy coi mình là **Giám đốc (CEO)**. Bạn không trực tiếp gõ code, bạn chỉ đạo các Agent thông qua các bản kế hoạch (PRD/TODO). Hãy để AI làm phần việc nặng nhất!

*Chúc bạn thành công với dự án của mình!*
