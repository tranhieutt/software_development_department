# Report: Upgrade Hooks SDD từ Claude-mem Patterns

**Ngày:** 2026-04-16  
**Nguồn tham khảo:** `E:\claude-mem` — plugin claude-mem v12.x  
**Áp dụng cho:** `E:\SDD-Upgrade\.claude\hooks\`

---

## 1. Tổng quan Claude-mem Hook Architecture

Claude-mem có **8 handlers** chạy qua 5 lifecycle events:

| Handler | Event | Làm gì |
|---------|-------|--------|
| `context` | SessionStart | Inject markdown context từ DB vào Claude |
| `user-message` | SessionStart (parallel) | Hiển thị colored output ra stderr cho user |
| `session-init` | UserPromptSubmit | Init session + semantic search Chroma theo prompt |
| `observation` | PostToolUse | Lưu mọi tool call vào DB |
| `file-context` | PreToolUse Read/Edit | Inject lịch sử file cụ thể trước khi đọc |
| `summarize` | Stop | Queue AI summary, poll đến khi xong (110s) |
| `session-complete` | Stop (phase 2) | Dọn active sessions map |
| `file-edit` | Cursor only | Lưu file edit như observation |

### Patterns tinh vi nhất trong claude-mem

**Pattern 1: `isWorkerUnavailableError` — phân loại lỗi**
```typescript
// Exit 0: network error, 5xx, timeout → graceful, không block user
// Exit 2: 4xx, TypeError, ReferenceError → bug cần fix, feed to Claude
```

**Pattern 2: `file-context` — thông minh nhất trong system**
- File size gate: bỏ qua file < 1.5KB (overhead > benefit)
- mtime invalidation: file mới hơn observation → không truncate
- Session deduplication: giữ 1 observation mới nhất per session
- Specificity scoring: modified > read; ít file liên quan > survey rộng
- Output: timeline với date grouping, icon theo type (⚖️🔴🟢🔄🔵✅), recovery hints

**Pattern 3: `session-init` — UserPromptSubmit với semantic injection**
- Mỗi prompt → Chroma vector search → inject context liên quan
- Không inject lại nếu context đã có (tránh duplicate)
- Platform-aware: chỉ init SDK agent trên claude-code, không phải Cursor

**Pattern 4: `summarize` — async polling trong Stop (120s window)**
- Queue summary (trả về ngay), poll 500ms/lần đến hết queue
- Stop hook có 120s — đủ để AI summarize; SessionEnd chỉ có 1.5s

**Pattern 5: stderr suppression toàn bộ hook context**
- Claude Code renders stderr thành error UI đỏ
- Claude-mem suppress hoàn toàn: `process.stderr.write = (() => true)`
- Chỉ dùng exit codes + log file để communicate

---

## 2. Gap Analysis: SDD vs Claude-mem

### Hooks hiện có của SDD

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
| `session-stop.sh` | Stop | Archive state, stats, MEMORY.md update, auto-dream |
| `log-agent.sh` | SubagentStart | JSONL audit log agents |

### Gaps được xác định

| # | Gap | Mô tả | Impact |
|---|-----|--------|--------|
| G1 | Không có UserPromptSubmit hook | Context dump 1 lần ở SessionStart, không adapt theo từng prompt | Cao |
| G2 | PostToolUse không log writes ngay | Phải đợi đến Stop mới biết file nào được sửa (qua `git diff`) | Trung bình |
| G3 | Exit code semantics chưa nhất quán | `bash-guard.sh` đúng (exit 2), nhưng các hook khác thiếu error handling | Trung bình |
| G4 | Stderr leak trong bash-guard warnings | `>&2` → Claude Code hiển thị error UI đỏ | Trung bình |
| G5 | Không có file-history cho PreToolUse Read | Có impact analysis cho Write, không có lịch sử cho Read | Trung bình |
| G6 | pre-compact thiếu "đang làm gì" context | Dump state file nhưng không capture last intent/action của Claude | Thấp |

---

## 3. Đề xuất Upgrade Chi tiết

---

### Upgrade 1: UserPromptSubmit hook — Memory-aware context injection

**Gap:** G1  
**Effort:** Trung bình  
**Impact:** Cao nhất

**Vấn đề hiện tại:**  
`session-start.sh` dump toàn bộ context 1 lần. Sau đó Claude không nhận thêm context theo từng prompt → Claude phải tự nhớ hoặc hỏi lại.

**Giải pháp:**  
Thêm hook mới `prompt-context.sh` chạy ở `UserPromptSubmit`. Hook đọc từ khóa trong prompt → tìm topic files liên quan trong `.claude/memory/` → inject vào context.

**File mới:** `.claude/hooks/prompt-context.sh`

```bash
#!/bin/bash
# Claude Code UserPromptSubmit hook: Memory-aware context injection
# Reads prompt keywords → finds relevant memory topic files → injects context
#
# Input: { "session_id": "...", "prompt": "...", "cwd": "..." }
# Exit 0: continue (inject context or passthrough)
# Exit 2: blocking error (should not happen normally)

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
CONTEXT_PARTS=""

