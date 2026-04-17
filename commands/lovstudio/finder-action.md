---
allowed-tools: Bash(*), Write(*), Read(*), Edit(*)
description: 生成 Mac Finder 右键 Quick Action（Automator workflow）
version: "1.0.0"
author: "公众号：手工川"
---

# Mac Finder Quick Action 生成器

根据用户描述，生成一个 Mac Finder 右键菜单 Quick Action。

## 参数格式
`<动作名称> <触发文件类型> <shell命令描述>`

示例：
- `pdf2png .pdf 将PDF所有页面纵向拼接成一张PNG`
- `md2pdf .md 用pandoc将Markdown转成PDF`
- `compress .jpg 用ffmpeg压缩图片`

## 执行流程

### Step 1: 分析需求

收集以下信息（参数未提供时用 AskUserQuestion 询问）：
- **动作名称**：显示在右键菜单中的名称
- **触发文件类型**：扩展名，如 `.pdf`、`.md`、`.jpg`
- **核心命令**：用什么工具做什么转换

### Step 2: 检查依赖工具

```bash
which <所需工具>
```

如果工具不存在，提示用户安装：`brew install <tool>`

### Step 3: 生成 shell 脚本

在当前项目目录创建 `<action-name>.sh`：

```bash
#!/bin/bash
for f in "$@"; do
  [[ "$f" == *.<ext> ]] || continue
  output="${f%.<ext>}.<out_ext>"
  <具体命令> "$f" -o "$output"
done
```

注意：
- 工具路径使用绝对路径（`which <tool>` 获取）
- 使用 `"$@"` 接收文件参数（inputMethod=1）

### Step 4: 创建 Automator workflow

创建 `~/Library/Services/<动作名称>.workflow/Contents/document.wflow`。

**关键配置**：
- `inputMethod`: `1`（以 `"$@"` 传参，不用 stdin）
- `serviceInputTypeIdentifier`: `com.apple.Automator.fileSystemObject`
- `workflowTypeIdentifier`: `com.apple.Automator.servicesMenu`

使用以下 plist 模板（替换 `ACTION_NAME`、`SHELL_SCRIPT`）：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>531</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.automator.fileSystemObject</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>2.0.3</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMParameterProperties</key>
				<dict>
					<key>COMMAND_STRING</key><dict/>
					<key>CheckedForUserDefaultShell</key><dict/>
					<key>inputMethod</key><dict/>
					<key>shell</key><dict/>
					<key>source</key><dict/>
				</dict>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key>
				<string>Run Shell Script</string>
				<key>ActionParameters</key>
				<dict>
					<key>COMMAND_STRING</key>
					<string>SHELL_SCRIPT</string>
					<key>CheckedForUserDefaultShell</key>
					<true/>
					<key>inputMethod</key>
					<integer>1</integer>
					<key>shell</key>
					<string>/bin/bash</string>
					<key>source</key>
					<string></string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>CFBundleVersion</key>
				<string>2.0.3</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunShellScriptAction</string>
				<key>InputUUID</key>
				<string>A1111111-1111-1111-1111-111111111111</string>
				<key>Keywords</key>
				<array>
					<string>Shell</string>
				</array>
				<key>OutputUUID</key>
				<string>B2222222-2222-2222-2222-222222222222</string>
				<key>UUID</key>
				<string>C3333333-3333-3333-3333-333333333333</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
				<key>arguments</key>
				<dict>
					<key>0</key>
					<dict>
						<key>default value</key>
						<integer>1</integer>
						<key>name</key>
						<string>inputMethod</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>0</string>
					</dict>
					<key>1</key>
					<dict>
						<key>default value</key>
						<false/>
						<key>name</key>
						<string>CheckedForUserDefaultShell</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>1</string>
					</dict>
					<key>2</key>
					<dict>
						<key>default value</key>
						<string></string>
						<key>name</key>
						<string>COMMAND_STRING</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>2</string>
					</dict>
					<key>3</key>
					<dict>
						<key>default value</key>
						<string>/bin/sh</string>
						<key>name</key>
						<string>shell</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>3</string>
					</dict>
				</dict>
				<key>isViewVisible</key>
				<true/>
				<key>location</key>
				<string>309.000000:305.000000</string>
				<key>nibPath</key>
				<string>/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib</string>
			</dict>
			<key>isViewVisible</key>
			<true/>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>applicationBundleIDsByPath</key>
		<dict/>
		<key>applicationPaths</key>
		<array/>
		<key>inputTypeIdentifier</key>
		<string>com.apple.Automator.fileSystemObject</string>
		<key>outputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>presentationMode</key>
		<integer>15</integer>
		<key>processesInput</key>
		<false/>
		<key>serviceInputTypeIdentifier</key>
		<string>com.apple.Automator.fileSystemObject</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceProcessesInput</key>
		<false/>
		<key>systemImageName</key>
		<string>NSActionTemplate</string>
		<key>useAutomaticInputType</key>
		<false/>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
```

### Step 5: 验证并注册

```bash
# 验证 plist 格式
plutil -lint ~/Library/Services/<动作名称>.workflow/Contents/document.wflow

# 重载服务
/System/Library/CoreServices/pbs -update
killall Finder
```

### Step 6: 用 Automator 打开保存（关键步骤）

```bash
open -a Automator ~/Library/Services/<动作名称>.workflow
```

**必须**在 Automator 里按 Cmd+S 保存一次，macOS 才会正式注册该 Quick Action。

## 已知问题 & 经验

- `inputMethod=1` → 文件以 `"$@"` 传入（正确）；`inputMethod=0` → stdin（可能无效）
- 工具路径必须用绝对路径，Quick Action 环境没有 `$PATH`
- Automator 保存后会重写部分 plist 字段（正常现象，不影响功能）
- `.md` 文件在某些系统上不触发右键菜单，需在 Automator 中确认 input type 为 "文件或文件夹"
