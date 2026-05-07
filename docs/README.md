# Docs Directory

开发文档、设计规范、参考资料目录。

## 目录结构

```text
docs/
├── README.md                    # 本文件
├── concept-art/                 # 压缩后的设计参考图
│   └── wasteland_hunter_design_images/
├── game-design/                 # 游戏玩法设计
│   ├── worldview.md             # 世界观
│   ├── core-loop.md             # 核心循环
│   └── battle-system.md         # 战斗系统
├── ui-design/                   # UI 设计规范
│   └── ui-style-guide.md        # UI 风格指南
├── art-direction/               # 美术风格规范
│   └── pixel-style-guide.md     # 像素风格指南
├── audio-design/                # 音频设计规范
│   └── audio-style-guide.md     # 音频风格指南
├── tech-design/                 # 技术架构设计
│   └── architecture.md          # Godot 架构
└── production/                  # 开发流程与规范
    ├── asset-pipeline.md        # 素材流程
    └── codex-prompts.md         # Codex 提示词
```

## 开发前阅读顺序

开发前请优先阅读 docs/ 下的设计文档：

- **实现 UI** 时读取 `docs/ui-design/` 和 `docs/concept-art/`
- **实现美术风格** 时读取 `docs/art-direction/`
- **实现玩法** 时读取 `docs/game-design/`
- **实现工程结构** 时读取 `docs/tech-design/`

## 注意

docs/ 不是运行时资源目录。游戏实际加载的资源放在 `assets/`。