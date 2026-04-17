---
description: 检查点列表：展示项目所有检查点历史记录
allowed-tools: Bash(git log:*), Read, Glob
aliases: "/checkpoint-list"---

# Checkpoint List - 检查点历史列表

## 数据源检查

### 检查点日志文件
- 日志文件: !`test -f .checkpoint_log && echo "✅ 发现检查点日志" || echo "❌ 无检查点日志"`
- 记录数量: !`test -f .checkpoint_log && grep -c "timestamp" .checkpoint_log || echo "0"`
- 最新记录: !`test -f .checkpoint_log && tail -1 .checkpoint_log || echo "无记录"`

### CLAUDE.md 检查点记录
- 文件存在: !`test -f CLAUDE.md && echo "✅ 发现 CLAUDE.md" || echo "❌ 无 CLAUDE.md"`
- 检查点数量: !`test -f CLAUDE.md && grep -c "## Checkpoint 记录" CLAUDE.md || echo "0"`
- 最近记录: !`test -f CLAUDE.md && grep -A 3 "## Checkpoint 记录" CLAUDE.md | tail -4 || echo "无记录"`

### Git 检查点提交
- 提交数量: !`git log --grep="checkpoint.*Generated with.*Claude Code" --oneline | wc -l | tr -d ' '`
- 最新提交: !`git log --grep="checkpoint.*Generated with.*Claude Code" --oneline -1 || echo "无检查点提交"`
- 时间范围: !`FIRST=$(git log --grep="checkpoint.*Generated with.*Claude Code" --reverse --format="%cd" --date=short -1); LAST=$(git log --grep="checkpoint.*Generated with.*Claude Code" --format="%cd" --date=short -1); if [ -n "$FIRST" ]; then echo "$FIRST 至 $LAST"; else echo "无时间范围"; fi`

## 检查点历史列表

### 完整检查点记录

#### 从 Git 提交历史提取
!`git log --grep="checkpoint.*Generated with.*Claude Code" --format="📅 %cd | %h | %s" --date=short --reverse`

#### 从检查点日志提取（如果存在）
!`if [ -f .checkpoint_log ]; then echo "=== JSON 日志记录 ==="; cat .checkpoint_log | jq -r '. | "📅 \(.timestamp) | 🎯 \(.checkpoint_status.milestone // "未知") | 💚 \(.checkpoint_status.health_score // 0)/10 | 📈 \(.period_analysis.development_phase // "未知")"' 2>/dev/null || cat .checkpoint_log; else echo "无 JSON 日志"; fi`

#### 从 CLAUDE.md 提取摘要
!`if [ -f CLAUDE.md ]; then echo "=== CLAUDE.md 记录摘要 ==="; grep -B 1 -A 10 "## Checkpoint 记录" CLAUDE.md | grep -E "(项目:|时间:|里程碑:|Git提交:)" || echo "无结构化记录"; else echo "无 CLAUDE.md"; fi`

## 检查点统计

### 活动统计
- 总检查点数: !`git log --grep="checkpoint.*Generated with.*Claude Code" --oneline | wc -l | tr -d ' '`
- 平均间隔: !`COMMITS=$(git log --grep="checkpoint.*Generated with.*Claude Code" --format="%ct" | sort -n); if [ $(echo "$COMMITS" | wc -l) -gt 1 ]; then FIRST=$(echo "$COMMITS" | head -1); LAST=$(echo "$COMMITS" | tail -1); DAYS=$(((LAST-FIRST)/86400)); COUNT=$(echo "$COMMITS" | wc -l); echo "约 $((DAYS/(COUNT-1))) 天"; else echo "仅一个检查点"; fi`
- 最新活动: !`git log --grep="checkpoint.*Generated with.*Claude Code" --format="%cr" -1 || echo "无记录"`

### 项目演进概览
- 首次检查点: !`git log --grep="checkpoint.*Generated with.*Claude Code" --reverse --format="%cd (%cr)" --date=short -1 || echo "无记录"`
- 发展阶段: !`if [ -f .checkpoint_log ]; then jq -r '.period_analysis.development_phase // "未知"' .checkpoint_log 2>/dev/null | tail -1 || echo "无数据"; else echo "无日志文件"; fi`
- 健康度趋势: !`if [ -f .checkpoint_log ]; then echo "最新健康度:"; jq -r '.checkpoint_status.health_score // 0' .checkpoint_log 2>/dev/null | tail -1 || echo "无数据"; else echo "无日志文件"; fi`

## 详细视图选项

### 简洁模式（默认）
显示检查点的时间、提交哈希和简要描述

### 详细模式  
如需详细信息，可以：
1. 查看完整的 .checkpoint_log 文件: `cat .checkpoint_log | jq .`
2. 查看 CLAUDE.md 完整记录: `grep -A 20 "## Checkpoint 记录" CLAUDE.md`
3. 查看特定提交详情: `git show [提交哈希]`

### 过滤选项
- **按时间**: `git log --grep="checkpoint" --since="2024-01-01" --format="%cd | %s" --date=short`
- **按分支**: `git log --grep="checkpoint" [分支名] --oneline`
- **最近N个**: `git log --grep="checkpoint" -n 5 --oneline`

## 预期输出

    📋 检查点历史概览
    
    💾 数据源状态:
       ✅ 检查点日志: [数量]条记录
       ✅ CLAUDE.md: [数量]个检查点
       ✅ Git提交: [数量]次检查点提交
    
    ⏱️  时间范围: [首次] 至 [最新]
    📊 平均间隔: [天数]天
    📈 最新健康度: [评分]/10
    
    📅 检查点列表:
    [按时间顺序的检查点记录]
    
    💡 提示: 使用 `git show [哈希]` 查看详细信息

基于当前项目的检查点记录，生成完整的历史列表...