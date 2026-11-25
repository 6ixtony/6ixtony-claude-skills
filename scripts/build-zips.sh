#!/usr/bin/env bash
# Build one claude.ai-uploadable zip per skill into zips/.
# Each archive contains a single top-level folder (the skill directory's name)
# with SKILL.md and that skill's files. Files larger than 50MB are left out
# and listed in zips/SKIPPED.txt.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p zips
find zips -maxdepth 1 -name '*.zip' -delete
rm -f zips/SKIPPED.txt zips/manifest.json

python3 - "$ROOT" << 'PY'
import json
import os
import re
import sys
import zipfile
from pathlib import Path

import yaml

root = Path(sys.argv[1])
out_dir = root / "zips"
max_bytes = 50 * 1024 * 1024
skipped = []

def parse_frontmatter(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        raise SystemExit(f"{path} missing YAML frontmatter")
    end = text.find("\n---", 4)
    if end < 0:
        raise SystemExit(f"{path} unclosed frontmatter")
    data = yaml.safe_load(text[4:end])
    if not isinstance(data, dict):
        raise SystemExit(f"{path} frontmatter is not a mapping")
    name = data.get("name")
    desc = data.get("description")
    if not isinstance(name, str) or not re.fullmatch(r"[a-z0-9-]{1,64}", name):
        raise SystemExit(f"{path} invalid name: {name!r}")
    if not isinstance(desc, str) or len(desc) > 1024:
        length = len(desc) if isinstance(desc, str) else None
        raise SystemExit(f"{path} invalid description (len={length})")
    return data

def zip_name(rel: str) -> str:
    parts = rel.split("/")
    if parts == ["skills", "ffmpeg-skill", "SKILL.md"]:
        return "ffmpeg-skill.zip"
    if parts == ["skills", "claude-shorts", "SKILL.md"]:
        return "claude-shorts.zip"
    if parts == ["skills", "ghost-editor", "SKILL.md"]:
        return "ghost-editor.zip"
    if len(parts) == 5 and parts[:3] == ["skills", "hyperframes", "skills"] and parts[4] == "SKILL.md":
        return f"hyperframes__{parts[3]}.zip"
    if len(parts) == 5 and parts[:3] == ["skills", "threejs", "skills"] and parts[4] == "SKILL.md":
        return f"threejs__{parts[3]}.zip"
    if (
        len(parts) == 7
        and parts[:3] == ["skills", "motion", "packs"]
        and parts[4] == "skills"
        and parts[6] == "SKILL.md"
    ):
        return f"motion__{parts[3]}__{parts[5]}.zip"
    raise SystemExit(f"unexpected SKILL.md location: {rel}")

skills = []
for path in sorted(root.rglob("SKILL.md")):
    rel = path.relative_to(root).as_posix()
    if rel.startswith("zips/"):
        continue
    data = parse_frontmatter(path)
    skills.append((zip_name(rel), path.parent, data))

names = [item[0] for item in skills]
if len(names) != len(set(names)):
    raise SystemExit("zip names are not unique")

manifest = []
for zip_filename, skill_dir, data in skills:
    folder = skill_dir.name
    archive_path = out_dir / zip_filename
    with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for dirpath, dirnames, filenames in os.walk(skill_dir):
            dirnames.sort()
            filenames.sort()
            for filename in filenames:
                full = Path(dirpath) / filename
                if not full.is_file():
                    continue
                size = full.stat().st_size
                rel_inside = full.relative_to(skill_dir).as_posix()
                if size > max_bytes:
                    skipped.append(f"{skill_dir.relative_to(root).as_posix()}/{rel_inside}\t{size}")
                    continue
                zf.write(full, f"{folder}/{rel_inside}")
    manifest.append(
        {
            "name": data["name"],
            "description": " ".join(data["description"].split()),
            "path": skill_dir.relative_to(root).as_posix(),
            "zip": zip_filename,
            "bytes": archive_path.stat().st_size,
        }
    )

manifest.sort(key=lambda item: item["zip"])
(out_dir / "manifest.json").write_text(json.dumps({"skills": manifest, "count": len(manifest)}, indent=2) + "\n", encoding="utf-8")
readme = [
    "# Skill zips",
    "",
    "One zip per installable skill, for Claude.ai (Settings → Capabilities → Skills).",
    "Each zip contains a single top-level folder with that skill's `SKILL.md` and its files.",
    "",
    f"{len(manifest)} zips. Names and descriptions: [SKILLS-INDEX.md](../SKILLS-INDEX.md).",
    "",
]
if skipped:
    readme.append("Some files over 50MB were left out of the archives. See SKIPPED.txt.")
    readme.append("")
(out_dir / "README.md").write_text("\n".join(readme), encoding="utf-8")
if skipped:
    (out_dir / "SKIPPED.txt").write_text("\n".join(skipped) + "\n", encoding="utf-8")
    print(f"skipped {len(skipped)} large files")
else:
    print("no files over 50MB")
total = sum(item["bytes"] for item in manifest)
print(f"zips={len(manifest)} total_bytes={total}")
PY
