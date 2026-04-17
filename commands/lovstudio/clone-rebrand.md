---
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep, AskUserQuestion, TodoWrite]
description: 从模板/fork/clone创建新项目：交互收集信息→品牌替换→i18n→GitHub→Vercel
version: "1.0.0"
author: "公众号：手工川"
---

# Clone Rebrand

将 clone/fork 的项目完整改造成你的新项目：品牌替换、多语言、GitHub 仓库、Vercel 部署。

## Process

### Step 1: Collect Info (Interactive)

使用 AskUserQuestion 收集必要信息：

**Q1: 基础信息**
```
questions:
  - question: "新项目名称是什么？（用于 package.json、GitHub 等）"
    header: "项目名"
    options: [提取当前目录名作为建议]

  - question: "项目的一句话描述？"
    header: "描述"
    options: [从当前 package.json description 提取]
```

**Q2: GitHub 配置**
```
questions:
  - question: "GitHub 仓库创建在哪里？"
    header: "GitHub"
    options:
      - label: "个人账户"
        description: "用户名/项目名"
      - label: "组织账户"
        description: "选择一个组织"
      - label: "跳过"
        description: "不创建 GitHub 仓库"
```

**Q3: 部署配置**
```
questions:
  - question: "需要配置 Vercel 部署吗？"
    header: "部署"
    options:
      - label: "是，配置域名"
        description: "输入自定义域名如 app.example.com"
      - label: "是，用默认域名"
        description: "使用 project.vercel.app"
      - label: "跳过"
        description: "稍后手动配置"
```

### Step 2: Detect Current Brand

```bash
# 检测当前品牌名（优先级）
OLD_NAME=$(jq -r '.name' package.json 2>/dev/null)
[ -z "$OLD_NAME" ] && OLD_NAME=$(basename "$(pwd)")

# 检测相关变体
OLD_PASCAL=$(echo "$OLD_NAME" | sed -r 's/(^|-)(\w)/\U\2/g')  # my-app → MyApp
OLD_SNAKE=$(echo "$OLD_NAME" | tr '-' '_')                     # my-app → my_app
OLD_UPPER=$(echo "$OLD_SNAKE" | tr '[:lower:]' '[:upper:]')    # my_app → MY_APP
```

### Step 3: Brand Replacement (TodoWrite tracking)

按类别替换，使用 TodoWrite 追踪进度：

**3.1 核心配置文件**
- `package.json` - name, description
- `src/utils/AppConfig.ts` 或类似 - app name
- `src/app/**/layout.tsx` - metadata, title, description
- `.env*` - 相关环境变量名

**3.2 i18n 多语言文件**
```bash
# 扫描所有 locale 文件
find src -name "*.json" -path "*/locales/*" -o -name "*.json" -path "*/i18n/*"
```

对每个 locale 文件：
- 替换产品名称
- 替换产品描述
- 替换相关 UI 文案（如 "Powered by X"）

**3.3 Logo/Icon 组件**
```bash
# 检测可能的 logo 组件
find src -name "*Logo*" -o -name "*Icon*" | grep -v node_modules
```

- 重命名文件：`OldNameLogo.tsx` → `NewNameLogo.tsx`
- 更新组件名和导出
- 更新所有 import 引用

**3.4 README 和文档**
- 替换标题、描述
- 更新徽章链接
- 更新截图引用（如有）

### Step 4: Git Operations

```bash
# 4.1 提交品牌变更
git add -A
git commit -m "refactor: rebrand to $NEW_NAME

- Update package.json and configs
- Update i18n locale files
- Rename logo/icon components
- Update README and docs

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### Step 5: GitHub Repository

根据 Step 1 的选择：

```bash
# 5.1 创建新仓库（如果选择了 GitHub）
gh repo create "$GITHUB_OWNER/$NEW_NAME" --public --source=. --remote=origin --push

# 5.2 或更新现有 remote
git remote set-url origin "git@github.com:$GITHUB_OWNER/$NEW_NAME.git"
git push -u origin main
```

### Step 6: Vercel Deployment

根据 Step 1 的选择：

```bash
# 6.1 部署到 Vercel
vercel --prod --yes

# 6.2 配置自定义域名（如果提供了）
vercel domains add "$CUSTOM_DOMAIN"

# 6.3 DNS 配置提示（如果用 Cloudflare）
# 检测 CLOUDFLARE_API_KEY 环境变量，自动配置 CNAME
```

### Step 7: Summary

输出完成摘要：

```
✅ 项目重塑完成: $OLD_NAME → $NEW_NAME

📦 品牌替换:
   - 核心配置: 5 files
   - i18n 文件: 4 locales
   - 组件重命名: 2 components

🔗 仓库:
   - GitHub: https://github.com/$OWNER/$NEW_NAME

🚀 部署:
   - Vercel: https://$NEW_NAME.vercel.app
   - 域名: https://$CUSTOM_DOMAIN

📋 后续检查:
   - [ ] 验证本地 dev 服务正常
   - [ ] 检查生产环境
   - [ ] 更新第三方服务配置（OAuth、API keys 等）
```

## 智能检测

### 框架检测
自动识别项目类型并调整替换策略：
- **Next.js**: `layout.tsx`, `next.config.*`
- **Vite/React**: `index.html`, `vite.config.*`
- **Vue**: `App.vue`, `vue.config.*`

### i18n 检测
支持常见 i18n 方案：
- `next-intl`: `src/locales/*.json`
- `react-i18next`: `public/locales/*/*.json`
- `vue-i18n`: `src/i18n/*.json`

## 安全特性

1. **Git 干净检查**: 有未提交更改时提示 stash
2. **备份分支**: 自动创建 `backup/pre-rebrand` 分支
3. **幂等性**: 重复运行安全，已完成的步骤会跳过
4. **回滚指南**: 失败时提供回滚命令

## 示例

```bash
# 交互式（推荐）
/clone-rebrand

# 带参数（跳过部分问题）
/clone-rebrand my-new-app
```
