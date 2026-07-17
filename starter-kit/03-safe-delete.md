# AI 誤刪怎麼辦？跨 Agent 安全三件套：垃圾桶＋危險指令黑名單＋權限護欄

> ⭐ 初學者友善｜約 5～10 分鐘｜Claude Code／Codex 終端機／Codex 桌面版｜macOS（Windows 見底部說明）

## 先講結論

這套安全觀念不分 Claude Code 或 Codex，都有三層：

1. 刪檔優先移到垃圾桶，誤刪還能救回來。
2. 把最危險、通常救不回來的指令直接擋掉。
3. 保留確認與沙盒。沙盒就是把 AI 的活動範圍關在工作資料夾裡。

共同觀念一樣，**設定檔不一樣**。Claude Code 要改 `~/.claude/settings.json`；Codex 要改 `~/.codex/rules/*.rules` 與 `~/.codex/config.toml`。請先確認你正在用哪一個產品，再走對應分支，不要一次把兩套設定都寫進電腦。

## 你會得到什麼

- **共同層：垃圾桶保護**。AI 刪除檔案時優先使用 `trash`，保留反悔空間。
- **Claude Code：Deny 黑名單**。命中危險寫法時直接拒絕。
- **Codex：`forbidden` 規則**。效果同樣是直接擋下，不跳過護欄。
- **各自的權限保護**。Claude Code 用權限模式；Codex 用沙盒與執行前確認。

> [!IMPORTANT]
> 安裝 `trash` 不會讓所有刪除自動變安全。AI 仍可能選到別的刪除方式，所以第二層黑名單和「刪除時優先用 `trash`」的指示不能省。

## 怎麼裝？

把這份文件的網址丟給你目前使用的 AI Agent，跟它說：

> 請先判斷我現在用的是 Claude Code、Codex CLI，還是 Codex 桌面版。只設定我正在用的這一套，照文件幫我裝安全三件套；每次改設定前先備份，完成後實際驗證。

---

<!-- 以下是給 AI Agent 讀的設定指引 -->

## AI 執行指引

### 第 0 步：只選一條路

先辨識目前入口：

- 終端機可用 `command -v claude` 與 `command -v codex` 輔助判斷。
- 如果正在 ChatGPT 桌面版的 Codex 模式，視為「Codex 桌面版」。
- 如果兩個指令都有，依照目前對話所在的產品選一個；不確定才問用戶一次。

**只修改所選產品的設定。** 除非用戶明確說兩套都要，否則不要同時寫 `~/.claude/` 和 `~/.codex/`。

每次寫檔都要先備份。不要整份覆寫既有設定，要合併進去並保留用戶原本的內容。

## Section A：共同層，讓刪除可以反悔

### A-1. 安裝並測試 `trash`

```bash
command -v trash || brew install trash
touch /tmp/test-safe-delete.txt
trash /tmp/test-safe-delete.txt
test ! -e /tmp/test-safe-delete.txt
```

如果沒有 Homebrew，先說明用途並取得同意，再引導安裝。不要為了省一步就改用永久刪除。

完成後告訴用戶：

> 第一層好了。之後我需要刪檔時會先用 `trash` 移到垃圾桶；真的需要永久刪除時，會先列出目標並請你確認。

這一層不代表 AI 永遠不能刪錯，後面還要安裝產品自己的黑名單。

## Section B：如果是 Claude Code

不是 Claude Code 就跳到 Section C。

### B-1. 備份並合併 Deny 規則

目標檔是 `~/.claude/settings.json`。先建立備份，再用 `jq` 合併，不能把原設定整份換掉。

