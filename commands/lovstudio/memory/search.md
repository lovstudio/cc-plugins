---
allowed-tools: [Read, Glob, Grep, Bash]
description: 搜索知识库（memory + distill）
version: "1.0.0"
author: "公众号：手工川"
created: "2025-12-26"
aliases: "/memory-search"
---

# Memory Search

搜索知识库，支持跨 memory 和 distill 检索。

## Storage Locations

```
~/.lovstudio/docs/
├── memory/           # 通用知识
│   ├── index.jsonl
│   └── *.md
└── distill/          # 会话经验
    ├── index.jsonl
    └── *.md
```

## Process

### Step 1: Parse Query

```
/memory-search <query> [--scope memory|distill|all] [--tags tag1,tag2] [--category cat]
```

- `query`: 搜索关键词
- `--scope`: 搜索范围 (默认 all)
- `--tags`: 按标签筛选
- `--category`: 按分类筛选 (仅 memory)

### Step 2: Search Index

```bash
# Search memory index
grep -i "query" ~/.lovstudio/docs/memory/index.jsonl 2>/dev/null

# Search distill index
grep -i "query" ~/.lovstudio/docs/distill/index.jsonl 2>/dev/null
```

### Step 3: Full-text Search (if needed)

```bash
# Search file contents
grep -r -l -i "query" ~/.lovstudio/docs/memory/ --include="*.md" 2>/dev/null
grep -r -l -i "query" ~/.lovstudio/docs/distill/ --include="*.md" 2>/dev/null
```

### Step 4: Format Results

输出格式：
```markdown
## 搜索结果: "query"

### Memory (X 条)
1. **[Title](file.md)** - category - #tag1 #tag2
   > 摘要内容...

### Distill (X 条)
1. **[Title](file.md)** - #tag1 #tag2
   > 摘要内容...

---
共找到 N 条结果
```

### Step 5: Read Selected (Optional)

用户可指定序号查看完整内容：
```
/memory-search --read 1
```

## Search Modes

| Mode | Description | Example |
|------|-------------|---------|
| 关键词 | 标题和内容匹配 | `/memory-search tauri` |
| 标签 | 按标签筛选 | `/memory-search --tags rust,tauri` |
| 分类 | 按分类筛选 | `/memory-search --category tool` |
| 日期 | 按日期范围 | `/memory-search --after 2025-12-01` |

## Usage

```bash
/memory-search "快捷键"                        # 搜索所有知识库
/memory-search tauri --scope distill           # 仅搜索经验库
/memory-search --tags react                    # 按标签搜索
/memory-search git --category tool             # 按分类搜索
```

## Integration

- 与 `/memory-add` 配合添加新知识
- 与 `/distill` 互补检索会话经验
