#!/bin/bash
# Description: Full-featured statusline with comprehensive metrics and daily tracking
# =============================================================================
# Claude Code Custom Statusline
# =============================================================================
# Author: Mark Shawn (https://github.com/markshawn2020)
# Community: Vibe Genius
# Version: 1.0.0
# Date: 2025-08-27
# 
# Description:
#   A comprehensive statusline for Claude Code that displays:
#   - Current time and daily cost tracking
#   - Working directory and git branch
#   - Session metrics (duration, cost, code changes)
#   - Model information
#
# Features:
#   ✓ Real-time session cost and duration tracking
#   ✓ Daily cost accumulation with automatic reset
#   ✓ Git branch awareness
#   ✓ Code changes statistics (lines added/removed)
#   ✓ Beautiful ANSI color formatting
#
# Installation:
#   1. Save this script to ~/.claude/statusline.sh
#   2. Make it executable: chmod +x ~/.claude/statusline.sh
#   3. Add to ~/.claude/settings.json:
#      {
#        "statusLine": {
#          "type": "command",
#          "command": "~/.claude/statusline.sh",
#          "padding": 0
#        }
#      }
#
# =============================================================================

# Read JSON input
input=$(cat)

# Extract values using jq
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
COST_USD=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
SESSION_ID=$(echo "$input" | jq -r '.session_id // ""')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Get current time with date (without year and seconds)
CURRENT_TIME=$(date +"%m-%d %H:%M")

# Daily cost tracking file
TODAY=$(date +"%Y-%m-%d")
COST_FILE="$HOME/.claude/.daily_costs"
COST_SESSIONS_FILE="$HOME/.claude/.daily_sessions"

# Initialize or update daily cost
if [ -n "$SESSION_ID" ]; then
    # Check if this session has been tracked today
    if [ -f "$COST_SESSIONS_FILE" ]; then
        SESSION_TRACKED=$(grep "^$TODAY:$SESSION_ID:" "$COST_SESSIONS_FILE" 2>/dev/null | cut -d: -f3)
    else
        SESSION_TRACKED="0"
    fi
    
    # Calculate new cost for this session
    SESSION_COST_DIFF=$(echo "$COST_USD - ${SESSION_TRACKED:-0}" | bc 2>/dev/null || echo "0")
    
    # Update session tracking
    if [ "$SESSION_COST_DIFF" != "0" ] && [ "$SESSION_COST_DIFF" != "0.000" ]; then
        # Update session record
        grep -v "^$TODAY:$SESSION_ID:" "$COST_SESSIONS_FILE" 2>/dev/null > "$COST_SESSIONS_FILE.tmp" || true
        echo "$TODAY:$SESSION_ID:$COST_USD" >> "$COST_SESSIONS_FILE.tmp"
        mv "$COST_SESSIONS_FILE.tmp" "$COST_SESSIONS_FILE" 2>/dev/null || true
        
        # Update daily total
        if [ -f "$COST_FILE" ]; then
            DAILY_COST=$(grep "^$TODAY:" "$COST_FILE" 2>/dev/null | cut -d: -f2 || echo "0")
        else
            DAILY_COST="0"
        fi
        NEW_DAILY_COST=$(echo "$DAILY_COST + $SESSION_COST_DIFF" | bc 2>/dev/null || echo "0")
        grep -v "^$TODAY:" "$COST_FILE" 2>/dev/null > "$COST_FILE.tmp" || true
        echo "$TODAY:$NEW_DAILY_COST" >> "$COST_FILE.tmp"
        mv "$COST_FILE.tmp" "$COST_FILE" 2>/dev/null || true
    fi
fi

# Read daily cost
if [ -f "$COST_FILE" ]; then
    DAILY_COST=$(grep "^$TODAY:" "$COST_FILE" 2>/dev/null | cut -d: -f2 || echo "0")
else
    DAILY_COST="0"
fi

# Format daily cost
DAILY_COST_STR=$(printf "$%.2f" $DAILY_COST 2>/dev/null || echo "$0.00")