```bash
mkdir -p ~/.claude
test -f ~/.claude/settings.json || printf '{}\n' > ~/.claude/settings.json
cp ~/.claude/settings.json ~/.claude/settings.json.backup.$(date +%Y%m%d-%H%M%S)
command -v jq >/dev/null || brew install jq

jq '
  .permissions = (.permissions // {}) |
  .permissions.deny = (((.permissions.deny // []) + [
    "Bash(rm -rf *)",
    "Bash(rm -fr *)",
    "Bash(rm -r *)",
    "Bash(rm -R *)",
    "Bash(rm -f *)",
    "Bash(sudo *)",
    "Bash(dd *)",
    "Bash(mkfs*)",
    "Bash(diskutil erase*)",
    "Bash(chmod 777 *)",
    "Bash(chmod -R 777 *)",
    "Bash(git reset --hard*)",
    "Bash(git push --force*)",
    "Bash(git push -f *)",
    "Bash(git clean -f*)",
    "Bash(git branch -D*)",
    "Bash(shutdown*)",
    "Bash(reboot*)",
    "Bash(: >*)",
    "Bash(truncate *)"
  ]) | unique)
' ~/.claude/settings.json > /tmp/claude-settings.new.json &&
mv /tmp/claude-settings.new.json ~/.claude/settings.json
```

### B-2. 選權限模式

先用互動選項詢問，不要替用戶直接開最高權限：

| 模式 | 白話說明 |
|:--|:--|
| `Accept Edits`（建議新手） | 改檔案可以直接做；執行指令時仍會在關鍵處詢問。 |
| `Default` | 多數動作都先問，最適合想觀察 AI 怎麼做的人。 |
| `Plan` | 只規劃、不動手，適合大改造前先看全貌。 |
| `Bypass` | 幾乎不詢問。風險最高，不能當新手預設。 |

依照選擇，把 `permissions.defaultMode` 合併成 `acceptEdits`、`default`、`plan` 或 `bypassPermissions`。若用戶選 Bypass，必須再確認一次，並說清楚黑名單只能擋常見寫法，不能保證攔住所有繞法。

### B-3. 驗證

```bash
jq '.permissions | {defaultMode, deny}' ~/.claude/settings.json
```

請用 `claude` 開新對話，再確認設定已載入。不要真的執行危險指令做測試。

## Section C：如果是 Codex CLI 或 Codex 桌面版

不是 Codex 就跳過本節。

Codex CLI、Codex 桌面版與 IDE 擴充套件共用 `~/.codex/` 設定。這裡要做兩件不同的事：

1. `.rules` 決定哪些指令永遠禁止。
2. `config.toml` 決定 AI 平常能碰哪些檔案，以及什麼時候要先問。

### C-1. 建立 `forbidden` 規則

先備份既有規則，再把缺少的規則合併到 `~/.codex/rules/default.rules`。不要刪掉原本的 allow／prompt 規則。

```python
# 高風險刪除
prefix_rule(
    pattern = ["rm", ["-rf", "-fr", "-r", "-R", "-f"]],
    decision = "forbidden",
    justification = "永久或遞迴刪除不可逆，請改用 trash 移到垃圾桶",
)

# 系統與磁碟
prefix_rule(pattern = ["sudo"], decision = "forbidden", justification = "請由本人在終端機手動處理系統管理操作")
prefix_rule(pattern = ["dd"], decision = "forbidden", justification = "打錯目標可能直接覆寫磁碟")
prefix_rule(pattern = ["mkfs"], decision = "forbidden", justification = "會格式化磁碟分區")
prefix_rule(pattern = ["diskutil", "erase"], decision = "forbidden", justification = "會清空磁區")

# Git 不可逆操作
prefix_rule(pattern = ["git", "reset", "--hard"], decision = "forbidden", justification = "會清掉未提交的工作，請先用 git stash 或建立 commit")
prefix_rule(pattern = ["git", "push", ["--force", "--force-with-lease", "-f"]], decision = "forbidden", justification = "會改寫遠端歷史，請由本人確認後手動執行")
prefix_rule(pattern = ["git", "clean", "-f"], decision = "forbidden", justification = "會刪除未追蹤檔案，請先列出目標")
prefix_rule(pattern = ["git", "branch", "-D"], decision = "forbidden", justification = "可能刪掉尚未合併的工作")

# 關機與清空檔案
prefix_rule(pattern = ["shutdown"], decision = "forbidden", justification = "AI 不應自行關機")
prefix_rule(pattern = ["reboot"], decision = "forbidden", justification = "AI 不應自行重新啟動電腦")
prefix_rule(pattern = ["truncate"], decision = "forbidden", justification = "會把檔案內容直接清空")
```

