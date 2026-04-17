# Báo cáo Năng lực Mới — SDD + GitNexus

**Ngày:** 2026-04-02
**Trạng thái:** Đánh giá năng lực sau tích hợp

---

## Tóm tắt nội dung (Executive Summary)

Trước khi tích hợp, SDD hoạt động như một phòng ban phát triển AI có cấu trúc hoàn chỉnh với các vai trò, quy trình làm việc và quản trị được xác định rõ ràng — nhưng không có khả năng nhìn thấu cấu trúc bên trong của mã nguồn mà nó tương tác. Mọi quyết định về kiến trúc, đánh giá PR (Pull Request) và quá trình refactor đều dựa trên việc đọc từng file riêng lẻ thay vì hiểu được cách chúng kết nối với nhau.

Sau khi tích hợp GitNexus, SDD có thêm sơ đồ tri thức mã nguồn (code knowledge graph) — một bản đồ thời gian thực về mọi hàm, lớp (class), chuỗi lệnh gọi (call chain) và luồng thực thi (execution flow). Bất kỳ agent nào chạm vào hoặc xem xét code giờ đây đều có thể đưa ra các quyết định dự trên dữ liệu cấu trúc thực tế, chứ không phải dựa trên trực giác.

---

## Trước vs Sau

| Tình huống | Trước khi tích hợp | Sau khi tích hợp |
|----------|--------|-------|
| Chỉnh sửa một hàm lõi | Không biết có bao nhiêu lời gọi hàm tồn tại | Tầm ảnh hưởng (Blast radius): số lượng chính xác + mức độ rủi ro |
| Đổi tên trên nhiều file | Tìm kiếm & Thay thế (bỏ sót các tham chiếu động) | Đổi tên với trợ giúp của Graph, bao phủ 100% tham chiếu |
| Review PR (Pull Request) | Đọc code bằng mắt | Cảnh báo các luồng thực thi bị ảnh hưởng + thiếu cập nhật từ lời gọi hàm |
| Review bảo mật luồng Auth | Đọc thủ công các file auth | Lập sơ đồ tất cả các hàm gọi tới auth qua graph |
| Lên kế hoạch QA test | Dựa trên trực giác hoặc tuỳ cơ ứng biến | Dựa trên rủi ro: test chính xác các luồng bị ảnh hưởng |
| Quyết định Kiến trúc | Dựa trên việc đọc file + kinh nghiệm | Được củng cố bởi dữ liệu liên kết thực tế từ graph |
| Bắt đầu phiên làm việc | Nhánh, sprint, milestone | + Biết được Repo nào đã được index và mức độ cập nhật |
| Ghi nhận (Commit) thay đổi | Không có nhận thức về cấu trúc | Cảnh báo tầm ảnh hưởng (Blast-radius) trên diff đang chờ commit |

---

## Năng lực mới theo từng hạng mục

### 1. Phân tích tầm ảnh hưởng (Impact Analysis)

**Tính năng:** Với một biểu tượng (hàm, lớp, phương thức), trả về tất cả các lời gọi trực tiếp (độ sâu=1, sẽ gây lỗi), những thành phần phụ thuộc gián tiếp (độ sâu=2-3), các luồng thực thi bị ảnh hưởng, và mức độ rủi ro (THẤP / TRUNG BÌNH / CAO / NGHIÊM TRỌNG).

**Công cụ (Tools):** `mcp__gitnexus__impact`, `mcp__gitnexus__detect_changes`
**Skills:** `/gitnexus-impact-analysis`
**Agents:** `lead-programmer`, `security-engineer`, `qa-lead`
**Hooks:** `validate-commit.sh` (tự động chạy mỗi khi commit)

**Giá trị mang lại:** Ngăn chặn các lỗi ẩn (silent breakage). Trước đây, việc thay đổi tham số truyền vào (signature) của một hàm có thể làm hỏng 12 lời gọi hàm khác mà không ai nhớ là chúng có tồn tại.

---

### 2. Refactor an toàn

