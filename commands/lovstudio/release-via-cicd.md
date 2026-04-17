---
allowed-tools: Bash(git:*), Bash(gh:*), Bash(node:*), Bash(pnpm:*), Bash(npm:*), Bash(npx:*), Bash(find:*), Bash(sleep:*), Bash(ls:*), Bash(cat:*), Bash(jq:*), Bash(mkdir:*), Bash(awk:*), Bash(for:*), Bash(vercel:*), Read(*), Write(*), Edit(*), Glob(*), Grep(*), AskUserQuestion(*)
description: CI/CD 配置 + 一键发布（幂等）
version: "8.4.0"
author: "公众号：手工川"
aliases: "/release-via-cicd"
---

# Release via CI/CD

幂等、自适应的发布流程。**默认自动执行 setup + publish**。

**默认使用 changesets**，除非用户明确选择保留 semantic-release。

## Step 0: 开场笑话 🎭

**在开始发布前，先讲一个程序员笑话放松一下：**

从以下笑话中随机选一个讲：

1. > 为什么程序员总是搞混万圣节和圣诞节？因为 Oct 31 = Dec 25
2. > 程序员最讨厌的数字是什么？2.0——因为它意味着重写
3. > "我的代码能跑了！" "太好了，提交吧。" "等等，我先看看为什么能跑..."
4. > 产品经理：这个需求很简单。程序员：你这句话本身就很复杂。
5. > 为什么程序员喜欢暗黑模式？因为 bugs 都怕光
6. > git commit -m "最终版" → git commit -m "最终版2" → git commit -m "这次真的是最终版"
7. > 99 个 bug 在代码里，99 个 bug～ 修掉一个，编译一下，127 个 bug 在代码里...

讲完笑话后，继续执行发布流程。

## 参数

```
无参数      → setup + publish（默认，自动模式）
setup      → 仅检查/修复配置
publish    → 仅执行发布
--keep-semantic-release  → 保留现有 semantic-release 配置
patch|minor|major        → 指定版本类型
```

## 自动模式行为

**原则：除非非常不确定，否则自动执行**

1. **自动提交**：有未提交更改时，自动 `git add -A && git commit`
   - 提交信息从 diff 内容推断（如 "fix: update xxx" 或 "feat: add xxx"）
   - 仅当变更复杂且无法推断意图时才询问

2. **自动版本**：默认 patch，除非用户显式指定
   - **首次发布（无 tag）→ `0.1.0`**（不是 1.0.0！1.0+ 需要用户明确指定）
   - 当前版本 `0.x.y` → 保持 `0.x` 前缀，按 patch/minor 递增
   - 默认 → patch（最安全的选择）
   - 用户参数 `minor` → minor
   - 用户参数 `major` → major
   - 用户显式指定 `1.0.0` 或 `major` 且当前 ≥ 0.x → 才可升到 1.0+
   - 检测到 `BREAKING` 变更 → 询问用户是否使用 major

   **版本号哲学**：0.x 表示「功能在持续演进」，1.0 表示「稳定 API 承诺」。无用户指引时永远不要自行跳到 1.0+。如果已有错误的 1.0+ tag，应提议重写（删除旧 tag/release，从 0.x 重新开始）。

3. **询问条件**：只有以下情况才询问用户
   - 工作区有多个不相关的变更
   - 变更涉及敏感文件（如 .env, secrets）
   - 版本类型无法自动推断（如 refactor 可能是 patch 或 minor）

4. **自动分支处理**：如果在 feature 分支
   - 自动提交当前变更
   - 自动 push 到 remote
   - 自动切换到 main 并 merge feature 分支
   - 使用 `--no-ff` 保留分支历史

5. **自动 Issue 处理**：从分支名/commit 检测关联 issue
   - 分支名格式：`*/issue-<number>*` 或 `*/<number>-*`
   - Commit 格式：`Closes #<number>` / `Fixes #<number>` / `Resolves #<number>`
   - 发布成功后自动 comment + close

## Step 1: 自动检测项目

