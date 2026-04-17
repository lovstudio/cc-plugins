---
allowed-tools: [Bash, Read, Edit, Glob, Grep]
description: 全自动重命名项目：检测→替换→提交→推送→GitHub改名，无需确认
version: "2.0.0"
author: "公众号：手工川"
---

# Rename Project

全自动重命名项目，零交互完成：检测当前名 → 替换所有引用 → git commit & push → gh repo rename。

## Arguments
`<new-name>` - 新项目名称

## Process

### Step 1: Auto-Detect Current Name

```bash
# 优先从 GitHub remote 获取（最权威）
OLD_NAME=$(git remote get-url origin 2>/dev/null | sed 's/.*\/\([^\/]*\)\.git$/\1/' | sed 's/.*\/\([^\/]*\)$/\1/')

# 回退到目录名
[ -z "$OLD_NAME" ] && OLD_NAME=$(basename "$(pwd)")
```

如果 `OLD_NAME == NEW_NAME` → 直接退出，提示 "已是该名称"。

### Step 2: Scan & Replace

```bash
# 扫描所有文本文件中的旧名称
grep -r -l "$OLD_NAME" . --include="*.{json,md,yml,yaml,ts,tsx,js,jsx,toml,env*}" \
  2>/dev/null | grep -v -E "(node_modules|\.git|dist|build|\.next|vendor)"
```

对每个文件执行替换：
```bash
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" <file>
```

### Step 3: Git Commit & Push

```bash
git add -A
git commit -m "chore: rename project from $OLD_NAME to $NEW_NAME"
git push
```

### Step 4: GitHub Repo Rename

```bash
gh repo rename "$NEW_NAME" --yes
```

### Step 5: Summary

```
✓ $OLD_NAME → $NEW_NAME
✓ 更新 N 个文件
✓ 已提交并推送
✓ GitHub 仓库已重命名
```

## 无需确认

所有操作均可逆：
- 文件修改 → `git checkout .`
- 提交 → `git reset HEAD~1`
- GitHub 重命名 → 再次运行本命令

## 自动跳过

- `node_modules/`, `.git/`, `dist/`, `build/`, `.next/`, `vendor/`
- 二进制文件
- lock 文件内容

## 错误处理

- 无 git remote → 跳过 GitHub 重命名
- gh 未安装 → 跳过 GitHub 重命名，提示手动操作
- 无匹配文件 → 仅执行 GitHub 重命名
