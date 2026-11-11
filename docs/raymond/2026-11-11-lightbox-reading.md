# CC Lightbox 閱讀融合版

本次依 Raymond 決定只更新 CC 學習資源站；Expo／Talk／Apps 不在這次部署範圍。

## 變更

1. 原閱讀位置的半透明暗色背景與 14 px blur，保留開啟／關閉的 morph。
2. 圖說置於圖片外，依 footer 實際高度保留至少 24 px 間距。
3. 點空白可關閉並回原捲動位置／來源焦點；圖片、圖說、縮圖、拖曳不誤關。
4. 保留既有 5 張見證圖庫、縮放、相鄰預覽／單張、鍵盤與觸控操作；首頁內容、圖片及 CTA 保持原樣。
5. 縮圖選取停用 element-scoped View Transition，避免窄版 Brave `Prepaint layout check failed`；仍保留縮圖捲動與開啟／關閉動畫，不攔截全域錯誤。

來源：brand-cis `1a32764`，`components/ramka-lightbox/`；Ramka 0.0.2。整組重建資產，bootstrap 版本 `20261111-reading-1`，仍按需載入。入口 1,471 bytes gzip，不以此宣稱一定比舊自製遮罩小。

## 驗收

隔離 Brave 1440 × 1000 與 430 × 932：逐一選取 5 張縮圖，索引與圖說一致；桌機圖說間距為 25／33／25／25／25 px，窄版為 208／260／203／172／152 px；背景為 0.58 alpha 與 14 px blur。圖片／圖說／拖曳不誤關，點空白關閉後捲動位置差 0 px 並還原來源焦點；兩種寬度皆無 uncaught error。

正式站 `https://cc.lifehacker.tw/`（無 query）於 2026-11-11 驗證通過：1440／430 px 全部 5 張圖索引、留白、blur、空白關閉及焦點還原皆正常，無 uncaught error。桌機點擊前／關閉後 scrollY 為 11128／11128；窄版以實際 pointerdown 時刻為基準，為 15159／15159。初測在自動捲入與實際點擊前就取值，遇正式站載入排版位移產生 52 px 差；修正量測時點後確認還原差 0 px。

共用 CC QA 14 項通過，含 lazy load、5 張縮圖、相鄰預覽、縮圖跳轉、單張切換、縮放、鍵盤／focus trap、Escape、CDP swipe／pinch／pull 與 reduced-motion／無 View Transitions 降級。首頁原碼逐字比較，除了 loader 的版本 query 完全相同。

Cloudflare production deployment `0b322d21-5d61-48c1-9cc4-ef3aa886ae34` 為 success，對應 merge commit `0b509c4d874fb34fac09ccdf10628ee9ac27bc44`。正式站 viewer 與已提交建置檔逐位元相同，SHA256 `ade19c3ec2bc8f9260de587a974e062826ee6a62f34decc1dbdb934086b8b9a7`。實體手機、Safari 與 VoiceOver 尚待實機驗證；CDP 觸控模擬不等同實機。

## 還原

revert 本次 CC 的 runtime／index 更新 commit，由既有 Cloudflare Pages Git integration 重部署。上一個正式版本為 `c36d0f2533d83485a821e5088ee906cf56c8ce08`，deployment `bce6e1f1-e4f7-4914-9b71-4761fa342823`。無資料庫、圖片或內容遷移。
