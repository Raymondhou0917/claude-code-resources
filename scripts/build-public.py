#!/usr/bin/env python3
"""Build the public site from an explicit allowlist, never the repository root."""
from pathlib import Path
import shutil, subprocess, re
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "dist"
OUT.mkdir(exist_ok=True)
# Fail closed on stale output; CI starts clean. Rebuild locally into a new directory.
if any(OUT.iterdir()):
    raise SystemExit("dist is not empty; archive it before rebuilding")
FILES = ['index.html', 'styles.css', 'robots.txt', 'sitemap.xml', '404.html', '_headers', 'course-articles.js']
DIRS = ['images', 'fonts', 'starter-kit', 'env-installer']
ALLOWED = {".html", ".css", ".js", ".png", ".jpg", ".jpeg", ".webp", ".svg", ".gif", ".woff2", ".md", ".sh", ".zip"}
for name in FILES:
    shutil.copy2(ROOT / name, OUT / name)
for folder in DIRS:
    for src in (ROOT / folder).rglob("*"):
        if not src.is_file() or src.is_symlink() or any(x.startswith(".") for x in src.relative_to(ROOT).parts):
            continue
        if "tests" in src.parts or src.suffix.lower() not in ALLOWED:
            continue
        target = OUT / src.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, target)
# Git content date, not the deployment date: rebuilds do not claim fresh content.
lastmod = subprocess.check_output(["git", "log", "-1", "--format=%cI", "--", "index.html", "styles.css", "course-articles.js"], cwd=ROOT, text=True).strip()
sitemap = (OUT / "sitemap.xml").read_text()
if lastmod:
    (OUT / "sitemap.xml").write_text(re.sub(r"<lastmod>.*?</lastmod>", f"<lastmod>{lastmod}</lastmod>", sitemap))
print(f"Published {sum(1 for p in OUT.rglob('*') if p.is_file())} allowlisted files")
