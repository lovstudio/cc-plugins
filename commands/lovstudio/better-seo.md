---
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Task]
description: 分析并优化 Next.js 项目的 SEO
version: "1.0.0"
author: "公众号：手工川"
---

# SEO 优化命令

对 Next.js App Router 项目进行全面 SEO 分析和优化。

## 执行流程

### 1. 分析现状

使用 Task(Explore) 分析项目 SEO 实现状态：

```
检查项：
- 各页面 metadata 导出情况
- generateMetadata 动态 metadata
- sitemap.ts / robots.txt
- OpenGraph / Twitter Cards
- JSON-LD 结构化数据
- canonical URLs
- noindex 标记（admin/auth）
```

### 2. 生成分析报告

输出表格形式的 SEO 分析报告：

| 优先级 | 问题 | 影响 |
|--------|------|------|
| 🔴 Critical | 问题描述 | 影响说明 |
| 🟠 High | ... | ... |
| 🟡 Medium | ... | ... |

### 3. 创建 SEO 工具库

如果不存在 `src/lib/seo.ts`（或 `lib/seo.ts`），创建：

```typescript
import type { Metadata } from "next"

export const SITE_CONFIG = {
  name: "站点名称",
  url: "https://example.com",
  description: "站点描述",
  author: "作者",
  locale: "zh_CN",
  twitter: "@handle",
  ogImage: "/opengraph-image",
}

export function createMetadata({
  title,
  description,
  path = "",
  image,
  noIndex = false,
  type = "website",
}: {
  title: string
  description: string
  path?: string
  image?: string
  noIndex?: boolean
  type?: "website" | "article"
}): Metadata {
  // 完整实现包含 canonical、OG、Twitter Cards
}

// JSON-LD 生成函数
export function getOrganizationJsonLd() { ... }
export function getWebsiteJsonLd() { ... }
export function getFAQJsonLd(faqs: ...) { ... }
export function getSoftwareAppJsonLd(app: ...) { ... }
```

### 4. 优化清单

按优先级执行：

1. **首页 metadata**（最关键）
2. **创建 sitemap.ts**（动态生成所有页面）
3. **更新 robots.txt**（添加 Sitemap URL + Disallow 规则）
4. **创建 opengraph-image.tsx**（Edge Runtime 动态 OG 图）
5. **各页面统一使用 createMetadata()**
6. **Admin/Auth 添加 noindex**
7. **动态页面添加 generateStaticParams**
8. **Root Layout 添加 JSON-LD**

### 5. 验证

```bash
pnpm build
```

确认：
- `/sitemap.xml` 生成
- `/opengraph-image` 生成
- 所有页面正确预渲染

## 关键文件模板

### sitemap.ts

```typescript
import type { MetadataRoute } from "next"

export default function sitemap(): MetadataRoute.Sitemap {
  const BASE_URL = "https://example.com"
  const now = new Date()

  return [
    { url: BASE_URL, lastModified: now, changeFrequency: "daily", priority: 1 },
    // 动态生成所有页面
  ]
}
```

### opengraph-image.tsx

```typescript
import { ImageResponse } from "next/og"

export const runtime = "edge"
export const alt = "站点名称"
export const size = { width: 1200, height: 630 }
export const contentType = "image/png"

export default async function Image() {
  return new ImageResponse(/* JSX */)
}
```

### robots.txt

```
User-agent: *
Allow: /

Disallow: /admin
Disallow: /auth

Sitemap: https://example.com/sitemap.xml
```

## 注意事项

- Client Component (use client) 不能导出 metadata，需拆分为 Server Layout + Client 内容组件
- 动态路由需要 generateStaticParams 提升构建性能
- OG 图片尺寸标准：1200x630
- Twitter Card 类型：summary_large_image
