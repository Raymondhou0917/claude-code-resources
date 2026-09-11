# AI 誤刪怎麼辦？跨 Agent 安全三件套：垃圾桶＋危險指令黑名單＋權限護欄

> **ver. 2.0** ｜ **Last edited: 2026-09-11**
> ⭐ 初學者友善｜約 5 分鐘｜Claude Code／Codex 終端機／Codex 桌面版｜macOS／Windows 通用

## 先講結論

這套安全觀念不分 Claude Code 或 Codex，都有三層保險：

1. **第一層：刪檔先進垃圾桶** — AI 刪檔不再直接抹掉，而是移到垃圾桶（Mac 是廢紙簍，Windows 原生支援資源回收筒 API），誤刪隨時能救回來。
2. **第二層：危險指令黑名單** — `rm -rf`、`git reset --hard`、`git push --force` 這類「一執行就回不來」的指令，直接擋下，AI 會改用安全的做法。
3. **第三層：權限模式二選一** — **Auto**（代我核准，新手首選）或 **Bypass**（完整存取），減少大量跳窗打擾，同時把底線守死。

共同觀念一樣，**設定檔不一樣**。Claude Code 寫入 `~/.claude/settings.json` 與前置攔截 hook；Codex 寫入 `~/.codex/rules/default.rules` 與 `~/.codex/config.toml`。AI 會自動偵測你電腦裝了哪一套，兩邊都有就兩邊都設定好。

| | **Auto** （不確定就選這個） | **Bypass** （全部不問） |
| :-- | :-- | :-- |
| AI 什麼時候問你 | 日常小事直接做；看起來有風險的，會先停下來問你 | 什麼都不問，直接做 |
| 保護有幾層 | AI 自己先判斷一次，再加上垃圾桶和黑名單 | 只靠垃圾桶、黑名單和工作守則 |
| 適合誰 | 大多數人，剛開始用 AI Agent 的你 | 想要最快、清楚自己在做什麼的人 |
| 在 Codex 裡叫 | 代我核准 | 完整存取 |

---

## 怎麼裝？

把這份文件的內容或 GitHub 網址複製給你使用的 Claude Code 或 Codex，跟它說這段啟動詞就好：

```text
我是 AI 與程式的新手。請判斷我目前使用的 AI 工具（Claude Code / Codex）與作業系統（macOS / Windows），幫我安裝這份「AI 安全三件套」：
https://github.com/Raymondhou0917/claude-code-resources/blob/master/starter-kit/03-safe-delete.md

1. 請照文件裡的「AI 執行指引」直接幫我裝好，過程用繁體中文白話跟我說就好
2. 每次改動設定檔前請先備份，重跑時整段替換，不要重複堆疊
```

貼上之後，AI 只會問你一件事：要用 **Auto** 還是 **Bypass** 模式。選好後等它跑完（大約 5 分鐘），不用自己改設定。

---

<!-- 以下是給 AI Agent 讀的設定指引 -->

## AI 執行指引

> **🤖 給 AI 的互動規範**
>
> 1. **直接安裝，不要把工作丟回給用戶**。用戶是沒有程式背景的新手。系統、裝了哪些工具、目前在哪個工具裡，你自己查，不要問。不要請用戶切換模式、開終端機、打指令、做測試，也不要給他「驗證用 prompt」。
> 2. **修改前備份，重跑不重複**：每個設定檔先做時間戳備份。設定區塊用固定的起訖標記管理，已經存在就整段換新；其他設定一律保留。
> 3. **自己檢查，不交給用戶驗收**：每一步寫完，照該步驟的自我檢查確認格式正確、規則有效。失敗就還原備份，在最後的總結用一句白話說明哪一項沒裝成。
> 4. **全程繁體中文，白話、親切**。

### Step 0：安靜確認環境

- **系統**：`uname -s`（`Darwin`＝Mac；`MINGW`／`MSYS` 開頭＝Windows Git Bash；Windows PowerShell 用 `$env:OS`）。
- **工具偵測**：檢查家目錄是否有 `~/.claude` 與 `~/.codex`。兩者都有就兩者都裝。
- **詢問權限模式（唯一問題）**：詢問用戶要 `Auto` 還是 `Bypass`。Claude Code 用 `AskUserQuestion`；Codex 用純文字選項（1 或 2）。記下答案：`MODE=auto` 或 `MODE=bypassPermissions`。

---

### Step 1：垃圾桶機制

#### macOS / Linux：
1. 確認有 `trash` 指令：`command -v trash >/dev/null 2>&1 || brew install trash`（macOS 內建或 Homebrew 安裝）。
2. 在用戶 shell 設定檔（`~/.zshrc` 或 `~/.bashrc`）寫入別名保護日常指令：
   ```bash
   # >>> pro-kit-safe-rm >>>
   alias rm='trash'
   alias rm!='command rm'
   # <<< pro-kit-safe-rm <<<
   ```
