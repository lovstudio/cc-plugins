---
allowed-tools: [Bash(git:*), Bash(gh:*), Bash(pnpm:*), Bash(jq:*), Bash(find:*), Bash(ls:*), Bash(cat:*), Bash(awk:*), Bash(wc:*), Read(*), Glob(*), Grep(*), AskUserQuestion]
description: Pre-release audit — verify all sub-projects, skills, gallery, README, version before /release-via-cicd
version: "0.1.0"
author: 公众号：手工川
aliases: /pre-release, /lovstudio-pre-release
---

# Pre-Release Audit

Run BEFORE `/release-via-cicd` to catch missing sub-projects, stale READMEs, gallery uploads, and version mistakes. Outputs a go / no-go checklist.

**Why this exists**: past releases missed `xbti-gallery`, required immediate patch releases, rewrote 1.x tags back to 0.x, and confused stale Vercel deploys for code bugs. This command front-loads those checks.

## Process

### Step 1: Collect baseline

Run in parallel:
- `git tag --sort=-v:refname | head -5` — last 5 tags
- `git log "$(git describe --tags --abbrev=0)..HEAD" --oneline` — commits since last tag
- `git status --porcelain` — uncommitted changes
- `cat package.json | jq -r '.name, .version'` — current name + version
- `git remote get-url origin` — repo identity

If there are zero commits since the last tag, STOP and tell the user there is nothing to release.

### Step 2: Identify sub-projects

Detect all sibling/child projects that typically ship together:
- `git submodule status` — registered submodules
- `find . -maxdepth 3 -name "package.json" -not -path "*/node_modules/*"` — nested packages
- `ls ~/.claude/skills/lovstudio* ~/.claude/plugins/marketplaces/*/lovstudio 2>/dev/null` — related skills/plugins
- For XBTI work: `ls ~/projects/ | grep -Ei '^(xbti|[a-z]bti)'` — sibling personality-test repos
- For gallery-backed projects: check if there's a `*-gallery` sibling repo

For each detected sub-project, report:
- Last tag / version
- Unreleased commits count (`git log <last_tag>..HEAD --oneline | wc -l`)
- Dirty working tree? (yes/no)

### Step 3: Run consistency checks

Parallel checks against the main project:

1. **Version sanity**: current version is `0.x`, NOT `1.x+` (unless user explicitly overrode in a previous session)
2. **README freshness**: if the release touches skills/cases/gallery, grep README for the names of changed items — warn on missing mentions
3. **Changeset presence** (if `.changeset/` exists): `ls .changeset/*.md | wc -l` should be > 0 when there are feature/fix commits
4. **Lockfile in sync**: `git status pnpm-lock.yaml` — must be committed, not dirty
5. **Build sanity**: `pnpm tsc --noEmit 2>&1 | tail -5` — must pass (if the project uses TS)
6. **Gallery registration** (if sibling `*-gallery` repo exists): check that any newly scaffolded items are referenced there

### Step 4: Output the go / no-go checklist

Print a markdown table like:

```
## Pre-Release Audit — <project> v<current> → v<proposed>

| Check                         | Status | Note                          |
|-------------------------------|--------|-------------------------------|
| Commits since last tag        | OK     | 12 commits                    |
| Version stays in 0.x line     | OK     | 0.31.1 → 0.31.2               |
| Lockfile clean                | OK     |                               |
| tsc --noEmit                  | OK     |                               |
| Changeset present             | WARN   | no .changeset/*.md found      |
| README mentions new skill X   | FAIL   | add reference in skills table |
| xbti-gallery has 2 unreleased | WARN   | sibling needs its own release |
| No 1.x tags polluting history | OK     |                               |

Sub-projects detected:
- xbti-gallery (last tag v0.2.0, 2 unreleased commits, clean)
- lovstudio-plugin (last tag v0.30.0, clean, no changes)

GO / NO-GO: ❌ NO-GO
Blockers:
  - README missing skill X reference (Step 3 check #2)

Fix the blockers then re-run /lovstudio/pre-release.
```

### Step 5: Offer to fix

For each `FAIL` or `WARN`:
- If it's a trivial fix (README sync, add changeset stub, bump version suggestion), offer via AskUserQuestion to auto-fix
- If it's structural (sibling repo needs its own release), just report and bail

**Do not** proceed to `/release-via-cicd` automatically — this command is audit-only. The user should re-run `/lovstudio/pre-release` until GO, then invoke `/release-via-cicd` themselves.

## Notes

- This is a read-mostly command. Writes are gated behind explicit user approval in Step 5.
- Keep the output tight — the table is the deliverable, not prose.
- If the user has a `.lovstudio/release-manifest.json` at repo root listing sub-projects explicitly, prefer that over auto-detection.