```
类型: Tauri (src-tauri/) | Monorepo (pnpm-workspace.yaml) | Node (package.json) | Shell (无 package.json)
目标: npm | GitHub Release | 二进制
子类型:
  - Obsidian 插件 → GitHub Release Only（tag 触发，无 npm）
  - Vite/前端项目 (private: true) → GitHub Release + dist.zip
发布工具:
  - 检测到 semantic-release → 询问是否迁移到 changesets（推荐）
  - 检测到 changesets → 继续使用
  - 未配置 → 自动配置 changesets
```

**Shell 项目**：只需 workflow + tag + CHANGELOG.md
**Vite/前端项目**：GitHub Release + 上传 `{project}-{version}.zip`

**所有项目类型**：必须维护 CHANGELOG.md，发布前自动在顶部添加新版本变更记录，workflow 从中提取 release notes。禁止使用 `generate_release_notes: true`。

### semantic-release 迁移检测

检测是否使用 semantic-release：
```bash
# 检查 package.json 是否有 semantic-release 相关配置
grep -q "semantic-release" package.json && echo "semantic-release detected"
# 检查 workflow 是否调用 semantic-release
grep -rq "semantic-release" .github/workflows/ && echo "workflow uses semantic-release"
```

**如果检测到 semantic-release 且未传 `--keep-semantic-release`**：
1. 使用 AskUserQuestion 询问用户是否迁移到 changesets
2. 推荐迁移（changesets 更灵活、支持 Monorepo）
3. 用户同意后执行迁移（见下方「迁移步骤」）

### 迁移到 changesets 步骤

```bash
# 1. 初始化 changesets
pnpm add -D @changesets/cli
pnpm changeset init

# 2. 更新 .changeset/config.json
cat > .changeset/config.json << 'EOF'
{
  "$schema": "https://unpkg.com/@changesets/config@3.1.1/schema.json",
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "public",
  "baseBranch": "main",
  "updateInternalDependencies": "patch",
  "ignore": []
}
EOF

# 3. 移除 semantic-release 配置
# - 从 package.json 删除 "release" 配置块
# - 从 devDependencies 删除 semantic-release 相关包

# 4. 更新 workflow（见下方 Workflow 模板）
```

---

## Setup 阶段

### 检查并报告

```
✓/✗ .github/workflows/release.yml
✓/✗ .github/workflows/release.yml 包含 `permissions: contents: write`
✓/✗ Repo workflow permissions (write)
✓/✗ [Node] package.json (packageManager, scripts)
✓/✗ [Node] package.json 包含 packageManager 字段
✓/✗ [Node] .changeset/config.json（推荐）
⚠️ [Node] semantic-release 检测（建议迁移到 changesets）
✓/✗ [npm] NPM_TOKEN secret
✓/✗ CHANGELOG.md 存在且格式正确（## x.y.z 格式）
✓/✗ [Tauri] Cargo.toml 版本同步
```

### 自动修复

**Repo 权限**:
```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh api "repos/${REPO}/actions/permissions/workflow" -X PUT \
  -f default_workflow_permissions=write -F can_approve_pull_request_reviews=true
```

**packageManager 字段**（如缺失）:
```bash
PNPM_VERSION=$(pnpm --version)
# 在 package.json 中添加 "packageManager": "pnpm@${PNPM_VERSION}"
```

**Shell 项目 Workflow**:
```yaml
name: Release
on:
  push:
    tags: ['v*']
  workflow_dispatch:
    inputs:
      tag:
        description: 'Tag (e.g. v1.0.0)'
        required: true
permissions:
  contents: write
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Get tag
        id: tag
        run: echo "tag=${{ github.event.inputs.tag || github.ref_name }}" >> $GITHUB_OUTPUT
      - name: Extract release notes
        id: notes
        run: |
          VERSION="${{ steps.tag.outputs.tag }}"
          VERSION_NUM="${VERSION#v}"
          if [ -f CHANGELOG.md ]; then
            NOTES=$(awk -v ver="$VERSION_NUM" '
              /^## / { if (found) exit; if ($2 == ver) { found=1; next } }
              found { print }
            ' CHANGELOG.md)
          fi
          if [ -z "$NOTES" ]; then NOTES="Release $VERSION"; fi
          echo 'notes<<EOF' >> $GITHUB_OUTPUT
          echo "$NOTES" >> $GITHUB_OUTPUT
          echo 'EOF' >> $GITHUB_OUTPUT
      - uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.tag.outputs.tag }}
          body: ${{ steps.notes.outputs.notes }}
          files: |
            *.sh
```

