---
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep]
description: Install and align logo files for web applications
version: "1.2.0"
author: "公众号：手工川"
---
# Install Web Logo

Generate and install unified logo files for web applications (favicon, OG images, manifest icons, etc.).

## Prerequisites

- Source logo: `assets/logo.png` or `public/logo.png` (ideally 1024x1024 PNG/SVG)
- ImageMagick installed (`magick` command)

## Process

### Step 1: Detect Source Logo

```bash
LOGO=""
for p in assets/logo.png public/logo.png src/assets/logo.png; do
  [ -f "$p" ] && LOGO="$p" && break
done
```

If no logo found, abort with message to run `/gen-logo` first.

### Step 2: Detect Project Type

```bash
# Detect framework/project type
if [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ]; then
  PROJECT_TYPE="nextjs"
  PUBLIC_DIR="public"
  APP_DIR="app"  # or src/app
elif [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
  PROJECT_TYPE="vite"
  PUBLIC_DIR="public"
elif [ -f "angular.json" ]; then
  PROJECT_TYPE="angular"
  PUBLIC_DIR="src/assets"
else
  PROJECT_TYPE="generic"
  PUBLIC_DIR="public"
fi
```

### Step 3: Generate Favicon Set

```bash
mkdir -p "$PUBLIC_DIR"

# favicon.ico (multi-size ICO: 16, 32, 48)
magick "$LOGO" -resize 48x48 -define icon:auto-resize=48,32,16 "$PUBLIC_DIR/favicon.ico"

# Modern favicon PNG sizes
magick "$LOGO" -resize 32x32 "$PUBLIC_DIR/favicon-32x32.png"
magick "$LOGO" -resize 16x16 "$PUBLIC_DIR/favicon-16x16.png"

# Apple Touch Icon (180x180)
magick "$LOGO" -resize 180x180 "$PUBLIC_DIR/apple-touch-icon.png"

# PWA icons (both naming conventions for compatibility)
magick "$LOGO" -resize 192x192 "$PUBLIC_DIR/android-chrome-192x192.png"
magick "$LOGO" -resize 512x512 "$PUBLIC_DIR/android-chrome-512x512.png"
cp "$PUBLIC_DIR/android-chrome-192x192.png" "$PUBLIC_DIR/icon-192x192.png"
cp "$PUBLIC_DIR/android-chrome-512x512.png" "$PUBLIC_DIR/icon-512x512.png"

# Copy original logo
cp "$LOGO" "$PUBLIC_DIR/logo.png"

# SVG versions (for modern browsers and components)
if [ -f "${LOGO%.png}.svg" ]; then
  cp "${LOGO%.png}.svg" "$PUBLIC_DIR/logo.svg"
  cp "${LOGO%.png}.svg" "$PUBLIC_DIR/favicon.svg"
  cp "${LOGO%.png}.svg" "$PUBLIC_DIR/safari-pinned-tab.svg"
fi
```

### Step 4: Sync Logo to src/assets (For Component Imports)

For React/Vue/Angular apps, components often import logo directly from `src/assets/`:

```bash
# If src/assets exists, sync logo files there too
if [ -d "src/assets" ]; then
  cp "$LOGO" "src/assets/logo.png"
  [ -f "${LOGO%.png}.svg" ] && cp "${LOGO%.png}.svg" "src/assets/logo.svg"
fi
```

### Step 5: Find and Update Logo Components

**Critical**: Many projects have dedicated logo components with inline SVG. These MUST be updated.

1. **Search for logo components**:
```bash
# Find *Icon.tsx, *Logo.tsx components
find src/components -name "*Icon.tsx" -o -name "*Logo.tsx" 2>/dev/null
```

2. **For each component found**, check if it contains inline SVG (`<svg>`). If so, refactor to use Image:

**Before** (inline SVG):
```tsx
const AppIcon = ({ className }) => (
  <svg viewBox="..." className={className}>
    <path d="..." />
  </svg>
);
```

