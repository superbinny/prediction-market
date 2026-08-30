```
*************************************************************
*       Created:     2026-08-31  10:00（创建时间）
*       Filename:    change_github_fork_from_orign_manaul.md（脚本文件名）
*       Author:   ______
*                    / /  (_)
*                   / /_  /\____  ____  __   ______
*                  / __ \/ / __ \/ __ \/ /  / /
*                 / /_/ / / / / / / / / /__/ /
*                /_____/_/_/ /_/_/ /_/_/ /_/\___  /
*               ========== ________________/ /
*                          \______________/
*
*       Email:       Binny@vip.163.com
*       Group:       SP
*       Create By:   Binny
*       Purpose:     上游同步脚本使用说明书
*       Copyright:   TJYM(C) 2010 - All Rights Reserved
*       Version:     1.1（版本号）
*       LastModify:  2026-08-31（最后一次修改日期）
*************************************************************
```

# change_github_fork_from_orign.sh 使用说明书

## 功能概述

本脚本用于将 GitHub 上游原始项目的更新自动拉取并合并到当前 fork 分支中，同时保留所有本地修改。

## 工作流程

```
┌─────────────────────────────────────────────┐
│  1. 暂存本地未提交的更改（stash）             │
│  2. 添加/更新上游远程（upstream）             │
│  3. 从上游拉取最新代码（fetch）               │
│  4. 分析上游新提交（diff）                    │
│  5. Rebase 当前分支到上游最新提交（merge）     │
│  6. 恢复暂存的本地更改（pop stash）           │
│  7. 输出同步结果                              │
└─────────────────────────────────────────────┘
```

## 使用方法

### 前置准备

1. **修改上游仓库地址**

   编辑 `change_github_fork_from_orign.sh`，找到 `UPSTREAM_URL` 变量，替换为实际的上游仓库地址：

   ```bash
   UPSTREAM_URL="https://github.com/Polymarket/prediction-market.git"
   ```

2. **确保当前分支与上游分支对应**

   脚本会自动检测当前所在分支（`git rev-parse --abbrev-ref HEAD`），请确保上游存在同名分支。

### 执行同步

```bash
# 在项目根目录下执行
./change_github_fork_from_orign.sh
```

### 推送更新

同步完成后，如需将更新推送到自己的 fork：

```bash
git push origin main
```

## 冲突处理策略

脚本按以下优先级处理合并冲突：

1. **Rebase 阶段** — 上游更新作为基底，本地更改位于顶部
2. **Stash 恢复阶段** — 自动应用 stash，如有冲突：
   - 先尝试 `git checkout --ours`（保留当前分支版本）
   - 再尝试 `git checkout --theirs`（保留上游版本）
   - 最终保留本地修改优先

## 输出示例

```
================================================
  上游同步脚本 — 自动从原始项目拉取更新
================================================

[1/7] 当前分支: main

[2/7] 检查未提交的本地更改...
  检测到未提交的更改，正在创建临时 stash...
  本地更改已暂存，可以安全拉取上游更新

[3/7] 配置上游远程仓库 (upstream)...
  添加上游远程: https://github.com/Polymarket/prediction-market.git

[4/7] 从上游拉取最新代码...
  * [new branch]    main       -> upstream/main

[5/7] 分析上游更新...
  上游有以下新提交:
  abc1234 fix: resolve chart issue
  def5678 feat: add new feature

[6/7] 合并上游更新到当前分支...
  Successfully rebased and updated refs/heads/main.
  合并完成!

[7/7] 恢复暂存的本地更改...
  本地更改已恢复

================================================
  同步完成!
================================================
```

## 注意事项

- 脚本使用 `git rebase` 而非 `git merge`，保持线性提交历史
- 本地未提交的更改会自动 stash，同步完成后恢复
- 如果上游分支不存在或地址错误，脚本会安全退出
- 执行前建议手动备份重要更改

```

```
