---
allowed-tools: [Read, Write, Edit, Glob]
description: 为网站生成隐私政策和服务条款页面
version: "1.1.0"
author: "公众号：手工川"
---
# Legal Pages Generator

为 React 网站生成标准的隐私政策(Privacy Policy)和服务条款(Terms of Service)页面。

## Arguments Format
`[email] [company_name]`

- email: 联系邮箱 (默认从项目常量或 CLAUDE.md 推断)
- company_name: 公司/工作室名称 (默认从项目常量推断)

## Workflow

### 1. 分析项目结构

```
Glob: src/pages/*.tsx
Glob: src/constants/*.ts
Read: src/App.tsx (路由配置)
Read: src/components/Footer.tsx (可选，添加链接)
```

### 2. 提取配置信息

从以下位置获取网站信息：
- `src/constants/site.ts` → AUTHOR_NAME, TAGLINE
- 参数传入 → email, company_name
- 日期 → 使用 JavaScript 动态获取运行时日期（非硬编码）

### 3. 生成页面

**日期格式化**：页面需动态显示更新日期，使用以下模式：
```tsx
// 在组件内计算当前日期
const formattedDate = new Date().toLocaleDateString("zh-CN", {
  year: "numeric",
  month: "long",
  day: "numeric",
});

// 然后在 JSX 中使用
<p className="text-muted-foreground">最后更新日期：{formattedDate}</p>
```

**创建 `src/pages/PrivacyPolicy.tsx`**:
- 信息收集说明
- 信息使用目的
- 信息共享政策
- 数据安全措施
- Cookie 使用
- 第三方服务
- 用户权利
- 联系方式
- 政策更新说明

**创建 `src/pages/TermsOfService.tsx`**:
- 服务接受条款
- 服务描述
- 用户账户责任
- 知识产权声明
- 用户行为规范
- 第三方链接免责
- 服务免责声明
- 服务变更权利
- 适用法律
- 联系方式

### 4. 添加路由

编辑 `src/App.tsx`:
```tsx
import PrivacyPolicy from "./pages/PrivacyPolicy";
import TermsOfService from "./pages/TermsOfService";

// 在 Routes 中添加
<Route path="/privacy" element={<PrivacyPolicy />} />
<Route path="/terms" element={<TermsOfService />} />
```

### 5. 更新 Footer (可选)

如果存在 Footer 组件，在底部添加链接：
```tsx
<Link to="/privacy">隐私政策</Link>
<Link to="/terms">服务条款</Link>
```

## 页面样式要求

- 使用项目现有的 Header/Footer 组件
- 遵循项目 Tailwind 语义化颜色
- 响应式布局，max-w-3xl 居中
- 中文内容，专业法律用语

## 输出

- `/privacy` - 隐私政策页面
- `/terms` - 服务条款页面
- Footer 底部链接（如适用）
