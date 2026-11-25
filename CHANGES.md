# Changes in the 6ixtony packaging

These are the only intentional differences from upstream. Skill workflows and most file contents are unchanged.

1. **Packaging.** Skills from several repositories are grouped in one tree, with a 6ixtony README, attribution, install instructions, and an index table. Original LICENSE files travel with each vendor folder.
2. **HyperFrames `media-use` telemetry disabled.** Upstream `skills/media-use/scripts/lib/telemetry.mjs` shipped a hardcoded PostHog project API key (`phc_…`) that sent coarse usage events to `us.i.posthog.com` unless the user opted out. In this copy the key is cleared and the original line is left commented so the change is auditable. `track()` returns immediately when the key is empty, so this copy does not post those events. This does not remove HeyGen's copyright or license. If you want upstream telemetry, use the official repo.
3. **Media omitted to keep the copy smaller** — listed in EXCLUDED.md. Function of the skills is not supposed to depend on those demo GIFs. Also omitted from ffmpeg-skill: `assets/demo.gif`.
4. **Name-collision notes.** Two upstream skills share the frontmatter name `lower-thirds` (TikTok pack vs lower-thirds pack). Two share `threejs-animation` (CloudAI-X vs iart-ai webgl pack). Zip names and install folder names in this pack are unique; see SKILLS-INDEX.md.
5. **No new telemetry, no bundled API keys, no auto-publish scripts.** Paid provider calls that already existed upstream (ElevenLabs, fal, Gemini, iArt MCP, HyperFrames cloud render) still exist in those skills and still need your own keys and approval before use.

6. **ghost-editor skill description trimmed by a few characters** so it meets Claude.ai's 1024-character skill-description limit (the quoted YAML source was 1025 characters, counting backslash escapes; the decoded description was 1013). The phrase "talking-head phone recording" is now "talking-head recording". No other wording in that file was changed. The decoded description is 1007 characters.

7. **product-demo-video frontmatter quoted.** In iart-ai/ecommerce-video-skills the description was an unquoted YAML string containing a colon (`demo: device`), so a strict parser rejected the file. The description text is unchanged; it is now a single-quoted string.

8. **Maintainer files left out.** This repo has no GitHub Actions workflows. Upstream workflow files from ffmpeg-skill and talking-head-skills were not copied. ffmpeg-skill's `.github/scripts/publish_plugin_branch.sh` (it pushes a plugin branch) was not copied. Maintainer-only skills under `ffmpeg-skill/.claude/skills/` and the generated plugin mirror `skills/ffmpeg-skill/SKILL.md` were not copied, so that vendor folder has one installable SKILL.md.

If you re-sync from upstream, re-apply item 2 and keep ATTRIBUTION.md current.
