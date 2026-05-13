# Kết hợp SDD và Linear

## Mục đích

Tài liệu này mô tả cách Software Development Department (SDD) sử dụng Linear như hệ thống quản trị công việc phần mềm. Trong mô hình này, SDD giữ vai trò định nghĩa quy trình, tiêu chuẩn, cách đánh giá chất lượng và cách bàn giao. Linear giữ vai trò lưu trữ, điều phối, ưu tiên và theo dõi công việc.

Mục tiêu chính:

- Biến mọi nhu cầu thành issue rõ ràng.
- Quản lý backlog, roadmap, sprint/cycle và delivery trên một hệ thống.
- Tạo chuẩn chung cho yêu cầu, thực thi, review và hoàn tất công việc.
- Giảm tình trạng công việc nằm rải rác trong chat, ghi chú cá nhân hoặc trí nhớ của từng người.
- Tạo nền tảng để sau này kết nối với agent, automation, CI/CD hoặc dashboard.

## Năng lực SDD đang có

SDD đang có các năng lực cốt lõi sau:

- Quản lý công việc phần mềm theo issue.
- Xây dựng quy trình phát triển, review và bàn giao.
- Viết tài liệu, checklist, tiêu chuẩn và mẫu làm việc.
- Chuẩn bị môi trường tích hợp công cụ phát triển.
- Sử dụng Codex hoặc agent để hỗ trợ phân tích, lập kế hoạch, viết code, viết tài liệu và kiểm tra.
- Vận hành theo hệ thống: backlog, trạng thái, ưu tiên, acceptance criteria, validation và retrospective.

Những năng lực này cần một nơi trung tâm để ghi nhận, sắp xếp và theo dõi. Linear phù hợp với vai trò đó.

## Khả năng Linear đáp ứng

Linear cung cấp các năng lực cần thiết cho SDD:

- Workspace để tập trung toàn bộ công việc của bộ phận.
- Team để chia theo phòng ban, nhóm sản phẩm hoặc chuyên môn.
- Project để quản lý mục tiêu lớn trong 2-8 tuần.
- Issue để quản lý từng đầu việc cụ thể.
- Cycle để quản lý sprint hoặc nhịp làm việc lặp lại.
- Label để phân loại công việc theo loại, khu vực, mức độ rủi ro.
- Priority để sắp xếp thứ tự thực hiện.
- State workflow để theo dõi tiến độ từ backlog đến done.
- Milestone để chia project thành các chặng nhỏ.
- Comment, document và attachment để lưu ngữ cảnh, quyết định và bằng chứng.
- Tích hợp với GitHub, PR, commit, automation và công cụ bên ngoài.

## Mô hình kết hợp

SDD và Linear nên chia vai trò như sau:

| Thành phần | Vai trò |
| --- | --- |
| SDD | Định nghĩa cách làm việc, tiêu chuẩn, workflow, template, definition of done |
| Linear | Lưu trữ và điều phối công việc |
| Issue | Đơn vị công việc nhỏ nhất có thể giao, làm, review và đóng |
| Project | Mục tiêu lớn gồm nhiều issue |
| Cycle | Khung thời gian thực thi, thường là 1-2 tuần |
| Label | Bộ lọc và phân loại công việc |
| Document | Nơi lưu quy ước, hướng dẫn, ADR và checklist |

Nguyên tắc: SDD đặt luật, Linear giúp vận hành luật đó hằng ngày.

## Cấu trúc Linear đề xuất

### Workspace

Tên workspace nên đại diện cho bộ phận hoặc tổ chức, ví dụ:

- `Software Development Department`
- `SDD`

### Team

Giai đoạn đầu có thể chỉ cần một team:

- `SDD`

Khi quy mô tăng, có thể tách:

- `Frontend`
- `Backend`
- `DevOps`
- `QA`
- `Product`
- `AI Engineering`

### Project

Project nên là mục tiêu có điểm kết thúc rõ ràng, không phải danh sách việc vô hạn.

Ví dụ project:

- `SDD Operating System`
- `Linear Integration`
- `Developer Onboarding`
- `Internal Tooling`
- `CI/CD Standardization`
- `Documentation System`
- `Product MVP`

### Issue

Issue nên là một đơn vị việc có thể hoàn thành và kiểm tra.

Issue tốt nên có:

- Tiêu đề rõ hành động.
- Mục tiêu cụ thể.
- Phạm vi rõ.
- Acceptance criteria.
- Validation/test plan.
- Owner hoặc assignee nếu có.
- Priority.
- Project liên quan.

## Workflow state đề xuất

SDD nên dùng workflow đơn giản:

