# AUDIT KIEN TRUC HARNESS ENGINEERING SDD - Bao cao v6

> **Reviewer:** GPT-5.4 - OpenAI-style Harness Engineering Architect  
> **Ngay:** 2026-04-21  
> **Du an:** SDD-Upgrade  
> **Phuong phap:** Evidence-based review tren repo hien tai, uu tien runtime guarantees hon artifact presence.

---

## 0. Executive Summary

Kien truc SDD da vuot xa mot prompt library thong thuong. Repo co day du cac thanh phan cua mot agentic harness nghiem tuc: agents, skills, rules, hooks, memory tiering, decision ledger, circuit breaker, audit script va governance documents.

Tuy nhien, diem yeu chinh hien tai la khoang cach giua **architecture claims** va **runtime guarantees**. Nhieu artifact da ton tai, nhung chua du contract test va telemetry de chung minh chung dang hoat dong dung trong cac tinh huong thuc te.

**Danh gia tong quan:**

| Truc | Diem | Nhan xet |
|---|---:|---|
| Structural architecture | 7/10 | Harness co control plane that su, khong chi la docs |
| Runtime reliability | 5.5/10 | Hook/telemetry/circuit can contract tests |
| Governance | 6/10 | Rule 16 da downgrade hop ly, nhung portal hygiene con lech |
| Observability | 5/10 | Ledger co that, skill telemetry chua co data |
| Scalability | 6/10 | 116 skills/31 agents can usage-driven consolidation |

**Ket luan:** Khong can rebuild kien truc. Nen chuyen tu "artifact-complete harness" sang "runtime-proven harness".

---

## 1. Evidence Snapshot

### 1.1 Repo state da kiem tra

| Hang muc | Ket qua |
|---|---:|
| Skills hop le | 116 |
| Agents | 31 |
| Hook files | 25 |
| `scripts/validate-skills.ps1` | 116 pass / 0 fail / 58 warn |
| `scripts/harness-audit.js repo` | 120/120 |
| Branch hien tai | `main` |
| Untracked | `.claude/memory/archive/sessions/`, `docs/internal/portal-data.js` |

### 1.2 Diem can luu y

- IDE dang mo `docs/internal/portal.html`, nhung file nay khong con ton tai trong working tree.
- `docs/internal/portal-data.js` van con untracked.
- `production/traces/skill-usage.jsonl` chua ton tai, mac du da co hook `log-skill.sh`.
- `production/traces/agent-metrics.jsonl` co du lieu, nhung co dau hieu encoding lon xon NUL/UTF-16-ish sau dong schema.
- Circuit state source-of-truth hien la `.claude/memory/circuit-state.json`, khong phai `production/session-state/circuit-state.json`.

---

## 2. What Is Working

### 2.1 Control plane co that

Repo co day du control plane cua mot agentic harness:

- `.claude/agents/` dinh nghia role/domain.
- `.claude/skills/` dinh nghia workflows va capability routing.
- `.claude/rules/` dinh nghia path-scoped standards.
- `.claude/hooks/` gan enforcement vao lifecycle.
- `.claude/memory/` luu state, annotations, decisions.
- `production/traces/decision_ledger.jsonl` cung cap audit trail.

Day la nen tang dung. Kien truc khong can dap di lam lai.

### 2.2 Enforcement da tot hon docs-only

`.claude/settings.json` dang wire cac hook quan trong:

- `validate-commit.sh`
- `validate-push.sh`
- `circuit-guard.sh`
- `extract-decisions.sh`
- `log-skill.sh`
- `decision-ledger-writer.sh`
- `circuit-updater.sh`

Day la buoc tien quan trong: rule khong chi nam trong Markdown.

### 2.3 Rule 16 downgrade la quyet dinh dung

A2A handoff contracts da duoc ha tu `MUST` xuong `SHOULD`. Day la quyet dinh kien truc hop ly vi contract file bat buoc tao friction cao, trong khi lightweight handoff summary co the dat 80% gia tri voi chi phi thap hon.

---

## 3. Critical Findings

### ~~P0-1. Circuit breaker dang global, khong phai per-agent~~

> ✅ **FIXED** — Refactor sang per-agent schema v2. `circuit-state.json` gio co `agents.<name>.{state, fail_count, fallback, ...}`. `circuit-guard.sh` doc `subagent_type` tu Task input va chi block agent dang OPEN, hien thi fallback agent de route sang. `circuit-updater.sh` ghi state vao dung agent key.

~~**Hien trang:**~~

~~Rule 14 mo ta circuit breaker cho agent failures va co fallback pairs. Nhung implementation dung mot file state duy nhat `.claude/memory/circuit-state.json`. Khi state `OPEN`, `circuit-guard.sh` block toan bo Task tool. Day la global kill switch, khong phai per-agent routing.~~

