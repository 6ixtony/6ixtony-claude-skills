# 6ixtony video and motion skills — project instructions

You have access to a packaged set of open-source Claude skills for video editing, motion graphics, and 3D. They were collected by 6ixtony from public GitHub repositories and are not originally authored by 6ixtony. Prefer the attached skill folders when they match the task. Do not claim tools are installed if they are not. Do not spend money, call paid APIs, or publish anything unless the user clearly asks for that step and has provided the keys.

## How to choose a skill

- **Cut, trim, caption, reframe, or export existing footage locally:** use `ffmpeg-skill`. It drives local FFmpeg. No cloud is required. Transcription, if requested, needs a local engine such as faster-whisper that the user has installed.
- **Build a video as HTML/CSS/JS and render a deterministic MP4:** use `hyperframes` and `hyperframes-cli`. The user must have the HyperFrames CLI (and usually FFmpeg and Node 22+) installed from https://github.com/heygen-com/hyperframes. This pack contains the skills, not the full editor application.
- **Turn a long video into vertical Shorts or Reels with animated captions:** use `shorts` (claude-shorts). Needs FFmpeg, Python, and Remotion as documented in that skill.
- **Turn a raw talking-head recording into a styled vertical reel:** use `ghost-editor`. Upstream documents Apple silicon Macs; do not assume it has been proven on Linux. Optional Gemini or ElevenLabs keys are the user's to provide.
- **Motion graphics, kinetic type, explainers, short-form templates, data films, web motion, WebGL, Manim, lower thirds, or b-roll graphics:** use the matching iart.ai skill (see the index). These teach craft and often render with Remotion, the web, or Manim. They are not a hosted iArt subscription. Do not call the iArt MCP or any paid iArt API unless the user supplies a key and asks for it.
- **Write or fix Three.js / React Three Fiber code on a current release (r186 / R3F 9.8):** use the `threejs-*` skills from CloudAI-X. If both `threejs-animation` (CloudAI-X) and the iart-ai WebGL `threejs-animation` skill are present, prefer CloudAI-X for API-accurate Three.js code and the iart skill for motion-graphic film workflows.
- **Speech-to-text:** this pack does not vendor OpenAI Whisper. If the user has Whisper or faster-whisper installed, use that; otherwise say what needs installing. Official repo: https://github.com/openai/whisper
- **Downloading source media:** this pack does not vendor yt-dlp. If the user already has it and has the right to the media, you may use it. Do not rip copyrighted material. Official repo: https://github.com/yt-dlp/yt-dlp
- **MotionClone** (copy motion from a reference video onto generated clips) is not included: the official repo has no license.

## Rules

- Keep originals and timestamps when editing real footage unless the user wants a restyle.
- Do not invent facts, figures, or quotes in explainer or testimonial videos.
- Never put API keys into project files, plans, or commits.
- Do not run `npx ffmpeg-skill setup`, package-manager installs, or cloud renders unless the user asked for that machine change or spend.
- If a skill's platform or dependency is missing, say so and stop at a clear install list instead of improvising a broken render.
- Credit upstream authors if the user publishes work that ships these skill files themselves.

Full index and licenses: see SKILLS-INDEX.md and ATTRIBUTION.md in the 6ixtony-claude-skills repo.
