# Contributing Guide

感谢你参与 **重装机兵 Remake**！

## 1. 分支策略

- `main`: 发布分支
- `develop`: 集成分支
- `feature/<name>`: 新功能
- `fix/<name>`: 修复

## 2. 提交规范

采用 Conventional Commits：

- `feat:` 新功能
- `fix:` 修复
- `docs:` 文档
- `refactor:` 重构
- `test:` 测试
- `chore:` 维护

示例：

```text
fix(combat): resolve damage overflow when crit
```

## 3. Pull Request 流程

1. 从 `develop` 创建分支
2. 完成功能并补充测试
3. 本地通过构建与测试
4. 发起 PR 到 `develop`

## 4. 代码评审要求

- 描述清晰
- 小步提交
- 不提交无关改动
- 必要时附截图/录屏
