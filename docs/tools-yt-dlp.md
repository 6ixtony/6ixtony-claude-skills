# yt-dlp (related tool, not a Claude Skill)

Official repo: https://github.com/yt-dlp/yt-dlp  
License: Unlicense (public domain)  
This pack does **not** vendor yt-dlp's source. Install it from upstream when you need a downloader.

yt-dlp is a command-line audio/video downloader that supports thousands of sites. Several skills in this pack assume you already have source footage; yt-dlp is one way to fetch it.

## Install (official)

```bash
pip install -U yt-dlp
# or follow https://github.com/yt-dlp/yt-dlp#installation
```

## Safety and legal notes

- yt-dlp makes network requests to whatever URL you give it. Some extractors run JavaScript from the site. That is expected for a downloader, not a hidden backdoor, but you should only point it at sources you are allowed to use.
- Site terms of service and copyright still apply. Do not use it to rip material you do not have rights to reuse.
- Keep it updated; extractor breakage and security fixes are frequent.
