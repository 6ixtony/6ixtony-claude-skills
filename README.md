# 6ixtony Claude Skills

A packaged collection of **open-source Claude skills** for video editing, motion graphics, and 3D — assembled so they can be uploaded to Claude.ai, dropped into Claude Code, or summarized in a Claude Project.

This is a **redistribution with attribution**, not original authorship. The skills come from the public GitHub repositories named in [@getintoai's 10-repo carousel](https://www.instagram.com/p/DgLSyhCE52l/). 6ixtony added packaging, an index, install notes, and a small safety change (HyperFrames usage telemetry is off in this copy). Every vendored tree keeps its original license and copyright notice.

**Read [ATTRIBUTION.md](ATTRIBUTION.md) before you publish or reuse this repo.** Licenses here are MIT, Apache-2.0, or CC0, plus Unlicense for a related tool that is documented but not vendored.

## What's inside

| Area | What you get | Upstream |
|---|---|---|
| **HyperFrames skills** (9) | Teach an agent to author HTML timelines and render MP4s with the HyperFrames CLI | [heygen-com/hyperframes](https://github.com/heygen-com/hyperframes) (Apache-2.0) |
| **ffmpeg-skill** (1) | 42 local FFmpeg tools: cut, caption, reframe, loudness, export | [kajisho5/ffmpeg-skill](https://github.com/kajisho5/ffmpeg-skill) (MIT) |
| **claude-shorts** (1) | Long video → vertical Shorts/Reels with Remotion captions | [AgriciDaniel/claude-shorts](https://github.com/AgriciDaniel/claude-shorts) (MIT) |
| **ghost-editor** (1) | Raw talking-head take → styled vertical reel (Mac / Apple silicon noted by the author) | [kurbaitaev/ghost-editor](https://github.com/kurbaitaev/ghost-editor) (MIT) |
| **Motion packs** (55) | Kinetic type, explainers, short-form, data, web, WebGL, Manim, lower thirds, and more | [iart-ai/motion-skills](https://github.com/iart-ai/motion-skills) and 18 MIT pack repos |
| **Three.js skills** (13) | Current three.js r186 / React Three Fiber guidance | [CloudAI-X/threejs-skills](https://github.com/CloudAI-X/threejs-skills) (MIT) |
| **Catalog** | Curated, security-graded list of many other video skills | [zhuyansen/awesome-claude-video-skills](https://github.com/zhuyansen/awesome-claude-video-skills) (CC0) |

**80 installable skills** are listed in [SKILLS-INDEX.md](SKILLS-INDEX.md). Per-skill zip files are in [`zips/`](zips/).

Related tools that the carousel also named, but that are **not** Claude Skills:

- [openai/whisper](https://github.com/openai/whisper) — see [docs/tools-whisper.md](docs/tools-whisper.md)
- [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) — see [docs/tools-yt-dlp.md](docs/tools-yt-dlp.md)

Not included: [LPengYang/MotionClone](https://github.com/LPengYang/MotionClone) (no license) and [iart-ai/generative-illustration-skills](https://github.com/iart-ai/generative-illustration-skills) (no license). Details in [EXCLUDED.md](EXCLUDED.md). Packaging differences are in [CHANGES.md](CHANGES.md).

## A sensible starter set

Do not upload all 80 skills at once. Claude loads skill descriptions into context; a huge set can get in the way. Start with what matches the job:

| If you want to… | Install |
|---|---|
| Cut and export real footage locally | `zips/ffmpeg-skill.zip` |
| Build motion or edit in HTML, then render MP4 | `zips/hyperframes__hyperframes.zip` and `zips/hyperframes__hyperframes-cli.zip` (install the HyperFrames CLI from upstream too) |
| Turn a long video into Shorts | `zips/claude-shorts.zip` |
| Polish a talking-head reel | `zips/ghost-editor.zip` (Mac / Apple silicon per upstream) |
| Animate type, explainers, or short-form motion | a single iart pack from `zips/motion__…` |
| Write current Three.js | `zips/threejs__threejs-fundamentals.zip` and the topic zips you need |

## Install

### Claude.ai (upload a skill zip)

1. Open Claude.ai → **Settings → Capabilities → Skills**.
2. Upload one zip from `zips/`. Upload one skill per zip, not a batch of unrelated trees.
3. Repeat for each skill you actually need.
4. Skills that call FFmpeg, Remotion, Node, or paid APIs still need those tools or keys on the machine that runs them. The Claude.ai chat upload gives Claude the *instructions*; it does not install FFmpeg into the browser.

### Claude Code (`~/.claude/skills`)

For all your projects:

```bash
git clone https://github.com/6ixtony/6ixtony-claude-skills.git
mkdir -p ~/.claude/skills

# examples — copy only what you need
cp -R 6ixtony-claude-skills/skills/ffmpeg-skill ~/.claude/skills/ffmpeg-skill
cp -R 6ixtony-claude-skills/skills/claude-shorts ~/.claude/skills/shorts
cp -R 6ixtony-claude-skills/skills/ghost-editor ~/.claude/skills/ghost-editor
cp -R 6ixtony-claude-skills/skills/hyperframes/skills/hyperframes ~/.claude/skills/hyperframes
cp -R 6ixtony-claude-skills/skills/threejs/skills/* ~/.claude/skills/
```

For one project, copy into `.claude/skills/` at the repo root instead.

ffmpeg-skill's upstream installer (`npx ffmpeg-skill setup`) can also place the skill and, if FFmpeg is missing, offer to install it with Homebrew, winget, or apt. That step is optional and changes the machine — read it before you run it.

Several motion packs also support:

```bash
npx skills add iart-ai/tiktok-video-skills
npx skills add cloudai-x/threejs-skills
npx skills add heygen-com/hyperframes
```

Those commands talk to the **upstream** repos, which is the most direct way to stay current.

### Claude Projects (claude.ai)

1. Create a Project.
2. Paste [project-instructions.md](project-instructions.md) into the project instructions.
3. Optionally upload the zip files for the few skills that project should use.
4. In the instructions, say which skills are attached so Claude does not assume tools that are not installed.

## Requirements and costs

- **Local tools:** many skills expect FFmpeg, Node 18/22+, and sometimes Python 3.10+, Remotion, or Three.js. Read the skill's own README.
- **Paid APIs (do not run until you have agreed to the spend):** iart talking-head uses ElevenLabs and fal; ghost-editor can use Gemini (optional) and ElevenLabs (explainer narrator); HyperFrames can render in the cloud; the iArt MCP is a paid product. No API keys are bundled here.
- **HyperFrames telemetry:** disabled in this copy. See CHANGES.md.
- **Downloads and copyright:** yt-dlp and similar tools do not grant you rights to the media. Only use sources you are allowed to edit and publish.
- **ghost-editor platform:** the author documents Apple silicon Macs; Linux and Intel Macs are untested upstream.

## Safety in short

A review of the vendored text and scripts found no webhook exfiltration, no bundled private keys, and no curl-piped-to-shell installers. What *is* present, by design:

- Local command execution (FFmpeg, Node, Python, shell helpers).
- Optional network calls to model or media APIs when you set keys.
- ffmpeg-skill setup may invoke a system package manager to install FFmpeg.
- HyperFrames upstream included PostHog usage telemetry; this copy turns that off.
- talking-head and similar skills upload photos or voice to third parties when used.

Treat each skill like any other development tool you install: read it, run it on footage you own, and keep secrets in your environment.

## License

There is no single license covering every file. Use the LICENSE sitting next to each upstream tree:

- Apache-2.0 — HyperFrames skills
- MIT — ffmpeg-skill, claude-shorts, ghost-editor, iart.ai packs, Three.js skills
- CC0 1.0 — the awesome-list text only

The 6ixtony README, index, project instructions, and packaging notes in this repository may be reused under MIT, with the same courtesy of attribution if you fork the pack. That MIT grant does **not** replace the upstream licenses.

## Suggested GitHub listing (when published)

- **Repository name:** `6ixtony-claude-skills`
- **Description:** 6ixtony pack of open-source Claude video and motion skills (HyperFrames, ffmpeg-skill, Shorts, ghost-editor, iart.ai, Three.js), redistributed with attribution.
- **Visibility:** public, if you want other people to install from this GitHub account. This would be the first public repo on `6ixtony` (existing repos are private).