**After** (reference external SVG):
```tsx
import Image from 'next/image';

const AppIcon = ({ className = 'h-8 w-8' }) => (
  <Image
    src="/logo.svg"
    alt="App Name"
    width={32}
    height={32}
    className={className}
  />
);
```

3. **Search for other logo references**:
```bash
grep -rn --include="*.tsx" --include="*.ts" --include="*.jsx" --include="*.js" \
  -E "import.*[Ll]ogo|src=.*logo|<svg.*viewBox" src/ 2>/dev/null | grep -v node_modules
```

**Action**: Update ALL found references to use `/logo.svg` or `/logo.png`.

### Step 6: Generate OG Image (Optional)

For social media sharing, generate 1200x630 OG image:

```bash
# OG image: logo centered on brand color background
THEME_COLOR="#D97757"  # 陶土色
magick -size 1200x630 xc:"$THEME_COLOR" \
  \( "$LOGO" -resize 300x300 -gravity center \) \
  -gravity center -composite \
  "$PUBLIC_DIR/og-image.png"
```

### Step 7: Update/Create manifest.json

Check and update `manifest.json` (for PWA support):

```json
{
  "name": "App Name",
  "short_name": "App",
  "icons": [
    { "src": "/icon-192x192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512x512.png", "sizes": "512x512", "type": "image/png" }
  ],
  "theme_color": "#D97757",
  "background_color": "#F9F9F7",
  "display": "standalone"
}
```

### Step 8: Update HTML Head

Check `index.html` or layout files for proper favicon references:

**For Next.js (app/layout.tsx or pages/_document.tsx):**
```tsx
// Next.js 13+ App Router - check app/layout.tsx metadata
export const metadata: Metadata = {
  icons: [
    { rel: 'icon', url: '/favicon.ico' },
    { rel: 'icon', type: 'image/svg+xml', url: '/favicon.svg' },
    { rel: 'icon', type: 'image/png', sizes: '32x32', url: '/favicon-32x32.png' },
    { rel: 'icon', type: 'image/png', sizes: '16x16', url: '/favicon-16x16.png' },
    { rel: 'icon', type: 'image/png', sizes: '192x192', url: '/icon-192x192.png' },
    { rel: 'icon', type: 'image/png', sizes: '512x512', url: '/icon-512x512.png' },
    { rel: 'apple-touch-icon', sizes: '180x180', url: '/apple-touch-icon.png' },
  ],
  openGraph: {
    images: ['/og-image.png'],
  },
}
```

**For Vite/Generic (index.html):**
```html
<link rel="icon" type="image/x-icon" href="/favicon.ico">
<link rel="icon" type="image/svg+xml" href="/favicon.svg">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
<link rel="manifest" href="/manifest.json">
<meta name="theme-color" content="#D97757">
<meta property="og:image" content="/og-image.png">
```

### Step 9: Verify & Summary

Output checklist:
- [ ] favicon.ico (16, 32, 48)
- [ ] favicon.svg
- [ ] favicon-32x32.png
- [ ] favicon-16x16.png
- [ ] apple-touch-icon.png (180x180)
- [ ] icon-192x192.png / android-chrome-192x192.png
- [ ] icon-512x512.png / android-chrome-512x512.png
- [ ] logo.png (original in public/)
- [ ] logo.svg (if SVG source exists)
- [ ] src/assets/logo.* (for component imports)
- [ ] og-image.png (1200x630)
- [ ] manifest.json updated
- [ ] HTML head references updated
- [ ] **Logo components updated** (e.g., AppIcon.tsx, AppLogo.tsx)

## Arguments

- `--source <path>`: Override source logo path
- `--no-og`: Skip OG image generation
- `--no-manifest`: Skip manifest.json update

## Notes

- For Tauri apps, use `/install-tauri-logo` for Dock, tray, and bundle icons
- Theme color defaults to Lovstudio 陶土色 (#D97757)
- **Always check for `*Icon.tsx` and `*Logo.tsx` components** - these often contain inline SVG that needs updating

ARGUMENTS: $ARGUMENTS
