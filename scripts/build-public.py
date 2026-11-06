#!/usr/bin/env python3
"""Build the public site from an explicit allowlist, never the repository root."""
from pathlib import Path
import hashlib, html, json, re, shutil, subprocess
import xml.etree.ElementTree as ET
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "dist"
# Fail closed on stale output; CI starts clean. Rebuild locally into a new directory.
if OUT.exists() and any(OUT.iterdir()):
    raise SystemExit("dist is not empty; archive it before rebuilding")
# Keep the Chinese heading subsets in sync with every page, including inline JS copy.
# The manifest is generated from the actual font cmap; hashes catch stale manifests.
pages = [ROOT / 'index.html', ROOT / '404.html', *sorted((ROOT / 'learn').rglob('*.html'))]
cjk = set(re.findall(r'[\u3400-\u9fff\uf900-\ufaff\U00020000-\U0003134f]', ''.join(html.unescape(p.read_text()) for p in pages)))
for name, coverage in json.loads((ROOT / 'fonts/coverage.json').read_text()).items():
    if hashlib.sha256((ROOT / 'fonts' / name).read_bytes()).hexdigest() != coverage['sha256']:
        raise SystemExit(f'{name}: stale font coverage; run scripts/subset-fonts.py')
    missing = cjk - set(coverage['characters'])
    if missing:
        raise SystemExit(f'{name}: missing glyphs {"".join(sorted(missing))}; run scripts/subset-fonts.py')
OUT.mkdir(exist_ok=True)
FILES = ['index.html', 'styles.css', 'robots.txt', 'sitemap.xml', '404.html', '_headers', 'site.webmanifest']
DIRS = ['images', 'fonts', 'starter-kit', 'env-installer', 'learn']
ALLOWED = {".html", ".css", ".js", ".png", ".jpg", ".jpeg", ".webp", ".svg", ".gif", ".woff2", ".md", ".sh", ".zip"}
for name in FILES:
    shutil.copy2(ROOT / name, OUT / name)
for folder in DIRS:
    for src in (ROOT / folder).rglob("*"):
        if not src.is_file() or src.is_symlink() or any(x.startswith(".") for x in src.relative_to(ROOT).parts):
            continue
        if any(part in {"tests", "_originals-backup"} for part in src.parts):
            continue
        if src.suffix.lower() not in ALLOWED and src != ROOT / 'fonts/OFL.txt':
            continue
        target = OUT / src.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, target)
# Each page uses its own committed content date, never the deployment date.
page_sources = {
    'https://cc.lifehacker.tw/': ['index.html', 'styles.css'],
    'https://cc.lifehacker.tw/learn/ai-agent-basics/': ['learn/ai-agent-basics/index.html', 'learn/learn.css', 'styles.css'],
    'https://cc.lifehacker.tw/learn/mac-setup/': ['learn/mac-setup/index.html', 'learn/learn.css', 'styles.css'],
}
namespace = 'http://www.sitemaps.org/schemas/sitemap/0.9'
ET.register_namespace('', namespace)
tree = ET.parse(OUT / 'sitemap.xml')
for entry in tree.getroot():
    sources = page_sources[entry.find(f'{{{namespace}}}loc').text]
    lastmod = entry.find(f'{{{namespace}}}lastmod')
    if lastmod is not None:
        entry.remove(lastmod)
    # New preview pages have no commit yet; don't inherit an older CSS date.
    committed = subprocess.check_output(['git', 'log', '-1', '--format=%cI', '--', sources[0]], cwd=ROOT, text=True).strip()
    if committed:
        value = subprocess.check_output(['git', 'log', '-1', '--format=%cI', '--', *sources], cwd=ROOT, text=True).strip()
        ET.SubElement(entry, f'{{{namespace}}}lastmod').text = value
ET.indent(tree, space='  ')
tree.write(OUT / 'sitemap.xml', encoding='UTF-8', xml_declaration=True)
print(f"Published {sum(1 for p in OUT.rglob('*') if p.is_file())} allowlisted files")
