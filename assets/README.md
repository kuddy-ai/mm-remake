# Assets Directory

游戏运行时真正会加载的资源。

**判断标准**：如果无法确定某个资源是否运行时使用，先放到 `external-assets/`，不要放进这里。

## 目录结构

```text
assets/
├── sprites/
│   ├── player/          # 玩家精灵
│   ├── enemies/         # 敌人精灵
│   ├── vehicles/        # 载具精灵
│   └── npcs/            # NPC 精灵
│
├── ui/
│   ├── atlas/           # UI 纹理合集
│   ├── fonts/           # 字体资源
│   ├── ninepatch/       # 九宫格拉伸面板
│   ├── panels/          # 预制面板素材
│   ├── hud/             # HUD UI
│   ├── inventory/       # 库存 UI
│   ├── battle/          # 战斗 UI
│   ├── dialog/          # 对话框 UI
│   ├── buttons/         # 按钮 UI
│   └── icons/           # 图标
│
├── tilesets/
│   ├── wasteland/       # 废土 tileset
│   ├── ruins/           # 废墟 tileset
│   ├── town/            # 城镇 tileset
│   └── dungeon/         # 地牢 tileset
│
├── backgrounds/
│   ├── wasteland/       # 废土背景
│   ├── battle/          # 战斗背景
│   └── parallax/        # 视差背景
│
├── effects/
│   ├── explosions/      # 爆炸特效
│   ├── bullets/         # 子弹特效
│   ├── smoke/           # 烟雾特效
│   └── weather/         # 天气特效
│
└── audio/
    ├── bgm/             # 背景音乐
    ├── sfx/             # 战斗、爆炸、武器音效
    ├── ui/              # UI 音效
    └── ambience/        # 环境循环音
```

## 命名规范

所有文件使用：英文小写 + 数字序号 + 下划线

示例：
- `001_player_idle.png`
- `002_tank_cannon_fire.ogg`
- `ui_confirm.wav`

## 音频格式规则

- MP3 只允许作为 demo 临时音频，正式版不应包含 MP3
- 正式 BGM 和循环环境音推荐 ogg
- 短音效推荐 wav 或 ogg

## 注意

- 不要把设计参考图放进 assets/
- 不要把 PSD、Aseprite 等源文件放进 assets/
- 设计参考图放在 `docs/concept-art/`
- 源文件放在 `external-assets/`