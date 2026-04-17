---
allowed-tools: [Read, Write, Bash, Glob, Grep]
description: 部署前端项目到 Vercel（支持 Vite/Next.js/CRA）
version: "1.0.0"
author: "公众号：手工川"
aliases: "/deploy-vercel"---

# Deploy to Vercel

一键部署前端项目到 Vercel，自动处理 SPA 路由和环境变量。

## Workflow

### Step 1: 检测项目类型

```bash
# 检查框架类型
if [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
  FRAMEWORK="vite"
elif [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; then
  FRAMEWORK="next"
elif grep -q "react-scripts" package.json 2>/dev/null; then
  FRAMEWORK="cra"
else
  FRAMEWORK="static"
fi
```

### Step 2: 检查/创建 vercel.json

对于 SPA 项目（Vite/CRA），需要配置路由重写：

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/" }
  ]
}
```

Next.js 项目通常不需要额外配置。

### Step 3: 检查 Vercel CLI

```bash
vercel --version || npm i -g vercel
vercel whoami || vercel login
```

### Step 4: 读取环境变量

从 `.env` 或 `.env.local` 读取需要同步的环境变量：
- 过滤掉敏感的私钥（SECRET、PRIVATE 等）
- 识别 `VITE_`、`NEXT_PUBLIC_` 等公开变量

### Step 5: 部署

```bash
# 首次部署（链接项目）
vercel --yes

# 同步环境变量到 Vercel
vercel env add <VAR_NAME> production <<< "<value>"

# 生产部署
vercel --prod --yes
```

### Step 6: 输出结果

显示：
- 生产 URL
- 项目设置链接
- 已配置的环境变量列表

## Options

参数通过 `$ARGUMENTS` 传入：

| 参数 | 说明 |
|------|------|
| `--prod` | 直接部署到生产环境（默认） |
| `--preview` | 仅部署预览版本 |
| `--no-env` | 跳过环境变量同步 |
| `--link-only` | 仅链接项目，不部署 |

## Key Behaviors

1. **幂等性**: 已存在 vercel.json 时不覆盖
2. **安全性**: 不同步包含 SECRET/PRIVATE 的变量
3. **自动检测**: 根据项目类型选择正确配置
4. **GitHub 集成**: 自动连接 GitHub 仓库实现 CI/CD
