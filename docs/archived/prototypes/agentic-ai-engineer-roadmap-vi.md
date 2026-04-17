| Lộ trình | Hoàn chỉnh |     | để  | Trở thành | một | Kỹ sư | Agentic AI |
| -------- | ------- | --- | --- | ------ | --- | ------- | ----------- |
năm 2026
|     |     | Câu hỏi | Phỏng vấn       |        | & Trả lời | theo Chủ đề      |     |
| --- | --- | --------- | --------------- | ------ | --------- | ------------- | --- |
|     |     |           | Lamhot          |        | Siagian   |               |     |
|     | PhD | Sinh viên   | - Đánh giá AI |        | Kỹ sư  | - Kỹ sư AI |     |
|     |     | Machine   | Learning        | - Khoa học | Dữ liệu   | & AI/ML       |     |
linkedin.com/in/lamhotsiagian
softwaretestarchitect.com
lamhotsiagian2025@gmail.com
|     |     |     | Ngày 19 |     | tháng 1, 2026 |     |     |
| --- | --- | --- | ------- | --- | -------- | --- | --- |
Tài liệu này chuyển đổi lộ trình học tập Agentic AI năm 2026 thành các bài thực hành phỏng vấn thực tế. Mỗi phần bao gồm 10 câu hỏi phỏng vấn phổ biến với câu trả lời mẫu và một vài ví dụ mã nguồn nhỏ.

| Kỹ sư | Agentic AI | Lộ trình | (2026) |     |     | Phỏng vấn | Q&A |
| ------- | ----------- | ------- | ------ | --- | --- | --------- | --- |
Nội dung
| 1 Cách    | sử dụng  | Lộ trình này |         |     |     |     | 1   |
| -------- | ------------ | ------- | ------- | --- | --- | --- | --- |
| 2 Cơ bản | về Python | (cho    | Agentic | AI) |     |     | 2   |
| 3 Cơ bản | về LLM    |         |         |     |     |     | 4   |
4 Chọn một Framework (LangChain/LangGraph vs CrewAI vs AutoGen) 6
5 Các khái niệm Framework nâng cao (LCEL, Runnables, Workflows, Multi-Agent) 8
6 Quản lý bộ nhớ (Ngắn hạn, Dài hạn, Checkpointing) 10
| 7 Tích hợp | Công cụ | (Custom | Tools, | Connectors, | Decorators) |     | 12  |
| ------ | ----------- | ------- | ------ | ----------- | ----------- | --- | --- |
8 Hệ thống RAG (Vector Stores, Embeddings, Chiến lược truy xuất) 14
9 Agents & Multi-Agents (ReAct, Supervisors, Giao tiếp) 16
10 Xây dựng các dự án thực tế (FastAPI, Streamlit/UI, Docker, AWS) 18
| 11 Danh sách | nhanh: | Thứ tự | đúng | để học | (2026) |     | 20  |
| -------- | ---------- | --------- | ----- | -------- | ------ | --- | --- |

| Kỹ sư | Agentic AI | Lộ trình (2026) |     |     | Phỏng vấn Q&A |
| ------- | ----------- | -------------- | --- | --- | ------------- |
| 1 Cách   | sử dụng | Lộ trình này        |     |     |               |
Lộ trình này tuân theo thứ tự "nền tảng trước": học lập trình cốt lõi, sau đó đến các khái niệm LLM, tiếp theo là các framework, kiến trúc agent nâng cao, và cuối cùng là triển khai thực tế (production).
Cách thực hành: với mỗi chủ đề, (1) đọc câu hỏi, (2) viết lại câu trả lời theo ngôn từ của bạn, (3) triển khai ít nhất một dự án nhỏ cho mỗi phần, và (4) ghi lại các lỗi và cách khắc phục - đó là những gì nhà tuyển dụng muốn nghe.

Phạm vi: Các câu hỏi tập trung vào kỹ thuật Agentic AI cho các sản phẩm phần mềm: ứng dụng LLM sử dụng công cụ, quy trình làm việc đa agent (multi-agent workflows), RAG, bộ nhớ, đánh giá và triển khai.

| Kỹ sư  | AI  | Lộ trình (2026) |         |     | Phỏng vấn Q&A |
| -------- | --- | ---------------- | ------ | ------- | --- | ------------- |
| 2 Cơ bản |     | về Python     | (cho   | Agentic | AI) |               |
1.1 Câu hỏi: Tại sao Python là ngôn ngữ mặc định cho kỹ thuật Agentic AI?
Trả lời: Python có hệ sinh thái trưởng thành cho API, xử lý dữ liệu và ML (ví dụ: FastAPI, Pydantic, NumPy, PyTorch) và trải nghiệm lập trình viên tuyệt vời. Hầu hết các framework agent và công cụ (LangChain/LangGraph, CrewAI, AutoGen, vector DB clients) đều hỗ trợ Python hàng đầu. Trong phỏng vấn, hãy nhấn mạnh rằng Python cho phép bạn tạo nguyên mẫu nhanh chóng và sau đó làm bền vững hệ thống với typing, tests và đóng gói (packaging).

1.2 Câu hỏi: Giải thích cách bạn cấu trúc một dự án Python cho một hệ thống agentic.
Trả lời: Sử dụng cấu trúc phân tầng: app/ (điểm vào API/UI), core/ (logic nghiệp vụ, prompts, policies), agents/ (đồ thị agent, routers), tools/ (wrapper công cụ, schemas), rag/ (chunking, retrieval), eval/ (tests, golden sets), và infra/ (Docker, configs). Thêm pyproject.toml, typed interfaces, và các bài kiểm tra unit/integration. Mục tiêu là phân tách các mối quan tâm để prompts/tools có thể phát triển mà không làm hỏng quá trình triển khai.

1.3 Câu hỏi: Những tính năng nào của Python quan trọng nhất để xây dựng các agent mạnh mẽ?
Trả lời: Type hints (mypy/pyright), dataclasses hoặc Pydantic models cho schemas, context managers cho an toàn tài nguyên, async/await cho các cuộc gọi công cụ nặng về IO, và exceptions để xử lý lỗi rõ ràng. OOP hữu ích cho các bộ điều hợp công cụ, nhưng composition và các hàm thuần túy nhỏ thường mở rộng tốt hơn. Ngoài ra còn quan trọng: logging, retries/backoff, và dependency injection cho khả năng kiểm thử.

1.4 Câu hỏi: Làm thế nào để thiết kế một API client sạch cho các công cụ (REST/GraphQL)?
Trả lời: Định nghĩa request/response models (Pydantic), tập trung hóa auth và url cơ sở, triển khai timeouts, retries và idempotency nơi có thể. Cung cấp các phương thức nhỏ phù hợp với các hành động nghiệp vụ, không phải các endpoint thô. Ghi lại correlation IDs để truy vết qua các bước của agent. Trong phỏng vấn, hãy đề cập đến việc bảo vệ bí mật bằng biến môi trường hoặc trình quản lý bí mật và không bao giờ in các token ra.

1.5 Câu hỏi: Khi nào bạn sẽ sử dụng Python đồng bộ (sync) so với bất đồng bộ (async) cho các agent?
Trả lời: Nếu các công cụ chủ yếu là gọi mạng (tìm kiếm, DB, API bên ngoài), async có thể cải thiện thông lượng và độ trễ bằng cách chạy các cuộc gọi đồng thời. Nếu khối lượng công việc của bạn nặng về CPU (như tạo embedding hàng loạt cục bộ), multiprocessing hoặc các worker chạy ngầm có thể tốt hơn. Nhiều ứng dụng agent kết hợp cả hai: async cho các cuộc gọi công cụ và một hàng đợi công việc cho việc xử lý trước/đánh chỉ mục nặng.

1.6 Câu hỏi: Cho ví dụ tối giản về một sơ đồ đầu vào công cụ có kiểu dữ liệu (typed tool input schema) trong Python.
Trả lời: Một mô hình tốt là xác thực đầu vào công cụ trước khi agent chạy công cụ đó.
```python
from pydantic import BaseModel, Field

class WeatherArgs(BaseModel):
    city: str = Field(..., min_length=2)
    units: str = Field("metric", pattern="^(metric|imperial)$")
```
Các schema có kiểu dữ liệu giúp giảm bớt các tham số bị ảo tưởng (hallucinated) và đưa ra các lỗi rõ ràng mà bạn có thể định tuyến lại cho agent để tự sửa chữa.

