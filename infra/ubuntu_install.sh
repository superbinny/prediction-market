#!/bin/bash
# *************************************************************
#       Created:     2026-09-11  16:00（创建时间）
#       Filename:    ubuntu_install.sh（Ubuntu 一键安装脚本）
#       Author:   ______
#                    / /  (_)
#                   / /_  /\____  ____  __   ______
#                  / __ \/ / __ \/ __ \/ /  / /
#                 / /_/ / / / / / / / / /__/ /
#                /_____/_/_/ /_/_/ /_/____  /
#               ========== ______________/ /
#                          \______________/
#
#       Email:       Binny@vip.163.com
#       Group:       SP
#       Create By:   Binny
#       Purpose:     Ubuntu 一键安装 Kuest Prediction Market 预测市场平台
#       Copyright:   TJYM(C) 2010 - All Rights Reserved
#       Version:     1.1（版本号）
#       LastModify:  2026-09-11（最后一次修改日期）
# *************************************************************

set -euo pipefail

# ======================== 颜色定义 ========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ======================== 日志函数 ========================
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }
header()  { echo -e "\n${BOLD}${CYAN}=== $1 ===${NC}\n"; }

# ======================== 配置变量 ========================
# 可在执行前覆盖这些变量
export NODE_MAJOR=24                    # Node.js 主版本
INSTALL_DIR="/opt/kuest"                # 项目安装目录
APP_USER="kuest"                        # 运行用户
APP_PORT=3000                           # 应用端口
APP_DOMAIN=""                          # 域名（可选，用于 Caddy 反向代理）
INSTALL_POSTGRES=true                   # 是否安装本地 PostgreSQL
INSTALL_CADDY=false                     # 是否安装 Caddy 反向代理
INSTALL_TYPE="full"                     # 安装类型: minimal/full

# ======================== 检查根权限 ========================
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "请使用 root 或 sudo 运行此脚本"
        exit 1
    fi
}

# ======================== 检查系统版本 ========================
check_os() {
    header "检查操作系统"

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS="$NAME"
        VER="$VERSION_ID"
        info "检测到: $OS $VER"
    else
        error "无法检测操作系统版本"
        exit 1
    fi

    # 仅支持 Ubuntu 22.04+
    if [[ "$OS" != *"Ubuntu"* ]]; then
        warn "检测到非 Ubuntu 系统，尝试兼容安装..."
    fi

    local ubuntu_ver
    ubuntu_ver=$(lsb_release -rs 2>/dev/null || echo "")
    if [[ -n "$ubuntu_ver" ]] && [[ "$(echo "$ubuntu_ver < 22.04" | bc 2>/dev/null || echo 0)" == "1" ]]; then
        error "需要 Ubuntu 22.04 或更高版本"
        exit 1
    fi

    success "操作系统检查通过"
}

# ======================== 检查硬件要求 ========================
check_hardware() {
    header "检查硬件要求"

    # 检查内存
    local total_mem
    total_mem=$(free -m | awk '/^Mem:/{print $2}')
    info "总内存: ${total_mem}MB"
    if [[ $total_mem -lt 1024 ]]; then
        warn "内存低于 1GB，构建可能失败。建议至少 2GB 内存。"
    fi

    # 检查磁盘空间
    local available_space
    available_space=$(df -m "$INSTALL_DIR" 2>/dev/null | awk 'NR==2{print $4}' || echo "0")
    if [[ -z "$available_space" ]]; then
        available_space=$(df -m / | awk 'NR==2{print $4}')
    fi
    info "可用磁盘空间: ${available_space}MB"
    if [[ $available_space -lt 5120 ]]; then
        warn "磁盘空间低于 5GB，可能影响构建"
    fi

    success "硬件检查完成"
}

# ======================== 安装基础依赖 ========================
install_base_packages() {
    header "安装基础依赖"

    apt-get update -y

    local base_packages=(
        curl
        wget
        git
        unzip
        gnupg
        lsb-release
        ca-certificates
        apt-transport-https
        software-properties-common
        build-essential
        python3
    )

    apt-get install -y "${base_packages[@]}"
    success "基础依赖安装完成"
}

# ======================== 安装 Node.js 24 ========================
install_nodejs() {
    header "安装 Node.js $NODE_MAJOR"

    if command -v node &>/dev/null && node --version | grep -q "^v${NODE_MAJOR}."; then
        info "Node.js $NODE_MAJOR 已安装，跳过"
        node --version
        return
    fi

    # 使用 NodeSource 官方仓库
    curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash -

    apt-get install -y nodejs
    success "Node.js $(node --version) 安装完成"

    # 验证 npm
    npm --version
}