**Node 项目原则**:
- 必须支持 `workflow_dispatch`
- Tauri 用 job chaining（GITHUB_TOKEN 限制）
- npm 包需要 `NPM_TOKEN`
- `pnpm/action-setup@v4` **不要指定 version**（读取 packageManager 字段）
- Tauri macOS 交叉编译需添加 Rust targets: `aarch64-apple-darwin,x86_64-apple-darwin`

**CHANGELOG.md 集成**:
- 发布时从 `CHANGELOG.md` 提取对应版本内容作为 release notes
- Fallback: CHANGELOG.md 无内容时用 GitHub 自动生成
- 避免 `generate_release_notes` 在多 job 重复

---

## Publish 阶段

### 前置检查
```bash
git status --porcelain      # 不干净 → 自动提交（见自动模式）
git branch --show-current   # 非 main/master → 自动合并（见分支处理）
git pull --rebase
# CHANGELOG.md 检查：不存在 → 自动创建（从 git log 生成历史记录）
# 发布前必须在 CHANGELOG.md 顶部添加新版本变更记录
```

### 自动分支合并
```bash
BRANCH=$(git branch --show-current)
MAIN_BRANCH="main"  # 或 master，自动检测

# 如果不在 main 分支
if [ "$BRANCH" != "$MAIN_BRANCH" ]; then
  # 1. 提交并推送当前分支
  git add -A && git commit -m "<auto message>" || true
  git push origin "$BRANCH"

  # 2. 切换到 main 并拉取最新
  git checkout "$MAIN_BRANCH"
  git pull origin "$MAIN_BRANCH"

  # 3. 合并 feature 分支（保留历史）
  git merge "$BRANCH" --no-ff -m "Merge branch '$BRANCH' into $MAIN_BRANCH

<changeset description>

Closes #<issue_number>"  # 如果检测到关联 issue
fi
```

### 自动 Issue 检测与处理
```bash
# 从分支名提取 issue 号
BRANCH=$(git branch --show-current)
ISSUE_NUM=""

# 匹配模式：issue-123, 123-feature, feature/issue-123
if [[ "$BRANCH" =~ issue-([0-9]+) ]]; then
  ISSUE_NUM="${BASH_REMATCH[1]}"
elif [[ "$BRANCH" =~ ^([0-9]+)- ]]; then
  ISSUE_NUM="${BASH_REMATCH[1]}"
elif [[ "$BRANCH" =~ /([0-9]+)- ]]; then
  ISSUE_NUM="${BASH_REMATCH[1]}"
fi

# 从 commit message 提取（作为补充）
if [ -z "$ISSUE_NUM" ]; then
  COMMITS=$(git log "$MAIN_BRANCH"..HEAD --format=%s 2>/dev/null)
  ISSUE_NUM=$(echo "$COMMITS" | grep -oE '(Closes|Fixes|Resolves) #[0-9]+' | head -1 | grep -oE '[0-9]+')
fi

# 验证 issue 存在且未关闭
if [ -n "$ISSUE_NUM" ]; then
  STATE=$(gh issue view "$ISSUE_NUM" --json state -q '.state' 2>/dev/null || echo "")
  if [ "$STATE" = "OPEN" ]; then
    echo "检测到关联 Issue #$ISSUE_NUM"
  else
    ISSUE_NUM=""  # 忽略已关闭的 issue
  fi
fi
```