1.7 Câu hỏi: Làm thế nào để kiểm thử mã nguồn agentic khi đầu ra có tính xác suất?
Trả lời: Kiểm thử các lớp xác định (bộ phân tích cú pháp, bộ điều hợp công cụ, quy tắc định tuyến) bằng unit tests. Đối với các bước LLM, sử dụng các prompt "vàng" (golden prompts) với snapshots, và đánh giá bằng các chỉ số như khớp chính xác (exact match), tính hợp lệ của JSON schema, hoặc chấm điểm dựa trên râu ria (rubric-based scoring). Thêm các bài kiểm tra tích hợp để giả lập công cụ và kiểm soát seed/temperature. Mục tiêu là phát hiện sự thụt lùi (regressions), không phải để chứng minh sự chính xác hoàn hảo.

1.8 Câu hỏi: Những cạm bẫy Python phổ biến trong các ứng dụng agent thực tế là gì?
Trả lời: Các lần thử lại (retries) vô hạn gây ra bão lưu lượng, thiếu timeouts, rò rỉ file handles/sockets, trạng thái toàn cục (global state) được chia sẻ qua các yêu cầu, và xác thực đầu vào yếu. Một cạm bẫy khác là trộn lẫn logic prompt với logic nghiệp vụ khiến việc thay đổi trở nên rủi ro. Cuối cùng, thiếu khả năng quan sát (logs có cấu trúc, traces) khiến việc gỡ lỗi khi "agent hành xử kỳ quặc" trở nên gần như không thể.

1.9 Câu hỏi: Làm thế nào để quản lý cấu hình qua các môi trường local/dev/prod?
Trả lời: Sử dụng một đối tượng cấu hình duy nhất được tải từ các biến môi trường (và tùy chọn một file cấu hình), được xác thực bởi Pydantic. Giữ các bí mật ngoài hệ thống kiểm soát phiên bản. Quản lý phiên bản cấu hình cùng với hạ tầng (Terraform/CloudFormation) và tài liệu hóa các biến cần thiết. Trong phỏng vấn, hãy nhắc đến việc sử dụng feature flags để triển khai an toàn các prompt mới hoặc chính sách agent.

1.10 Câu hỏi: Giải thích về quản lý phụ thuộc và khả năng tái lập trong Python cho ML/agents.
Trả lời: Sử dụng phương pháp lockfile (như uv/poetry/pip-tools) để các phiên bản được ghim cố định. Tách biệt các phụ thuộc lúc chạy (runtime deps) khỏi các phụ thuộc dùng để phát triển/kiểm thử. Xây dựng Docker images với các gói OS được ghim phiên bản. Khả năng tái lập quan trọng vì các thay đổi nhỏ trong thư viện có thể làm thay đổi việc mã hóa (tokenization), HTTP clients, hoặc hành vi của vector DB, dẫn đến thay đổi đầu ra của agent.

| Kỹ sư AI | Lộ trình (2026) | Phỏng vấn Q&A |
| ------- | ----------- | ------------- |
| 3 Cơ bản về LLM | | |

2.1 Câu hỏi: Theo cách đơn giản nhất, LLM tạo văn bản như thế nào?
Trả lời: Một LLM dự đoán token tiếp theo dựa trên các token trước đó. Nó chuyển đổi văn bản thành các token, ánh xạ token thành các embeddings, áp dụng các lớp transformer với cơ chế chú ý (attention) để tính toán các biểu diễn theo ngữ cảnh, và sau đó đưa ra phân phối xác suất cho token tiếp theo. Quá trình tạo lặp lại cho đến khi gặp điều kiện dừng. Đối với agent, điều quan trọng là "lập luận" thực chất là dự đoán dựa trên mô hình, vì vậy bạn phải cung cấp cấu trúc, công cụ và các ràng buộc.

2.2 Câu hỏi: Token là gì và tại sao chúng quan trọng đối với kỹ thuật phần mềm?
Trả lời: Token là các đơn vị rời rạc của mô hình (thường là các mảnh từ). Chúng ảnh hưởng đến chi phí, độ trễ và lượng ngữ cảnh bạn có thể cung cấp. Giới hạn token buộc bạn phải đánh đổi: những hướng dẫn, bộ nhớ và tài liệu được truy xuất nào sẽ vừa. Các kỹ sư tối ưu hóa prompts, việc truy xuất và tóm tắt để nằm trong ngữ cảnh trong khi vẫn bảo tồn các bằng chứng đúng đắn.

2.3 Câu hỏi: Giải thích về cửa sổ ngữ cảnh (context window) và tác động thực tế của nó đối với agent.
Trả lời: Cửa sổ ngữ cảnh là số lượng token tối đa mà mô hình có thể chú ý đến cùng một lúc. Nếu bạn vượt quá nó, mô hình sẽ bị cắt bớt hoặc bạn phải tóm tắt. Về mặt thực tế, agent cần các chiến lược bộ nhớ (tóm tắt, truy xuất, nén) và lọc đầu ra công cụ cẩn thận. Trong phỏng vấn, hãy nhắc đến "lập ngân sách ngữ cảnh" (context budgeting) và bảo vệ các hướng dẫn hệ thống quan trọng khỏi bị đẩy ra ngoài.

2.4 Câu hỏi: Prompting có gì khác ngoài việc "viết một prompt tốt"?
Trả lời: Prompting là thiết kế giao diện: chỉ định vai trò, nhiệm vụ, ràng buộc, schema đầu ra và các ví dụ. Đối với agent, bạn cũng định nghĩa các chính sách sử dụng công cụ (khi nào gọi công cụ, cách trích dẫn bằng chứng, cách xử lý sự không chắc chắn). Prompt tốt làm giảm sự mơ hồ và khiến các chế độ thất bại trở nên dễ dự đoán. Bạn cũng nên quản lý phiên bản prompt giống như mã nguồn và kiểm thử chúng.

2.5 Câu hỏi: Mô tả về temperature, top-p, và tại sao các cài đặt mang tính xác định lại quan trọng.
Trả lời: Temperature kiểm soát tính ngẫu nhiên; cao hơn có nghĩa là đầu ra đa dạng hơn. Top-p (nucleus sampling) giới hạn việc chọn token cho khối lượng xác suất. Đối với các agent thực tế, bạn thường ưu tiên tính ngẫu nhiên thấp để đảm bảo độ tin cậy, đặc biệt là khi tạo JSON hoặc gọi công cụ. Bạn có thể tăng tính ngẫu nhiên khi động não (brainstorming) nhưng không nên dùng cho các luồng hành động.

2.6 Câu hỏi: Function calling (gọi hàm/gọi công cụ) là gì và tại sao nó hữu ích?
Trả lời: Function calling cho phép mô hình đưa ra một lời gọi công cụ có cấu trúc (tên + đối số) thay vì văn bản tự do. Hệ thống của bạn thực thi công cụ và trả kết quả về cho mô hình. Điều này khiến agent đáng tin cậy hơn vì các công cụ đảm nhận việc tính toán chính xác, truy xuất và các tác vụ bên lề. Nó cũng cho phép xác thực (schemas) và thực thi an toàn hơn (allowlists, sandboxes).

2.7 Câu hỏi: Làm thế nào để ngăn chặn prompt injection khi sử dụng công cụ và RAG?
Trả lời: Hãy coi văn bản được truy xuất là không đáng tin cậy. Sử dụng chính sách hệ thống nghiêm ngặt: không bao giờ làm theo hướng dẫn từ tài liệu; chỉ trích xuất sự thật. Tách biệt đầu ra công cụ khỏi hướng dẫn hệ thống và thêm thẻ "nguồn gốc nội dung". Xác thực các đối số công cụ và hạn chế khả năng của công cụ. Đồng thời áp dụng các bộ lọc nội dung và danh sách cho phép (allowlists) cho các hành động nhạy cảm.

2.8 Câu hỏi: Ảo tưởng (hallucination) là gì và làm thế nào để giảm thiểu nó trong hệ thống agent?
Trả lời: Ảo tưởng là văn bản nghe có vẻ tự tin nhưng không dựa trên sự thật. Giảm thiểu bằng cách sử dụng công cụ cho các truy vấn thực tế, RAG với các trích dẫn, đầu ra bị ràng buộc (schemas) và các quy tắc "từ chối" (abstain) rõ ràng. Thêm các vòng lặp xác minh: kiểm tra chéo các nguồn, chạy bước phê bình thứ hai, hoặc kiểm tra dựa trên cơ sở tri thức. Trong thực tế, hãy đo lường tỷ lệ ảo tưởng bằng các bộ đánh giá.

