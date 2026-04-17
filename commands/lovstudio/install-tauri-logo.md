---
allowed-tools: [Bash, Read, Write, Edit, Glob]
description: Install logo to Tauri app icons (tray + bundle)
version: "4.0.0"
author: "公众号：手工川"
---
# Install Tauri Logo

Generate and install logo files for a Tauri application using official Tauri CLI.

## Prerequisites

- Source logo: `assets/logo.png` or `public/logo.png` (ideally 1024x1024 PNG/SVG)
- Tauri project with `src-tauri/` directory
- `@tauri-apps/cli` installed (or use npx)

## Process

### Step 1: Detect Source Logo

```bash
# Priority: --source arg > assets/logo.png > public/logo.png > src-tauri/icons/icon.png
LOGO=""
for p in assets/logo.png public/logo.png src-tauri/icons/icon.png; do
  [ -f "$p" ] && LOGO="$p" && break
done
```

If no logo found, abort with message to run `/gen-logo` first.

### Step 2: Generate App Icons (Dock + Bundle)

生成 macOS 风格的 Dock 图标：圆角矩形背景 + 白色 logo。

```bash
# 主题色背景 + 白色 logo（符合 macOS 图标规范）
THEME_COLOR="#E76F4D"  # 陶土色
CANVAS=1024            # 画布尺寸
ICON_SIZE=824          # 圆角矩形尺寸（~80%，留出标准边距）
OFFSET=$(( (CANVAS - ICON_SIZE) / 2 ))  # 居中偏移 = 100px
CORNER_RADIUS=185      # macOS Big Sur+ 圆角比例 (~22% of ICON_SIZE)

# 创建带边距的圆角矩形背景
magick -size ${CANVAS}x${CANVAS} xc:none \
  -fill "$THEME_COLOR" \
  -draw "roundrectangle ${OFFSET},${OFFSET} $((OFFSET + ICON_SIZE)),$((OFFSET + ICON_SIZE)) ${CORNER_RADIUS},${CORNER_RADIUS}" \
  /tmp/dock-bg.png

# 白色 logo，缩放到圆角矩形的 65% 并居中
LOGO_SIZE=$((ICON_SIZE * 65 / 100))
magick "$LOGO" -trim +repage \
  -resize ${LOGO_SIZE}x${LOGO_SIZE} \
  -colorspace gray -fill white -colorize 100% \
  -gravity center -background none -extent ${CANVAS}x${CANVAS} \
  /tmp/dock-logo.png

# 合成
magick /tmp/dock-bg.png /tmp/dock-logo.png -gravity center -composite /tmp/dock-icon.png

# 使用 Tauri CLI 生成所有尺寸
npx tauri icon /tmp/dock-icon.png

# 清理临时文件
rm -f /tmp/dock-bg.png /tmp/dock-logo.png /tmp/dock-icon.png
```

This generates in `src-tauri/icons/`:
- `icon.icns` - macOS Dock & App bundle (824x824 圆角矩形 + 白色 logo，1024x1024 画布)
- `icon.ico` - Windows taskbar & installer
- Various PNG sizes for Linux and notifications

### Step 3: Generate Tray Icon (Optional)

If `--no-tray` is NOT specified, generate white template icon for macOS menu bar:

```bash
ICONS="src-tauri/icons"

# 生成 tray icon: 白色、38x44内容、56x44画布
# - 白色：macOS 菜单栏 template icon，自动适配深浅模式
# - 38x44：几乎填满高度，视觉饱满
# - 56x44：横向留出间距，与其他 app 图标对齐
magick "$LOGO" -trim +repage \
  -resize 38x44 -gravity center -background transparent -extent 56x44 \
  -colorspace gray -fill white -colorize 100% \
  "$ICONS/tray-icon.png"

echo "Tray icon: 38x44 content in 56x44 canvas, white template"
```

**Tray Icon 规格：**
| 属性 | 值 | 说明 |
|------|-----|------|
| 颜色 | 白色 | macOS template icon，自动适配深浅模式 |
| 内容尺寸 | 38x44 | 高度几乎填满，视觉饱满 |
| 画布尺寸 | 56x44 | 横向各 9px 间距，与其他 app 图标对齐 |

### Step 4: Update Rust Code (Optional)

If `--no-rust` is NOT specified, check `src-tauri/src/lib.rs` or `main.rs` for tray setup.

If tray code exists but doesn't load custom icon, add:

```rust
// In Cargo.toml: image = "0.25"

let tray_icon_bytes = include_bytes!("../icons/tray-icon.png");
let tray_icon = image::load_from_memory(tray_icon_bytes)
    .map(|img| {
        let rgba = img.to_rgba8();
        let (width, height) = rgba.dimensions();
        tauri::image::Image::new_owned(rgba.into_raw(), width, height)
    })
    .unwrap_or_else(|_| app.default_window_icon().unwrap().clone());

TrayIconBuilder::with_id("main-tray")
    .icon(tray_icon)
    .icon_as_template(true)  // macOS auto light/dark
```

### Step 5: Clear Cache (macOS)

```bash
# Clear Dock icon cache if icons don't update
if [[ "$OSTYPE" == darwin* ]]; then
  killall Dock 2>/dev/null || true
fi
```

### Step 6: Summary

Output:
- Generated files list
- Reminder to rebuild: `pnpm tauri build` or `npm run tauri dev`
- If cache issues persist: `rm -rf src-tauri/target`

### Step 7: Prompt for Web Logo

After completion, ask user:

> "是否需要继续执行 `/install-web-logo` 来配置 Web 端的 favicon、OG image 等？"

## Arguments

- `--source <path>`: Override source logo path
- `--no-tray`: Skip tray icon generation
- `--no-rust`: Skip Rust code modification

ARGUMENTS: $ARGUMENTS
