---
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep]
description: Install logo to Tauri app icons (tray + bundle) — aligns with project theme, ensures menubar visibility
version: "4.1.0"
author: "公众号：手工川"
---
# Install Tauri Logo

Generate and install logo files for a Tauri application using official Tauri CLI. Ensures tray icon renders correctly on the macOS menubar regardless of source logo color.

## Prerequisites

- Source logo: `assets/logo.png` or `public/logo.png` (ideally 1024x1024 PNG/SVG, with transparent background)
- Tauri project with `src-tauri/` directory
- `@tauri-apps/cli` installed (or use npx)
- `magick` (ImageMagick) installed

## Process

### Step 1: Detect & Verify Source Logo

```bash
# Priority: --source arg > assets/logo.png > public/logo.png > src-tauri/icons/icon.png
LOGO=""
for p in assets/logo.png public/logo.png src-tauri/icons/icon.png; do
  [ -f "$p" ] && LOGO="$p" && break
done

if [ -z "$LOGO" ]; then
  echo "❌ No logo found. Run /gen-logo first."
  exit 1
fi

# Show source info so user can confirm it's the intended (latest) logo.
# Pitfall: /gen-logo only writes to assets/logo-drafts/ — must be --publish'd
# to assets/logo.png before running this command.
echo "Source: $LOGO"
ls -la "$LOGO"
md5 "$LOGO" 2>/dev/null || md5sum "$LOGO"
magick identify "$LOGO"
```

If the user just ran `/gen-logo` without `--publish`, stop and remind them:
`assets/logo.png` is still the **previous** logo. Publish the draft first.

### Step 2: Detect Project Theme Color

Tauri app icons use a colored rounded-rectangle background. The color should match the project's design system, not be hardcoded.

Resolution order:
1. `--theme-color <hex>` argument
2. `CLAUDE.md` → look for `Primary.*#[0-9A-Fa-f]{6}` or `陶土色.*#[0-9A-Fa-f]{6}`
3. Tailwind config → `primary`
4. Fallback: `#CC785C` (Lovstudio terracotta)

```bash
THEME_COLOR=""
# 1. CLI arg already captured as $THEME_COLOR_ARG
[ -n "$THEME_COLOR_ARG" ] && THEME_COLOR="$THEME_COLOR_ARG"

# 2. Project CLAUDE.md
if [ -z "$THEME_COLOR" ] && [ -f "CLAUDE.md" ]; then
  THEME_COLOR=$(grep -oE '(Primary|陶土色)[^#]*#[0-9A-Fa-f]{6}' CLAUDE.md | grep -oE '#[0-9A-Fa-f]{6}' | head -1)
fi

# 3. Fallback
[ -z "$THEME_COLOR" ] && THEME_COLOR="#CC785C"

echo "Theme color: $THEME_COLOR"
```

### Step 3: Generate App Icons (Dock + Bundle)

生成 macOS 风格的 Dock 图标：圆角矩形背景 + 白色 logo。

```bash
CANVAS=1024
ICON_SIZE=824
OFFSET=$(( (CANVAS - ICON_SIZE) / 2 ))
CORNER_RADIUS=185  # ~22% of ICON_SIZE (macOS Big Sur+)
LOGO_PX=$((ICON_SIZE * 65 / 100))

# Rounded rectangle background
magick -size ${CANVAS}x${CANVAS} xc:none \
  -fill "$THEME_COLOR" \
  -draw "roundrectangle ${OFFSET},${OFFSET} $((OFFSET + ICON_SIZE)),$((OFFSET + ICON_SIZE)) ${CORNER_RADIUS},${CORNER_RADIUS}" \
  /tmp/dock-bg.png

# White logo (from alpha shape — works for transparent-bg logos)
magick "$LOGO" -trim +repage \
  -resize ${LOGO_PX}x${LOGO_PX} \
  -colorspace gray -fill white -colorize 100% \
  -gravity center -background none -extent ${CANVAS}x${CANVAS} \
  /tmp/dock-logo.png

# Composite
magick /tmp/dock-bg.png /tmp/dock-logo.png -gravity center -composite /tmp/dock-icon.png

# Generate all bundle sizes
npx tauri icon /tmp/dock-icon.png

rm -f /tmp/dock-bg.png /tmp/dock-logo.png /tmp/dock-icon.png
```

This generates in `src-tauri/icons/`:
- `icon.icns` - macOS Dock & App bundle
- `icon.ico` - Windows taskbar & installer
- Various PNG sizes for Linux/Android/iOS

### Step 4: Generate Tray Icon (macOS Menubar)

If `--no-tray` is NOT specified. **Critical**: use black-on-transparent (not white) for template icons — macOS inverts template icons based on menubar color.

**Why black, not white?** A white template icon looks invisible on a light-mode menubar because `icon_as_template(true)` treats non-transparent pixels as *the shape to invert*. When source logo has a transparent background with colored foreground, we want the **alpha channel** (foreground silhouette) filled with any solid color — black is the safest default.

