# SDD vs Claude Managed Agents — Báo Cáo So Sánh Chiến Lược

> **Phiên bản:** SDD v1.22.0
> **Ngày phân tích:** 2026-04-09
> **Tác giả:** CTO Analysis
> **Nguồn tham chiếu:** https://claude.com/blog/claude-managed-agents

---

## 1. TỔNG QUAN

### 1.1 Mô tả hai hệ thống

| Hệ thống | Loại | Nơi chạy | Mô hình phí |
|----------|------|-----------|-------------|
| **SDD** (Software Development Department) | Agentic Harness (self-managed) | Local / Claude Code | Miễn phí (Open Source) |
| **Claude Managed Agents** | Managed Infrastructure (cloud) | Anthropic Cloud | $0.08/session-hour + token rates |

### 1.2 Định nghĩa ngắn gọn

- **SDD**: Framework template định nghĩa 27 specialized agents, 108 skills/workflows, 8 hooks, 12 path-scoped rules và 5-layer memory system chạy trên Claude Code CLI. Người dùng quản lý toàn bộ infrastructure.

- **Claude Managed Agents**: Bộ composable APIs do Anthropic vận hành, cung cấp production-grade agent runtime với sandboxing, long-running sessions, multi-agent coordination, credential management và execution tracing tích hợp sẵn.

---

## 2. PHÂN TÍCH KIẾN TRÚC

### 2.1 Stack tổng thể

```
┌────────────────────────────────────────────────────────────────┐
│                     AGENTIC AI FULL STACK                      │
├────────────────────────────┬───────────────────────────────────┤
│      TẦNG                  │           MÔ TẢ                   │
├────────────────────────────┼───────────────────────────────────┤
│ [CLOUD] Infrastructure     │ Sandboxing, session persistence,  │
│ → Claude Managed Agents    │ identity management, execution     │
│                            │ tracing, credential management     │
├────────────────────────────┼───────────────────────────────────┤
│ [HARNESS] Orchestration    │ Agent definitions, workflow rules, │
│ → SDD lives HERE           │ memory tiering, governance hooks,  │
│                            │ delegation protocols, domain       │
│                            │ boundaries, specialist knowledge   │
├────────────────────────────┼───────────────────────────────────┤
│ [MODEL] Intelligence       │ Claude Opus / Sonnet / Haiku       │
│ → Anthropic Models         │ (Tier-based: Claude Code agents)   │
└────────────────────────────┴───────────────────────────────────┘
```

**Kết luận tầng:** SDD và Managed Agents **hoạt động ở hai tầng khác nhau**. SDD là Harness Layer. Managed Agents là Infrastructure Layer. Chúng bổ sung cho nhau, không thay thế nhau.

---

## 3. SO SÁNH TÍNH NĂNG CHI TIẾT

### 3.1 Multi-Agent Coordination

| Tiêu chí | SDD | Claude Managed Agents |
|----------|-----|----------------------|
| Mô hình | 3-tier hierarchy (CTO → Leads → Specialists) | Orchestrator spawns sub-agents dynamically |
| Số lượng agents | 27 predefined agents | Không giới hạn, spawn on-demand |
| Delegation | Structured (vertical + horizontal) | Dynamic, task-based |
| Parallelism | Sequential (fork-join.sh via git worktrees) | True parallel execution |
| Conflict resolution | Escalation rules (escalate to CTO) | Không có built-in, do dev định nghĩa |

**Nhận xét:** SDD có mô hình delegation rõ ràng và có thể predict; Managed Agents có khả năng scale thực sự. SDD phù hợp hơn cho môi trường cần audit trail.

---

### 3.2 Context & Memory Management

| Tiêu chí | SDD | Claude Managed Agents |
|----------|-----|----------------------|
| Persistence | File-based (local .claude/memory/) | Cloud-based, native session state |
| Tier 1 (hot) | MEMORY.md (<50 lines, always loaded) | Session context window |
| Tier 2 (warm) | Load-on-demand (max 3 files/session) | Tool calls, memory retrieval APIs |
| Tier 3 (cold) | grep search .claude/memory/archive/ | External storage via integrations |
| Auto-consolidation | auto-dream.sh hook | Không có built-in (dev tự implement) |
| Offline access | ✅ Yes | ❌ No |
| Cross-machine sync | ❌ Manual (git push) | ✅ Automatic |

