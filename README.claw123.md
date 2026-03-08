# Claw123 OpenClaw Docker 镜像

这是基于 OpenClaw 官方镜像的自定义版本，增加了额外的开发工具和持久化配置支持。

## 快速构建

### 基本构建（按日期命名）

```bash
docker build -f Dockerfile.claw123 -t claw123-openclaw:$(date +%Y.%m.%d) .
```

### 同时打 latest 标签

```bash
docker build -f Dockerfile.claw123 -t claw123-openclaw:$(date +%Y.%m.%d) -t claw123-openclaw:latest .
```

### 其他日期格式选项

- `$(date +%Y.%m.%d)` → `2026.03.09`
- `$(date +%Y%m%d)` → `20260309`
- `$(date +%Y.%m.%d-%H%M)` → `2026.03.09-1430`

## 修改内容

### 相比官方 Dockerfile 的变化

1. **自定义 Entrypoint** (`docker-entrypoint.sh`)
   - 启动前自动恢复持久化的 SSH 密钥
   - 启动前自动恢复 Git 配置
   - 支持 `~/.openclaw/ssh/` → `~/.ssh/` 软链接
   - 支持 `~/.openclaw/gitconfig` → `~/.gitconfig` 复制

2. **运行用户改为 root**
   - 官方版本运行为 `node` 用户（uid 1000）
   - 本版本运行为 `root`，便于使用 pyenv、docker 等需要 root 的工具

3. **预装开发工具**
   - apt packages: git, curl, wget, vim, nano, python3, postgresql-client, redis-tools, htop, tmux, jq, ripgrep, fzf, docker CLI, docker-compose, pyenv, yq, chromium 等（详见下方完整列表）

4. **预装 Python 包**
   - bittensor（包含完整系统依赖：libzmq3-dev, protobuf-compiler, pkg-config）

## Bittensor 支持

本镜像已预装 bittensor 及其所有系统依赖，可直接在 OpenClaw agent 中使用 bittensor 功能。

### 为什么需要预装

bittensor 包含 C++/Rust 编写的原生组件，这些组件在编译时链接了各种系统库（如 libzmq、protobuf 等）。在最小化的沙箱环境中这些库缺失会导致运行时崩溃。

### 验证安装

```bash
# 进入运行中的容器
docker exec -it openclaw-gateway /bin/bash

# 验证 bittensor 安装
python3 -c "import bittensor; print(bittensor.__version__)"

# 运行 bittensor CLI
btcli --help
```

### 相关文件变更

- `Dockerfile.claw123:49-50` - 添加 bittensor 系统依赖 (libzmq3-dev, protobuf-compiler, pkg-config)
- `Dockerfile.claw123:74-76` - 安装 bittensor Python 包
- `README.claw123.md` - 添加 bittensor 支持文档

## 文件说明

| 文件 | 说明 |
|------|------|
| `Dockerfile.claw123` | 自定义镜像构建文件 |
| `docker-entrypoint.sh` | 容器启动入口脚本，恢复持久化配置 |

## 运行容器

### 基本运行

```bash
docker run -d \
  -v ~/.openclaw:/root/.openclaw \
  -p 18789:18789 \
  claw123-openclaw:latest
```

### 挂载 Docker socket（容器内使用 docker）

```bash
docker run -d \
  -v ~/.openclaw:/root/.openclaw \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 18789:18789 \
  claw123-openclaw:latest
```

### 完整参数示例

```bash
docker run -d \
  --name openclaw-gateway \
  -v ~/.openclaw:/root/.openclaw \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 18789:18789 \
  --restart unless-stopped \
  claw123-openclaw:latest
```

## 持久化配置

### SSH 密钥

在宿主机创建并挂载 SSH 密钥目录：

```bash
mkdir -p ~/.openclaw/ssh
cp ~/.ssh/id_rsa ~/.openclaw/ssh/
chmod 700 ~/.openclaw/ssh
chmod 600 ~/.openclaw/ssh/id_rsa
```

容器启动时会自动创建 `~/.ssh → ~/.openclaw/ssh` 软链接。

### Git 配置

```bash
cp ~/.gitconfig ~/.openclaw/gitconfig
```

容器启动时会自动复制到 `~/.gitconfig`。

## 预装工具列表

### 开发基础
- git, curl, wget, vim, nano, ca-certificates, gnupg

### Python
- python3, python3-pip, python3-venv, python3-dev
- pyenv (Python 版本管理器)
- bittensor (去中心化神经网络，预装系统依赖: libzmq3-dev, protobuf-compiler, pkg-config)

### 数据库客户端
- postgresql-client, redis-tools, sqlite3

### 系统监控
- htop, tmux, procps, lsof

### 网络调试
- netcat-openbsd, dnsutils, nmap, httpie

### 文本处理
- jq, ripgrep, fzf, gawk, yq (YAML 处理)

### 构建工具
- make, gcc, g++, build-essential
- libzmq3-dev, protobuf-compiler, pkg-config (bittensor 依赖)

### 压缩传输
- zip, unzip, rsync, openssh-client

### 浏览器
- chromium (用于 Puppeteer/Playwright)
- fonts-liberation

### Docker
- Docker CLI 27.5.1 (静态二进制)
- Docker Compose (独立二进制)

## 网络配置

默认情况下，OpenClaw gateway 绑定到 `127.0.0.1`（loopback）。如需从外部访问：

1. **使用 host 网络**
   ```bash
   docker run --network host ...
   ```

2. **或覆盖 bind 地址**
   ```bash
   docker run ... claw123-openclaw:latest node openclaw.mjs gateway --bind lan --allow-unconfigured
   ```

## 健康检查

容器内置健康检查端点：
- `GET /healthz` - 存活检查
- `GET /readyz` - 就绪检查
- 别名: `/health` 和 `/ready`

## 维护说明

### 清理旧镜像

```bash
# 查看所有 claw123-openclaw 镜像
docker images | grep claw123-openclaw

# 删除旧镜像（保留最新）
docker rmi claw123-openclaw:2026.03.08
```

### 进入运行中的容器

```bash
docker exec -it <container-id> /bin/bash
# 或
docker exec -it openclaw-gateway /bin/bash
```

### 查看日志

```bash
docker logs -f <container-id>
# 或
docker logs -f openclaw-gateway
```
