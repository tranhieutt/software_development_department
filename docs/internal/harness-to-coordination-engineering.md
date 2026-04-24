# Harness Engineering -> Coordination Engineering
**Trang thai hien tai cua Tier 2 va backlog con lai**

> Ngay goc: 2026-04-23
> Cap nhat rut gon: 2026-04-24
> Loai: Architecture analysis + execution tracker
> Related: `docs/internal/adr/ADR-006-shared-state-adoption.md`

---

## 1. Ket luan ngan

SDD da hoan thanh **Tier 1: Harness Engineering**.

Huong di dung khong phai la nhay thang len full **Coordination Engineering**,
ma la di qua **Tier 2: Shared State Adoption & Source-of-Truth
Consolidation**.

Phan "build scaffold" cua Tier 2 da xong phan lon. Phan con lai la
**adoption verification** va **rollout decision**, khong con la tao artifact moi
co ban.

---

## 2. Nhung gi da xong

Nhung muc duoi day da hoan thanh va da duoc loai khoi backlog hien hanh:

- `Sprint 0`: `docs/technical/SOURCE_OF_TRUTH_REGISTRY.md`
- `Sprint 0.5`: `docs/technical/API.md` skeleton
- `Sprint 1`: decision-log read-gate wiring
  - ADR workflow
  - coordination-rule change workflow
  - high-risk retry workflow
  - protocol-removal workflow
  - SHOULD-tier guidance trong `api-design` va `spec-evolution`
- `Sprint 2` scaffold:
  - `design/contracts/`
  - `design/contracts/contract-template.md`
  - 1 pilot contract ban dau
- `Sprint 3` wiring:
  - 3-field handoff summary
  - `/orchestrate` prompt integration
  - Rule 16 / handoff schema / registry sync
- `Sprint 4` scaffold:
  - `scripts/coordination-audit.js`
  - malformed fixture test
  - che do manual, report-only

---

## 3. Backlog con lai

### 3.1 Sprint 2 follow-up: Contract Store Pilot verification

Scaffold contract store da co, nhung chua co verify end-to-end cho mot feature
spec that.

**Con thieu:**
- Gan pilot contract vao `design/specs/*` that
- Co consumer that tu `backend-developer` va `frontend-developer`
- Neu contract move sang `implemented`, phai reflect vao
  `docs/technical/API.md`

**Verify de close:**
- contract link tu feature spec
- `backend-developer` + `frontend-developer` cung reference contract trong PR
  hoac workflow artifact that
- implemented endpoint duoc reflect vao `docs/technical/API.md`

### 3.2 Sprint 3 follow-up: Handoff Schema adoption

Workflow wiring da co, nhung adoption van chua duoc chung minh.

**Con thieu:**
- bang chung van hanh that cho 3-field handoff summary

**Verify de close:**
- 3 cross-domain handoffs lien tiep co du:
  - `What was built`
  - `What's missing`
  - `Acceptance criteria`
- khong can user intervention de chen schema
- adoption rate >= 70% sau sprint

### 3.3 Sprint 4 follow-up: Coordination Audit rollout decision

`scripts/coordination-audit.js` da ton tai, nhung chi o che do manual.

**Chua duoc claim la rollout hoan chinh** cho den khi du trigger adoption/drift.

**Trigger conditions de nang len rollout:**
1. Adoption >= 70% across artifacts trong 2 sprints lien tiep
2. Co >= 2 drift incidents du artifact da duoc dung that

**Anti-trigger:**
- Adoption < 50% o bat ky artifact nao
- Decision log churn
- Handoff schema bi mo rong qua muc toi thieu
- Registry stale

Neu gap anti-trigger, uu tien rollback/simplify theo ADR-006, khong dung audit
de bu cho adoption thap.

**Verify khi rollout:**
- detect >= 1 malformed fixture trong test
- khong modify Claude runtime files
- weekly/manual usage, non-blocking CI

---

## 4. Authority boundary

Shared state la **READ LAYER**, khong phai **DECIDE LAYER**.

No duoc dung de:
- giam text relay friction
- de agents doc cung mot truth
- tang observability

No khong duoc dung de:
- bypass human approval
- bypass Rule 3 escalation
- cho agents tu negotiate binding decisions

---

## 5. Khi nao moi can Tier 3

Chi can tien len full Coordination Engineering khi co it nhat mot trigger duoi
day dat threshold:

- concurrent-write conflicts >= 3 / sprint
- producer phai escalate Rule 3 >= 2 / sprint
- orchestrator thuong xuyen spawn > 5 agents / task

Neu chua dat, tiep tuc iterate trong Tier 2.

---

## 6. Tom tat mot dong

Harness da xong phan nen. Viec con lai khong phai build them he thong moi, ma la
chung minh rang contract store, handoff summary, va coordination audit dang duoc
dung dung cach trong van hanh that.