# Get directory name (basename)
DIR_NAME=$(basename "$CURRENT_DIR")

# Get git branch if in a git repo
GIT_BRANCH=""
if [ -d "$CURRENT_DIR/.git" ] || git -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" \033[91m(\033[0m\033[91m$BRANCH\033[0m\033[91m)\033[0m"
    fi
fi

# Format duration (convert ms to human-readable)
format_duration() {
    local ms=$1
    local seconds=$((ms / 1000))
    local minutes=$((seconds / 60))
    local hours=$((minutes / 60))
    
    if [ $hours -gt 0 ]; then
        printf "%dh %dm" $hours $((minutes % 60))
    elif [ $minutes -gt 0 ]; then
        printf "%dm %ds" $minutes $((seconds % 60))
    else
        printf "%ds" $seconds
    fi
}

DURATION_STR=$(format_duration $DURATION_MS)

# Format cost with proper decimal places
COST_STR=$(printf "$%.3f" $COST_USD)

# Format lines changes
if [ "$LINES_ADDED" -gt 0 ] || [ "$LINES_REMOVED" -gt 0 ]; then
    LINES_STR=" 📊 \033[92m+$LINES_ADDED\033[0m/\033[91m-$LINES_REMOVED\033[0m"
else
    LINES_STR=""
fi

# Format session ID (first 8 chars)
SESSION_SHORT="${SESSION_ID:0:8}"

# Get Claude Code version
CC_VERSION=$(claude code --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if [ -n "$CC_VERSION" ]; then
    VERSION_STR="V$CC_VERSION "
else
    VERSION_STR=""
fi

# Detect provider from ANTHROPIC_BASE_URL
detect_provider() {
    local base_url="${ANTHROPIC_BASE_URL:-}"

    if [ -z "$base_url" ]; then
        echo "anthropic"
        return
    fi

    case "$base_url" in
        *"zenmux"*)      echo "zenmux" ;;
        *"modelgate"*)   echo "modelgate" ;;
        *"qiniu"*)       echo "qiniu" ;;
        *"siliconflow"*) echo "siliconflow" ;;
        *"univibe"*)     echo "univibe" ;;
        *"openrouter"*)  echo "openrouter" ;;
        *"openai"*)      echo "openai" ;;
        *"anthropic"*)   echo "anthropic" ;;
        *"localhost"*|*"127.0.0.1"*) echo "local" ;;
        *)               echo "custom" ;;
    esac
}

PROVIDER=$(detect_provider)