3. AI 自己執行時一律直接使用 `trash <路徑>`。

#### Windows 原生環境（免裝第三方工具）：
Windows 內建資源回收筒 API，Step 4 會將以下 PowerShell 指令寫入 AI 守則，AI 日後要刪檔時會自動呼叫，檔案會直接進入「資源回收筒」：
`Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile("完整路徑", "OnlyErrorDialogs", "SendToRecycleBin")`
（資料夾改用 `DeleteDirectory`）。

---

### Step 2：Claude Code（有裝才做）

#### 2a. 快速通行、黑名單與權限模式
備份 `~/.claude/settings.json` 後，用 `jq` 合併。加入常用只讀與 Git 快速通行，並把危險指令加入 `deny`：

```bash
S="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude/hooks"
[ -f "$S" ] || printf '{}\n' > "$S"
cp "$S" "$S.backup.$(date +%Y%m%d-%H%M%S)"

jq '
  .permissions = (.permissions // {}) |
  .permissions.allow = ((.permissions.allow // []) - [
    "Bash(python3:*)", "Bash(python3 *)", "Bash(python *)", "Bash(node:*)", "Bash(node *)",
    "Bash(npm run:*)", "Bash(npm run *)", "Bash(npm test*)", "Bash(npm install:*)",
    "Bash(pnpm install)", "Bash(pip3 install:*)", "Bash(gh *)", "Bash(git checkout*)", "WebFetch(*)",
    "Bash(git push:*)"
  ]) |
  .permissions.deny = ((.permissions.deny // []) - [
    "Bash(git push*)", "PowerShell(git push*)", "Bash(git clean*)", "PowerShell(git clean*)",
    "Bash(git push *-f*)", "PowerShell(git push *-f*)"
  ]) |
  .permissions.allow = ((.permissions.allow + [
    "WebSearch", "WebFetch", "Bash(ls:*)", "Bash(cd:*)", "Bash(find:*)", "Bash(grep:*)",
    "Bash(cat:*)", "Bash(head:*)", "Bash(tail:*)", "Bash(wc:*)", "Bash(which:*)", "Bash(jq:*)",
    "Bash(git status)", "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)",
    "Bash(git branch)", "Bash(git ls-remote:*)", "Bash(git add:*)", "Bash(git commit:*)"
  ]) | unique) |
  .permissions.deny = ((.permissions.deny + [
    "Bash(rm)", "Bash(rm *)", "Bash(rmdir *)", "Bash(del *)", "Bash(erase *)", "Bash(rd *)",
    "Bash(Remove-Item *)", "PowerShell(Remove-Item *)", "Bash(rm -rf *)", "Bash(rm -fr *)",
    "Bash(rm -r *)", "Bash(rm -R *)", "Bash(rm -f *)", "Bash(sudo *)", "Bash(dd *)", "Bash(mkfs*)",
    "Bash(diskutil erase*)", "Bash(diskutil partitionDisk*)", "Bash(diskutil deleteVolume*)",
    "Bash(chmod 777 *)", "Bash(chmod -R 777 *)", "Bash(git reset --hard*)", "Bash(git reset *--hard*)",
    "Bash(git push --force*)", "Bash(git push *--force*)", "Bash(git push -f *)", "Bash(git push * -f*)",
    "Bash(git push --force-with-lease*)", "Bash(git push *--force-with-lease*)", "Bash(git clean -f*)",
    "Bash(git clean *-f*)", "Bash(git branch -D*)", "Bash(git branch *-D*)", "Bash(shutdown*)",
    "Bash(reboot*)", "Bash(: >*)", "Bash(truncate *)", "PowerShell(Remove-Item -Recurse *)",
    "PowerShell(Remove-Item *-Recurse*)", "PowerShell(Remove-Item -Force *)", "PowerShell(Remove-Item *-Force*)",
    "PowerShell(rm -Recurse *)", "PowerShell(rm *-Recurse*)", "PowerShell(Format-Volume *)",
    "PowerShell(Clear-Disk *)", "PowerShell(Remove-Partition *)", "PowerShell(Stop-Computer *)",
    "PowerShell(Restart-Computer *)", "PowerShell(diskpart *)", "PowerShell(format *)",
    "PowerShell(cmd /c rd *)", "PowerShell(cmd /c del *)", "PowerShell(git reset --hard*)",
    "PowerShell(git reset *--hard*)", "PowerShell(git push --force*)", "PowerShell(git push *--force*)",
    "PowerShell(git push -f *)", "PowerShell(git push * -f*)", "PowerShell(git push --force-with-lease*)",
    "PowerShell(git push *--force-with-lease*)", "PowerShell(git clean -f*)", "PowerShell(git clean *-f*)"
  ]) | unique) |
  (if $mode != "" then .permissions.defaultMode = $mode
   elif (.permissions.defaultMode // "") == "" then .permissions.defaultMode = "auto"
   else . end)
' --arg mode "${MODE:-}" "$S" > "$S.pro-kit-tmp" && mv "$S.pro-kit-tmp" "$S"
```

