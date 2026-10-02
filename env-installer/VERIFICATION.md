# 安裝包 1.2.0 驗證紀錄

驗證日期：2026-10-01。封裝驗證與實機安裝驗證分開記錄。

## 已通過

- App 版本 1.2.0；ZIP 內安裝腳本與本分支來源逐位元一致。
- Launcher：x86_64、arm64；最低 macOS 11，安裝腳本要求 macOS 13 以上。
- Developer ID 簽名、Apple 公證（Accepted）、staple。
- 最終 ZIP 重新解壓：`codesign --verify --deep --strict`、`stapler validate` 均通過，Gatekeeper 回覆 `accepted / Notarized Developer ID`。
- Bash 語法、diff 格式與 13 項隔離回歸測試通過。
- Claude、ChatGPT arm64／x86_64 官方下載 ZIP：完整下載、SHA-256、解壓、架構、簽名檢查通過；未啟動 App。

公證提交 ID：`982dd02e-6192-464c-a962-78ea91ea654e`

ZIP SHA-256：`6e9f36365fb914f765e9a05aa97b456dc7e91f65acf1d14c4ebcd1eeefb475ea`

安裝腳本 SHA-256：`c924edeee41722e1bbabe39b4ffdd27eafb4060b74460618d43498fc8cea74b4`

## 尚待驗證

- Intel、Apple Silicon 乾淨環境全選安裝及桌面 App 實際開啟。
- Rosetta 啟動、macOS 13、Homebrew 失敗備援與實機中斷重跑。
- GitHub CLI／Codex 完整發行包下載：本次連線中斷／逾時，未完成完整檔案驗證。來源 URL／預期 SHA 已核對，執行時仍會檢查 SHA；模擬測試不代表真實安裝成功。
- 補 Intel 分流及部分失敗、補裝完成畫面的真實截圖。

## 回驗方式

使用 `ditto -x -k` 解壓 ZIP，再對其中 App 執行：

```sh
codesign --verify --deep --strict "雷蒙的 AI 基礎環境安裝包(MAC).app"
spctl -a -vvv -t exec "雷蒙的 AI 基礎環境安裝包(MAC).app"
xcrun stapler validate "雷蒙的 AI 基礎環境安裝包(MAC).app"
```

公證證明封裝通過 Apple 檢查，不代表所有硬體上的工具安裝均已實測。
