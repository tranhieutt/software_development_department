# Harness Engineering → Coordination Engineering
**Phân tích kiến trúc tầng phát triển tiếp theo của SDD**

> Ngày: 2026-04-23  
> Người thực hiện: Claude Sonnet 4.6  
> Revision 1: 2026-04-23 — fix factual claim về decision_ledger, thêm §5.1 boundary vs specs, §6.5 anti-pattern watch, verify criteria cho roadmap  
> Revision 2: 2026-04-23 — merge rebuttal findings (maturity labels, authority boundary, source-of-truth registry, fix API.md gap)  
> Loại: Architecture Analysis Report  
> Related: `harness-to-coordination-engineering-rebuttal.md`

---

## 1. Bối cảnh

Câu hỏi đặt ra: *"Bước phát triển tiếp theo của harness engineering là Coordination Engineering có hợp lý không?"*

Để trả lời, cần nhìn vào những gì harness engineering đã xây dựng được và những gì còn thiếu trong hệ thống SDD hiện tại.

---

## 2. Harness Engineering đang giải quyết gì?

SDD hiện tại đã xây dựng các thành phần cốt lõi. Để tránh over-claim completeness, dùng thang **5 mức độ trưởng thành** (từ rebuttal §2 Finding 4):

| Status | Ý nghĩa |
|---|---|
| **Baseline exists** | Artifact/policy tồn tại, dùng được manual |
| **Operational** | Runtime path tồn tại và được dùng trong workflow bình thường |
| **Needs adoption** | Capability có nhưng chưa consistent invoke |
| **Needs tooling** | Policy có nhưng thiếu automation ergonomic |
| **Needs consolidation** | Nhiều artifact overlap hoặc conflict |

### Trạng thái thực tế các capability

| Capability | Artifact | Trạng thái |
|---|---|---|
| Agent identity & domain | `.claude/agents/*.md` | Operational |
| Delegation hierarchy | `agent-coordination-map.md` | Baseline exists |
| Routing & fallback | Circuit breaker, Rule 14 | Operational with open consolidation items |
| Failure handling | Layered recovery, Rule 6 | Operational |
| Session persistence | `active.md`, memory tiers | Operational |
| Decision ledger | `decision_ledger.jsonl` + `/trace-history` | Operational write path, **needs read adoption** |
| Handoff protocol | Rule 16, `.tasks/handoffs/` | Baseline exists, **downgraded due to friction** |
| API contract discipline | `design/specs/`, ad-hoc | Baseline exists, **needs source-of-truth consolidation** |

**Kết luận:** Harness = infrastructure cho agents *tồn tại* và *hoạt động độc lập* — nhưng không phải tất cả đều ở mức Operational. Gaps thực tế tập trung ở 3 dòng cuối.

---

## 3. Điểm mù lớn nhất của hệ thống hiện tại

Quan sát từ thực tế vận hành SDD:

> **Các agents biết *ai* và biết *làm gì* — nhưng không biết *tại sao đang làm* và *trạng thái chung đang ở đâu*.**

### Ví dụ minh họa

```
backend-developer  → implement xong API
frontend-developer → bắt đầu integrate
```

Vấn đề: Hai agent này **không có shared truth** về:
- Contract đã thay đổi chưa?
- Endpoint nào đã stable, endpoint nào vẫn đang draft?
- Acceptance criteria của slice này là gì?

`producer` phải là người trung gian — nhưng producer cũng chỉ biết qua text, không có state machine. Kết quả: friction cao, dễ desync.

### Bằng chứng trong codebase

Rule 16 (A2A Handoff Contracts) đã bị downgrade từ **MUST → SHOULD** vì:

> *"No handoff contracts were generated across multiple sessions, indicating the full protocol has too much friction."*

Đây là dấu hiệu rõ ràng nhất: coordination đang bị hy sinh vì thiếu shared state infrastructure.

---

## 4. Phân tích: Coordination Engineering có phải bước tiếp theo không?

### Câu trả lời ngắn

**Có — nhưng cần phân tầng chính xác hơn.**

"Coordination Engineering" là một umbrella term bao gồm nhiều tầng khác nhau. Gọi nó là một bước duy nhất sẽ dẫn đến over-engineering.

### Ba tầng thực sự

```
Tầng 1: Harness Engineering                       → agents có thể TỒN TẠI
Tầng 2: Shared State Adoption &                   → agents BIẾT nhau đang ở đâu
        Source-of-Truth Consolidation               (dựa trên authority rõ ràng)
Tầng 3: Coordination Engineering                  → agents có thể NEGOTIATE và CONFLICT-RESOLVE
```