### 发布后自动关闭 Issue
```bash
# 在 workflow 成功后执行
if [ -n "$ISSUE_NUM" ]; then
  VERSION="v${VERSION}"
  RELEASE_URL="https://github.com/${REPO}/releases/tag/${VERSION}"

  # 添加评论
  gh issue comment "$ISSUE_NUM" --body "已在 ${VERSION} 中修复。

Release: ${RELEASE_URL}"

  # 关闭 issue
  gh issue close "$ISSUE_NUM" --reason completed

  echo "✓ Issue #$ISSUE_NUM 已关闭"
fi
```

### 自动提交逻辑
```bash
# 1. 检查变更
CHANGES=$(git status --porcelain)
if [ -z "$CHANGES" ]; then exit; fi

# 2. 分析变更推断提交类型
#    - 修改现有文件 → fix
#    - 添加新文件 → feat
#    - 删除文件 → chore
#    - 配置文件 → chore

# 3. 推断提交描述（从文件名/diff 内容）
#    - 单文件：直接用文件名
#    - 多文件同类：归纳共同点
#    - 复杂变更：才询问用户

# 4. 自动提交
git add -A && git commit -m "${TYPE}: ${DESC}"
```

### 自动版本推断
```bash
# 版本类型优先级：
# 1. 用户显式参数 (patch/minor/major/具体版本号)
# 2. 检测到 BREAKING 变更 → 询问用户
# 3. 无 tag（首次发布）→ v0.1.0（不是 v1.0.0！）
# 4. 当前 0.x → 保持 0.x，按 patch/minor 递增
# 5. 默认 patch（最安全）
#
# ⚠️ 1.0+ 需要用户明确指定，绝不自行跳到 1.0+

LATEST=$(git tag -l 'v*' | sort -V | tail -1)
if [ -z "$LATEST" ]; then
  NEXT="v0.1.0"  # 首次发布从 0.1.0 开始
else
  # 解析当前版本并递增
  # 0.1.0 + patch → 0.1.1
  # 0.1.1 + minor → 0.2.0
  # 只有用户显式指定 major 或 1.0.0 才跳到 1.x
fi

# 检查是否有 BREAKING 变更
LAST_MSG=$(git log -1 --format=%s)
if [[ "$LAST_MSG" =~ ^BREAKING ]] || [[ "$LAST_MSG" =~ ^major: ]]; then
  echo "检测到可能的 BREAKING CHANGE: $LAST_MSG"
  echo "是否使用 major 版本？(y/N)"
  # 使用 AskUserQuestion 工具询问
fi

VERSION_TYPE="${USER_SPECIFIED_VERSION:-patch}"
```

### Shell 项目

```bash
# 获取最新 tag 并递增
LATEST=$(git tag -l 'v*' | sort -V | tail -1)
NEXT="v0.1.0"  # 无 tag 时默认 0.1.0（不是 1.0.0！）
# 自动递增 patch（0.1.0 → 0.1.1），minor 需用户指定

git tag "$NEXT" && git push --tags
# workflow 自动触发
```

### Node 项目

**自动模式**（默认）:
- 版本：从 commit 类型自动推断（见自动版本推断）
- 方式：默认 `local`（最快）

**询问模式**（仅当无法推断时）:
```
版本: [patch] / [minor] / [major]
方式: [local] 快速本地 | [ci] 通过 PR | [ci-auto] PR+自动合并
```

**Local 路径（Tauri）**:
```bash
# 1. 创建 changeset（如缺失）
cat > .changeset/<name>.md << 'EOF'
---
"<package>": patch
---

<description>
EOF

# 2. Bump version
pnpm changeset version  # 或项目自定义的 changeset:version 脚本
git add . && git commit -m "chore: release v${VERSION}"
git push

# 3. 创建并推送 tag（workflow checkout 需要 tag 存在）
git tag v${VERSION} && git push origin v${VERSION}

# 4. 触发构建
gh workflow run release.yml -f tag=v${VERSION}
sleep 3
RUN_ID=$(gh run list -w release.yml -L 1 --json databaseId -q '.[0].databaseId')
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "Workflow: https://github.com/$REPO/actions/runs/$RUN_ID"

# 5. **必须**等待 workflow 完成（指数退避轮询）
DELAY=5
MAX_DELAY=60
while true; do
  STATUS=$(gh run view $RUN_ID --json status,conclusion -q '.status')
  if [ "$STATUS" = "completed" ]; then
    CONCLUSION=$(gh run view $RUN_ID --json conclusion -q '.conclusion')
    echo "Workflow $CONCLUSION"
    break
  fi
  echo "Status: $STATUS, waiting ${DELAY}s..."
  sleep $DELAY
  DELAY=$((DELAY * 2 > MAX_DELAY ? MAX_DELAY : DELAY * 2))
done
```

