# 終端機輸入大段內容時，無法編輯的解決方法：設定輕量外部編輯器 CotEditor

> ⭐ 初學者友善｜3 分鐘｜macOS（其他平台見備用方案）

## 你可能遇過這個問題

用終端機使用 Claude Code 時，貼入大段文字時輸入框會顯示「[Pasted text +20 lines]」，讓你無法再編輯 prompt？如果用語音轉文字輸入時，也無法去調整修正錯字？只能送出後再按 ESC 改？這些太痛苦，怎麼辦？

## 裝完之後你會得到

- **一鍵跳到編輯器** — 按 `Ctrl+G`，熟悉的編輯器就彈出來
- **用編輯器寫長 prompt** — 多行、分段、加標題，隨便你排版
- **語音輸入也能改** — 用 Typeless 等語音轉文字工具輸入後，在編輯器裡自由修正錯字、調整語句
- **存檔關閉自動送回** — `Cmd+S` 存檔 → `Cmd+W` 關閉，內容直接填回 Claude Code
- **支援各種編輯器** — CotEditor、VS Code、Cursor、Vim 都行

## 雷蒙當時的情況和選擇

我一開始用的是 VSCode 或 Antigravity 當編輯器（`code --wait`），但每次按 `Ctrl+G` 要等它啟動，太慢了。我的需求很簡單：按快捷鍵 → 馬上看到剛剛語音輸入的文字 → 快速改幾個錯字 → 存檔送回。不需要程式碼高亮、不需要 extension，只要快。

後來發現 **CotEditor**，Mac 上免費的輕量文字編輯器，啟動速度幾乎是瞬間。按下 `Ctrl+G` 的那一秒，編輯器就開好了，改完存檔關閉，prompt 就送回 Claude Code。整個流程不到三秒。

如果你也覺得 VS Code 太重、Vim 太難、純終端機輸入太痛苦，CotEditor 就是那個剛好的選擇。

## 怎麼裝？

把這份文件丟給 Claude Code，跟它說：

> 照這份文件幫我設定外部編輯器

或者直接往下看手動設定步驟。

---

<!-- 以下是給 Claude Code 讀的安裝指令 -->

## 安裝指令（AI 執行區）

以下以 CotEditor 為例。如果用戶指定其他編輯器，請跳到「備用方案」區塊。

### Step 1：安裝 CotEditor

Mac App Store 搜尋「CotEditor」→ 免費下載。需要用戶手動操作。

### Step 2：安裝 `cot` CLI

需要用戶手動操作：CotEditor → Settings（`Cmd+,`）→ General → 底部 **Install `cot` command to /usr/local/bin** → 點擊安裝。

驗證：

```bash
which cot
# 應顯示：/usr/local/bin/cot
```

### Step 3：建立 Wrapper Script

直接用 `cot --wait` 在某些終端環境下會回傳 exit code 1（見踩坑紀錄），Claude Code 會因此不採用編輯後的內容。需要一個 wrapper 強制 exit 0：

```bash
mkdir -p ~/.local/bin && cat > ~/.local/bin/cot-editor << 'SCRIPT'
#!/bin/bash
# Wrapper for cot --wait
# 忽略 AppleScript 錯誤（某些終端不支援視窗操作指令）
cot --wait "$@" 2>/dev/null
exit 0
SCRIPT
chmod +x ~/.local/bin/cot-editor
```

### Step 4：設定環境變數

```bash
# 確保 ~/.local/bin 在 PATH 中
grep -q 'HOME/.local/bin' ~/.zshrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# 設定 EDITOR
grep -q 'EDITOR=' ~/.zshrc || echo "export EDITOR='cot-editor'" >> ~/.zshrc

# 載入設定
source ~/.zshrc
```

驗證：

```bash
echo $EDITOR
# 應顯示：cot-editor
```

### Step 5：驗證流程

1. 啟動 Claude Code
2. 按 `Ctrl+G`
3. CotEditor 跳出來 → 隨便打幾個字
4. `Cmd+S` 存檔 → `Cmd+W` 關閉該檔案
5. 內容出現在 Claude Code 輸入框 = 成功

### 備用方案（其他編輯器）

| 編輯器  | EDITOR 設定                     | 備註                                                                                          |
| :------ | :------------------------------ | :-------------------------------------------------------------------------------------------- |
| VS Code | `export EDITOR='code --wait'`   | 功能最完整，但啟動較慢。需先安裝 `code` CLI（VS Code → Cmd+Shift+P → Install 'code' command） |
| Cursor  | `export EDITOR='cursor --wait'` | AI 編輯器，啟動速度同 VS Code                                                                 |
| Vim     | `export EDITOR='vim'`           | 終端機內完成，不需額外安裝，但學習曲線高                                                      |
| Nano    | `export EDITOR='nano'`          | 最簡單的終端機編輯器                                                                          |

備用快捷鍵：`Ctrl+X` → `Ctrl+E`（readline 傳統綁定，同樣功能）。

### 踩坑紀錄

**為什麼不直接用 `cot --wait`？**

`cot --wait` 在關閉檔案分頁後，會用 AppleScript 嘗試把「呼叫它的 app」拉回前方。如果 Claude Code 跑在不支援 AppleScript 視窗操作的終端（例如 cmux），就會回傳 exit code 1。Claude Code 看到非 0 的 exit code，就不採用編輯後的內容。Wrapper script 用 `2>/dev/null` 忽略錯誤，並強制 `exit 0` 解決。

**為什麼不用 `open -W -a CotEditor`？**

`open -W` 等待的是整個 CotEditor app 結束。如果 CotEditor 已經在背景開著，`open -W` 會立即返回，Claude Code 拿到的是未修改的空檔案。

---

## 授權

- **License**：MIT · 自由使用、修改、分享。fork 或嵌入時請保留腳本 header 的作者資訊（MIT 基本要求）
- **商標**：「雷蒙三十」「雷蒙 Starter Kit」為品牌名，fork 版請用你自己的名字，不要冠上這些品牌販售
- **完整版教學** → [Claude Code 迷你課](https://cc.lifehacker.tw) | [雷蒙週報](https://raymondhouch.com/subscribe) | Threads [@raymond0917](https://www.threads.com/@raymond0917)

---

> 📖 更多設定 → [Starter Kit 目錄](README.md) | 🌐 [Claude Code 學習資源站](https://cc.lifehacker.tw)
