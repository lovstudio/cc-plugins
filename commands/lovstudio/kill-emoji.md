---
allowed-tools: [Task, Read, Edit, Grep, Glob, Bash, TodoWrite]
description: 将项目中的 emoji 替换为 lucide-react/radix 图标
version: "1.0.0"
author: "公众号：手工川"
---
# Kill Emoji

将项目中的 Unicode emoji 替换为图标库组件（lucide-react / radix-ui）。

## Phase 1: 扫描分析

使用 Explore agent 全面扫描项目中的 emoji 使用：

```
搜索项目中所有 emoji 使用场景：
1. Unicode emoji 直接出现在 JSX/TSX 中（如 🎉, 📷, ✨）
2. 特殊符号字符（如 →, ✓, ✗, ✕）
3. 列出每个 emoji 的文件、行号、上下文
```

## Phase 2: 分类决策

将 emoji 分为三类：

| 类别 | 处理方式 | 示例 |
|------|----------|------|
| **UI 交互** | 替换为图标 | ✨按钮、⚠️警告、✕关闭 |
| **业务数据** | 保留原样 | 数据库中的 emoji、海报渲染 |
| **调试日志** | 可选保留 | console.log 中的 emoji |

**判断逻辑**：
- 如果 emoji 在 JSX 中直接渲染 → UI 交互，需替换
- 如果 emoji 存储在数据结构中且用于 canvas/图片生成 → 业务数据，保留
- 如果 emoji 在 console.log/debug 语句中 → 调试日志，可选

## Phase 3: 图标映射

常用 emoji → lucide-react 映射：

```typescript
// 状态/操作
✨ Sparkles → <Sparkles />
⚠️ Warning  → <AlertTriangle />
✓ ✔ Check  → <Check />
✗ ✕ × Close → <X />
→ Arrow     → <ArrowRight />

// 功能
📷 Camera   → <Camera />
🎨 Palette  → <Palette />
📹 Video    → <Video />
🖼️ Image    → <Image />
💾 Save     → <Save />
🗑️ Delete   → <Trash2 />
📥 Download → <Download />
📤 Upload   → <Upload />

// 用户/社交
👤 User     → <User />
👥 Users    → <Users />
🔔 Bell     → <Bell />
💬 Message  → <MessageSquare />

// 导航
🏠 Home     → <Home />
⚙️ Settings → <Settings />
🔍 Search   → <Search />
🚀 Rocket   → <Rocket />
```

## Phase 4: 执行替换

1. **添加 import**：在文件顶部添加 lucide-react 导入
2. **替换 emoji**：用图标组件替换 Unicode emoji
3. **调整样式**：确保图标大小、颜色与原设计一致

**替换模式**：

```tsx
// Before
<button>✨ Generate</button>

// After
import { Sparkles } from 'lucide-react'
<button><Sparkles className="w-4 h-4 mr-1" /> Generate</button>
```

## Phase 5: 验证

```bash
pnpm check:types  # 类型检查
```

## 注意事项

- **不要替换业务数据中的 emoji**：如 SPIRIT_INFO、数据库字段
- **保持视觉一致性**：图标大小通常为 `w-4 h-4` 或 `w-5 h-5`
- **添加适当间距**：图标和文字之间用 `mr-1` 或 `mr-1.5`
- **检查项目已有图标库**：优先使用项目中已安装的库

## 输出

完成后输出：
1. 替换汇总表（文件 | 原 emoji | 新图标）
2. 保留的 emoji 及原因
3. 类型检查结果
