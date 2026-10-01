# 安裝包更新紀錄

## 1.2.0 — 2026-10-01（開發分支，已簽名測試包／公證待完成）

- 保留四個勾選項目、原安裝順序與完成畫面。
- Intel 與 macOS 13–14 改用官方下載，不強制安裝 Homebrew；Rosetta 啟動時切回 Apple Silicon 原生程序。
- 補齊 GitHub CLI、Codex CLI、Claude 與 ChatGPT 桌面版的直接下載路線；不再因備用模式直接取消已勾選工具。
- Homebrew 或個別工具失敗後接續其他工具；完成畫面與 exit code 反映失敗及 AI PATH 驗證結果。
- 固定官方二進位版本與 SHA-256，App 複製前檢查架構、最低系統版本、簽名與 Gatekeeper；不覆蓋無法驗證的既有 App。
- ChatGPT 桌面版採官方 macOS 14 下限；無法安裝時保留失敗狀態。

## 維護與驗證

固定下載資訊在 `install-mac.sh`，來源為官方 GitHub Releases 及 Homebrew cask metadata（僅查下載 URL／SHA，不執行 cask 程式碼）。Claude Code 使用 Anthropic 官方安裝器。

```sh
bash -n env-installer/install-mac.sh
python3 -m unittest discover -s env-installer/tests -v
```

發布前必須完成 Intel 與 Apple Silicon 乾淨環境的全選安裝、重跑、Rosetta、網路失敗測試，以及 App ZIP 重建、Developer ID 簽名、公證與下載回驗。模擬測試不代表實機安裝完成。`preview/` 提供新版已簽名測試包；原正式 ZIP 未替換，待公證與實機驗證通過後再更新正式下載。

本次驗證：Bash 語法、diff 格式與 13 項隔離回歸測試通過。已核對官方 release／cask 的下載 URL 與 SHA-256；完整 Codex 發行包下載檢查未完成，尚無 Intel 實機或 App 開啟驗證。

上游依據：[Homebrew Intel 安裝限制](https://github.com/Homebrew/install/pull/1140)、[GitHub CLI 發行包](https://github.com/cli/cli/releases)、[Codex 發行包](https://github.com/openai/codex/releases)、[ChatGPT 系統需求](https://help.openai.com/en/articles/9275200-downloading-the-chatgpt-macos-app)。

封裝狀態與檔案雜湊見 [preview/README.md](./preview/README.md)。Apple 公證提交因必要協議未完成而回傳 HTTP 403，目前尚無公證票據。
