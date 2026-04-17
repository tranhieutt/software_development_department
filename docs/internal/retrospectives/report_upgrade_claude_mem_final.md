# Báo cáo Tổng hợp: Nâng cấp SDD-Upgrade từ Claude-mem

**Ngày:** 2026-04-16  
**Nguồn tham khảo:** `E:\claude-mem` — plugin claude-mem v12.x  
**Áp dụng cho:** `E:\SDD-Upgrade`  
**Tổng hợp từ:** `report_upgrade_claude_mem.md` + `report_upgrade_claude_mem_other.md`

---

## 1. Tầm nhìn

Nâng cấp SDD-Upgrade từ **Kỷ luật thủ công** (Manual Discipline) sang **Kỷ luật tự động hóa** (Automated Discipline) bằng cách tích hợp các pattern từ Claude-mem.

Hiện tại SDD đã có khung xương tốt (hooks bảo vệ, memory tiers, sprint tracking). Điều còn thiếu là **hệ thần kinh**: bộ nhớ tự cập nhật theo từng hành động, context thích nghi theo từng prompt, và khả năng truy xuất kiến thức cũ một cách thông minh.

> **Mục tiêu:** Kỷ luật ở khung xương — Thông minh ở hệ thần kinh.

---

## 2. Phân tích Claude-mem

### 2.1. Hook Architecture (8 Handlers / 5 Lifecycle Events)

| Handler | Event | Làm gì |
|---------|-------|--------|
| `context` | SessionStart | Inject markdown context từ DB vào Claude |
| `user-message` | SessionStart (parallel) | Hiển thị colored output ra stderr cho user |
| `session-init` | **UserPromptSubmit** | Init session + semantic search Chroma theo từng prompt |
| `observation` | PostToolUse | Lưu mọi tool call vào DB ngay lập tức |
| `file-context` | PreToolUse Read/Edit | Inject lịch sử file cụ thể trước khi đọc |
| `summarize` | Stop | Queue AI summary, poll đến khi xong (110s) |
| `session-complete` | Stop (phase 2) | Dọn active sessions map |
| `file-edit` | Cursor only | Lưu file edit như observation |

### 2.2. Các Pattern tinh vi nhất

**Pattern 1 — Error classification (Graceful Degradation)**
```
Exit 0: network error, 5xx, timeout → không block user, tiếp tục
Exit 1: non-blocking error → hiển thị cho user, không inject vào Claude
Exit 2: 4xx, TypeError, bug code → feed to Claude để fix
```
Nguyên tắc: lỗi dịch vụ không được làm gián đoạn workflow của user.

**Pattern 2 — `file-context`: Thông minh nhất trong hệ thống**
- **File size gate**: bỏ qua file < 1.5KB (overhead > benefit)
- **mtime invalidation**: file mới hơn observation gần nhất → không truncate
- **Session deduplication**: giữ 1 observation mới nhất per session, loại trùng
- **Specificity scoring**: modified > read; ít file liên quan > survey rộng
- **Rich output**: timeline với date grouping, icon theo type (⚖️🔴🟢🔄🔵✅), recovery hints

**Pattern 3 — `session-init`: Semantic injection mỗi prompt**
- Mỗi prompt → Chroma vector search → inject context liên quan
- Không inject lại nếu đã có (tránh duplicate token)
- Platform-aware: chỉ init SDK agent trên claude-code

**Pattern 4 — `summarize`: Async polling trong Stop (120s window)**
- Queue summary (trả về ngay), poll 500ms/lần đến hết queue
- Stop hook có 120s → đủ để AI summarize; SessionEnd chỉ có 1.5s → không làm gì async được

**Pattern 5 — Stderr suppression toàn bộ hook context**
- Claude Code renders stderr thành error UI đỏ ngay cả với warnings
- Claude-mem suppress hoàn toàn, chỉ dùng exit codes + log file

### 2.3. Kiến trúc Tìm kiếm 3 Lớp (Progressive Disclosure)

Claude-mem giải quyết bài toán "tràn bộ nhớ" theo nguyên tắc tiết lộ lũy tiến:

| Lớp | Công cụ | Token cost | Mục đích |
|-----|---------|-----------|---------|
| Discovery | `search` | Rất thấp | Tìm danh sách kết quả (ID + tiêu đề) |
| Context | `timeline` | Thấp | Xem diễn biến 3 bước trước/sau một sự kiện |
| Extraction | `get_observations` | Trung bình | Chỉ nạp code/log của ID đã chọn |

→ Thay thế `grep` + `mcp_supermemory_recall` hiện tại của SDD bằng quy trình này.

### 2.4. Smart AST Discovery (Tree-sitter)

- `smart_outline`: Xem "bản đồ" file (hàm/class) không cần load body code
- `smart_unfold`: Chỉ "soi" đúng khối code cần sửa

Kết hợp với GitNexus đang có trong SDD:
- **GitNexus (vĩ mô)**: định vị file đúng xuyên suốt nhiều repo
- **Smart AST (vi mô)**: đọc file đó một cách thông minh, không lãng phí context

### 2.5. Knowledge Corpora

Đóng gói kinh nghiệm theo module chuyên biệt ("Corpus bảo mật", "Corpus UI"). Khi Agent mới tham gia SDD, `prime_corpus` để sở hữu năng lực Agent cũ ngay lập tức.

---

## 3. Gap Analysis: SDD hiện tại vs Claude-mem

### 3.1. Hooks hiện có của SDD

| File | Event | Chức năng |
|------|-------|-----------|
| `session-start.sh` | SessionStart | Branch, commits, sprint, milestone, bug count, session state |
| `detect-gaps.sh` | SessionStart | Kiểm tra doc gaps |
| `bash-guard.sh` | PreToolUse Bash | Block lệnh nguy hiểm |
| `validate-commit.sh` | PreToolUse Bash | Validate git commit |
| `validate-push.sh` | PreToolUse Bash | Validate git push |
| `pre-refactor-impact.sh` | PreToolUse Write\|Edit | Impact analysis trước khi write |
| `validate-assets.sh` | PostToolUse Write\|Edit | Validate assets sau khi write |
| `pre-compact.sh` | PreCompact | Dump session state trước compact |
| `session-stop.sh` | Stop | Archive state, stats, MEMORY.md, auto-dream |
| `log-agent.sh` | SubagentStart | JSONL audit log agents |

### 3.2. Gaps được xác định

| # | Gap | Mô tả | Impact |
|---|-----|--------|--------|
| **G1** | Không có UserPromptSubmit hook | Context dump 1 lần ở SessionStart, không adapt theo từng prompt | **Cao** |
| **G2** | PostToolUse không log writes ngay | Phải đợi Stop mới biết file nào sửa (qua `git diff`, bỏ sót committed) | Trung bình |
| **G3** | Exit code semantics chưa nhất quán | `bash-guard.sh` đúng (exit 2), các hook khác thiếu error handling | Trung bình |
| **G4** | Stderr leak trong bash-guard warnings | `>&2` → Claude Code hiển thị error UI đỏ dù không có lỗi thực | Trung bình |
| **G5** | Không có PreToolUse Read hook | Có impact analysis cho Write, thiếu lịch sử khi đọc file | Trung bình |
| **G6** | pre-compact thiếu "đang làm gì" signal | Dump state file nhưng không capture last intent của Claude | Thấp |
| **G7** | Không có DB/Semantic layer | Memory dạng file markdown, không có vector search theo nghĩa | Cao (dài hạn) |
| **G8** | Không có observation pipeline | Agent không tự học từ tool calls; phải dùng lệnh thủ công | Cao (dài hạn) |

---

## 4. Kế hoạch Nâng cấp

### Tổng quan lộ trình

| Giai đoạn | Tên | Nội dung | Kết quả |
|-----------|-----|---------|---------|
| **P0** | Quick Fixes | Fix stderr, exit codes, error handling | Hệ thống ổn định hơn, không "fake errors" |
| **P1** | Automation | Log writes, UserPromptSubmit, file-history | Agent tự cập nhật, context thích nghi theo prompt |
| **P2** | Brain | SQLite + ChromaDB, observation pipeline | Truy xuất kiến thức theo nghĩa, tự học từ tool calls |
| **P3** | Multi-Agent | Knowledge Corpora per Specialist Agent | Agent mới kế thừa năng lực Agent cũ ngay lập tức |

