#!/bin/bash
# 激活 iTerm2 中保存的 tmux 环境

# terminal-notifier 执行时 PATH 不完整
export PATH="/opt/homebrew/bin:$PATH"

CONTEXT_FILE="/tmp/tmux-notify-context"
LOG="/tmp/activate-tmux-debug.log"

echo "[DEBUG] ========== $(date) ==========" >> "$LOG"

# 读取上下文
if [ ! -f "$CONTEXT_FILE" ]; then
    echo "[DEBUG] 错误: 上下文文件不存在" >> "$LOG"
    exit 1
fi

source "$CONTEXT_FILE"
echo "[DEBUG] session=$TMUX_SESSION, window=$TMUX_WINDOW, pane=$TMUX_PANE" >> "$LOG"

# 激活 iTerm2 并切换到对应 tab
osascript <<EOF 2>> "$LOG"
tell application "iTerm2"
    activate

    set targetTab to missing value
    set targetWindow to missing value

    repeat with w in windows
        repeat with t in tabs of w
            repeat with s in sessions of t
                if name of s contains "$TMUX_SESSION" then
                    set targetTab to t
                    set targetWindow to w
                    exit repeat
                end if
            end repeat
            if targetTab is not missing value then exit repeat
        end repeat
        if targetTab is not missing value then exit repeat
    end repeat

    if targetTab is not missing value then
        select targetWindow
        select targetTab
    end if
end tell
EOF

echo "[DEBUG] osascript 退出码: $?" >> "$LOG"

# 切换 tmux 窗口和 pane
tmux select-window -t "${TMUX_SESSION}:${TMUX_WINDOW}" 2>> "$LOG"
echo "[DEBUG] select-window 退出码: $?" >> "$LOG"

tmux select-pane -t "${TMUX_SESSION}:${TMUX_WINDOW}.${TMUX_PANE}" 2>> "$LOG"
echo "[DEBUG] select-pane 退出码: $?" >> "$LOG"

echo "[DEBUG] 完成" >> "$LOG"
