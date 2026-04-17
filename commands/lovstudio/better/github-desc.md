---

allowed-tools: [Read(*), Bash(gh:*)]
description: 基于 README.md 自动更新 GitHub 仓库信息
version: "1.1.0"
author: "公众号：手工川"
aliases: /better-github-desc
---

# 更新仓库信息

基于项目 README.md 文件自动更新 GitHub 仓库的描述、话题标签和网站链接。

## 执行步骤

1. 读取 @README.md 文件
2. 提取项目描述（通常是 `<strong>` 标签内的一行描述）
3. 根据内容分析相关话题标签
4. 获取项目名称（从 package.json 或目录名）
5. 使用 gh repo edit 命令更新仓库信息：
   - `--description` 项目描述
   - `--homepage` 网站链接，默认为 `https://lovstudio.ai/app/$project_name`
   - `--add-topic` 相关话题标签

## 使用方法

在项目根目录执行：`/lovstudio/better-github-desc`

## 注意事项

- 需要安装 GitHub CLI (gh)
- 需要有仓库的写入权限
- 建议在 git 仓库中使用
- 网站链接默认指向 lovstudio.ai/app/$project_name

ARGUMENTS: $ARGUMENTS
