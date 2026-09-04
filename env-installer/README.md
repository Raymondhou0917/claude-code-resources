# ⚡ AI 基礎環境安裝包（開源版）：一鍵把電腦備好「AI 辦公室」

> **ver. 3.2** ｜ **Last edited: 2026-09-04**
> ⭐ 初學者友善｜10～15 分鐘｜零程式基礎適用
> 這是專為想開始使用 AI Agent（如 Claude Code、Codex）的新手設計的**開源自動安裝工具**。
> **這不是程式碼，不用你寫任何指令！** 在 Mac 上下載解壓縮後「點兩下打開」，就能一口氣幫電腦裝好 AI 所需的基本文具與軟體。本課學員把它當**步驟 0**，跑完再進 Pro-Kit 01。

> **這裡就是開源正本**（`env-installer/`）。課程 repo 的 `content/pro-kit/bootstrap/` 與此同步，方便學員在課程路徑內找到。

---

## 💡 為什麼需要這套安裝包？（零基礎 30 秒白話）

過去用網頁版 ChatGPT，就像在「打客服電話」：電話掛斷它就忘了，它也完全碰不到你的電腦檔案。  
而現在的 **AI Agent 是「住進你電腦裡的萬能秘書」**，能直接幫你閱讀教材、整理專案、自動化工作。

為了讓秘書能順利上工，這個小工具會自動幫你準備好 4 樣「辦公用品」：

| # | 必備項目 | 白話功能說明 |
| :-- | :-- | :-- |
| 1 | **Git** | 講義檔案櫃與安全備忘錄（讓 AI 隨時能存檔、反悔） |
| 2 | **Homebrew** | Mac 的自動代購管家（之後安裝任何輔助軟體都靠它） |
| 3 | **GitHub CLI (`gh`)** | 雲端檔案庫連線工具 |
| 4 | **GitHub 登入** | 秘書的專屬識別證（讓 AI 能存取你的私人教材與專案） |

接著，你只需要用鍵盤勾選想使用的 **AI 秘書辦公桌（Claude 或 Codex 的桌面版 / 終端機版）**，按下 Enter，剩下的雜事通通自動搞定！

```text
挑你要裝的 AI 工具（用 ↑↓ 移動、空白鍵勾選、可複選；都不勾＝只裝基礎）：

  [x] Claude 桌面版      Claude 官方桌面 App
  [x] Claude 終端機版    Claude Code，終端機裡的 AI Agent
  [x] ChatGPT 桌面版     ChatGPT 官方桌面 App
  [x] Codex 終端機版     Codex CLI，終端機裡的 AI Agent
```

四個選項各自獨立，想裝哪個就勾哪個（**建議全選**，之後換路線最方便）。  
已經裝好的項目會自動跳過，所以**重跑幾次都沒關係**——中途被打斷、或之後想換路線，再雙擊一次就好。完成畫面會依**實際結果**打勾，跑完按一下 Enter 視窗就會自動關掉。

---

## 🍎 怎麼用（Mac 用戶：雙擊 App）

> 📸 每一步都有手把手圖文對照：👉 **[點我查看圖解操作步驟（操作.md）](./操作.md)**

1. 下載本資料夾的 [`雷蒙的 AI 基礎環境安裝包(MAC).zip`](<./雷蒙的 AI 基礎環境安裝包(MAC).zip>)（已通過 Apple 官方簽名與安全公證，雙擊即可）。
2. 瀏覽器通常會自動解壓成 App，**雙擊它打開**。
3. 開場用 ↑↓ 方向鍵與空白鍵勾選你要的 AI 工具（**建議全選**）、按 Enter，跟著終端機畫面走。
4. 中途可能請你輸入 Mac 開機密碼、或彈出瀏覽器登入 GitHub——這都是正常的安全流程。
5. 如果中途裝了系統的「命令列開發者工具」：裝完後**再雙擊 App 一次**，就會自動接續完成。

> [!TIP]
> ### 🛡️ 新手安心指南：三個「看起來壞了，其實一切正常」的狀況
>
> - **輸入密碼時看不到游標在動？**  
>   這是 Mac 終端機保護密碼隱私的正常行為（防止身旁的人偷看位數）。不要懷疑，直接打完你的開機密碼並按 Enter 即可！
> - **畫面卡住好幾分鐘不動？**  
>   那是在背後下載 Homebrew 大檔案（通常需要 3～5 分鐘），電腦沒有當機，請喝口水耐心稍等一下。
> - **跳出未識別開發者提示？**  
>   正式公證版通常可直接開啟；若系統彈出提示，對著 App 按 **右鍵 → 打開** 即可。