| State | Ý nghĩa |
| --- | --- |
| Backlog | Mới ghi nhận, chưa sẵn sàng làm |
| Ready | Đã rõ yêu cầu, có thể nhận làm |
| In Progress | Đang thực hiện |
| Review | Chờ review, test hoặc phê duyệt |
| Blocked | Bị chặn bởi thiếu thông tin, quyền, phụ thuộc hoặc quyết định |
| Done | Hoàn tất và đạt definition of done |
| Canceled | Hủy vì không còn cần |
| Duplicate | Trùng với issue khác |

Quy tắc quan trọng:

- Chỉ đưa issue vào `Ready` khi đã đủ thông tin để làm.
- Chỉ đưa issue vào `Review` khi đã có kết quả có thể kiểm tra.
- Chỉ đưa issue vào `Done` khi đã đạt acceptance criteria và validation.
- Issue `Blocked` phải ghi rõ đang bị chặn bởi gì và cần ai xử lý.

## Quyền của agent SDD trên Linear

Agent của SDD có thể được cấp quyền để thao tác trực tiếp với issue trên Linear. Điều này hữu ích khi SDD muốn tự động hóa một phần quy trình vận hành: cập nhật tiến độ, đổi trạng thái, tạo follow-up issue hoặc ghi lại kết quả làm việc.

Agent có thể làm được nếu được cấp quyền Linear phù hợp:

- Assign issue cho người phụ trách hoặc cho chính agent.
- Đổi trạng thái issue, ví dụ `Ready` -> `In Progress` -> `Review` -> `Blocked`.
- Cập nhật title, description, priority, label, project hoặc cycle.
- Tạo comment hoặc workpad để ghi tiến độ.
- Tạo issue mới khi phát hiện việc ngoài scope.
- Liên kết issue liên quan, blocker hoặc duplicate.
- Gắn PR, tài liệu, link hoặc bằng chứng vào issue.
- Cập nhật project status nếu workflow cho phép.

Điều kiện cần:

- Linear connector hoặc Linear API token đã được kết nối.
- Token có quyền với workspace, team và project liên quan.
- Agent được phép gọi tool/API Linear trong môi trường làm việc.
- SDD có quy định rõ agent được đổi trạng thái khi nào.

Guardrail nên áp dụng:

- Agent chỉ chuyển `Ready` -> `In Progress` khi bắt đầu thực hiện issue.
- Agent chỉ chuyển `In Progress` -> `Review` khi đã có kết quả, bằng chứng và validation.
- Agent có thể chuyển sang `Blocked` khi thiếu quyền, thiếu thông tin, thiếu dependency hoặc thiếu quyết định.
- Agent phải ghi lý do trong comment/workpad trước hoặc cùng lúc đổi trạng thái.
- Agent không nên tự chuyển `Review` -> `Done` nếu quy trình yêu cầu human approval.
- Agent không nên tự đổi priority mang tính business-critical nếu chưa có rule.
- Agent không nên reassign người khác nếu SDD chưa định nghĩa quy tắc assign.
- Agent không được xóa, archive hoặc hủy issue nếu không có quyền rõ ràng.

Quy tắc đề xuất:

```md
Agent được phép:
- Cập nhật progress comment/workpad.
- Đổi issue sang In Progress khi bắt đầu làm.
- Đổi issue sang Review khi hoàn tất phần việc và đã validation.
- Đổi issue sang Blocked khi có blocker rõ.
- Tạo follow-up issue nếu phát hiện việc ngoài scope.

Agent không được phép:
- Đóng Done khi chưa có approval.
- Đổi priority business-critical nếu không được giao.
- Reassign người khác nếu chưa có rule.
- Xóa hoặc archive issue.
```

Nguyên tắc: agent được phép hỗ trợ vận hành, nhưng không được thay thế hoàn toàn quyền quyết định của người phụ trách quy trình.

## Label convention

SDD nên dùng label có tiền tố để dễ lọc.

### Type

- `type:bug`
- `type:feature`
- `type:docs`
- `type:infra`
- `type:research`
- `type:chore`
- `type:support`

### Area

- `area:frontend`
- `area:backend`
- `area:devops`
- `area:qa`
- `area:docs`
- `area:product`
- `area:ai`

### Risk

- `risk:low`
- `risk:medium`
- `risk:high`

### Status/context

- `needs:clarification`
- `needs:design`
- `needs:review`
- `needs:decision`
- `blocked`

Nguyên tắc: label phải giúp lọc và ra quyết định, không tạo label chỉ để trang trí.

## Priority convention

Đề xuất dùng priority như sau:

| Priority | Ý nghĩa |
| --- | --- |
| Urgent | Đang chặn delivery, production, khách hàng hoặc quyết định quan trọng |
| High | Cần làm sớm trong cycle hiện tại |
| Medium | Việc có giá trị, nên làm khi có năng lực |
| Low | Việc tốt nhưng không cấp bách |
| No priority | Mới ghi nhận, chưa triage |