SDD đã hoàn thành Tầng 1. Bước tiếp theo là **Tầng 2 — Shared State Adoption & Source-of-Truth Consolidation**, không phải nhảy thẳng lên Tầng 3.

> **Lưu ý về naming:** Tầng 2 **không phải** "xây thêm artifact mới" mà là **consolidate authority** giữa các artifact đã có + tạo adoption cho infra đã có (decision ledger, handoff protocol). Đây là lý do đổi tên từ "Shared State Engineering" (dễ hiểu lầm là build-heavy) sang "Shared State **Adoption**" (adoption-first).

---

## 5. Shared State Adoption là gì?

### Định nghĩa

Consolidate authority giữa các source-of-truth đã tồn tại + adoption cho infra đã có. Các agents **đọc trực tiếp** shared artifacts (thay vì nhận state qua producer làm text relay), nhưng **decision authority vẫn đi qua human / producer / Rule 3 escalation** — shared state chỉ giảm relay friction, không bypass orchestrator authority. Xem §5.5 để biết ranh giới chi tiết.

### Bốn artifact cụ thể cần xử lý

> **Ordering note:** §5.1 (Registry) là **prerequisite** cho 3 artifact còn lại. Không được build contract/read-gate/handoff trước khi Registry xác định authority của từng artifact đó.

#### 5.1 Source-of-Truth Registry *(prerequisite cho tất cả)*

**Artifact đề xuất:** `docs/technical/SOURCE_OF_TRUTH_REGISTRY.md` — file duy nhất declare ai own truth gì, trước khi build bất kỳ shared state artifact nào.

**Tại sao đây là prerequisite:**
- SDD hiện có nhiều artifact overlap scope: specs, ADRs, API docs, handoffs, task files, ledger, memory
- Không có file duy nhất nói: *artifact X → owner Y → authority level Z → conflict winner W*
- Hệ quả: mỗi lần có conflict, phải negotiate lại từ đầu → friction cao giống Rule 16

**Schema tối giản (mỗi entry):**

```yaml
artifact:            # tên file hoặc pattern
purpose:             # 1 dòng mục đích
owner:               # agent ID hoặc human role
authority_level:     # feature-behavior | interface-lock | impl-reference | architecture-constraint
updated_by:          # ai được phép update
updated_when:        # trigger update
conflict_resolution: # winner + escalation path
verification:        # cách kiểm tra entry còn chính xác
```

**Coverage tối thiểu (Sprint 0):** 8 artifact types: `design/specs/`, ADR, `docs/technical/API.md`, `.tasks/handoffs/`, `.tasks/NNN-*.md`, `decision_ledger.jsonl`, `.claude/memory/`, `design/contracts/` (proposed).

**Nguyên tắc registry không được trở thành bureaucracy** — xem red flags ở §6.5.

#### 5.2 API Contract Store + Source-of-Truth Matrix

**Artifact đề xuất:** `design/contracts/` để lock interface trước khi implement.

```
design/contracts/
  user-api-v1.contract.md    ← status: stable
  payment-api-v2.contract.md ← status: draft
```

##### Matrix authority 4-artifact (từ rebuttal §2 Finding 1)

Contract Store chỉ có giá trị nếu authority được bounded rõ ràng. Nếu không, nó compete với `docs/technical/API.md`, `design/specs/`, `/api-design`, và backend ownership. Matrix đầy đủ:

| Artifact | Mục đích | Owner | Authority | Winner khi conflict |
|---|---|---|---|---|
| `design/specs/*` | Feature intent, behavior, acceptance | `lead-programmer` / `product-manager` | Approved feature behavior | Approved spec (unless evolved) |
| `design/contracts/*` | Pre-implementation interface lock | `lead-programmer` / `backend-developer` | Draft/stable interface giữa agents/layers | ADR hoặc approved spec |
| `docs/technical/API.md` *(cần tạo)* | Implemented API reference | `backend-developer` | Current implemented API contract | Runtime implementation sau review |
| ADR | Durable architecture decision | `technical-director` | Architecture-level constraint | ADR supersedes lower-level docs |

**Decision rule ngắn gọn:**

```
Spec explains WHY.
Contract locks WHAT to build.
API.md documents what EXISTS.
ADR decides what must REMAIN TRUE.
```

##### Contract Lifecycle (từ rebuttal §3.4)

```
proposed → reviewed → stable → implemented → deprecated
```

- `proposed`: có thể discuss, chưa được implement against
- `reviewed`: đã check bởi owning lead, vẫn có thể thay đổi
- `stable`: có thể bắt đầu implement
- `implemented`: reflected trong `docs/technical/API.md`
- `deprecated`: superseded hoặc không dùng nữa