---

### P0: Quick Fixes (Effort thấp — làm ngay)

#### Fix 1: Stderr leak trong `bash-guard.sh`

Warnings hiện viết ra `>&2` → Claude Code hiển thị error UI đỏ dù không block gì.

```bash
# TRƯỚC (dòng 102-104):
if [ -n "$WARNINGS" ]; then
    printf "[HOOK:BashGuard] Warnings for command review:%b\n" "$WARNINGS" >&2
fi

# SAU — stdout → Claude thấy như context, không phải error UI:
if [ -n "$WARNINGS" ]; then
    printf "[HOOK:BashGuard] Warnings for command review:%b\n" "$WARNINGS"
fi
```

> **Lưu ý:** Stderr cho exit 2 (BLOCKED) vẫn đúng — Claude Code feeds stderr to Claude khi exit 2. Chỉ sửa warnings (exit 0).

#### Fix 2: Error handling trong `session-start.sh`

```bash
# TRƯỚC:
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
LATEST_SPRINT=$(ls -t production/sprints/sprint-*.md 2>/dev/null | head -1)

# SAU:
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(no git)")
LATEST_SPRINT=$(ls -t production/sprints/sprint-*.md 2>/dev/null | head -1 || true)
LATEST_MILESTONE=$(ls -t production/milestones/*.md 2>/dev/null | head -1 || true)
```

---

### P1: Automation (1–2 tuần)

#### Upgrade 1: UserPromptSubmit — Memory-aware context injection

**Gap giải quyết:** G1  
**Vấn đề:** `session-start.sh` dump toàn bộ context 1 lần duy nhất. Không adapt theo từng prompt → Claude phải tự nhớ hoặc hỏi lại.  
**Giải pháp:** Hook đọc keyword từ prompt → tìm topic files liên quan → inject.

**File mới:** `.claude/hooks/prompt-context.sh`

```bash
#!/bin/bash
# Claude Code UserPromptSubmit hook: Memory-aware context injection
# Reads prompt keywords → finds relevant memory topic files → injects context
#
# Input: { "session_id": "...", "prompt": "...", "cwd": "..." }
# Exit 0: continue (inject context or passthrough silently)

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
else
    PROMPT=$(echo "$INPUT" | grep -oE '"prompt":"[^"]*"' | sed 's/"prompt":"//;s/"$//')
    SESSION_ID="unknown"
fi

[ -z "$PROMPT" ] && exit 0

MEMORY_DIR=".claude/memory"
[ ! -d "$MEMORY_DIR" ] && exit 0

# Extract keywords từ prompt (words > 4 chars, lowercase)
KEYWORDS=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]' | \
    grep -oE '[a-z]{4,}' | sort -u | head -10)

MATCHED_FILES=""

for keyword in $KEYWORDS; do
    FILE_MATCH=$(find "$MEMORY_DIR" -maxdepth 1 -name "*.md" \
        ! -name "MEMORY.md" -iname "*${keyword}*" 2>/dev/null | head -2)
    CONTENT_MATCH=$(grep -rl "$keyword" "$MEMORY_DIR" 2>/dev/null | \
        grep -v "MEMORY.md" | head -2)
    for f in $FILE_MATCH $CONTENT_MATCH; do
        if ! echo "$MATCHED_FILES" | grep -q "$f"; then
            MATCHED_FILES="$MATCHED_FILES $f"
        fi
    done
done

FILE_COUNT=0
CONTEXT_PARTS=""
for f in $MATCHED_FILES; do
    [ "$FILE_COUNT" -ge 3 ] && break
    [ ! -f "$f" ] && continue
    TOPIC=$(basename "$f" .md)
    CONTENT=$(head -50 "$f" 2>/dev/null)
    CONTEXT_PARTS="${CONTEXT_PARTS}\n\n### Memory: ${TOPIC}\n${CONTENT}"
    FILE_COUNT=$((FILE_COUNT + 1))
done

[ "$FILE_COUNT" -eq 0 ] && exit 0

CONTEXT_TEXT="## Relevant Memory Context\n_Auto-injected from .claude/memory/ based on prompt keywords_${CONTEXT_PARTS}"

printf '{"additionalContext":"%s"}' \
    "$(printf '%s' "$CONTEXT_TEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n')"

exit 0
```

