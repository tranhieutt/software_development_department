---
name: feedback-rules
description: Team rules, code review feedback, and "do/don't" guidelines that agents must follow.
type: feedback
---

A repository of do/don't rules corrected by the user — agents must never repeat these mistakes.

## Core Rules (từ audit sessions)

- **Đừng thêm skill mới khi chưa có telemetry:** Mỗi lần thêm skill = phải có evidence usage. Telemetry trước, expansion sau.
**Why:** Skill count tăng từ 117→118 ngay sau cam kết cắt — anti-pattern "thêm nhanh hơn cắt".

- **Đừng để rule MUST không có hook enforcement:** Mỗi MUST rule phải có hook tương ứng hoặc downgrade SHOULD.
**Why:** Rule 16 aspirational 4 ngày, Rule 14/15 aspirational nhiều tuần trước khi có hooks.

- **Khi present options, dùng format "Option A / Option B" rõ ràng** — không tự quyết.
**Why:** User muốn approve trước khi implement, đặc biệt với changes ảnh hưởng coordination rules.

- **Commit thường xuyên sau mỗi P0 fix** — không batch nhiều fixes vào 1 commit lớn.
**Why:** Easier to revert, easier to review, mirrors surgical change principle.

## 2026-04-19 — Từ giờ bạn làm việc trên nhánh main nhé
**Trigger:** "Từ giờ bạn làm việc trên nhánh main nhé"
**Source:** user-prompt
Từ giờ bạn làm việc trên nhánh main nhé