~~**Rui ro:**~~

~~- Mot agent yeu co the lam dung toan bo subagent execution.~~
~~- Fallback pairs trong docs khong duoc enforce thuc su.~~
~~- Observability khong tra loi duoc "agent nao dang bi circuit open".~~

---

### P0-2. Harness audit score 120/120 qua lac quan

**Hien trang:**

`node scripts/harness-audit.js repo --format text` tra ve 120/120. Tuy nhien audit nay chu yeu check artifact presence.

**Nhung loi runtime ma score khong bat duoc:**

- `portal.html` khong ton tai nhung IDE/report van co dau vet.
- `portal-data.js` untracked.
- `skill-usage.jsonl` chua co du lieu.
- Circuit breaker implementation khong khop semantics per-agent.
- JSONL metrics co encoding issue.

**Khuyen nghi:**

Giu `harness-audit.js` lam structural audit, nhung them runtime audit rieng:

```text
node scripts/harness-audit.js repo --format text
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate-skills.ps1
node scripts/hook-contract-test.js
node scripts/trace-integrity-check.js
```

---

### ~~P0-3. Skill telemetry chua duoc chung minh~~

> ✅ **FIXED** — Root cause xac nhan: Claude Code khong fire PostToolUse cho `Skill` tool (internal harness construct). Chuyen `log-skill.sh` sang `UserPromptSubmit` hook — detect `/skill-name` pattern tu user prompt. `production/traces/skill-usage.jsonl` gio duoc tao va co data. Ghi note: chi catch user-typed slash commands, khong catch Claude-autonomous skill calls.

~~**Hien trang:**~~
~~Co hook `log-skill.sh` va settings matcher `Skill`, nhung `production/traces/skill-usage.jsonl` chua ton tai.~~

---

### ~~P0-4. Portal governance/hygiene chua sach~~

> ✅ **FIXED** — commit `170614f` xoa `portal.html`, commit `74fc9ca` remove pipeline. Portal da duoc remove cleanly (Option A). `portal-data.js` con untracked nhung khong con duoc tham chieu.

~~**Hien trang:**~~

~~- `docs/internal/portal.html` khong ton tai.~~
~~- `docs/internal/portal-data.js` con untracked.~~
~~- Ledger co entry `chore: remove SDD Governance Portal entirely`.~~

~~**Rui ro:**~~

~~Repo dang o trang thai nua xoa nua con. Dieu nay lam governance portal tro thanh source of confusion.~~

~~**Khuyen nghi binary:**~~

~~Chon 1:~~

~~- **Option A - Remove cleanly:** xoa/ignore `portal-data.js`, cap nhat report/docs khong con coi portal la active component.~~
~~- **Option B - Restore with governance:** tao lai `portal.html`, them ADR portal, schema validate data contract, va test pipeline.~~

---

### ~~P0-5. Trace files can integrity check~~

> ✅ **FIXED** — commit `eedfc93` (v1.44.0) them `scripts/trace-integrity-check.js` voi day du validation: UTF-8, one-JSON-per-line, schema fields, NUL byte rejection. Hook `debug-posttooluse.sh` va `circuit-guard.sh` update them schema discovery.

~~**Hien trang:**~~

~~`production/traces/agent-metrics.jsonl` co the doc duoc noi dung chinh, nhung encoding sau dong schema co NUL bytes.~~

~~**Rui ro:**~~

~~- Parser JSONL co the fail tren Linux/CI/Node.~~
~~- Portal/report co the render sai.~~
~~- Metrics health mat tin cay.~~

~~**Khuyen nghi:**~~

~~Them `scripts/trace-integrity-check.js`:~~

~~- validate UTF-8~~
~~- one JSON object per line~~
~~- schema required fields~~
~~- reject NUL bytes~~
~~- fail CI neu trace bi corrupted~~

---

## 4. Recommended Upgrades

### Upgrade 1 - Runtime Contract Tests

Tao `tests/hooks/` hoac `scripts/hook-contract-test.js` de test cac hook quan trong bang fixture JSON:

| Hook | Contract can test |
|---|---|
| `bash-guard.sh` | block destructive/RCE patterns, allow safe read commands |
| `validate-commit.sh` | enforce staged rules, fail on known bad commit cases |
| `validate-push.sh` | detect secrets/unsafe push cases |
| `circuit-guard.sh` | CLOSED allow, HALF_OPEN warn, OPEN block/reroute |
| `circuit-updater.sh` | success reset, failure increments, threshold transition |
| `log-skill.sh` | writes valid JSONL entry |
| `extract-decisions.sh` | appends only valid decision markers, dedups |

### Upgrade 2 - Per-Agent Circuit Breaker

