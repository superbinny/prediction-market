#!/bin/bash
# *************************************************************
#       Created:     2026-09-11  16:30（创建时间）
#       Filename:    pack.sh（.deb 包一键打包脚本）
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
#       Purpose:     从项目源码目录打包 Kuest Prediction Market .deb 安装包
#       Copyright:   TJYM(C) 2010 - All Rights Reserved
#       Version:     1.1（版本号）
#       LastModify:  2026-09-11（最后一次修改日期）
# *************************************************************

set -euo pipefail

# ======================== 配置 ========================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_SCRIPT="$SCRIPT_DIR/build.sh"
OUTPUT_DIR="$SCRIPT_DIR/debian-pkg"
VERSION=""

# ======================== 颜色 ========================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }
header()  { echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"; }

# ======================== 检查依赖 ========================
check_dependencies() {
    header "检查构建依赖"

    local missing=0

    for cmd in dpkg-deb tar gzip; do
        if command -v "$cmd" &>/dev/null; then
            success "$cmd found"
        else
            error "$cmd not found, please install dpkg-dev"
            missing=$((missing + 1))
        fi
    done

    # 检查 Node.js 版本（构建时需要）
    if command -v node &>/dev/null; then
        local node_ver
        node_ver=$(node --version 2>/dev/null || echo "unknown")
        info "Node.js: $node_ver"
    else
        warn "Node.js not found (optional, for version verification)"
    fi

    if [[ $missing -gt 0 ]]; then
        error "缺少 $missing 个依赖，请安装: sudo apt-get install dpkg-dev"
        exit 1
    fi

    success "构建依赖检查通过"
}

# ======================== 获取版本号 ========================
get_version() {
    # 优先使用命令行参数
    if [[ -n "$1" ]]; then
        VERSION="$1"
        return
    fi

    # 从 package.json 读取
    local pkg_json="$PROJECT_ROOT/package.json"
    if [[ -f "$pkg_json" ]]; then
        # 尝试用 grep/sed 提取版本号（兼容无 jq 环境）
        local extracted
        extracted=$(grep '"version"' "$pkg_json" 2>/dev/null | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/' || echo "")
        if [[ -n "$extracted" ]]; then
            VERSION="$extracted"
            info "从 package.json 获取版本号: $VERSION"
            return
        fi
    fi

    # 使用默认版本号
    VERSION="1.0.0"
    warn "无法获取版本号，使用默认: $VERSION"
}

# ======================== 预处理项目文件 ========================
prepare_project() {
    header "预处理项目文件"

    info "项目目录: $PROJECT_ROOT"

    # 检查必要文件
    local required_files=(
        "package.json"
        "src/app"
        "src/lib"
    )

    for f in "${required_files[@]}"; do
        if [[ -e "$PROJECT_ROOT/$f" ]]; then
            success "Found: $f"
        else
            warn "Missing: $f (may affect package contents)"
        fi
    done

    # 清理旧的构建产物（避免将 .next 等缓存打包进去）
    info "Cleaning build artifacts..."
    rm -rf "$PROJECT_ROOT/.next/cache" 2>/dev/null || true
    rm -rf "$PROJECT_ROOT/node_modules/.cache" 2>/dev/null || true

    success "项目预处理完成"
}

# ======================== 设置环境变量 ========================
set_env() {
    # 导出版本号给 build.sh 使用
    export KUEST_PKG_VERSION="$VERSION"
}

# ======================== 构建 .deb 包 ========================
build_package() {
    header "构建 .deb 包"

    mkdir -p "$OUTPUT_DIR"

    # 运行构建脚本
    bash "$BUILD_SCRIPT" "$VERSION"

    # 检查输出
    local deb_file
    deb_file=$(find "$OUTPUT_DIR" -name "*.deb" -type f 2>/dev/null | head -1)

    if [[ -n "$deb_file" ]]; then
        local filename
        filename=$(basename "$deb_file")
        local size
        size=$(du -h "$deb_file" | cut -f1)

        success ".deb 包已生成: $deb_file"
        info "文件名: $filename"
        info "大小: $size"

        # 显示包信息
        info "包信息:"
        dpkg-deb --info "$deb_file" 2>/dev/null | head -15 || true
    else
        error "构建失败，未找到 .deb 文件"
        exit 1
    fi
}

# ======================== 安装测试 ========================
test_install() {
    header "安装测试（可选）"

    echo -e "${YELLOW}是否在测试环境安装 .deb 包? (y/N): ${NC}"
    read -r test_install_response
    if [[ "${test_install_response:-N}" == [Yy]* ]]; then
        local deb_file
        deb_file=$(find "$OUTPUT_DIR" -name "*.deb" -type f 2>/dev/null | head -1)

        if [[ -n "$deb_file" ]]; then
            info "安装测试: $deb_file"
            sudo dpkg -i "$deb_file"
            info "安装完成，请检查: systemctl status kuest"
        else
            error "未找到 .deb 文件"
        fi
    else
        info "跳过安装测试"
    fi
}

# ======================== 主函数 ========================
main() {
    header "Kuest Prediction Market - .deb 包构建工具"

    info "项目目录: $PROJECT_ROOT"
    info "输出目录: $OUTPUT_DIR"

    # 获取版本号
    get_version "${1:-}"

    # 检查依赖
    check_dependencies

    # 预处理
    prepare_project

    # 设置环境变量
    set_env

    # 构建
    build_package

    # 测试安装
    test_install

    # 输出结果
    header "构建完成"
    local deb_files
    deb_files=$(find "$OUTPUT_DIR" -name "*.deb" -type f 2>/dev/null)

    if [[ -n "$deb_files" ]]; then
        echo ""
        echo "生成的 .deb 包:"
        echo "$deb_files" | while read -r f; do
            local size
            size=$(du -h "$f" | cut -f1)
            echo "  $f ($size)"
        done
        echo ""
        echo "使用方法:"
        echo "  sudo dpkg -i <deb_file>"
        echo "  kuest-setup          # 配置向导"
        echo "  kuest-build          # 构建项目"
        echo "  systemctl start kuest  # 启动服务"
    fi
}

# 执行
main "$@"
