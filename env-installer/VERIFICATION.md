# 安裝包驗證紀錄

## 1.2.1（2026-11-02）

只改版號與 ZIP 封裝方式，安裝邏輯與 1.2.0 相同；launcher 沿用 1.2.0 已驗證的 universal binary。

- App 版本 1.2.1；ZIP 內安裝腳本與本分支來源逐位元一致。
- ZIP 不含 `._` 隱藏檔（12 個項目）。
- Developer ID 簽名、Apple 公證（Accepted）、staple。
- 最終 ZIP 分別用 `unzip`、`ditto -x -k`、帶 quarantine 的 `ditto -x -k` 三種方式解壓：`codesign --verify --deep --strict`、`stapler validate` 均通過，Gatekeeper 回覆 `accepted / Notarized Developer ID`。舊 1.2.0 ZIP 用 `unzip` 解壓會回 `a sealed resource is missing or invalid`。
- Bash 語法與 13 項隔離回歸測試通過。
- 實機安裝尚待驗證的項目同 1.2.0（見下方「尚待驗證」），這一版沒有另外做實機測試。

公證提交 ID：`e4e67ebb-dc49-4f85-81bf-638fd923a92e`

ZIP SHA-256：`6f8baf748a591a233f79ab4c57b4d09410c22cfa472f36dbebf01e9e14cf3e86`

安裝腳本 SHA-256：`4b82b7d261b11971599bd5933ffeb0f16d545836100e02144020bb6f6013cae8`

## 1.2.0（2026-10-01）

### 已通過

- App 版本 1.2.0；ZIP 內安裝腳本與本分支來源逐位元一致。
- Launcher：x86_64、arm64；最低 macOS 11，安裝腳本要求 macOS 13 以上。
- Developer ID 簽名、Apple 公證（Accepted）、staple。
- 最終 ZIP 重新解壓：`codesign --verify --deep --strict`、`stapler validate` 均通過，Gatekeeper 回覆 `accepted / Notarized Developer ID`。
- Bash 語法、diff 格式與 13 項隔離回歸測試通過。
- Claude、ChatGPT arm64／x86_64 官方下載 ZIP：完整下載、SHA-256、解壓、架構、簽名檢查通過；未啟動 App。

公證提交 ID：`982dd02e-6192-464c-a962-78ea91ea654e`

ZIP SHA-256：`6e9f36365fb914f765e9a05aa97b456dc7e91f65acf1d14c4ebcd1eeefb475ea`

安裝腳本 SHA-256：`c924edeee41722e1bbabe39b4ffdd27eafb4060b74460618d43498fc8cea74b4`

### 尚待驗證

- Intel、Apple Silicon 乾淨環境全選安裝及桌面 App 實際開啟。
- Rosetta 啟動、macOS 13、Homebrew 失敗備援與實機中斷重跑。
- GitHub CLI／Codex 完整發行包下載：本次連線中斷／逾時，未完成完整檔案驗證。來源 URL／預期 SHA 已核對，執行時仍會檢查 SHA；模擬測試不代表真實安裝成功。
- 補 Intel 分流及部分失敗、補裝完成畫面的真實截圖。

## 回驗方式

使用 `ditto -x -k` 或 `unzip` 解壓 ZIP（1.2.1 起兩者都應通過），再對其中 App 執行：

```sh
codesign --verify --deep --strict "雷蒙的 AI 基礎環境安裝包(MAC).app"
spctl -a -vvv -t exec "雷蒙的 AI 基礎環境安裝包(MAC).app"
xcrun stapler validate "雷蒙的 AI 基礎環境安裝包(MAC).app"
```

公證證明封裝通過 Apple 檢查，不代表所有硬體上的工具安裝均已實測。