Refactor `.claude/memory/circuit-state.json` thanh per-agent model. Day la upgrade co gia tri cao nhat neu SDD muon hanh xu nhu orchestrator production.

### Upgrade 3 - Skill Usage Dashboard

Sau khi `skill-usage.jsonl` co data that, tao report:

- top skills last 7/30 days
- never-used skills
- duplicate skill clusters
- skills with missing metadata
- cull candidates

Chi nen merge/delete skills sau khi co usage data.

### Upgrade 4 - Portal Decision

Portal la optional. Nhung neu ton tai, no phai co:

- ADR ownership
- data schema
- generation/update contract
- validation script
- clear git policy: generated file tracked hay ignored

Neu khong, remove cleanly.

### Upgrade 5 - Windows Hook Launcher

Hien repo co mot so `.ps1`, nhung settings van chu yeu goi bash. Neu target la Windows/VS Code native, tao wrapper:

```text
.claude/hooks/run-hook.sh
.claude/hooks/run-hook.ps1
```

Wrapper chon implementation phu hop theo platform va check dependency ro rang.

---

## 5. Skill Ecosystem Review

116 skills khong phai tu dong la xau. Van de la chua co usage telemetry.

**Khong nen lam ngay:**

- Cat xuong <=90 bang cam tinh.
- Gop skill chi vi ten giong nhau.
- Them skill moi khi chua co invocation data.

**Nen lam:**

1. Bat telemetry.
2. Thu thap 7-14 ngay usage.
3. Chia skills thanh:
   - core used
   - rare but critical
   - duplicate
   - obsolete
   - template/reference-only
4. Moi skill moi can co "replacement/deprecation decision" cho skill cu neu trung mien.

---

## 6. Agent Architecture Review

31 agents la chap nhan duoc neu domain ownership ro. Rui ro hien tai la agents co the thanh thin routers den skills.

**Candidates de xem xet sau telemetry:**

- `qa-lead` + `qa-tester`: co the giu rieng neu lead lam quality strategy va tester lam execution. Neu ca hai chi run checklist, nen merge.
- `investigator` + `verifier` + `solver`: co the merge thanh diagnostic pipeline agent neu khong can concurrency.
- frontend family: can phan biet ro `frontend-developer`, `ui-programmer`, `ui-spec-designer`, `ux-designer`, `senior-frontend`.

**Khuyen nghi:** Khong merge agents truoc khi co task dispatch telemetry.

---

## 7. Roadmap De Xuat

### Week 1 - Make Runtime Trustworthy

1. ~~Clean portal state: remove or restore with ADR/schema.~~ ✅ Done (commit `170614f`)
2. ~~Add `trace-integrity-check.js`.~~ ✅ Done (commit `eedfc93`)
3. Add hook contract tests for 5 critical hooks. ❌ Con lai
4. ~~Verify/fix `log-skill.sh` telemetry path.~~ ✅ Done (chuyển sang UserPromptSubmit, xác nhận PostToolUse không fire cho Skill tool)
5. Update README counts to match repo reality. ❌ Con lai

### Week 2 - Make Orchestration Real

1. ~~Refactor circuit breaker to per-agent state.~~ ✅ Done (circuit-state.json v2, circuit-guard.sh + circuit-updater.sh refactored)
2. ~~Add circuit transition ledger entries.~~ ✅ Done (circuit-updater.sh ghi ledger tại CLOSED→HALF_OPEN, HALF_OPEN→OPEN; circuit-guard.sh ghi tại OPEN→HALF_OPEN TTL reset)
3. ~~Add agent-health report reading per-agent circuit state.~~ ✅ Done (`scripts/agent-health.js` — table + `--open` filter + `--json` flag)
4. ~~Add skill usage report.~~ ✅ Done (`scripts/skill-usage-report.js` — table, never-used list, `--cull-only`, `--days N`, `--json`)
5. ~~Start usage-based skill cull candidates list, not deletion yet.~~ ✅ Done (48 candidates identified, written to `production/traces/skill-cull-candidates.md`)

### Week 3 - Consolidate

1. Merge/delete only proven duplicate skills.
2. Consolidate agents only where dispatch data supports it.
3. Add CI gate for audit + skill validator + trace integrity.
4. Publish v1.43/v1.44 with clear changelog.

---

## 8. Final Recommendation

SDD should not invest the next cycle in adding more agents, skills, or portal surfaces. The next architectural gain comes from proving that the harness behaves correctly under runtime pressure.

Priority order:

1. **Contract tests**
2. **Telemetry**
3. **Per-agent circuit breaker**
4. **Trace integrity**
5. **Repo hygiene**
6. **Usage-based consolidation**

This will move SDD from a strong architecture prototype into a reliable agentic engineering harness.

