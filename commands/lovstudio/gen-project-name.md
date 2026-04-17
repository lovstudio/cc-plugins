---
allowed-tools: []
description: "基于需求生成项目名（Mac文件夹兼容）"
version: "1.0.0"
author: "公众号：手工川"
---
# Project Name Generator

基于用户需求生成项目名候选，可直接用作 Mac 文件夹名。

## 输入

$ARGUMENTS = 用户的项目需求描述

如果 $ARGUMENTS 为空，使用 AskUserQuestion 询问：
- 项目是做什么的？
- 目标用户/平台是什么？

## 生成规则

1. **Mac 文件夹兼容**：仅使用 `a-z 0-9 -_`，不以 `.` 开头，不超过 50 字符
2. **命名风格自动选择**：
   - 前端/Node 项目 → kebab-case
   - Python 项目 → snake_case
   - 通用/不确定 → kebab-case
3. **生成 3 组候选**，每组包含：
   - **创意名**：品牌感强、有寓意、好记（如 aurora, brevity, inkwell）
   - **描述名**：一看就懂功能（如 ai-image-editor, markdown-converter）

## 输出格式

直接输出表格，不要多余废话：

| # | 创意名 | 描述名 | 灵感来源 |
|---|--------|--------|----------|
| 1 | xxx    | xxx    | 一句话解释创意名含义 |
| 2 | xxx    | xxx    | ... |
| 3 | xxx    | xxx    | ... |

然后问用户：选哪个？或者给反馈我继续迭代。
