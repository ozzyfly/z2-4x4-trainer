#!/usr/bin/env python3
"""Merge new-language stringUnits into an .xcstrings catalog.

Usage: import and call merge(path, {key: {lang: value}}). Existing
localizations are never touched; missing keys abort loudly so a typo can't
silently drop a translation. Verifies %-placeholders match the source key.
"""
import json
import re
import sys

PLACEHOLDER = re.compile(r"%(?:\d+\$)?(?:lld|@|d|%)")


def placeholders(s: str):
    """Normalized (positional stripped) sorted list of format specifiers."""
    out = []
    for p in PLACEHOLDER.findall(s.replace("%%", "")):
        out.append("%" + p.split("$")[1] if "$" in p else p)
    return sorted(out)


def merge(path: str, translations: dict):
    with open(path) as f:
        doc = json.load(f)
    strings = doc["strings"]
    added = 0
    for key, langs in translations.items():
        if key not in strings:
            sys.exit(f"ABORT: key not in catalog: {key!r}")
        locs = strings[key].setdefault("localizations", {})
        want = placeholders(key)
        for lang, value in langs.items():
            if lang in locs:
                continue  # never overwrite
            got = placeholders(value)
            if want != got:
                sys.exit(f"ABORT: placeholder mismatch {key!r} [{lang}]: {want} vs {got}")
            locs[lang] = {"stringUnit": {"state": "translated", "value": value}}
            added += 1
    with open(path, "w") as f:
        json.dump(doc, f, ensure_ascii=False, indent=2, sort_keys=True)
    print(f"{path}: +{added} localizations → {len(strings)} keys")
