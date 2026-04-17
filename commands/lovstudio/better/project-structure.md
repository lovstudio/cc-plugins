---
allowed-tools: ["Bash", "Read", "Write", "Edit", "MultiEdit", "Glob", "Grep", "TodoWrite", "Task"]
description: 语言无关的智能项目结构优化器，自适应各种项目类型
version: "2.0.0"
author: "公众号：手工川"
aliases: /better-project-structure
---

# Better Project Structure 🏗️

**通用的项目结构智能优化器** - 自动检测项目类型，提供定制化的结构改进方案。

## 核心理念

不强制任何特定结构，而是：
1. **理解**你的项目（语言、框架、规模）
2. **学习**你的习惯（现有组织方式）
3. **建议**改进方案（基于最佳实践）
4. **执行**你选择的操作（安全可控）

## 智能检测系统

### 🔍 自动识别

#### 语言检测
```yaml
通过文件扩展名和特征文件：
- Python: .py, requirements.txt, setup.py, pyproject.toml
- JavaScript/Node: .js, .ts, package.json, node_modules/
- Java: .java, pom.xml, build.gradle, .classpath
- Go: .go, go.mod, go.sum
- Rust: .rs, Cargo.toml, Cargo.lock
- Ruby: .rb, Gemfile, Rakefile
- PHP: .php, composer.json, composer.lock
- C/C++: .c, .cpp, .h, CMakeLists.txt, Makefile
- C#/.NET: .cs, .csproj, .sln, nuget.config
- Swift: .swift, Package.swift, .xcodeproj
- Kotlin: .kt, build.gradle.kts
- Dart/Flutter: .dart, pubspec.yaml
- Elixir: .ex, mix.exs
- Scala: .scala, build.sbt
- R: .R, .Rmd, DESCRIPTION
- Julia: .jl, Project.toml
```

#### 框架检测
```yaml
通过特征文件和目录：
# Web框架
- Django: manage.py, settings.py, wsgi.py
- Flask: app.py, wsgi.py, templates/
- FastAPI: main.py, routers/
- Rails: Gemfile, config.ru, app/controllers/
- Express: app.js, routes/, views/
- Spring: @SpringBootApplication, application.properties
- Laravel: artisan, composer.json(laravel/framework)
- Next.js: next.config.js, pages/
- Nuxt: nuxt.config.js
- Angular: angular.json, src/app/
- React: package.json(react), src/App.js
- Vue: vue.config.js, src/components/

# 其他框架
- Electron: electron.js, main.js(electron)
- React Native: metro.config.js, ios/, android/
- Flutter: lib/main.dart, android/, ios/
- Unity: Assets/, ProjectSettings/
- Godot: project.godot, .import/
```

#### 项目类型推断
```yaml
基于文件和结构特征：
- CLI工具: 单文件或简单结构，有main入口
- 库/包: setup.py, package.json(main), lib/目录
- Web应用: 路由、视图、模板、静态文件
- API服务: 路由、控制器、无前端文件
- 全栈应用: 前后端分离或混合
- 微服务: 多个独立服务目录，docker-compose
- Monorepo: packages/, lerna.json, nx.json
- 数据科学: .ipynb, data/, models/, notebooks/
- 文档项目: 主要是.md/.rst，mkdocs.yml, conf.py
- DevOps: terraform/, ansible/, k8s/, .gitlab-ci.yml
- 游戏: Assets/, Scripts/, Scenes/
- 移动应用: iOS/Android特定文件
- 桌面应用: Electron/Qt/GTK特征
```

### 📊 结构分析

#### 问题识别器
```python
class IssueDetector:
    def detect_issues(self):
        issues = []

        # 1. 根目录混乱
        if count_root_files() > threshold_for_project_type():
            issues.append("根目录文件过多")

        # 2. 混合关注点
        if has_mixed_source_and_tests():
            issues.append("源码和测试混合")

        # 3. 缺少标准目录
        if missing_expected_directories():
            issues.append("缺少常见目录结构")

        # 4. 命名不一致
        if has_inconsistent_naming():
            issues.append("命名风格不统一")

        # 5. 深度嵌套
        if max_depth() > reasonable_depth():
            issues.append("目录嵌套过深")

        # 6. 重复结构
        if has_duplicate_structures():
            issues.append("存在重复的目录结构")

        return issues
```

## 自适应规则系统

### 📋 预设配置（可覆盖）

```yaml
# .projectstructure.yaml - 用户可自定义
version: 2.0
detect_mode: auto  # auto | manual | config

# 通用规则（语言无关）
universal:
  # 总是清理的垃圾文件
  always_clean:
    - "**/.DS_Store"
    - "**/Thumbs.db"
    - "**/*~"
    - "**/*.swp"
    - "**/.*.swp"

  # 构建产物（检查.gitignore后清理）
  build_artifacts:
    - "**/build/"
    - "**/dist/"
    - "**/out/"
    - "**/target/"
    - "**/*.egg-info/"

  # 缓存目录
  cache_dirs:
    - "**/__pycache__/"
    - "**/.cache/"
    - "**/.pytest_cache/"
    - "**/node_modules/"  # 仅当在.gitignore中时

# 语言特定规则（自动应用）
languages:
  python:
    source_patterns: ["*.py"]
    source_dirs: ["src/", "lib/", "{name}/", "app/"]
    test_patterns: ["test_*.py", "*_test.py"]
    test_dirs: ["tests/", "test/"]

  javascript:
    source_patterns: ["*.js", "*.jsx", "*.ts", "*.tsx"]
    source_dirs: ["src/", "lib/", "app/"]
    test_patterns: ["*.test.js", "*.spec.js"]
    test_dirs: ["__tests__/", "test/", "spec/"]

  java:
    source_patterns: ["*.java"]
    source_dirs: ["src/main/java/"]
    test_dirs: ["src/test/java/"]
    resource_dirs: ["src/main/resources/"]

# 自定义映射规则
custom_rules:
  - pattern: "old_*"
    action: "move"
    target: "legacy/"

  - pattern: "*.backup"
    action: "remove"
    confirm: true
```