Backlog mới tạo có thể là `No priority`. Sau triage, nên có priority rõ.

## Issue template chuẩn SDD

Mỗi issue nên dùng template:

```md
## Mục tiêu

Mô tả kết quả cần đạt.

## Bối cảnh

Vì sao việc này cần làm? Liên quan đến người dùng, hệ thống hoặc quy trình nào?

## Phạm vi

Trong scope:
- ...

Ngoài scope:
- ...

## Acceptance Criteria

- [ ] Điều kiện 1
- [ ] Điều kiện 2
- [ ] Điều kiện 3

## Validation

- [ ] Cách kiểm tra 1
- [ ] Cách kiểm tra 2

## Ghi chú

Link, quyết định, rủi ro hoặc thông tin bổ sung.
```

## Definition of Ready

Issue được chuyển sang `Ready` khi:

- Mục tiêu rõ.
- Phạm vi rõ.
- Acceptance criteria có thể kiểm tra.
- Validation/test plan tối thiểu có sẵn.
- Không thiếu thông tin quan trọng.
- Priority đã được gán.
- Project hoặc cycle đã được gán nếu cần.

## Definition of Done

Issue được chuyển sang `Done` khi:

- Tất cả acceptance criteria đã đạt.
- Validation đã thực hiện.
- Code, tài liệu hoặc quy trình liên quan đã cập nhật.
- Review hoặc approval đã xong nếu cần.
- Link PR, tài liệu hoặc bằng chứng đã gắn vào issue.
- Follow-up issue đã tạo cho việc ngoài scope nếu phát hiện.

## Cadence vận hành

### Hằng ngày

- Xem issue `Blocked`.
- Xem issue quá hạn hoặc sắp đến hạn.
- Triage issue mới.
- Chọn việc cần đưa vào `Ready`.
- Cập nhật issue đang `In Progress`.

### Hằng tuần

- Review backlog.
- Sắp xếp priority.
- Chọn issue cho cycle tiếp theo.
- Đóng hoặc hủy issue không còn giá trị.
- Cập nhật project status.

### Hằng tháng

- Review roadmap.
- Xem project nào đang chậm.
- Xem loại việc nào chiếm nhiều thời gian.
- Cập nhật quy trình SDD dựa trên dữ liệu thực tế.

## Metrics nên theo dõi

SDD nên dùng Linear để theo dõi:

- Số issue tạo mới mỗi tuần.
- Số issue hoàn tất mỗi tuần.
- Thời gian trung bình từ `Ready` đến `Done`.
- Số issue bị `Blocked`.
- Số issue bị reopen hoặc quay lại `Review`.
- Tỷ lệ bug/feature/docs/infra.
- Cycle completion rate.
- Project on-track / at-risk / off-track.

Không nên chỉ dùng metric để ép tốc độ. Nên dùng để phát hiện nút thắt quy trình.

## Cách SDD dùng Linear theo giai đoạn

### Giai đoạn 1: Chuẩn hóa

- Tạo workspace/team.
- Tạo state workflow.
- Tạo label convention.
- Tạo issue template.
- Đưa việc hiện có vào backlog.
- Triage mỗi ngày.

### Giai đoạn 2: Điều phối

- Dùng project và cycle.
- Gán priority và owner.
- Theo dõi blocked issue.
- Định kỳ cập nhật project status.
- Đưa review và validation vào issue.

### Giai đoạn 3: Tối ưu

- Kết nối GitHub/PR.
- Tạo automation cho issue state.
- Tạo dashboard delivery.
- Đo lead time, throughput, blocked time.
- Chuẩn hóa release note và changelog.

### Giai đoạn 4: Tự động hóa

- Kết nối với Codex/agent nếu cần.
- Tự động tạo workpad, checklist, validation.
- Tự động cập nhật issue theo PR/CI.
- Tự động tạo follow-up issue khi phát hiện việc ngoài scope.

## Bộ issue nên tạo ban đầu

Để khởi động SDD với Linear, nên tạo các issue:

- Viết issue template chuẩn SDD.
- Định nghĩa workflow state cho SDD.
- Tạo label convention.
- Tạo priority convention.
- Tạo Definition of Ready và Definition of Done.
- Tạo project `SDD Operating System`.
- Nhập backlog hiện có vào Linear.
- Tạo cadence triage hằng ngày và review hằng tuần.
- Kết nối GitHub với Linear.
- Tạo dashboard theo dõi delivery.

## Kết luận

Linear nên trở thành bộ nhớ vận hành của SDD. Mọi việc cần làm, đang làm, bị chặn, chờ review và đã xong đều nằm trong Linear. SDD không chỉ dùng Linear như todo list, mà dùng như hệ thống điều hành delivery: có quy trình, có tiêu chuẩn, có bằng chứng và có dữ liệu để cải tiến liên tục.

