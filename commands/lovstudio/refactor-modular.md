---
allowed-tools: Read(*), Write(*), Edit(*), Glob(*), Grep(*), Bash(mkdir:*)
description: 将长代码文件重构为模块化、组件化的短文件结构
argument-hint: <file-path>
version: "1.2.0"
author: "公众号：手工川"
---

# Modular Refactoring Command

将输入的长代码文件重构为模块化、职责单一的短文件。

## Input

目标文件路径: $1

**重要**：
- 如果 `$1` 为空或不存在，立即使用 AskUserQuestion 询问用户要重构的文件路径
- 如果路径以 `@` 开头（如 `@src/file.ts`），去掉 `@` 前缀后使用
- 支持相对路径和绝对路径

## Process

### 1. 分析阶段

读取目标文件，识别：
- **类型定义** → `types.ts` 或 `types/`
- **常量/配置** → `constants.ts` 或 `config.ts`
- **工具函数** → `utils.ts` 或 `utils/`
- **Hooks** → `hooks/` (React)
- **组件** → `components/` (按功能拆分)
- **服务/API** → `services/` 或 `api/`
- **状态管理** → `store/` 或 `context/`

### 2. 重构原则

遵循 SOLID：
- **S**ingle Responsibility: 每个文件只做一件事
- **O**pen-Closed: 通过扩展而非修改
- **L**iskov Substitution: 可替换的抽象
- **I**nterface Segregation: 小而专的接口
- **D**ependency Inversion: 依赖抽象

目标：
- 每个文件 < 150 行
- 每个函数 < 30 行
- 每个组件 < 100 行

### 3. 输出结构

```
原文件目录/
├── index.ts          # 统一导出
├── types.ts          # 类型定义
├── constants.ts      # 常量配置
├── utils/            # 工具函数
│   ├── index.ts
│   └── [function].ts
├── hooks/            # React Hooks
│   ├── index.ts
│   └── use[Name].ts
├── components/       # UI 组件
│   ├── index.ts
│   └── [Component]/
│       ├── index.tsx
│       └── [SubComponent].tsx
└── services/         # 业务逻辑
    ├── index.ts
    └── [service].ts
```

### 4. 执行步骤

1. **读取**原文件内容
2. **分析**代码结构和依赖关系
3. **规划**拆分方案（先展示给用户确认）
4. **创建**目录结构
5. **拆分**代码到各文件
6. **更新**导入导出
7. **验证**无循环依赖

### 5. 命名规范

| 类型 | 命名 | 示例 |
|------|------|------|
| 类型文件 | `types.ts` | `UserTypes.ts` |
| Hook | `use[Name].ts` | `useAuth.ts` |
| 组件 | `PascalCase` | `UserCard.tsx` |
| 工具 | `camelCase` | `formatDate.ts` |
| 常量 | `UPPER_SNAKE` | `API_ENDPOINTS` |

## Output

完成后输出：
1. 创建的文件列表
2. 每个文件的职责说明
3. 依赖关系图（简化版）

---

**执行**: 立即读取 `$1` 文件并开始分析。如果参数为空，先询问用户。
