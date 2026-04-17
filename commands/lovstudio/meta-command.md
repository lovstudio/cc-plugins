---
allowed-tools: Write(*), Read(*), Edit(*), Bash(ls:*), Bash(date:*), Bash(mkdir:*), AskUserQuestion
description: Generate optimized slash commands
version: "4.2.0"
author: "公众号：手工川"
aliases: "/meta-command"
---

# Meta Command

Create or iterate slash commands.

## Arguments Format
`<name> ["<description>"] [project|user] [requirements/feedback]`

## Process

### Step 1: Check Existence

    ls ~/.claude/commands/lovstudio/<name>.md

### Step 2: Clarify Requirements (苏格拉底式追问)

在生成或修改命令前，使用 AskUserQuestion 澄清模糊点：

**必问问题**（如果参数未提供）：
- 命令的**核心场景**是什么？（谁在什么情况下用？）
- 期望的**输入→输出**是什么？
- 有没有**边界情况**需要处理？

**追问技巧**（参考 brainstorm）：
- 不假设：对模糊表述追问「具体指什么？」
- 挖动机：问「为什么需要这个？」而非直接实现
- 暴露矛盾：「你既想 X 又想 Y，如何取舍？」

**何时跳过追问**：
- 用户已给出详细的 requirements
- 迭代模式下用户只是修 bug/小改动
- 上下文中已有足够信息

### Step 3: Route by Result

**If NOT exists** → Create Mode:
- `mkdir -p ~/.claude/commands/lovstudio/`
- Generate `lovstudio/<name>.md` with v1.0.0
- Generate `lovstudio/<name>.changelog`

**If EXISTS** → Iterate Mode:
- Read current `<name>.md`
- Read `<name>.changelog` (if exists)
- Analyze current implementation
- Apply improvements based on:
  - User feedback in arguments
  - Conversation context (recent usage issues, edge cases)
  - Design principles below
- Bump version (patch/minor/major per change scope)
- Update changelog

## File Templates

**<name>.md**:

    ---
    allowed-tools: [minimal required tools]
    description: one-line description
    version: "x.y.z"
    author: "公众号：手工川"
    ---
    # Command logic

**<name>.changelog**:

    # Changelog for <name>

    ## vX.Y.Z - YYYY-MM-DD
    - Change description

    Author: 公众号：手工川

## Design Principles

1. **Idempotent**: Safe to run multiple times
2. **Minimal**: Only necessary tools and logic
3. **Robust**: Handle edge cases gracefully
4. **Clear**: Self-documenting, no ambiguity

## Version Bump Rules
- **Patch** (x.y.Z): Bug fixes, typos
- **Minor** (x.Y.0): New features, improvements
- **Major** (X.0.0): Breaking changes, redesign

## Tool Reference
- Git: `Bash(git:*)`
- GitHub: `Bash(gh:*)`
- Files: `Read(*)`, `Write(*)`, `Edit(*)`
- Search: `Glob(*)`, `Grep(*)`
- Web: `WebFetch(*)`, `WebSearch(*)`
