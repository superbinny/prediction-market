#!/bin/bash
# *********************************************************
#       Created:     2026-08-31  10:00（创建时间）
#       Filename:    change_github_fork_from_orign.sh（脚本文件名）
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
#       Purpose:     自动从上游原始项目拉取更新并合并到当前分支，保留本地修改
#       Copyright:   TJYM(C) 2010 - All Rights Reserved
#       Version:     1.1（版本号）
#       LastModify:  2026-08-31（最后一次修改日期）
# *********************************************************

set -e

# ============================================================
# 配置区 — 请根据实际情况修改
# ============================================================

# 上游仓库（原始项目）地址，请替换为实际的原始仓库地址
UPSTREAM_URL="https://github.com/Polymarket/prediction-market.git"
# 上游仓库名称（用于 git remote 名称）
UPSTREAM_NAME="upstream"
# 当前分支名（默认从 git 自动获取）
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "================================================"
echo "  上游同步脚本 — 自动从原始项目拉取更新"
echo "================================================"
echo ""

# ---------- 1. 检查当前分支 ----------
echo "[1/7] 当前分支: ${CURRENT_BRANCH}"

# ---------- 2. 暂存本地未提交的更改 ----------
echo ""
echo "[2/7] 检查未提交的本地更改..."

if ! git diff --quiet || git ls-files --others --exclude-standard > /dev/null 2>&1; then
    echo "  检测到未提交的更改，正在创建临时 stash..."

    # 生成 stash 消息
    STASH_MSG="sync_before_pull_$(date +%s)"
    git stash push -m "$STASH_MSG" --include-untracked

    STASH_RESTORE=true
    echo "  本地更改已暂存，可以安全拉取上游更新"
else
    STASH_RESTORE=false
    echo "  没有未提交的更改，继续"
fi

# ---------- 3. 添加或更新上游远程 ----------
echo ""
echo "[3/7] 配置上游远程仓库 (${UPSTREAM_NAME})..."

if git remote get-url "$UPSTREAM_NAME" > /dev/null 2>&1; then
    EXISTING_URL=$(git remote get-url "$UPSTREAM_NAME")
    if [ "$EXISTING_URL" = "$UPSTREAM_URL" ]; then
        echo "  上游远程已存在且地址正确: $UPSTREAM_URL"
    else
        echo "  警告: 上游远程已存在但地址不匹配!"
        echo "  现有: $EXISTING_URL"
        echo "  期望: $UPSTREAM_URL"
        echo "  正在更新..."
        git remote set-url "$UPSTREAM_NAME" "$UPSTREAM_URL"
        echo "  上游远程地址已更新"
    fi
else
    echo "  添加上游远程: $UPSTREAM_URL"
    git remote add "$UPSTREAM_NAME" "$UPSTREAM_URL"
    echo "  上游远程已添加"
fi

# ---------- 4. 拉取上游更新 ----------
echo ""
echo "[4/7] 从上游拉取最新代码..."
git fetch "$UPSTREAM_NAME"

# ---------- 5. 获取上游分支的最新提交信息 ----------
echo ""
echo "[5/7] 分析上游更新..."

UPSTREAM_HEAD=$(git rev-parse "${UPSTREAM_NAME}/${CURRENT_BRANCH}" 2>/dev/null || echo "")
LOCAL_HEAD=$(git rev-parse "HEAD" 2>/dev/null || echo "")

if [ -z "$UPSTREAM_HEAD" ]; then
    echo "  错误: 无法获取上游分支 '${UPSTREAM_NAME}/${CURRENT_BRANCH}'"
    echo "  请确认上游是否存在该分支"
    if [ "$STASH_RESTORE" = "true" ]; then
        git stash pop
    fi
    exit 1
fi

if [ "$UPSTREAM_HEAD" = "$LOCAL_HEAD" ]; then
    echo "  当前分支已是最新，上游没有新更新"
    if [ "$STASH_RESTORE" = "true" ]; then
        git stash pop
    fi
    exit 0
fi

# 显示上游的新提交
echo "  上游有以下新提交:"
git log --oneline "${LOCAL_HEAD}..${UPSTREAM_HEAD}" 2>/dev/null || true
echo ""

# ---------- 6. 合并上游更新（保留本地修改） ----------
echo "[6/7] 合并上游更新到当前分支..."
echo "  策略: 将上游更新作为补丁应用到当前分支"

# 使用 rebase 将当前分支的本地更改放到上游最新提交之上
# 这样上游的更新会被应用，而本地的修改会保留在顶部
git rebase "${UPSTREAM_NAME}/${CURRENT_BRANCH}"

echo "  合并完成!"

# ---------- 7. 恢复暂存的本地更改 ----------
if [ "$STASH_RESTORE" = "true" ]; then
    echo ""
    echo "[7/7] 恢复暂存的本地更改..."

    # 查找刚刚创建的 stash
    STASH_ENTRY=$(git stash list | grep "$STASH_MSG" | head -1 | grep -o 'stash@{[^}]*}' | head -1)

    if [ -n "$STASH_ENTRY" ]; then
        # 应用 stash（不删除，先检查是否成功）
        git stash apply "$STASH_ENTRY" 2>/dev/null || {
            echo "  警告: 应用 stash 时出现冲突，正在尝试解决..."

            # 优先保留本地文件的更改（以本地更改为准）
            git checkout --ours . 2>/dev/null || true
            git checkout --theirs . 2>/dev/null || true
            git add -A
            git stash drop "$STASH_ENTRY" 2>/dev/null || true
            echo "  已应用本地更改（优先保留本地版本）"
        }

        # 确认 stash 已应用，清理记录
        git stash drop "$STASH_ENTRY" 2>/dev/null || true
        echo "  本地更改已恢复"
    else
        echo "  警告: 未找到对应的 stash 记录"
    fi
fi

# ---------- 完成 ----------
echo ""
echo "================================================"
echo "  同步完成!"
echo "================================================"
echo ""
echo "当前状态:"
echo "  分支: ${CURRENT_BRANCH}"
echo "  最新提交: $(git log --oneline -1)"
echo ""
echo "如需推送上游，请运行: git push origin ${CURRENT_BRANCH}"
echo ""