> ⚠️ **Pre-requisite:** `docs/technical/API.md` **hiện chưa tồn tại** (verified 2026-04-23). Phải tạo skeleton file này **trước** Sprint contract pilot — nếu không, trạng thái `implemented` không có chỗ phản chiếu.

#### 5.3 Decision Log Read-Gate Adoption

**Factual correction (từ rebuttal §2 Finding 2):** Cả write path và query path đều đã tồn tại:
- `decision_ledger.jsonl` có 23+ entries (verified 2026-04-23)
- `/trace-history` skill đã được implement tại `.claude/skills/trace-history/SKILL.md`
- Script backing tại `scripts/trace-history.sh`

**Gap thực sự:** Không phải thiếu tool — mà thiếu **mandatory read gates** trước khi tạo decision mới. Agents ghi ledger nhưng không query để check prior decisions.

##### Read gates đề xuất — **tiered by risk** (tránh lặp lại Rule 16)

Áp dụng theo Risk Tier trong CLAUDE.md (Low/Medium/High) để tránh blanket mandate gây friction:

| Enforcement | Trigger | Required query | Rationale |
|---|---|---|---|
| **MUST** | Viết ADR mới | `/trace-history --risk High --last 20` | Architecture decision phải check prior context |
| **MUST** | Đổi coordination rule | Query prior `outcome: blocked` / `fail` entries | Policy change rủi ro cao, dễ conflict history |
| **MUST** | Retry failed orchestration (High-risk task) | `/trace-history --outcome blocked` và `--outcome fail` | Tránh lặp lại lỗi vừa block |
| **MUST** | Delete/weaken existing protocol | Query adoption/failure history của protocol | Rule 16 lesson: biết why before remove |
| **SHOULD** | API design thường (trong existing domain) | Quick scan ledger cho API decisions gần | Tránh API convention drift, không blocking |
| **SHOULD** | Feature spec trong existing domain | Scan related prior specs/decisions | Phát hiện overlap, không blocking |
| **SKIP** | Low-risk decisions (bug fix, cosmetic, doc typo) | — | Query overhead > value |
| **SKIP** | Trivial style choices, one-line fixes | — | Aligns với Rule 15 "what NOT to log" |

**Nguyên tắc:** Gate càng mandatory càng phải *narrow* về scope. Mở rộng MUST ra nhiều trigger = Rule 16 redux.

##### Metric thành công

- **Read-before-decision rate:** agents reference prior decisions ít nhất 1 lần/sprint
- **Repeat decision rate:** < 10% quyết định mới mâu thuẫn với quyết định đã có trong ledger

#### 5.4 Handoff Schema tối giản
Không phải full contract protocol (quá friction). Chỉ cần 3 trường bắt buộc:

```markdown
## Handoff: backend-developer → frontend-developer
- **What was built**: POST /api/users endpoint, returns {id, email, created_at}
- **What's missing**: Rate limiting chưa implement
- **Acceptance criteria**: Frontend nhận được 201 khi form submit hợp lệ
```

#### 5.5 Authority Boundary — Shared State ≠ Autonomous Authority

**(Từ rebuttal §2 Finding 3 — insight mới so với revision 1)**

Shared state phải giảm gánh nặng "text relay" của producer **nhưng không được làm yếu mô hình operating human-governed**:

| Shared state **LÀM** | Shared state **KHÔNG LÀM** |
|---|---|
| Cải thiện observability cho agents | Cấp autonomous authority cho agents |
| Giảm dependency vào producer làm trung gian text | Cho phép agents self-negotiate binding decisions ngoài SDD hierarchy |
| Để agent đọc cùng một truth | Bypass Rule 3 (conflict escalation) hay Rule 11 (permission mode) |
| Reduce friction trong handoff | Thay thế human approval cho multi-file changes |

**Nguyên tắc cốt lõi:**

```
Decision authority, conflict resolution, và scope approval
VẪN thuộc về: human, producer, technical-director, Rule 3 escalation.

Shared state chỉ là READ LAYER, không phải DECIDE LAYER.
```

Điều này critical để Tầng 2 không biến thành Tầng 3 ngầm (automation creep).

---

## 6. Khi nào mới cần Coordination Engineering thực sự?

Coordination Engineering (Tầng 3) chỉ có giá trị khi các điều kiện sau đạt **threshold đo được**:

