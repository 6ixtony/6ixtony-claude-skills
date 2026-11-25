# Excluded or not vendored

## Excluded (no license that clearly allows redistribution)

| Project | URL | Reason |
|---|---|---|
| LPengYang/MotionClone | https://github.com/LPengYang/MotionClone | No LICENSE file. GitHub license field is empty. Research code for the ICLR 2025 paper *MotionClone: Training-Free Motion Cloning for Controllable Video Generation* (arXiv:2406.05338). Use the official repo directly if you accept the unlicensed-code risk; this pack does not copy it. |
| iart-ai/generative-illustration-skills | https://github.com/iart-ai/generative-illustration-skills | Pack listed from the MIT motion-skills index, but the pack repo itself has no LICENSE file (README + one skill only). One of 56 advertised skills; excluded until a license is added upstream. |

## Documented, not vendored (permissive license, but not Claude Skills)

| Project | License | Why it is not copied into this repo |
|---|---|---|
| openai/whisper | MIT | Python ML package, not SKILL.md format. Install from official instructions. See docs/tools-whisper.md. |
| yt-dlp/yt-dlp | Unlicense | Large CLI downloader, not SKILL.md format. Install from official instructions. See docs/tools-yt-dlp.md. |

## Intentionally omitted media (source still attributed)

- kajisho5/ffmpeg-skill demo videos, site media, and docs/demos GIFs
- kurbaitaev/ghost-editor `docs/media` demo GIFs (a short pointer file remains)
- zhuyansen/awesome-claude-video-skills preview image assets
- iart-ai/motion-skills and pack-root showcase GIFs
- The full heygen-com/hyperframes monorepo (CLI, studio app, packages). Only the `skills/` tree, LICENSE, and CREDITS.md are here. To render videos you still install HyperFrames from upstream (`npx skills add heygen-com/hyperframes` / the HyperFrames CLI).
