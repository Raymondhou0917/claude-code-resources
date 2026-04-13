# 讓 Claude Code 的終端機更好用：不閃爍、能滾動、滑鼠能用、快速啟動

> ⭐ 初學者友善｜2 分鐘｜macOS / Linux / Windows

## 你可能遇過這些問題

用 Claude Code 的時候，你會覺得終端機很不友善：

- 想滾輪往上看剛剛的對話？畫面刷新了，內容不見了
- AI 回覆一長串程式碼時，畫面一直跳一直閃，看得眼睛很累
- 想用滑鼠選一段文字複製？選不到，或者選到的不是你要的
- 聊天越聊越久，整個終端機變得越來越慢、越來越吃記憶體

這些都不是 bug，是 Claude Code 預設的渲染模式導致的。好消息是，一行設定就能全部解決。

## 裝完之後你會得到

- **畫面穩定不閃爍** — AI 輸出再多程式碼，畫面也不會像抽搐一樣跳動
- **滾輪自由回看** — 對話再長都能滾回去看，滾上去時畫面會自動暫停、不會被新訊息拉回底部
- **滑鼠選取即複製** — 拖拉選取文字，放開滑鼠就自動複製；雙擊選一個詞，三擊選整行
- **滑鼠點擊可操作** — 點輸入框定位游標、點折疊區塊展開、點連結直接開瀏覽器、點檔案路徑直接開啟
- **輸入框固定在底部** — AI 工作時，輸入框不再被推來推去，始終釘在畫面最下方，像正常的聊天 App
- **長對話不卡頓** — 只渲染看得到的部分，記憶體佔用穩定不膨脹，聊再久都不會變慢
- **Page Up / Page Down 正常使用** — 鍵盤翻頁也通了（Mac 筆電用 `Fn+方向鍵`）
- **`cc` 兩個字一鍵啟動** — 不用每次打 `claude`，還能自動進到專案目錄

## 雷蒙當時的情況和選擇

我每天跟 Claude Code 對話超過 8 小時，一個 session 聊下來經常好幾百則訊息。預設模式下，聊到後面終端機開始明顯變慢，記憶體飆到 800MB 以上，畫面閃爍讓眼睛很累。最痛苦的是想回頭找剛剛 AI 給的指令，滾輪完全沒反應。

換成 NO_FLICKER 模式後，這些問題全部消失了。現在我兩台 Mac（Mac mini + MacBook）都設了 `cc` alias，打開終端機兩個字就進入工作狀態。Anthropic 內部團隊大多數人也已經改用這個模式，社群的評價是：「從終端機 hack 變成像原生 App 的體驗。」

## 怎麼裝？

把這份文件丟給 Claude Code，跟它說：

> 照這份文件幫我設定終端機，我的專案目錄是 `~/Projects/my-app`

或者直接往下看手動設定步驟。

---

<!-- 以下是給 Claude Code 讀的安裝指令 -->

## 安裝指令（AI 執行區）

### 前置確認

```bash
echo $SHELL
```

- `/bin/zsh` → 設定檔是 `~/.zshrc`（Mac 2019 年後預設）
- `/bin/bash` → 設定檔是 `~/.bashrc`

以下用 zsh 示範，bash 把 `.zshrc` 換成 `.bashrc`。

### 建立 `cc` alias（macOS / Linux）

**方案 A：綁定專案目錄**（請替換 `你的專案路徑`）：

```bash
echo "alias cc='cd ~/你的專案路徑 && CLAUDE_CODE_NO_FLICKER=1 claude'" >> ~/.zshrc && source ~/.zshrc
```

**方案 B：不綁目錄，純快速啟動**：

```bash
echo "alias cc='CLAUDE_CODE_NO_FLICKER=1 claude'" >> ~/.zshrc && source ~/.zshrc
```

---

### 建立 `cc` function（Windows 11 + WMUX）

> ⚠️ Windows 用戶注意：CMUX 目前不支援 Windows 11，請改用 **WMUX**。
> WMUX 安裝完成後，用以下步驟設定 `cc` 快速啟動。

Windows 的 PowerShell 不支援 `alias` 語法，改用 `function`，寫入 PowerShell Profile 讓每次開終端機都自動生效。

**步驟 1：用系統管理員身分打開 PowerShell**

開始功能表搜尋 `PowerShell` → 右鍵 → 「以系統管理員身分執行」

**步驟 2：允許執行自訂腳本**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

> 系統詢問時輸入 `Y` 確認。這是允許執行自己寫的腳本，不影響安全性。

**步驟 3：確認 Profile 檔案存在**

