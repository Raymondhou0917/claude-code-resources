# 雷蒙推薦的 MCP 工具清單：Claude Code、Codex 都能用

> ⭐ 初學者友善｜Claude Code／Codex CLI／Codex 桌面版｜前三項約 3～5 分鐘，Google Workspace 是進階選裝

## 先講結論

MCP 不綁 Claude Code。只要你的 AI Agent 支援 MCP，同一套工具就能接到 Claude Code、Codex 終端機或 Codex 桌面版。

差別只有「在哪裡加入」：

- **Claude Code**：使用 `claude mcp add`。
- **Codex CLI**：使用 `codex mcp add`。
- **Codex 桌面版**：打開 Settings → MCP servers → Add server。Codex 桌面版、CLI 與 IDE 擴充套件共用設定，不必重裝三次。

先確認你正在用哪個入口，整份文件只走那一條路。不要看到兩組指令就全部執行。

## MCP 是什麼？

你可以把 MCP 想成 AI 的外接插座。接上不同工具後，AI 才能讀網頁、操作瀏覽器，或在你授權的範圍內使用 Google Workspace。

## 推薦清單

不用全部裝。先挑你真的需要的：

1. **Firecrawl**：把網頁轉成 AI 容易整理的文字。
2. **Filesystem**：讓 AI 存取你指定的其他資料夾。
3. **Playwright**：需要點按、登入或操作互動式網頁時使用。
4. **Google Workspace MCP**：讀 Gmail、Calendar、Drive、Docs、Sheets 等資料。設定較多，建議有明確需求再裝。

> [!IMPORTANT]
> MCP 會把外部服務的資料與操作權交給 AI。第一次先開最小範圍，能只讀就先只讀；需要建立、修改或寄送時，再逐項增加權限。

## 怎麼使用這份文件？

把網址丟給你現在使用的 AI Agent：

> 請先判斷我正在用 Claude Code、Codex CLI，還是 Codex 桌面版。介紹這份清單後問我要裝哪些；只設定目前這一套。偵測到既有 MCP 時先保留並合併，不要覆寫。

---

<!-- 以下是給 AI Agent 讀的設定指引 -->

## AI 執行共通規則

1. 先辨識 runtime，只選 Claude Code 或 Codex 一條路。
2. 先列出既有 MCP，避免重複安裝：Claude Code 用 `claude mcp list`；Codex 用 `codex mcp list`，桌面版也可在 Settings → MCP servers 查看。
3. 需要 API Key、OAuth 或資料夾路徑時要問用戶，不能猜。
4. 憑證只放本機設定或環境變數，不得寫入 Git repo、Markdown 或聊天回覆。
5. 安裝完成後，用不會改動資料的方式驗證；不要為了測試就寄信、刪檔或建立行程。

## 工具 1：Firecrawl

**適合：** 摘要文章、比較產品頁、把網頁表格整理成資料。

