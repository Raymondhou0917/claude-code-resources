# 環境安裝包（開源版）：一鍵把你的 Mac 調成「AI 友善」

> **ver. 3.0** ｜ **Last edited: 2026-07-21**
> ⭐ 初學者友善｜10～15 分鐘｜macOS（Windows 同學看[最下方](#windows-同學怎麼辦)）
> 這是「超級 AI 個體」課程出品的**開源環境安裝包**：不綁課程內容、給所有想開始用 AI Agent 的小白。**不是貼給 AI 的文件，而是一個雙擊就開始跑的安裝程式**，一口氣把電腦的 AI 環境裝好、設定好。本課學員把它當**步驟 0**，跑完再進 Pro-kit 01。

> **這裡就是開源正本**（`env-installer/`）。課程 repo 的 `content/pro-kit/bootstrap/` 與此同步，方便學員在課程路徑內找到。

---

## 它會幫你裝好什麼

**必裝地基**（自動處理，不用選）：

| # | 項目 | 用途 |
| :-- | :-- | :-- |
| 1 | git | 版本控制，AI 的「時光機」——記住每一步、隨時反悔 |
| 2 | Homebrew | Mac 的軟體管家，之後裝東西都靠它（macOS 13 備用路線會跳過） |
| 3 | GitHub CLI（`gh`） | 跟 GitHub 溝通的工具 |
| 4 | GitHub 登入 | 連結你的帳號——讓 AI 幫你備份、管理做出來的專案 |

**安裝路線**（開場選一條；直接 Enter＝只裝基礎）：

| 選項 | 會裝什麼 |
| :-- | :-- |
| **[1] Claude 路線** | Claude Code 終端機版 ＋ Claude 桌面版 App |
| **[2] ChatGPT／Codex 路線** | Codex CLI ＋ ChatGPT 桌面版 App |
| **[3] 兩套都裝** | 上面兩條一次到位（雙棲） |
| **[4] 只裝基礎環境** | 只有必裝地基；Agent 之後再補 |

已經裝好的項目會自動跳過，所以**重跑幾次都沒關係**——中途被打斷、或之後想換路線，再雙擊一次就好。完成畫面會依**實際結果**打勾，不會因為你選了某條路線就假裝裝好。跑完最後按一下 Enter，視窗會自己關掉。

> [!TIP]
> 桌面版 App 本身會提示更新，這個安裝包**不會**替你排程 `brew upgrade`，避免動到整台電腦其他軟體。

## 怎麼用

### 方法 A：雙擊 App（給新手）

1. 下載 `超級AI個體 環境安裝.zip`（簽名公證版由 ShiFu 打包後回填連結；開發測試可先跑下方腳本）。
2. 瀏覽器通常會自動解壓成 App，**雙擊它**。
3. 開場選路線 1／2／3／4，跟著終端機畫面走。中途可能請你輸入 Mac 密碼、或開瀏覽器登入 GitHub——都是正常流程。
4. 如果中途裝了系統的「命令列工具」：裝完後**再雙擊 App 一次**，會自動接續。

> [!WARNING]
> **常見的三個「看起來壞了，其實沒有」**
>
> - **輸入密碼時看不到字**：終端機的正常行為，打完直接按 Enter。
> - **畫面卡住不動**：那是在下載（Homebrew 那步最久，約 3～5 分鐘），不是當機。
> - **App 被系統擋下來**：已公證的正式版不會發生；若遇到，對 App 按**右鍵 → 打開**即可。

### 方法 B：熟手指令版（本機立刻可跑）

不想等 App 打包、或想讓你的 AI Agent 代跑，也可以直接執行本資料夾的 [`install-mac.sh`](./install-mac.sh)：

```bash
chmod +x install-mac.sh && ./install-mac.sh
```

| 參數 | 作用 |
| :-- | :-- |
| （無） | 互動安裝（開場選路線） |
| `--skip-auth` | 只裝工具，不登入 GitHub |

非互動執行（例如交給 AI Agent 代跑）時，**預設只裝基礎環境**，不會擅自幫你裝 Claude 或 Codex。

## 我的 Mac 舊舊的，能跑嗎？

安裝程式一開始就會檢查你的 macOS 版本，自動選路線，不會讓你卡在半路：

| 你的 macOS | 會發生什麼 |
| :-- | :-- |
| **14（Sonoma）以上** | 完整路線，全部走 Homebrew，體驗最順 |
| **13（Ventura）** | 自動改走「備用路線」：跳過 Homebrew（它已不完整支援 13），GitHub CLI 與 Claude Code 改用官方安裝器，結果一樣；桌面版 App 不代裝，結尾會給官方下載連結 |
| **12 以下** | 終端機版 Claude Code 最低需要 macOS 13，安裝程式會直接停下來，引導你改用 **Claude 桌面版**（支援 macOS 11 以上），一樣能開始用 AI |

> [!TIP]
> 不確定自己的版本？點螢幕左上角蘋果選單 → 「關於這台 Mac」就看得到。

## Windows 同學怎麼辦

Claude Code 原生支援 Windows 10（build 1809）以上，**不需要 WSL**。一鍵安裝包目前只有 Mac 版（Windows 版規劃中），先用下面三段指令，效果一樣。

打開「Windows PowerShell」（開始選單搜尋 PowerShell），依序貼上：

```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
irm https://claude.ai/install.ps1 | iex
```

若你走 ChatGPT／Codex 路線，可再裝：

```powershell
winget install --id OpenAI.Codex -e
```

（若 winget 找不到套件，改看 [Codex 官方說明](https://chatgpt.com/codex/)／ChatGPT 桌面 App。）

裝完後關掉 PowerShell 再開一個新的，登入 GitHub：

```powershell
gh auth login
```

照畫面選 `GitHub.com → HTTPS → Login with a web browser`，把顯示的 one-time code 貼進瀏覽器就完成了。

> [!TIP]
> `winget` 是 Windows 內建的軟體管家（Windows 10 新版與 Windows 11 都有）。如果提示找不到 `winget`，先到 Microsoft Store 更新「應用程式安裝程式（App Installer）」再重試。

## 裝完之後

- **一般使用者**：依你選的路線，在終端機打 `claude` 或 `codex`，或打開對應桌面 App。想學怎麼把 AI 練成你的分身、用中文指揮它處理工作？體驗課／課程入口 → [超級 AI 個體體驗課](https://shifu.tw/course/trial/aibootcamp)
- **本課學員**：回到課程單元 1-2「開始安裝配置你的 AI Agent」，把 Pro-kit 01 丟給你的 AI，開始長出你的 AI 分身。

<details>
<summary>給協作者的維護說明（學員可略過）</summary>

- **開源 SSOT**：[`claude-code-resources/env-installer/`](https://github.com/Raymondhou0917/claude-code-resources/tree/master/env-installer)。本課 `content/pro-kit/bootstrap/` 與其同步。
- `install-mac.sh` 是安裝邏輯與終端機文案的腳本正本；`.app` 打包、簽名與公證的工具鏈在 ShiFu 內部（打包時以本檔覆蓋其 `install-mac.sh` 並改 App 名稱後重建）。
- 定位是**開源版**（不綁課程內容、不連課程 repo）：只在**開場品牌**與**完成畫面 CTA** 導流到課程；`AD_URL` 一處改全部。
- 簽名＋公證過的 ZIP 不進 git（`bootstrap/dist/` 已列入 `.gitignore`）。
- 改文案／流程只動 `install-mac.sh`；改版時同步更新本檔開頭的 `ver.`、開源 repo，以及課程 1-2 相關段落。

</details>

---

## 相關資源

- 網站入口：[cc.lifehacker.tw](https://cc.lifehacker.tw)
- 體驗課／課程：[超級 AI 個體](https://shifu.tw/course/trial/aibootcamp)
- 本 repo Starter Kit：[starter-kit/](../starter-kit/)
