---
allowed-tools: [Read, Write, Bash]
description: 将信息添加到知识库，支持分类和标签
version: "1.0.0"
author: "公众号：手工川"
created: "2025-12-26"
aliases: "/memory-add"
---

# Memory Add

将信息添加到知识库，便于后续检索。

## Storage

```
~/.lovstudio/docs/memory/
├── index.jsonl                    # Append-only index
└── {YYYY-MM-DD}-{topic}.md        # Knowledge files
```

## Process

### Step 1: Parse Input

```
/memory-add [category] "title" [--tags tag1,tag2]
```

- `category`: 可选分类 (tech/tool/concept/snippet/ref)
- `title`: 知识标题（必填）
- `--tags`: 可选标签列表

若无显式 category，根据内容自动推断。

### Step 2: Ensure Directory

```bash
mkdir -p ~/.lovstudio/docs/memory
```

### Step 3: Gather Content

询问用户要记录的具体内容，或从当前会话上下文中提取。

**可记录内容类型**:
- 代码片段 (snippet)
- 工具用法 (tool)
- 技术概念 (concept)
- 参考资料 (ref)
- 经验技巧 (tech)

### Step 4: Write Memory File

**Filename**: `{YYYY-MM-DD}-{topic-slug}.md`

**Template**:
```markdown
# [Title]

**Date**: YYYY-MM-DD
**Category**: tech | tool | concept | snippet | ref
**Tags**: #tag1 #tag2
**Source**: url | project | manual

## 内容

[Main content here]

## 用法/示例

[Usage examples if applicable]

## 相关

- [[related-topic]]
```

### Step 5: Update Index (MANDATORY)

```bash
echo '{"date":"YYYY-MM-DD","file":"filename.md","title":"Title","category":"tech","tags":["tag1"],"source":"manual"}' >> ~/.lovstudio/docs/memory/index.jsonl
```

**Index fields**:
- `date`: 添加日期
- `file`: Markdown 文件名
- `title`: 标题
- `category`: 分类
- `tags`: 标签数组
- `source`: 来源 (url/project/manual)

## Categories

| Category | Description | Example |
|----------|-------------|---------|
| `tech` | 技术经验/技巧 | React hooks 使用模式 |
| `tool` | 工具/CLI 用法 | gh CLI 常用命令 |
| `concept` | 概念/理论 | CAP 定理解释 |
| `snippet` | 代码片段 | 常用 TypeScript 类型 |
| `ref` | 参考资料/链接 | 官方文档链接集合 |

## Usage

```bash
/memory-add "Git 常用命令"                     # 手动输入内容
/memory-add tool "Tauri CLI 用法" --tags tauri,rust
/memory-add snippet "TypeScript 工具类型"      # 代码片段
/memory-add ref "React 19 新特性" --tags react
```

## Integration

- 与 `/memory-search` 配合使用检索
- 与 `/distill` 互补：distill 记录会话经验，memory 记录通用知识