```bash
ICONS="src-tauri/icons"

# Use alpha channel as shape, fill RGB with black, keep alpha transparency.
# macOS will invert black→white in dark mode automatically.
magick "$LOGO" -trim +repage \
  -resize 38x44 \
  -background none -gravity center -extent 56x44 \
  -channel RGB -evaluate set 0 +channel \
  "$ICONS/tray-icon.png"

# Verify: should be GrayscaleAlpha, 56x44, non-empty shape
magick identify "$ICONS/tray-icon.png"
echo "Tray icon: 38x44 content in 56x44 canvas, black template (macOS auto-inverts)"
```

**Tray Icon 规格：**
| 属性 | 值 | 说明 |
|------|-----|------|
| 颜色 | 黑色 (RGB=0) | macOS template icon，`icon_as_template(true)` 自动反色 |
| Alpha | 原 logo alpha | 形状由 source logo 透明度决定 |
| 内容尺寸 | 38x44 | 高度几乎填满 |
| 画布尺寸 | 56x44 | 横向 9px 间距，与其他 app 对齐 |

**Common failure modes:**
- Source logo has opaque white background → tray will be a solid rectangle. **Fix**: run the logo through `/gen-logo` publish (which produces transparent-bg) or manually `magick logo.png -fuzz 5% -transparent white logo.png`.
- Tray icon appears blank in light mode → means it was filled white instead of black. Re-run Step 4.

### Step 5: Update Rust Code

If `--no-rust` is NOT specified, ensure `src-tauri/src/lib.rs` (or `main.rs`) loads the custom tray icon.

**Required Cargo dep** (`src-tauri/Cargo.toml`):
```toml
[dependencies]
image = "0.25"
```

**Required code pattern** (in `setup_tray` or wherever `TrayIconBuilder` is used):
```rust
let tray_icon_bytes = include_bytes!("../icons/tray-icon.png");
log::info!("tray-icon.png embedded bytes: {}", tray_icon_bytes.len());

let tray_icon = image::load_from_memory(tray_icon_bytes)
    .map(|img| {
        let rgba = img.to_rgba8();
        let (w, h) = rgba.dimensions();
        log::info!("tray icon decoded: {}x{}", w, h);
        tauri::image::Image::new_owned(rgba.into_raw(), w, h)
    })
    .expect("failed to decode tray-icon.png"); // explicit panic, NOT silent fallback

TrayIconBuilder::new()
    .icon(tray_icon)
    .icon_as_template(true)  // macOS auto light/dark inversion
    // ... menu, handlers, etc.
    .build(app)?;
```

**Key points:**
- `include_bytes!` embeds the PNG at **compile time** → changes require rebuild
- Use `.expect()` not `.unwrap_or_else(fallback)` — silent fallback to `default_window_icon()` hides decoding bugs
- Always set `icon_as_template(true)` on macOS for menubar visual consistency

### Step 6: Clear macOS Caches

```bash
if [[ "$OSTYPE" == darwin* ]]; then
  killall Dock 2>/dev/null || true
fi
```

### Step 7: Rebuild Verification

**This is critical.** The tray icon is compiled into the binary — a running dev process shows the *old* icon until rebuild.

```bash
# Stop any running dev process
pkill -f "target/debug/$(basename $(pwd))" 2>/dev/null || true

echo ""
echo "⚠️  REBUILD REQUIRED:"
echo "   Stop current 'pnpm tauri:dev' (Ctrl+C) and restart it."
echo "   Incremental cargo compile will pick up the new tray-icon.png."
echo ""
echo "Verify after restart by checking logs for:"
echo "   'tray-icon.png embedded bytes: <N>'"
echo "   'tray icon decoded: 56x44'"
echo ""
echo "If icons still look stale: rm -rf src-tauri/target && pnpm tauri:dev"
```

### Step 8: Summary

Print:
- Source logo path + md5 (so user can cross-check it's the intended version)
- Theme color used
- Generated files: `icon.icns`, `icon.ico`, `tray-icon.png`, PNG bundle sizes
- Rust code status: "already configured" / "updated" / "needs manual edit"
- **Explicit reminder to restart dev server**

### Step 9: Prompt for Web Logo

> "是否需要继续执行 `/install-web-logo` 来配置 Web 端的 favicon、OG image 等？"

## Arguments

- `--source <path>`: Override source logo path
- `--theme-color <hex>`: Override theme color (e.g. `#CC785C`)
- `--no-tray`: Skip tray icon generation
- `--no-rust`: Skip Rust code modification

## Design Principles

1. **Fail loud, not silent**: `.expect()` over `.unwrap_or_else(fallback)` so failures surface
2. **Project-aligned**: read theme color from CLAUDE.md, not hardcoded
3. **Template icon correctness**: black alpha-shape for macOS menubar, not white
4. **Compile-time awareness**: `include_bytes!` requires rebuild — make it impossible to miss

ARGUMENTS: $ARGUMENTS
