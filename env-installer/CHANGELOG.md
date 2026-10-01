# 安裝包更新紀錄

## 1.2.0 — 2026-10-01（已完成簽名、公證與 ZIP 封裝）

- 保留四個勾選項目、原安裝順序與完成畫面。
- Intel 與 macOS 13–14 改用官方下載，不強制安裝 Homebrew；Rosetta 啟動時切回 Apple Silicon 原生程序。
- 補齊 GitHub CLI、Codex CLI、Claude 與 ChatGPT 桌面版的直接下載路線；不再因備用模式直接取消已勾選工具。
- Homebrew 或個別工具失敗後接續其他工具；完成畫面與 exit code 反映失敗及 AI PATH 驗證結果。
- 固定官方二進位版本與 SHA-256，App 複製前檢查架構、最低系統版本、簽名與 Gatekeeper；不覆蓋無法驗證的既有 App。
- ChatGPT 桌面版採官方 macOS 14 下限；無法安裝時保留失敗狀態。

## 維護與驗證

版本號以 `install-mac.sh` 的 `VERSION` 為單一來源。固定官方二進位的 URL／SHA-256 亦在該檔；升版需重新核對官方發行來源。Claude Code 使用 Anthropic 官方安裝器。

```sh
bash -n env-installer/install-mac.sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s env-installer/tests -v
```

本版固定檔名 ZIP 已更新為 1.2.0，完成簽名、公證、staple 與解壓後驗證；詳細證據及尚待實機測試項目見 [VERIFICATION.md](./VERIFICATION.md)。

上游依據：[Homebrew Intel 安裝限制](https://github.com/Homebrew/install/pull/1140)、[GitHub CLI 發行包](https://github.com/cli/cli/releases)、[Codex 發行包](https://github.com/openai/codex/releases)、[ChatGPT 系統需求](https://help.openai.com/en/articles/9275200-downloading-the-chatgpt-macos-app)。
