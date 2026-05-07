# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"重装机兵 Remake" (Wasteland Hunter Remake) is a Godot 4.x 2D HD pixel-art RPG project. The game emphasizes wasteland mechanical pixel UI with a tank dashboard aesthetic.

## Development Workflow

开发新功能的标准流程：

1. **新建 Issue** — 在 GitHub 上创建 issue 描述功能需求
2. **创建开发分支** — 从 `develop` 分支创建 `feature/<issue-number>-<description>` 分支
3. **开发与测试** — 使用本地 Godot 编辑器开发和测试
4. **提交 PR** — 开发完成后创建 PR 合并到 `develop` 分支

```bash
# 示例流程
gh issue create --title "添加背包系统" --body "..."
git checkout develop && git pull
git checkout -b feature/42-inventory-system
# ... 开发 ...
gh pr create --base develop
```

## Development Preview Modes

### Mode 1: 本地 Godot（推荐）

系统已安装 Godot 4.6.2，直接启动：

```bash
godot --path .
```

适用场景：本地有 Godot 安装，日常开发。

### Mode 2: X11 Forwarding (Docker Editor)

通过 Docker 容器运行 Godot 编辑器，X11 转发到远程显示器。

**首次运行前必须复制 `.env.example` 为 `.env`**：

```bash
cp .env.example .env
# 编辑 .env 设置 DISPLAY_HOST=<远程IP>
docker compose up --build
```

适用场景：本地无 Godot 安装，远程开发环境。

### Mode 3: Samba Export (Windows Build)

构建 Windows 可执行文件并发布到 Samba 共享：

```bash
./scripts/build.sh windows debug   # 调试版
./scripts/build.sh windows release # 发布版
```

输出：`build/windows/mm-remake.exe`

适用场景：团队 Windows 用户测试。

### CI

GitHub Actions runs on push/PR to main/develop. Uses Godot 4.6.2.

## Architecture

### Scene Structure

- Main entry: `res://scenes/main.tscn` → loads `game/demo_main.gd`
- UI scenes: `scenes/ui/` — reusable UI components
- Theme: `themes/wasteland_ui_theme.tres`

### UI System

The UI follows a strict wasteland mechanical pixel style defined in `docs/ui-design/ui-style-guide.md`. Key points:

- **Palette**: Dark iron/rust colors (`BG_DARK=#050403`, `PANEL_BG=#11110f`, `BORDER=#5b3f22`, `TEXT=#b9a982`)
- **No bright/candy colors**: Forbidden are toy-like UI, rounded controls, high-saturation colors
- **HUD**: Uses `CanvasLayer`, compact resource strips, grounded bottom status cards
- **Buttons**: Tank console switch style — dark metal, small edge highlight on hover, military green for selected

### UIStyleGuide Class

`game/ui_style_guide.gd` is the central style provider:
- Constants for colors, font sizes, dimensions
- Static methods: `panel_style()`, `compact_panel_style()`, `button_style()`
- UI components import and use these: `const UIStyleGuide := preload("res://game/ui_style_guide.gd")`

### Custom UI Components

Located in `scripts/ui/`:
- `wasteland_button.gd` — extends Button with wasteland styling
- `wasteland_progress_bar.gd` — mechanical slot progress bars
- `battle_command_button.gd` — battle UI buttons
- `dialog_box.gd` — radio/terminal style dialog
- `pixel_metal_panel.gd` — metal panel with rivets/scratches
- `inventory_slot.gd` — military crate cell slots

## Code Style

GDScript:
- 4-space indent
- `snake_case.gd` filenames
- `PascalCase` class names
- Use type hints: `func _ready() -> void:`
- Prefer `const` for colors and sizes

Commit format: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`)

Branch strategy: `main` (stable), `develop` (integration), `feature/*`, `fix/*`

## Project Configuration

- Viewport: 1280×720
- Stretch mode: `canvas_items`, aspect `expand`
- Texture filter: nearest-neighbor (`default_texture_filter=0`)
- Renderer: `forward_plus`

## Export

Currently configured for Windows Desktop (`export_presets.cfg`). Product name: "荒原战车 REMAKE". Build output: `build/windows/mm-remake.exe`.