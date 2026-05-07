# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"重装机兵 Remake" (Wasteland Hunter Remake) is a Godot 4.x 2D HD pixel-art RPG project. The game emphasizes wasteland mechanical pixel UI with a tank dashboard aesthetic.

## Development Preview Modes

有两种开发预览方式：

### Mode 1: X11 Forwarding (Docker Editor)

通过 Docker 容器运行 Godot 编辑器，X11 转发到远程显示器（如 Windows MobaXterm）。

```bash
# 启动容器内 Godot 编辑器
docker compose up --build
```

配置步骤：
1. 创建 `.env` 文件：`DISPLAY_HOST=<远程IP>`
2. 远程机器开放 X11 防火墙端口 6000
3. 容器连接远程 X Server 显示编辑器界面

`.env` 示例见 `.env.example`。

适用场景：本地无 Godot 安装，远程开发环境。

### Mode 2: Samba Export (Windows Build)

构建 Windows 可执行文件并发布到 Samba 共享，供 Windows 用户直接运行。

```bash
# 构建 Windows 版本
./scripts/build.sh windows debug   # 调试版
./scripts/build.sh windows release # 发布版
```

输出：
- `build/windows/mm-remake.exe` — 本地构建产物
- 自动复制到 Samba 容器 `SMB_CONTAINER:/share/mm-remake/windows/`

依赖环境变量（可在 `.env` 中配置）：
- `SMB_CONTAINER` — Samba 容器名称
- `SMB_OUTPUT_DIR` — 共享目录路径（可选，默认 `/share/mm-remake/windows`）
- `SMB_USER` / `SMB_GROUP` — Samba 用户/组（可选，默认 `smbuser:smb`）

适用场景：团队 Windows 用户测试，无需安装 Godot。

### CI

GitHub Actions runs on push/PR to main/develop. Uses Godot 4.3.0.

## Architecture

### Scene Structure

- Main entry: `res://scenes/main.tscn` → loads `game/demo_main.gd`
- UI scenes: `scenes/ui/` — reusable UI components
- Theme: `themes/wasteland_ui_theme.tres`

### UI System

The UI follows a strict wasteland mechanical pixel style defined in `docs/ui_style_guide.md`. Key points:

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