**Nhận xét:** SDD có memory architecture rõ ràng và tinh tế hơn (5-layer). Managed Agents cung cấp persistence tự động nhưng không có opinionated memory tiering — dev phải tự thiết kế.

---

### 3.3 Governance & Safety

| Tiêu chí | SDD | Claude Managed Agents |
|----------|-----|----------------------|
| Triết học kiểm soát | Human-in-the-loop (mỗi bước cần approve) | Trust-by-default, autonomous |
| Scoped permissions | 12 path-scoped rules (file path-based) | Platform-level scoped permissions |
| Audit trail | session-stop.sh logs + validate-commit.sh | Built-in execution tracing |
| Security | bash-guard.sh, Risk Tier assessment | Sandboxed execution environment |
| Credential management | .env file (manual) | Managed, encrypted, platform-handled |
| Pre-action validation | validate-push.sh, pre-refactor-impact.sh | Không có built-in |

**Nhận xét:** SDD an toàn hơn cho môi trường regulated (fintech, healthcare) do human approval từng bước. Managed Agents nhanh hơn nhưng đòi hỏi tin tưởng autonomous execution.

---

### 3.4 Agent Specialization

| Tiêu chí | SDD | Claude Managed Agents |
|----------|-----|----------------------|
| Số lượng specialists | 27 được định nghĩa sẵn | Không có — dev tự define |
| Domain expertise | Embedded trong agent .md files | Thông qua system prompt + tools |
| Skill frameworks | 108 skills (Next.js, FastAPI, K8s...) | Không có built-in framework knowledge |
| Model tiering | Opus (Tier 1), Sonnet (Tier 2-3) | Dev tự chọn model per agent |
| Onboarding | `/start` command guided setup | Docs + quickstart guide |

**Nhận xét:** SDD mang lại **immediate specialist context** — một developer mới clone repo là có ngay 27 chuyên gia với domain knowledge embedded. Managed Agents là blank slate — mạnh hơn nhưng cần setup nhiều hơn.

---

### 3.5 Observability & Debugging

| Tiêu chí | SDD | Claude Managed Agents |
|----------|-----|----------------------|
| Session logging | log-agent.sh (bash-based) | Built-in console tracing |
| Tool call tracking | ❌ Không có | ✅ Every tool call logged |
| Failure debugging | Manual (grep logs) | Troubleshooting UI trong Claude Console |
| Performance metrics | ❌ Không có | ✅ Integration analytics |
| Cost tracking | ❌ Không có | ✅ Per-session consumption tracking |

**Nhận xét:** Managed Agents có observability stack vượt trội. SDD thiếu visibility vào tool call behavior — đây là gap lớn nhất cho production use.

---

### 3.6 Long-Running Tasks

| Tiêu chí | SDD | Claude Managed Agents |
|----------|-----|----------------------|
| Session duration | Giới hạn bởi context window | Hours — persist qua disconnection |
| Background execution | ❌ Không có | ✅ Native |
| Progress persistence | Pre-compact hook (partial) | ✅ Full session state |
| Reconnect/resume | ❌ Context lost | ✅ Seamless |
| Parallel task queues | ❌ Không có | ✅ Available |

---

## 4. ĐIỂM MẠNH / ĐIỂM YẾU

### 4.1 SDD — Điểm mạnh

1. **Free & Open Source** — Không có chi phí runtime
2. **Maximum control** — Human approve từng thao tác
3. **Embedded specialist knowledge** — 27 agents + 108 skill frameworks sẵn sàng
4. **Opinionated memory architecture** — 5-layer tiering rõ ràng
5. **Local-first & offline capable** — Không phụ thuộc network
6. **Customizable & forkable** — Template, không phải locked framework
7. **Community shareable** — Clone và dùng ngay
8. **Audit-friendly** — Mỗi bước đều có human sign-off