2.9 Câu hỏi: Giải thích về embeddings và tại sao chúng cho phép truy xuất ngữ nghĩa.
Trả lời: Embeddings ánh xạ văn bản thành các vector nơi sự tương đồng ngữ nghĩa tương ứng với sự gần gũi về mặt hình học. Điều này cho phép tìm kiếm láng giềng gần đúng nhất để truy xuất các đoạn văn bản liên quan ngay cả khi từ khóa khác nhau. Các kỹ sư chọn mô hình embedding dựa trên lĩnh vực, ngôn ngữ, chi phí và kích thước vector. Bạn cũng cần các chiến lược chunking (chia nhỏ văn bản) để embeddings đại diện cho ý nghĩa mạch lạc.

2.10 Câu hỏi: Những rủi ro chính của ứng dụng LLM trong thực tế là gì?
Trả lời: Độ tin cậy (đầu ra bất ngờ), bảo mật (prompt injection, rò rỉ dữ liệu), quyền riêng tư (tiết lộ PII), chi phí/độ trễ tăng vọt, và sự trôi dạt (drift) của đánh giá. Agent thêm rủi ro vì chúng có thể thực hiện hành động thông qua công cụ. Các biện pháp giảm thiểu bao gồm các lớp chính sách, công cụ có đặc quyền tối thiểu, nhật ký kiểm tra, đánh giá ngoại tuyến và triển khai từng giai đoạn có giám sát.

| Kỹ sư AI | Lộ trình (2026) | Phỏng vấn Q&A |
| ------- | ----------- | ------------- |
| 4 Chọn một Framework | | |

3.1 Câu hỏi: Làm thế nào để bạn chọn giữa LangChain+LangGraph, CrewAI, và AutoGen?
Trả lời: Bắt đầu từ yêu cầu: quy trình làm việc xác định so với tự chủ đàm thoại, số lượng agent, độ phức tạp của công cụ và nhu cầu quan sát. LangGraph mạnh mẽ cho các máy trạng thái (state machines)/đồ thị rõ ràng, việc thử lại và các quy trình dài hạn. CrewAI mang tính định hướng cho sự hợp tác đa agent "dựa trên vai trò". AutoGen linh hoạt cho các mô hình chat giữa agent-với-agent. Trong phỏng vấn, hãy nói rằng bạn tạo nguyên mẫu nhanh nhưng ổn định bằng các đồ thị rõ ràng và các bài kiểm tra.

3.2 Câu hỏi: Tại sao LangGraph thường được khuyên dùng cho các agent thực tế?
Trả lời: Nó mô hình hóa hành vi agent dưới dạng một đồ thị với các node (bước) và cạnh (chuyển tiếp), giúp dễ dàng suy luận hơn so với các vòng lặp ngầm định. Bạn có thể lưu lại trạng thái (checkpoint), thực thi các chính sách tại các biên, và thêm các lần thử lại. Điều này cải thiện khả năng gỡ lỗi và ngăn chặn các cuộc hội thoại không kiểm soát được. Nó cũng hỗ trợ các mô hình "có con người can thiệp" (human-in-the-loop) một cách tự nhiên hơn.

3.3 Câu hỏi: Anti-pattern lớn nhất khi áp dụng một framework là gì?
Trả lời: Sao chép mã nguồn demo và coi framework đó là kiến trúc. Framework là công cụ triển khai; kiến trúc là mô hình trạng thái, biên giới công cụ, hợp đồng dữ liệu và các quy tắc an toàn của bạn. Nếu bạn bỏ qua các nền tảng (schemas, xử lý lỗi, đánh giá), framework sẽ chỉ làm tăng thêm sự hỗn loạn. Nhà tuyển dụng thích nghe câu "Tôi bắt đầu nhỏ và làm bền vững từng lớp".

3.4 Câu hỏi: Làm thế nào để bạn xử lý những lo ngại về việc bị khóa vào một nhà cung cấp (vendor lock-in)?
Trả lời: Trừu tượng hóa các nhà cung cấp LLM và embedding đằng sau các interface. Tránh sử dụng các tính năng đặc thù của nhà cung cấp trừ khi thực sự cần thiết. Giữ prompts, schemas và bộ đánh giá có tính di động cao. Nếu sử dụng một framework, hãy cô lập nó trong một lớp để logic nghiệp vụ cốt lõi không phụ thuộc vào nó. Sau đó bạn có thể hoán đổi framework hoặc nhà cung cấp với ít thay đổi nhất.

3.5 Câu hỏi: "Trạng thái" (state) nghĩa là gì trong một đồ thị agent?
Trả lời: Trạng thái là dữ liệu có cấu trúc chảy qua các bước: đầu vào của người dùng, lịch sử hội thoại, tài liệu được truy xuất, kết quả công cụ và các quyết định. Thiết kế trạng thái tốt là có kiểu dữ liệu rõ ràng và tối giản. Nó cho phép khả năng tái lập (chạy lại một lượt), khả năng quan sát (kiểm tra từng trường), và sự an toàn (xác thực các chuyển tiếp). Thiết kế trạng thái kém dẫn đến sự phụ thuộc ẩn và hành vi dễ gãy.

3.6 Câu hỏi: Giải thích cách bạn sẽ triển khai một router để chọn công cụ.
Trả lời: Sử dụng một chính sách: hoặc là các quy tắc (từ khóa, intents) hoặc là một bộ phân loại dựa trên LLM bị ràng buộc trong một tập hợp nhãn nhỏ. Sau đó xác thực công cụ đã chọn và các đối số dựa trên schemas. Ghi lại các quyết định và điểm tin cậy. Một mô hình mạnh mẽ là: Router (quyết định) -> Bộ thực thi công cụ (hành động) -> Bộ xác minh (kiểm tra) trước khi phản hồi.

3.7 Câu hỏi: Framework giúp ích gì cho cấu trúc đầu ra (JSON, schemas)?
Trả lời: Chúng cung cấp các parser, các ràng buộc đầu ra và các tiện ích để thực thi đầu ra có cấu trúc. Ngay cả khi không có các trợ giúp tích hợp, bạn có thể bao bọc đầu ra bằng xác thực Pydantic. Nếu việc phân tích cú pháp thất bại, framework có thể định tuyến đến một bước sửa chữa. Trong phỏng vấn, hãy nhắc đến hành vi "đóng khi thất bại" (fail-closed): nếu xác thực schema thất bại, không thực thi các hành động.

3.8 Câu hỏi: Làm thế nào để bạn gỡ lỗi các agent bên trong một framework?
Trả lời: Bắt đầu với các vết (traces): prompts, gọi công cụ, đầu vào/đầu ra, độ trễ và việc sử dụng token. Tái hiện với một seed/temperature cố định. Sau đó cô lập lỗi: đó là do truy xuất, định tuyến, lỗi công cụ, hay sự mơ hồ của prompt? Các trình gỡ lỗi đặc thù của framework rất hữu ích, nhưng cốt lõi vẫn là khả năng quan sát + phát lại (replay).

3.9 Câu hỏi: Một lộ trình di chuyển tốt từ bản demo trên notebook sang môi trường thực tế là gì?
Trả lời: Trích xuất mã nguồn vào một package, thêm quản lý cấu hình, và bao bọc agent đằng sau một API. Đưa vào các schema có kiểu dữ liệu, xử lý lỗi, thử lại và giới hạn lưu lượng (rate limits). Bổ sung các khung đánh giá với một bộ dữ liệu vàng nhỏ. Cuối cùng, container hóa và triển khai với sự giám sát. Lộ trình phân đoạn này ngăn chặn những thất bại kiểu "viết lại từ đầu".

3.10 Câu hỏi: "Stack tối giản" mặc định của bạn cho các nguyên mẫu agentic là gì?
Trả lời: Python + FastAPI, một vòng lặp agent duy nhất, một tập hợp nhỏ các công cụ với schemas nghiêm ngặt, một vector store (hoặc thậm chí là in-memory) cho RAG, và việc truy vết/logging cơ bản. Khi hành vi đã ổn định, chuyển sang một đồ thị rõ ràng (LangGraph), thêm giao diện UI (Streamlit), và triển khai các đánh giá. Chìa khóa là các thành phần chuyển động ít nhất có thể lúc ban đầu.

