#!/usr/bin/env bash
# Build one claude.ai-uploadable zip per skill into zips/.
# Each archive contains a single top-level folder (the skill directory's name)
# with SKILL.md and that skill's files. Files larger than 50MB are left out
# and listed in zips/SKIPPED.txt.
# Claude.ai rejects zips with more than 200 files. Any skill over that limit
# also gets a <name>-lite.zip that drops bulky folders and notes the omission
# in the copy of README.md inside the zip.
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
max_files = 200
skipped = []
# Dropped first for every lite zip. Ghost-editor's lite is this set alone.
lite_standard = ("library/", "recipes/", "templates/fonts/", "tests/")
# Used, in order, only while a lite zip is still over the file cap.
lite_extra = (
    "evals/",
    "fuzz/",
    ".github/",
    ".clusterfuzzlite/",
    "demos/",
    "site/",
    "brand/",
)

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

def upstream_url(skill_dir: Path) -> str:
    origin = skill_dir / "ORIGIN.md"
    if origin.is_file():
        for line in origin.read_text(encoding="utf-8").splitlines():
            if line.startswith("Upstream:"):
                return line.split(":", 1)[1].strip()
    return ""

def iter_files(skill_dir: Path, exclude_prefixes: tuple[str, ...]):
    for dirpath, dirnames, filenames in os.walk(skill_dir):
        dirnames.sort()
        filenames.sort()
        for filename in filenames:
            full = Path(dirpath) / filename
            if not full.is_file():
                continue
            rel_inside = full.relative_to(skill_dir).as_posix()
            if any(rel_inside == prefix[:-1] or rel_inside.startswith(prefix) for prefix in exclude_prefixes):
                continue
            yield full, rel_inside

def write_zip(archive_path: Path, folder: str, skill_dir: Path, exclude_prefixes: tuple[str, ...], readme_note: str | None):
    count = 0
    with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        wrote_readme = False
        for full, rel_inside in iter_files(skill_dir, exclude_prefixes):
            size = full.stat().st_size
            if size > max_bytes:
                skipped.append(f"{skill_dir.relative_to(root).as_posix()}/{rel_inside}\t{size}")
                continue
            arcname = f"{folder}/{rel_inside}"
            if readme_note and rel_inside == "README.md":
                text = full.read_text(encoding="utf-8")
                if not text.endswith("\n"):
                    text += "\n"
                zf.writestr(arcname, text + readme_note)
                wrote_readme = True
            else:
                zf.write(full, arcname)
            count += 1
        if readme_note and not wrote_readme:
            zf.writestr(f"{folder}/README.md", "# " + folder + "\n" + readme_note)
            count += 1
    return count

def human_list(items: list[str]) -> str:
    if len(items) == 1:
        return items[0]
    if len(items) == 2:
        return f"{items[0]} and {items[1]}"
    return ", ".join(items[:-1]) + ", and " + items[-1]

def lite_note(skill_rel: str, upstream: str, omitted: list[str]) -> str:
    listed = human_list([f"`{name}`" for name in omitted])
    lines = [
        "",
        "## 6ixtony lite package",
        "",
        "This zip is a smaller copy for Claude.ai, which rejects skill uploads with more than 200 files. "
        f"It omits {listed}.",
        "",
        "The full skill, including those folders, is in this repo: "
        f"https://github.com/6ixtony/6ixtony-claude-skills/tree/main/{skill_rel}",
        "",
        f"Upstream: {upstream}",
        "",
    ]
    return "\n".join(lines)

def prefixes_that_match(skill_dir: Path, prefixes: tuple[str, ...]) -> list[str]:
    matched = []
    for prefix in prefixes:
        if any(True for _full, rel in iter_files(skill_dir, ()) if rel == prefix[:-1] or rel.startswith(prefix)):
            matched.append(prefix)
    return matched

manifest = []
lite_built = []
for zip_filename, skill_dir, data in skills:
    folder = skill_dir.name
    archive_path = out_dir / zip_filename
    file_count = write_zip(archive_path, folder, skill_dir, (), None)
    entry = {
        "name": data["name"],
        "description": " ".join(data["description"].split()),
        "path": skill_dir.relative_to(root).as_posix(),
        "zip": zip_filename,
        "bytes": archive_path.stat().st_size,
        "files": file_count,
        "lite": False,
    }
    manifest.append(entry)
    if file_count <= max_files:
        continue
    chosen = list(lite_standard)
    while True:
        omitted = prefixes_that_match(skill_dir, tuple(chosen))
        count = sum(1 for _full, _rel in iter_files(skill_dir, tuple(chosen)))
        # README is rewritten in place, so the file count does not grow.
        if count <= max_files or len(chosen) >= len(lite_standard) + len(lite_extra):
            break
        extra = lite_extra[len(chosen) - len(lite_standard)]
        chosen.append(extra)
    if count > max_files:
        raise SystemExit(f"{zip_filename} lite still has {count} files (limit {max_files})")
    note = lite_note(entry["path"], upstream_url(skill_dir), [p.rstrip("/") + "/" for p in omitted])
    lite_name = zip_filename.replace(".zip", "-lite.zip")
    lite_path = out_dir / lite_name
    lite_count = write_zip(lite_path, folder, skill_dir, tuple(chosen), note)
    if lite_count > max_files:
        raise SystemExit(f"{lite_name} has {lite_count} files")
    manifest.append(
        {
            "name": data["name"],
            "description": entry["description"],
            "path": entry["path"],
            "zip": lite_name,
            "bytes": lite_path.stat().st_size,
            "files": lite_count,
            "lite": True,
            "omitted": [p.rstrip("/") + "/" for p in omitted],
        }
    )
    lite_built.append((lite_name, lite_count, [p.rstrip("/") + "/" for p in omitted]))

manifest.sort(key=lambda item: item["zip"])
(out_dir / "manifest.json").write_text(json.dumps({"skills": manifest, "count": len(manifest)}, indent=2) + "\n", encoding="utf-8")
full_count = sum(1 for item in manifest if not item["lite"])
readme = [
    "# Skill zips",
    "",
    "One zip per installable skill, for Claude.ai (Settings → Capabilities → Skills).",
    "Each zip contains a single top-level folder with that skill's `SKILL.md` and its files.",
    "",
    "Claude.ai rejects a zip with more than 200 files. Skills over that limit also have a `-lite` zip.",
    "",
    (
        f"{full_count} skill zips and {len(lite_built)} lite zips "
        f"({', '.join(name for name, _count, _omitted in lite_built)}). "
        "Names and descriptions: [SKILLS-INDEX.md](../SKILLS-INDEX.md)."
        if lite_built
        else f"{full_count} skill zips. Names and descriptions: [SKILLS-INDEX.md](../SKILLS-INDEX.md)."
    ),
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
for name, count, omitted in lite_built:
    print(f"lite {name} files={count} omitted={', '.join(omitted)}")
PY
