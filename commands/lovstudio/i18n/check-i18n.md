---
allowed-tools: [Bash, Read, Edit, Write, Glob, Grep, AskUserQuestion, Skill]
description: 检测并修复前端项目的 i18n 硬编码问题
version: "1.0.0"
author: "公众号：手工川"
---

# Check i18n

检测前端项目的 i18n 配置和硬编码，自动初始化或修复。

## Configuration

    supported_frameworks:
      nextjs: "next-intl"
      vite: "react-i18next"
      vue: "vue-i18n"

    scan_patterns:
      - "**/*.tsx"
      - "**/*.ts"
      - "**/*.jsx"
      - "**/*.js"
      - "**/*.vue"
      - "**/package.json"  # version strings 排除

    exclude_patterns:
      - "node_modules/**"
      - ".next/**"
      - "dist/**"
      - "build/**"
      - "**/*.d.ts"
      - "**/*.config.*"
      - "**/*.test.*"
      - "**/*.spec.*"

## Workflow

### Phase 1: 项目识别

1. **检测框架类型**:
   - `package.json` 中的 `next` → Next.js
   - `package.json` 中的 `vite` + `react` → Vite React
   - `package.json` 中的 `vue` → Vue

2. **检测现有 i18n**:
   - Next.js: 检查 `next-intl` 或 `next-i18next`
   - Vite/React: 检查 `react-i18next` 或 `i18next`
   - Vue: 检查 `vue-i18n`

### Phase 2: 初始化（如果未配置）

1. **询问用户语言需求**:
   使用 AskUserQuestion 询问：
   - 需要支持哪些语言？（默认选项：zh-CN, en, ja, ko）
   - 默认语言是哪个？

2. **安装依赖并配置**:
   - Next.js: 使用 `next-intl`（最主流）
   - Vite React: 使用 `react-i18next`
   - Vue: 使用 `vue-i18n`

3. **创建基础文件结构**:
   ```
   messages/
     └── zh-CN.json
     └── en.json
   ```

### Phase 3: 硬编码检测

1. **扫描用户侧可见内容**:
   - JSX 中的中文/英文文本
   - placeholder, title, alt, aria-label 属性
   - 错误提示、成功消息
   - 按钮文案、标签文案
   - 表格表头、表单标签

2. **排除项**（非用户感知）:
   - console.log/debug 语句
   - 代码注释
   - 开发时变量名
   - 技术性常量（如 API 路径）
   - package.json 中的版本字符串

3. **生成报告**:
   列出每个文件的硬编码位置和内容：
   ```
   src/components/Button.tsx:12 - "提交"
   src/pages/Home.tsx:45 - "欢迎使用"
   ```

### Phase 4: 确认并修复

1. **向用户展示报告**:
   - 显示发现的硬编码总数
   - 按文件分组展示

2. **使用 AskUserQuestion 确认**:
   - 是否修复全部？
   - 是否跳过某些项？

3. **执行修复**:
   - 替换硬编码为 `t('key')` 调用
   - 生成合理的 key 名（基于上下文）
   - 更新 messages/*.json 文件

### Phase 5: 提交

调用 `Skill(skill: "lovstudio:git:commit-with-context")` 自动提交更改。

## Key Principles

1. **渐进式**: 先检测再修复，给用户确认机会
2. **智能识别**: 区分用户可见 vs 技术内容
3. **幂等性**: 重复运行不会重复添加
4. **框架适配**: 自动选择合适的 i18n 方案

## i18n Key 命名规则

- 组件名 + 语义: `button.submit`, `header.title`
- 页面名 + 区域: `home.hero.title`, `about.description`
- 通用: `common.loading`, `common.error`

## Example Output

```
=== i18n 检测报告 ===

项目类型: Next.js (已配置 next-intl)
当前语言: zh-CN, en

发现 12 处硬编码:

src/components/Header.tsx:
  L15: "首页"
  L16: "关于我们"

src/pages/index.tsx:
  L23: "欢迎使用我们的产品"
  L45: "立即开始"

是否修复这些硬编码？[Y/n]
```
