// 免費試看文章內容
window.ARTICLES = {
  lesson1: `# AI Agent 是什麼？為什麼連 OpenAI 都把 ChatGPT 砍了？

你一定用過 ChatGPT 或 Claude 網頁：問一句、答一句。

但 2026 年大廠真正在推的，已經不是「更好的聊天框」，而是 **AI Agent**：能讀你的檔案、用工具、把一整件事做完的代理人。

這篇用最白話講清楚三件事：Agent 是什麼、跟聊天差在哪、為什麼連 OpenAI 都把舊的 ChatGPT 桌面程式整併掉。

---

## 先講結論

| | 聊天型 AI（Lv1） | AI Agent（Lv3） |
|:--|:--|:--|
| **像什麼** | 顧問：給你答案 | 實習生：接手任務 |
| **你在做什麼** | 一直問、一直複製貼上 | 給目標、給規則，讓它跑 |
| **典型入口** | ChatGPT 的 Chat、claude.ai 網頁 | Claude Code、ChatGPT 的 Codex／Work |

一句話：**聊天是「給你答案」；Agent 是「幫你做事」。**

---

## 為什麼說 OpenAI「把 ChatGPT 砍了」？

2026 年 7 月起，OpenAI 將官方桌面端以 Codex 為主體，將 AI 應用的主力方向調整成 AI Agent。

原本大家習慣的純聊天型 AI（ChatGPT），被改名為「ChatGPT Classic」（傳統版）。

這款新的桌面版應用，已整合了 Codex 的功能，主要提供兩大模式：

- **Work／Codex**：Agent 模式（規劃、用工具、交成果），吃獨立的訂閱額度
- **Chat**：問答（你熟悉的聊天，變成輔助任務執行用）

Anthropic 也一樣：從網頁聊天，走到桌面、Cowork、再到 **Claude Code** 這種能動本機專案的 Agent。

大廠的共識很清楚：

> 把「專門寫程式的 Coding Agent」變成「通用 AI 代理人」。

模型當然還在變強，但真正拉開差距的，是你有沒有一套**能替你執行任務的 Agent**。

---

## 三層地圖：你現在站在哪？

不用背產品名，先分層：

**Lv1｜聊天型**  
代表：ChatGPT 的 Chat、claude.ai。  
適合：臨時問一句。你的角色是操作員，每一步都要自己下指令。

**Lv2｜協作型**  
代表：NotebookLM、Claude Cowork、做簡報／整理文件的 AI。  
適合：丟進多份資料，一起完成一個領域任務。你的角色是管理者。

**Lv3｜代理型（本篇重點）**  
代表：**Claude Code**、**ChatGPT Codex**（或日常用 Work）。  
適合：丟一個完整目標，讓它規劃步驟、用工具、交成果。你的角色是定規則、驗收結果。

Lv3 學會之後，Lv1／Lv2 的能力通常都涵蓋得到，還多出「真的能接手工作」的那一層。

---

## Agent 到底是什麼？（不是更強的模型）

常見迷思：**Agent ≠ 比較強的 LLM**。

Claude、GPT、Gemini 是大腦（模型）。Agent 是一套運作方式：

> **Agent = LLM（大腦）＋ Harness（規則與工作環境）＋ Tools（手腳）**

Harness 白話說就是：員工手冊、資料怎麼放、做事流程、能不能動哪些檔案。  
模型人人租得到；真正屬於你的，是你替它設計的那套工作環境。

---

## 我該選 Claude 還是 ChatGPT？

短期不用焦慮「選錯廠牌」：

1. **先選一個約 USD 20 的方案試一個月**（常見起點：Claude Pro 或 ChatGPT Plus）。
2. **拿不定主意就兩個都試**，用一陣子比看十篇評測準。
3. 新手入口常見是：
   - Claude → **Claude 桌面 App**／Claude Code
   - OpenAI → **ChatGPT 桌面 App** → 開 **Codex** 或 **Work**

兩邊概念同一套；檔名與介面不同（例如規則檔一邊叫 \`CLAUDE.md\`，一邊常寫 \`AGENTS.md\`）。

---

## 下一步：先把電腦變成「AI 友善基地」

觀念對了，再來裝工具。

如果你是 Mac，可以用我們開源的一鍵環境安裝包：裝 git、Homebrew、GitHub，再開場用 checkbox 勾選要裝的 Claude／Codex 桌面版或終端機版。

→ 同一頁下方第二則免費導讀（含圖解截圖），或直接看 GitHub：  
[env-installer 使用說明](https://github.com/Raymondhou0917/claude-code-resources/tree/master/env-installer)

想系統性把 AI 練成自己的分身：  
[超級 AI 個體｜體驗課](https://shifu.tw/course/trial/ai-agent-bootcamp)

---

## 延伸閱讀

- 課程附錄級地圖（產品名會變，以官方為準）：可對照 Claude Code × ChatGPT Codex 雙棲說法
- 完整比較若你還在選工具：可再讀雷蒙站上的 Claude／Cowork／NotebookLM 相關長文

*產品名稱變很快；這篇講的是「聊天 → Agent」的方向，細節以各官網為準。*
`,

  lesson2: `# Mac 一鍵環境安裝包：把電腦調成 AI 友善基地

這是「超級 AI 個體」課程開源的 **步驟 0**：給所有想開始用 AI Agent 的人，不綁付費內容。

雙擊 App 大約 10～15 分鐘，把地基裝好；開場用 checkbox 勾選要裝的 Claude／Codex（可複選）。下面每一步都有截圖，照著做即可。

---

## 它會裝什麼

**必裝地基（自動）**

1. git（版本控制／時光機）
2. Homebrew（Mac 軟體管家；舊系統可能走備用路線）
3. GitHub CLI（\`gh\`）
4. GitHub 登入

**挑你要裝的 AI 工具**（↑↓ 移動、空白鍵勾選、可複選；都不勾＝只裝基礎）

| 選項 | 說明 |
|:--|:--|
| ☐ Claude 桌面版 | Claude 官方桌面 App |
| ☐ Claude 終端機版 | Claude Code |
| ☐ ChatGPT 桌面版 | ChatGPT 官方桌面 App |
| ☐ Codex 終端機版 | Codex CLI |

已經裝過的會自動跳過，可重跑。完成畫面依**實際結果**打勾，不會假裝成功。

> 桌面版自己會提示更新；安裝包**不會**幫你排程 \`brew upgrade\`。

---

## 下載

已簽名＋公證的 Mac 安裝包：

→ [下載「雷蒙的 AI 基礎環境安裝包(MAC).zip」](env-installer/%E9%9B%B7%E8%92%99%E7%9A%84%20AI%20%E5%9F%BA%E7%A4%8E%E7%92%B0%E5%A2%83%E5%AE%89%E8%A3%9D%E5%8C%85%28MAC%29.zip)

文字版與 Windows 做法：[env-installer/README.md](https://github.com/Raymondhou0917/claude-code-resources/blob/master/env-installer/README.md)

---

## 圖解操作步驟

跟著截圖走。中途只會請你「輸入 Mac 密碼」和「開瀏覽器登入 GitHub」，都是正常關卡。

### 一、下載到打開

**1. 解壓縮**：下載到的 zip，瀏覽器通常會自動解壓成 App（沒有的話雙擊它）。

![解壓縮下載的 zip](env-installer/images/01-download-unzip.webp)

**2. 雙擊 App**：解壓後會出現星光背包圖示的 App，雙擊它。

![雙擊 App](env-installer/images/02-open-app.webp)

**3. 打開**：已簽名＋公證，系統顯示「已檢查，未偵測到惡意軟體」時按「打開」。

![確認打開](env-installer/images/03-gatekeeper-allow.webp)

### 二、開場：挑你要裝的 AI 工具

基礎環境一定會裝。AI 工具用 **↑↓ 移動、空白鍵勾選（可複選）、Enter 確認**；都不勾＝只裝基礎環境。

![勾選要裝的 AI 工具](env-installer/images/04-select-tools.webp)

### 三、基礎環境

**5. 輸入 Mac 密碼**：安裝 Homebrew 時會請你輸入電腦密碼。打字時看不到字是正常的，打完按 Enter。

![輸入 Mac 密碼](env-installer/images/05-enter-mac-password.webp)

**6. 按 Enter 繼續**：Homebrew 會列出要安裝的位置，按 Enter 讓它繼續。這一站最久，約 3～5 分鐘，畫面卡著是在下載、不是當機。

![Homebrew 按 Enter 繼續](env-installer/images/06-homebrew-continue.webp)

### 四、登入 GitHub

**7. 開始 GitHub 登入**：進到「GitHub 登入」這一站，跟著往下選。

![GitHub 登入引導](env-installer/images/07-github-login-overview.webp)

**8. 選 GitHub.com**：用方向鍵選 \`GitHub.com\`。

![選 GitHub.com](env-installer/images/08-github-choose-host.webp)

**9. 選 HTTPS**：協定選 \`HTTPS\`。

![選 HTTPS 協定](env-installer/images/09-github-choose-protocol.webp)

**10. 複製一次性驗證碼**：終端機會顯示一組 one-time code，先複製起來，按 Enter 會自動開瀏覽器。

![複製一次性驗證碼](env-installer/images/10-github-copy-code.webp)

**11. 瀏覽器：Device Activation**：瀏覽器打開後按「Continue」。

![Device Activation](env-installer/images/11-browser-device-activation.webp)

**12. 貼上驗證碼**：把剛剛複製的驗證碼貼進去，按 Continue。

![貼上驗證碼](env-installer/images/12-browser-paste-code.webp)

**13. 授權**：確認權限後按綠色的「Authorize github」。

![授權 GitHub CLI](env-installer/images/13-browser-authorize.webp)

**14. 連結完成**：看到「Congratulations, you're all set!」就代表登入好了，可關掉瀏覽器回到終端機。

![連結完成](env-installer/images/14-browser-connected.webp)

### 五、其他工具與完成

**15. 繼續安裝你勾選的工具**：接著會自動裝你勾的 AI 工具，跟著跑就好。

![安裝其他工具](env-installer/images/15-install-other-tools.webp)

**16. 完成**：最後畫面會依**實際結果**逐項打勾。看到這張就全部裝好了，按 Enter 關閉視窗即可。

![完成安裝](env-installer/images/16-done.webp)

---

## 常見「以為壞了」

- **打密碼沒有字**：正常，打完按 Enter。
- **畫面卡住**：多半在下載（Homebrew 最久約 3～5 分鐘）。
- **系統擋 App**：已公證的正式版通常不會；若遇到，對 App 按右鍵 → 打開。

---

## 舊 Mac？

| macOS | 行為 |
|:--|:--|
| 14+ | 完整 Homebrew 路線 |
| 13 | 自動改官方安裝器備用路線 |
| 12 以下 | 友善停止，導向 Claude 桌面版 |

---

## Windows

一鍵 App 還沒有。PowerShell 可先：

\`\`\`powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
irm https://claude.ai/install.ps1 | iex
gh auth login
\`\`\`

細節見 [README 的 Windows 段落](https://github.com/Raymondhou0917/claude-code-resources/blob/master/env-installer/README.md#windows-%E5%90%8C%E5%AD%B8%E6%80%8E%E9%BA%BC%E8%BE%A6)。

### 熟手：直接跑腳本

\`\`\`bash
cd env-installer
chmod +x install-mac.sh
./install-mac.sh
\`\`\`

只要工具、不登入 GitHub：\`./install-mac.sh --skip-auth\`  
指定工具、不進選單：\`./install-mac.sh --tools=claude|codex|both|base\`

---

## 裝完之後

- 依你勾選的工具，終端機打 \`claude\` 或 \`codex\`，或開對應桌面 App 登入。
- 想把 AI 練成自己的分身：[超級 AI 個體體驗課](https://shifu.tw/course/trial/ai-agent-bootcamp)
- 觀念還沒搞懂？先看同一頁第一則免費導讀：〈AI Agent 是什麼？〉
`
};