| Điều kiện | Threshold trigger | Nguồn đo |
|---|---|---|
| Concurrent writes cùng domain | ≥ 3 lần/sprint bị conflict phải manual merge | git log + `active.md` conflict markers |
| Quyết định xung đột cần negotiate | ≥ 2 lần/sprint producer phải escalate Rule 3 | `decision_ledger.jsonl` với `outcome: blocked` |
| Workflow quá phức tạp | Orchestrator spawn > 5 agents/task thường xuyên | `agent-metrics.jsonl` |

**Ở quy mô SDD hiện tại** (tính đến 2026-04-23): chưa có điều kiện nào chạm threshold. Review lại mỗi cuối quarter.

### 6.5 Anti-pattern Watch: phòng ngừa lặp lại thất bại Rule 16

Rule 16 (A2A Handoff Contracts) đã bị downgrade vì friction quá cao. Mọi artifact mới của Tầng 2 có rủi ro lặp lại cùng failure mode. Các red flag cần monitor:

| Red flag | Artifact áp dụng | Ngưỡng rollback | Hành động |
|---|---|---|---|
| Contract file bị skip/bypass | `design/contracts/` | > 30% handoffs không reference contract | Giảm required fields xuống minimum viable |
| Decision log churn | `decision_ledger.jsonl` | Agents ghi rồi không ai đọc sau 2 sprint | Xóa infrastructure, không giữ vestigial |
| Handoff schema bị expand | §5.4 schema | > 5 fields bắt buộc | Reject PR, giữ schema ở 3 fields |
| Adoption rate | Any new artifact | < 50% sau 3 sprints | Treat như Rule 16: downgrade MUST→SHOULD hoặc remove |
| Registry stale | `SOURCE_OF_TRUTH_REGISTRY.md` | > 30 ngày không có `updated_when` refresh khi artifact mới thêm | Trigger audit; xoá entries không còn authority |
| Registry bureaucracy | `SOURCE_OF_TRUTH_REGISTRY.md` | Phải update >3 files khi thêm 1 artifact | Simplify schema, cắt mandatory fields |

**Nguyên tắc:** Nếu artifact Tầng 2 trở thành overhead mà không tạo value đo được, phải rollback ngay — không giữ lại vì sunk cost. **Registry cũng phải chịu cùng tiêu chuẩn** — không phải ngoại lệ chỉ vì nó là "meta-infrastructure".

---

## 7. Lộ trình đề xuất

Mỗi sprint có **verify criterion** cụ thể theo Rule 12 — không bắt đầu sprint kế tiếp cho đến khi criterion của sprint trước được xác nhận pass.

### Q2 2026 — Shared State Adoption & Source-of-Truth Consolidation

**Nguyên tắc ordering** *(từ rebuttal §5)*: Authority clarity trước, adoption infra sau, automation cuối cùng.

**Sprint 0: Source-of-Truth Registry** *(ưu tiên cao nhất — authority baseline)*
- Deliverable: `docs/technical/SOURCE_OF_TRUTH_REGISTRY.md`
- Nội dung: mỗi artifact (specs, ADRs, API docs, handoffs, task files, ledger, memory, proposed contract store) có entries với fields — `artifact`, `purpose`, `owner`, `authority_level`, `updated_by`, `updated_when`, `conflict_resolution`, `verification`
- → **verify:** registry cover ≥ 8 artifact types hiện có; mỗi entry có owner + conflict winner; review bởi technical-director pass

**Sprint 0.5: `docs/technical/API.md` skeleton** *(fix gap từ rebuttal)*
- Deliverable: tạo file skeleton cho API reference (chưa populate content, chỉ structure)
- Rationale: nhiều decision ở Sprint 2 reference file này; phải tồn tại trước
- → **verify:** file tồn tại với structure rõ ràng (endpoints table, schema conventions, deprecation policy); registry entry được thêm

**Sprint 1: Decision Log Read-Gate Adoption** *(re-use infra đã có)*
- Deliverable:
  - **MUST-tier updates**: ADR workflow, coordination-rule change process, high-risk retry workflow, protocol-removal workflow phải require `/trace-history` query
  - **SHOULD-tier updates**: `spec-evolution`, `api-design` skills khuyến khích (không block) query trước decision
  - **SKIP**: không thêm gate cho low-risk workflows — tránh broad mandate
- Rationale: tool đã có (`.claude/skills/trace-history/` + `scripts/trace-history.sh`); gap là compliance, không phải build. Tiered theo Risk Tier (§5.3) để tránh Rule 16 friction.
- → **verify:** ≥ 1 ADR thực tế cite prior ledger entry; ≥ 1 high-risk retry cite prior blocked entries; SHOULD-tier workflows có ít nhất 30% adoption trong 1 sprint; KHÔNG có blanket mandate broad hơn §5.3 table

