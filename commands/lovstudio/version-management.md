---
allowed-tools: [Bash, Read, Write, Edit, Grep, Glob]
description: 使用 changeset 管理版本和 CHANGELOG
version: "2.0.0"
author: "公众号：手工川"
aliases: "/version-management"---

# Version Management with Changeset

使用 changeset 工具专业管理版本发布和 CHANGELOG 生成。

## 执行流程

### 1. 检测环境

```bash
# 检查 changeset 是否可用
ls node_modules/.bin/changeset 2>/dev/null || npx changeset --version
```

如果项目没有 `.changeset` 目录，先初始化：
```bash
npx changeset init
```

### 2. 根据参数路由

| 参数 | 操作 |
|------|------|
| (无) / `add` | AI 分析变更，生成 changeset |
| `status` | `npx changeset status` |
| `version` | `npx changeset version` |
| `release` | version → commit → tag |
| `publish` | `npx changeset publish` |

### 3. Add 操作（默认）

AI 自动分析并生成 changeset：

1. **分析变更**
   ```bash
   git diff --cached --stat   # 已暂存
   git diff --stat            # 未暂存
   git log -3 --oneline       # 最近提交
   ```

2. **判断变更类型**
   - `patch`: bug 修复、小改动
   - `minor`: 新功能、非破坏性增强
   - `major`: 破坏性变更、API 改动

3. **生成 changeset 文件**
   ```bash
   # 生成唯一文件名
   FILENAME=$(echo "$(date +%s)-$(head -c 4 /dev/urandom | xxd -p)" | head -c 16)

   # 写入 .changeset/
   cat > ".changeset/${FILENAME}.md" << 'EOF'
   ---
   "package-name": patch
   ---

   变更描述（用户可见的语言）
   EOF
   ```

4. **输出结果**
   - 显示生成的文件路径
   - 显示 changeset 内容

### 4. Release 操作

```bash
# 1. 消费 changeset
npx changeset version

# 2. 读取新版本号
NEW_VERSION=$(node -p "require('./package.json').version")

# 3. 提交
git add .
git commit -m "chore(release): v${NEW_VERSION}"

# 4. 打 tag
git tag "v${NEW_VERSION}"

echo "Released v${NEW_VERSION}"
```

## Changeset 文件格式

```markdown
---
"package-name": minor
---

添加了用户导出功能，支持 CSV 和 JSON 格式
```

- frontmatter: 包名和版本类型
- body: 人类友好的变更描述（会进入 CHANGELOG）

## Monorepo 支持

对于 monorepo，分析每个受影响的包：
```bash
git diff --name-only | grep -E '^packages/' | cut -d'/' -f2 | sort -u
```

生成的 changeset 可包含多个包：
```markdown
---
"@scope/pkg-a": minor
"@scope/pkg-b": patch
---

描述变更内容
```

## 命令示例

```bash
/version-management          # AI 分析生成 changeset
/version-management status   # 查看待发布变更
/version-management release  # 发布：version + commit + tag
```
