---
allowed-tools: [Read, Edit, Grep, Glob, Bash, Task]
description: 识别并重构冗余的后端 API（Tauri/REST/GraphQL）
version: "1.0.0"
author: "公众号：手工川"
---

# Refactor API - 后端 API 重构

## 执行流程

### Step 1: 识别后端类型

扫描项目结构，识别后端框架：
- `src-tauri/` → Tauri (Rust)
- `src/api/` 或 `routes/` → REST (Node/Python/Go)
- `schema.graphql` 或 `resolvers/` → GraphQL

### Step 2: 提取 API 清单

**Tauri**:
```bash
grep -n "#\[tauri::command\]" src-tauri/src/**/*.rs -A 1
```

**REST (Express/Fastify)**:
```bash
grep -rn "router\.\(get\|post\|put\|delete\)" src/
```

**GraphQL**:
```bash
grep -rn "Query:\|Mutation:" src/
```

### Step 3: 分析冗余模式

识别以下冗余类型：

1. **读取类冗余**: 多个函数只是读取不同路径的文件
   - 模式: `read_X_file()`, `get_X_content()`, `load_X()`
   - 合并为: 通用 `read_file(path)` + 前端路径拼接

2. **CRUD 冗余**: 同一资源的重复操作
   - 模式: `get_user_settings()`, `get_project_settings()`
   - 合并为: `get_settings(scope, key)`

3. **路径获取冗余**: 多个函数只返回不同路径
   - 模式: `get_X_path()`, `get_Y_path()`
   - 合并为: `get_path(type)` 或前端直接拼接

### Step 4: 生成重构报告

输出格式：
```
## 冗余 API 分析

### 可合并的 API 组

#### 组 1: 文件读取类
| 现有 API | 功能 | 合并方案 |
|---------|------|---------|
| get_X() | 读取 X 文件 | 用 read_file(path) |
| get_Y() | 读取 Y 文件 | 用 read_file(path) |

#### 前端改动
- `get_X()` → `read_file({ path: homeDir + "/x" })`
```

### Step 5: 执行重构

1. **更新前端调用**:
   - 搜索所有调用点: `grep -rn "invoke.*get_X" src/`
   - 替换为通用 API + 路径参数

2. **删除后端冗余函数**:
   - 从源文件删除函数定义
   - 从路由注册/handler 列表中移除

3. **验证**:
   - TypeScript: `pnpm tsc --noEmit`
   - Rust: `cargo check`

## 边界情况处理

- **有副作用的 API**: 不合并，只标记
- **权限差异**: 保留独立 API 或添加权限参数
- **性能敏感**: 批量操作保留专用 API

## 使用示例

```
/refactor-api src-tauri/src/lib.rs
/refactor-api --report-only  # 只分析不重构
```
