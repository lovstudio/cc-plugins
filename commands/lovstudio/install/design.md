---
allowed-tools: Read(*), Write(*), Edit(*), Glob(*), Grep(*), Bash(pnpm:*, npm:*, npx:*, cp, mkdir, ls, rm, rsvg-convert, iconutil, convert, magick, pwd)
description: 幂等配置 Lovstudio 设计系统（暖学术风格）到当前项目
version: "1.2.1"
author: "公众号：手工川"
aliases: /install-lovstudio-design, /install-design
---

# Install Lovstudio Design

幂等地将 Lovstudio 设计系统（暖学术风格）集成到当前前端项目，包括主题色、Tailwind 配置、shadcn 组件、应用图标等。

## 执行步骤

### 0. 检测执行模式

检查当前工作目录：

```bash
pwd
```

**全局配置模式**：如果当前目录是 `~/.claude` 或 `/Users/*/\.claude`：
- 仅更新全局 CLAUDE.md 中的设计系统引用
- 在 `frontend` 部分添加设计系统引用（如不存在）
- 输出：「✓ 全局设计规范已配置」并结束
- 跳过后续项目级步骤

**项目安装模式**：其他目录继续执行后续步骤。

### 1. 检测项目类型

检测当前项目是否为前端项目：

```
glob: package.json
glob: tailwind.config.{ts,js,mjs}
glob: components.json (shadcn配置)
glob: src-tauri/tauri.conf.json (Tauri项目)
```

如果 package.json 不存在，输出错误并退出：
```
✗ 未检测到前端项目（缺少 package.json）

提示：在 ~/.claude 目录执行可配置全局设计规范
```

### 2. 检查是否已集成（幂等检查）

在 `CLAUDE.md` 或 `.claude/CLAUDE.md` 中搜索：
- `design-guide.md` 关键字
- `Lovstudio` 关键字
- `Warm Academic` 关键字

在 globals.css 中搜索：
- `Lovstudio Warm Academic` 关键字

如果已存在，输出「✓ Lovstudio 设计系统已配置，无需重复操作」并结束。

### 3. 安装依赖

**3.1 检查 Tailwind CSS**

检查 package.json 是否包含 `tailwindcss`：
- 已存在：跳过
- 不存在：执行安装
  ```bash
  pnpm add -D tailwindcss postcss autoprefixer
  ```

**3.2 检查 shadcn/ui**

检查是否存在 `components.json`：
- 已存在：跳过
- 不存在：执行初始化
  ```bash
  npx shadcn@latest init -y --defaults
  ```

### 4. 配置 Tailwind CSS

**4.1 读取现有配置**

读取 `tailwind.config.ts` 或 `tailwind.config.js`。

**4.2 更新主题配置**

添加字体配置（Tailwind 4 使用 CSS 变量处理颜色，只需添加字体）：

```typescript
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        serif: ["Georgia", "Times New Roman", "serif"],
        sans: ["Inter", "Arial", "sans-serif"],
      },
    },
  },
} satisfies Config;
```

### 5. 配置 CSS 变量

**5.1 查找全局 CSS 文件**

优先查找：
```
glob: src/globals.css
glob: app/globals.css
glob: src/app/globals.css
glob: styles/globals.css
glob: src/index.css
```

**5.2 添加或更新 CSS 变量**

根据 Tailwind 版本使用不同格式：

**Tailwind CSS 4 (oklch 格式)**：

```css
:root {
  /* Lovstudio Warm Academic Theme - Light Mode */
  --radius: 1rem;

  /* #F9F9F7 暖米色 (Warm Beige) */
  --background: oklch(0.98 0.01 85);
  /* #181818 炭灰色 (Charcoal) */
  --foreground: oklch(0.15 0 0);

  --card: oklch(1 0 0);
  --card-foreground: oklch(0.15 0 0);

  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.15 0 0);

  /* #E66F4C 陶土色 (Terracotta) - Primary accent */
  --primary: oklch(0.65 0.17 35);
  --primary-foreground: oklch(1 0 0);

  /* #F0EEE6 浅灰 (Light Gray) - Secondary */
  --secondary: oklch(0.94 0.01 85);
  --secondary-foreground: oklch(0.15 0 0);

  /* #E8E6DC Muted background */
  --muted: oklch(0.92 0.01 85);
  /* #87867F Muted foreground */
  --muted-foreground: oklch(0.55 0.01 85);

  --accent: oklch(0.94 0.01 85);
  --accent-foreground: oklch(0.15 0 0);

  --destructive: oklch(0.6 0.21 29);
  --destructive-foreground: oklch(1 0 0);

  /* #D5D3CB Border/Input */
  --border: oklch(0.85 0.01 85);
  --input: oklch(0.85 0.01 85);
  --ring: oklch(0.62 0.11 35);
}

.dark {
  /* Lovstudio Warm Academic Theme - Dark Mode */
  --background: oklch(0.18 0.01 35);
  --foreground: oklch(0.95 0.01 85);
  --card: oklch(0.22 0.01 35);
  --card-foreground: oklch(0.95 0.01 85);
  --primary: oklch(0.68 0.12 35);
  --primary-foreground: oklch(0.18 0.01 35);
  --secondary: oklch(0.28 0.01 35);
  --secondary-foreground: oklch(0.95 0.01 85);
  --muted: oklch(0.28 0.01 35);
  --muted-foreground: oklch(0.65 0.01 85);
  --accent: oklch(0.28 0.01 35);
  --accent-foreground: oklch(0.95 0.01 85);
  --destructive: oklch(0.55 0.19 29);
  --destructive-foreground: oklch(0.95 0.01 85);
  --border: oklch(0.35 0.01 35);
  --input: oklch(0.35 0.01 35);
  --ring: oklch(0.68 0.12 35);
}
```

