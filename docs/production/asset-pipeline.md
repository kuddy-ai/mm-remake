# Asset Pipeline

资源导入流程与规范。

## 目录区别

| 目录 | 用途 | Git 提交 |
|------|------|----------|
| `assets/` | 游戏运行时真正会加载的资源 | ✓ 提交 |
| `docs/` | 设计文档、开发规范、压缩后的参考图 | ✓ 提交 |
| `external-assets/` | 原始大文件、源文件、母带、分轨、AI原图 | ✗ 不提交 |

**判断标准**：如果无法确定某个资源是否运行时使用，先放到 `external-assets/`，不要放进 `assets/`。

## 图片资源导入

### 原始设计图 → external-assets/

原始设计图、高清大图、AI 生成原图放入：
```
external-assets/original-images/
```

### PSD/Aseprite 等源文件 → external-assets/

PSD、Aseprite、Krita、Clip Studio、分层源文件放入：
```
external-assets/art-source/
```

### 设计参考图 → docs/concept-art/

给 AI / Codex / 开发者参考的压缩设计图放入：
```
docs/concept-art/wasteland_hunter_design_images/
```

**导出标准**：
- 场景图：长边约 1920px，webp 质量 85 左右
- UI 图：长边约 2400px，webp 质量 90 左右
- 角色、怪物、载具：整图一份 + 局部裁切一份
- 单张建议控制在 500KB 到 2MB
- 文字、边框、材质细节必须清晰可读

**裁切示例**：
```
002_battle_ui_full.webp          # 完整 UI
002_battle_ui_hud_crop.webp      # HUD 局部
002_battle_ui_buttons_crop.webp  # 按钮局部
002_battle_ui_inventory_crop.webp # 库存局部
```

### 运行时图片 → assets/

游戏实际运行时加载的图片放入：
```
assets/sprites/player/     # 玩家精灵
assets/sprites/enemies/    # 敌人精灵
assets/sprites/vehicles/   # 载具精灵
assets/sprites/npcs/       # NPC 精灵
assets/ui/atlas/           # UI 纹理合集
assets/ui/fonts/           # 字体资源
assets/ui/ninepatch/       # 九宫格拉伸面板
assets/ui/panels/          # 预制面板素材
assets/ui/hud/             # HUD UI
assets/ui/inventory/       # 库存 UI
assets/ui/battle/          # 战斗 UI
assets/ui/dialog/          # 对话框 UI
assets/ui/buttons/         # 按钮 UI
assets/ui/icons/           # 图标
assets/tilesets/wasteland/ # 废土 tileset
assets/tilesets/ruins/     # 废墟 tileset
assets/tilesets/town/      # 城镇 tileset
assets/tilesets/dungeon/   # 地牢 tileset
assets/backgrounds/wasteland/ # 废土背景
assets/backgrounds/battle/    # 战斗背景
assets/backgrounds/parallax/  # 视差背景
assets/effects/explosions/   # 爆炸特效
assets/effects/bullets/      # 子弹特效
assets/effects/smoke/        # 烟雾特效
assets/effects/weather/      # 天气特效
```

## 音频资源导入

### 原始音频/母带 → external-assets/

原始音频、母带 WAV、分轨、工程文件放入：
```
external-assets/audio-source/   # 母带 WAV、工程文件
external-assets/audio-stems/    # 分轨文件
```

### 游戏音频 → assets/audio/

游戏实际播放的音频放入：
```
assets/audio/bgm/       # 背景音乐
assets/audio/sfx/       # 战斗、爆炸、武器、受击音效
assets/audio/ui/        # UI 点击、确认、取消、光标移动音效
assets/audio/ambience/  # 风声、机械声、城镇环境声
```

**音频格式建议**：
- MP3 只允许作为 demo 临时音频，正式版不应包含 MP3
- BGM：ogg
- 环境循环音：ogg
- 短音效：wav 或 ogg
- UI 音效：wav 或 ogg
- 原始母带 WAV 不进 Git，只放 `external-assets/`

## Git 提交规则

### 可以提交

- assets/ 下的所有运行时资源
- docs/ 下的文档和压缩参考图
- 代码文件（.gd, .tscn, .tres 等）
- 配置文件（project.godot 等）

### 不能提交

- external-assets/ 目录下的所有文件
- 源文件格式：
  - 图片源文件：`.psd .ai .kra .clip .tiff .tif .svg .xcf .aseprite .afdesign`
  - 音频源文件：`.flp .als .logicx .band .cpr .aiff .aif .wav.original`
  - 压缩包：`.zip .rar .7z`
- 环境变量文件：`.env`
- Godot 缓存：`.godot/ .import/ .export/`
- 构建产物：`build/ bin/ obj/ artifacts/`

## 资源命名规范

所有文件统一使用：**英文小写 + 数字序号 + 下划线**

### 图片命名示例

```
001_start_screen.webp
002_wasteland_scene.webp
003_battle_ui_full.webp
004_battle_ui_hud_crop.webp
005_player_idle.png
006_tank_idle.png
007_enemy_bandit_idle.png
```

### 音频命名示例

```
001_opening_theme.ogg
002_wasteland_field_loop.ogg
003_battle_normal_loop.ogg
004_boss_battle_loop.ogg
ui_confirm.wav
ui_cancel.wav
ui_cursor_move.wav
tank_cannon_fire_01.wav
explosion_small_01.wav
desert_wind_loop.ogg
```

### 禁止命名

不要使用：
- 中文文件名
- 空格
- 特殊符号
- 开始界面.png
- battle ui.png
- 角色-待机.png
- final_final_最终版.png
- new image copy 2.png

## 新增资源检查清单

添加新资源前，请确认：

1. [ ] 确定资源类型：运行时 / 参考图 / 源文件
2. [ ] 放入正确目录：assets / docs / external-assets
3. [ ] 检查文件大小：运行时资源是否过大？
4. [ ] 使用正确命名：英文小写 + 数字序号 + 下划线
5. [ ] 检查 gitignore：源文件格式是否会被忽略？
6. [ ] 更新相关代码：路径引用是否正确？
7. [ ] 测试加载：Godot 是否能正确加载？

## 目录结构总览

```text
project/
├── assets/                      # 运行时资源（提交 Git）
│   ├── sprites/
│   ├── ui/
│   ├── tilesets/
│   ├── backgrounds/
│   ├── effects/
│   └── audio/
│       ├── bgm/
│       ├── sfx/
│       ├── ui/
│       └── ambience/
│
├── docs/                        # 文档与参考图（提交 Git）
│   ├── README.md
│   ├── concept-art/
│   │   └── wasteland_hunter_design_images/
│   ├── game-design/
│   ├── ui-design/
│   ├── art-direction/
│   ├── audio-design/
│   ├── tech-design/
│   └── production/
│
├── external-assets/             # 原始源文件（不提交 Git）
│   ├── original-images/
│   ├── art-source/
│   ├── audio-source/
│   ├── audio-stems/
│   ├── ai-generated-originals/
│   └── references/
│
└── .gitignore                   # 排除源文件格式
```