# statusline

Independent component: the **vibe-genius** statusline for Claude Code, plus a companion **subagent** row renderer.

## Layout

```
💥 cc-plugins (main) │ Opus 4.7 (anthropic) │ $82.13 / 66.2M │ V2.1.119
💬 目前是/clear后就会触发复制session resume命令到剪切板，我希望 · #9f1c7720
```

- **Line 1 (status header)**: cwd (branch) · model (provider) · daily cost / daily tokens · Claude Code version
- **Line 2**: `💬 <session title> · #<session-id-short>` — title prefers the `/compact` summary from the transcript, falls back to the first user prompt; when neither exists, Line 2 degrades to `💬 #<session-id-short>` so the two-line shape stays consistent.

Colors in priority order: cost/tokens (bold bright green / bold bright yellow) > title (plain bright white) > cwd/model (cyan/magenta) > separators (dim gray).

## Files

| File | Role |
| :--- | :--- |
| `vibe-genius.sh` | Main statusline. Installed to `~/.claude/statusline.sh` via the `/lovstudio:better:statusline` command. |
| `subagent-vibe-genius.sh` | Subagent row renderer. Auto-wired via `.claude-plugin/settings.json` when the plugin is enabled — no install step. |

## How the daily-token counter works

- Cache file: `~/.claude/.daily_tokens`, one line per `(day, session_id)` storing `byte_offset:session_token_total`.
- Each statusLine tick only parses the **newly-appended bytes** of the current session's transcript — cost is O(delta), not O(transcript size).
- Daily total = sum of `session_token_total` across all lines matching today. Multi-session aggregation is automatic: each session updates its own row, the sum is the day total.
- Day rollover prunes old rows. File truncation (session restart) resets the offset.

## Subagent row format

Each overridable row renders as `<glyph> <name> · <description> · <tokens>`:

- ⚙ running / in_progress / active
- ✓ completed / done / success
- ✗ failed / error
- ○ queued / pending / unknown

Description is truncated to terminal width minus ~40 chars (minimum 20 chars).

## Why main statusLine isn't a declarative plugin component

Anthropic's plugin manifest only accepts `agent` and `subagentStatusLine` in a plugin's `settings.json` ([plugins-reference — Standard plugin layout](https://code.claude.com/docs/en/plugins-reference#standard-plugin-layout), line 695). The main `statusLine` must live in the user's or project's `settings.json`, and `${CLAUDE_PLUGIN_ROOT}` does not resolve there. That's why the main statusline needs an install command (`/lovstudio:better:statusline`) to copy the script into `~/.claude/` and wire up the user's settings.

## Installing the main statusline

Run `/lovstudio:better:statusline` in Claude Code, or manually:

```bash
cp "$CLAUDE_PLUGIN_ROOT/statusline/vibe-genius.sh" ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

Then in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

## Changelog

See [CHANGELOG.md](./CHANGELOG.md).