### 4.2 SDD — Điểm yếu

1. **Không có true parallelism** — fork-join.sh là sequential
2. **No sandbox isolation** — Chạy thẳng trên local filesystem
3. **Session state mất khi close** — Phải manually save
4. **Manual credential management** — .env file approach
5. **No observability stack** — Không có tool call tracing
6. **Solo developer only** — Không hỗ trợ multi-user
7. **Self-evaluation loop thiếu** — QA agents review nhưng không autonomous iterate

### 4.3 Claude Managed Agents — Điểm mạnh

1. **True parallel execution** — Nhiều agents chạy thực sự đồng thời
2. **Production-grade sandboxing** — Bảo mật, isolation native
3. **Hours-long autonomous sessions** — Không cần babysitting
4. **Built-in observability** — Console tracing, analytics, debug
5. **Managed credentials** — Secure, encrypted, platform-handled
6. **Cloud persistence** — State survive disconnection, multi-device
7. **Self-evaluation loop** — Claude iterate until success criteria met
8. **Enterprise-ready** — Identity management, RBAC, compliance

### 4.4 Claude Managed Agents — Điểm yếu

1. **Chi phí runtime** — $0.08/session-hour + tokens
2. **Blank slate** — Không có specialist knowledge built-in
3. **No opinionated harness** — Dev phải tự design agent coordination
4. **Cloud lock-in** — Phụ thuộc Anthropic infrastructure
5. **No offline operation** — Cần internet
6. **Learning curve** — APIs mới, setup complex
7. **Early stage** — Multi-agent coordination còn trong research preview

---

## 5. KHÁC BIỆT TRIẾT HỌC CỐT LÕI

### SDD — "Collaborative, Not Autonomous"
```
NGƯỜI DÙNG → Giao task
     ↓
AGENT → Đặt câu hỏi làm rõ
     ↓
AGENT → Đề xuất 2-4 options với pros/cons
     ↓
NGƯỜI DÙNG → Ra quyết định
     ↓
AGENT → Soạn thảo, show trước
     ↓
NGƯỜI DÙNG → Approve
     ↓
AGENT → Thực thi
```

### Claude Managed Agents — "Define Outcomes, Let Agent Iterate"
```
NGƯỜI DÙNG → Định nghĩa outcomes + success criteria
     ↓
AGENT → Tự plan, tự execute, tự evaluate
     ↓
AGENT → Iterate nếu chưa đạt criteria
     ↓
NGƯỜI DÙNG → Review output cuối
```

**Nhận xét:** Không có mô hình nào sai. Đây là trade-off có ý thức:
- SDD: `Safety > Speed` — phù hợp regulated environments, solo devs học AI
- Managed Agents: `Speed > Safety` — phù hợp product teams cần ship nhanh

---

## 6. KỊCH BẢN ÁP DỤNG

### Kịch bản 1: Solo Developer / Open Source Project
**→ Khuyến nghị: SDD**
- Free, full control, embedded knowledge
- Không cần parallel execution
- Audit trail từng bước là lợi thế

### Kịch bản 2: Startup — Cần ship trong tuần
**→ Khuyến nghị: Claude Managed Agents + SDD Agent Definitions**
- Giữ: Agent .md files, skills workflows, governance philosophy
- Bỏ: bash hooks, file-based memory (platform replaces)
- Gain: Autonomous execution, true parallel, built-in observability

### Kịch bản 3: Enterprise — Regulated Industry
**→ Khuyến nghị: SDD (Human-in-loop) + Managed Agents (background tasks)**
- SDD cho tasks cần approval (code review, deploy)
- Managed Agents cho background tasks (monitoring, reporting)

### Kịch bản 4: Platform / SaaS — Building Agent Products
**→ Khuyến nghị: Claude Managed Agents as infrastructure, SDD as template**
- Managed Agents handles: multi-tenant isolation, billing, scaling
- SDD provides: agent specialization patterns, workflow templates
- Giống Notion, Asana, Sentry đang làm