**Đăng ký trong `settings.json`:**
```json
"UserPromptSubmit": [
  {
    "matcher": "",
    "hooks": [
      {
        "type": "command",
        "command": "bash .claude/hooks/prompt-context.sh",
        "timeout": 5
      }
    ]
  }
]
```

---

#### Upgrade 2: PostToolUse — Write/Edit observation logging

**Gap giải quyết:** G2  
**Vấn đề:** `session-stop.sh` dùng `git diff` → chỉ thấy uncommitted, bỏ sót committed files, không có timestamp.  
**Giải pháp:** Log vào JSONL ngay khi write xảy ra.

**File mới:** `.claude/hooks/log-writes.sh`

```bash
#!/bin/bash
# Claude Code PostToolUse hook: Log file writes/edits to JSONL immediately
# Gives session-stop.sh accurate per-file timeline instead of relying on git diff
#
# Input: { "session_id": "...", "tool_name": "Write|Edit", "tool_input": { "path": "..." } }

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // ""')
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
else
    TOOL_NAME=$(echo "$INPUT" | grep -oE '"tool_name":"[^"]*"' | sed 's/"tool_name":"//;s/"$//')
    FILE_PATH=""
    SESSION_ID="unknown"
fi

[ -z "$FILE_PATH" ] && exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
LOG_DIR="production/session-logs"
mkdir -p "$LOG_DIR" 2>/dev/null

LOG_ENTRY="{\"event\":\"${TOOL_NAME}\",\"timestamp\":\"$TIMESTAMP\",\"session_id\":\"$SESSION_ID\",\"file\":\"$FILE_PATH\",\"branch\":\"$BRANCH\"}"
echo "$LOG_ENTRY" >> "$LOG_DIR/writes.jsonl" 2>/dev/null

exit 0
```

**Cập nhật `settings.json`** — PostToolUse Write|Edit:
```json
{
  "matcher": "Write|Edit",
  "hooks": [
    {
      "type": "command",
      "command": "bash .claude/hooks/log-writes.sh",
      "timeout": 5
    },
    {
      "type": "command",
      "command": "bash .claude/hooks/validate-assets.sh",
      "timeout": 10
    }
  ]
}
```

**Cập nhật `session-stop.sh`** — thêm section đọc writes.jsonl:
```bash
# ─── Files written this session (từ writes log, chính xác hơn git diff) ───────
WRITES_LOG="$SESSION_LOG_DIR/writes.jsonl"
WRITTEN_FILES=""
if [ -f "$WRITES_LOG" ] && command -v jq >/dev/null 2>&1; then
    WRITTEN_FILES=$(jq -r --arg sid "$SESSION_ID" \
        'select(.session_id == $sid) | .file' \
        "$WRITES_LOG" 2>/dev/null | sort -u)
fi
if [ -n "$WRITTEN_FILES" ]; then
    echo ""
    echo "### Files Written This Session"
    echo "$WRITTEN_FILES" | while read -r f; do echo "  - $f"; done
fi
```

---

#### Upgrade 3: PreToolUse Read — File git history injection

**Gap giải quyết:** G5  
**Vấn đề:** SDD có `pre-refactor-impact.sh` cho Write, không có gì cho Read. Claude phải tự suy luận tại sao file trông như vậy.  
**Giải pháp:** Inject git log 5 commits gần nhất cho file đang được đọc.

**File mới:** `.claude/hooks/file-history.sh`

