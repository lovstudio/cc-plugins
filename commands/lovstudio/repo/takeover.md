---
description: "Take over a cloned repo and publish to your own GitHub account"
version: "1.0.0"
author: "公众号：手工川"
aliases: /fork-repo
---

# Repo Takeover

Convert a cloned third-party repo into your own GitHub repository.

## Usage

    /lovstudio/repo-takeover [new-name] [--private]

## Process

1. Verify current state
2. Create new repo on your GitHub
3. Optionally keep original as upstream

## Instructions

```bash
# 1. Check current state
git remote -v
git log --oneline -3

# 2. Create and push to your GitHub
gh repo create <name> --public --source=. --push

# 3. (Optional) Add upstream reference
git remote add upstream <original-url>
```

Arguments: $ARGUMENTS
