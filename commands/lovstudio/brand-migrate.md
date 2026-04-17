---
allowed-tools: [Bash, Read, Edit, Glob, Grep]
description: "[DEPRECATED] Use /rename-project instead"
version: "2.0.0"
author: "公众号：手工川"
---

# Brand Migration Command (DEPRECATED)

> **已废弃**: 请使用 `/lovstudio:rename-project <new-name>` 代替，更智能更自动。

---

以下为旧版逻辑，仅供参考：

Safely migrate project brand/name (e.g., neurora → lovstudio) with interactive confirmation for each category of changes.

## Arguments Format
`<new_name> [--dry-run]`

## Process

### Step 1: Auto-Detect Current Brand

Detect current brand name from (priority order):
1. `package.json` → `name` field
2. Root directory name
3. `README.md` title
4. Most frequent brand-like identifier in codebase

If multiple candidates found:
```
AskUserQuestion:
  question: "Detected multiple brand names. Which is the current brand?"
  options: [detected candidates...]
```

Parse new_name from arguments, validate both names differ.

### Step 2: Scan & Categorize

Search for all occurrences using multiple patterns:
- Exact match: `old_name`
- CamelCase: `OldName`
- snake_case: `old_name`
- UPPER_CASE: `OLD_NAME`
- kebab-case: `old-name`

Categorize findings:

1. **Code References** (*.ts, *.tsx, *.js, *.jsx, *.py, etc.)
2. **Config Files** (package.json, *.config.*, .env*, etc.)
3. **Documentation** (*.md, *.txt)
4. **Database** (migrations, seeds, schema files)
5. **Meta/Branding** (manifest.json, index.html, assets/)
6. **Git/CI** (.github/, .gitlab-ci.yml)
7. **Directory Names** (folders containing old name)
8. **File Names** (files containing old name)

### Step 3: Interactive Confirmation

For EACH category with findings:

```
AskUserQuestion:
  question: "Found X occurrences in [Category]. Migrate these?"
  options:
    - "Yes, migrate all"
    - "Show me the files first"
    - "Skip this category"
    - "Abort migration"
```

If "Show me the files first":
- Display file list with context
- Re-ask for confirmation

### Step 4: Execute Migration

For each confirmed category:

1. **Text replacements** (preserving case variants):
   - `old_name` → `new_name`
   - `OldName` → `NewName`
   - `OLD_NAME` → `NEW_NAME`
   - `old-name` → `new-name`

2. **File renames** (if confirmed):
   ```bash
   git mv old-name-file.ts new-name-file.ts
   ```

3. **Directory renames** (if confirmed):
   ```bash
   git mv old-name-dir/ new-name-dir/
   ```

### Step 5: Database Handling

If database files detected:

```
AskUserQuestion:
  question: "Database references found. How to handle?"
  options:
    - "Generate migration script (recommended)"
    - "Skip database changes"
    - "Show affected tables/columns"
```

Generate migration script if requested:
```sql
-- Brand Migration: old_name → new_name
-- Generated: YYYY-MM-DD
-- Review carefully before executing!

-- Example:
ALTER TABLE brands RENAME old_name TO new_name;
UPDATE settings SET brand = 'new_name' WHERE brand = 'old_name';
```

### Step 6: Post-Migration Checklist

Display checklist:

```markdown
## Migration Complete

### Automated Changes:
- [x] Code references updated (X files)
- [x] Config files updated (X files)
- [x] Files renamed (X files)
- [x] Directories renamed (X dirs)

### Manual Review Required:
- [ ] Database migration script: ./migrations/brand-migrate-YYYYMMDD.sql
- [ ] Update external services (DNS, OAuth, API keys)
- [ ] Update README badges/links
- [ ] Verify build passes
- [ ] Test core functionality

### Git Status:
[Show git status summary]
```

### Step 7: Offer Commit

```
AskUserQuestion:
  question: "Create a commit for these changes?"
  options:
    - "Yes, commit now"
    - "No, I'll review first"
```

If yes:
```bash
git add -A
git commit -m "chore: migrate brand from old_name to new_name"
```

## Safety Features

1. **Dry Run Mode**: Use `--dry-run` to preview changes without executing
2. **Git Safety**: Only proceed if working directory is clean or user confirms
3. **Backup Suggestion**: Recommend `git stash` or branch before migration
4. **Exclude Patterns**: Skip node_modules, .git, dist, build, vendor
5. **Binary Files**: Skip binary files, only process text files

## Example Usage

```bash
# Preview changes (auto-detects current brand)
/brand-migrate lovstudio --dry-run

# Execute migration
/brand-migrate lovstudio
```

## Error Handling

- If git not clean: warn and ask to proceed or abort
- If no occurrences found: inform user, exit gracefully
- If rename conflicts: report and skip conflicting items
- If permission errors: report and continue with accessible files