#### 2b. 執行前攔截器（PreToolUse hook）
建立 `~/.claude/hooks/pro-kit-block-dangerous-commands.sh`（權限 700），並登記進 `~/.claude/settings.json` 的 `hooks.PreToolUse`，攔截常規 rm 與不可逆破壞指令。

---

### Step 3：Codex（有裝才做）

#### 3a. 指令規則 `~/.codex/rules/default.rules`
管理 `# >>> pro-kit-dangerous-rules >>>` 區塊，設定不可逆指令一律 `decision = "forbidden"`（包含 rm/del/Remove-Item、sudo、dd、mkfs、diskutil erase、chmod 777、git reset --hard、git push --force、git clean -f、git branch -D、shutdown、truncate 等）。

#### 3b. 核准與沙盒策略 `~/.codex/config.toml`
在最頂部加入：
- **選 Auto**：
  ```toml
  # >>> pro-kit-02 permissions >>>
  approval_policy = "on-request"
  approvals_reviewer = "auto_review"
  sandbox_mode = "workspace-write"
  # <<< pro-kit-02 permissions >>>
  ```
- **選 Bypass**：
  ```toml
  # >>> pro-kit-02 permissions >>>
  approval_policy = "never"
  sandbox_mode = "danger-full-access"
  # <<< pro-kit-02 permissions >>>
  ```

---

### Step 4：寫入工作守則

Claude Code 寫入 `~/.claude/CLAUDE.md`，Codex 寫入 `~/.codex/AGENTS.md`：

```markdown
<!-- pro-kit-trash:start -->
## AI 安全三件套
- 刪除檔案或資料夾前，先確認這是用戶要刪的目標：
  - Mac：用 `trash <完整路徑>` 移到廢紙簍，不用 `rm`。
  - Windows：不用 rm、del、Remove-Item（會直接抹掉）。目標在本機硬碟（C:、D: 這類）時，用 PowerShell 移到資源回收筒：
    `Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile("完整路徑", "OnlyErrorDialogs", "SendToRecycleBin")`
    資料夾改用 `DeleteDirectory`。在 Git Bash 裡，把整段用單引號包起來交給 `powershell -NoProfile -Command`。
    不確定是不是本機硬碟，用 `[System.IO.DriveInfo]::new("E:\").DriveType` 看，是 `Fixed` 才用。網路磁碟、隨身碟，或這個指令失敗時，不要改用其他刪除方式；把完整路徑列給用戶，請他在檔案總管按 Delete。
- 要大量修改、搬移或刪除檔案前，如果資料夾有 Git，先在本機 commit 一次當存檔點，並告訴用戶可以回到這個版本。
- 被安全規則擋下時，改用可還原的做法，或回頭用白話問用戶；不要換成其他指令、腳本或程式碼繞過，也不要自己修改或關掉這些保護。
- 不做 force push、git reset --hard、git clean -f 這類會丟掉進度的操作。推送到用戶自己的私人備份 repo 可以照做；公開發布、正式上線或變更權限前，先問用戶。
- 日常的讀檔、查資料、寫檔、存版本直接完成，不必每一步都問；會影響別人或對外的動作，先用一句白話說明再做。
<!-- pro-kit-trash:end -->
```

---

### Step 5：白話總結

依實際裝好的內容調整，用親切白話告知用戶已完成安裝：
- 🗑️ 刪檔移至垃圾桶／資源回收筒
- 🚫 危險指令直接被黑名單攔截
- ⚡ 權限模式（Auto 或 Bypass）已生效
- 🧠 雷蒙工作守則已寫入，下次開啟對話即全面保護

---

## 授權

- **License**：[CC BY-NC-SA 4.0](../LICENSE) · 個人使用、學習、分享自由；禁止商業用途
- **出處**：出自 [雷蒙三十 Starter Kit](https://cc.lifehacker.tw) | CC BY-NC-SA 4.0
- **商標**：「雷蒙三十」「雷蒙 Starter Kit」為品牌名，fork 版請用你自己的名字，不要冠上這些品牌販售
- **完整版教學** → [Claude Code 迷你課](https://cc.lifehacker.tw) | [雷蒙週報](https://raymondhouch.com/subscribe) | Threads [@raymond0917](https://www.threads.com/@raymond0917)

---

> 📖 更多設定 → [Starter Kit 目錄](README.md) | 🌐 [Claude Code 學習資源站](https://cc.lifehacker.tw)