**Local 路径（纯 Node）**:
```bash
pnpm build && pnpm changeset publish
git push --follow-tags
NOTES=$(awk -v ver="${VERSION}" '/^## / { if (found) exit; if ($2 == ver) { found=1; next } } found { print }' CHANGELOG.md)
gh release create "v${VERSION}" --notes "${NOTES:-Release v${VERSION}}" --latest
```

**CI 路径**:
```bash
git add -A && git commit -m "chore: add changeset" && git push
# 等待 Version Packages PR
gh pr merge ... --squash --delete-branch  # ci-auto
```

---

## Vercel 自动部署（前端项目）

**在 git push 后，自动检测并触发 Vercel 部署**：

```bash
# 检测是否为 Vercel 项目
if [ -d ".vercel" ]; then
  echo "检测到 Vercel 项目，检查部署状态..."

  # 等待几秒让 Vercel Git Integration 触发
  sleep 10

  # 检查最新部署是否是刚触发的（2分钟内）
  LATEST_AGE=$(vercel ls 2>&1 | head -4 | tail -1 | awk '{print $1}')

  # 如果最新部署不是刚触发的，手动部署
  if [[ ! "$LATEST_AGE" =~ ^[0-9]+s$ ]]; then
    echo "Vercel 未自动触发，手动部署..."
    vercel --prod
  else
    echo "✓ Vercel 已自动触发部署"
  fi
fi
```

**原则**：
- 检测 `.vercel/` 目录判断是否 Vercel 项目
- 优先等待 Git Integration 自动部署
- 未自动触发时 fallback 到 `vercel --prod`
- 部署完成后输出生产 URL

## 关键经验

| 陷阱 | 解决 |
|------|------|
| Tag 推送后 build 不触发 | Tauri 用 job chaining |
| `--label` 找不到 PR | `--search "in:title"` |
| npm 403/401 | `gh secret set NPM_TOKEN` |
| Tag already exists | bump 后重试 |
| Tauri 产物版本错误 | `sync-cargo-version.cjs` |
| gh-release 403 权限错误 | 需**同时**：1) workflow 添加 `permissions: contents: write` 2) 修复 repo 权限 |
| action-gh-release v1 问题 | 升级到 v2 |
| Tag 推送未触发 workflow | 用 `gh workflow run` 手动触发 |
| pnpm/action-setup 版本冲突 | 不要指定 `version`，让它读取 `packageManager` 字段 |
| **pnpm/action-setup 报错 No pnpm version** | **package.json 必须有 `packageManager` 字段** |
| macOS 交叉编译 target 未安装 | rust-toolchain 添加 `targets: aarch64-apple-darwin,x86_64-apple-darwin` |
| Release notes 重复 N 次 | 创建 draft 时用占位符，publish 时统一生成一次 |
| **Release notes 显示 `%0A` 乱码** | **多行输出必须用 heredoc：`echo 'notes<<EOF' >> $GITHUB_OUTPUT`** |
| **checkout with ref 失败** | **workflow 使用 `ref: tag` 时，必须先 push tag 再触发** |
| **静态网站上传了 dist 文件** | **private 网站项目不要配置 `files:`，Release 仅作版本标记** |
| **Release assets 需要清理** | `for name in $(gh release view vX.Y.Z --json assets -q '.assets[].name'); do gh release delete-asset vX.Y.Z "$name" --yes; done` |
| **changeset 包名错误** | 必须与 `package.json` 中 `name` 完全匹配，否则报 "package not in workspace" |
| **Monorepo CI 创建 PR 而非直接发布** | changesets/action 行为：有 changeset → 创建 PR；合并 PR → 才发布 |
| **合并 PR 后又创建新 PR** | 时序问题：changeset 在 PR 创建后推送，需再次合并新 PR |
| **Release asset 命名不专业** | 使用 `{project}-{version}.zip` 格式，如 `lovstudio-v0.3.1.zip` |
| **Vite 项目未上传 dist** | 前端项目应打包 dist 并上传为 release asset |
| **Workflow 触发后未监控结果** | **必须**使用指数退避轮询 `gh run view` 直到完成，不能只触发不等待 |
| **Release notes 只有链接** | 使用 awk 从 CHANGELOG.md 提取对应版本内容，而非 `--generate-notes` |
| **npm 包未上传 tgz 文件** | Monorepo 发布时 `npm pack` 所有包并上传到 release assets |
| **macOS 未签名应用无法运行** | Release notes 添加 `xattr -dr com.apple.quarantine` 授权命令 |
| **Feature 分支未合并到 main** | 自动检测非 main 分支 → merge --no-ff |
| **关联 Issue 未关闭** | 从分支名/commit 提取 issue 号 → 自动 comment + close |
| **Issue 已关闭但仍尝试处理** | 检查 issue state，跳过已关闭的 |
| **分支名格式多样** | 支持 `issue-123`、`123-feat`、`feat/issue-123` 等模式 |
| **Release notes 空白或只有 commit SHA** | **禁止** `generate_release_notes`，所有项目必须维护 CHANGELOG.md 并从中提取 |
| **CHANGELOG.md 不存在** | 发布前自动创建，从 git log 生成历史版本记录 |
| **Vercel 未自动部署** | push 后检测 `.vercel/` 目录，等待 10s 后检查是否触发，未触发则 `vercel --prod` |