**Tính năng:** Hỗ trợ các thao tác đổi tên, trích xuất, di chuyển và chia tách bằng Graph. Hiển thị mọi tham chiếu (bao gồm cả tham chiếu động và dạng chuỗi) trước khi thực thi. Chế độ chạy thử (Dry-run) cho thấy chính xác những gì sẽ thay đổi trước khi chạm vào bất kỳ file nào.

**Công cụ (Tools):** `mcp__gitnexus__rename`, `mcp__gitnexus__context`
**Skills:** `/gitnexus-refactoring`
**Agents:** `lead-programmer`

**Giá trị mang lại:** Loại bỏ các lỗi do đổi tên không đầy đủ (lỗi runtime do bỏ sót tham chiếu, khi các bài test tích hợp phát hiện ra những gì lệnh `grep` bỏ qua).

---

### 3. Khám phá Kiến trúc (Architecture Exploration)

**Tính năng:** Điều hướng bất kỳ mã nguồn xa lạ nào bằng cách truy vấn các khái niệm bằng ngôn ngữ tự nhiên. Trả về các symbol liên quan, nơi gọi chúng, nơi chúng gọi đến, và chúng tham gia vào những luồng thực thi nào. Tiết lộ những module bị ràng buộc ngầm mặc dù trông có vẻ tách biệt ở cấp độ file.

**Công cụ (Tools):** `mcp__gitnexus__query`, `mcp__gitnexus__context`, `mcp__gitnexus__cypher`
**Skills:** `/gitnexus-exploring`, `/gitnexus-guide`
**Agents:** `technical-director`, `lead-programmer`

**Giá trị mang lại:** Một agent có thể hiểu một module lạ chỉ trong vài phút thay vì phải mất hàng giờ đọc từng file một.

---

### 4. Đánh giá PR dựa trên rủi ro (Risk-Assessed PR Review)

**Tính năng:** Lập biểu đồ mọi symbol bị thay đổi trong một PR sang các hàm gọi đến nó và các luồng thực thi. Đánh dấu các lời gọi có trong sơ đồ nhưng KHÔNG được cập nhật trong PR. Xác định các luồng thực thi bị gián đoạn do sự thay đổi. Tạo ra một báo cáo rủi ro có cấu trúc có thể đính kèm vào các yêu cầu xác nhận QA (QA sign-off).

**Công cụ (Tools):** `mcp__gitnexus__detect_changes`, `mcp__gitnexus__impact`
**Skills:** `/gitnexus-pr-review`
**Agents:** `lead-programmer`, `qa-lead`, `release-manager`

**Giá trị mang lại:** Việc review PR không còn là bài tập đọc code bằng mắt mà trở thành một checklist dựa trên dữ liệu. Câu hỏi "Bạn đã cập nhật tất cả các lệnh gọi chưa?" giờ đây có thể trả lời trong vài giây.

---

### 5. Lập bản đồ Luồng Bảo mật (Security Flow Mapping)

**Tính năng:** Tìm tất cả các đường dẫn thực thi chạm tới các hàm xác thực (authentication), phân quyền (authorization), hoặc xác nhận (validation). Xác minh rằng không có lời gọi nào bỏ qua (bypass) ranh giới bảo mật. Hỗ trợ mô hình hóa mối đe dọa STRIDE với dữ liệu call graph thực tế thay vì giả định.

**Công cụ (Tools):** `mcp__gitnexus__query`, `mcp__gitnexus__impact`
**Skills:** `/gitnexus-impact-analysis`
**Agents:** `security-engineer`

**Giá trị mang lại:** Đánh giá bảo mật dựa trên dữ liệu graph giúp bắt được các lỗ hổng bypass mà việc đọc code dễ bỏ sót — những lời gọi tồn tại trong các module không ngờ tới hoặc được thêm vào sau lần đánh giá bảo mật trước đó.

---

### 6. Định hướng Phiên làm việc Thông minh (Intelligent Session Orientation)

**Tính năng:** Khi bắt đầu phiên làm việc, hiển thị ngay repository nào đang được index trong GitNexus, lần cuối chúng được phân tích là khi nào, và liệu index có đủ mới để phân tích tác động đáng tin cậy hay không.

**Hook:** `session-start.sh` (tự động)
**Memory:** `gitnexus-registry.md`

