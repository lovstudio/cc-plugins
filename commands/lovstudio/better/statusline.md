---

allowed-tools: [Read, Write, Edit, Bash, Glob, AskUserQuestion]
description: Install or update the vibe-genius statusline (see statusline/README.md for full component docs)
version: "2.1.0"
author: "公众号:手工川"
aliases: /better-statusline
---

# Better Statusline — installer

This command is a thin installer for the **statusline component**. The component itself lives at `statusline/` in the repo with its own `README.md` and `CHANGELOG.md` — read those for format, fields, subagent rendering, and design rationale.

## Install (default mode)

### 1. Copy the script into `~/.claude/`

```bash
src="$CLAUDE_PLUGIN_ROOT/statusline/vibe-genius.sh"
dst="$HOME/.claude/statusline.sh"

# Back up any existing file so /rollback works
if [ -f "$dst" ]; then
    mkdir -p "$HOME/.claude/statusline-versions"
    ts=$(date +"%Y%m%d_%H%M%S")
    cp "$dst" "$HOME/.claude/statusline-versions/statusline.sh.$ts.bak"
fi

cp "$src" "$dst"
chmod +x "$dst"
```

### 2. Wire it into `~/.claude/settings.json`

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

If `statusLine` already exists, replace its `command` — do not duplicate the key.

### 3. Verify

Start a new Claude Code session or run the script manually with mock stdin.

## Rollback

Backups live at `~/.claude/statusline-versions/statusline.sh.<timestamp>.bak`.

```bash
ls ~/.claude/statusline-versions/
cp ~/.claude/statusline-versions/statusline.sh.<ts>.bak ~/.claude/statusline.sh
```

## Subagent statusline (no install needed)

Already auto-wired via `.claude-plugin/settings.json`. Enabling the plugin is enough. See `statusline/README.md` for the row format.

## Legacy inline-string mode

Pass `inline` as the argument to fall back to the v1.x flow that set `statusLine.command` to an inline string.

ARGUMENTS: $ARGUMENTS
