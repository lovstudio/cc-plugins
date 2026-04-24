# statusline CHANGELOG

Independent versioning for the statusline component (both `vibe-genius.sh` and `subagent-vibe-genius.sh`). Decoupled from the plugin's overall version.

## v2.2.0 — 2026-04-24

- Promoted to a top-level component: files moved from `scripts/statusline/` to `statusline/`.
- Independent `README.md` and this `CHANGELOG.md` — the statusline no longer piggybacks on the `/lovstudio:better:statusline` command's changelog.
- Plugin `settings.json` `subagentStatusLine.command` updated to the new `${CLAUDE_PLUGIN_ROOT}/statusline/subagent-vibe-genius.sh` path.

## v2.1.0 — 2026-04-24

- Two-line layout: status header on line 1, `💬 <title> · #<session-id>` on line 2.
- Title color toned down to `\033[0;97m` (plain bright white, no bold) so cost/tokens stay the brightest segment.
- Session id reinstated (short 8-char form) on the title line.
- New `subagent-vibe-genius.sh` row renderer: `<glyph> <name> · <desc> · <tokens>` with glyphs ⚙ / ✓ / ✗ / ○.
- Plugin `settings.json` auto-wires `subagentStatusLine` via `${CLAUDE_PLUGIN_ROOT}` — no install step for subagent rows.

## v2.0.0 — 2026-04-24

- Shipped as a managed script (`vibe-genius.sh`), migrated from the now-archived `claude-code-manager` repo.
- Daily token counter with incremental per-session byte-offset caching in `~/.claude/.daily_tokens`.
- Session title suffix — `/compact` summary preferred, falls back to first user prompt.
- `/lovstudio:better:statusline` v2.0.0 installs the script + wires the user's `settings.json`; legacy inline-string mode preserved behind the `inline` argument.

## Pre-history

Earlier work lived in the now-archived [`claude-code-manager`](https://github.com/MarkShawn2020/claude-code-manager) repo as `modules/statusline/vibe-genius.sh`.