# ======================== 安装 pnpm ========================
install_pnpm() {
    header "安装 pnpm"

    if command -v pnpm &>/dev/null; then
        info "pnpm 已安装: $(pnpm --version)"
        return
    fi

    corepack enable
    corepack prepare pnpm@latest --activate
    pnpm --version
    success "pnpm 安装完成"
}

# ======================== 安装 PostgreSQL ========================
install_postgres() {
    header "安装 PostgreSQL"

    if ! $INSTALL_POSTGRES; then
        info "跳过 PostgreSQL 安装"
        return
    fi

    if command -v postgres &>/dev/null; then
        info "PostgreSQL 已安装，跳过"
        return
    fi

    # 添加 PostgreSQL 官方仓库
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
        > /etc/apt/sources.list.d/postgresql.list

    apt-get update -y
    apt-get install -y postgresql-17 pgadmin4 postgresql-17-pgvector

    # 启动 PostgreSQL
    systemctl enable postgresql
    systemctl start postgresql

    # 配置数据库和用户
    local db_name="kuest"
    local db_user="kuest"
    local db_pass="${POSTGRES_PASSWORD:-$(openssl rand -base64 16)}"

    info "创建数据库: $db_name"
    su - postgres -c "psql -c \"CREATE USER $db_user WITH PASSWORD '$db_pass';\"" 2>/dev/null || true
    su - postgres -c "psql -c \"CREATE DATABASE $db_name OWNER $db_user;\"" 2>/dev/null || true
    su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;\"" 2>/dev/null || true

    # 保存数据库密码
    echo "$db_pass" > /opt/kuest_db_password.txt
    chmod 600 /opt/kuest_db_password.txt

    success "PostgreSQL 安装完成"
    info "数据库密码已保存至 /opt/kuest_db_password.txt"
}

# ======================== 安装 Caddy 反向代理 ========================
install_caddy() {
    header "安装 Caddy"

    if ! $INSTALL_CADDY; then
        info "跳过 Caddy 安装"
        return
    fi

    if [[ -z "$APP_DOMAIN" ]]; then
        warn "APP_DOMAIN 未设置，跳过 Caddy 安装"
        return
    fi

    curl -fsSL https://caddy.dev/cover | bash 2>/dev/null || true

    apt-get install -y caddy

    # 配置 Caddyfile
    cat > /etc/caddy/Caddyfile <<CADDYFILE
${APP_DOMAIN} {
    reverse_proxy localhost:${APP_PORT}

    encode gzip

    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
    }

    file_server
}
CADDYFILE

    systemctl enable caddy
    systemctl start caddy
    success "Caddy 安装完成 (域名: $APP_DOMAIN)"
}

# ======================== 创建运行用户 ========================
create_app_user() {
    header "创建应用用户"

    if id "$APP_USER" &>/dev/null; then
        info "用户 $APP_USER 已存在"
        return
    fi

    useradd --system \
        --home-dir "$INSTALL_DIR" \
        --shell /bin/bash \
        --groups www-data \
        "$APP_USER"

    success "用户 $APP_USER 创建完成"
}

# ======================== 克隆/安装项目 ========================
install_project() {
    header "安装项目代码"

    # 创建安装目录
    mkdir -p "$INSTALL_DIR"
    chown "$APP_USER":"$APP_USER" "$INSTALL_DIR"

    if [[ -d "$INSTALL_DIR/.git" ]]; then
        info "项目已安装，执行更新..."
        cd "$INSTALL_DIR"
        git pull || warn "Git pull 失败，尝试重新克隆"

        # 重新安装依赖
        install_dependencies
        build_project
        return
    fi

    # 克隆项目
    if [[ -n "$GITHUB_REPO" ]]; then
        info "从 $GITHUB_REPO 克隆项目..."
        git clone "$GITHUB_REPO" "$INSTALL_DIR"
    else
        # 如果是本地仓库，直接复制代码
        local src_dir
        src_dir="$(dirname "${BASH_SOURCE[0]}")/../.."
        if [[ -d "$src_dir/.git" ]]; then
            info "从本地仓库复制代码..."
            cp -r "$src_dir" "$INSTALL_DIR"
            # 清理 node_modules 和 .next
            rm -rf "$INSTALL_DIR/node_modules" "$INSTALL_DIR/.next" 2>/dev/null || true
        else
            error "未找到 Git 仓库，请设置 GITHUB_REPO 变量"
            exit 1
        fi
    fi

    chown -R "$APP_USER":"$APP_USER" "$INSTALL_DIR"
    success "项目代码安装完成"
}