---

## Workflow 监控（必须执行）

**重要**：触发 workflow 后**必须**等待完成，不能只触发不管结果。使用指数退避轮询：

```bash
# 获取最新 run ID
RUN_ID=$(gh run list -w release.yml -L 1 --json databaseId -q '.[0].databaseId')
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "Workflow: https://github.com/$REPO/actions/runs/$RUN_ID"

# 指数退避轮询（5s → 10s → 20s → 40s → 60s max）
DELAY=5
MAX_DELAY=60
while true; do
  STATUS=$(gh run view $RUN_ID --json status -q '.status')
  if [ "$STATUS" = "completed" ]; then
    CONCLUSION=$(gh run view $RUN_ID --json conclusion -q '.conclusion')
    if [ "$CONCLUSION" = "success" ]; then
      echo "✓ Workflow succeeded"
      gh release view v${VERSION} --json tagName,url -q '"Release: \(.url)"' 2>/dev/null || true
    else
      echo "✗ Workflow $CONCLUSION"
      gh run view $RUN_ID --json jobs -q '.jobs[] | select(.conclusion != "success") | "  \(.name): \(.conclusion)"'
    fi
    break
  fi
  echo "Status: $STATUS, next check in ${DELAY}s..."
  sleep $DELAY
  DELAY=$((DELAY * 2 > MAX_DELAY ? MAX_DELAY : DELAY * 2))
done
```

---

## 快速参考

```bash
# 完整自动流程（feature 分支 → main → release → close issue）
/release-via-cicd minor
# 自动：commit → push → merge to main → changeset → bump → tag → workflow → close issue

# Shell 项目
git tag v1.0.0 && git push --tags

# 静态网站（仅版本标记）
pnpm changeset && pnpm changeset version
git add -A && git commit -m "chore: release vX.Y.Z" && git push
git tag vX.Y.Z && git push origin vX.Y.Z

# Node 本地一键
npx changeset && npx changeset version && pnpm build && pnpm changeset publish && git push --follow-tags

# Tauri 完整流程（推荐）
pnpm changeset                    # 创建 changeset
pnpm version                      # changeset version + sync-cargo-version
git add -A && git commit -m "chore: release vX.Y.Z" && git push
git tag vX.Y.Z && git push origin vX.Y.Z  # 必须先 push tag
gh workflow run release.yml -f tag=vX.Y.Z
# **必须**等待 workflow 完成（见「Workflow 监控」章节）
# **自动**关闭关联 issue（如有）

# 清理 Release assets
for name in $(gh release view vX.Y.Z --json assets -q '.assets[].name'); do gh release delete-asset vX.Y.Z "$name" --yes; done

# Monorepo + changesets/action（推荐）
pnpm changeset                    # 创建 changeset（包名必须与 package.json name 完全匹配）
git add -A && git commit -m "feat: xxx" && git push
# 等 CI 创建 "chore: release packages" PR
gh pr merge <number> --squash --delete-branch
# CI 自动 build + publish + release
```