**Giá trị mang lại:** Các Agent lập tức biết được liệu có nên tin tưởng vào output của tool tác động (impact) hay cần chạy `npx gitnexus analyze` trước. Loại bỏ các lỗi ngầm do index đã cũ.

---

## Các Agent và Năng lực mới của họ

### lead-programmer (người hưởng lợi chính)
- Kiểm tra tầm ảnh hưởng trước khi thực hiện bất kỳ thay đổi code nào có độ phức tạp cao
- Đổi tên an toàn thông qua Graph (không phải tìm-và-thay-thế)
- Đánh giá PR kèm theo báo cáo các luồng bị ảnh hưởng
- Phát hiện các thay đổi trên diff đang chờ commit

### security-engineer
- Lập bản đồ toàn bộ lời gọi các hàm auth/validation
- Xác minh không có lỗ hổng đường vòng (bypass paths) trong call graph
- Mô hình hóa STRIDE kết hợp dữ liệu luồng thực thi thực tế

### qa-lead
- Xác định chính xác luồng thực thi nào đã thay đổi trong một sprint
- Nhắm mục tiêu kiểm thử hồi quy thẳng vào các luồng bị ảnh hưởng (dựa trên rủi ro)
- Cảnh báo các PR khi các đoạn code thay đổi chưa được test

### technical-director
- Sử dụng dữ liệu ghép nối (coupling) thực tế khi định nghĩa các hợp đồng giao tiếp (interface contracts)
- Các quyết định kiến trúc (ADRs) được củng cố bằng bằng chứng từ Graph, không phải qua việc đọc file
- Khám phá các module bị ràng buộc ngầm (hidden coupling) trước khi chúng trở thành nợ kỹ thuật (tech debt)

### release-manager
- Đính kèm báo cáo phân tích tầm ảnh hưởng vào yêu cầu chốt QA (QA sign-off)
- Định lượng rủi ro của branch release bằng chính xác các luồng bị ảnh hưởng

### devops-engineer
- Quản lý bước cập nhật index trong pipeline post-merge
- Giữ cho graph luôn mới để kết quả trả về từ các tool cho agent khác luôn đáng tin cậy

---

## Các Skills sẵn có sau khi Tích hợp

| Skill | Mục đích |
|-------|---------|
| `/gitnexus-guide` | Tìm hiểu kiến thức và công cụ GitNexus — bắt đầu tại đây |
| `/gitnexus-exploring` | Điều hướng và am hiểu kiến trúc mã nguồn |
| `/gitnexus-impact-analysis` | Tầm ảnh hưởng: điều gì sẽ xảy ra nếu thay đổi X |
| `/gitnexus-pr-review` | Đánh giá rủi ro PR bằng sơ đồ gọi hàm (call graph) |
| `/gitnexus-refactoring` | Đổi tên, cấu trúc lại, di chuyển file an toàn bằng graph |
| `/gitnexus-debugging` | Truy vết bugs thông qua các luồng thực thi |
| `/gitnexus-cli` | Lệnh CLI: analyze, status, clean, wiki, list |

---

## Quản trị Tự động (Hooks)

| Hook | Điều kiện kích hoạt (Trigger) | Hành vi (Behavior) |
|------|---------|---------|
| `validate-commit.sh` | Mỗi lần `git commit` | Cảnh báo tầm ảnh hưởng trên diff chờ commit |
| `session-start.sh` | Khi mở Session | Hiển thị các repo đã index + trạng thái mới nhất |
| `pre-refactor-impact.sh` | Khi Viết/Sửa vào `src/**` | Nhắc agent chạy đánh giá tác động (impact analysis) |

Tất cả các hooks chỉ mang tính chất cảnh báo (exit 0). Chúng cung cấp thông tin mà không làm gián đoạn luồng làm việc.

---

## Tóm gọn trong 1 câu

> SDD đã chuyển từ việc biết **cách để làm mọi thứ** sang việc đồng thời biết **điều gì sẽ xảy ra khi thực hiện chúng** — mọi thay đổi về mã nguồn giờ đây được củng cố bởi dữ liệu cấu trúc (graph data) chứ không phải dựa trên trực giác.
