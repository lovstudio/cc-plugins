---
allowed-tools: [Bash, Read, Edit]
description: Generate git commit from conversation context changes
version: "1.1.0"
author: "公众号：手工川"
aliases: "/git-commit-with-context"
---

# Git Commit with Context

Generate git commit based on changes made during the current conversation.

## Configuration

    default_language: "zh-CN"
    commit_style: "conventional"

## Workflow

### Phase 1: Analyze Conversation Context (NO git commands yet)

1. **Review conversation history**:
   - Identify all file changes made during this conversation
   - Note which files were created, modified, or deleted
   - **Build explicit file list** for selective staging
   - Understand the purpose and scope of changes
   - Extract key features, fixes, or improvements

2. **Determine commit type**:
   - feat: 新功能
   - fix: 修复bug
   - docs: 文档更新
   - style: 代码格式调整
   - refactor: 重构
   - perf: 性能优化
   - test: 测试相关
   - build: 构建系统
   - ci: CI/CD配置
   - chore: 其他更改

3. **Generate commit message**:
   - Use conventional commit format: type(scope): description
   - Write description in Chinese by default
   - Keep subject line under 50 characters
   - Add detailed body if needed (wrapped at 72 characters)

### Phase 2: Execute Commit (Fast)

4. **Stage ONLY session files and commit**:
   - **IMPORTANT**: Only stage files modified in THIS conversation
   - Run `git add <file1> <file2> ...` with explicit file paths
   - **DO NOT use `git add -A`** to avoid conflicts with other sessions
   - Create commit with generated message
   - Show commit result

## Key Principles

- **Context-first**: Analyze conversation context BEFORE running git commands
- **Session-scoped**: Only commit files changed in current conversation
- **Conflict-safe**: Avoid staging unrelated changes from other sessions
- **Fast execution**: Skip `git status`/`git diff` analysis - we already know changes
- **Auto commit**: No confirmation needed
- **Conventional commits**: Use standard commit format

## Example

User made changes during conversation:
- Created `src/components/Button.tsx`
- Modified `src/App.tsx` to use Button
- Updated `package.json` dependencies

Generated commit:
```bash
# Stage only session files
git add src/components/Button.tsx src/App.tsx package.json

# Commit
git commit -m "feat(components): 新增 Button 组件

- 创建 Button 组件支持多种样式变体
- 在 App 中集成 Button 组件
- 更新相关依赖"
```

## Command Behavior

1. **Analyze context** - Review what was changed in this conversation
2. **Build file list** - Collect all files modified in session
3. **Generate message** - Create conventional commit message
4. **Selective stage** - `git add` only session files (NOT `-A`)
5. **Auto commit** - Commit without confirmation
6. **Show result** - Display commit hash and summary
