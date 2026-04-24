#!/usr/bin/env python3
"""Vibe-genius subagent statusline row renderer.

Per Anthropic docs (https://code.claude.com/docs/en/statusline#subagent-status-lines):
- stdin: one JSON object containing `columns` and `tasks[]` (each with id, name,
  type, status, description, label, startTime, tokenCount, tokenSamples, cwd).
- stdout: one JSON line per row to override, shape {"id":"<task id>","content":"<body>"}.
  Empty content hides the row; omitting a task leaves its default rendering.

Layout (single line per task):
  <status-glyph> <name> · <description-truncated> · <tokens>

Status glyph: ⚙ running · ✓ completed · ✗ failed · ○ anything else (queued/pending).
"""
import json
import sys


def fmt_tokens(n):
    n = n or 0
    if n >= 1_000_000:
        return f"{n/1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n/1_000:.1f}K"
    return str(n)


def glyph(status):
    s = (status or "").lower()
    if s in ("running", "in_progress", "active"):
        return "\033[36m⚙\033[0m"
    if s in ("completed", "done", "success"):
        return "\033[32m✓\033[0m"
    if s in ("failed", "error"):
        return "\033[31m✗\033[0m"
    return "\033[90m○\033[0m"


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return

    columns = int(data.get("columns") or 120)
    tasks = data.get("tasks") or []
    desc_budget = max(20, columns - 40)

    for t in tasks:
        tid = t.get("id")
        if not tid:
            continue
        name = (t.get("name") or "").strip()
        desc = (t.get("description") or "").strip().replace("\n", " ")
        if len(desc) > desc_budget:
            desc = desc[: desc_budget - 1] + "…"
        tokens = fmt_tokens(t.get("tokenCount"))
        body = (
            f"{glyph(t.get('status'))} "
            f"\033[1;97m{name}\033[0m"
            f" \033[90m·\033[0m \033[37m{desc}\033[0m"
            f" \033[90m·\033[0m \033[1;93m{tokens}\033[0m"
        )
        print(json.dumps({"id": tid, "content": body}, ensure_ascii=False))


if __name__ == "__main__":
    main()
