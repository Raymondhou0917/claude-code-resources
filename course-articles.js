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

如果你是 Mac，可以用我們開源的一鍵環境安裝包：裝 git、Homebrew、GitHub，再開場選 Claude／Codex／兩套都裝／只裝基礎。

→ 同一頁下方第二則免費導讀，或直接看 GitHub：  
[env-installer 使用說明](https://github.com/Raymondhou0917/claude-code-resources/tree/master/env-installer)

想系統性把 AI 練成自己的分身：  
[超級 AI 個體｜體驗課](https://shifu.tw/course/trial/aibootcamp)

---

## 延伸閱讀

- 課程附錄級地圖（產品名會變，以官方為準）：可對照 Claude Code × ChatGPT Codex 雙棲說法
- 完整比較若你還在選工具：可再讀雷蒙站上的 Claude／Cowork／NotebookLM 相關長文

*產品名稱變很快；這篇講的是「聊天 → Agent」的方向，細節以各官網為準。*
`,

  lesson2: `# Mac 一鍵環境安裝包：把電腦調成 AI 友善基地

這是「超級 AI 個體」課程開源的 **步驟 0**：給所有想開始用 AI Agent 的人，不綁付費內容。

雙擊（或跑一支腳本）大約 10～15 分鐘，把地基裝好；Agent 要 Claude 還是 Codex，開場自己選。

---

## 它會裝什麼

**必裝地基（自動）**

1. git（版本控制／時光機）
2. Homebrew（Mac 軟體管家；舊系統可能走備用路線）
3. GitHub CLI（\`gh\`）
4. GitHub 登入

**開場選一條路線**

| 選項 | 內容 |
|:--|:--|
| **[1] Claude** | Claude Code ＋ Claude 桌面版 |
| **[2] ChatGPT／Codex** | Codex CLI ＋ ChatGPT 桌面版 |
| **[3] 兩套都裝** | 雙棲一次到位 |
| **[4] 只裝基礎** | 只有地基；Agent 之後再補 |

直接按 Enter＝只裝基礎。已經裝過的會自動跳過，可重跑。  
完成畫面依**實際結果**打勾，不會假裝成功。

> 桌面版自己會提示更新；安裝包**不會**幫你排程 \`brew upgrade\`。

---

## 怎麼用

### 新手：等簽名 App（正式下載）

簽名＋公證的 \`超級AI個體 環境安裝.zip\` 打包完成後會放在本 repo Release／說明頁。解壓後**雙擊 App**，選路線，跟著畫面走即可。

### 現在就能跑（熟手／開發預覽）

在本機 clone 這個 repo 後：

\`\`\`bash
cd env-installer
chmod +x install-mac.sh
./install-mac.sh
\`\`\`

只要工具、不登入 GitHub：

\`\`\`bash
./install-mac.sh --skip-auth
\`\`\`

完整說明：[env-installer/README.md](https://github.com/Raymondhou0917/claude-code-resources/blob/master/env-installer/README.md)

---

## 常見「以為壞了」

- **打密碼沒有字**：正常，打完按 Enter。
- **畫面卡住**：多半在下載（Homebrew 最久約 3～5 分鐘）。
- **系統擋 App**：未公證的測試檔，對 App 按右鍵 → 打開。

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

細節見 README 的 Windows 段落。

---

## 裝完之後

- 終端機打 \`claude\` 或 \`codex\`（依你選的路線），或開對應桌面 App。
- 想把 AI 練成自己的分身： [超級 AI 個體體驗課](https://shifu.tw/course/trial/aibootcamp)
- 觀念還沒搞懂？先看同一頁第一則免費導讀：〈AI Agent 是什麼？〉
`
};