---

## 🪟 Windows 同學怎麼辦？（極簡 3 步走）

Windows 用戶不用看 Mac 的設定，也不需要安裝複雜的 WSL，照著以下 **3 個極簡步驟** 即可完成配置：

1. **安裝 Git（檔案櫃）**：
   - 前往 [Git 官方下載頁面](https://git-scm.com/download/win)，下載 **64-bit Windows Setup**。
   - 下載後打開安裝檔，**一路按「Next」到底直到完成**即可（選項保持預設）。
2. **取得 GitHub 識別證（授權登入）**：
   - 在開始選單搜尋並打開 **「終端機」（Terminal）** 或 **「PowerShell」**。
   - 輸入指令安裝工具：`winget install --id GitHub.cli`（按 Enter 執行）。
   - 輸入登入指令：`gh auth login`。
   - 依提示按 Enter 選擇：`GitHub.com` → `HTTPS` → `Yes` → `Login with a web browser`。
   - 畫面上會出現一組 8 碼英文驗證碼，瀏覽器會自動開啟登入頁面，貼上確認即完成！
3. **下載 AI 秘書桌面版（辦公桌）**：
   - 👉 **[下載 ChatGPT / Codex 桌面版官方安裝檔](https://openai.com/codex/)**（或 [ChatGPT 官方下載頁](https://openai.com/chatgpt/download/)）
   - 👉 **[下載 Claude Code 桌面版官方安裝檔](https://claude.ai/download)**

---

## 我的 Mac 舊舊的，能跑嗎？

安裝程式一開始就會檢查你的 macOS 版本，自動選擇最合適的路線，不會讓你卡在半路：

| 你的 macOS | 會發生什麼事 |
| :-- | :-- |
| **14（Sonoma）以上** | 完整路線，全部走 Homebrew 自動管理，體驗最順暢。 |
| **13（Ventura）** | 自動改走備用路線：GitHub CLI 與 Claude Code 改用官方安裝器，結果完全一樣。 |
| **12 以下** | 終端機版 Claude Code 最低需要 macOS 13，安裝程式會引導你改用 **Claude 桌面版**（支援 macOS 11 以上），一樣能開始上課。 |

> [!TIP]
> 不確定自己的版本？點螢幕左上角蘋果選單  → 「關於這台 Mac」就看得到。

---

## 裝完之後：開始你的 AI 之旅

- **一般朋友**：打開你剛裝好的 Claude 或 Codex 桌面版，就能體驗直接在電腦裡指揮 AI 的強大能力！想系統化學習如何把 AI 調教成個人專屬分身？歡迎參考 👉 [超級 AI 個體免費體驗課](https://shifu.tw/course/trial/ai-agent-bootcamp)。
- **課程學員**：恭喜完成「步驟 0」！現在可以回到課程單元 1-2，打開 Pro-Kit 01 開始長出你的 AI 數位分身了。

---

<details>
<summary>給技術協作者的維護說明（學員可略過）</summary>

- **開源 SSOT**：[`claude-code-resources/env-installer/`](https://github.com/Raymondhou0917/claude-code-resources/tree/master/env-installer)。本課 `content/pro-kit/bootstrap/` 與其同步。
- `install-mac.sh` 是安裝邏輯與終端機文案的腳本正本；`.app` 打包、簽名與公證的工具鏈在 ShiFu 內部（打包時以本檔覆蓋其 `install-mac.sh` 並改 App 名稱後重建）。
- 定位是**開源版**（不綁課程內容、不連課程 repo）：只在**開場品牌**與**完成畫面 CTA** 導流到課程；`AD_URL` 一處改全部。
- 簽名＋公證過的 ZIP 直接發佈在本資料夾（`env-installer/`）；課程 repo 的 `content/pro-kit/bootstrap/dist/` 仍列入 `.gitignore`、不進 git。

</details>

---

## 相關資源

- 網站入口：[cc.lifehacker.tw](https://cc.lifehacker.tw)
- 體驗課／課程：[超級 AI 個體](https://shifu.tw/course/trial/ai-agent-bootcamp)
- 本 repo Starter Kit：[starter-kit/](../starter-kit/)