---

## 7. MIGRATION ROADMAP: SDD → MANAGED AGENTS

Nếu quyết định migrate:

### Phase 1: Prepare (1-2 tuần)
- [ ] Export tất cả agent definitions sang format độc lập
- [ ] Document tất cả workflow patterns (skills)
- [ ] Map 12 path-scoped rules sang Managed Agents permission model
- [ ] Port memory structure sang persistent storage (Supabase/Redis)

### Phase 2: Hybrid (2-4 tuần)
- [ ] Setup Managed Agents project trong Claude Console
- [ ] Migrate 3-5 agents critical nhất trước (cto, lead-programmer, qa-lead)
- [ ] Replace bash hooks bằng Managed Agents event hooks
- [ ] Build observability dashboard thay thế log-agent.sh

### Phase 3: Full Migration (4-8 tuần)
- [ ] Migrate toàn bộ 27 agents
- [ ] Implement self-evaluation loops cho QA cycle
- [ ] Enable true parallel execution (team-*  skills)
- [ ] Integration: MCP servers cho Jira, Slack, GitHub

### Những gì KHÔNG cần thay đổi
- Agent domain boundaries và responsibilities
- Conflict resolution paths (cto for strategic, technical-director for technical)
- Coding standards và quality gates
- Templates (PRD, ADR, API Design...)
- Governance philosophy (ask → present options → decide → draft → approve)

---

## 8. ĐÁNH GIÁ MATURITY

| Dimension | SDD | Managed Agents |
|-----------|-----|----------------|
| Production readiness | ⭐⭐⭐ (Self-managed) | ⭐⭐⭐⭐⭐ (Platform-managed) |
| Developer experience | ⭐⭐⭐⭐ (Great DX, /start cmd) | ⭐⭐⭐ (New APIs, early stage) |
| Specialist knowledge | ⭐⭐⭐⭐⭐ (108 frameworks embedded) | ⭐⭐ (Blank slate) |
| Scalability | ⭐⭐ (Solo dev limit) | ⭐⭐⭐⭐⭐ (Enterprise scale) |
| Cost efficiency | ⭐⭐⭐⭐⭐ (Free) | ⭐⭐⭐ (Pay per use) |
| Safety & compliance | ⭐⭐⭐⭐⭐ (Human-in-loop) | ⭐⭐⭐ (Autonomous by default) |
| Customizability | ⭐⭐⭐⭐⭐ (Full open source) | ⭐⭐⭐⭐ (API-extensible) |
| Observability | ⭐⭐ (Basic logs) | ⭐⭐⭐⭐⭐ (Built-in console) |

---

## 9. KẾT LUẬN

SDD v1.22.0 là implementation thủ công, opinionated của một **Agentic Harness** — đã giải quyết đúng bài toán cần giải. Claude Managed Agents là industrialization của bài toán đó ở tầng infrastructure.

**Ba insight quan trọng nhất:**

1. **SDD không lỗi thời** — Layer Harness (agent definitions, specialization, governance) vẫn cần thiết dù chạy trên local hay Managed Agents cloud.

2. **Khoảng cách nằm ở tầng Infrastructure** — Sandboxing, true parallelism, cloud persistence, observability. Đây là những gì Managed Agents bán với $0.08/session-hour.

3. **SDD là template hoàn hảo để migrate** — 27 agent definitions, 108 skills, governance rules — toàn bộ transferable. Chi phí migration thấp, lợi ích cao.

> **Metaphor:** SDD là bản thiết kế kiến trúc (blueprint) của một tòa cao ốc. Claude Managed Agents là tòa nhà đã được xây xong với điện nước, thang máy, bảo vệ. Bạn vẫn cần blueprint — dù xây ở đâu.

---

*Báo cáo này dựa trên phân tích SDD v1.22.0 và bài báo Claude Managed Agents (2026-04-09).*
*Xem thêm: [SDD README](README.md) | [Claude Managed Agents Blog](https://claude.com/blog/claude-managed-agents)*