```bash
#!/bin/bash
# Claude Code PreToolUse hook: Inject git history for files being read
# Helps Claude understand WHY a file looks the way it does.
# Inspired by claude-mem file-context handler pattern.
#
# Input: { "tool_name": "Read", "tool_input": { "path": "..." } }

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // ""')
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"path":"[^"]*"' | sed 's/"path":"//;s/"$//')
fi

[ -z "$FILE_PATH" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# File size gate: bỏ qua file nhỏ < 1KB (overhead > benefit)
FILE_SIZE=$(wc -c < "$FILE_PATH" 2>/dev/null | tr -d ' ')
[ "${FILE_SIZE:-0}" -lt 1024 ] && exit 0

# Git history cho file này
GIT_LOG=$(git log --oneline -5 -- "$FILE_PATH" 2>/dev/null)
[ -z "$GIT_LOG" ] && exit 0  # File chưa commit → không có history

LAST_AUTHOR=$(git log -1 --pretty="%an" -- "$FILE_PATH" 2>/dev/null)
LAST_DATE=$(git log -1 --pretty="%ar" -- "$FILE_PATH" 2>/dev/null)

CONTEXT="## File History: $(basename "$FILE_PATH")
_Last modified: $LAST_DATE by $LAST_AUTHOR_

Recent commits touching this file:
$(echo "$GIT_LOG" | while read -r line; do echo "  - $line"; done)"

printf '{"additionalContext":"%s"}' \
    "$(printf '%s' "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n')"

exit 0
```

**Đăng ký trong `settings.json`:**
```json
{
  "matcher": "Read",
  "hooks": [
    {
      "type": "command",
      "command": "bash .claude/hooks/file-history.sh",
      "timeout": 5
    }
  ]
}
```

---

#### Upgrade 4: PreCompact — Last intent signal

**Gap giải quyết:** G6  
**Vấn đề:** `pre-compact.sh` dump state file nhưng không capture "Claude đang cố làm gì ngay lúc compact xảy ra."

**Thêm vào cuối `pre-compact.sh`** (trước `exit 0`):

```bash
# --- Last intent signal (what was Claude doing before compact) ---
echo ""
echo "## Last Intent Signal"
LAST_COMMIT=$(git log -1 --pretty="Commit: %s (%ar)" 2>/dev/null)
LAST_STAGED=$(git diff --staged --stat 2>/dev/null | tail -1)
[ -n "$LAST_COMMIT" ] && echo "$LAST_COMMIT"
[ -n "$LAST_STAGED" ] && echo "Staged: $LAST_STAGED"
WRITES_LOG="production/session-logs/writes.jsonl"
if [ -f "$WRITES_LOG" ]; then
    LAST_WRITE=$(tail -1 "$WRITES_LOG" 2>/dev/null | \
        grep -oE '"file":"[^"]*"' | sed 's/"file":"//;s/"$//')
    [ -n "$LAST_WRITE" ] && echo "Last file written: $LAST_WRITE"
fi
```

---

### P2: Brain — DB + Semantic Layer (Dài hạn)

**Gap giải quyết:** G7, G8

#### Bước 1: SQLite local registry

Dựng SQLite tại `.claude/memory/sdd.db` để lưu:
- Observations từ PostToolUse (tool calls, kết quả)
- Session summaries với metadata (session_id, timestamp, files touched)
- Annotations có thể query được

#### Bước 2: ChromaDB cho Semantic Search

Thay thế keyword search trong `prompt-context.sh` bằng vector search:
- Embed observations/decisions vào Chroma
- `session-init` query theo semantic similarity của prompt
- Trả về top-K relevant memories thay vì keyword match

#### Bước 3: Observation pipeline tự động

Nâng cấp `log-writes.sh` + thêm `PostToolUse Bash` hook:
```bash
# PostToolUse Bash: log command + output vào observation pipeline
# → Agent tự học từ kết quả lệnh terminal
# → Lỗi lặp lại được nhận ra và tránh tự động
```

#### Bước 4: Web Viewer (cổng 37777)

Giám sát real-time:
- Agent đang ở bước nào trong `/vertical-slice`?
- Lịch sử thay đổi code qua các session
- Timeline observations theo file

---

### P3: Multi-Agent — Knowledge Corpora (Dài hạn)