# ======================== 安装依赖 ========================
install_dependencies() {
    header "安装项目依赖"

    cd "$INSTALL_DIR"

    # 启用 corepack
    corepack enable

    # 安装 pnpm 依赖
    pnpm install --frozen-lockfile

    success "依赖安装完成"
}

# ======================== 构建项目 ========================
build_project() {
    header "构建项目"

    cd "$INSTALL_DIR"

    # 设置环境变量
    export NODE_ENV=production
    export NEXT_TELEMETRY_DISABLED=1

    # 执行构建
    pnpm build

    success "项目构建完成"
}

# ======================== 创建环境变量文件 ========================
create_env_file() {
    header "创建环境变量"

    local env_file="$INSTALL_DIR/.env"

    if [[ -f "$env_file" ]]; then
        warn ".env 文件已存在，跳过创建"
        return
    fi

    # 生成随机密钥
    local secret_key
    secret_key=$(openssl rand -base64 32)

    # 获取数据库密码
    local db_pass=""
    if [[ -f /opt/kuest_db_password.txt ]]; then
        db_pass=$(cat /opt/kuest_db_password.txt)
    fi

    # 创建 .env 文件
    cat > "$env_file" <<ENVFILE
# ========================
# Kuest Prediction Market 环境变量
# ========================

# --- 站点配置 ---
SITE_URL=http://localhost:${APP_PORT}
# 如果有域名，请取消下面这行并修改为实际域名
# SITE_URL=https://your-domain.com

# --- 数据库配置 (PostgreSQL) ---
# 如果使用远程数据库（Supabase），请替换为远程连接字符串
DATABASE_URL=postgresql://${db_user:-kuest}:${db_pass:-placeholder}@localhost:5432/${db_name:-kuest}
DIRECT_URL=postgresql://${db_user:-kuest}:${db_pass:-placeholder}@localhost:5432/${db_name:-kuest}

# --- Better Auth 配置 ---
BETTER_AUTH_SECRET=${secret_key}
BETTER_AUTH_URL=http://localhost:${APP_PORT}

# --- Web3 / Polygon 配置 ---
NEXT_PUBLIC_CHAIN_ID=137
NEXT_PUBLIC_NETWORK=polygon

# --- CLOB (Central Limit Order Book) ---
NEXT_PUBLIC_CLOB_URL=https://clob.polymarket.com
NEXT_PUBLIC_CLOB_BASE_URL=/clob

# --- Sentry 配置 (可选) ---
# SENTRY_AUTH_TOKEN=your_sentry_token

# --- AWS S3 配置 (可选) ---
# AWS_REGION=us-east-1
# AWS_ACCESS_KEY_ID=your_access_key
# AWS_SECRET_ACCESS_KEY=your_secret_key
# AWS_BUCKET_NAME=your_bucket_name

# --- Sumsub KYC (可选) ---
# SUMSUB_APP_TOKEN=your_sumsub_token
# SUMSUB_SDK_URL=https://api.sumsub.com

# --- Li.Fi 配置 (可选) ---
# LIFI_PROVIDER_URL=https://li.quest/v1

# --- 其他 ---
NODE_ENV=production
ENVFILE

    chown "$APP_USER":"$APP_USER" "$env_file"
    success "环境变量文件已创建: $env_file"
    info "请编辑 $env_file 以匹配您的实际配置"
}

# ======================== 创建 Systemd 服务 ========================
create_systemd_service() {
    header "创建 Systemd 服务"

    local service_file="/etc/systemd/system/kuest.service"

    cat > "$service_file" <<SERVICE
[Unit]
Description=Kuest Prediction Market
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=${APP_USER}
Group=${APP_USER}
WorkingDirectory=${INSTALL_DIR}
Environment=NODE_ENV=production
Environment=PORT=${APP_PORT}
Environment=HOSTNAME=0.0.0.0
Environment=NEXT_TELEMETRY_DISABLED=1

# 重载环境变量文件
EnvironmentFile=${INSTALL_DIR}/.env

# 重启策略
Restart=always
RestartSec=10
StartLimitInterval=120
StartLimitBurst=5

# 日志
StandardOutput=journal
StandardError=journal
SyslogIdentifier=kuest

# 安全增强
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=${INSTALL_DIR}
CapabilityBoundingSet=NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
SERVICE

    # 重新加载 systemd
    systemctl daemon-reload
    systemctl enable kuest

    success "Systemd 服务已创建: kuest.service"
}

