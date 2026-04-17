---

allowed-tools: [Read, Write, Edit, Bash, Glob, AskUserQuestion]
description: Update statusline config with version management and rollback support
version: "1.0.0"
author: "公众号:手工川"
aliases: /better-statusline
---

# Better Statusline

Update Claude Code statusline based on user requirements with full version management.

## Process

### 1. Locate Config File

```bash
config_path=~/.claude/settings.json
```

### 2. Backup Current Version

Before any changes:
- Read current `settings.json`
- Extract current statusline value
- Generate version ID: `YYYYMMDD_HHMMSS`
- Save to `~/.claude/statusline-versions/<version_id>.json`:
  ```json
  {
    "timestamp": "YYYY-MM-DD HH:MM:SS",
    "statusline": "current value"
  }
  ```

### 3. Parse User Requirements

Analyze user input for:
- Static text elements
- Dynamic variables (git branch, time, etc.)
- Formatting preferences (colors, separators)
- Position/order of elements

### 4. Build New Statusline

Common patterns:
- `{git_branch}` - Current git branch
- `{cwd}` - Current working directory
- `{time}` - Current time
- `{user}` - Username
- Custom text and symbols

### 5. Update Config

Use Edit tool to update `statusline` field in settings.json

### 6. Verify Update

- Re-read settings.json
- Confirm new value matches intent
- Display before/after comparison

### 7. Show Rollback Instructions

```
Version saved as: <version_id>
To rollback, run: /lovstudio/better-statusline rollback <version_id>
To list versions: /lovstudio/better-statusline list
```

## Rollback Mode

When arguments contain "rollback <version_id>":

1. Read `~/.claude/statusline-versions/<version_id>.json`
2. Extract statusline value
3. Backup current (as new version)
4. Apply old version to settings.json
5. Confirm restoration

## List Mode

When arguments contain "list":

1. `ls ~/.claude/statusline-versions/`
2. Read each version file
3. Display table:
   ```
   Version ID        Timestamp            Statusline Preview
   20250101_120000   2025-01-01 12:00:00  {git_branch} | ...
   ```

## Edge Cases

- Missing `~/.claude/statusline-versions/` → Create directory
- No existing statusline field → Add new field
- Invalid version_id for rollback → List available versions
- Empty user requirements → Ask for clarification

## Examples

**Input**: "显示 git 分支和当前时间"
**Output**: `{git_branch} | {time}`

**Input**: "加上项目路径,用箭头分隔"
**Output**: `{cwd} → {git_branch} → {time}`

**Input**: "rollback 20250115_143022"
**Action**: Restore statusline from that version

ARGUMENTS: $ARGUMENTS
