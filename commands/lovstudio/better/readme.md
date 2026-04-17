---
allowed-tools: [Read(*), Write(*), Edit(*), Glob(*), Grep(*), Bash(*), Task, TodoWrite, Skill(image-gen, gen-logo), AskUserQuestion]
description: Analyzes project structure and creates/improves README files professionally
version: "2.7.0"
author: 公众号：手工川
aliases: /better-readme, /lovstudio-better-readme
---

# Better README Command

Analyzes project structure, creates/improves README, and generates cover image if missing.

## Process

### Step 1: Check existing README

Check if README.md exists and analyze its current state.

### Step 2: Check for cover image

Detect if README contains a cover image in the first 10 lines:
- Look for patterns: `![...](...)`  at the top
- Common cover image indicators: "cover", "banner", "hero", "header"
- Check if `docs/images/cover.png` already exists (idempotent)

If cover image already exists, skip generation.

### Step 3: Generate cover image (if needed)

Use the image-gen skill with this prompt template:

```
Abstract minimalist cover image for a software project, 2.25:1 aspect ratio.
Style: Warm academic, intellectual, high-end minimalist.
Colors: Warm off-white background (#F9F9F7), deep charcoal accents, terracotta clay (#CC785C) as primary accent.
Elements: Abstract geometric shapes, subtle textures, clean lines, generous whitespace.
Theme: [PROJECT_NAME] - [PROJECT_PURPOSE]
No text, no logos, no icons. Pure abstract composition.
Matte finish, feels like a high-quality print magazine cover.
```

Save to: `docs/images/cover.png` (create directory if needed)

### Step 4: Check for logo

Search for existing logo in common locations:
1. `Glob` for: `logo.svg`, `logo.png`, `assets/logo.*`, `public/logo.*`, `src-tauri/icons/icon.png`
2. If found:
   - Use `AskUserQuestion` to ask user:
     - **Keep existing**: Use current logo
     - **Regenerate**: Generate new logo with `/gen-logo`
   - If user chooses regenerate, proceed to step 3
3. If NOT found (or user chose regenerate): Generate project-specific logo using `/gen-logo` skill:
   ```
   /gen-logo [PROJECT_NAME] -o ./assets/logo
   ```
   This creates `assets/logo.png` and `assets/logo.svg` with Lovstudio brand style.

**Logo selection priority:**
1. `assets/logo.svg` (preferred)
2. `public/logo.svg`
3. `logo.svg` (root)
4. `assets/logo.png`
5. `public/logo.png`
6. `src-tauri/icons/icon.png` (Tauri apps)

Use the first existing logo found, or generate new if none exist or user requests regeneration.

### Step 5: Check LICENSE file

Check if LICENSE file exists in project root:
1. `Glob` for `LICENSE*` files
2. If exists: Read and identify license type for README
3. If NOT exists:
   - Create `LICENSE` file with Apache-2.0 full text
   - Use template from: https://www.apache.org/licenses/LICENSE-2.0.txt
   - Or copy from `~/.claude/templates/LICENSE-Apache-2.0` if available

This ensures every project has a proper license file (Apache-2.0 by default).

### Step 6: Analyze project structure

Examine the project to understand:
- Project type and purpose
- Technology stack
- Key features
- Target audience

### Step 7: Generate/Update README

Create professional README with this header structure:

```html
<p align="center">
  <img src="docs/images/cover.png" alt="[PROJECT] Cover" width="100%">
</p>

<h1 align="center">
  <img src="assets/logo.svg" width="32" height="32" alt="Logo" align="top">
  [PROJECT_NAME]
</h1>

<p align="center">
  <strong>[ONE_LINE_DESCRIPTION]</strong><br>
  <sub>[PLATFORMS]</sub>
</p>
```

**Layout notes:**
- Cover image: Full width at the top
- Logo + Title: Same line using `align="top"` for vertical alignment
- Logo size: 32x32 works well with h1 text

**GitHub Markdown limitations:**
- `style="..."` attributes are stripped - use HTML attributes instead
- `align="top"` works for image vertical alignment
- Custom text colors are NOT supported - don't attempt

Content sections:
- Navigation links
- Features list
- Screenshots (if available)
- Installation instructions
- Usage examples
- Keyboard shortcuts (if applicable)
- Tech stack
- Star History (see Step 7b)
- License (default to Apache-2.0 if not specified in project)

Content principles:
- **Professional**: Industry-standard formatting
- **Concise**: High readability, scannable sections
- **User-focused**: Immediately communicates purpose

### Step 7b: Add Star History Section

Add a Star History section before License using star-history.com:

```markdown
## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=[OWNER]/[REPO]&type=Date)](https://star-history.com/#[OWNER]/[REPO]&Date)
```

**How to get OWNER/REPO:**
1. Run `git remote get-url origin`
2. Extract from URL patterns:
   - `git@github.com:owner/repo.git` → `owner/repo`
   - `https://github.com/owner/repo.git` → `owner/repo`
   - `https://github.com/owner/repo` → `owner/repo`

**Placement:** Between Tech Stack and License sections.

### Step 8: Validate image links

Scan README for all image references (`![...](...)`):
1. Extract all image paths
2. Check if each file exists using `Glob`
3. For broken links, use `AskUserQuestion` to ask user:
   - **Delete**: Remove the image reference
   - **Replace**: User provides correct path
   - **Placeholder**: Use placeholder service (optional)

This ensures no broken images in final README.

### Step 9: Git Commit

Stage and commit changes:
- `git add README.md docs/images/cover.png assets/logo.svg LICENSE` (include newly added files)
- Squash multiple iterations into single commit
- Commit message: "docs: improve README with cover and branding" or "docs: update README"

---

Execute analysis, cover generation (if needed), README optimization, and git commit now.

ARGUMENTS: $ARGUMENTS