## 分支与 Issue 自动化

**分支名识别模式**：
- `claude/issue-12-xxx` → Issue #12
- `feat/123-add-feature` → Issue #123
- `fix/issue-456` → Issue #456
- `bugfix-789` → Issue #789（需从 commit 提取）

**Issue 自动关闭流程**：
```bash
# 1. 从分支名/commit 检测 issue 号
# 2. 验证 issue 存在且为 OPEN 状态
# 3. Release 成功后:
gh issue comment <num> --body "已在 vX.Y.Z 中修复。\n\nRelease: <url>"
gh issue close <num> --reason completed
```

**合并 commit message 模板**：
```
Merge branch '<feature-branch>' into main

<changeset 描述>

Closes #<issue_number>
```

## Monorepo Workflow 模板（changesets/action）

```yaml
name: Release
on:
  push:
    branches: [main]
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
          registry-url: 'https://registry.npmjs.org'
      - run: pnpm install
      - run: pnpm build
      - run: echo "//registry.npmjs.org/:_authToken=${{ secrets.NPM_TOKEN }}" >> ~/.npmrc
      - uses: changesets/action@v1
        id: changesets
        with:
          version: pnpm changeset version
          publish: pnpm release  # 需定义 scripts.release = "pnpm build && pnpm changeset publish"
          title: 'chore: release packages'
          commit: 'chore: release packages'
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}

      # Pack npm packages for release assets
      - name: Pack npm packages
        if: steps.changesets.outputs.published == 'true'
        run: |
          mkdir -p release-assets
          for pkg in packages/*/; do
            if [ -f "$pkg/package.json" ]; then
              cd "$pkg"
              npm pack --pack-destination ../../release-assets
              cd ../..
            fi
          done

      # Create GitHub Release with CHANGELOG content and tgz files
      - name: Create GitHub Release
        if: steps.changesets.outputs.published == 'true'
        run: |
          VERSION=$(node -p "require('./packages/core/package.json').version")

          # Extract release notes from CHANGELOG.md
          NOTES=$(awk -v ver="$VERSION" '
            /^## / { if (found) exit; if ($2 == ver) { found=1; next } }
            found { print }
          ' packages/core/CHANGELOG.md)

          if [ -z "$NOTES" ]; then
            NOTES="Release v${VERSION}"
          fi

          gh release create "v${VERSION}" \
            --title "v${VERSION}" \
            --notes "$NOTES" \
            --latest \
            release-assets/*.tgz
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Tauri Workflow 模板（推荐）

```yaml
name: Release
on:
  workflow_dispatch:
    inputs:
      tag:
        description: 'Tag (e.g. v0.1.0)'
        required: true
permissions:
  contents: write
