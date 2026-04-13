---
name: [Tên Skill e.g. skill-name]
description: [Một câu mô tả ngắn gọn và đanh thép về mục đích của skill này]
---

# 1. Tổng quan (Overview)
[Mô tả nhanh gọn về lý do tồn tại của kỹ năng này trong kiến trúc của SDD. Tại sao nó quan trọng? Nếu thiếu nó thì hậu quả gì?]

# 2. Khi nào kích hoạt? (When to Use)
Kích hoạt lập tức khi phát hiện các dấu hiệu:
- Dấu hiệu 1: [e.g., User yêu cầu tạo tính năng mới]
- Dấu hiệu 2: [e.g., User nhắc đến luồng xử lý database]
- Command ngầm: Gõ `/skill-name`

# 3. Quy trình bắt buộc (Strict Process)
*MỘT TỐI HẬU THƯ*: Ngươi là một Agent. Ngươi KHÔNG có quyền tự ý bỏ qua, rút gọn hay thay đổi thứ tự các bước này, cho dù ngươi nghĩ "code có vẻ đã chạy đúng".

1. **[Bước 1 - Phân tích/Chuẩn bị]**: [Mô tả]
2. **[Bước 2 - Viết Test/Kế hoạch]**: [Mô tả]
3. **[Bước 3 - Viết Giải pháp Code]**: [Mô tả]
4. **[Bước 4 - Xác minh]**: [Mô tả chạy command nào để kiểm chứng]

# 4. Ngụy biện thường gặp & Cách bác bỏ (Anti-Rationalizations)
Đây là các tư duy lười biếng mà Agent (như ngươi) thường hay mắc phải. Nếu ý tưởng nảy ra trong đầu ngươi trùng với cột Trái, ngươi PHẢI ngay lập tức tuân thủ Cột Phải:

| Ngụy biện của Agent (Lười biếng) | Bác bỏ & Hành động bắt buộc |
| :--- | :--- |
| "Phần sửa đổi này chỉ có 2 dòng code, không cần phải chạy lại bộ Test." | Sửa 1 ký tự cũng có thể làm sập hệ thống. BẮT BUỘC chạy Command Unit Test. Nếu không có bộ test, phải chạy build/lint kiểm tra syntax. |
| "Người dùng chỉ bảo 'sửa lỗi này', tôi sẽ sinh code ngay lập tức." | Dừng lại. Không bao giờ đoán mò. Phải đọc logs lỗi trước khi sinh code. Dùng `grep` hoặc `tail` để đọc log stack trace. |
| "File code hiện quá dài, tôi sẽ ghi đè toàn bộ bằng script sed." | Rất nguy hiểm vì tỷ lệ lỗi cao. Trả kết quả code dạng block hoặc dùng công cụ chỉnh sửa có độ chính xác cao `replace_file_content`. |

# 5. Cổng xác minh (Verification Gates)
Ngươi không được phép kết thúc lượt đi (Turn) và phản hồi "Tôi đã làm xong" cho User nếu CHƯA HOÀN THÀNH các cổng kiểm tra dưới đây:

* [ ] Ghi rõ tên command đã chạy để test/verify.
* [ ] Cung cấp ít nhất 3-5 dòng log output (console logs) chứng minh thành quả là Thành công (Success / Pass).
* [ ] Kiểm tra lướt qua nếu thay đổi có làm ảnh hưởng đến biến môi trường `.env` hoặc DB schema không? Nếu có, phải cảnh báo cho User.

# 6. Cờ Đỏ (Red Flags)
Lập tức DỪNG LẠI và xin ý kiến User nếu:
- Command test (hoặc lint) liên tục failed sau 2 lần thử fix. Đừng cố đâm đầu đoán lỗi.
- Yêu cầu của User động chạm làm xóa dữ liệu cơ sở hạ tầng (Xóa database, drop tables).
- Framework version bị sai lệch (ví dụ `package.json` dùng Next.js 14 nhưng prompt hướng dẫn xài Next 13).
