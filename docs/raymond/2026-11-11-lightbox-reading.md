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

正式站讀回結果另於部署後補記。實體手機、Safari 與 VoiceOver 尚待實機驗證；CDP 觸控模擬不等同實機。

## 還原

revert 本次 CC 的 runtime／index 更新 commit，由既有 Cloudflare Pages Git integration 重部署。上一個正式版本為 `c36d0f2533d83485a821e5088ee906cf56c8ce08`，deployment `bce6e1f1-e4f7-4914-9b71-4761fa342823`。無資料庫、圖片或內容遷移。