# ======================== 启动服务 ========================
start_service() {
    header "启动服务"

    # 启动应用
    systemctl start kuest

    # 等待服务就绪
    info "等待服务启动..."
    local retries=30
    while [[ $retries -gt 0 ]]; do
        if curl -sf "http://localhost:${APP_PORT}" &>/dev/null; then
            success "服务启动成功！"
            info "访问地址: http://localhost:${APP_PORT}"
            return
        fi
        sleep 2
        retries=$((retries - 1))
    done

    warn "服务可能在启动中，请检查状态:"
    warn "  systemctl status kuest"
    warn "  journalctl -u kuest -f"
}

# ======================== 防火墙配置 ========================
configure_firewall() {
    header "配置防火墙"

    if command -v ufw &>/dev/null; then
        ufw allow ${APP_PORT}/tcp 2>/dev/null || true
        ufw allow ssh 2>/dev/null || true

        if ! ufw status | grep -q "Status: active"; then
            info "UFW 未启用，如需启用请运行:"
            info "  ufw enable"
        fi

        success "UFW 防火墙配置完成"
    else
        info "UFW 未安装，跳过防火墙配置"
        info "如果使用 iptables，请手动开放端口 ${APP_PORT}"
    fi
}

# ======================== 验证安装 ========================
verify_install() {
    header "验证安装"

    local errors=0

    # 检查 Node.js
    if command -v node &>/dev/null; then
        success "Node.js: $(node --version)"
    else
        error "Node.js 未安装"
        ((errors++))
    fi

    # 检查 pnpm
    if command -v pnpm &>/dev/null; then
        success "pnpm: $(pnpm --version)"
    else
        error "pnpm 未安装"
        ((errors++))
    fi

    # 检查 PostgreSQL
    if $INSTALL_POSTGRES && command -v postgres &>/dev/null; then
        success "PostgreSQL: 已安装"
    elif ! $INSTALL_POSTGRES; then
        info "PostgreSQL: 跳过"
    fi

    # 检查服务状态
    if systemctl is-active --quiet kuest 2>/dev/null; then
        success "Kuest 服务: 运行中"
    else
        warn "Kuest 服务: 未运行"
        systemctl status kuest --no-pager 2>/dev/null || true
    fi

    # 检查构建产物
    if [[ -d "$INSTALL_DIR/.next" ]]; then
        success "构建产物: 存在"
    else
        error "构建产物: 不存在，请检查构建日志"
        ((errors++))
    fi

    if [[ $errors -eq 0 ]]; then
        success "所有检查通过！"
    else
        error "存在 $errors 项检查失败"
    fi
}

# ======================== 显示管理命令 ========================
show_help() {
    header "管理命令"

    cat <<HELP

${BOLD}Kuest Prediction Market 安装完成！${NC}

${BOLD}常用管理命令:${NC}
  systemctl status kuest           # 查看服务状态
  journalctl -u kuest -f           # 查看实时日志
  systemctl restart kuest          # 重启服务
  systemctl stop kuest             # 停止服务

${BOLD}环境管理:${NC}
  编辑环境变量: vim ${INSTALL_DIR}/.env
  重新构建:     cd ${INSTALL_DIR} && pnpm build

${BOLD}数据库管理:${NC}
  sudo -u postgres psql -d kuest   # 进入 PostgreSQL
  sudo -u postgres psql -c '\\l'    # 查看所有数据库

${BOLD}备份:${NC}
  pg_dump -U kuest kuest > backup.sql  # 数据库备份
  tar -czf kuest-backup.tar.gz ${INSTALL_DIR}  # 项目备份

${BOLD}更新:${NC}
  cd ${INSTALL_DIR} && git pull && pnpm install --frozen-lockfile && pnpm build
  systemctl restart kuest

HELP
}

# ======================== 主函数 ========================
main() {
    header "Kuest Prediction Market - Ubuntu 一键安装脚本"

    info "安装目录: $INSTALL_DIR"
    info "应用端口: $APP_PORT"
    info "安装类型: $INSTALL_TYPE"

    # 执行安装流程
    check_root
    check_os
    check_hardware
    install_base_packages
    install_nodejs
    install_pnpm
    install_postgres
    create_app_user
    install_project
    install_dependencies
    create_env_file
    build_project
    install_caddy
    create_systemd_service
    configure_firewall

    # 询问是否启动服务
    info ""
    info "是否现在启动 Kuest 服务？(y/N)"
    read -r start_service_response
    if [[ "${start_service_response:-N}" == [Yy]* ]]; then
        start_service
    else
        info "稍后可手动启动: systemctl start kuest"
    fi

    verify_install
    show_help
}

# 执行主函数
main "$@"
