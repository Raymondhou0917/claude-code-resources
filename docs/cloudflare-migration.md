# Cloudflare 靜態站搬遷

日期：2026-10-10 America/Lima（台北 2026-10-11）。

## 部署與公開範圍

- 正式網址：https://cc.lifehacker.tw/，原網址、錨點、CTA、tracking 不變。
- Cloudflare Pages：`lifehacker-cc`；GitHub `master` push 自動 production build，其他分支 preview；PR comments 關閉。
- Build：`python3 scripts/build-public.py`，只發布 `dist/`。不需要 Node、API key、執行期伺服器或 Functions。
- 根檔案與子目錄 allowlist 在 script；不公開 `.git`、`.env`、scripts、docs、測試。新公開檔案須明確加 allowlist。
- 本機 dist 已存在時 build fail closed；先把舊 dist 移到 repo 外的暫存目錄，再重建。
- sitemap lastmod 取內容檔 Git commit 時間，重新部署不虛報更新。
- Pages 預覽／pages.dev 有 noindex header；正式 canonical 指向原網址。
- 真實 404：未存在路徑使用 404.html，不把未知 URL 回成首頁 200。

## SEO/AEO

保持全部可見內容，補穩定 H2 錨點與機器可讀資訊的一致性。canonical、OG、原有 GA／Meta Pixel 和外部表單行為保留。僅移除與可見頁面不相符的 schema（academy 隱藏 FAQ；cc 不存在的 SearchAction）。不承諾搜尋排名／AI 引用提升。

## 驗收與切換

待獨立 reviewer 檢查 preview、原文／CTA／資產一致、404／SEO／下載／表單（不送出），才綁原域與切 DNS。正式 HTTPS、Git push deployment、舊站停後仍健康均須驗收。Zeabur 保留專案與設定，只解除對應 Git trigger 並暫停服務。

## 還原

若切換有問題，先恢復原 Zeabur 服務與保存的 Git trigger，再依搬遷證據恢復原 DNS 記錄。先確認原站健康，才切回流量；不刪除 Cloudflare 專案。若僅內容 regression，Pages 可 rollback 到上一個健康 deployment。
