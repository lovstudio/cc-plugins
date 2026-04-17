---

allowed-tools: [Read(*), Edit(*), Glob(*), Grep(*), Bash(pnpm:*), Bash(npm:*)]
description: Refactor and clean CSS code with Tailwind CSS optimization
version: "1.0.0"
author: "公众号：手工川"
aliases: /better-css
---

# Better CSS Command

智能 CSS 代码重构工具，专注于优化和清理 CSS 代码质量。

## 核心功能

### 1. CSS 冗余清理
- 识别并删除未使用的 CSS 类
- 合并重复的样式定义
- 移除过时的浏览器前缀

### 2. Tailwind CSS 迁移
- 将传统 CSS 转换为 Tailwind utility classes
- 保留必要的自定义样式（动画、特殊效果）
- 优化 className 结构

### 3. 代码组织优化
- 按功能分组样式定义
- 压缩冗长的样式声明
- 统一代码格式

## 执行流程

### 阶段 1: 分析现状
1. 扫描所有 CSS 文件
2. 分析组件中的 className 使用情况
3. 识别可优化的部分

### 阶段 2: 制定计划
1. 列出可迁移到 Tailwind 的样式
2. 标记需要保留的自定义样式
3. 识别未使用的 CSS 类

### 阶段 3: 执行重构
1. 将基础样式转换为 Tailwind classes
2. 更新组件 className
3. 清理 CSS 文件

### 阶段 4: 验证结果
1. 运行类型检查
2. 对比文件大小
3. 生成重构报告

## 保留策略

### 必须保留的样式
- ✅ @keyframes 动画定义
- ✅ 浏览器特定样式（::-webkit-scrollbar）
- ✅ 复杂的伪类/伪元素组合
- ✅ 需要 !important 的覆盖样式
- ✅ 第三方库要求的特定类

### 可以迁移的样式
- ✅ 布局（flex, grid, position）
- ✅ 间距（margin, padding）
- ✅ 颜色和背景
- ✅ 边框和圆角
- ✅ 字体和文本样式
- ✅ 基础过渡和变换

## 优化原则

### KISS 原则
- 优先使用 Tailwind 标准类
- 避免过度自定义
- 保持简单直观

### 性能优先
- 减小 CSS 文件体积
- 减少运行时样式计算
- 利用 Tailwind 的 JIT 模式

### 可维护性
- 统一样式命名规范
- 清晰的代码结构
- 完善的注释说明

## 使用示例

### 基础重构
```bash
/lovstudio/better-css
```
自动分析并优化项目中的所有 CSS 文件

### 指定文件
```bash
/lovstudio/better-css src/App.css
```
重构特定的 CSS 文件

### 仅分析不修改
```bash
/lovstudio/better-css --dry-run
```
生成分析报告，不修改文件

## 输出格式

### 重构报告
```
Clean CSS Report
================

Original Size: 790 lines
Optimized Size: 105 lines
Reduction: 87%

Removed:
- 45 unused classes
- 78 lines of markdown-preview styles
- 22 lines of wysiwyg-container styles

Migrated to Tailwind:
- 156 layout declarations
- 89 spacing declarations
- 67 color/background declarations

Retained:
- 8 @keyframes animations
- 3 rank-badge color configs
- 19 lines of scrollbar styles
```

## 最佳实践

### 迁移优先级
1. **高优先级**: 布局和间距（最常用）
2. **中优先级**: 颜色、字体、边框
3. **低优先级**: 复杂交互、特殊效果

### 渐进式重构
- 一次处理一个文件
- 保持功能正常运行
- 及时提交版本控制

### 团队协作
- 更新样式指南
- 同步 Tailwind 配置
- 培训团队成员

## 注意事项

⚠️ **备份提醒**
- 重构前确保代码已提交
- 建议在独立分支进行

⚠️ **兼容性检查**
- 验证浏览器支持
- 测试响应式布局
- 检查暗色模式

⚠️ **性能测试**
- 对比构建产物大小
- 测量首屏加载时间
- 检查运行时性能

## 技术栈要求

- 项目使用 Tailwind CSS
- 支持 TypeScript/JavaScript
- 使用 npm/pnpm/yarn 包管理器

ARGUMENTS: $ARGUMENTS
