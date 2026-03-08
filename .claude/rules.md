# Claw123 自定义规则

## Docker 镜像构建规则

- **必须使用 `Dockerfile.claw123` 进行构建** - 所有 Docker 镜像的构建必须基于 `Dockerfile.claw123`，而不是官方的 `Dockerfile`。

- **构建命令**:
  ```bash
  # 基本构建（按日期命名）
  docker build -f Dockerfile.claw123 -t claw123-openclaw:$(date +%Y.%m.%d) .

  # 同时打 latest 标签
  docker build -f Dockerfile.claw123 -t claw123-openclaw:$(date +%Y.%m.%d) -t claw123-openclaw:latest .
  ```

## 文档更新规则

- **配置更改必须更新 `README.claw123.md`** - 当对 `Dockerfile.claw123` 或相关配置文件（如 `docker-entrypoint.sh`）进行任何修改时，必须在 `README.claw123.md` 中记录这些更改。

- **更新内容应包括**:
  - 新增/删除的软件包或工具
  - 修改的配置选项
  - 变更原因和影响
  - 相关的运行命令示例（如有必要）

## 相关文件

| 文件 | 用途 |
|------|------|
| `Dockerfile.claw123` | 自定义 Docker 镜像构建文件 |
| `README.claw123.md` | 自定义镜像的完整文档和使用说明 |
| `docker-entrypoint.sh` | 容器启动入口脚本 |
| `.claude/rules.md` | 本规则文件 |

## 原则

这些规则确保：
1. 所有镜像构建保持一致性
2. 文档与实际配置同步
3. 便于追溯配置变更历史