### 🎯 智能建议生成

```python
class StructureSuggester:
    def generate_suggestions(self, project_info):
        suggestions = []

        # 基于项目类型生成建议
        if project_info.is_monorepo:
            suggestions.extend(self.monorepo_suggestions())
        elif project_info.is_microservice:
            suggestions.extend(self.microservice_suggestions())
        elif project_info.is_library:
            suggestions.extend(self.library_suggestions())
        else:
            suggestions.extend(self.app_suggestions())

        # 基于语言添加建议
        for lang in project_info.languages:
            suggestions.extend(self.language_suggestions(lang))

        # 基于发现的问题添加建议
        for issue in project_info.issues:
            suggestions.extend(self.issue_suggestions(issue))

        return self.prioritize_suggestions(suggestions)
```

## 交互式执行

### 🎨 智能交互界面

```
🔍 项目智能分析
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 检测结果：
├─ 语言: TypeScript (45%), Python (30%), Shell (15%), YAML (10%)
├─ 框架: Next.js (前端), FastAPI (后端)
├─ 类型: 全栈Web应用
├─ 规模: 中型 (287个文件, 15个目录)
└─ 状态: 需要优化

🔴 发现的问题：
1. 根目录有23个配置文件（建议: <10）
2. 前后端代码混合在同一层级
3. 测试文件分散在源码中
4. 存在 node_modules/ 在版本控制中
5. 有6个 "old_" 前缀的文件

💡 推荐方案 A - 前后端分离：
frontend/               # Next.js应用
├── src/
├── public/
├── tests/
└── package.json

backend/                # FastAPI应用
├── app/
├── tests/
└── requirements.txt

shared/                 # 共享资源
├── docs/
├── scripts/
└── docker/

💡 推荐方案 B - 统一结构：
src/
├── frontend/          # Next.js
├── backend/           # FastAPI
└── shared/           # 共享代码

tests/
├── frontend/
├── backend/
└── integration/

⚙️ 选择操作：
[1] 采用方案A
[2] 采用方案B
[3] 自定义调整
[4] 仅清理垃圾文件
[5] 生成配置文件
[6] 查看详细分析
[0] 退出

请选择 (1-6, 0): _
```

### 🛡️ 安全执行

```python
class SafeExecutor:
    def execute(self, operations):
        # 1. 验证阶段
        self.validate_operations(operations)

        # 2. 备份关键文件
        backup_path = self.create_backup()

        # 3. 生成回滚脚本
        rollback_script = self.generate_rollback()

        # 4. 逐步执行
        for op in operations:
            try:
                self.execute_operation(op)
                self.log_success(op)
            except Exception as e:
                self.log_error(op, e)
                if self.should_rollback(e):
                    self.rollback(backup_path)
                    break

        # 5. 验证结果
        self.verify_result()
```

## 高级功能

### 🔧 配置生成器

自动生成项目配置：
- `.projectstructure.yaml` - 项目结构配置
- `.gitignore` - 智能Git忽略规则
- `.editorconfig` - 编辑器配置
- `README_STRUCTURE.md` - 目录结构文档

### 📈 增量优化

```python
class IncrementalOptimizer:
    def optimize(self):
        # 不是一次性重构，而是逐步改进

        # 第1阶段：清理垃圾
        self.cleanup_phase()

        # 第2阶段：整理文档
        self.organize_docs()

        # 第3阶段：分离测试
        self.separate_tests()

        # 第4阶段：模块化重构
        self.modularize()

        # 每个阶段都可以独立执行
```

### 🤖 学习模式

```python
class LearningMode:
    def learn_from_project(self):
        # 学习当前项目的组织模式
        patterns = self.extract_patterns()

        # 保存到用户配置
        self.save_user_preferences(patterns)

        # 未来项目会使用这些偏好
        return patterns
```

### 🌍 社区最佳实践

```python
class BestPractices:
    def fetch_community_standards(self, project_type):
        # 从流行的开源项目学习
        # 基于GitHub星标最多的同类项目

        examples = {
            "python-web": ["django/django", "pallets/flask"],
            "javascript-frontend": ["facebook/react", "vuejs/vue"],
            "go-cli": ["spf13/cobra", "urfave/cli"],
            # ...
        }

        return self.analyze_structures(examples[project_type])
```

## 输出示例

### 最小化模式
```bash
$ /lovstudio/better-project-structure --minimal
✨ 快速清理完成：删除了15个垃圾文件
```

### 标准模式
```bash
$ /lovstudio/better-project-structure
🔍 检测到 Python/FastAPI 项目
📊 分析完成：85分（良好）
💡 3个建议：
  1. 分离测试文件 → tests/
  2. 整理配置文件 → config/
  3. 归档旧代码 → legacy/
执行建议？[y/n/select]: _
```

### 详细模式
```bash
$ /lovstudio/better-project-structure --verbose
[完整的交互式界面，包含所有选项和详细信息]
```

## 真正的泛化

这个2.0版本实现了真正的泛化：

1. **语言无关** - 支持所有主流语言
2. **框架感知** - 识别并适应各种框架
3. **类型自适应** - 不同项目类型不同策略
4. **用户主导** - 建议而非强制
5. **可配置** - 完全可自定义规则
6. **增量改进** - 逐步优化而非一次重构
7. **学习能力** - 记住用户偏好
8. **社区驱动** - 基于最佳实践

ARGUMENTS: $ARGUMENTS
