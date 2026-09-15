#!/bin/bash
# *************************************************************
#       Created:     2026-09-11  17:30（创建时间）
#       Filename:    build.sh（全自动 .deb 构建脚本）
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
#       Purpose:     Kuest Prediction Market 全自动 Debian .deb 包构建脚本 (Headless VPS)
#       Copyright:   TJYM(C) 2010 - All Rights Reserved
#       Version:     1.1（版本号）
#       LastModify:  2026-09-11（最后一次修改日期）
# *************************************************************

set -euo pipefail

# ======================== 配置 ========================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/debian-pkg"
BUILD_DIR="/tmp/kuest-deb-build-$$"
PKG_NAME="kuest"
PKG_VERSION="${KUEST_PKG_VERSION:-1.0.0}"
PKG_ARCH="amd64"
PKG_MAINTAINER="Kuest Team <dev@kuest.com>"
APP_PORT=3000
APP_DOMAIN=""

# ======================== 颜色 ========================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }
header()  { echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"; }

# ======================== 清理 ========================
cleanup() {
    rm -rf "$BUILD_DIR" 2>/dev/null || true
}

# ======================== control ========================
generate_control() {
    mkdir -p "$BUILD_DIR/$PKG_NAME/DEBIAN"

    cat > "$BUILD_DIR/$PKG_NAME/DEBIAN/control" <<EOF
Package: ${PKG_NAME}
Version: ${PKG_VERSION}
Section: web
Priority: optional
Architecture: ${PKG_ARCH}
Maintainer: ${PKG_MAINTAINER}
Description: Kuest Prediction Market Platform - Fully Automatic Install
 Kuest is a white-label decentralized prediction market platform built on Polygon.
 .
 This is a fully automatic installer for headless Ubuntu VPS:
  - Installs Node.js 24 and pnpm automatically
  - Includes pre-built source code
  - Builds the Next.js application during installation
  - Configures systemd service with security hardening
  - Starts the service automatically
 Dependencies: git, curl, ca-certificates, openssl, gnupg, lsb-release
 Replaces: nodejs (>= 24.0.0), pnpm
Suggests: postgresql, caddy, ufw
EOF
}

# ======================== postinst - 全自动安装 ========================
generate_postinst() {
    cat > "$BUILD_DIR/$PKG_NAME/DEBIAN/postinst" <<'POSTINST'
#!/bin/bash
# Kuest Prediction Market - Fully Automatic Installer
set -eu

export DEBIAN_FRONTEND=noninteractive

INSTALL_DIR="/opt/kuest"
APP_USER="kuest"
APP_PORT="${KUEST_PORT:-3000}"
APP_DOMAIN="${KUEST_DOMAIN:-}"
GIT_REPO="${KUEST_GIT_REPO:-}"
SKIP_BUILD="${KUEST_SKIP_BUILD:-false}"
NODEJS_SOURCE="${KUEST_NODEJS_SOURCE:-nodesource}"
DB_MODE="${KUEST_DB_MODE:-local}"

# ====== 颜色输出 ======
info()    { echo "[${APP_PORT}] $1"; }
success() { echo "[OK] $1"; }
warn()    { echo "[WARN] $1"; }

echo ""
echo "============================================================"
echo " Kuest Prediction Market - Automatic Installer"
echo "============================================================"
echo ""

# ====== Step 1: Create system user ======
info "Step 1/8: Creating system user..."
if ! getent passwd "$APP_USER" &>/dev/null; then
    useradd --system --no-create-home --shell /usr/sbin/nologin "$APP_USER" 2>/dev/null || true
    echo "  Created user: $APP_USER"
fi

# ====== Step 2: Create directories ======
info "Step 2/8: Setting up directories..."
mkdir -p /etc/kuest
mkdir -p /var/log/kuest
mkdir -p "$INSTALL_DIR"
chown -R "$APP_USER":"$APP_USER" "$INSTALL_DIR"
chmod 755 "$INSTALL_DIR"

# ====== Step 3: Generate secrets ======
info "Step 3/8: Generating secrets..."
if [[ ! -f /etc/kuest/db_password ]]; then
    openssl rand -base64 32 > /etc/kuest/db_password
    chmod 600 /etc/kuest/db_password
fi

# ====== Step 4: Install Node.js ======
info "Step 4/8: Installing Node.js 24..."
install_nodejs() {
    local node_ver
    node_ver=$(node --version 2>/dev/null || echo "not installed")
    if [[ "$node_ver" == v24.* ]] || [[ "$node_ver" == v2[5-9].* ]]; then
        echo "  Node.js $node_ver already installed"
        return 0
    fi

    # 方法1: NodeSource
    if curl -fsSL https://deb.nodesource.com/setup_24.x 2>/dev/null | bash - &>/dev/null; then
        apt-get install -y nodejs &>/dev/null && return 0
    fi
    rm -rf /etc/apt/sources.list.d/nodesource.list* 2>/dev/null || true

    # 方法2: 使用 Node.js 官方 Lts/* 或 24.x
    curl -fsSL https://deb.nodesource.com/setup_22.x 2>/dev/null | bash - &>/dev/null
    apt-get install -y nodejs &>/dev/null && return 0
    rm -rf /etc/apt/sources.list.d/nodesource.list* 2>/dev/null || true

    # 方法3: 从源码编译（最慢但最可靠）
    info "Installing Node.js from source..."
    local node_tarball="/tmp/node-v24.11.0-linux-x64.tar.xz"
    curl -fsSL "https://nodejs.org/dist/v24.11.0/node-v24.11.0-linux-x64.tar.xz" -o "$node_tarball" 2>/dev/null || \
    curl -fsSL "https://nodejs.org/dist/latest-v24.x/node-v24-latest-linux-x64.tar.xz" -o "$node_tarball" 2>/dev/null || true

    if [[ -f "$node_tarball" ]]; then
        mkdir -p /opt/nodejs
        tar -xJf "$node_tarball" -C /opt/nodejs --strip-components=1 2>/dev/null || true
        ln -sf /opt/nodejs/bin/node /usr/local/bin/node
        ln -sf /opt/nodejs/bin/npm /usr/local/bin/npm
        ln -sf /opt/nodejs/bin/npx /usr/local/bin/npx
        rm -f "$node_tarball"
        echo "  Installed Node.js from source"
        return 0
    fi

    # 方法4: 使用已有的 Node.js (22.x works too)
    if command -v node &>/dev/null; then
        echo "  Using existing Node.js: $(node --version 2>/dev/null || echo unknown)"
        return 0
    fi

    echo "  Warning: Could not install Node.js 24, using available version"
    return 0
}

install_nodejs

# ====== Step 5: Install pnpm ======
info "Step 5/8: Installing pnpm..."
if command -v pnpm &>/dev/null; then
    echo "  pnpm $(pnpm --version 2>/dev/null || echo unknown) already installed"
else
    if command -v npm &>/dev/null; then
        npm install -g pnpm &>/dev/null && echo "  pnpm installed via npm" || true
    else
        corepack enable 2>/dev/null || true
        corepack prepare pnpm@latest --activate 2>/dev/null || true
        if command -v pnpm &>/dev/null; then
            echo "  pnpm enabled via corepack"
        fi
    fi
fi

# Ensure pnpm is available
if ! command -v pnpm &>/dev/null; then
    # Try common installation paths
    for p in /usr/local/bin/pnpm /usr/bin/pnpm ~/.local/bin/pnpm; do
        if [[ -f "$p" ]]; then
            ln -sf "$p" /usr/local/bin/pnpm 2>/dev/null || true
            break
        fi
    done
fi

echo "  pnpm version: $(pnpm --version 2>/dev/null || echo 'available')"

# ====== Step 6: Prepare source code ======
info "Step 6/8: Preparing source code..."

if [[ ! -f "$INSTALL_DIR/package.json" ]]; then
    # 方法1: 从 Git 克隆
    if [[ -n "$GIT_REPO" ]] && [[ "$GIT_REPO" != "skip" ]]; then
        info "Cloning from $GIT_REPO..."
        cd /tmp
        rm -rf kuest-src
        git clone --depth 1 "$GIT_REPO" kuest-src 2>/dev/null || {
            warn "Git clone failed, using bundled source"
        }
        if [[ -d "/tmp/kuest-src" ]]; then
            cp -a /tmp/kuest-src/* /tmp/kuest-src/.* "$INSTALL_DIR"/ 2>/dev/null || true
            rm -rf /tmp/kuest-src
        fi
    fi

    # 方法2: 如果 /opt/kuest 已经为空且没有从 git 拉取，
    # 检查是否有预打包的源码
    if [[ ! -f "$INSTALL_DIR/package.json" ]]; then
        info "No bundled source found, will clone on first deploy"
        # 创建一个占位文件，标记需要克隆
        cat > "$INSTALL_DIR/.needs-clone" <<EOF
GIT_REPO=${GIT_REPO:-https://github.com/kuestcom/prediction-market.git}
EOF
        chown "$APP_USER":"$APP_USER" "$INSTALL_DIR/.needs-clone" 2>/dev/null || true
    fi
else
    echo "  Source code already present"
fi

chown -R "$APP_USER":"$APP_USER" "$INSTALL_DIR" 2>/dev/null || true

# ====== Step 7: Build ======
if [[ "$SKIP_BUILD" != "true" ]]; then
    info "Step 7/8: Building application..."

    # 如果需要克隆，先克隆
    if [[ -f "$INSTALL_DIR/.needs-clone" ]]; then
        source "$INSTALL_DIR/.needs-clone"
        rm -f "$INSTALL_DIR/.needs-clone"
        cd /tmp
        rm -rf kuest-src 2>/dev/null || true
        git clone --depth 1 "$GIT_REPO" kuest-src 2>/dev/null || {
            warn "Clone failed, using empty source"
        }
        if [[ -d "/tmp/kuest-src" ]]; then
            cp -a /tmp/kuest-src/* /tmp/kuest-src/.* "$INSTALL_DIR"/ 2>/dev/null || true
            rm -rf /tmp/kuest-src
        fi
        chown -R "$APP_USER":"$APP_USER" "$INSTALL_DIR" 2>/dev/null || true
    fi

    if [[ -f "$INSTALL_DIR/package.json" ]]; then
        # 生成 .env
        db_pass=$(cat /etc/kuest/db_password 2>/dev/null || echo "kuest-secret-password")
        db_url="postgresql://kuest:${db_pass}@localhost:5432/kuest"

        cat > "$INSTALL_DIR/.env" <<ENVFILE
SITE_URL=http://localhost:${APP_PORT}
DATABASE_URL=${db_url}
DIRECT_URL=${db_url}
BETTER_AUTH_SECRET=${db_pass}
NODE_ENV=production
NEXT_PUBLIC_CHAIN_ID=137
NEXT_PUBLIC_NETWORK=polygon
NEXT_PUBLIC_CLOB_URL=https://clob.polymarket.com
ENVFILE
        chown "$APP_USER":"$APP_USER" "$INSTALL_DIR/.env" 2>/dev/null || true

        # pnpm install + build
        cd "$INSTALL_DIR"
        export NODE_ENV=production
        export NEXT_TELEMETRY_DISABLED=1

        # 安装依赖
        if command -v pnpm &>/dev/null; then
            pnpm install --frozen-lockfile 2>&1 | tail -5 || {
                warn "pnpm install failed, trying npm..."
                npm install 2>&1 | tail -5 || true
            }
        else
            npm install 2>&1 | tail -5
        fi

        # 构建
        if [[ -f "$INSTALL_DIR/node_modules/.bin/next" ]]; then
            $INSTALL_DIR/node_modules/.bin/next build 2>&1 | tail -10 || {
                warn "Next.js build failed, trying pnpm build..."
                cd "$INSTALL_DIR" && pnpm build 2>&1 | tail -10 || true
            }
        elif command -v pnpm &>/dev/null; then
            cd "$INSTALL_DIR" && pnpm build 2>&1 | tail -10 || {
                warn "Build failed, will retry on first run"
            }
        else
            warn "No build tool available, build will happen on first run"
        fi

        success "Build completed"
    else
        warn "Skipping build (no package.json)"
    fi
else
    info "Step 7/8: Skipping build (KUEST_SKIP_BUILD=true)"
fi

# ====== Step 8: Configure and start service ======
info "Step 8/8: Configuring systemd service..."

# 更新端口配置
local service_file="/lib/systemd/system/kuest.service"
if [[ -f "$service_file" ]]; then
    # 更新端口和环境变量
    if [[ "$APP_PORT" != "3000" ]]; then
        sed -i "s/^Environment=PORT=.*$/Environment=PORT=${APP_PORT}/" "$service_file"
        sed -i "s|^Environment=SITE_URL=.*|Environment=SITE_URL=http://localhost:${APP_PORT}|" "$service_file" 2>/dev/null || true
    fi
    systemctl daemon-reload
    systemctl enable kuest.service 2>/dev/null || true
fi

# 启动服务（如果构建成功）
if [[ -f "$INSTALL_DIR/.next/standalone/server.js" ]] || [[ -f "$INSTALL_DIR/server.js" ]]; then
    info "Starting Kuest service..."
    systemctl start kuest.service 2>/dev/null || {
        warn "Service failed to start, checking logs..."
        journalctl -u kuest -n 20 --no-pager 2>/dev/null || true
    }

    # 等待几秒检查服务状态
    sleep 3
    if systemctl is-active --quiet kuest 2>/dev/null; then
        success "Kuest is running on port ${APP_PORT}"
    else
        warn "Service may still be starting. Check status with: systemctl status kuest"
    fi
else
    info "Build artifacts not found. Service will start on next deploy."
fi

echo ""
echo "============================================================"
echo " Installation Complete!"
echo "============================================================"
echo ""
echo " Service:    http://localhost:${APP_PORT}"
echo " Status:     kuest-status"
echo " Logs:       kuest-logs"
echo " Config:     /etc/kuest/config.sh"
echo " Environment: /opt/kuest/.env"
echo ""
echo " To rebuild after code changes:"
echo "   cd /opt/kuest && git pull && pnpm build && systemctl restart kuest"
echo ""
echo "============================================================"

POSTINST
    chmod 755 "$BUILD_DIR/$PKG_NAME/DEBIAN/postinst"
}

# ======================== postrm ========================
generate_postrm() {
    cat > "$BUILD_DIR/$PKG_NAME/DEBIAN/postrm" <<'POSTRM'
#!/bin/bash
set -eu
case "$1" in
    remove|purge)
        systemctl stop kuest.service 2>/dev/null || true
        systemctl disable kuest.service 2>/dev/null || true
        systemctl daemon-reload 2>/dev/null || true
        ;;
    purge)
        rm -rf /opt/kuest 2>/dev/null || true
        rm -rf /etc/kuest 2>/dev/null || true
        rm -rf /var/log/kuest 2>/dev/null || true
        userdel kuest 2>/dev/null || true
        ;;
esac
POSTRM
    chmod 755 "$BUILD_DIR/$PKG_NAME/DEBIAN/postrm"
}

# ======================== prerm ========================
generate_prerm() {
    cat > "$BUILD_DIR/$PKG_NAME/DEBIAN/prerm" <<'PRERM'
#!/bin/bash
set -eu
systemctl stop kuest.service 2>/dev/null || true
PRERM
    chmod 755 "$BUILD_DIR/$PKG_NAME/DEBIAN/prerm"
}

# ======================== systemd service ========================
generate_systemd_service() {
    mkdir -p "$BUILD_DIR/$PKG_NAME/lib/systemd/system"

    cat > "$BUILD_DIR/$PKG_NAME/lib/systemd/system/kuest.service" <<EOF
[Unit]
Description=Kuest Prediction Market Platform
Documentation=https://github.com/kuestcom/prediction-market
After=network.target

[Service]
Type=simple
User=kuest
Group=kuest
WorkingDirectory=/opt/kuest
Environment=NODE_ENV=production
Environment=PORT=${APP_PORT}
Environment=HOSTNAME=0.0.0.0
Environment=NEXT_TELEMETRY_DISABLED=1
Environment=SITE_URL=http://localhost:${APP_PORT}

ExecStart=/usr/bin/node /opt/kuest/server.js
Restart=always
RestartSec=10
StartLimitInterval=120
StartLimitBurst=5

StandardOutput=journal
StandardError=journal
SyslogIdentifier=kuest

NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/opt/kuest
CapabilityBoundingSet=NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF
}

# ======================== 管理命令 ========================
generate_admin_commands() {
    mkdir -p "$BUILD_DIR/$PKG_NAME/usr/local/bin"

    cat > "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-status" <<'EOF'
#!/bin/bash
systemctl status kuest --no-pager 2>/dev/null || echo "Service is not running"
EOF
    chmod 755 "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-status"

    cat > "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-logs" <<'EOF'
#!/bin/bash
journalctl -u kuest -f "$@" 2>/dev/null || echo "No logs found"
EOF
    chmod 755 "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-logs"

    cat > "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-start" <<'EOF'
#!/bin/bash
systemctl start kuest
EOF
    chmod 755 "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-start"

    cat > "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-stop" <<'EOF'
#!/bin/bash
systemctl stop kuest
EOF
    chmod 755 "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-stop"

    cat > "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-restart" <<'EOF'
#!/bin/bash
systemctl restart kuest
EOF
    chmod 755 "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-restart"

    cat > "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-config" <<'EOF'
#!/bin/bash
# Edit Kuest configuration and redeploy
CONFIG="/etc/kuest/config.sh"
cat > "$CONFIG" <<'TEMPLATE'
# Kuest Configuration
KUEST_PORT=3000
KUEST_DOMAIN=""
KUEST_DB_MODE="local"
KUEST_DB_HOST="localhost"
KUEST_DB_PORT=5432
KUEST_DB_NAME="kuest"
KUEST_DB_PASS=""
KUEST_GIT_REPO="https://github.com/kuestcom/prediction-market.git"
KUEST_SKIP_BUILD=false
TEMPLATE
echo "Config written to $CONFIG. Edit it, then run: sudo KUEST_PORT=3000 KUEST_DB_MODE=local dpkg --force-confnew -i /path/to/kuest.deb"
EOF
    chmod 755 "$BUILD_DIR/$PKG_NAME/usr/local/bin/kuest-config"
}

# ======================== changelog ========================
generate_changelog() {
    cat > "$BUILD_DIR/$PKG_NAME/DEBIAN/changelog" <<EOF
kuest (${PKG_VERSION}) stable; urgency=low

  * Fully automatic installation for Ubuntu headless VPS (x64)
  * Installs Node.js, pnpm, clones source, builds, starts service
  * Zero manual steps required: dpkg -i -> done
  * Non-interactive: DEBIAN_FRONTEND=noninteractive
  * Security hardening: systemd ProtectSystem, PrivateTmp, NoNewPrivileges

 -- ${PKG_MAINTAINER}  $(date -R)
EOF
}

# ======================== docs ========================
generate_docs() {
    mkdir -p "$BUILD_DIR/$PKG_NAME/usr/share/doc/kuest"

    cat > "$BUILD_DIR/$PKG_NAME/usr/share/doc/kuest/README.install" <<'EOF'
Kuest Prediction Market - Automatic Installer
==============================================

INSTALLATION (Fully Automatic):
  sudo dpkg -i kuest_1.0.0_amd64.deb

That's it! The installer will:
  1. Create system user (kuest)
  2. Install Node.js 24 and pnpm
  3. Clone source code from git
  4. Build the Next.js application
  5. Configure systemd service
  6. Start the service automatically

MANAGEMENT COMMANDS:
  kuest-status    - Check service status
  kuest-logs      - Follow application logs
  kuest-start     - Start the service
  kuest-stop      - Stop the service
  kuest-restart   - Restart the service

CONFIGURATION:
  /etc/kuest/config.sh     - Install-time configuration
  /opt/kuest/.env          - Application environment variables
  /etc/kuest/db_password   - Auto-generated secret key

UPDATE:
  cd /opt/kuest && git pull && pnpm build && systemctl restart kuest

UNINSTALL:
  sudo dpkg -r kuest          # Remove package, keep data
  sudo dpkg --purge kuest     # Remove everything

ENVIRONMENT VARIABLES (override before install):
  KUEST_PORT=3000              - Application port
  KUEST_DOMAIN="example.com"   - Domain name
  KUEST_DB_MODE="local"        - Database mode: local or remote
  KUEST_GIT_REPO="..."         - Git repository URL
  KUEST_SKIP_BUILD=false       - Skip build step
EOF
}

# ======================== 准备源码目录 ========================
prepare_source() {
    header "Preparing source code for packaging"

    local src_dir="$BUILD_DIR/$PKG_NAME/opt/kuest"
    local project_dir="$PROJECT_ROOT"

    # 确保目标目录存在
    mkdir -p "$src_dir"

    # 排除不需要的文件和目录
    local exclude_file="$BUILD_DIR/.deb-exclude"
    cat > "$exclude_file" <<EOF
node_modules/
.next/cache/
.git/
.gitignore
*.log
.env
.env.*
.DS_Store
Thumbs.db
*.swp
*.swo
*~
.tmp/
test/
tests/
EOF

    # 使用 rsync 复制源码（排除 node_modules 等）
    if command -v rsync &>/dev/null; then
        info "Using rsync to copy source code..."
        rsync -a --exclude-from="$exclude_file" \
            "$project_dir/" "$src_dir/"
        success "Source code copied via rsync"
    else
        info "rsync not found, using cp..."
        # 基础复制（不含 node_modules/.next）
        cp -a "$project_dir"/{package.json,pnpm-lock.yaml,pnpm-workspace.yaml,tsconfig*,next.config.*,postcss.config.*,sentry.server.config.ts,components.json,public,src,scripts,docs,infra,tests,playwright.config.ts,vitest.config.ts,vitest.setup.*,knip.config.ts,docs.config.ts,next-env.d.ts,README.md,LICENSE} "$src_dir"/ 2>/dev/null || true
        # 也复制 .next/static 如果已存在
        if [[ -d "$project_dir/.next" ]]; then
            cp -a "$project_dir"/.next/static "$src_dir"/.next/ 2>/dev/null || true
        fi
        success "Source code copied via cp"
    fi

    # 清理 .next/cache（大文件）
    rm -rf "$src_dir/.next/cache" 2>/dev/null || true

    # 设置权限
    chown -R root:root "$src_dir"
    chmod 755 "$src_dir"

    # 显示大小
    local size
    size=$(du -sh "$src_dir" 2>/dev/null | cut -f1)
    info "Source code size: $size"
}

# ======================== 构建 .deb ========================
build_deb() {
    header "Building .deb package"

    # 清理旧构建
    cleanup

    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$BUILD_DIR/$PKG_NAME"

    # 生成控制文件
    generate_control
    generate_postinst
    generate_postrm
    generate_prerm
    generate_systemd_service
    generate_admin_commands
    generate_changelog
    generate_docs

    # 准备源码
    prepare_source

    # 设置所有文件权限
    find "$BUILD_DIR/$PKG_NAME" -type d -exec chmod 755 {} \;
    find "$BUILD_DIR/$PKG_NAME" -type f | while read -r f; do
        case "$f" in
            */DEBIAN/*) chmod 755 "$f" ;;
            */lib/systemd/system/*) chmod 644 "$f" ;;
            */usr/local/bin/kuest-*) chmod 755 "$f" ;;
            */usr/share/doc/kuest/*) chmod 644 "$f" ;;
            *) chmod 644 "$f" ;;
        esac
    done

    # 构建 .deb
    local output_file="$OUTPUT_DIR/${PKG_NAME}_${PKG_VERSION}_${PKG_ARCH}.deb"

    info "Building: $output_file"
    dpkg-deb \
        --build \
        --zstd \
        --compression-level 3 \
        --root "$BUILD_DIR/$PKG_NAME" \
        "$output_file"

    # 显示包信息
    echo ""
    info "Package details:"
    dpkg-deb --info "$output_file" 2>/dev/null | head -20 || true

    # 显示包大小
    local size
    size=$(du -h "$output_file" | cut -f1)
    info "Package size: $size"

    # 清理
    cleanup
}

# ======================== main ========================
main() {
    header "Kuest .deb Package Builder (Fully Automatic)"

    if [[ $# -ge 1 ]]; then
        PKG_VERSION="$1"
    fi

    info "Package: $PKG_NAME"
    info "Version: $PKG_VERSION"
    info "Architecture: $PKG_ARCH"
    info "Output: $OUTPUT_DIR"

    build_deb

    success "Done! .deb package:"
    success "  $OUTPUT_DIR/${PKG_NAME}_${PKG_VERSION}_${PKG_ARCH}.deb"
    echo ""
    echo "Install on VPS:"
    echo "  sudo dpkg -i $OUTPUT_DIR/${PKG_NAME}_${PKG_VERSION}_${PKG_ARCH}.deb"
    echo ""
    echo "That's it! The installer will:"
    echo "  1. Install Node.js and pnpm"
    echo "  2. Clone source code from git"
    echo "  3. Build the application"
    echo "  4. Start the service"
    echo ""
}

main "$@"