| Kỹ sư AI | Lộ trình (2026) | Phỏng vấn Q&A |
| ------- | ----------- | ------------- |
| 5 Các khái niệm Framework nâng cao | | |

4.1 Câu hỏi: LCEL là gì và tại sao các kỹ sư lại sử dụng nó?
Trả lời: LCEL (LangChain Expression Language) kết hợp các thành phần (prompts, models, parsers, tools) thành các pipeline. Nó khuyến khích tính mô-đun: bạn có thể đổi mô hình hoặc parser mà không cần viết lại mọi thứ. Nó cũng giúp các chuỗi (chains) phức tạp trở nên dễ đọc và dễ kiểm thử. Trong phỏng vấn, hãy nhấn mạnh lợi ích về tính kết hợp và khả năng quan sát.

4.2 Câu hỏi: "Runnables" về mặt khái niệm là gì?
Trả lời: Một runnable là một đơn vị nhận đầu vào, tạo đầu ra, và có thể được kết hợp với các runnables khác. Hãy coi nó như một khối xây dựng pipeline chức năng. Điều này giúp bạn tiêu chuẩn hóa việc thực thi, logging, thử lại và tính đồng thời. Ngay cả ngoài LangChain, ý tưởng tương tự cũng được áp dụng: các interface thống nhất cho các bước.

4.3 Câu hỏi: Làm thế nào để bạn thiết kế một quy trình bao gồm việc thử lại (retries) và dự phòng (fallbacks)?
Trả lời: Phân loại các lỗi (timeout công cụ vs đối số không hợp lệ vs lỗi phân tích mô hình). Đối với các lỗi tạm thời, hãy thử lại với sự trì hoãn tăng dần (exponential backoff). Đối với các lỗi kéo dài, hãy chuyển sang các công cụ đơn giản hơn hoặc hỏi lại người dùng. Trong đồ thị, mô hình hóa điều này một cách rõ ràng: cạnh lỗi -> node sửa chữa -> thử lại. Ghi lại mỗi lần thử để tránh vòng lặp vô hạn.

4.4 Câu hỏi: Giải thích "multi-agent" so với "single agent với tools".
Trả lời: Single agent với tools là một người đưa ra quyết định duy nhất gọi các hàm bên ngoài. Multi-agent phân chia trách nhiệm: ví dụ, người lập kế hoạch, người truy xuất, người thực thi, người phê bình. Điều này có thể cải thiện tính chuyên môn hóa và sự an toàn nhưng làm tăng độ phức tạp trong phối hợp. Nhà tuyển dụng muốn nghe rằng bạn chỉ sử dụng multi-agent khi nhiệm vụ thực sự hưởng lợi từ việc phân rã.

4.5 Câu hỏi: Một "workflow" khác biệt gì so với một "chain"?
Trả lời: Một chain thường là tuyến tính: bước A rồi B rồi C. Một workflow bao gồm các rẽ nhánh, vòng lặp, các bước phê duyệt của con người, và các đường dẫn khác nhau cho các điều kiện khác nhau. Hệ thống agentic thường cần workflow vì các nhiệm vụ thực tế có sự không chắc chắn và các thất bại một phần. Các máy trạng thái kiểu LangGraph là một sự lựa chọn tự nhiên.

4.6 Câu hỏi: Làm thế nào để bạn ngăn chặn các agent bị lặp vô hạn?
Trả lời: Thêm số bước tối đa, ngân sách thời gian và "điều kiện dừng" dựa trên các tín hiệu hoàn thành nhiệm vụ. Truy vết các lần gọi công cụ lặp lại hoặc các mô hình lập luận lặp lại. Triển khai một cơ chế giám sát (watchdog) buộc phải leo thang: hỏi người dùng hoặc trả về kết quả một phần. Trong một đồ thị, thực thi các điều này thông qua các bộ đếm trạng thái và các cạnh bảo vệ (guard edges).

4.7 Câu hỏi: "Structured output" là gì và tại sao nó lại quan trọng đối với agent?
Trả lời: Structured output có nghĩa là mô hình tạo ra dữ liệu được xác thực bằng máy (JSON tuân thủ một schema). Nó ngăn chặn việc phân tích cú pháp chuỗi dễ gãy và giảm thiểu các tham số bị ảo tưởng. Nó cũng cho phép thực thi công cụ an toàn: chỉ chạy nếu xác thực schema vượt qua. Đối với các sản phẩm agentic, structured output thường là điểm khác biệt giữa một bản demo và một hệ thống đáng tin cậy.

4.8 Câu hỏi: Làm thế nào để bạn thiết kế một bước "phê bình" (critic) hoặc bộ xác minh?
Trả lời: Định nghĩa các tiêu chí rõ ràng: có trích dẫn, có sử dụng kết quả công cụ, JSON hợp lệ, thỏa mãn các ràng buộc. Sử dụng các kiểm tra xác định trước (xác thực schema, regex, quy tắc nghiệp vụ). Tùy chọn thêm một giám khảo LLM với một bộ râu ria (rubric), nhưng hãy giữ nó như một lớp thứ hai. Nếu xác minh thất bại, định tuyến đến một bước sửa chữa hoặc hỏi để làm rõ.

4.9 Câu hỏi: Những đánh đổi của việc song song hóa các bước agent là gì?
Trả lời: Gọi công cụ song song làm giảm độ trễ nhưng có thể lãng phí chi phí nếu nhiều cuộc gọi không cần thiết. Gọi LLM song song cải thiện chất lượng thông qua "tự nhất quán" (self-consistency) nhưng tăng chi phí. Bạn nên song song hóa ở những nơi sự không chắc chắn cao và kết quả có thể tái sử dụng, và tuần tự hóa ở những nơi các quyết định phụ thuộc vào kết quả trước đó. Luôn giới hạn tính đồng thời và xử lý giới hạn lưu lượng.

4.10 Câu hỏi: Làm thế nào để bạn xử lý các nhiệm vụ chạy dài (phút/giờ) với các agent?
Trả lời: Sử dụng các công việc bất đồng bộ (async jobs) với trạng thái bền vững (DB/hàng đợi) và lưu lại điểm kiểm soát (checkpoint) sau mỗi bước. Phát các sự kiện tiến trình tới UI. Thiết kế các cuộc gọi công cụ có tính lũy đẳng (idempotent) để việc thử lại không làm lặp lại các tác dụng phụ. Đối với quy trình làm việc, mô hình hóa việc "tiếp tục từ checkpoint" để hệ thống có thể phục hồi sau khi khởi động lại.

| Kỹ sư AI | Lộ trình (2026) | Phỏng vấn Q&A |
| ------- | ----------- | ------------- |
| 6 Quản lý bộ nhớ | | |

5.1 Câu hỏi: Sự khác biệt giữa bộ nhớ ngắn hạn và dài hạn trong Agentic AI là gì?
Trả lời: Bộ nhớ ngắn hạn là cửa sổ ngữ cảnh/cuộc hội thoại ngay lập tức: các lượt hội thoại gần đây, đầu ra công cụ, trạng thái nhiệm vụ hiện tại. Bộ nhớ dài hạn được lưu trữ bên ngoài: cơ sở dữ liệu, vector stores, hồ sơ người dùng, tóm tắt. Ngắn hạn thì nhanh nhưng hạn chế; dài hạn thì có thể mở rộng nhưng cần truy xuất và lọc mức độ liên quan. Kỹ thuật ở đây là chọn cái gì để lưu và khi nào để truy xuất.

5.2 Câu hỏi: Khi nào bạn nên lưu trữ bộ nhớ dưới dạng tóm tắt văn bản so với embeddings?
Trả lời: Sử dụng tóm tắt cho "những gì đã xảy ra" trong một phiên (quyết định, cam kết, sở thích). Sử dụng embeddings cho khối lượng tri thức lớn nơi bạn cần truy xuất ngữ nghĩa (ghi chú, tài liệu, các ticket quá khứ). Thường thì bạn kết hợp cả hai: một bản tóm tắt cho ngữ cảnh nhanh cộng với embeddings cho việc thu hồi chi tiết. Đồng thời xem xét bộ nhớ có cấu trúc (key-value) cho các sự thật ổn định như đơn vị đo ưu tiên hoặc ngôn ngữ của người dùng.

