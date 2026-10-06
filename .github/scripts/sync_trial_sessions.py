#!/usr/bin/env python3
"""
從 shifu.tw 體驗課頁同步「免費線上體驗課」場次與報名人數到 index.html。

只改兩個地方，其他內容一律不碰：
  1. <!-- trial-sessions:start --> 與 <!-- trial-sessions:end --> 之間的場次 <li>
  2. <span class="bootcamp-side-count">…</span> 的報名人數

抓不到、格式對不上、場次是 0 筆，一律 exit 1 且不寫檔——網站維持原樣，workflow 會標成失敗。
場次過期的隱藏交給前端 JS（index.html 底部），所以就算某天沒跑，網站也不會掛著過期場次。

用法：
  python3 .github/scripts/sync_trial_sessions.py              # 抓線上頁、有變才寫檔
  python3 .github/scripts/sync_trial_sessions.py --dry-run    # 只印結果不寫檔
  python3 .github/scripts/sync_trial_sessions.py --source page.html   # 用本機 HTML 測試
"""

import argparse
import datetime as dt
import html
import os
import re
import sys
import time
import urllib.request

URL = "https://shifu.tw/course/trial/ai-agent-bootcamp"
INDEX = os.path.join(os.path.dirname(__file__), "..", "..", "index.html")
TPE = dt.timezone(dt.timedelta(hours=8))
WEEKDAYS = "一二三四五六日"

BLOCK_RE = re.compile(
    r"(?P<indent>[ \t]*)<!-- trial-sessions:start(?P<note>[^>]*)-->.*?<!-- trial-sessions:end -->",
    re.S,
)
COUNT_RE = re.compile(r'(<span class="bootcamp-side-count">)[^<]*(</span>)')


class SyncError(Exception):
    pass


def fetch(url: str) -> str:
    last = None
    for attempt in range(3):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (cc.lifehacker.tw trial sync)"})
            with urllib.request.urlopen(req, timeout=30) as r:
                return r.read().decode("utf-8", errors="replace")
        except Exception as e:  # 網路抖動重試兩次
            last = e
            time.sleep(5 * (attempt + 1))
    raise SyncError(f"抓不到 shifu.tw 頁面：{last}")


def parse_sessions(page: str, today: dt.date):
    """每個場次在 <div class="trial-date-time">📍日期：10/11（日）\n📍時間：19:00 - 20:30…</div>"""
    sessions = {}
    for raw in re.findall(r'class="trial-date-time"[^>]*>(.*?)</div>', page, re.S):
        text = html.unescape(raw)
        d = re.search(r"日期：\s*(\d{1,2})/(\d{1,2})", text)
        t = re.search(r"時間：\s*(\d{1,2}):(\d{2})\s*[-–~～]\s*(\d{1,2}):(\d{2})", text)
        if not (d and t):
            raise SyncError(f"場次格式對不上：{text.strip()[:80]}")
        month, day = int(d.group(1)), int(d.group(2))
        # 頁面上沒有年份：取今年，若比今天早超過半年就當成明年（跨年場次）
        year = today.year
        if dt.date(year, month, day) < today - dt.timedelta(days=180):
            year += 1
        date = dt.date(year, month, day)
        start = f"{int(t.group(1)):02d}:{t.group(2)}"
        end = f"{int(t.group(3)):02d}:{t.group(4)}"
        sessions[(date, start)] = (date, start, end)
    if not sessions:
        raise SyncError("頁面上找不到任何體驗課場次（可能是 shifu.tw 改版，或目前沒有開放場次）")
    return [sessions[k] for k in sorted(sessions)]


def parse_count(page: str) -> int:
    m = re.search(r'class="[^"]*trial-enroll-count[^"]*"[^>]*>.*?<strong>\s*([\d,]+)\s*</strong>', page, re.S)
    if not m:
        raise SyncError("找不到報名人數（trial-enroll-count）")
    return int(m.group(1).replace(",", ""))


def render_sessions(sessions, indent: str, note: str) -> str:
    lines = [f"{indent}<!-- trial-sessions:start{note}-->"]
    for date, start, end in sessions:
        wd = WEEKDAYS[date.weekday()]
        lines.append(
            f'{indent}<li data-end="{date.isoformat()}T{end}:00+08:00">'
            f"<strong>{date.month}/{date.day}（{wd}）</strong>{start}–{end}</li>"
        )
    lines.append(f"{indent}<!-- trial-sessions:end -->")
    return "\n".join(lines)


def render_count(n: int) -> str:
    # 18,141 → 18,000+；不到一千就照實寫
    return f"{n // 1000 * 1000:,}+ 人已報名" if n >= 1000 else f"{n} 人已報名"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--source", help="用本機 HTML 檔取代線上頁（測試用）")
    ap.add_argument("--index", default=INDEX)
    args = ap.parse_args()

    out = os.environ.get("GITHUB_OUTPUT")
    try:
        page = open(args.source, encoding="utf-8").read() if args.source else fetch(URL)
        today = dt.datetime.now(TPE).date()
        sessions = parse_sessions(page, today)
        count = parse_count(page)

        src = open(args.index, encoding="utf-8").read()
        m = BLOCK_RE.search(src)
        if not m:
            raise SyncError("index.html 找不到 trial-sessions:start/end 標記")
        if not COUNT_RE.search(src):
            raise SyncError("index.html 找不到 bootcamp-side-count")

        new = src[: m.start()] + render_sessions(sessions, m.group("indent"), m.group("note")) + src[m.end() :]
        new = COUNT_RE.sub(lambda c: c.group(1) + render_count(count) + c.group(2), new, count=1)
    except SyncError as e:
        e = " ".join(str(e).split())  # 壓成一行：GITHUB_OUTPUT 不能有換行
        print(f"::error::{e}")
        if out:
            with open(out, "a") as f:
                f.write(f"error={e}\n")
        return 1

    label = "、".join(f"{d.month}/{d.day}" for d, _, _ in sessions)
    print(f"場次：{label}｜報名人數：{count:,}（顯示 {render_count(count)}）")
    changed = new != src
    print("有變動" if changed else "沒有變動")

    if changed and not args.dry_run:
        with open(args.index, "w", encoding="utf-8") as f:
            f.write(new)
    if out:
        with open(out, "a") as f:
            f.write(f"changed={'true' if changed else 'false'}\n")
            f.write(f"summary=場次 {label}／{render_count(count)}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