jobs:
  create-release:
    runs-on: ubuntu-latest
    outputs:
      release_id: ${{ steps.create.outputs.id }}
      tag: ${{ github.event.inputs.tag }}
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.inputs.tag }}
      - name: Extract release notes
        id: notes
        run: |
          VERSION="${{ github.event.inputs.tag }}"
          VERSION_NUM="${VERSION#v}"
          NOTES=$(awk -v ver="$VERSION_NUM" '
            /^## / { if (found) exit; if ($2 == ver) { found=1; next } }
            found { print }
          ' CHANGELOG.md)
          if [ -z "$NOTES" ]; then NOTES="Release $VERSION"; fi
          # 添加 macOS 未签名应用授权说明
          MACOS_NOTE="

---

**macOS 用户注意**: 本应用暂未签名，首次运行需授权：
\`\`\`bash
sudo xattr -dr com.apple.quarantine /Applications/${APP_NAME}.app
\`\`\`
详见: https://lovstudio.ai/app/${APP_NAME}"
          echo 'notes<<EOF' >> $GITHUB_OUTPUT
          echo "$NOTES" >> $GITHUB_OUTPUT
          echo "$MACOS_NOTE" >> $GITHUB_OUTPUT
          echo 'EOF' >> $GITHUB_OUTPUT
        env:
          APP_NAME: ${{ github.event.repository.name }}
      - id: create
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ github.event.inputs.tag }}
          draft: true
          body: ${{ steps.notes.outputs.notes }}

  build-tauri:
    needs: create-release
    strategy:
      fail-fast: false
      matrix:
        include:
          - platform: macos-latest
            args: --target aarch64-apple-darwin
          - platform: macos-latest
            args: --target x86_64-apple-darwin
          - platform: ubuntu-22.04
            args: ''
          - platform: windows-latest
            args: ''
    runs-on: ${{ matrix.platform }}
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.inputs.tag }}
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - uses: dtolnay/rust-toolchain@stable
        with:
          targets: ${{ matrix.platform == 'macos-latest' && 'aarch64-apple-darwin,x86_64-apple-darwin' || '' }}
      - if: matrix.platform == 'ubuntu-22.04'
        run: sudo apt-get update && sudo apt-get install -y libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev patchelf
      - uses: swatinem/rust-cache@v2
        with:
          workspaces: './src-tauri -> target'
      - run: pnpm install
      - uses: tauri-apps/tauri-action@v0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          releaseId: ${{ needs.create-release.outputs.release_id }}
          args: ${{ matrix.args }}

  publish-release:
    needs: [create-release, build-tauri]
    runs-on: ubuntu-latest
    steps:
      - name: Publish release
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh release edit "${{ needs.create-release.outputs.tag }}" \
            --repo ${{ github.repository }} \
            --draft=false
```

## Vite/前端项目 Workflow 模板

**命名规范**: `{project}-{version}.zip`（如 `lovstudio-v0.3.1.zip`）

```yaml
name: Release
on:
  push:
    tags: ['v*']
  workflow_dispatch:
    inputs:
      tag:
        description: 'Tag (e.g. v1.0.0)'
        required: true

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.inputs.tag || github.ref_name }}

      - uses: pnpm/action-setup@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'

      - run: pnpm install

      - run: pnpm build

      - name: Package dist
        run: |
          TAG="${{ github.event.inputs.tag || github.ref_name }}"
          zip -r "${PROJECT_NAME}-${TAG}.zip" dist
        env:
          PROJECT_NAME: myproject  # 替换为实际项目名

      - name: Get tag
        id: tag
        run: echo "tag=${{ github.event.inputs.tag || github.ref_name }}" >> $GITHUB_OUTPUT

      - name: Extract release notes
        id: notes
        run: |
          VERSION="${{ steps.tag.outputs.tag }}"
          VERSION_NUM="${VERSION#v}"
          if [ -f CHANGELOG.md ]; then
            NOTES=$(awk -v ver="$VERSION_NUM" '
              /^## / { if (found) exit; if ($2 == ver) { found=1; next } }
              found { print }
            ' CHANGELOG.md)
          fi
          if [ -z "$NOTES" ]; then NOTES="Release $VERSION"; fi
          echo 'notes<<EOF' >> $GITHUB_OUTPUT
          echo "$NOTES" >> $GITHUB_OUTPUT
          echo 'EOF' >> $GITHUB_OUTPUT

      - uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.tag.outputs.tag }}
          body: ${{ steps.notes.outputs.notes }}
          files: ${{ env.PROJECT_NAME }}-${{ steps.tag.outputs.tag }}.zip
        env:
          PROJECT_NAME: myproject  # 替换为实际项目名
```