5.3 Câu hỏi: Checkpointing là gì và tại sao nó quan trọng?
Trả lời: Checkpointing lưu lại trạng thái quy trình sau các bước để bạn có thể tiếp tục sau khi gặp lỗi, timeout, hoặc khi cần con người phê duyệt. Nó cực kỳ quan trọng cho các agent chạy dài và cho khả năng kiểm tra (auditability). Một checkpoint tốt bao gồm đầu vào, các lần gọi công cụ, đầu ra, và phiên bản của prompts/policies. Điều này cho phép phát lại và gỡ lỗi.

5.4 Câu hỏi: Làm thế nào để bạn ngăn chặn bộ nhớ gây ra các vấn đề về quyền riêng tư hoặc bảo mật?
Trả lời: Áp dụng tối giản hóa dữ liệu: chỉ lưu trữ những gì bạn cần. Mã hóa khi lưu trữ, hạn chế quyền truy cập theo tenant, và thiết lập các chính sách lưu giữ. Tránh lưu trữ bí mật, thông tin đăng nhập hoặc PII nhạy cảm. Nếu bạn phải lưu trữ bộ nhớ đặc thù của người dùng, hãy cho người dùng sự minh bạch và quyền kiểm soát. Đồng thời vệ sinh đầu ra công cụ trước khi lưu.

5.5 Câu hỏi: "Lập ngân sách ngữ cảnh" (context budgeting) cho bộ nhớ là gì?
Trả lời: Đó là việc quyết định bao nhiêu phần trong cửa sổ ngữ cảnh được phân bổ cho hướng dẫn, chat gần đây, tài liệu được truy xuất và bộ nhớ. Bạn có thể thực thi các ngân sách: ví dụ, tối đa 30% cho tài liệu truy xuất, tối đa 20% cho tóm tắt bộ nhớ. Khi vượt quá ngân sách, hãy nén: tóm tắt, khử trùng lặp và bỏ các nội dung giá trị thấp. Ngân sách ngăn chặn các hướng dẫn hệ thống quan trọng bị đẩy ra khỏi khung hình.

5.6 Câu hỏi: Làm thế nào để bạn đánh giá xem bộ nhớ giúp ích hay gây hại?
Trả lời: Chạy thử nghiệm A/B có và không có bộ nhớ và so sánh tỷ lệ thành công nhiệm vụ, tỷ lệ ảo tưởng và sự hài lòng của người dùng. Bộ nhớ có thể gây hại khi đưa vào các sự thật đã lỗi thời hoặc không liên quan. Sử dụng tính điểm độ tươi mới (freshness scoring) và quy tắc giải quyết xung đột. Trong phỏng vấn, hãy nhắc đến việc giám sát "tỷ lệ khớp bộ nhớ" (memory hit rate) và các trường hợp "lỗi do bộ nhớ gây ra".

5.7 Câu hỏi: Giải thích về "tính mới" (recency) so với "tính liên quan" (relevance) trong truy xuất bộ nhớ.
Trả lời: Tính mới ưu tiên thông tin mới hơn; tính liên quan ưu tiên sự tương đồng ngữ nghĩa. Trong thực tế, bạn cân bằng cả hai: truy xuất các kết quả khớp ngữ nghĩa hàng đầu, sau đó xếp hạng lại theo độ mới và độ tin cậy. Đối với sở thích của người dùng, tính mới có thể quan trọng (người ta hay thay đổi ý định). Đối với các sự thật ổn định, tính liên quan chiếm ưu thế.

5.8 Câu hỏi: Làm thế nào để bạn triển khai bộ nhớ cho hệ thống đa agent?
Trả lời: Quyết định cái gì là dùng chung (shared) so với riêng tư (private). Bộ nhớ dùng chung có thể bao gồm kế hoạch nhiệm vụ và các sự thật đã xác minh; bộ nhớ riêng tư có thể bao gồm các ghi chú trung gian của một agent chuyên gia. Sử dụng trạng thái có cấu trúc được chuyển qua đồ thị làm "sự thật" chính, và lưu trữ các thành phẩm dài hạn bên ngoài. Luôn bao gồm thông tin nguồn gốc (provenance): mỗi bộ nhớ đến từ đâu và khi nào.

5.9 Câu hỏi: Các chế độ thất bại phổ biến của bộ nhớ dài hạn là gì?
Trả lời: Truy xuất các đoạn văn bản không liên quan, lưu trữ thông tin nhiễu hoặc chưa xác minh, và các vòng lặp phản hồi nơi các ảo tưởng được lưu lại dưới dạng bộ nhớ. Ngoài ra: các sở thích cũ rích và các bộ nhớ xung đột. Giảm thiểu bằng xác thực (chỉ lưu các sự thật đã xác minh), suy giảm/hết hạn, và một chính sách "không lưu trữ" cho các nội dung không chắc chắn. Một quy tắc tốt là "chỉ lưu giữ những gì bạn có thể giải trình".

5.10 Câu hỏi: Làm thế nào để bạn xử lý các chỉnh sửa của người dùng đối với bộ nhớ?
Trả lời: Hãy coi các chỉnh sửa của người dùng là mức độ ưu tiên cao. Cập nhật các trường bộ nhớ có cấu trúc và đánh dấu các mục cũ là đã quá hạn thay vì xóa mù quáng (để có thể kiểm tra sau này). Nếu sử dụng embeddings, hãy lưu một ghi chú chỉnh sửa mới và xếp hạng lại theo độ mới. Cung cấp một giao diện UI/câu lệnh đơn giản để người dùng có thể xem và chỉnh sửa những gì đang được ghi nhớ.

| Kỹ sư AI | Lộ trình (2026) | Phỏng vấn Q&A |
| ------- | ----------- | ------------- |
| 7 Tích hợp Công cụ | | |

6.1 Câu hỏi: Điều gì làm cho một công cụ trở nên "thân thiện với agent"?
Trả lời: Tên rõ ràng, mục đích hẹp, schema đầu vào có kiểu dữ liệu, đầu ra xác định và thất bại nhanh. Công cụ nên trả về dữ liệu có cấu trúc, không phải là những bài tự sự dài dòng. Chúng nên thực thi timeouts và trả về các mã lỗi hữu ích. Các công cụ thân thiện với agent thì dễ kiểm thử và an toàn để gọi đi gọi lại.

6.2 Câu hỏi: Làm thế nào để bạn hiển thị các công cụ có tác dụng phụ một cách an toàn (email, mua hàng, xóa dữ liệu)?
Trả lời: Sử dụng quyền đặc quyền tối thiểu và tách biệt các công cụ "đọc" khỏi các công cụ "ghi". Yêu cầu xác nhận rõ ràng cho các hành động không thể đảo ngược. Thêm các kiểm tra chính sách và các bước phê duyệt từ con người. Ghi lại mọi hành động với đầu vào, đầu ra và danh tính người dùng. Trong phỏng vấn, hãy nhấn mạnh rằng agent không bao giờ được trực tiếp thực thi các hành động rủi ro cao mà không có các rào chắn (guardrails).

6.3 Câu hỏi: Giải thích vai trò của một allowlist (danh sách cho phép) và sandbox (hộp cát) cho các công cụ.
Trả lời: Một allowlist giới hạn những công cụ nào mà mô hình có thể gọi. Một sandbox giới hạn những gì các công cụ đó có thể làm (ví dụ: hạn chế hệ thống tập tin, quy tắc thoát mạng). Cùng nhau, chúng làm giảm thiệt hại từ các lời gọi công cụ ảo tưởng hoặc prompt injection. Tiêu chuẩn là chặn thực thi mã tùy ý trừ khi môi trường được cách ly hoàn toàn và được kiểm tra.

6.4 Câu hỏi: Làm thế nào để bạn thiết kế đầu ra của công cụ để giảm thiểu sự phình to của ngữ cảnh?
Trả lời: Chỉ trả về những gì agent cần: các trường súc tích và các bản tóm tắt. Cung cấp phân trang hoặc kết quả "top-k". Loại bỏ HTML, nhật ký và siêu dữ liệu không liên quan. Nếu cần, hãy lưu trữ các đầu ra thô lớn bên ngoài và trả về một ID tham chiếu ngắn. Điều này giữ cho cửa sổ ngữ cảnh tập trung và ít tốn kém hơn.

6.5 Câu hỏi: Cho ví dụ tối giản về một hàm wrapper công cụ tùy chỉnh.
Trả lời: Hãy giữ nó có tính xác định, được xác thực, và an toàn về timeout.
```python
import httpx
from pydantic import BaseModel

class SearchArgs(BaseModel):
    q: str
    k: int = 5

async def web_search(args: SearchArgs) -> dict:
    async with httpx.AsyncClient(timeout=10.0) as client:
        r = await client.get("https://example.com/search", params=args.model_dump())
        r.raise_for_status()
        return r.json()
```
Ngay cả khi framework của bạn có các decorator, các nguyên lý kỹ thuật là như nhau.

