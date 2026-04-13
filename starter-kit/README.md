# Claude Code Starter Kit

> 精選 Claude Code 設定包。非工程師也能上手，直接丟給 AI 就能用。
> by [雷蒙三十](https://raymondhouch.com) — 聰明工作、好好生活。

---

## 這是什麼？

一系列「可以直接丟給 Claude Code 讀取並執行」的設定文件。

每份文件都是獨立的，挑你需要的用就好。就像手機 App Store，看到喜歡的就安裝。

## 使用方式

把任何一份設定包的網址丟給你的 Claude Code，它就會幫你安裝：

```
幫我照這份文件設定：
https://raw.githubusercontent.com/Raymondhou0917/claude-code-resources/master/starter-kit/01-terminal-setup.md
```

就這樣，一句話搞定。

---

## 設定包清單

### 基礎設定（建議必裝）

| # | 名稱 | 說明 | 難度 |
|:--|:-----|:-----|:-----|
| 01 | [讓對話可以往回滾](01-terminal-setup.md) | `cc` 一鍵啟動 + NO_FLICKER 模式，對話不再滾不回去 | ⭐ |
| 02 | [用編輯器寫長 Prompt](02-external-editor.md) | `Ctrl+G` 跳到熟悉的編輯器，不再跟輸入框搏鬥 | ⭐ |
| 03 | [安全三件套](03-safe-delete.md) | 垃圾桶 + 危險指令黑名單 + 權限模式引導選擇，一次裝好 | ⭐ |
| 04 | [MCP 推薦清單](04-mcp-essentials.md) | 讓 AI 讀信、抓網頁、操作瀏覽器、讀寫檔案（互動式選裝） | ⭐⭐ |
| 06 | [Status Line 狀態列](06-statusline.md) | 終端機顯示模型、額度、Git、最後訊息時間（互動式選裝） | ⭐ |

### 主題懶人包（Skills & 工具組合）

| # | 名稱 | 說明 | 難度 |
|:--|:-----|:-----|:-----|
| 05 | [線上部署懶人包](05-deploy-online.md) | Zeabur + Cloudflare，讓作品被全世界看到（互動式選裝） | ⭐⭐ |

### 更多主題持續更新中...

---

## 想要更系統化的學習？

這些設定包讓你快速上手（Lv.1 → Lv.10）。

如果你想讓 AI 助理真正變成即戰力（Lv.30），我們有完整、即將推出的 **[Claude Code 迷你課](https://academy.lifehacker.tw/)**，包含：

- 10+ 個升級模組（記憶系統、Skills 模板、MCP 整合...）
- CLAUDE.md 範本（入門 / 進階 / 完整版個人化知識庫版本）
- 5+ 個精選 Skill 模板（安裝就能用）

---

## 撰寫格式（協作者參考）

每份設定包分為**上半給人看、下半給 AI 執行**，用 `---` 分割線隔開：

```
# 標題（問題導向或成果導向，含關鍵字，讓人搜尋得到）

> ⭐ 難度｜時間｜適用平台

## 你可能遇過這些問題
→ 描述痛點，讓讀者覺得「這就是我遇到的！」

## 裝完之後你會得到
→ 列點式，每點一句話講清楚好處

## 雷蒙當時的情況和選擇
→ 第一人稱，為什麼選這個方案、試過什麼、踩過什麼坑

## 怎麼裝？
→ 一句話：「把這份文件丟給 Claude Code」

---（分割線）

## 安裝指令（AI 執行區）
→ 完整步驟、指令、驗證、備用方案、踩坑紀錄
```

參考範例：`01-terminal-setup.md`、`02-external-editor.md`、`06-statusline.md`（最新金標準）

### 必備元素（2026-04 起的新標準）

1. **腳本 header attribution** — 所有會寫入用戶檔案系統的 bash / shell 腳本，第一段註解必須包含 **Designer / Source / Docs / License** 四項。參考 `06-statusline.md` Section D 的完整範例區塊。

2. **互動式選擇用 AskUserQuestion** — 需要用戶做決定時，請用 `AskUserQuestion` 工具跳出互動框，**不要**在純文字訊息中列「請輸入 1/2/3」要求用戶回覆——新手看到這種問題不知道要回什麼。參考 `03-safe-delete.md` Section C（單選）、`06-statusline.md` Section B/C/E（多選 + 自訂輸入）。

3. **結尾授權區塊** — 每份 `.md` 末尾必須有「## 授權」小節：
   - **License**：CC BY-NC-SA 4.0 · 個人使用、學習、分享自由；禁止商業用途
   - **出處標記**：`出自 雷蒙三十 Starter Kit — cc.lifehacker.tw | CC BY-NC-SA 4.0`
   - **延伸觸點**：迷你課 / 週報 / Threads 用分隔符排成一行，避免看起來像廣告條

---

## 授權

[CC BY-NC-SA 4.0](../LICENSE) — 歡迎個人使用、學習、分享，禁止商業用途。修改後需以相同授權釋出並標註出處。

## 相關資源

- 📖 [Claude Code 學習資源站](https://cc.lifehacker.tw)
- 📋 [Claude Code 指令速查表](https://github.com/Raymondhou0917/claude-code-cheatsheet-zh)
- 📧 [雷蒙週報（免費訂閱）](https://raymondhouch.com/subscribe)
