---
allowed-tools: [Read, Edit, Write, Bash, Glob]
description: 为当前项目生成稳定端口号并配置到项目中
version: "1.1.0"
author: "公众号：手工川"
---

# Init Port

为当前项目生成稳定唯一的端口号（范围 3000-8999），并自动配置到项目中。

## 端口生成算法

```python
def generate_port(project_name: str) -> int:
    hash_value = sum(ord(c) * (i + 1) for i, c in enumerate(project_name))
    return 3000 + (hash_value % 6000)
```

## 执行流程

### 1. 获取项目名

从 `package.json` 的 `name` 字段读取，若无则使用当前目录名。

### 2. 计算端口

使用上述算法生成端口号。

### 3. 更新配置

检测项目类型并更新相应配置（幂等操作）：

**Next.js 项目**（检测到 `next` 依赖）：
1. `.env` 或 `.env.local`：添加或更新 `PORT=<port>`
2. `package.json` scripts：**必须**更新 `next dev -p <port>`（Next.js 不读取 .env 中的 PORT）

**Vite 项目**（检测到 `vite.config.ts`）：
1. `.env` 或 `.env.local`：添加或更新 `PORT=<port>`
2. `vite.config.ts`：设置 `server.port`

**其他项目**：
1. `.env` 或 `.env.local`：添加或更新 `PORT=<port>`
2. `package.json` scripts：更新 `--port` 参数

仅更新已存在的配置文件，不创建新文件。

### 4. 输出结果

```
项目 "<name>" 的端口号：<port>
已更新配置：<更新的文件列表>
```

## 端口冲突

若用户反馈端口被占用：
- 提示使用 `lsof -i :<port>` 查看占用进程
- 建议追加后缀：`generate_port("project-dev")`
