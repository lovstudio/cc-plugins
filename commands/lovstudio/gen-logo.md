---
allowed-tools: Read(*), Bash(python3:*, magick:*, vtracer:*, npx:*, mkdir:*, rm:*, ls:*, mv:*, cat:*, cp:*, git:*), Glob(*), AskUserQuestion(*)
description: 迭代式 Logo 生成，支持版本管理和用户反馈
version: "5.0.0"
author: "公众号：手工川"
aliases: /gen-logo
---

# Gen Logo

迭代式 Logo 生成工作流，支持版本管理、用户反馈和最终发布。

## 核心理念

- **不覆盖**: 每次生成保存为新版本 `v{n}-{描述}`
- **迭代优化**: 基于用户反馈持续改进
- **确认发布**: 用户满意后才复制到正式位置
- **项目驱动**: 基于项目功能特性设计，而非字面解读项目名

## 参数

```
/gen-logo [concept] [--use vN] [--publish vN]
```

- `concept`: 设计概念/风格描述
- `--use vN`: 选用第 N 版作为正式 logo
- `--publish vN`: 同 --use，并 git commit

示例：
```
/gen-logo                           # 首次：分析项目自动生成 v1
/gen-logo 更简洁 sharp 风格          # 迭代：基于反馈生成下一版
/gen-logo --use v3                  # 选用 v3 作为正式 logo
/gen-logo --publish v3              # 选用并提交
```

## 工作流程

### Step 0: 初始化草稿目录

```bash
mkdir -p ./assets/logo-drafts
ls ./assets/logo-drafts/ | grep -E '^v[0-9]+-' | sort -V | tail -1
```

获取当前最大版本号 N，下一版为 N+1。

### Step 1: 分析项目（首次生成）

**首次生成 (v1)** - 自动分析，无需询问：

1. 读取 `package.json` 获取：
   - `name`: 项目名（仅用于标识，不做字面解读）
   - `description`: 项目描述
   - `keywords`: 关键词
   - 依赖分析：判断项目类型

2. 读取 `README.md` 获取：
   - 项目功能描述
   - 核心特性

3. **项目类型识别**（基于依赖和描述）：

| 类型 | 识别特征 | 推荐风格 |
|------|----------|----------|
| Web 框架/Starter | next, react, vue, angular | 几何抽象、模块化、网格 |
| CLI 工具 | commander, yargs, bin字段 | 终端符号、尖锐、技术感 |
| 桌面应用 | electron, tauri | 应用图标风格、圆润 |
| 库/SDK | 无UI依赖、纯逻辑 | 极简符号、单一形状 |
| AI/ML | openai, langchain, ml | 神经网络、连接、节点 |

4. **自动生成设计概念**（不解读项目名字面含义）：
   - 基于项目功能而非名称
   - 例：项目名含 "love" 不意味着要用爱心

**迭代生成 (v2+)**:
1. 参考用户的反馈/要求
2. 结合对话上下文调整 prompt
3. 明确改进点

### Step 2: 生成 PNG

```bash
python3 ~/.claude/plugins/cache/lovstudio-plugins-official/lovstudio/1.0.0/skills/image-gen/gen_image.py "PROMPT" \
  -o ./assets/logo-drafts/v{N}-{short_desc}.png -q high
```

命名规则: `v{版本号}-{简短描述}.png`
- v1-initial, v2-simpler, v3-grid, v4-sharp

### Step 3: 处理图片

```bash
cd ./assets/logo-drafts

# 去白底
magick v{N}-{desc}.png -fuzz 5% -transparent white -type TrueColorAlpha PNG32:temp.png
mv temp.png v{N}-{desc}.png

# 转 SVG
magick v{N}-{desc}.png -channel A -threshold 50% +channel temp.png
vtracer --input temp.png --output v{N}-{desc}.svg \
  --mode spline --filter_speckle 8 --color_precision 8 \
  --corner_threshold 120 --segment_length 6 --path_precision 5
npx svgo v{N}-{desc}.svg -o v{N}-{desc}.svg --multipass
rm -f temp.png
```

### Step 4: 展示并获取反馈

使用 Read 工具展示生成的 PNG，然后输出：

```
✓ v{N}-{desc} 生成完成

继续迭代？告诉我改进方向，或 `/gen-logo --publish v{N}` 确认使用
```

### Step 5: 发布（--use 或 --publish）

当用户确认使用某版本时：

```bash
cp ./assets/logo-drafts/v{N}-{desc}.png ./assets/logo.png
cp ./assets/logo-drafts/v{N}-{desc}.svg ./assets/logo.svg
cp ./assets/logo-drafts/v{N}-{desc}.png ./public/logo.png
cp ./assets/logo-drafts/v{N}-{desc}.svg ./public/logo.svg

# 如果是 --publish，还要提交
git add assets/logo* public/logo* assets/logo-drafts/
git commit -m "docs: update logo to v{N}-{desc}"
```

### Step 6: 生成 Tray Icon（Tauri 项目）

如果是 Tauri 项目（存在 `src-tauri/` 目录），自动生成 macOS 菜单栏图标：

```bash
if [ -d "src-tauri/icons" ]; then
  magick ./assets/logo-drafts/v{N}-{desc}.png -gravity center -background transparent \
    -extent "%[fx:max(w,h)]x%[fx:max(w,h)]" ./assets/logo-drafts/v{N}-{desc}-square.png

  magick ./assets/logo-drafts/v{N}-{desc}-square.png -trim +repage \
    -resize 38x44 -gravity center -background transparent -extent 56x44 \
    -colorspace gray -fill white -colorize 100% \
    src-tauri/icons/tray-icon.png

  echo "Tray icon generated"
fi
```

## Prompt 模板

```
Minimalist logo icon for "{project_name}" - {project_description}

Design concept: {auto_generated_from_project_type}

Requirements:
- Warm terracotta color (#D97757)
- Pure white background (will be removed)
- NO TEXT, icon only
- Works at favicon size (16x16)
- 2-3 geometric shapes maximum
- Clean, modern, professional

Style: {style_from_project_type}
```

**按项目类型的 Prompt 关键词：**

| 项目类型 | 设计关键词 |
|----------|------------|
| Web 框架 | modular grid, stacked layers, building blocks, architectural |
| CLI 工具 | terminal cursor, angle brackets, sharp lines, command prompt |
| 桌面应用 | app icon style, rounded corners, depth, gradient-ready |
| 库/SDK | single abstract shape, mathematical, symbolic |
| AI/ML | connected nodes, neural pattern, flowing data |

## 设计原则

1. **功能优先**: 基于项目做什么，而非项目叫什么
2. **极简**: 2-3 个形状，能在 16x16 识别
3. **品牌色**: 陶土色 #D97757（Lovstudio 设计系统）
4. **通用性**: 不依赖文字，纯图形

## 依赖

- python3 + google-genai
- imagemagick (magick)
- vtracer
- svgo

ARGUMENTS: $ARGUMENTS