# Daily token tracking — incremental scan of the current session's transcript.
# Cache file format, one line per (day, session): "YYYY-MM-DD:session_id:byte_offset:session_token_total"
# Daily total is derived by summing session_token_total across lines matching TODAY.
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // ""')
TOKEN_FILE="$HOME/.claude/.daily_tokens"
DAILY_TOKENS=0
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ] && [ -n "$SESSION_ID" ]; then
    FILE_SIZE=$(stat -f%z "$TRANSCRIPT_PATH" 2>/dev/null || echo 0)
    PREV_LINE=$(grep "^$TODAY:$SESSION_ID:" "$TOKEN_FILE" 2>/dev/null | tail -1)
    PREV_OFFSET=$(echo "$PREV_LINE" | cut -d: -f3)
    PREV_TOKENS=$(echo "$PREV_LINE" | cut -d: -f4)
    PREV_OFFSET=${PREV_OFFSET:-0}
    PREV_TOKENS=${PREV_TOKENS:-0}
    # If the file shrunk (session restart / truncation), restart from 0.
    if [ "$FILE_SIZE" -lt "$PREV_OFFSET" ]; then
        PREV_OFFSET=0
        PREV_TOKENS=0
    fi
    if [ "$FILE_SIZE" -gt "$PREV_OFFSET" ]; then
        DELTA_TOKENS=$(tail -c +$((PREV_OFFSET + 1)) "$TRANSCRIPT_PATH" 2>/dev/null | python3 -c '
import json, sys
total = 0
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try:
        d = json.loads(line)
    except Exception:
        continue
    if d.get("type") != "assistant": continue
    u = d.get("message", {}).get("usage", {}) or {}
    total += (u.get("input_tokens", 0) or 0) + (u.get("output_tokens", 0) or 0) \
           + (u.get("cache_creation_input_tokens", 0) or 0) + (u.get("cache_read_input_tokens", 0) or 0)
print(total)
' 2>/dev/null || echo 0)
        NEW_TOKENS=$((PREV_TOKENS + DELTA_TOKENS))
        grep -v "^$TODAY:$SESSION_ID:" "$TOKEN_FILE" 2>/dev/null > "$TOKEN_FILE.tmp" || true
        echo "$TODAY:$SESSION_ID:$FILE_SIZE:$NEW_TOKENS" >> "$TOKEN_FILE.tmp"
        # Prune entries from previous days to keep the file small.
        grep "^$TODAY:" "$TOKEN_FILE.tmp" > "$TOKEN_FILE.tmp2" 2>/dev/null || true
        mv "$TOKEN_FILE.tmp2" "$TOKEN_FILE" 2>/dev/null || mv "$TOKEN_FILE.tmp" "$TOKEN_FILE" 2>/dev/null
        rm -f "$TOKEN_FILE.tmp"
    fi
    DAILY_TOKENS=$(grep "^$TODAY:" "$TOKEN_FILE" 2>/dev/null | awk -F: '{s+=$4} END{print s+0}')
fi

# Format token count as 1.2K / 3.4M
format_tokens() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        python3 -c "print(f'{$n/1000000:.1f}M')"
    elif [ "$n" -ge 1000 ]; then
        python3 -c "print(f'{$n/1000:.1f}K')"
    else
        echo "$n"
    fi
}
TOKENS_STR=$(format_tokens "${DAILY_TOKENS:-0}")

# Session title: prefer the latest type:summary entry in the transcript,
# fall back to the first user prompt. Keep it cheap — tail -r + grep -m1.
TITLE=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    TITLE=$(tail -r "$TRANSCRIPT_PATH" 2>/dev/null | grep -m1 '"type":"summary"' \
        | jq -r '.summary // ""' 2>/dev/null)
    if [ -z "$TITLE" ]; then
        TITLE=$(grep -m1 '"type":"user"' "$TRANSCRIPT_PATH" 2>/dev/null \
            | jq -r '(.message.content // "") | if type=="string" then . else (.[0].text // "") end' 2>/dev/null \
            | tr '\n' ' ' | cut -c1-40)
    fi
fi
if [ -n "$TITLE" ]; then
    TITLE_STR=" \033[36m│\033[0m \033[1;97m$TITLE\033[0m"
else
    TITLE_STR=""
fi

# Output with colors (using ANSI escape codes)
# Format: 💥 MM-DD HH:MM ($X.XX) │ Model (provider) │ directory (branch) #session │ V2.0.73 │ title
# Line 1: status header — cwd (branch) │ model (provider) │ cost / tokens │ version
echo -e "💥 \033[96m$DIR_NAME\033[0m$GIT_BRANCH \033[36m│\033[0m \033[35m$MODEL\033[0m \033[90m($PROVIDER)\033[0m \033[36m│\033[0m \033[1;92m$DAILY_COST_STR\033[0m \033[90m/\033[0m \033[1;93m$TOKENS_STR\033[0m \033[36m│\033[0m \033[33m$VERSION_STR\033[0m"
# Line 2: 💬 <session title> · #<session short id>
if [ -n "$TITLE" ]; then
    echo -e "💬 \033[0;97m$TITLE\033[0m \033[90m· #$SESSION_SHORT\033[0m"
else
    echo -e "💬 \033[90m#$SESSION_SHORT\033[0m"
fi

# End of statusline script
# Shared with love by Mark Shawn for the Vibe Genius community 💜