# Match keywords against topic file names and content
for keyword in $KEYWORDS; do
    # Match by filename
    FILE_MATCH=$(find "$MEMORY_DIR" -maxdepth 1 -name "*.md" \
        ! -name "MEMORY.md" -iname "*${keyword}*" 2>/dev/null | head -2)

    # Match by content (first 20 lines only for speed)
    CONTENT_MATCH=$(grep -rl "$keyword" "$MEMORY_DIR" 2>/dev/null | \
        grep -v "MEMORY.md" | head -2)

    for f in $FILE_MATCH $CONTENT_MATCH; do
        # Deduplicate
        if ! echo "$MATCHED_FILES" | grep -q "$f"; then
            MATCHED_FILES="$MATCHED_FILES $f"
        fi
    done
done

# Build context from matched files (cap at 3 files, 50 lines each)
FILE_COUNT=0
for f in $MATCHED_FILES; do
    [ "$FILE_COUNT" -ge 3 ] && break
    [ ! -f "$f" ] && continue
    TOPIC=$(basename "$f" .md)
    CONTENT=$(head -50 "$f" 2>/dev/null)
    CONTEXT_PARTS="${CONTEXT_PARTS}\n\n### Memory: ${TOPIC}\n${CONTENT}"
    FILE_COUNT=$((FILE_COUNT + 1))
done

# If no matches, passthrough silently
[ "$FILE_COUNT" -eq 0 ] && exit 0

# Output context injection (Claude Code UserPromptSubmit format)
CONTEXT_TEXT="## Relevant Memory Context\n_Auto-injected from .claude/memory/ based on prompt keywords_${CONTEXT_PARTS}"

printf '{"additionalContext":"%s"}' \
    "$(printf '%s' "$CONTEXT_TEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n')"

exit 0
```

**Đăng ký trong settings.json:**
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

### Upgrade 2: PostToolUse Write log — Observation ngay lập tức

**Gap:** G2  
**Effort:** Thấp  
**Impact:** Trung bình

**Vấn đề hiện tại:**  
`session-stop.sh` dùng `git diff` để biết file nào bị sửa. Vấn đề: chỉ thấy uncommitted changes, không thấy committed changes trong session; không có timestamp.

**Giải pháp:**  
Thêm hook `log-writes.sh` ở `PostToolUse Write|Edit`. Log ngay vào JSONL kèm timestamp. `session-stop.sh` dùng log này thay vì chỉ `git diff`.

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

**Cập nhật settings.json** — thêm vào PostToolUse:
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
# ─── Files written this session (from writes log) ────────────────────────────
WRITES_LOG="$SESSION_LOG_DIR/writes.jsonl"
WRITTEN_FILES=""
if [ -f "$WRITES_LOG" ] && command -v jq >/dev/null 2>&1; then
    WRITTEN_FILES=$(jq -r --arg sid "$SESSION_ID" \
        'select(.session_id == $sid) | .file' \
        "$WRITES_LOG" 2>/dev/null | sort -u)
fi
```

---

### Upgrade 3: Fix stderr leak + Exit code consistency

**Gap:** G3, G4  
**Effort:** Thấp  
**Impact:** Trung bình

**Vấn đề hiện tại:**  
`bash-guard.sh` dùng `>&2` cho warnings → Claude Code hiển thị thành error UI đỏ. Người dùng thấy "error" dù không có lỗi thực sự.

**Giải pháp:**  
Chuyển warnings sang stdout (Claude sẽ thấy). Chỉ dùng stderr nếu muốn exit 2 block.

**Thay đổi trong `bash-guard.sh`:**

```bash
# TRƯỚC (dòng 38-39):
echo "[HOOK:BashGuard] BLOCKED: $reason" >&2
echo "[HOOK:BashGuard] Command: $COMMAND" >&2
exit 2

# SAU:
# Stderr vẫn đúng cho exit 2 — Claude Code feeds stderr to Claude khi exit 2
# Nhưng warnings (không block) → stdout thay vì stderr
```

```bash
# TRƯỚC warnings (dòng 102-104):
if [ -n "$WARNINGS" ]; then
    printf "[HOOK:BashGuard] Warnings for command review:%b\n" "$WARNINGS" >&2
fi

# SAU:
if [ -n "$WARNINGS" ]; then
    # stdout → Claude thấy như context, không phải error UI
    printf "[HOOK:BashGuard] Warnings for command review:%b\n" "$WARNINGS"
fi
```

