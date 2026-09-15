==============================================================

-       Created:     2026-09-11  16:00（创建时间）
-       Filename:    ubuntu_install_manaul.md（Ubuntu 安装脚本使用手册）
-       Author:   ______
-                    / /  (_)
-                   / /_  /\____  ____  __   ______
-                  / __ \/ / __ \/ __ \/ /  / /
-                 / /_/ / / / / / / / / /__/ /
-                /_____/_/_/ /_/_/ /_/____  /
-               ========== ______________/ /
-                          \______________/
-
-       Email:       Binny@vip.163.com
-       Group:       SP
-       Create By:   Binny
-       Purpose:     Kuest Prediction Market Ubuntu 一键安装包使用手册
-       Copyright:   TJYM(C) 2010 - All Rights Reserved
-       Version:     1.1（版本号）
-       LastModify:  2026-09-11（最后一次修改日期）

==============================================================

# Kuest Prediction Market - Ubuntu 一键安装包使用手册

## 目录

- [概述](#概述)
- [系统要求](#系统要求)
- [快速开始](#快速开始)
- [安装配置](#安装配置)
- [安装流程](#安装流程)
- [服务管理](#服务管理)
- [数据库管理](#数据库管理)
- [备份与恢复](#备份与恢复)
- [更新与维护](#更新与维护)
- [故障排查](#故障排查)
- [环境变量详解](#环境变量详解)

---

## 概述

`ubuntu_install.sh` 是用于在 Ubuntu 系统上一键部署 Kuest Prediction Market 预测市场平台的自动化安装脚本。

**主要功能：**

- 自动安装 Node.js 24.x
- 自动安装 pnpm 包管理器
- 自动安装 PostgreSQL 17
- 自动安装 Caddy 反向代理（可选）
- 自动拉取/复制项目代码
- 自动构建生产版本
- 自动创建 Systemd 服务
- 自动配置防火墙（UFW）

---

## 系统要求

### 最低配置

| 项目     | 要求                        |
| -------- | --------------------------- |
| 操作系统 | Ubuntu 22.04 LTS 或更高版本 |
| CPU      | 2 核心或以上                |
| 内存     | 2GB RAM 或以上              |
| 磁盘空间 | 10GB 可用空间               |
| 网络     | 需要访问外网下载依赖        |

### 推荐配置

| 项目     | 推荐值           |
| -------- | ---------------- |
| 操作系统 | Ubuntu 24.04 LTS |
| CPU      | 4 核心或以上     |
| 内存     | 4GB RAM 或以上   |
| 磁盘空间 | 20GB SSD         |
| 网络     | 固定公网 IP      |

---

## 快速开始

### 1. 下载安装脚本

```bash
# 方法一：从 Git 仓库下载
wget https://raw.githubusercontent.com/kuestcom/prediction-market/main/infra/ubuntu_install.sh

# 方法二：从本地仓库复制
cp infra/ubuntu_install.sh /tmp/
```

### 2. 赋予执行权限

```bash
chmod +x ubuntu_install.sh
```

### 3. 运行安装脚本

```bash
sudo ./ubuntu_install.sh
```

### 4. 等待安装完成

脚本将自动执行所有安装步骤，全程约需 10-30 分钟（取决于网络速度和机器性能）。

---

## 安装配置

### 环境变量配置

在安装脚本执行前，可通过设置环境变量来自定义安装行为：

```bash
# 应用安装目录（默认: /opt/kuest）
export INSTALL_DIR="/opt/kuest"

# 应用运行用户（默认: kuest）
export APP_USER="kuest"

# 应用端口（默认: 3000）
export APP_PORT=3000

# 域名（用于 Caddy 反向代理，默认: 空）
export APP_DOMAIN="markets.example.com"

# 是否安装本地 PostgreSQL（默认: true）
export INSTALL_POSTGRES=true

# 是否安装 Caddy 反向代理（默认: false）
export INSTALL_CADDY=true

# Git 仓库地址（用于拉取项目代码）
export GITHUB_REPO="https://github.com/kuestcom/prediction-market.git"

# PostgreSQL 数据库密码（随机生成如果未设置）
export POSTGRES_PASSWORD="your_secure_password"
```

### 安装模式

脚本支持两种安装模式：

- **`full`**（默认）：安装所有组件（Node.js + pnpm + PostgreSQL + Caddy）
- **`minimal`**：仅安装 Node.js + pnpm + 项目代码（适用于已有数据库的环境）

设置方式：

```bash
export INSTALL_TYPE="minimal"
```

---

## 安装流程

安装脚本按以下顺序执行：

```
1. 检查系统
   ├── 检查 root 权限
   ├── 检查操作系统版本
   └── 检查硬件资源（内存/磁盘）

2. 安装基础依赖
   └── curl, wget, git, build-essential 等

3. 安装 Node.js 24
   └── 通过 NodeSource 官方仓库安装

4. 安装 pnpm
   └── 通过 corepack 安装

5. 安装 PostgreSQL 17（可选）
   ├── 添加 PostgreSQL 官方仓库
   ├── 安装 PostgreSQL 17 + pgvector
   └── 创建数据库和用户

6. 创建应用用户
   └── 创建专用系统用户

7. 安装项目代码
   ├── 从 Git 仓库克隆
   └── 或从本地仓库复制

8. 安装项目依赖
   └── pnpm install --frozen-lockfile

9. 创建环境变量文件
   └── 生成 .env 文件

10. 构建项目
    └── pnpm build

11. 安装 Caddy（可选）
    └── 配置反向代理

12. 创建 Systemd 服务
    └── 配置自动启动

13. 配置防火墙
    └── UFW 端口开放

14. 启动服务
    └── systemctl start kuest

15. 验证安装
    └── 检查所有组件状态
```

---

## 服务管理

### Systemd 服务命令

```bash
# 查看服务状态
sudo systemctl status kuest

# 启动服务
sudo systemctl start kuest

# 停止服务
sudo systemctl stop kuest

# 重启服务
sudo systemctl restart kuest

# 重新加载配置（不中断服务）
sudo systemctl reload kuest

# 设置开机自启
sudo systemctl enable kuest

# 取消开机自启
sudo systemctl disable kuest

# 查看服务日志
sudo journalctl -u kuest -f

# 查看最近的日志（最后 100 行）
sudo journalctl -u kuest -n 100 --no-pager
```

### 日志查看

```bash
# 实时跟踪日志
sudo journalctl -u kuest -f

# 查看今天的日志
sudo journalctl -u kuest --since today

# 查看最近的崩溃日志
sudo journalctl -u kuest -p err

# 导出日志到文件
sudo journalctl -u kuest > /tmp/kuest-logs.txt
```

---

## 数据库管理

### 连接数据库

```bash
# 使用 postgres 用户连接
sudo -u postgres psql -d kuest

# 使用应用用户连接
psql -U kuest -d kuest -h localhost
```

### 常用数据库操作

```bash
# 查看所有数据库
sudo -u postgres psql -c '\l'

# 查看表列表
sudo -u postgres psql -d kuest -c '\dt'

# 查看数据库大小
sudo -u postgres psql -d kuest -c 'SELECT pg_database_size(\'kuest\');'

# Vacuum 优化
sudo -u postgres psql -d kuest -c 'VACUUM ANALYZE;'
```

### 数据库迁移

```bash
# 进入项目目录
cd /opt/kuest

# 执行数据库迁移
pnpm db:push
```

---

## 备份与恢复

### 数据库备份

```bash
# 全量备份
pg_dump -U kuest -d kuest > /tmp/kuest-backup-$(date +%Y%m%d).sql

# 仅备份结构
pg_dump -U kuest -d kuest --schema-only > /tmp/kuest-schema.sql

# 压缩备份
pg_dump -U kuest -d kuest | gzip > /tmp/kuest-backup-$(date +%Y%m%d).sql.gz
```

### 数据库恢复

```bash
# 从 SQL 文件恢复
psql -U kuest -d kuest < /tmp/kuest-backup-20260911.sql

# 从压缩文件恢复
gunzip -c /tmp/kuest-backup-20260911.sql.gz | psql -U kuest -d kuest
```

### 项目备份

```bash
# 备份整个项目目录
tar -czf /tmp/kuest-project-$(date +%Y%m%d).tar.gz -C /opt kuest

# 仅备份 .env 文件
cp /opt/kuest/.env /tmp/kuest-backup/

# 备份 node_modules（不推荐，体积大）
tar -czf /tmp/kuest-node_modules-$(date +%Y%m%d).tar.gz -C /opt/kuest node_modules
```

### 自动备份脚本

创建定时备份任务：

```bash
# 编辑 crontab
crontab -e

# 添加每日凌晨 2 点自动备份
0 2 * * * pg_dump -U kuest -d kuest | gzip > /backup/kuest-$(date +\%Y\%m\%d).sql.gz
```

---

## 更新与维护

### 手动更新

```bash
# 进入项目目录
cd /opt/kuest

# 拉取最新代码
git pull

# 安装最新依赖
pnpm install --frozen-lockfile

# 重新构建
pnpm build

# 重启服务
sudo systemctl restart kuest
```

### 更新 .env 文件

```bash
# 编辑环境变量
sudo vim /opt/kuest/.env

# 重新加载服务（不中断）
sudo systemctl reload kuest
```

### 清理缓存

```bash
# 清理 Next.js 缓存
rm -rf /opt/kuest/.next/cache

# 清理 pnpm 缓存
pnpm store prune

# 清理系统日志
sudo journalctl --vacuum-time=7d
```

### 监控资源使用

```bash
# 查看服务资源占用
systemctl status kuest

# 查看内存使用
ps aux | grep node

# 查看磁盘使用
df -h

# 查看日志大小
du -sh /var/log/journal/
```

---

## 故障排查

### 服务无法启动

```bash
# 查看服务状态
sudo systemctl status kuest

# 查看详细日志
sudo journalctl -u kuest -n 200 --no-pager

# 检查端口占用
sudo lsof -i :3000

# 检查文件权限
ls -la /opt/kuest/.env
```

**常见问题：**

1. **端口被占用**

   ```bash
   # 查找占用端口的进程
   sudo lsof -i :3000
   # 杀掉进程或修改 APP_PORT
   ```

2. **数据库连接失败**

   ```bash
   # 检查 PostgreSQL 状态
   sudo systemctl status postgresql
   # 检查数据库密码
   cat /opt/kuest_db_password.txt
   ```

3. **构建失败**
   ```bash
   # 检查内存
   free -m
   # 检查 Node.js 版本
   node --version
   ```

### 数据库连接问题

```bash
# 检查 PostgreSQL 是否运行
sudo systemctl status postgresql

# 手动测试连接
psql -U kuest -d kuest -h localhost -c 'SELECT 1;'

# 检查 pg_hba.conf 配置
sudo cat /etc/postgresql/17/main/pg_hba.conf
```

### 构建失败

```bash
# 检查磁盘空间
df -h

# 检查内存
free -m

# 手动构建查看详细错误
cd /opt/kuest
pnpm build

# 清理后重新构建
rm -rf .next
pnpm build
```

### 日志轮转

```bash
# 配置日志大小限制（已在 systemd 服务中设置）
# 如需调整，编辑服务文件
sudo systemctl edit kuest

# 手动清理旧日志
sudo journalctl --vacuum-size=100M
```

---

## 环境变量详解

### 必需配置

| 变量                 | 说明             | 默认值                  |
| -------------------- | ---------------- | ----------------------- |
| `SITE_URL`           | 站点 URL         | `http://localhost:3000` |
| `DATABASE_URL`       | 数据库连接字符串 | 本地 PostgreSQL         |
| `BETTER_AUTH_SECRET` | Auth 密钥        | 自动生成                |

### Web3 配置

| 变量                   | 说明     | 默认值          |
| ---------------------- | -------- | --------------- |
| `NEXT_PUBLIC_CHAIN_ID` | 链 ID    | `137` (Polygon) |
| `NEXT_PUBLIC_NETWORK`  | 网络名称 | `polygon`       |

### CLOB 配置

| 变量                   | 说明          | 默认值               |
| ---------------------- | ------------- | -------------------- |
| `NEXT_PUBLIC_CLOB_URL` | CLOB 服务地址 | Polymarket 公共 CLOB |

### 可选配置

| 变量                    | 说明                |
| ----------------------- | ------------------- |
| `SENTRY_AUTH_TOKEN`     | Sentry 错误追踪令牌 |
| `AWS_REGION`            | AWS S3 区域         |
| `AWS_ACCESS_KEY_ID`     | AWS 访问密钥        |
| `AWS_SECRET_ACCESS_KEY` | AWS 密钥            |
| `AWS_BUCKET_NAME`       | S3 存储桶名称       |
| `SUMSUB_APP_TOKEN`      | Sumsub KYC 令牌     |
| `LIFI_PROVIDER_URL`     | Li.Fi 兑换服务地址  |

---

## 安全建议

1. **修改默认数据库密码**

   ```bash
   sudo vim /opt/kuest/.env
   ```

2. **配置防火墙**

   ```bash
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 80/tcp    # HTTP
   sudo ufw allow 443/tcp   # HTTPS
   sudo ufw enable
   ```

3. **定期更新系统**

   ```bash
   sudo apt-get update && sudo apt-get upgrade
   ```

4. **限制数据库访问**

   ```bash
   # 编辑 pg_hba.conf
   sudo vim /etc/postgresql/17/main/pg_hba.conf
   # 仅允许本地连接
   ```

5. **备份 .env 文件**
   ```bash
   cp /opt/kuest/.env /backup/kuest.env.backup
   ```

---

## 卸载

如需完全卸载 Kuest：

```bash
# 停止服务
sudo systemctl stop kuest
sudo systemctl disable kuest

# 删除服务文件
sudo rm /etc/systemd/system/kuest.service
sudo systemctl daemon-reload

# 删除项目目录
sudo rm -rf /opt/kuest

# 删除应用用户
sudo userdel kuest

# （可选）删除数据库
sudo -u postgres dropdb kuest
sudo -u postgres dropuser kuest

# （可选）卸载 PostgreSQL
sudo apt-get remove postgresql*
sudo apt-get autoremove
```

---

## 技术支持

- **仓库地址**: https://github.com/kuestcom/prediction-market
- **Email**: Binny@vip.163.com
- **Group**: SP

---

_本文档随安装脚本一同提供，如有更新请访问 Git 仓库获取最新版本。_
