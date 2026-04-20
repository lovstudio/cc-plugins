# Changelog

## 1.2.0

- **commands**: All top-level commands moved under `commands/lovstudio/` so every command gets the `/lovstudio:` namespace prefix (e.g. `/code-reviewer` → `/lovstudio:code-reviewer`)
- **marketplace**: Renamed marketplace to `lovstudio-claude-code-plugin`; this repo is now the single source of truth (supersedes `markshawn2020/lovstudio-plugins-official`)
- **plugin.json**: Fixed stale `repository` URL

## 1.1.0

- **png2svg**: PNG 转高质量 SVG（ImageMagick + vtracer + svgo）

## 1.0.0

- Initial release
- **image-gen**: Generate images using Gemini via ZenMux API
- **project-port**: Generate stable, hash-based port numbers for projects
- **Hooks**: Desktop notifications with Lovnotifier integration
