---
allowed-tools: [Read, Write, Bash]
description: "Distill experiences into reusable wisdom, then auto-commit"
version: "3.6.0"
author: "公众号：手工川"
created: "2025-07-14"
updated: "2025-12-24"
aliases: "/distill"
---

# Wisdom Distillation

Refine real experiences into reusable wisdom. Keep it simple.

## Storage

```
~/.lovstudio/docs/distill/
├── index.jsonl                    # Append-only index
└── {YYYY-MM-DD}-{topic}.md        # Single flat files
```

## Process

### Step 1: Analyze Context
Scan conversation for valuable insights, lessons, or experiences worth preserving.

### Step 2: Ensure Directory
```bash
mkdir -p ~/.lovstudio/docs/distill
```

### Step 3: Write Distillation

**Filename**: `{YYYY-MM-DD}-{topic-slug}.md`

**Template**:
```markdown
# [Title]

**Date**: YYYY-MM-DD
**Tags**: #tag1 #tag2
**Source**: cc | codex | cursor | ...
**Stats**: ~N turns, ~M min

## 问题
[What happened / what was the challenge]

## 原因
[Root cause analysis]

## 解决
[What worked]

## 教训
[Key takeaways, generalizable principles]
```

### Step 4: Get Session Stats (Claude Code only)

**CRITICAL**: Use `$PWD` to find the correct project, not global search!

```bash
# Encode current working directory to project ID format
PROJECT_ID=$(echo "$PWD" | sed 's|/|-|g' | sed 's|^-||')
PROJECT_DIR="$HOME/.claude/projects/$PROJECT_ID"

# Get most recent session file in THIS project
if [ -d "$PROJECT_DIR" ]; then
  SESSION_FILE=$(ls -t "$PROJECT_DIR"/*.jsonl 2>/dev/null | grep -v "agent-" | head -1)
  SESSION_ID=$(basename "$SESSION_FILE" .jsonl 2>/dev/null)
else
  SESSION_FILE=""
  SESSION_ID=""
fi

# Extract stats from session file
if [ -n "$SESSION_FILE" ] && [ -f "$SESSION_FILE" ]; then
  TURNS=$(grep -c '"type":"user"' "$SESSION_FILE" 2>/dev/null || echo "0")
  FIRST_TS=$(grep '"timestamp"' "$SESSION_FILE" | head -1 | grep -o '"timestamp":"[^"]*"' | cut -d'"' -f4)
  LAST_TS=$(grep '"timestamp"' "$SESSION_FILE" | tail -1 | grep -o '"timestamp":"[^"]*"' | cut -d'"' -f4)
  if [ -n "$FIRST_TS" ] && [ -n "$LAST_TS" ]; then
    START_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${FIRST_TS%%.*}" "+%s" 2>/dev/null || echo "0")
    END_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${LAST_TS%%.*}" "+%s" 2>/dev/null || echo "0")
    DURATION_MIN=$(( (END_SEC - START_SEC) / 60 ))
  else
    DURATION_MIN=0
  fi
else
  TURNS=0
  DURATION_MIN=0
fi
```

### Step 5: Update Index (MANDATORY)

⚠️ **MUST execute this step** - append one line to index.jsonl:

```bash
# With session (Claude Code) - SESSION_ID must be valid UUID
if [ -n "$SESSION_ID" ] && [ "$SESSION_ID" != "unknown" ] && [ "$SESSION_ID" != "manual" ]; then
  echo '{"date":"YYYY-MM-DD","file":"YYYY-MM-DD-topic.md","title":"Title","tags":["tag1","tag2"],"source":"cc","session":"'"$SESSION_ID"'","turns":'"$TURNS"',"duration_min":'"$DURATION_MIN"'}' >> ~/.lovstudio/docs/distill/index.jsonl
else
  # Without valid session
  echo '{"date":"YYYY-MM-DD","file":"YYYY-MM-DD-topic.md","title":"Title","tags":["tag1","tag2"],"source":"cc"}' >> ~/.lovstudio/docs/distill/index.jsonl
fi
```

Replace placeholders with actual values. This step is NOT optional.

**Index fields**:
- `date`: Distillation date
- `file`: Markdown filename
- `title`: Document title
- `tags`: Array of tags (optional, defaults to [])
- `source`: Tool source - "cc" (Claude Code), "codex", "cursor", etc. (required)
- `session`: Session UUID (optional, omit if not available - NEVER use "unknown"/"manual")
- `turns`: Number of conversation turns (optional)
- `duration_min`: Session duration in minutes (optional)

### Step 6: Auto-Commit (if in git repo)

Distillation implies the problem is solved. Auto-commit changes from this conversation.

```bash
# Check if in git repo with uncommitted changes
if git rev-parse --git-dir > /dev/null 2>&1; then
  if [ -n "$(git status --porcelain)" ]; then
    # Stage all changes and commit
    git add -A
    # Generate commit message based on conversation context
    # Use conventional commit format, Chinese description
  fi
fi
```

**Commit generation**:
1. Review conversation history for changes made
2. Determine commit type (feat/fix/refactor/docs/chore)
3. Generate conventional commit: `type(scope): 中文描述`
4. Execute `git add -A && git commit -m "..."`
5. Show commit result

**Skip commit**: Add `--no-commit` argument to skip auto-commit.

## Source Identifiers

| Source | Description |
|--------|-------------|
| `cc` | Claude Code (default) |
| `codex` | OpenAI Codex CLI |
| `cursor` | Cursor IDE |
| `copilot` | GitHub Copilot |
| `other` | Other tools |

## Quality Standards

**Good**:
- Actionable: Others can apply this
- Specific: Concrete, not vague
- Balanced: Acknowledges trade-offs

**Avoid**:
- Too abstract ("communication is important")
- Too specific (only applies to one case)

## Usage

```bash
/distill                           # Distill + auto-commit
/distill "API design patterns"     # Distill with topic focus + commit
/distill --no-commit               # Distill only, skip commit
/distill codex "debugging tips"    # Distill from Codex session
```