6.6 Câu hỏi: Làm thế nào để bạn xử lý các lỗi công cụ để agent có thể phục hồi?
Trả lời: Trả về các lỗi có cấu trúc: mã, thông điệp, và cờ có thể thử lại. Đối với các thất bại có thể thử lại (timeouts), hãy thử lại với backoff. Đối với các lỗi không thể thử lại (xác thực), hãy yêu cầu mô hình sửa đầu vào. Luôn giới hạn số lần thử lại và hiển thị lỗi trong nhật ký/truy vết. Một agent không thể tự sửa chữa nên hạ cấp một cách duyên dáng và hỏi người dùng.

6.7 Câu hỏi: Sự khác biệt giữa "tools" và "plugins/connectors" là gì?
Trả lời: Tools là các hàm có thể gọi được trong môi trường chạy của bạn. Connectors/plugins thường bao bọc các dịch vụ bên ngoài với bộ phận xác thực và khám phá (Google Drive, Slack, Jira). Những lo ngại về mặt kỹ thuật bao gồm luồng OAuth, làm mới token và phạm vi cấp phép. Trong phỏng vấn, hãy nhấn mạnh các biên giới quyền hạn: agent chỉ có thể truy cập những gì người dùng đã ủy quyền.

6.8 Câu hỏi: Làm thế nào để bạn quản lý phiên bản công cụ và giữ tính tương thích ngược?
Trả lời: Hãy coi các công cụ như các API. Quản lý phiên bản cho schemas (ví dụ: tool_v1, tool_v2) hoặc hỗ trợ các trường tùy chọn. Ngừng hỗ trợ dần dần và giám sát việc sử dụng. Trong các agent, ghim phiên bản công cụ trên từng quy trình làm việc để hành vi được ổn định. Điều này ngăn chặn những hư hỏng âm thầm khi công cụ phát triển.

6.9 Câu hỏi: Làm thế nào để bạn ngăn chặn mô hình gọi các công cụ không cần thiết?
Trả lời: Sử dụng các chính sách sử dụng công cụ rõ ràng: "chỉ gọi một công cụ khi bạn cần sự thật bên ngoài". Thêm một bước phân loại để chọn "trả lời trực tiếp" so với "sử dụng công cụ". Phạt các lời gọi công cụ không cần thiết trong đánh giá. Đồng thời hãy mặc định coi các công cụ là tốn kém: agent sẽ học rằng công cụ là tài nguyên khan hiếm.

6.10 Câu hỏi: Những tín hiệu quan sát nào quan trọng nhất cho việc tích hợp công cụ?
Trả lời: Độ trễ công cụ, tỷ lệ lỗi trên từng công cụ, số lần thử lại, khối lượng yêu cầu, và kích thước đầu ra. Đồng thời truy vết các lời gọi công cụ nào tương quan với việc hoàn thành nhiệm vụ thành công. Thêm các trace spans cho mỗi lần gọi công cụ và bao gồm các đối số đã được vệ sinh. Điều này giúp bạn tìm ra công cụ là nút thắt cổ chai hoặc công cụ gây ra nhiều hỏng hóc cho agent nhất.

| Kỹ sư AI | Lộ trình (2026) | Phỏng vấn Q&A |
| ------- | ----------- | ------------- |
| 8 Hệ thống RAG | | |

7.1 Câu hỏi: RAG giải quyết vấn đề gì trong Agentic AI?
Trả lời: RAG (Truy xuất-Tăng cường-Tạo) đưa kiến thức bên ngoài vào prompt bằng cách truy xuất tài liệu liên quan. Nó làm giảm ảo tưởng và cho phép cập nhật thông tin mới nhất hoặc kiến thức riêng tư mà không cần huấn luyện lại. Với hệ thống agent, RAG cũng cung cấp bằng chứng cho các quyết định và các lời gọi công cụ. Những câu trả lời tốt nhất là dẫn nguồn từ tài liệu truy xuất và tránh bịa ra các sự thật bị thiếu.

7.2 Câu hỏi: Làm thế nào để chọn chunk size (kích thước mảnh) và overlap (độ chồng lấp) khi đánh chỉ mục tài liệu?
Trả lời: Chunk size phụ thuộc vào cấu trúc tài liệu và mô hình truy vấn. Quá nhỏ: bạn mất ngữ cảnh; quá lớn: truy xuất trở nên nhiễu và đắt đỏ. Điểm bắt đầu phổ biến là 300-800 token với 10-20% chồng lấp, sau đó tinh chỉnh qua đánh giá. Sử dụng chunking ngữ nghĩa (chia theo tiêu đề) khi có thể. Luôn đo lường chất lượng truy xuất, đừng đoán mò.

7.3 Câu hỏi: Sự khác biệt giữa dense truy xuất, sparse truy xuất, và hybrid truy xuất là gì?
Trả lời: Dense sử dụng embeddings để khớp ý nghĩa. Sparse sử dụng các phương pháp dựa trên từ ngữ (BM25) vốn xuất sắc ở việc khớp chính xác từ khóa. Hybrid kết hợp cả hai và thường cải thiện độ phủ (recall), đặc biệt đối với các thuật ngữ kỹ thuật. Nhiều hệ thống thực tế truy xuất bằng hybrid sau đó xếp hạng lại (re-rank) bằng một cross-encoder hoặc LLM.

7.4 Câu hỏi: Giải thích về re-ranking và tại sao nó cải thiện RAG.
Trả lời: Truy xuất ban đầu mang tính xấp xỉ. Re-ranking sử dụng một mô hình mạnh hơn để chấm điểm các mảnh ứng viên so với truy vấn. Điều này cải thiện độ chính xác của ngữ cảnh cuối cùng, từ đó cải thiện chất lượng câu trả lời và giảm ảo tưởng. Tuy nhiên nó phải trả giá bằng độ trễ tăng thêm. Trong phỏng vấn, hãy nhắc đến việc cân bằng chất lượng so với độ trễ và việc lưu bộ nhớ đệm (caching) các truy vấn thường gặp.

7.5 Câu hỏi: Làm thế nào để bạn ngăn chặn việc truy xuất không liên quan làm ô nhiễm câu trả lời?
Trả lời: Sử dụng top-k một cách cẩn thận (không quá cao), áp dụng re-ranking, và lọc theo siêu dữ liệu (ngày, nguồn, quyền hạn). Thêm điều kiện "không có bằng chứng liên quan" để kích hoạt việc từ chối hoặc một câu hỏi để làm rõ. Ngoài ra, hãy tóm tắt các mảnh được truy xuất trước khi đưa ra câu trả lời cuối cùng. Cuối cùng, yêu cầu các trích dẫn ánh xạ tới các mảnh đã truy xuất để thực thi tính căn cứ (grounding).

7.6 Câu hỏi: Những chỉ số đánh giá nào quan trọng đối với RAG?
Trả lời: Chỉ số truy xuất: recall@k, precision@k, MRR, nDCG. Chỉ số câu trả lời: tính xác thực, tính chính xác của trích dẫn, sự thành công của nhiệm vụ. Đồng thời đo lường độ trễ, chi phí và tỷ lệ thất bại. Một cách tiếp cận thực tế là một bộ dữ liệu được tuyển chọn nhỏ với các nguồn và câu trả lời dự kiến, cộng với phân tích lỗi.

7.7 Câu hỏi: Làm thế nào để bạn xử lý cập nhật tài liệu và giữ cho chỉ mục luôn mới?
Trả lời: Sử dụng đánh chỉ mục tăng dần: phát hiện các tài liệu bị thay đổi, nhúng lại (re-embed) các mảnh bị ảnh hưởng, và cập nhật siêu dữ liệu. Theo dõi phiên bản tài liệu và dấu thời gian. Đối với các nguồn thay đổi nhiều, hãy xem xét việc đưa dữ liệu vào theo luồng (streaming ingestion). Trong phỏng vấn, hãy nhấn mạnh rằng chỉ mục lỗi thời sẽ gây ra câu trả lời sai, vì vậy việc giám sát độ tươi mới là một yêu cầu sản xuất.

