---
allowed-tools: Read(*), Write(*), Edit(*), Glob(*), Grep(*), Bash(git:*), Bash(mv:*), Bash(mkdir:*)
description: 整理知识库：归档、重组、清理重复内容
version: "1.0.0"
author: "公众号：手工川"
aliases: "/kb-organize"---

# Knowledge Base Organizer

整理和优化知识库结构。

## 输入格式

```
/kb-organize <action> [target]
```

### Actions

| Action | Description | Example |
|--------|-------------|---------|
| `scan` | 扫描并报告问题 | `/kb-organize scan` |
| `archive <path>` | 归档过时内容到 `__archive__/` | `/kb-organize archive blog/2020/old-post.md` |
| `dedup [dir]` | 检测重复/相似内容 | `/kb-organize dedup ai/` |
| `reorg <from> <to>` | 移动并更新引用 | `/kb-organize reorg docs/old/ docs/new/` |
| `images [dir]` | 整理图片到 attachments/ | `/kb-organize images blog/2024/` |
| `lint [dir]` | 检查格式问题 | `/kb-organize lint` |

## 执行逻辑

### 1. Parse Action
```
ACTION = $ARGUMENTS 的第一个词
TARGET = 剩余参数
```

### 2. Action: scan
扫描整个知识库，报告：
- 孤立文件（无引用的图片）
- 断链（引用不存在的文件）
- 空目录
- 格式不规范的文件名（应为 kebab-case 或中文）

输出格式：
```
## 扫描报告

### 孤立图片 (X个)
- path/to/orphan.png

### 断链 (X个)
- file.md:12 -> missing-ref.md

### 建议操作
- [ ] 归档 orphan.png
- [ ] 修复 file.md 中的链接
```

### 3. Action: archive
```
1. 检查目标文件存在
2. 创建对应的 __archive__/YYYY-MM-DD/ 目录
3. mv 文件到归档目录
4. 搜索并报告引用该文件的其他文件
5. 输出归档确认
```

### 4. Action: dedup
```
1. 提取目录下所有 .md 文件
2. 计算内容相似度（基于标题和前 500 字符）
3. 报告相似度 > 70% 的文件对
4. 建议合并或归档
```

### 5. Action: reorg
```
1. mv 源路径到目标路径
2. Grep 查找所有引用源路径的文件
3. 批量更新引用路径
4. 报告更新的文件列表
```

### 6. Action: images
```
1. 查找目录下所有图片文件
2. 检查是否在 attachments/ 子目录
3. 如不在，移动到最近的 attachments/
4. 更新 markdown 中的图片引用
```

### 7. Action: lint
检查项：
- [ ] 文件开头是否有 `#` 标题
- [ ] 图片路径是否为相对路径
- [ ] 链接是否有效
- [ ] 代码块是否指定语言

## Repository Context

```
ai/vibe-coding/     # Vibe Coding 方法论
ai/prompts/场景/    # 提示词模板
blog/               # 博客按年份组织
docs/               # 教程文档
TODO/               # 待办和草稿
__archive__/        # 归档内容
```

## 幂等原则

- 归档前检查目标是否已存在
- 移动前确认源文件存在
- 更新引用前备份原文件内容（Edit 自动保留）
- 重复执行 scan 应得到相同结果

## Output

执行完成后输出：
1. 执行了什么操作
2. 影响了哪些文件
3. 下一步建议（如有）