```powershell
if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
```

**步驟 4：加入 cc function**

方案 A：綁定專案目錄（替換 `C:\你的專案路徑`）：

```powershell
Add-Content $PROFILE "`nfunction cc { Set-Location 'C:\你的專案路徑'; `$env:CLAUDE_CODE_NO_FLICKER = '1'; claude @args }"
```

方案 B：不綁目錄，純快速啟動：

```powershell
Add-Content $PROFILE "`nfunction cc { `$env:CLAUDE_CODE_NO_FLICKER = '1'; claude @args }"
```

**步驟 5：重新載入 Profile**

```powershell
. $PROFILE
```

**步驟 6：驗證**

```powershell
# 確認 function 生效
Get-Command cc

# 啟動測試
cc
# Claude Code 啟動，畫面不閃爍 = 成功
```

> 💡 之後每次打開 PowerShell 或 WMUX，直接輸入 `cc` 即可啟動。

---

### 驗證（macOS / Linux）

```bash
# 確認 alias 生效
type cc
# 應顯示：cc is an alias for ...

# 啟動測試
cc
# Claude Code 啟動，滾輪可回看、畫面不閃爍 = 成功
```

### 技術說明：NO_FLICKER 模式（Fullscreen Rendering）

`CLAUDE_CODE_NO_FLICKER=1` 啟用 Claude Code 的新渲染引擎（v2.1.89+），改用差分渲染（只更新變化的字元），不再整螢幕重繪。

完整差異對照：

| 功能                  | 預設模式                | NO_FLICKER 模式                  |
| :-------------------- | :---------------------- | :------------------------------- |
| 畫面閃爍              | 每個 token 整螢幕重繪   | 差分渲染，穩定流暢               |
| 滑鼠滾輪回看          | ❌                       | ✅（滾上去自動暫停 auto-follow）  |
| Page Up / Down        | ❌                       | ✅                                |
| 滑鼠選取複製          | ❌ 需用終端機原生選取    | ✅ 拖選即複製，雙擊選詞，三擊選行 |
| 滑鼠點擊操作          | ❌                       | ✅ 點擊定位游標、展開折疊、開連結 |
| 輸入框位置            | 隨輸出移動              | 固定在底部                       |
| 記憶體佔用            | 越聊越多（可達 800MB+） | 恆定（只渲染可見訊息）           |
| 所有 Claude Code 功能 | 正常                    | 正常（無影響）                   |

### 可選：調整滾輪速度

如果覺得滾輪太慢，可以加上：

```bash
export CLAUDE_CODE_SCROLL_SPEED=3  # 範圍 1-20，預設值偏慢
```

### 搭配的實用快捷鍵

| 快捷鍵         | 功能                                               |
| :------------- | :------------------------------------------------- |
| `Ctrl+O` → `[` | 把完整對話匯出到終端機 scrollback，可 `Cmd+F` 搜尋 |
| `Ctrl+O` → `V` | 用編輯器打開完整對話                               |
| `Ctrl+O` → `/` | 在對話中搜尋關鍵字（`n`/`N` 跳下一個/上一個）      |

### 常見問題

**Q：聊天中途能開啟嗎？**
不行，需要退出後用 `cc` 重新啟動。但可以先按 `Ctrl+O` → `[` 把當前對話匯出。

**Q：Windows 也能用嗎？**
可以。Windows 11 請用 **WMUX**（CMUX 不支援 Windows），`cc` 的設定方式不同，詳見上方「建立 `cc` function（Windows 11 + WMUX）」區塊。

**Q：iTerm2 滾輪不動？**
需開啟 Mouse Reporting：Settings → Profiles → Terminal → Enable mouse reporting。

**Q：想保留終端機原生的滑鼠選取行為？**
設定 `CLAUDE_CODE_DISABLE_MOUSE=1`，但會失去點擊操作功能。

---

## 授權

- **License**：MIT · 自由使用、修改、分享。fork 或嵌入時請保留腳本 header 的作者資訊（MIT 基本要求）
- **商標**：「雷蒙三十」「雷蒙 Starter Kit」為品牌名，fork 版請用你自己的名字，不要冠上這些品牌販售
- **完整版教學** → [Claude Code 迷你課](https://cc.lifehacker.tw) | [雷蒙週報](https://raymondhouch.com/subscribe) | Threads [@raymond0917](https://www.threads.com/@raymond0917)

---

> 📖 更多設定 → [Starter Kit 目錄](README.md) | 🌐 [Claude Code 學習資源站](https://cc.lifehacker.tw)
