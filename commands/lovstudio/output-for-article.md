---
allowed-tools: Write(*), Read(*), Edit(*), Glob(*), AskUserQuestion(*)
description: 将AI回复输出为文章文件，存储在当前目录的 articles 子文件夹
version: "1.1.0"
author: "公众号：手工川"
aliases: "/output-for-article"
---

# Output for Article

将回复输出为文章文件，存储在当前工作目录的 `articles/` 子文件夹下。

## 使用方式

```
/output-for-article [filename] [content_description]
```

无文件名时使用 `article-YYYYMMDD-HHMMSS.md`

## 格式支持

根据文件扩展名自动识别：
- `.md` (默认) - Markdown，可嵌套格式
- `.txt` - 纯文本
- `.json` - JSON
- `.yaml` / `.yml` - YAML
- 其他 - 按纯文本处理

无扩展名时自动添加 `.md`

## Markdown 格式规范

输出 markdown 时遵守以下规则确保可嵌套：

### 代码块
- **禁止**三反引号 (```)
- 使用 4 空格缩进：

    function example() {
        return "safe";
    }

### 内联代码
- 单反引号 `code` 正常使用
- 双反引号 ``code with `tick` `` 用于含反引号的代码

### 其他
- 避免连续三个以上波浪号 (~~~)
- 表格、列表、标题正常使用

## 执行流程

1. 解析文件名参数，无则生成时间戳名 `article-YYYYMMDD-HHMMSS`
2. 无扩展名则加 `.md`
3. 确保目录存在：`mkdir -p ./articles`
4. 根据扩展名确定格式
5. 生成符合格式规范的内容
6. 写入 `./articles/<filename>`
7. 输出文件完整路径

## 示例

```
/output-for-article api-guide 编写 REST API 指南
```
→ 输出 `./articles/api-guide.md`

```
/output-for-article weekly-review.txt 本周技术总结
```
→ 输出 `./articles/weekly-review.txt`
