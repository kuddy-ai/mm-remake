# 重装机兵 Remake

> 一款基于 **Godot 4.x** 打造的 2D 高清像素风 RPG 垂直切片 Demo / 项目骨架，面向团队协作与持续迭代。

## 1. 项目介绍

"重装机兵 Remake"目标是以现代工作流重构经典战车题材游戏体验，强调：

- 高清像素风（HD Pixel Art）
- 可维护的工程结构
- 面向团队协作（规范、模板、CI/CD）

当前仓库为 Godot 4.x 垂直切片 Demo / 项目骨架，包含完整的城镇 Hub → 路线选择 → 自动战斗 → 资源结算 → 车库升级核心循环。

## 2. 技术栈说明

- **引擎/框架**：Godot 4.x
- **脚本语言**：GDScript（默认）或 C#（可选）
- **目标平台**：Windows Desktop（当前 build.sh 仅支持 Windows）
- **版本控制**：Git + GitHub
- **CI/CD**：GitHub Actions
- **可选工具**：Docker（X11 转发编辑器）、Samba（构建产物分发）

## 3. 快速启动指南

### 3.1 通用准备

1. 安装 Godot 4.x（建议与团队锁定同一小版本，如 4.3.x）
2. 克隆仓库：

```bash
git clone <your-repo-url>
cd mm-remake
```

3. 使用 Godot 打开 `project.godot`

### 3.2 使用 Docker 运行（X11 转发）

项目内置 Docker 支持，可以在容器中运行 Godot 编辑器，通过 X11 转发到远程显示器。

**首次运行前必须复制 `.env.example` 为 `.env`**，否则 Docker 容器无法显示界面：

```bash
cp .env.example .env
# 编辑 .env 设置 DISPLAY_HOST=<你的远程IP>
```

#### 3.2.1 本地运行（Linux / macOS）

```bash
# 允许 X11 转发
xhost +local:docker

# 一键运行
docker compose up --build
```

#### 3.2.2 从 Windows 通过 MobaXterm 远程运行

适用于 Docker 运行在 Linux 主机上，从 Windows 连接显示：

1. **复制 `.env.example` 为 `.env`**（项目根目录）
   ```bash
   cp .env.example .env
   # 编辑 .env 设置 DISPLAY_HOST=<你的WindowsIP>
   ```

2. **Windows 上启动 MobaXterm**（自带 X Server）
   - 打开 MobaXterm → 左下角 X Server 自动启动
   - 右键任务栏图标 → `X server settings` → Access control 改为 `full`

3. **开放 Windows 防火墙 6000 端口**（X11 默认端口）
   ```powershell
   New-NetFirewallRule -DisplayName "X11" -Direction Inbound -Protocol TCP -LocalPort 6000 -Action Allow
   ```

4. **在 Linux 主机上运行**
   ```bash
   docker compose up --build
   ```

> **注意**：两台机器需在同一局域网。如果画面不显示，检查 `.env` 中 `DISPLAY_HOST` 是否正确以及 Windows 防火墙是否允许 6000 端口入站。

### 3.3 Windows 构建

当前 `scripts/build.sh` 仅支持 Windows Desktop 构建：

```bash
./scripts/build.sh windows debug   # 调试版
./scripts/build.sh windows release # 发布版
```

输出：
- `build/windows/mm-remake.exe` — 本地构建产物
- 自动复制到 Samba 容器 `SMB_CONTAINER:/share/mm-remake/windows/`

依赖环境变量（可在 `.env` 中配置）：
- `SMB_CONTAINER` — Samba 容器名称
- `SMB_OUTPUT_DIR` — 共享目录路径（可选）
- `SMB_USER` / `SMB_GROUP` — Samba 用户/组（可选）

### 3.4 CI 构建

推送到 GitHub 后自动触发 `.github/workflows/ci.yml`。

## 4. 项目目录说明

```text
.
├── .github/
│   ├── workflows/
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
├── assets/
│   ├── sprites/
│   ├── ui/
│   ├── tilesets/
│   ├── backgrounds/
│   ├── effects/
│   └── audio/
├── docs/
├── game/
├── scenes/
├── scripts/
├── tests/
├── external-assets/          # 原始大文件（不提交 Git）
├── LICENSE
├── CONTRIBUTING.md
├── README.md
└── project.godot
```

详细目录说明与资源规范见：
- [docs/README.md](docs/README.md)
- [docs/production/asset-pipeline.md](docs/production/asset-pipeline.md)

## 5. 开发规范

### 5.1 代码风格

- GDScript：
  - 4 空格缩进
  - 文件名使用 `snake_case.gd`
  - 类名 `PascalCase`
- C#：
  - 遵循 .NET 命名规范
  - 开启可空引用类型（推荐）

### 5.2 分支策略

- `main`：稳定可发布
- `develop`：日常集成
- `feature/*`：功能开发
- `fix/*`：问题修复

### 5.3 提交规范（Conventional Commits）

- `feat: ...`
- `fix: ...`
- `docs: ...`
- `refactor: ...`
- `test: ...`
- `chore: ...`

示例：

```text
feat(player): add 8-direction movement
```

### 5.4 Pull Request 要求

- 关联 Issue
- 提供改动说明与测试说明
- 涉及 UI/玩法改动需附截图或录屏

---

欢迎通过 Issue / PR 一起完善这个项目模板。