**Mục tiêu:** Khi Agent mới tham gia SDD, `prime_corpus` để kế thừa năng lực Agent cũ.

**Corpus theo Specialist:**

| Corpus | Chứa gì | Dùng khi |
|--------|---------|---------|
| `corpus-architecture` | ADRs, system design decisions | Architect Agent mới tham gia |
| `corpus-security` | Bài học bảo mật, CVEs đã gặp | Backend Agent review code |
| `corpus-ui` | Component conventions, design tokens | UI Agent làm feature |
| `corpus-ops` | Deploy history, incident playbooks | Ops Agent xử lý production |

---

## 5. Tóm tắt ưu tiên

| # | Upgrade | Giai đoạn | Effort | Impact | File |
|---|---------|-----------|--------|--------|------|
| 0a | Fix stderr warnings | P0 | **Thấp** | Trung bình | `bash-guard.sh` |
| 0b | Fix error handling | P0 | **Thấp** | Thấp | `session-start.sh` |
| 1 | UserPromptSubmit memory-aware | P1 | Trung bình | **Cao** | `prompt-context.sh` (mới) |
| 2 | PostToolUse write logging | P1 | **Thấp** | Trung bình | `log-writes.sh` (mới) |
| 3 | PreToolUse Read file-history | P1 | Trung bình | Trung bình | `file-history.sh` (mới) |
| 4 | PreCompact last intent signal | P1 | **Thấp** | Thấp | `pre-compact.sh` (sửa) |
| 5 | SQLite + ChromaDB | P2 | Cao | **Cao** | Infrastructure mới |
| 6 | Observation pipeline | P2 | Cao | **Cao** | `PostToolUse Bash` hook |
| 7 | Knowledge Corpora | P3 | Cao | Cao | `.claude/corpus/` |

**Thứ tự khuyến nghị P0→P1:** `0a → 0b → 2 → 1 → 3 → 4`

- Bắt đầu bằng fix nhỏ không rủi ro (0a, 0b)
- Infrastructure trước (2 — writes.jsonl dùng cho cả 4 và session-stop)
- Feature lớn nhất (1 — UserPromptSubmit adaptive context)
- Nice-to-have sau (3, 4)

---

## 6. Files cần tạo mới / sửa

### P0 — Sửa ngay

| Action | File | Thay đổi |
|--------|------|---------|
| Sửa | `.claude/hooks/bash-guard.sh` | Warnings → stdout thay vì stderr |
| Sửa | `.claude/hooks/session-start.sh` | Thêm `|| true` / `|| echo fallback` cho git calls |

### P1 — Tạo mới + sửa

| Action | File | Thay đổi |
|--------|------|---------|
| Tạo mới | `.claude/hooks/prompt-context.sh` | UserPromptSubmit memory-aware hook |
| Tạo mới | `.claude/hooks/log-writes.sh` | PostToolUse Write\|Edit JSONL logger |
| Tạo mới | `.claude/hooks/file-history.sh` | PreToolUse Read git history injection |
| Sửa | `.claude/hooks/session-stop.sh` | Đọc `writes.jsonl` thay vì chỉ `git diff` |
| Sửa | `.claude/hooks/pre-compact.sh` | Thêm last intent signal section |
| Sửa | `.claude/settings.json` | Đăng ký 3 hooks mới + sửa PostToolUse order |

---

## 7. Kết luận

Claude-mem không chỉ là một plugin — nó là một bộ design patterns cho **AI-Native software workflow**. SDD đã có nền tảng tốt; việc tích hợp các patterns này sẽ biến SDD thành hệ thống có:

- **Bộ nhớ thích nghi**: context thay đổi theo từng prompt, không phải chỉ theo session
- **Audit trail đầy đủ**: mọi file write, agent invocation, bash command đều được log
- **Tự học**: observation pipeline tự động rút kiến thức từ tool calls
- **Khả năng kế thừa**: Agent mới không mất thời gian warm-up

---

*Báo cáo tổng hợp từ hai nguồn: phân tích chiến lược (Antigravity AI) + phân tích kỹ thuật hooks (2026-04-16).*
