# 重装机兵 Remake

> 一款基于 **Godot 4.x** 打造的 2D 高清像素风 RPG 项目模板，面向多人协作与多平台发布。

## 1. 项目介绍

“重装机兵 Remake”目标是以现代工作流重构经典战车题材游戏体验，强调：

- 高清像素风（HD Pixel Art）
- 可维护的工程结构
- 多平台构建（Desktop + Mobile）
- 面向团队协作（规范、模板、CI/CD）

当前仓库为初始化模板，可直接用于 GitHub 新项目启动。

## 2. 技术栈说明

- **引擎/框架**：Godot 4.x
- **脚本语言**：GDScript（默认）或 C#（可选）
- **目标平台**：Windows / macOS / Linux / Android / iOS
- **版本控制**：Git + GitHub
- **CI/CD**：GitHub Actions
- **可选工具**：Docker、pre-commit

## 3. 快速启动指南

### 3.1 通用准备

1. 安装 Godot 4.x（建议与团队锁定同一小版本，如 4.3.x）
2. 克隆仓库：

```bash
git clone <your-repo-url>
cd mm-remake
```

3. 使用 Godot 打开 `project.godot`

### 3.2 使用 Docker 运行（推荐，无需安装 Godot）

项目内置 Docker 支持，可以直接在容器中运行 Godot 编辑器。

#### 3.2.1 本地运行（Linux / macOS）

```bash
# 允许 X11 转发
xhost +local:docker

# 一键运行
docker compose up --build
```

#### 3.2.2 从 Windows 通过 MobaXterm 远程运行

适用于 Docker 运行在 Linux 主机上，从 Windows 连接显示：

1. **创建 `.env` 文件**（项目根目录）
   ```bash
   # .env
   DISPLAY_HOST=<你的WindowsIP>  # 例如 192.168.x.x
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

> **注意**：两台机器需在同一局域网。如果画面不显示，检查 Windows 防火墙是否允许 6000 端口入站。

### 3.3 Windows / macOS / Linux（本地 Godot）

- 编辑器运行：

```bash
./scripts/run.sh
```

- 构建（示例：Linux Debug）：

```bash
./scripts/build.sh linux debug
```

### 3.4 Android

1. 在 Godot 中安装 Android Build Template
2. 配置 `ANDROID_HOME` 与签名信息
3. 使用：

```bash
./scripts/build.sh android release
```

### 3.5 iOS（仅 macOS）

1. 安装 Xcode 与命令行工具
2. 在 Godot 导出 Xcode 项目
3. 使用 Xcode 进行签名与真机构建

### 3.6 CI 构建

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
│   ├── sounds/
│   └── ui/
├── docs/
├── game/
├── scenes/
├── scripts/
├── tests/
├── LICENSE
├── CONTRIBUTING.md
├── README.md
└── project.godot
```

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
