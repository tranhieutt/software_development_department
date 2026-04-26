# 🧪 QA Knowledge Base — Browser Automation Frameworks

> **Owner:** `qa-engineer`
> **Source:** Crawler Webgame Lessons #8, #4

---

## Puppeteer vs Playwright — Bảng so sánh API

Tuyệt đối KHÔNG mix API giữa hai framework. Dưới đây là các điểm khác biệt thường gây nhầm lẫn:

| Tính năng | Puppeteer | Playwright |
|---|---|---|
| **Import** | `require('puppeteer')` | `require('playwright')` |
| **Launch** | `puppeteer.launch()` | `chromium.launch()` |
| **waitUntil** | `load`, `domcontentloaded`, `networkidle0`, `networkidle2` | `load`, `domcontentloaded`, `networkidle`, **`commit`** |
| **Selector** | `page.$()` / `page.$$()` | `page.locator()` (preferred) |
| **Wait for element** | `page.waitForSelector()` | `page.locator().waitFor()` |
| **Click** | `page.click()` | `page.locator().click()` |
| **Type** | `page.type()` | `page.locator().fill()` |
| **Evaluate** | `page.evaluate()` | `page.evaluate()` (tương tự) |
| **Screenshot** | `page.screenshot()` | `page.screenshot()` (tương tự) |
| **Request Interception** | `page.setRequestInterception(true)` + `request` event | `page.route()` |
| **Browser Contexts** | `browser.createBrowserContext()` (đơn giản) | `browser.newContext()` (mạnh, có storage state) |
| **Auto-waiting** | Không (phải `waitForSelector` thủ công) | Có (tự động chờ element actionable) |

> ⚠️ **Gotcha phổ biến:** `waitUntil: 'commit'` chỉ tồn tại trong Playwright. Dùng nó trong Puppeteer sẽ gây lỗi: `Unknown value for options.waitUntil: commit`. Thay thế bằng `domcontentloaded` + `waitForFunction`.

---

## Checklist khi Upgrade thư viện (npm)

Từ bài học #3 và #4 (API breaking changes):

### Trước khi upgrade

- [ ] Đọc **CHANGELOG** và **Migration Guide** của phiên bản mới
- [ ] Kiểm tra **ESM/CJS compatibility** (xem field `"type"` trong `package.json` của thư viện)
- [ ] Tìm kiếm `is not a function` + tên thư viện trên GitHub Issues
- [ ] Pin **exact version** trong `package.json` (dùng `"4.1.5"`, không dùng `"^4.1.5"`)

### Sau khi upgrade

- [ ] Chạy đầy đủ test suite
- [ ] Kiểm tra log runtime — tìm `ERR_REQUIRE_ESM`, `is not a function`, `Cannot find module`
- [ ] Test trên môi trường staging trước production
- [ ] Nếu thư viện liên quan đến auth/API, test lại flow đầy đủ (không chỉ unit test)

---

## Defensive Coding Patterns cho External APIs

```javascript
// ✅ ĐÚNG: Try/catch + fallback
async function safeGetRows(sheet) {
    try {
        await sheet.loadHeaderRow();
        if (!sheet.headerValues || sheet.headerValues.length === 0) {
            await sheet.setHeaderRow(HEADERS);
        }
    } catch (e) {
        // Fallback: Sheet chưa có header → tạo mới
        await sheet.setHeaderRow(HEADERS);
    }
}

// ❌ SAI: Assume API luôn trả đúng format
async function unsafeGetRows(sheet) {
    const rows = await sheet.getRows(); // Throw nếu chưa có header!
    return rows;
}
```

---

*Knowledge base này được mở rộng liên tục từ các dự án thực chiến của team.*
