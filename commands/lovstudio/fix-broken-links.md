---
allowed-tools: [Task, Read, Edit, Grep, Glob, Bash(npm:*)]
description: Find and remove broken/placeholder links from codebase
version: "1.0.0"
author: "公众号：手工川"
---
# Fix Broken Links

Scan and clean broken/placeholder links in Header, Footer, and navigation components.

## Process

### 1. Scan for Links
Use Task(Explore) to find all links:
- Internal routes (href="/...")
- External URLs
- Anchor links (#...)
- Placeholder links

### 2. Verify Routes
Check if internal routes have corresponding pages:
- `src/app/[locale]/...` for page routes
- Report which links are broken

### 3. Present Findings
Show user:
- List of broken internal links (no page exists)
- Placeholder external links (example.com, #, etc.)
- File locations

### 4. Clean with Confirmation
For each affected file:
- Read current content
- Remove broken link entries from navigation arrays
- Remove unused imports if applicable
- Run type check to verify

## Target Files
- `src/components/layout/Header.tsx`
- `src/components/layout/Footer.tsx`
- Any navigation/menu components

## Validation
After cleanup:
```bash
npm run check:types
```
