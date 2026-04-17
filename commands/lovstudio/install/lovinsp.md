---

allowed-tools: Read(*), Write(*), Edit(*), Glob(*), Grep(*), Bash(pnpm:*, npm:*, cat:*)
description: 幂等集成 lovinsp (click-to-code) 到当前项目，支持从 code-inspector 迁移
version: "1.3.0"
author: "公众号：手工川"
aliases: /install-lovinsp
---

# Install Lovinsp

幂等地将 lovinsp（点击 DOM 跳转源码）集成到当前前端项目。支持从 code-inspector 自动迁移。

## 执行步骤

### 1. 检测项目类型

检测当前项目使用的构建工具：

```
glob: vite.config.{ts,js,mjs}
glob: webpack.config.{ts,js,mjs}
glob: next.config.{ts,js,mjs}
glob: nuxt.config.{ts,js}
glob: package.json
```

根据检测结果确定 bundler 类型：`vite` | `webpack` | `esbuild` | `turbopack` | `mako`

### 2. 检查是否已集成（幂等检查）

在配置文件中搜索：
- `lovinsp` 关键字
- `lovinspPlugin` 关键字
- `@lovinsp/` 前缀

如果已存在：
1. 检查版本更新：`pnpm view lovinsp version` 对比当前版本
2. 若有更新：提示「当前 x.x.x → 最新 y.y.y」并执行 `pnpm update lovinsp`
3. 若已是最新：输出「✓ lovinsp 已集成（v最新版），无需操作」

### 3. 检测并迁移 code-inspector（如存在）

检查 package.json 是否包含 `code-inspector` 相关依赖：
- `code-inspector-plugin`
- `@aspect/code-inspector-plugin`

如果存在，执行迁移：

**3.1 卸载旧依赖：**
```bash
pnpm remove code-inspector-plugin
# 或
npm uninstall code-inspector-plugin
```

**3.2 更新配置文件中的引用：**

替换 import 语句：
```diff
- import { codeInspectorPlugin } from 'code-inspector-plugin';
+ import { lovinspPlugin } from 'lovinsp';
```

替换插件调用：
```diff
- codeInspectorPlugin({ bundler: 'vite' }),
+ lovinspPlugin({ bundler: 'vite' }),
```

**3.3 输出迁移信息：**
```
✓ 已从 code-inspector 迁移到 lovinsp
  - 卸载: code-inspector-plugin
  - 安装: lovinsp
  - 更新: 配置文件
```

### 4. 安装依赖（幂等）

检查 package.json 的 devDependencies 是否已包含 `lovinsp`：
- 已存在：跳过安装
- 不存在：执行 `pnpm add -D lovinsp` 或 `npm install -D lovinsp`

### 5. 修改构建配置

根据 bundler 类型，在配置文件中添加插件：

**Vite (vite.config.ts):**
```typescript
import { lovinspPlugin } from 'lovinsp';

export default defineConfig({
  plugins: [
    // lovinsp 必须放在框架插件之前
    lovinspPlugin({ bundler: 'vite' }),
    // ... 其他插件
  ]
});
```

**Webpack (webpack.config.js):**
```javascript
const { lovinspPlugin } = require('lovinsp');

module.exports = {
  plugins: [
    lovinspPlugin({ bundler: 'webpack' }),
  ]
};
```

**Next.js with Turbopack (next.config.ts):**
```typescript
import { lovinspPlugin } from 'lovinsp';

export default {
  turbopack: {
    rules: lovinspPlugin({ bundler: 'turbopack' }),
  },
};
```

**Next.js with Webpack (next.config.js):**
```javascript
const { lovinspPlugin } = require('lovinsp');

module.exports = {
  webpack: (config) => {
    config.plugins.push(lovinspPlugin({ bundler: 'webpack' }));
    return config;
  }
};
```

### 6. 输出结果

成功集成后输出：
```
✓ lovinsp 集成完成

使用方法：
- Mac: Option + Shift 激活检查器
- Windows: Alt + Shift 激活检查器
- 点击任意 DOM 元素跳转到源码

文档: https://inspector.fe-dev.cn/en
```

## 幂等性保证

- 依赖检查：已安装则跳过
- 配置检查：已配置则跳过
- 重复执行：结果一致，无副作用

## 支持的框架

- Vite: React, Vue2, Vue3, Svelte, Solid, Preact, Qwik, Astro
- Webpack: React, Vue
- Next.js (Turbopack/Webpack)
- Nuxt
- Rspack, Farm, Mako

ARGUMENTS: $ARGUMENTS
