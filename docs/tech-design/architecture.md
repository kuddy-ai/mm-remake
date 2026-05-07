# Architecture Notes

## 启动链路

```
project.godot → scenes/main.tscn → game/demo_main.gd
```

- `project.godot` 配置主场景为 `scenes/main.tscn`
- `main.tscn` 根节点挂载 `game/demo_main.gd`，负责状态切换和 UI 构建
- 当前 demo_main.gd 为单文件原型（约 1200 行），后续需拆分到：
  - `game/states/` — 各状态逻辑（菜单、城镇、路线、战斗、车库、结算）
  - `game/systems/` — 战斗系统、资源系统、升级系统
  - `game/data/` — 路线数据、敌人数据、升级配置
  - `game/ui/` — UI 构建与样式

## 目录职责

| 目录 | 用途 | Git 提交 |
|------|------|----------|
| `assets/` | 运行时资源（精灵、音频、UI 纹理、tileset、背景、特效） | ✓ 提交 |
| `docs/` | 设计文档、开发规范、压缩后的参考图 | ✓ 提交 |
| `external-assets/` | 原始大文件、源文件、母带、AI原图 | ✗ 不提交（仅 README.md 提交） |
| `game/` | 游戏逻辑脚本 | ✓ 提交 |
| `scenes/` | 场景组合（.tscn） | ✓ 提交 |
| `scripts/` | 自动化脚本（构建、运行） | ✓ 提交 |
| `themes/` | Godot 主题资源 | ✓ 提交 |

## UI 系统

废土机械像素风格 UI 由以下部分组成：

- **设计规范**：`docs/ui-design/ui-style-guide.md` — 色板、排版、交互规则
- **样式提供**：`game/ui_style_guide.gd` — 颜色常量、字体尺寸、面板样式方法
- **主题文件**：`themes/wasteland_ui_theme.tres` — Godot Theme 资源
- **UI 场景**：`scenes/ui/` — 可复用 UI 组件（WastelandButton、PixelMetalPanel 等）
- **UI 脚本**：`scripts/ui/` — 组件扩展脚本

## 当前构建与导出

- 构建脚本：`scripts/build.sh`（仅支持 Windows Desktop）
- 导出预设：`export_presets.cfg`（Windows Desktop preset，产品名 "荒原战车 REMAKE"）
- 构建输出：`build/windows/mm-remake.exe`
- Samba 分发：构建产物自动复制到 Samba 容器共享目录

## 资源目录规划

- `assets/` — 运行时资源
- `docs/` — 设计文档与参考图
- `external-assets/` — 原始大文件（不提交 Git）