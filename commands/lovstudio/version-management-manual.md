---
allowed-tools: [Bash, Read, Write, Edit, Grep, Glob]
description: AI 生成 changeset 后打开编辑器修改
version: "1.0.0"
author: "公众号：手工川"
aliases: "/version-management-manual"---

# Version Management Manual

与 `/version-management` 相同，但在生成 changeset 后会打开编辑器让用户修改。

## 执行流程

### 1. 执行 /version-management 的 add 流程

按照 `/version-management` 的逻辑：
1. 检测环境，必要时初始化
2. 分析 git diff
3. 判断变更类型
4. 生成 `.changeset/xxx.md` 文件

### 2. 打开编辑器（阻塞式）

```bash
CHANGESET_FILE=".changeset/${FILENAME}.md"

# macOS: 使用默认 markdown 编辑器，-W 等待关闭
open -W "$CHANGESET_FILE"

# 备选（通用）: 使用 $EDITOR
# ${EDITOR:-vim} "$CHANGESET_FILE"
```

### 3. 编辑器关闭后

显示最终内容：
```bash
echo "Changeset 已保存："
cat "$CHANGESET_FILE"
```

## 使用场景

- AI 生成的描述不够准确，需要人工润色
- 需要补充更多上下文信息
- 变更复杂，需要详细说明

## 命令示例

```bash
/version-management-manual          # AI 生成 + 打开编辑器
/version-management-manual status   # 等同于 /version-management status
/version-management-manual release  # 等同于 /version-management release
```

注：只有 `add`（默认）操作会打开编辑器，其他操作与 `/version-management` 行为一致。