**Error handling cho `session-start.sh`** — thêm fallback:
```bash
# TRƯỚC:
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# SAU:
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(no git)")
LATEST_SPRINT=$(ls -t production/sprints/sprint-*.md 2>/dev/null | head -1 || true)
```

---

### Upgrade 4: PreToolUse Read — File git history injection

**Gap:** G5  
**Effort:** Trung bình  
**Impact:** Trung bình

**Vấn đề hiện tại:**  
SDD có `pre-refactor-impact.sh` cho Write/Edit. Nhưng khi Claude **đọc** file, không có context về tại sao file trông như vậy — Claude phải tự suy luận từ code.

**Giải pháp:**  
Thêm `file-history.sh` cho PreToolUse Read. Inject git log 5 commits gần nhất của file đó.

**File mới:** `.claude/hooks/file-history.sh`

```bash
#!/bin/bash
# Claude Code PreToolUse hook: Inject git history for files being read
# Helps Claude understand WHY a file looks the way it does.
# Inspired by claude-mem file-context handler.
#
# Input: { "tool_name": "Read", "tool_input": { "path": "..." } }
# Exit 0: continue (with or without context)

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // ""')
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"path":"[^"]*"' | sed 's/"path":"//;s/"$//')
fi

[ -z "$FILE_PATH" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# File size gate: bỏ qua file nhỏ (< ~1KB) — overhead không đáng
FILE_SIZE=$(wc -c < "$FILE_PATH" 2>/dev/null | tr -d ' ')
[ "${FILE_SIZE:-0}" -lt 1024 ] && exit 0

# Git history cho file này
GIT_LOG=$(git log --oneline -5 -- "$FILE_PATH" 2>/dev/null)
[ -z "$GIT_LOG" ] && exit 0  # File chưa được commit → không có history

# Last modifier
LAST_AUTHOR=$(git log -1 --pretty="%an" -- "$FILE_PATH" 2>/dev/null)
LAST_DATE=$(git log -1 --pretty="%ar" -- "$FILE_PATH" 2>/dev/null)

CONTEXT="## File History: $(basename "$FILE_PATH")
_Last modified: $LAST_DATE by $LAST_AUTHOR_

Recent commits touching this file:
$(echo "$GIT_LOG" | while read -r line; do echo "  - $line"; done)"

# Output context injection
printf '{"additionalContext":"%s"}' \
    "$(printf '%s' "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n')"

exit 0
```

**Đăng ký trong settings.json:**
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

### Upgrade 5: pre-compact — Thêm "current intent" context

**Gap:** G6  
**Effort:** Thấp  
**Impact:** Thấp

**Vấn đề hiện tại:**  
`pre-compact.sh` dump state file và git diff, nhưng không capture "Claude đang cố làm gì ngay lúc compact xảy ra."

**Thêm vào cuối `pre-compact.sh`** (trước dòng `exit 0`):

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

## 4. Tóm tắt ưu tiên thực hiện

| # | Upgrade | Effort | Impact | Phụ thuộc |
|---|---------|--------|--------|-----------|
| 1 | UserPromptSubmit memory-aware hook | Trung bình | **Cao** | Không |
| 2 | PostToolUse write logging | **Thấp** | Trung bình | Không |
| 3 | Fix stderr + exit code consistency | **Thấp** | Trung bình | Không |
| 4 | PreToolUse Read file-history | Trung bình | Trung bình | Không |
| 5 | pre-compact last intent signal | **Thấp** | Thấp | Upgrade 2 (writes.jsonl) |

**Thứ tự khuyến nghị:** 3 → 2 → 1 → 4 → 5

- Bắt đầu bằng fix nhỏ không rủi ro (3)
- Sau đó infrastructure (2 — writes.jsonl dùng cho 5 và session-stop)
- Rồi feature lớn nhất (1 — UserPromptSubmit)
- Cuối cùng nice-to-have (4, 5)

---

## 5. Files cần tạo mới / sửa

| Action | File |
|--------|------|
| Tạo mới | `.claude/hooks/prompt-context.sh` |
| Tạo mới | `.claude/hooks/log-writes.sh` |
| Tạo mới | `.claude/hooks/file-history.sh` |
| Sửa | `.claude/hooks/bash-guard.sh` (warnings → stdout) |
| Sửa | `.claude/hooks/session-start.sh` (error handling) |
| Sửa | `.claude/hooks/session-stop.sh` (đọc writes.jsonl) |
| Sửa | `.claude/hooks/pre-compact.sh` (last intent section) |
| Sửa | `.claude/settings.json` (đăng ký hooks mới) |
