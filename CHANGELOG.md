# 更新紀錄 Changelog

本檔記錄「Claude Code 學習資源」的版本更新。
網站：[cc.lifehacker.tw](https://cc.lifehacker.tw)

---

## [v1.1] — 2026-06-16

距離 v1.0 以來累積 49 個 commit 的整合更新。最大轉變：從「Claude Code 學習資源」擴展為 **Claude Code × Codex 雙棲的 AI Agent 學習資源**，Starter Kit 全面跟上 Claude Code 新版與 Windows 支援。

### 🗺 重新定位：Claude Code × Codex 雙棲
- 並列 Codex，網站重新定位為「AI Agent 學習資源」
- Hero 改垂直版型，加上 Claude / Codex 圓角 app icon 與雙桌面截圖，Codex 內容大幅擴充
- 新增 **Claude Code × Codex 雙棲進化地圖**（入門 / 活用 / 高手三層 + Context、Compact、Skills、SSOT 共用心法）
- 雷蒙教學文新增「Codex 搬家」「Context Window」兩篇

### 🪟 Windows 支援
- Starter Kit 01 補完 Windows 11 終端機設定：WMUX / Windows Terminal / Tabby + PowerShell `cc` function
- Starter Kit 全面支援 macOS / Linux / Windows

### 🛠 Starter Kit 更新（跟上 Claude Code 新版）
- **01 終端機**：減少閃爍改用 `tui:fullscreen`（settings.json）對應 CC 2.1.110+、移除過時的 `CLAUDE_CODE_NO_FLICKER` env var、新增 Fullscreen 取捨三欄比較表與 AI 情境選擇引導
- **04 MCP**：修正 Filesystem / Playwright 套件名稱、修正 gws CLI 安裝指令、補上 GWS CLI OAuth 雷區警告與 manual flow
- **05 部署**：加註安裝指令須在終端機執行（避免誤貼到 Claude 對話框）
- **06 狀態列**：自動偵測 Claude Code 主題切換顏色、模型範例更新為 4.8
- 全部 Starter Kit 加上 **AI 互動規範**：執行時自動詢問個人化偏好 → 偵測既有配置並確認 → 用白話文條列總結做了什麼

### ⭐ 學員見證 / 社會證明
- 新增學員心得牆（24 則 + 5 張截圖），內嵌 IG Reel，還原完整心得原文
- 購買人數從 2000+ 更新到 3800+

### 🚀 SEO / 效能
- 新增 OG image + SEO 優化
- 新增 robots.txt 與 sitemap.xml 加速 Google 索引
- 載入優化省約 4.7MB（圖片 / 字型 / LCP）
- Kit 訂閱表單加上 attribution 追蹤（host / referrer / search）

### 🎓 迷你課程 / 頁面
- 迷你課銷售頁改版：新版課綱、ProKit 對比區塊、「不到千元為什麼這麼便宜」FAQ
- 課程大綱對齊迷你課、3-3 課名更新為「日本旅行 AI 拍照收據自動記帳」
- 6/13 直播報名 →（直播結束後）改為作品平台導流、bonus 影片已上傳
- 大量 UI / UX 樣式優化、手機版跑版修正、CTA 與 UTM 追蹤統一

**完整 commit**：[v1.0...v1.1](https://github.com/Raymondhou0917/claude-code-resources/compare/v1.0...v1.1)

---

## [v1.0] — 2026-04-12

首次正式 Release，包含完整學習資源網站與 6 份 Starter Kit 設定包。

### 🌐 學習資源網站
- 一頁式 Claude Code 學習入口（[cc.lifehacker.tw](https://cc.lifehacker.tw)）
- 精選免費資源分類（安裝教學、應用案例、技術文件）
- 迷你課程導覽 + 應用案例展示（Showcase）
- 雷蒙教學文分頁（5 篇 WP 文章）
- Meta Pixel + GA 追蹤

### 🛠 Starter Kit 設定包（開源）
| # | 設定包 | 解決什麼問題 |
|:--|:--|:--|
| 01 | 終端機優化 | 滑鼠支援、減少閃爍、`cc` 快捷啟動 |
| 02 | 外部編輯器 | 長指令不再痛苦，用編輯器寫 Prompt |
| 03 | 安全三件套 | 垃圾桶 + 危險指令黑名單 + 權限模式 |
| 04 | MCP 推薦清單 | 讓 AI 讀信、抓網頁、管行事曆 |
| 05 | 線上部署 | Zeabur + Cloudflare 一條龍部署 |
| 06 | 狀態列設定 | 一眼看到模型、額度、Git 狀態 |

### 📺 搭配影片
- [Claude Code 超詳細入門教學（70 分鐘）](https://youtu.be/xo7dE80ktu4)
