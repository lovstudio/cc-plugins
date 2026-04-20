---
description: Diagnose CLAUDE.md quality — run scoring, validation, and show actionable fixes
permissions:
  allow:
    - Read
    - Glob
    - Bash(python3:*)
---

# CLAUDE.md Doctor

Diagnose the health of your CLAUDE.md file(s).

---

## Step 1: Find CLAUDE.md files

!`find . -name "CLAUDE.md" -type f -not -path "./node_modules/*" -not -path "./.git/*" | head -20`

---

## Step 2: Run diagnosis

For the root CLAUDE.md (or each file found above), run the analyzer and validator from the `claude-md-enhancer` skill.

**Analyzer** (three-dimension quality score):
- Signal-to-Noise (40pts): actionable directives vs boilerplate
- Actionability (40pts): constraint density, executable commands, path references
- Project Alignment (20pts): tech keyword coverage

**Validator** (pass/fail checks):
- File length, structure, formatting, completeness, anti-patterns (secrets, placeholders, broken links)

### Run analysis

```python
import sys, os

# Locate skill
for p in ['skill', os.path.expanduser('~/.claude/skills/claudeforge-skill')]:
    if os.path.isdir(p):
        sys.path.insert(0, p)
        break

from analyzer import CLAUDEMDAnalyzer
from validator import BestPracticesValidator

with open('CLAUDE.md') as f:
    content = f.read()

a = CLAUDEMDAnalyzer(content)
report = a.analyze_file()

v = BestPracticesValidator(content)
validation = v.validate_all()
```

---

## Step 3: Report

Present the results clearly:

1. **Score**: total/100 with per-dimension breakdown (signal-to-noise, actionability, alignment)
2. **Validation**: pass/fail for each check, list errors and warnings
3. **Top recommendations**: from analyzer, ordered by impact
4. **Quick fixes**: concrete actions the user can take right now

If score < 60, suggest running `/enhance-claude-md` to improve.
If secrets detected, flag as urgent.