先請用戶到 [Firecrawl 官網](https://www.firecrawl.dev/) 建立自己的 API Key。不要把 Key 寫進公開專案。

### Claude Code

```bash
claude mcp add --scope user firecrawl \
  --env FIRECRAWL_API_KEY=YOUR_API_KEY \
  -- npx -y firecrawl-mcp
```

### Codex CLI

```bash
codex mcp add firecrawl \
  --env FIRECRAWL_API_KEY=YOUR_API_KEY \
  -- npx -y firecrawl-mcp
```

### Codex 桌面版

Settings → MCP servers → Add server：

- Name：`firecrawl`
- Type：`STDIO`
- Command：`npx`
- Args：`-y`、`firecrawl-mcp`
- Environment：`FIRECRAWL_API_KEY` 使用用戶自己的 Key

**驗證：** 請 AI 讀一篇公開文章並回傳標題與三點摘要。

## 工具 2：Filesystem

**適合：** 讓 AI 讀寫工作資料夾以外、但由你明確指定的目錄。

先問用戶要開放哪一個資料夾。新手先開一個工作資料夾即可，不要一開始把整個家目錄、桌面、下載與文件全部開放。

以下以 `YOUR_ALLOWED_FOLDER` 代表用戶自己選的絕對路徑。

### Claude Code

```bash
claude mcp add --scope user filesystem -- \
  npx -y @modelcontextprotocol/server-filesystem YOUR_ALLOWED_FOLDER
```

### Codex CLI

```bash
codex mcp add filesystem -- \
  npx -y @modelcontextprotocol/server-filesystem YOUR_ALLOWED_FOLDER
```

### Codex 桌面版

Settings → MCP servers → Add server：

- Name：`filesystem`
- Type：`STDIO`
- Command：`npx`
- Args：`-y`、`@modelcontextprotocol/server-filesystem`、用戶選定的絕對路徑

**驗證：** 使用 `list_allowed_directories` 確認只有剛才選的資料夾，再列出該資料夾第一層檔名。不要建立或刪除測試檔。

## 工具 3：Playwright

**適合：** 需要點按、填表、截圖或讀取互動式頁面時使用。

Playwright 能操作瀏覽器，也可能看到登入後的內容。先用隔離的瀏覽器資料，不要直接接管你平常使用、已登入私人帳號的瀏覽器。

### Claude Code

```bash
claude mcp add --scope user playwright -- \
  npx @playwright/mcp@latest --isolated
```

### Codex CLI

```bash
codex mcp add playwright -- \
  npx @playwright/mcp@latest --isolated
```

### Codex 桌面版

Settings → MCP servers → Add server：

- Name：`playwright`
- Type：`STDIO`
- Command：`npx`
- Args：`@playwright/mcp@latest`、`--isolated`

如果第一次執行提示缺少瀏覽器，再依錯誤訊息安裝 Chromium；不要先下載所有瀏覽器。

**驗證：** 開啟一個不需登入的公開網頁，讀出頁面標題後關閉測試瀏覽器。

## 工具 4：Google Workspace MCP（進階選裝）

**適合：** 讓 AI 在你授權的範圍內讀 Gmail、Calendar、Drive、Docs、Sheets、Slides 等服務。

這裡使用公開專案 [Google Workspace MCP Server](https://github.com/taylorwilsdon/google_workspace_mcp)。它是第三方開源工具，不是 Google 官方產品。設定牽涉 Google Cloud 與 OAuth，請預留 15～30 分鐘，不要把它當成一鍵安裝。

### 安全預設

第一次先用：

- `core`：只載入常用工具，避免一次塞入大量用不到的功能。
- `read-only`：先只讀，不允許寄信、改行程或改檔案。
- 只啟用你真的要用的 Google API。
- 每位學員建立自己的 Google Cloud Project 與 OAuth 憑證。

不能共用別人的 OAuth client、token、登入信箱、憑證快取或加密金鑰。這些資料也不能 commit 進 repo。

### Step 1：準備 Google OAuth

請 AI 依照上游的 [Google Cloud 與 OAuth 設定說明](https://github.com/taylorwilsdon/google_workspace_mcp#configuration) 帶用戶完成：

1. 建立或選擇自己的 Google Cloud Project。
2. 只啟用需要的 API，例如 Gmail、Calendar 或 Drive。
3. 建立自己的 OAuth Client，並設定對應的 redirect URI。
4. 把 OAuth Client ID、Client Secret 與簽章金鑰存進本機受保護的設定檔，檔案權限設為僅本人可讀；不能貼回聊天或寫進專案。

如果用戶使用全新 Google 帳號，或 OAuth 第一次失敗，先看錯誤訊息與 Test users 設定，不要連續重試。

### Step 2：啟動學員自己的 MCP

先安裝 [uv](https://docs.astral.sh/uv/)，再由用戶選一個未使用的本機連接埠。以下 `YOUR_PORT` 必須換成實際數字：

```bash
export MCP_ENABLE_OAUTH21=true
export GOOGLE_OAUTH_CLIENT_ID="YOUR_OWN_CLIENT_ID"
export GOOGLE_OAUTH_CLIENT_SECRET="YOUR_OWN_CLIENT_SECRET"
export WORKSPACE_MCP_PORT="YOUR_PORT"
export WORKSPACE_MCP_HOST="127.0.0.1"
export GOOGLE_OAUTH_REDIRECT_URI="http://localhost:YOUR_PORT/oauth2callback"
export OAUTHLIB_INSECURE_TRANSPORT=1
export FASTMCP_SERVER_AUTH_GOOGLE_JWT_SIGNING_KEY="YOUR_OWN_STABLE_RANDOM_KEY"

uvx workspace-mcp \
  --transport streamable-http \
  --tool-tier core \
  --read-only
```

`YOUR_OWN_STABLE_RANDOM_KEY` 只產生一次並安全保存。不要每次啟動都換，也不要把它放進 Git。

這個終端機視窗要保持執行；關掉後 MCP 就會停止。自動開機常駐屬於進階部署，Starter Kit 先不替學員建立背景服務。

### Step 3：接到目前的 Agent

把 `YOUR_PORT` 換成 Step 2 使用的數字。

#### Claude Code

```bash
claude mcp add --scope user --transport http \
  google-workspace http://127.0.0.1:YOUR_PORT/mcp
```

#### Codex CLI

```bash
codex mcp add google-workspace \
  --url http://127.0.0.1:YOUR_PORT/mcp
```

#### Codex 桌面版

Settings → MCP servers → Add server：

- Name：`google-workspace`
- Type：`Streamable HTTP`
- URL：`http://127.0.0.1:YOUR_PORT/mcp`

儲存後重新啟動，若畫面顯示需要 OAuth，選 Authenticate 並使用自己的 Google 帳號登入。

### Step 4：只讀驗證

先做一件不會改資料的事，例如：

> 列出我今天的行事曆標題，不要新增、修改或刪除任何內容。

確認穩定後，才依上游的權限表逐項升級，例如 Gmail 只開草稿，不直接開寄信；Drive 先只讀。不要為了方便直接切到 complete＋full。

## 選修：`gws` CLI，保留終端機補位

`gws` 仍有價值，但它**不是 MCP**，所以不再列為上面的 MCP 主方案。Claude Code 與 Codex 都能在終端機呼叫它，適合查 Google API、跑結構化指令，或在 MCP 暫時不可用時補位。

你要知道三件事：

1. 專案雖然放在 `googleworkspace` GitHub 組織，README 明確寫著「不是 Google 正式支援的產品」。
2. 它仍在 v1.0 之前，可能出現不相容更新。
3. `gws mcp` 曾經存在，但已在 v0.8.0 移除。這項變更可在 [gws 更新紀錄](https://github.com/googleworkspace/cli/blob/main/CHANGELOG.md#080) 查到，不要再把 `gws` 當 MCP Server 安裝。

需要時可依 [gws 上游文件](https://github.com/googleworkspace/cli) 安裝：

```bash
brew install googleworkspace-cli
# 或
npm install -g @googleworkspace/cli
```

登入時只選需要的服務：

```bash
gws auth login -s gmail,calendar,drive,sheets
```

`gws` 與 Google Workspace MCP 可以使用不同憑證設定。不要假設裝過其中一個，另一個就會自動取得權限。

## 安裝完成後

請 AI 回報：

1. 判斷到的入口是 Claude Code、Codex CLI，還是 Codex 桌面版。
2. 新增了哪些 MCP，哪些因為不需要而跳過。
3. 憑證存在哪一類本機設定中。只說位置與保護方式，不要顯示內容。
4. 用什麼只讀測試確認連線。
5. 哪些工具具有寫入能力，使用前要先取得確認。

查看連線狀態：

- Claude Code：`claude mcp list`，或在對話輸入 `/mcp`。
- Codex CLI：`codex mcp list`，或在 TUI 輸入 `/mcp`。
- Codex 桌面版：到 Settings → MCP servers 查看。

## 官方與上游參考

- [Claude Code MCP 文件](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [Codex MCP 文件](https://learn.chatgpt.com/docs/extend/mcp?surface=cli)
- [Firecrawl MCP 上游](https://github.com/firecrawl/firecrawl-mcp-server)
- [Filesystem MCP 上游](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)
- [Playwright MCP 上游](https://github.com/microsoft/playwright-mcp)
- [Google Workspace MCP 上游](https://github.com/taylorwilsdon/google_workspace_mcp)
- [gws CLI 上游與限制](https://github.com/googleworkspace/cli)

---

## 授權

- **License**：[CC BY-NC-SA 4.0](../LICENSE) · 個人使用、學習、分享自由；禁止商業用途
- **出處**：出自 [雷蒙三十 Starter Kit](https://cc.lifehacker.tw) | CC BY-NC-SA 4.0
- **商標**：「雷蒙三十」「雷蒙 Starter Kit」為品牌名，fork 版請用你自己的名字，不要冠上這些品牌販售
- **完整版教學** → [Claude Code 迷你課](https://cc.lifehacker.tw) | [雷蒙週報](https://raymondhouch.com/subscribe) | Threads [@raymond0917](https://www.threads.com/@raymond0917)

---

> 📖 更多設定 → [Starter Kit 目錄](README.md) | 🌐 [Claude Code 學習資源站](https://cc.lifehacker.tw)
