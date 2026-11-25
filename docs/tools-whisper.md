# OpenAI Whisper (related tool, not a Claude Skill)

Official repo: https://github.com/openai/whisper  
License: MIT, Copyright (c) 2022 OpenAI  
This pack does **not** vendor Whisper's source. Install it from upstream when you need speech-to-text.

Whisper turns speech in a video or audio file into timestamped text so an editor (or Claude) can cut by words. It is a Python package, not a `SKILL.md` skill.

## Install (official)

```bash
pip install -U openai-whisper
# needs ffmpeg on PATH
```

First run downloads a model (tiny / base / small / medium / large-v3). That is a network download from OpenAI/GitHub and can be hundreds of MB.

## Use

```bash
whisper interview.mp4 --model small --language en --output_format srt
```

Local alternative used by some skills in this pack: `faster-whisper` (separate project). ffmpeg-skill's caption transcription can use it if you install it yourself.

## Safety notes

- Runs locally after the model is downloaded.
- The first model download is a network call.
- Not a substitute for checking transcripts before publishing.