**Tailwind CSS 3 (hsl 格式)**：

```css
:root {
  /* Lovstudio Warm Academic Theme */
  --background: 40 20% 97%;
  --foreground: 0 0% 9%;
  --primary: 14 52% 58%;
  --primary-foreground: 0 0% 100%;
  /* ... 其他变量 */
  --radius: 1rem;
}
```

### 6. 创建项目级 CLAUDE.md

**6.1 查找现有 CLAUDE.md**

优先查找：
```
glob: CLAUDE.md
glob: .claude/CLAUDE.md
```

**6.2 添加设计系统引用**

在文件开头添加（如不存在则创建）：

```markdown
## Design System

This project uses **Lovstudio Warm Academic Style (暖学术风格)**

Reference complete design guide: file:///Users/mark/@lovstudio/design/design-guide.md

### Quick Rules
1. **禁止硬编码颜色**：必须使用 semantic 类名（如 `bg-primary`、`text-muted-foreground`）
2. **字体配对**：标题用 `font-serif`，正文用默认 `font-sans`
3. **圆角风格**：使用 `rounded-lg`、`rounded-xl`、`rounded-2xl`
4. **主色调**：陶土色（按钮/高亮）+ 暖米色背景 + 炭灰文字
5. **组件优先**：优先使用 shadcn/ui 组件

### Color Palette
- **Primary**: #E66F4C (陶土色 Terracotta)
- **Background**: #F9F9F7 (暖米色 Warm Beige)
- **Foreground**: #181818 (炭灰色 Charcoal)
- **Border**: #D5D3CB

### Common Patterns
- 主按钮: `bg-primary text-primary-foreground hover:bg-primary/90`
- 卡片: `bg-card border border-border rounded-xl`
- 标题: `font-serif text-foreground`
```

### 7. 配置品牌 Logo

**7.1 复制 Logo 到 public 目录**

```bash
cp /Users/mark/@lovstudio/assets/lovpen-logo/LovPen-pure-logo_primaryColor.svg public/lovpen-logo.svg
```

**7.2 Tauri 项目：替换应用图标**

如果检测到 `src-tauri/tauri.conf.json`，需要生成全平台应用图标：

```bash
cd src-tauri/icons

# 核心图标
rsvg-convert -w 32 -h 32 /Users/mark/@lovstudio/assets/lovpen-logo/LovPen-pure-logo_primaryColor.svg -o 32x32.png
rsvg-convert -w 128 -h 128 ... -o 128x128.png
rsvg-convert -w 256 -h 256 ... -o 128x128@2x.png
rsvg-convert -w 512 -h 512 ... -o icon.png

# Windows Store 图标 (Square*.png)
rsvg-convert -w 30 -h 30 ... -o Square30x30Logo.png
rsvg-convert -w 44 -h 44 ... -o Square44x44Logo.png
# ... 其他尺寸: 71, 89, 107, 142, 150, 284, 310
rsvg-convert -w 50 -h 50 ... -o StoreLogo.png

# macOS icns
mkdir -p icon.iconset
rsvg-convert -w 16 -h 16 ... -o icon.iconset/icon_16x16.png
# ... 所有尺寸: 16, 32, 64, 128, 256, 512, 1024
iconutil -c icns icon.iconset -o icon.icns
rm -rf icon.iconset

# Windows ico
mkdir -p ico_temp
rsvg-convert -w 16 -h 16 ... -o ico_temp/16.png
# ... 尺寸: 16, 32, 48, 64, 128, 256
magick ico_temp/*.png icon.ico  # 或 convert
rm -rf ico_temp
```

**7.3 更新前端页面 Logo**

查找首页文件，替换默认 logo 为 Lovstudio logo：
```tsx
<img src="/lovpen-logo.svg" className="h-24" alt="Lovstudio" />
```

### 8. 安装常用 shadcn 组件

```bash
npx shadcn@latest add button card tabs input label -y
```

### 9. 输出结果

成功集成后输出：

```
✓ Lovstudio 设计系统集成完成

配置内容：
- Tailwind 主题色（暖学术风格）
- CSS 变量（陶土色、暖米色、炭灰色）
- shadcn 基础组件（Button, Card, Tabs, Input, Label）
- 项目 CLAUDE.md 设计规范引用
- Lovstudio Logo（/lovpen-logo.svg）
- [Tauri] 全平台应用图标（icns/ico/png）

设计原则：
- 禁止硬编码颜色，使用 semantic 类名
- 标题用衬线体，正文用无衬线体
- 柔和圆角，扁平设计

完整设计指南：
file:///Users/mark/@lovstudio/design/design-guide.md
```

## 幂等性保证

- 依赖检查：已安装则跳过
- 配置检查：已配置则跳过（不覆盖用户自定义）
- 文档检查：已引用则跳过
- 图标检查：Tauri 项目每次更新（覆盖）
- 重复执行：结果一致，无副作用

## 支持的框架

- Next.js (App Router / Pages Router)
- Vite + React
- **Tauri + React**（含应用图标）
- Remix
- Astro
- 任何使用 Tailwind CSS 的项目

## 依赖工具（Tauri 图标生成）

- `rsvg-convert`：SVG 转 PNG
- `iconutil`：生成 macOS icns
- `magick` 或 `convert`：生成 Windows ico

ARGUMENTS: $ARGUMENTS
