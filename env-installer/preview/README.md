# 1.2.0 測試包與驗證狀態

本資料夾為維護者驗證用途，**尚未完成 Apple 公證，不是正式學員下載包**。請勿要求學員停用 Gatekeeper 或移除隔離屬性來繞過系統檢查。

- [已簽名測試 ZIP](./raymond-ai-env-mac-v1.2.0.zip)
- 版本：1.2.0
- 啟動器架構：x86_64、arm64
- Developer ID 簽名及 ZIP 解壓回驗：通過
- ZIP 內腳本與本分支 `install-mac.sh`：逐位元一致
- Bash 語法、13 項隔離回歸測試：通過
- Apple 公證：提交回傳 HTTP 403，必要協議尚未生效；無票據
- Intel / Apple Silicon 乾淨環境完整安裝、Rosetta 實機流程：待驗證
- Claude 桌面版與 ChatGPT（arm64／x86_64）官方 ZIP：完整下載、SHA-256、解壓、架構及簽名驗證通過；未啟動 App
- GitHub CLI／Codex 發行包：下載連線中斷，完整驗證尚未通過；未宣稱所有工具可成功安裝

SHA-256：`1ab0b60b8972e236bf875e03e693b1441a3fb730184fced6330acc501bc3a5c9`

## 發布前補充證據

- [ ] Apple 公證、staple 及 ZIP 解壓後 Gatekeeper 驗證通過。
- [ ] Intel Mac：無 Homebrew，全選完成；確認桌面 App 可開啟、CLI 可執行。
- [ ] Apple Silicon：Homebrew 正常／失敗備援、Rosetta 啟動。
- [ ] macOS 13：ChatGPT 明確顯示不相容，其餘工具繼續。
- [ ] 中斷重跑、下載失敗、GitHub 登入失敗後可補裝。
- [ ] 補 Intel 自動分流及部分失敗的真實截圖。

正式公證包通過後，更新上層固定檔名的 ZIP，再移除本測試包，避免兩份下載互相混淆。
