---
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
description: 为项目集成 ZenMux API（Supabase Edge Function 代理）
version: "1.0.0"
author: "公众号：手工川"
---

# Install ZenMux API

为当前项目添加 ZenMux API 代理，支持 Gemini 图片生成等功能。

## Process

### Step 1: 检测项目类型

```bash
# 检查是否有 Supabase
ls supabase/config.toml 2>/dev/null
```

如果没有 Supabase → 报错退出，提示用户先初始化 Supabase

### Step 2: 创建 Edge Function

创建 `supabase/functions/zenmux-proxy/index.ts`：

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { endpoint, body } = await req.json();
    const ZENMUX_API_KEY = Deno.env.get("ZENMUX_API_KEY");

    if (!ZENMUX_API_KEY) {
      return new Response(
        JSON.stringify({ error: "ZENMUX_API_KEY not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const response = await fetch(`https://zenmux.ai/api${endpoint}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${ZENMUX_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    const data = await response.json();

    return new Response(JSON.stringify(data), {
      status: response.status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
```

### Step 3: 设置 Secret

```bash
# 从已有项目获取 key（如果存在）
ZENMUX_KEY=$(grep ZENMUX_API_KEY ~/.env* ~/projects/*/.env* 2>/dev/null | head -1 | cut -d= -f2 | tr -d '"')

# 如果没找到，提示用户
if [ -z "$ZENMUX_KEY" ]; then
  echo "请提供 ZENMUX_API_KEY（从 https://zenmux.ai/settings/keys 获取）"
  exit 1
fi

supabase secrets set ZENMUX_API_KEY="$ZENMUX_KEY"
```

### Step 4: 部署

```bash
supabase functions deploy zenmux-proxy
```

### Step 5: 创建前端 Hook（可选）

如果是 React 项目，创建 `src/hooks/useZenmux.ts`：

```typescript
import { supabase } from "@/integrations/supabase/client";

export async function callZenmux(endpoint: string, body: object) {
  const { data, error } = await supabase.functions.invoke("zenmux-proxy", {
    body: { endpoint, body },
  });

  if (error) throw new Error(error.message);
  if (data.error) throw new Error(data.error);
  return data;
}

// 图片生成便捷方法
export async function generateImage(prompt: string) {
  const model = "google/gemini-2.5-flash-image";
  const data = await callZenmux(`/vertex-ai/v1/models/${model}:generateContent`, {
    contents: [{ role: "user", parts: [{ text: prompt }] }],
    generationConfig: { responseModalities: ["TEXT", "IMAGE"] },
  });

  const parts = data?.candidates?.[0]?.content?.parts || [];
  const imagePart = parts.find((p: any) => p.inlineData?.data);

  if (!imagePart) throw new Error("No image generated");

  return {
    image: imagePart.inlineData.data,
    mimeType: imagePart.inlineData.mimeType || "image/png",
  };
}
```

## Output

完成后输出：
- Edge Function URL
- 使用示例
