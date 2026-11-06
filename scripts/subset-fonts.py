#!/usr/bin/env python3
"""Rebuild both heading fonts from the official Glow Sans TC Wide OTFs.

Requires fonttools[woff]. Pass the directory containing the two original OTFs.
Originals: https://github.com/welai/glow-sans/releases/tag/v0.93
"""
import argparse
import hashlib
import html
import json
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("source_dir", type=Path)
args = parser.parse_args()

pages = [ROOT / "index.html", ROOT / "404.html", *sorted((ROOT / "learn").rglob("*.html"))]
text = "".join(html.unescape(p.read_text()) for p in pages)
required = set(map(ord, text)) | set(range(32, 127))
# Preserve glyphs already shipped for punctuation and existing site components.
for path in (ROOT / "fonts").glob("*.woff2"):
    with TTFont(path) as font:
        required.update(font.getBestCmap())

records = {}
for weight in ("Bold", "ExtraBold"):
    font = TTFont(args.source_dir / f"GlowSansTC-Wide-{weight}.otf")
    # TC v0.93 omits these Unicode aliases although their glyphs exist.
    # Restore the mappings documented upstream; page text remains unchanged.
    # https://github.com/welai/glow-sans/issues/22
    aliases = {'值': '値', '告': '吿', '教': '敎', '清': '淸', '真': '眞'}
    original_cmap = font.getBestCmap()
    for char, variant in aliases.items():
        if ord(char) not in original_cmap:
            for table in font['cmap'].tables:
                if table.isUnicode():
                    table.cmap[ord(char)] = original_cmap[ord(variant)]
    cmap = font.getBestCmap()
    missing = {c for c in required if 0x3400 <= c <= 0x9fff and c not in cmap}
    if missing:
        raise SystemExit("Original font lacks: " + "".join(map(chr, sorted(missing))))
    options = subset.Options()
    options.flavor = "woff2"
    options.name_IDs = [0, 1, 2, 3, 4, 5, 6, 13, 14, 16, 17]
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=required & set(cmap))
    subsetter.subset(font)
    font.flavor = "woff2"
    output = ROOT / "fonts" / f"GlowSansTCWide-{weight}.woff2"
    font.save(output)
    # Record actual saved coverage, not the requested character list.
    with TTFont(output) as saved:
        chars = "".join(chr(c) for c in sorted(saved.getBestCmap()))
    records[output.name] = {
        "sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
        "characters": chars,
    }
    print(f"{output.name}: {len(chars)} glyphs, {output.stat().st_size:,} bytes")

(ROOT / "fonts" / "coverage.json").write_text(
    json.dumps(records, ensure_ascii=False, indent=2) + "\n"
)
print("Coverage recorded. Bump both font URL versions in styles.css after changing fonts.")
