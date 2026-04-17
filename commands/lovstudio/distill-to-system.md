---
allowed-tools: [Read, Edit, AskUserQuestion]
description: Distill info to CLAUDE.md system config
version: "1.0.0"
author: "公众号：手工川"
---
# Distill to System

将重要信息持久化到 CLAUDE.md，供后续会话使用。

## 触发场景

1. **手动**: `/distill-to-system <info>` - 用户指定要保存的信息
2. **AI 主动**: 发现以下信息时建议持久化：
   - API/SDK 重大变更（如 Supabase key 格式）
   - CLI 工具用法更新
   - 踩坑经验（调试良久才发现的问题）
   - 项目关键约定

## 目标文件

| 信息类型 | 目标 |
|---------|------|
| 通用（Supabase/Vercel/AWS...） | `~/.claude/CLAUDE.md` |
| 项目特定 | `{project}/CLAUDE.md` |
| 不确定 | 询问用户 |

## 格式要求

- **1-3 行**: 极简，context 宝贵
- **可操作**: 包含具体命令/用法
- **可溯源**: 附参考链接
- **归类**: 放在合适 section 下

## 流程

```
1. 判断 → 全局 or 项目
2. Read 目标文件
3. 找/创建 section
4. Edit 追加（去重）
5. 确认
```

## 示例

输入: `Supabase 新 key sb_secret_... 替代 service_role`

输出 (追加到 `~/.claude/CLAUDE.md`):
```markdown
## Supabase
- **新 Key**: `sb_secret_...` 替代 service_role (2026底弃用)
- Ref: https://github.com/orgs/supabase/discussions/29260
```