### C-2. 設定沙盒與確認方式

先備份 `~/.codex/config.toml`。如果已經有這兩個欄位，只修改既有值，不要重複新增；其他模型、通知、MCP 設定全部保留。

新手建議值：

```toml
sandbox_mode = "workspace-write"
approval_policy = "on-request"
```

白話說明：

- `workspace-write`：AI 可以處理目前工作資料夾，但不能任意寫進整台電腦。
- `on-request`：超出安全範圍時先問，不會默默把護欄關掉。
- 不建議新手使用 `danger-full-access` 加上 `never`。那等於活動範圍不設限，也不再詢問。

Codex 桌面版也可以從 Settings 檢查相關設定。檔案改完後要重新啟動 Codex，讓 `.rules` 與 `config.toml` 重新載入。

### C-3. 驗證規則，不執行危險指令

```bash
codex execpolicy check --pretty \
  --rules ~/.codex/rules/default.rules \
  -- git reset --hard
```

結果應顯示 `forbidden`。這只是在檢查規則，不會真的執行 `git reset --hard`。

## Section D：完成後怎麼回報

請用白話列出：

- 目前設定的是 Claude Code、Codex CLI，還是 Codex 桌面版。
- `trash` 是否安裝，以及測試是否成功。
- 寫入哪一套黑名單，以及備份檔位置。
- 權限模式或沙盒／確認設定。
- 實際跑過哪些不具破壞性的驗證。

不要宣稱「完全不可能誤刪」。這些規則擋的是常見錯誤，不是萬無一失的防毒軟體。重要專案仍然要用 Git、備份或雲端版本紀錄。

## 常見問題

### 我同時用 Claude Code 和 Codex，怎麼辦？

先把目前這一套設定好並驗證。之後再明確要求 AI 設定另一套。兩邊可以使用相同的安全原則，但設定內容要分別寫入自己的檔案。

### 為什麼不直接全部開到最高權限？

最高權限省掉的是幾次確認，代價是打錯路徑時少了煞車。先用建議設定，等你看懂哪些動作安全，再逐步放寬。

### Windows 怎麼辦？

建議在 WSL（Windows Subsystem for Linux）裡使用終端機 Agent，再安裝 Linux 的垃圾桶工具與對應設定。原生 PowerShell 的刪除方式不同，不要直接照抄 macOS 指令。

## 官方參考

- Claude Code：[權限與設定文件](https://code.claude.com/docs/en/permissions)
- Codex：[指令規則文件](https://learn.chatgpt.com/docs/agent-configuration/rules)
- Codex：[設定參考](https://learn.chatgpt.com/docs/config-file/config-reference)

---

## 授權

- **License**：[CC BY-NC-SA 4.0](../LICENSE) · 個人使用、學習、分享自由；禁止商業用途
- **出處**：出自 [雷蒙三十 Starter Kit](https://cc.lifehacker.tw) | CC BY-NC-SA 4.0
- **商標**：「雷蒙三十」「雷蒙 Starter Kit」為品牌名，fork 版請用你自己的名字，不要冠上這些品牌販售
- **完整版教學** → [Claude Code 迷你課](https://cc.lifehacker.tw) | [雷蒙週報](https://raymondhouch.com/subscribe) | Threads [@raymond0917](https://www.threads.com/@raymond0917)

---

> 📖 更多設定 → [Starter Kit 目錄](README.md) | 🌐 [Claude Code 學習資源站](https://cc.lifehacker.tw)