**Sprint 2: Contract Store Pilot**
- Deliverable: contract template + `design/contracts/` dir + **1 pilot contract duy nhất** (không broad rollout)
- Dependency: Sprint 0.5 đã xong (API.md tồn tại để reflect implemented status)
- → **verify:** contract link từ feature spec; `backend-developer` + `frontend-developer` cùng reference trong PR; endpoint implemented được reflect vào `docs/technical/API.md`

**Sprint 3: Handoff Schema tối giản + tích hợp `/orchestrate`**
- Deliverable: 3-field schema (§5.4) được orchestrator tự động chèn vào mỗi cross-domain handoff
- → **verify:** 3 cross-domain handoffs liên tiếp có schema đầy đủ mà không cần user intervention; adoption rate ≥ 70% sau sprint

### Sprint 4 (conditional): Coordination Audit Script

**Chỉ chạy nếu Sprint 1-3 data justify — không phải default.**

> **Nguyên tắc phân biệt audit vs rollback:** Audit = *catch drift* khi artifact đã được dùng rộng rãi. Rollback (§6.5) = *remove/simplify* khi artifact không được dùng. Hai công cụ, hai vấn đề — KHÔNG dùng audit để bù đắp adoption thấp.

**Trigger conditions (phải đạt CẢ HAI):**
1. Adoption **≥ 70%** across artifacts trong 2 sprints liên tiếp *(có được dùng thực sự)*
2. Có ≥ 2 drift/error incidents **dù đã dùng artifact** — ví dụ: stable contract không link spec dù contract được reference; implemented contract không reflect API.md dù cả hai đang active

**Anti-trigger (KHÔNG build audit):**
- Adoption < 50% ở bất kỳ artifact nào → xử lý theo §6.5 (rollback/simplify/remove)
- Red flag kiểu "decision log churn" hay "schema bị expand" → xử lý theo §6.5 (không phải audit vấn đề)
- Registry bị stale → fix Registry trực tiếp, không tự động

**Deliverable (nếu trigger match):** `scripts/coordination-audit.js` với initial checks — stable contract không link spec, implemented contract không reflect API.md, medium/high handoff thiếu ledger entry, v.v.

→ **verify:** detect ≥ 1 malformed fixture trong test; không modify Claude runtime files; chạy weekly, không blocking CI (tránh thêm friction).

### Gate check trước khi qua Q3 (Tầng 3)

Tại cuối Q2, review các threshold §6 + red flag §6.5. Chỉ proceed lên Coordination Engineering (Tầng 3) nếu:
1. Ít nhất 1 trigger §6 chạm threshold
2. Không có red flag §6.5 nào active (bao gồm Registry red flags)
3. Shared State adoption ≥ 50% across artifacts
4. Registry được reviewed ít nhất 1 lần bởi technical-director

Nếu không đạt, **giữ nguyên Tầng 2** và iterate thay vì build Tầng 3.

---

## 8. Kết luận

| Câu hỏi | Trả lời |
|---|---|
| Coordination Engineering có hợp lý không? | Có, nhưng dạng **tầng trung gian Shared State Adoption**, không phải Coordination trực tiếp |
| Có phải bước *tiếp theo* không? | Không — cần Shared State Adoption + Source-of-Truth Consolidation trước |
| Bước tiếp theo thực sự là gì? | **Authority clarity trước** (Registry) → adoption cho infra đã có (read gates) → artifact mới (contract pilot) |
| Artifact ưu tiên cao nhất? | `docs/technical/SOURCE_OF_TRUTH_REGISTRY.md` (Sprint 0) — không phải `design/contracts/` |
| `/trace-history` đã có chưa? | **Có** — `.claude/skills/trace-history/` + `scripts/trace-history.sh`; gap là read-gate adoption |
| `docs/technical/API.md` đã có chưa? | **Chưa** — phải tạo skeleton ở Sprint 0.5 trước contract pilot |
| Shared state có bypass producer không? | **Không** — chỉ là READ LAYER, authority vẫn thuộc human + Rule 3 escalation (§5.5) |
| Điều kiện rollback? | Xem §6.5 — áp dụng cho cả Registry (stale > 30 ngày hoặc bureaucracy > 3 files/entry) |

> **Một câu tóm tắt:** Harness xây nền cho agents *sống*; bước tiếp theo là **clarify ai own truth gì** trước khi adopt shared state — đó là Source-of-Truth Consolidation, không phải Coordination.

---

*Report này được tạo từ phân tích kiến trúc SDD ngày 2026-04-23.*
