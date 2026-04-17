#!/bin/bash
# 触发 Mac 通知，点击后激活当前 tmux 环境
# 每个通知独立保存上下文
# 依赖: terminal-notifier (brew install terminal-notifier)

# 获取当前 tmux 上下文
TMUX_SESSION=$(tmux display-message -p '#S' 2>/dev/null)
TMUX_WINDOW=$(tmux display-message -p '#I' 2>/dev/null)
TMUX_PANE=$(tmux display-message -p '#P' 2>/dev/null)

if [ -z "$TMUX_SESSION" ]; then
    echo "错误: 不在 tmux 环境中"
    exit 1
fi

# 生成唯一 ID
NOTIFY_ID=$(date +%s%N)
ACTIVATE_SCRIPT="/tmp/activate-tmux-${NOTIFY_ID}.sh"

# 生成独立的激活脚本
cat > "$ACTIVATE_SCRIPT" <<EOF
#!/bin/bash
export PATH="/opt/homebrew/bin:\$PATH"

TMUX_SESSION="$TMUX_SESSION"
TMUX_WINDOW="$TMUX_WINDOW"
TMUX_PANE="$TMUX_PANE"

# 激活 iTerm2 并切换到对应 tab
osascript <<APPLESCRIPT
tell application "iTerm2"
    activate
    repeat with w in windows
        repeat with t in tabs of w
            repeat with s in sessions of t
                if name of s contains "\${TMUX_SESSION}" then
                    select w
                    select t
                    return
                end if
            end repeat
        end repeat
    end repeat
end tell
APPLESCRIPT

# 切换 tmux 窗口和 pane
tmux select-window -t "\${TMUX_SESSION}:\${TMUX_WINDOW}"
tmux select-pane -t "\${TMUX_SESSION}:\${TMUX_WINDOW}.\${TMUX_PANE}"

# 清理自身
rm -f "$ACTIVATE_SCRIPT"
EOF

chmod +x "$ACTIVATE_SCRIPT"

# 发送通知
terminal-notifier \
    -title "Claude Code" \
    -message "任务完成，点击查看" \
    -execute "$ACTIVATE_SCRIPT" \
    -sound default \
    -group "claude-${NOTIFY_ID}"