7.8 Câu hỏi: Lọc theo siêu dữ liệu (metadata filtering) là gì và tại sao nó lại quan trọng?
Trả lời: Lọc siêu dữ liệu giới hạn việc truy xuất theo các trường như tenant (khách thuê), quyền hạn, loại tài liệu, ngày tháng hoặc ngôn ngữ. Nó ngăn chặn rò rỉ dữ liệu giữa các người dùng và cải thiện sự liên quan. Bạn nên thực thi các bộ lọc siêu dữ liệu bên ngoài mô hình (trong mã nguồn) để chúng không thể bị bỏ qua. Đây là yêu cầu an ninh then chốt cho RAG doanh nghiệp.

7.9 Câu hỏi: Giải thích về "grounded generation" (tạo dựa trên căn cứ) và trích dẫn trong RAG.
Trả lời: Grounded generation có nghĩa là các tuyên bố của mô hình phải được hỗ trợ bởi bằng chứng đã truy xuất. Trích dẫn ánh xạ các câu văn tới các nguồn (Chunk IDs hoặc URLs). Bạn có thể thực thi trích dẫn bằng cách định dạng các mảnh đã truy xuất với IDs và yêu cầu mô hình tham chiếu chúng. Sau đó bạn có thể tự động xác minh trích dẫn để giảm thiểu các tham chiếu ảo tưởng.

7.10 Câu hỏi: Các trường hợp thất bại RAG phổ biến và cách bạn khắc phục chúng là gì?
Trả lời: Chunking không tốt, embeddings yếu cho lĩnh vực/ngôn ngữ đó, thiếu bộ lọc siêu dữ liệu, và top-k quá cao hoặc quá thấp. Ngoài ra còn có sự không khớp truy vấn: người dùng hỏi "như thế nào" nhưng truy xuất lại tìm thấy "cái gì". Các cách khắc phục bao gồm chunking tốt hơn, hybrid truy xuất, re-ranking, thay đổi prompt, và thêm việc viết lại truy vấn. Luôn thực hiện phân tích lỗi với các truy vấn và nhật ký thực tế.

| Kỹ sư AI | Lộ trình (2026) | Phỏng vấn Q&A |
| ------- | ----------- | ------------- |
| 9 Agents & Multi-Agents | | |

8.1 Câu hỏi: Mô hình ReAct là gì?
Trả lời: ReAct đan xen giữa lập luận (lập kế hoạch) với các hành động (gọi công cụ) và quan sát (kết quả công cụ). Agent lặp lại việc quyết định phải làm gì tiếp theo dựa trên các quan sát. Nó cải thiện tính xác thực vì agent có thể tra cứu thông tin thay vì đoán. Thách thức kỹ thuật: kiểm soát các vòng lặp, việc lạm dụng công cụ và sự phình to của ngữ cảnh.

8.2 Câu hỏi: Supervisor agent là gì và khi nào bạn sử dụng nó?
Trả lời: Một supervisor điều phối các agent chuyên gia (người truy xuất, người viết mã, người phê bình) bằng cách định tuyến nhiệm vụ và hợp nhất đầu ra. Sử dụng nó khi nhiệm vụ đủ phức tạp để hưởng lợi từ chuyên môn hóa. Tuy nhiên, supervisor thêm chi phí vận hành và có thể che giấu lỗi nếu không được theo dõi. Một thiết kế tốt là một supervisor với các tiêu chí rõ ràng để giao phó và chấp nhận kết quả.

8.3 Câu hỏi: Làm thế nào để các agent giao tiếp an toàn và hiệu quả?
Trả lời: Sử dụng các thông điệp có cấu trúc: mục tiêu, ràng buộc, trạng thái hiện tại, và định dạng đầu ra yêu cầu. Tránh truyền ngữ cảnh thô quá lớn; hãy truyền tham chiếu và tóm tắt. Thực thi biên giới vai trò để agent không ghi đè chính sách hệ thống. Ngoài ra, hãy truy vết nguồn gốc: agent nào tạo ra tuyên bố nào. Điều này hỗ trợ việc gỡ lỗi và trách nhiệm giải trình.

8.4 Câu hỏi: Sự khác biệt giữa "lập kế hoạch" (planning) và "thực thi" (execution) trong hệ thống agent là gì?
Trả lời: Lập kế hoạch chọn các bước và công cụ; thực thi thực hiện chúng. Tách biệt chúng giúp giảm rủi ro: người lập kế hoạch có thể đề xuất hành động, nhưng người thực thi xác thực và chỉ chạy những hành động an toàn. Điều này tương tự như "chạy thử" (dry run) rồi mới "cam kết" (commit). Nhiều hệ thống thực tế giữ việc lập kế hoạch ở temperature thấp và thực thi được xác thực schema nghiêm ngặt.

8.5 Câu hỏi: Làm thế nào để bạn xử lý sự không chắc chắn trong các quyết định của agent?
Trả lời: Làm cho sự không chắc chắn trở nên rõ ràng: điểm tin cậy, các giả định, và cờ "cần thêm thông tin". Thêm các chính sách: nếu tin cậy thấp, hãy gọi một công cụ hoặc hỏi một câu làm rõ. Tránh ép buộc một phỏng đoán duy nhất. Trong phỏng vấn, hãy nhắc đến việc xử lý sự không chắc chắn là một tính năng của độ tin cậy, không phải là một điểm yếu.

8.6 Câu hỏi: Làm thế nào để bạn ngăn chặn việc lạm dụng công cụ trong các thiết lập đa agent?
Trả lời: Tập trung hóa việc thực thi công cụ sau một cổng chính sách. Ngay cả khi một agent chuyên gia yêu cầu một công cụ, bộ thực thi vẫn phải thực thi allowlists, phạm vi, và giới hạn lưu lượng. Ghi nhật ký mọi yêu cầu và các trường hợp bị từ chối. Ngoài ra, hãy giới hạn tập hợp công cụ của mỗi agent chỉ ở những gì nó cần. Điều này làm giảm phạm vi ảnh hưởng nếu một agent bị xâm nhập hoặc nhầm lẫn.

8.7 Câu hỏi: "Nghị định thư agent" (agent protocol) là gì và tại sao nó lại quan trọng?
Trả lời: Đó là định dạng tiêu chuẩn hóa mà các agent sử dụng cho đầu vào/đầu ra (schemas, các trường, quy ước về lỗi). Nghị định thư làm giảm sự hiểu lầm và khiến hành vi hệ thống trở nên dễ dự đoán. Chúng cũng cho phép hoán đổi agent hoặc mô hình mà không làm hỏng quy trình. Một nghị định thư đơn giản bao gồm: mục tiêu, ràng buộc, tham chiếu ngữ cảnh, kết quả công cụ, và câu trả lời cuối cùng có trích dẫn.

8.8 Câu hỏi: Mô tả một thiết kế đa agent thực tế cho RAG + viết bản báo cáo cuối cùng.
Trả lời: Sử dụng một retriever agent để thu thập và xếp hạng nguồn, một summarizer agent để trích xuất các ý chính có dẫn chứng, một writer agent để soạn thảo báo cáo, và một critic agent để kiểm tra các tuyên bố không được hỗ trợ. Supervisor điều phối: truy xuất -> tóm tắt -> soạn thảo -> xác minh. Nếu xác minh thất bại, quay lại bước truy xuất. Mô hình này cân bằng chất lượng và tính căn cứ.

8.9 Câu hỏi: Làm thế nào để đánh giá một agent hơn là chỉ nói "có vẻ tốt"?
Trả lời: Tạo các bộ nhiệm vụ (task suites): các mục tiêu thực tế của người dùng với kết quả mong đợi. Đo lường tỷ lệ thành công, số lượng cuộc gọi công cụ, độ trễ/chi phí và các vi phạm an toàn. Thêm các thùng chứa lỗi định tính (lỗi truy xuất, sai công cụ, lập luận tệ, hành động không an toàn). Sử dụng các bài kiểm tra thụt lùi (regression tests) trên các prompt và chính sách. Đánh giá là liên tục vì các mô hình, công cụ và dữ liệu luôn thay đổi.

8.10 Câu hỏi: Những lo ngại về an toàn then chốt nào là duy nhất đối với các agent?
Trả lời: Agent có thể thực hiện hành động (viết file, gửi tin nhắn, thực hiện thay đổi), vì vậy các lỗi có hậu quả thực sự. Prompt injection có thể chuyển hướng các hành động. Đầu ra công cụ có thể chứa các hướng dẫn độc hại. Biện pháp giảm thiểu: đặc quyền tối thiểu, yêu cầu xác nhận, sandboxing, các cổng chính sách, và nhật ký kiểm tra. An toàn là một lớp kỹ thuật, không phải chỉ là vấn đề của prompt.

| Kỹ sư AI | Lộ trình (2026) | Phỏng vấn Q&A |
| ------- | ----------- | ------------- |
| 10 Xây dựng các dự án thực tế | | |

9.1 Câu hỏi: Mô tả một kiến trúc đầu-cuối (end-to-end) cho một ứng dụng agent thực tế.
Trả lời: Một kiến trúc điển hình: UI (Streamlit/React) -> API (FastAPI) -> Agent Orchestrator (đồ thị) -> Tools (các dịch vụ nội bộ/APIs) + RAG (vector store) + Memory (DB). Thêm khả năng quan sát (logs, traces, metrics) và các đường ống đánh giá. Sử dụng một hàng đợi cho các nhiệm vụ dài và một bộ nhớ đệm cho các truy xuất lặp lại. Bảo mật bao gồm auth, cô lập tenant và quản lý bí mật.

9.2 Câu hỏi: Tại sao FastAPI là sự lựa chọn phổ biến cho backends của agent?
Trả lời: FastAPI nhanh để phát triển, hỗ trợ async, có kiểu dữ liệu mạnh mẽ qua Pydantic, và tự tạo tài liệu OpenAPI. Điều này khiến các endpoint của công cụ và API của agent được định nghĩa rõ ràng. Nó cũng tích hợp tốt với dependency injection và middleware cho logging/auth. Trong phỏng vấn, hãy nhắc đến việc xác thực đầu vào và các hợp đồng dựa trên schema.

9.3 Câu hỏi: Làm thế nào để bạn xây dựng một UI Streamlit đơn giản cho một agent?
Trả lời: Bắt đầu với một bố cục chat: hộp nhập liệu, lịch sử tin nhắn, và một bảng "gỡ lỗi" cho các trace. Gửi tin nhắn của người dùng tới FastAPI, stream các phản hồi, và hiển thị trích dẫn/các bước công cụ. Giữ trạng thái người dùng ở mức tối thiểu và dựa vào ID phiên (session IDs) của hệ thống backend. Một UI tốt làm cho các lỗi trở nên dễ thấy để người dùng có thể sửa chữa nhanh chóng.

9.4 Câu hỏi: Những gì nên có trong một Dockerfile cho một ứng dụng agentic?
Trả lời: Sử dụng một base image gọn nhẹ (slim), ghim các phụ thuộc Python, và chỉ sao chép các tệp cần thiết. Thiết lập các biến môi trường cho cấu hình và chạy dưới quyền một người dùng không phải root. Thêm các kiểm tra sức khỏe (health checks) và mở các cổng kết nối. Xây dựng các image riêng biệt cho API và worker nếu bạn có các công việc chạy ngầm. Trong phỏng vấn, hãy nhắc đến các bản build có thể tái lập và quét lỗ hổng bảo mật.

9.5 Câu hỏi: Làm thế nào bạn sẽ triển khai cái này trên AWS?
Trả lời: Các lựa chọn phổ biến: ECS/Fargate cho containers, EKS cho Kubernetes, hoặc Lambda cho các API serverless nhỏ. Sử dụng RDS/DynamoDB cho trạng thái, S3 cho thành phẩm, và một managed vector store hoặc tự lưu trữ. Sử dụng Secrets Manager cho bằng chứng xác thực. Thêm CloudWatch logs/metrics và các cảnh báo. Chọn dịch vụ đơn giản nhất đáp ứng được nhu cầu mở rộng và tuân thủ.

9.6 Câu hỏi: Bạn thêm khả năng quan sát nào để gỡ lỗi agent?
Trả lời: Logs có cấu trúc với request IDs, các trace spans cho mỗi bước của agent và cuộc gọi công cụ, các chỉ số về độ trễ, việc sử dụng token và các lỗi. Chụp lại prompts và các đối số công cụ dưới dạng đã được vệ sinh. Thêm cơ chế phát lại: với một trace ID, tái tạo lại lượt chạy đó. Điều này thiết yếu để chẩn đoán các thất bại không liên tục.

9.7 Câu hỏi: Làm thế nào để bạn xử lý phản hồi dạng luồng (streaming) tới người dùng?
Trả lời: Stream các token từ mô hình khi có thể để có trải nghiệm người dùng tốt hơn. Tuy nhiên, hãy giữ các cuộc gọi công cụ không phải dạng stream hoặc stream các sự kiện tiến trình (ví dụ: "Đang tìm kiếm...", "Đang gọi API..."). Đảm bảo quản lý áp lực ngược (backpressure) và timeouts. Nếu streaming thất bại, hãy quay lại trả về phản hồi đầy đủ. Trong phỏng vấn, hãy nhắc rằng streaming không thay thế được tính chính xác hay các trích dẫn.

9.8 Câu hỏi: Làm thế nào để bạn bảo mật một API của agent được tiếp xúc với internet?
Trả lời: Yêu cầu xác thực, giới hạn lưu lượng trên mỗi người dùng, và thực thi cô lập tenant. Xác thực mọi đầu vào. Hạn chế phạm vi công cụ dựa trên quyền của người dùng. Vệ sinh nhật ký để tránh rò rỉ bí mật. Ngoài ra, hãy phòng thủ trước prompt injection bằng cách coi nội dung người dùng là không đáng tin và thực thi các chính sách hệ thống.

9.9 Câu hỏi: Làm thế nào để bạn thiết lập CI/CD cho một dự án agent?
Trả lời: Chạy linting, kiểm tra kiểu dữ liệu, các bài unit tests, và các bài integration tests (giả lập công cụ). Xây dựng và quét các Docker images. Triển khai tới một môi trường staging với các prompt/chính sách thử nghiệm (canary). Chạy các bộ đánh giá sau mỗi thay đổi và chặn việc triển khai nếu các chỉ số bị thụt lùi. Điều này coi prompts và policies giống như mã nguồn.

9.10 Câu hỏi: "Sẵn sàng cho sản xuất" (production readiness) nghĩa là gì đối với Agentic AI?
Trả lời: Có nghĩa là sự tin cậy, an toàn, khả năng quan sát và khả năng bảo trì. Agent nên hạ cấp một cách duyên dáng, dẫn nguồn bằng chứng, và tránh các hành động không an toàn. Bạn nên có khả năng tái lập các thất bại từ nhật ký. Chi phí và độ trễ phải được kiểm soát. Quan trọng nhất, bạn liên tục đánh giá hệ thống khi mô hình, công cụ và dữ liệu phát triển.

| Kỹ sư | AI | Lộ trình | (2026) | | | | | | Phỏng vấn Q&A |
| --------- | ------------- | --- | ------- | ------ | ----- | ------ | ------- | ----------------- | ------------- |
| 11 Danh sách | nhanh: | Thứ tự | đúng | để học | (2026) | | | | |
| 1. Cơ bản về Python: | kiểu dữ liệu, | | APIs, | async, | cấu trúc | dự án, | tests. | | |
2. Cơ bản về LLM: tokens, ngân sách ngữ cảnh, prompting, gọi công cụ.
3. Lựa chọn Framework: bắt đầu đơn giản, sau đó nâng cấp lên đồ thị/quy trình.
| 4. Khái niệm | | nâng cao: | composition, | | retries, | | fallbacks, | xác minh. | |
| ----------- | --------- | ------------ | ------------ | -------------- | ----------- | ------- | -------------- | --------------- | --- |
| 5. Bộ nhớ: | | tóm tắt | + | vector | truy xuất | + | checkpointing. | | |
| 6. Công cụ: | schemas, | cổng an toàn, | | khả năng quan sát. | | | | | |
| 7. RAG: | chunking, | hybrid | | truy xuất, | re-ranking, | | đánh giá. | | |
| 8. Agents: | ReAct, | supervisors, | | protocols, | | an toàn. | | | |
| 9. Dự án | thực tế: | FastAPI | | + UI | + Docker | + | cloud | + CI/CD + eval. | |
Mẹo phỏng vấn: Mang theo 2-3 dự án cụ thể (thậm chí nhỏ) cho thấy việc sử dụng công cụ, RAG, đánh giá và tư duy sản xuất. Sẵn sàng giải thích một lần thất bại bạn đã gỡ lỗi (nhiễu truy xuất, timeout công cụ, lỗi phân tích cú pháp schema) và cách bạn đã khắc phục nó.
