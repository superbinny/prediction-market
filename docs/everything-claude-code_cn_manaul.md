<!--
  Created:     2026-09-13  14:00（创建时间）
  Filename:    everything-claude-code_cn_manaul.md（脚本文件名）
  Author:   ______
               / /  (_)
              / /_  /\____  ____  __   ______
             / __ \/ / __ \/ __ \/ /  / /
            / /_/ / / / / / / / / /__/ /
           /_____/_/_/ /_/_/ /_/\___  /
          ========== ______________/ /
                     \______________/

  Email:       Binny@vip.163.com
  Group:       SP
  Create By:   Binny
  Purpose:     Everything Claude Code (ECC) 完整手册 v2.0（中文版）
  Copyright:   TJYM(C) 2010 - All Rights Reserved
  Version:     1.0（版本号）
  LastModify:  2026-09-14（最后一次修改日期）
-->

---

title: Everything Claude Code (ECC) 完整手册
---

# Everything Claude Code (ECC) — 完整手册（中文版）

## 目录

1. [概述](#1-概述)
2. [安装与架构](#2-安装与架构)

- [2.1 使用方法](#21-使用方法)

3. [配置设置](#3-配置设置)
4. [钩子系统](#4-钩子系统)
5. [智能体系统（298 个智能体）](#5-智能体系统298-个智能体)
6. [命令（57 个命令）](#6-命令57-个命令)
7. [技能包（125 个技能）](#7-技能包125-个技能)
8. [规则系统](#8-规则系统)
9. [上下文系统](#9-上下文系统)
10. [OMC 集成](#10-omc-集成)
11. [插件系统](#11-插件系统)
12. [MCP 服务器（24 个服务器）](#12-mcp-服务器24-个服务器)
13. [多智能体编排](#13-多智能体编排)
14. [会话与项目管理](#14-会话与项目管理)
15. [故障排除](#15-故障排除)

---

## 1. 概述

**Everything Claude Code (ECC)** 是 Claude Code 的综合扩展系统，它将单个对话式 AI 助手转变为大型工程团队，具备：

- **298 个专业智能体**，涵盖工程、安全、营销、销售、GIS、游戏、医疗、金融等领域
- **57 个斜杠命令**，支持 TDD、多智能体工作流、代码审查、会话管理等
- **125 个技能包**，包含领域特定的模式、最佳实践和框架约定
- **49 个规则文件**，覆盖 9 种编程语言 + 通用规则
- **3 种执行上下文**（dev、research、review）
- **24 个 MCP 服务器**，用于外部工具集成（浏览器、GitHub、Vercel、Supabase 等）
- **OMC（Oh My Claude Code）多智能体编排引擎**，包含 83 个编译模块
- **41 个内部插件**和**16 个外部插件家族**
- **持续学习系统**，具备本能提取和进化能力

### 核心设计原则

1. **不可变性**：所有输出创建新对象，从不修改现有状态
2. **开失败**：钩子在出错时始终继续执行，不会阻塞会话
3. **优雅降级**：缺失的组件会被静默跳过
4. **并行执行**：独立的智能体并行运行以提升速度
5. **语言特定覆盖**：每语言规则可扩展并覆盖通用规则
6. **关键词驱动激活**：智能体和技能基于意图检测自动触发

---

## 2. 安装与架构

### 2.1 目录结构

```
~/.claude/
├── settings.json                    # 主配置（钩子、MCP、模型、权限）
├── .claude.json                     # 插件清单（53 KB）
├── CLAUDE.md                        # 全局项目规则（版权头部、编排）
├── history.jsonl                    # 会话对话历史（181 KB）
├── .env                             # 环境变量：LiteLLM 代理位于 localhost:18080
├── policy-limits.json               # 功能限制
│
├── agents/                          # 298 个智能体定义文件（.md）
├── commands/                        # 57 个斜杠命令文件（.md）
├── skills/                          # 125 个技能目录（每个包含 SKILL.md）
├── rules/                           # 49 个规则文件，分布在 10 个目录中
├── contexts/                        # 3 个上下文文件（dev.md、research.md、review.md）
│
├── omc/                             # Oh My ClaudeCode v4.13.6
│   ├── VERSION                      # "4.13.6"
│   ├── CHANGELOG.md                 # 发布说明
│   ├── LICENSE                      # MIT
│   ├── hooks/hooks.json             # 钩子定义（213 行）
│   ├── skills/                      # 11 个钩子子目录 + 9 个规则子目录
│   ├── scripts/                     # 40+ 个 OMC 脚本文件（.mjs/.cjs）
│   ├── dist/                        # 编译后的 TypeScript（83 个模块目录）
│   ├── agents/                      # 21 个 OMC 智能体变体（.md）
│   ├── templates/                   # 5 个模板目录（deliverables、hooks、rules、skills、scripts）
│   ├── .claude-plugin/              # 插件元数据
│   └── .claude-plugin/marketplace.json
│
├── plugins/                         # 插件市场
│   └── marketplaces/
│       ├── claude-plugins-official/  # 41 个内部插件 + 16 个外部家族
│       └── superpowers-marketplace/  # Git 钩子集成
│
├── projects/                        # 31 个按项目划分的会话目录
├── sessions/                        # 8 个活动会话目录
├── tasks/                           # 24 个任务目录
├── session-env/                     # 99 个会话环境目录
├── file-history/                    # 91 个文件历史记录条目
├── shell-snapshots/                 # 5 个 zsh shell 快照
├── paste-cache/                     # 缓存的粘贴文件
├── telemetry/                       # 失败的遥测事件
├── backups/                         # 5 个 .claude.json 备份
├── cc-haha/                         # SQLite 搜索索引（125 MB）
├── ide/                             # IDE 锁定文件
├── cache/                           # 本地模型缓存
├── .runtime/                        # OMC 运行时的 Python 3.13 venv
└── .session-stats.json              # 按会话划分的工具使用统计
```

### 2.2 模型配置

| 组件     | 值                                                                                 |
| -------- | ---------------------------------------------------------------------------------- |
| 会话模型 | Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q8_K_P.gguf                         |
| 模型路径 | `/Users/a1/Models/guff/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q8_K_P.gguf` |
| API 代理 | `http://localhost:18080/v1`（LiteLLM）                                             |
| API 密钥 | `sk-any-local-key`（仅限本地，无远程 API 调用）                                    |
| 模型系列 | Qwen3.6 35B 参数，约 33B 活跃，Q8_K 量化                                           |

### 2.3 组件摘要

| 组件                 | 数量     |
| -------------------- | -------- |
| 智能体定义           | 298      |
| 斜杠命令             | 57       |
| 技能目录             | 125      |
| 规则文件             | 49       |
| 上下文文件           | 3        |
| MCP 服务器           | 24       |
| 钩子事件类型         | 11       |
| 独立钩子             | 20       |
| OMC 脚本             | 40+      |
| OMC dist 模块        | 83       |
| OMC 智能体变体       | 21       |
| 内部插件             | 41       |
| 外部插件家族         | 16       |
| **ECC+OMC 组件总计** | **550+** |

---

## 2.1 使用方法

本节详细介绍如何在实际开发中使用 ECC。涵盖日常开发工作流、智能体调用、命令使用、技能加载和最佳实践。

### 2.1.1 启动会话

```bash
# 1. 在项目根目录启动 Claude Code
cd /path/to/project
claude

# 2. Claude Code 自动加载：
#    - 项目级 CLAUDE.md（如果有）
#    - 用户级 ~/.claude/CLAUDE.md（全局规则）
#    - ~/.claude/skills/ 中的所有技能
#    - ~/.claude/agents/ 中的所有智能体
#    - ~/.claude/commands/ 中的所有命令
#    - 钩子系统（自动运行）
```

启动后，Claude Code 会执行以下自动操作：

- `SessionStart` 钩子加载项目记忆、检测关键词、注入技能
- `wiki-session` 钩子初始化 Wiki 系统
- `omc-init` 钩子启动 OMC 编排引擎
- 关键词检测器扫描全局关键词库（47 KB），准备意图识别

### 2.1.2 通过自然语言调用智能体

**无需指定智能体类型**，ECC 的关键词检测器会自动匹配最合适的智能体。

#### 自动触发示例

```
用户输入: "帮我设计一个新的用户认证模块"
→ 自动触发: planner 智能体（架构设计）

用户输入: "这段代码有什么安全问题？"
→ 自动触发: security-reviewer 智能体（安全分析）

用户输入: "构建失败了，看看错误"
→ 自动触发: build-error-resolver 智能体（构建修复）

用户输入: "写一个新功能：支付处理"
→ 自动触发: tdd-guide 智能体（TDD 工作流）

用户输入: "检查有没有死代码"
→ 自动触发: refactor-cleaner 智能体（代码清理）
```

#### 手动指定智能体

当自动匹配不符合预期时，可以明确指定：

```
"使用 security-reviewer 智能体审查 auth.ts 文件"
"用 planner 智能体规划多因素认证功能"
"让 code-reviewer 审查最近的提交"
```

#### 常用智能体速查表

| 场景       | 推荐智能体             | 触发关键词                      |
| ---------- | ---------------------- | ------------------------------- |
| 新功能规划 | `planner`              | 规划、设计、架构、实现          |
| 代码审查   | `code-reviewer`        | 审查、review、检查代码          |
| 安全分析   | `security-reviewer`    | 安全、security、漏洞、认证      |
| 构建修复   | `build-error-resolver` | 构建失败、编译错误、build error |
| TDD 开发   | `tdd-guide`            | 新功能、实现、编写代码          |
| 死代码清理 | `refactor-cleaner`     | 清理、死代码、重构              |
| 文档更新   | `doc-updater`          | 更新文档、docs                  |
| 端到端测试 | `e2e-runner`           | E2E、端到端、集成测试           |
| 数据库优化 | `database-reviewer`    | SQL、查询、数据库、迁移         |
| Git 工作流 | `Git Workflow Master`  | 提交、分支、rebase、PR          |

### 2.1.3 使用斜杠命令

斜杠命令是预定义的完整工作流。格式：`/命令名称`

#### 核心命令速查

```bash
# ===== 开发工作流 =====
/update-docs       # 从代码生成文档
/update-codemaps   # 更新架构图谱
/commit            # 创建 git 提交
/code-review       # 执行代码审查
/verify            # 质量门验证
/tdd               # 测试驱动开发工作流

# ===== 构建与测试 =====
/go-build          # 修复 Go 构建错误
/rust-build        # 修复 Rust 构建错误
/kotlin-build      # 修复 Kotlin 构建错误
/python-review     # Python 代码审查
/go-review         # Go 代码审查
/rust-review       # Rust 代码审查
/kotlin-review     # Kotlin 代码审查

# ===== 架构与设计 =====
/blueprint         # 从目标生成构建蓝图
/plan              # 创建实现计划
/orchestrate       # 启动多角色分工

# ===== 会话管理 =====
/save-session      # 保存当前会话状态
/resume-session    # 恢复上次会话
/checkpoint        # 设置检查点
/loop-start        # 启动自动循环
/loop-status       # 查看循环状态

# ===== 学习与进化 =====
/learn             # 提取可复用模式
/evolve            # 进化本能
/skill-create      # 从 Git 历史创建技能
/skill-health      # 技能健康状况检查
/instinct-status   # 查看本能状态

# ===== 其他 =====
/docs              # 查找库文档（通过 Context7）
/claw              # 启动 NanoClaw REPL
/model-route       # 模型路由选择
```

#### 命令使用示例

```bash
# 编写新功能前，先规划
/plan 实现用户积分系统，包含积分获取、消耗、过期和排行榜

# 代码完成后，自动审查
/code-review

# 构建成功后，更新文档
/update-docs

# 准备提交前，创建规范提交
/commit
```

### 2.1.4 技能包使用

技能包提供领域特定的知识和最佳实践。它们可以自动触发，也可以手动加载。

#### 自动触发

ECC 会在以下场景自动加载相关技能：

| 检测到的内容       | 自动加载的技能                           |
| ------------------ | ---------------------------------------- |
| 编写 Python 代码   | `python-patterns`、`python-testing`      |
| 编写 React/Next.js | `frontend-patterns`、`nextjs-turbopack`  |
| 编写 Docker 文件   | `docker-patterns`、`deployment-patterns` |
| 编写 API 路由      | `api-design`、`backend-patterns`         |
| 数据库操作         | `postgres-patterns`                      |
| TDD 工作流         | `tdd-workflow`                           |
| 安全相关代码       | `security-scan`、`security-review`       |

#### 手动加载技能

```bash
# 通过 Skill 工具手动调用
Skill: django-patterns          # Django 架构模式
Skill: laravel-patterns         # Laravel 架构模式
Skill: springboot-patterns      # Spring Boot 模式
Skill: rust-testing             # Rust 测试模式
Skill: e2e-testing              # 端到端测试
Skill: deep-research            # 深度研究
Skill: market-research          # 市场调研
```

#### 本项目相关技能

针对 Kuest 项目（Next.js + TypeScript + Tailwind），以下技能最常用：

| 技能                  | 用途                     | 触发条件           |
| --------------------- | ------------------------ | ------------------ |
| `typescript-patterns` | TypeScript 惯用写法      | 编写 .ts/.tsx 文件 |
| `nextjs-turbopack`    | Next.js 16+ 和 Turbopack | Next.js 相关任务   |
| `postgres-patterns`   | PostgreSQL 查询优化      | SQL/数据库操作     |
| `security-scan`       | 安全扫描                 | 处理用户输入/认证  |
| `e2e-testing`         | Playwright E2E 测试      | E2E 测试编写       |
| `coding-standards`    | 通用编码标准             | 所有代码编写       |
| `deployment-patterns` | 部署工作流               | Docker/Vercel 部署 |
| `database-migrations` | 数据库迁移最佳实践       | Schema 变更        |

### 2.1.5 钩子系统使用

钩子无需手动配置，启动 Claude Code 后自动运行。了解钩子的工作方式有助于调试和优化。

#### 钩子生命周期

```
┌─────────────────────────────────────────────────────────────┐
│                      会话开始                                │
│  SessionStart → 项目记忆加载、关键词检测、技能注入           │
│  UserPromptSubmit → 每次用户输入时重新检测意图               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      工具调用                                │
│  PreToolUse → 调用前验证（权限检查、参数校验）               │
│  工具执行（Read / Write / Bash / Agent / Edit）             │
│  PostToolUse → 调用后验证（质量检查、记忆更新）              │
│  PostToolUseFailure → 失败恢复                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      上下文压缩                              │
│  PreCompact → 压缩前保留关键状态                             │
│  (上下文窗口接近限制时自动触发)                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      会话结束                                │
│  Stop → 上下文守卫、持久化模式检查、代码简化                 │
│  SessionEnd → 最终清理、Wiki 更新                            │
└─────────────────────────────────────────────────────────────┘
```

#### 关键钩子详解

| 钩子                 | 触发时机                                | 功能                                       |
| -------------------- | --------------------------------------- | ------------------------------------------ |
| `keyword-detector`   | SessionStart / UserPromptSubmit         | 扫描用户消息，匹配 47KB 关键词库，识别意图 |
| `skill-injector`     | SessionStart / UserPromptSubmit         | 根据检测到的关键词，加载匹配的技能包       |
| `project-memory`     | SessionStart / PostToolUse / PreCompact | 自动维护项目记忆（MEMORY.md + 记忆文件）   |
| `pre-tool-enforcer`  | PreToolUse                              | 验证工具调用参数，执行模型路由规则         |
| `post-tool-verifier` | PostToolUse                             | 验证工具输出质量和完整性                   |
| `rules-injector`     | PostToolUse                             | 根据所用工具注入相关规则                   |
| `context-guard`      | Stop                                    | 保留关键上下文，防止重要信息丢失           |
| `code-simplifier`    | Stop                                    | 会话结束时自动简化冗余代码                 |
| `permission-handler` | PermissionRequest                       | 处理工具权限请求                           |

#### 钩子调试

如果钩子行为不符合预期：

```bash
# 1. 检查钩子配置
cat ~/.claude/settings.json | grep hooks

# 2. 查看 OMC 钩子定义
cat ~/.claude/omc/hooks/hooks.json

# 3. 检查钩子脚本是否存在
ls ~/.claude/omc/skills/

# 4. 查看会话日志
cat ~/.claude/history.jsonl | tail -50
```

### 2.1.6 多智能体编排

对于复杂任务，可以启动多个智能体并行工作。

#### 基本编排

```
"使用 orchestrator 分解以下任务：实现用户积分系统，包含积分获取、消耗、过期和排行榜"
```

编排器会自动：

1. 分析任务复杂度
2. 拆分为独立子任务
3. 启动多个智能体并行执行
4. 合并各角色输出

#### 按角色分配

```
"启动以下角色分工：
- architect: 设计积分系统架构
- frontend: 实现积分展示 UI
- backend: 开发积分 API 路由
- qa: 编写积分系统测试"
```

#### OMC 编排模块

OMC 包含 83 个编译模块，支持完整的编排工作流：

| 模块          | 功能           |
| ------------- | -------------- |
| `pipeline`    | 顺序任务管道   |
| `dag`         | 有向无环图编排 |
| `worker-pool` | 工作池管理     |
| `retry`       | 失败重试逻辑   |
| `fallback`    | 降级策略       |
| `monitor`     | 执行监控       |
| `reporter`    | 结果报告       |

### 2.1.7 上下文系统

ECC 提供 3 种执行上下文，用于调整 AI 的行为模式。

| 上下文     | 用途     | 适用场景             |
| ---------- | -------- | -------------------- |
| `dev`      | 开发模式 | 日常编码、新功能开发 |
| `research` | 研究模式 | 技术调研、方案评估   |
| `review`   | 审查模式 | 代码审查、安全审计   |

切换上下文：

```
切换到开发上下文：我正在实现新功能
切换到研究上下文：调研最佳方案
切换到审查上下文：审查这段代码
```

### 2.1.8 插件系统

ECC 支持 41 个内部插件和 16 个外部插件家族。

#### 内部插件

内置于 ECC，自动加载：

| 插件       | 功能               |
| ---------- | ------------------ |
| Git 集成   | 提交历史、分支管理 |
| 文件监控   | 文件系统变更检测   |
| 会话持久化 | 会话状态保存/恢复  |
| 记忆管理   | 项目记忆自动维护   |

#### 外部插件

来自 marketplace，需手动安装：

| 插件家族                  | 功能                       |
| ------------------------- | -------------------------- |
| `superpowers-marketplace` | Git 钩子增强               |
| 更多...                   | 通过 `/configure-ecc` 浏览 |

#### 插件管理

```bash
# 查看已安装插件
cat ~/.claude/.claude.json | jq '.plugins'

# 安装新插件
/claw  # 启动 REPL 进行插件交互

# 配置插件权限
~/.claude/settings.json → "allowedTools"
```

### 2.1.9 MCP 服务器使用

ECC 配置了 24 个 MCP 服务器，扩展 Claude Code 的能力。

#### 开发常用 MCP

| MCP          | 用途        | 调用方式                       |
| ------------ | ----------- | ------------------------------ |
| `context7`   | 查找库文档  | "用 docs 查找 React 19 新特性" |
| `github`     | GitHub 操作 | "用 github 创建 issue"         |
| `supabase`   | 数据库操作  | "用 supabase 查询用户表"       |
| `filesystem` | 文件系统    | 自动加载                       |
| `memory`     | 持久化记忆  | 自动加载                       |

#### 部署常用 MCP

| MCP                        | 用途                    |
| -------------------------- | ----------------------- |
| `vercel`                   | Vercel 部署操作         |
| `railway`                  | Railway 部署操作        |
| `cloudflare-workers-build` | Cloudflare Workers 构建 |

#### 搜索与抓取

| MCP               | 用途                |
| ----------------- | ------------------- |
| `exa-web-search`  | 神经营销搜索        |
| `firecrawl`       | 网页抓取            |
| `cloudflare-docs` | Cloudflare 文档搜索 |

#### 浏览器自动化

| MCP           | 用途              |
| ------------- | ----------------- |
| `browser-use` | AI 驱动浏览器交互 |
| `browserbase` | 云端浏览器会话    |
| `playwright`  | Playwright 自动化 |

#### AI/ML 工具

| MCP                   | 用途               |
| --------------------- | ------------------ |
| `fal-ai`              | 图像/视频/音频生成 |
| `sequential-thinking` | 思维链推理         |

#### MCP 调用示例

```bash
# 查找文档
"用 context7 查找 Next.js 16 的新特性"

# GitHub 操作
"用 github 查看 prediction-market 的 open issues"

# 数据库查询
"用 supabase 查询最近的用户注册"
```

### 2.1.10 日常开发工作流

#### 场景 1：实现新功能

```
用户: "帮我实现一个用户积分获取功能"

步骤 1: planner 自动启动，分析需求并生成实现计划
步骤 2: tdd-guide 启动，编写测试文件（测试先行）
步骤 3: 实现核心逻辑（src/lib/points.ts）
步骤 4: code-reviewer 自动审查代码
步骤 5: security-reviewer 检查安全风险
步骤 6: 更新文档（/update-docs）
步骤 7: 创建提交（/commit）
```

#### 场景 2：修复 Bug

```
用户: "积分系统有 bug，用户注册后积分没有增加"

步骤 1: planner 分析 bug 原因
步骤 2: 定位到 src/lib/points.ts 的注册回调
步骤 3: 编写修复代码
步骤 4: 运行测试验证修复
步骤 5: 创建修复提交
```

#### 场景 3：代码重构

```
用户: "重构 API 路由，提取公共逻辑"

步骤 1: planner 规划重构方案
步骤 2: refactor-cleaner 识别重复代码
步骤 3: 提取公共工具函数
步骤 4: 更新所有引用
步骤 5: code-reviewer 审查重构结果
步骤 6: 运行测试确保无回归
```

#### 场景 4：部署

```
用户: "准备生产部署"

步骤 1: 运行构建（pnpm build）
步骤 2: 检查环境变量（对比 .env.example）
步骤 3: 运行测试（pnpm test）
步骤 4: 检查安全（security-scan）
步骤 5: 创建发布提交
步骤 6: 推送到 Vercel
步骤 7: 验证部署（health check）
```

### 2.1.11 最佳实践

1. **先规划再编码** — 复杂功能先用 `/plan` 生成实现计划
2. **测试驱动开发** — 使用 `/tdd` 确保测试先行
3. **每次代码变更都审查** — `code-reviewer` 必须在使用后调用
4. **安全扫描** — 处理用户输入、认证、API 时触发 `security-reviewer`
5. **利用钩子** — 让自动化钩子处理 lint/format/verify，不必手动执行
6. **善用记忆系统** — 项目记忆会自动保存上下文，跨会话保持一致
7. **模型路由** — 简单任务用 Haiku，开发用 Sonnet，复杂决策用 Opus
8. **并行执行** — 独立任务让多个智能体并行处理，提升效率
9. **定期更新文档** — 代码变更后立即运行 `/update-docs`
10. **使用检查点** — 长时间任务用 `/checkpoint` 保存进度

### 2.1.12 快速参考卡片

```
┌─────────────────────────────────────────────────────────┐
│              ECC 日常开发速查                             │
├─────────────────────────────────────────────────────────┤
│ 启动会话:    claude                                     │
│ 新功能:      "实现 X 功能" → planner → tdd → review     │
│ 修复 Bug:    "修复 X bug" → planner → fix → verify      │
│ 重构:        "重构 X" → refactor-cleaner → review       │
│ 部署:        "准备部署" → build → test → deploy         │
│ 查文档:      "用 docs 查找 X" → context7 MCP            │
│ 更新文档:    /update-docs                               │
│ 代码审查:    /code-review                               │
│ 质量验证:    /verify                                    │
│ 保存会话:    /save-session                              │
│ 恢复会话:    /resume-session                            │
└─────────────────────────────────────────────────────────┘
```

---

## 3. 配置设置

`~/.claude/settings.json` 是中央配置文件（约 6.4 KB），包含钩子、MCP 服务器、模型路由和权限。

### 3.1 钩子配置

11 种钩子事件类型，共 20 个独立钩子命令，均通过 `scripts/run.cjs`（跨平台运行器）调用。

| 钩子事件             | 钩子数量 | 钩子脚本                                                                         |
| -------------------- | -------- | -------------------------------------------------------------------------------- |
| `SessionStart`       | 5        | project-memory-session、keyword-detector、skill-injector、wiki-session、omc-init |
| `SessionEnd`         | 2        | session-end、wiki-session-end                                                    |
| `PreToolUse`         | 1        | pre-tool-enforcer                                                                |
| `PostToolUse`        | 3        | post-tool-verifier、project-memory-posttool、rules-injector-posttool             |
| `PostToolUseFailure` | 1        | post-tool-failure-handler                                                        |
| `SubagentStart`      | 1        | subagent-tracker-subagent                                                        |
| `SubagentStop`       | 2        | subagent-tracker-stop、verify-deliverables-subagent                              |
| `PreCompact`         | 3        | pre-compact、project-memory-precompact、wiki-pre-compact                         |
| `Stop`               | 3        | context-guard、persistent-mode、code-simplifier                                  |
| `UserPromptSubmit`   | 2        | keyword-detector、skill-injector                                                 |
| `PermissionRequest`  | 1        | permission-handler                                                               |

### 3.2 MCP 服务器（24 个）

按类别组织：

**浏览器自动化（3 个）：**

- `browser-use`（HTTP）— AI 驱动的浏览器交互
- `browserbase`（npx）— 云端浏览器会话
- `playwright`（npx）— 直接 Playwright 自动化

**文档搜索（2 个）：**

- `context7`（npx）— 库/API 文档查找
- `cloudflare-docs`（HTTP）— Cloudflare 文档搜索

**网络搜索与抓取（2 个）：**

- `exa-web-search`（npx）— 由 Exa AI 驱动的神经营销搜索
- `firecrawl`（npx）— 网页抓取和内容提取

**GitHub 生态（2 个）：**

- `github`（npx）— 完整 GitHub 操作（issue、PR、搜索、代码）
- `confluence`（npx）— Atlassian Confluence 搜索和管理

**部署（3 个）：**

- `vercel`（HTTP）— Vercel 部署操作
- `railway`（npx）— Railway 部署操作
- `cloudflare-workers-build`（HTTP）— Workers 构建管道

**Cloudflare 套件（3 个）：**

- `cloudflare-observability`（HTTP）— 日志和指标
- `cloudflare-workers-bindings`（HTTP）— TypeScript 绑定生成
- `cloudflare-docs`（HTTP）— 文档搜索

**数据库（1 个）：**

- `supabase`（npx）— Supabase 数据库操作

**分析（1 个）：**

- `clickhouse`（HTTP）— 分析和日志查询

**AI/ML（2 个）：**

- `fal-ai`（npx）— 通过 Fal 生成图像/视频/音频
- `sequential-thinking`（npx）— 思维链推理

**安全（1 个）：**

- `insaits`（Python3）— AI 安全监控

**UI 组件（1 个）：**

- `magic`（npx）— Magic UI 组件生成

**基础设施（2 个）：**

- `filesystem`（npx）— 文件系统操作
- `memory`（npx）— 持久化记忆系统

**优化（1 个）：**

- `token-optimizer`（npx）— 上下文窗口压缩

**开发（1 个）：**

- `devfleet`（HTTP）— 多智能体编排（并行任务）

**服务器类型：** HTTP（6 个）| npx（17 个）| Python3（1 个）

### 3.3 插件权限

```json
"allowedTools": {
    "Bash": { "mode": "default" }
}
```

Bash 命令默认需要用户批准。

### 3.4 策略限制

`policy-limits.json` 禁用特定功能：

| 功能            | 状态   |
| --------------- | ------ |
| `remoteControl` | 已禁用 |
| `routines`      | 已禁用 |
| `quick-web`     | 已禁用 |
| `cobalt-plinth` | 已禁用 |

---

## 4. 钩子系统深度解析

### 4.1 钩子运行器（`omc/scripts/run.cjs`）

`run.cjs` 脚本是所有 OMC 钩子的核心。它解决了跨平台钩子执行问题：

**关键特性：**

- **跨平台**：使用 `process.execPath` 查找正确的 Node 二进制文件（在 Windows 上有效，因为 `/usr/bin/sh` 是 PE32+ 二进制文件）
- **过期路径恢复**：如果 `CLAUDE_PLUGIN_ROOT` 指向已删除/旧版本，会扫描插件缓存以查找最新匹配版本
- **超时执行**：从 `hooks.json` 读取超时设置，杀死超过限制的钩子
- **开失败**：始终干净退出（代码 0），确保 Claude Code 钩子不会被阻塞

**使用模式：**

```bash
node "$CLAUDE_PLUGIN_ROOT/scripts/run.cjs" \
    "$CLAUDE_PLUGIN_ROOT/scripts/<hook-name>.mjs" \
    [hook-arguments]
```

### 4.2 钩子执行流程

```
会话开始
  ├── [SessionStart] project-memory-session.mjs
  │     └── 检测项目目录，注册项目记忆上下文
  ├── [SessionStart] keyword-detector.mjs
  │     └── 扫描用户消息中的意图关键词（47 KB 关键词数据库）
  ├── [SessionStart] skill-injector.mjs
  │     └── 根据检测到的关键词注入相关技能（13 KB）
  ├── [SessionStart] wiki-session.mjs
  │     └── 为会话设置 wiki 系统
  └── [SessionStart] omc-init.mjs
        └── 初始化 OMC 编排层

用户发送提示
  ├── [UserPromptSubmit] keyword-detector.mjs
  │     └── 从用户消息中重新检测意图
  └── [UserPromptSubmit] skill-injector.mjs
        └── 加载与检测到的关键词匹配的技能

工具执行前
  └── [PreToolUse] pre-tool-enforcer.mjs
        └── 验证工具参数，执行规则

工具执行（Read、Bash、Write、Edit、Agent 等）
  ├── [PostToolUse] post-tool-verifier.mjs
  │     └── 验证工具输出质量和完整性
  ├── [PostToolUse] project-memory-posttool.mjs
  │     └── 将执行状态保存到项目记忆
  └── [PostToolUse] rules-injector-posttool.mjs
        └── 根据所用工具注入相关规则

  └── [PostToolUseFailure]（如果工具失败）
        └── 失败处理和恢复

子智能体生命周期
  ├── [SubagentStart] subagent-tracker-subagent.mjs
  │     └── 记录子智能体生成，开始跟踪
  └── [SubagentStop] subagent-tracker-stop.mjs
        └── 记录子智能体完成
       └── verify-deliverables-subagent.mjs
            └── 检查子智能体输出的完整性

上下文压缩前
  ├── [PreCompact] pre-compact.mjs
  │     └── 通用压缩前钩子
  ├── [PreCompact] project-memory-precompact.mjs
  │     └── 压缩前保留项目记忆
  └── [PreCompact] wiki-pre-compact.mjs
        └── 压缩前保存 wiki 状态

会话停止
  ├── [Stop] context-guard.mjs
  │     └── 保留关键上下文
  ├── [Stop] persistent-mode.mjs（52 KB）
  │     └── 检查和管理持久化会话状态
  └── [Stop] code-simplifier.mjs（5 KB）
        └── 会话结束时简化代码

会话结束
  ├── [SessionEnd] session-end.mjs
  │     └── 最终会话清理
  └── [SessionEnd] wiki-session-end.mjs
        └── 使用会话发现更新 wiki
```

### 4.3 OMC 核心脚本

| 脚本                            | 大小  | 用途                           |
| ------------------------------- | ----- | ------------------------------ |
| `keyword-detector.mjs`          | 47 KB | 通过关键词匹配检测用户意图     |
| `skill-injector.mjs`            | 13 KB | 根据检测到的关键词注入相关技能 |
| `session-start.mjs`             | 38 KB | 带模型路由的会话初始化         |
| `pre-tool-enforcer.mjs`         | 41 KB | 工具执行前执行规则             |
| `post-tool-verifier.mjs`        | 38 KB | 验证工具输出质量               |
| `persistent-mode.mjs`           | 52 KB | 管理长运行持久化会话           |
| `project-memory-session.mjs`    | 3 KB  | 项目级记忆检测                 |
| `project-memory-precompact.mjs` | —     | 压缩前记忆保留                 |
| `project-memory-posttool.mjs`   | —     | 工具后状态保存                 |
| `subagent-tracker.mjs`          | 1 KB  | 跟踪子智能体生命周期           |
| `verify-deliverables.mjs`       | 8 KB  | 验证子智能体输出完整性         |
| `permission-handler.mjs`        | —     | 处理 Bash 权限提示             |
| `code-simplifier.mjs`           | 5 KB  | 会话结束时简化代码             |
| `run.cjs`                       | —     | 跨平台钩子运行器               |

### 4.4 OMC dist/ 模块

`dist/` 目录（编译后的 TypeScript）包含 83 个模块目录：

| 模块                         | 数量 | 用途                          |
| ---------------------------- | ---- | ----------------------------- |
| `autopilot/`                 | 52   | 自主工作流执行                |
| `learner/`                   | 70   | 从会话中持续学习              |
| `factcheck/`                 | 23   | 事实验证和声明检查            |
| `project-memory/`            | 47   | 项目上下文保留                |
| `ralph/`                     | 26   | 持久化循环编排                |
| `persistent-mode/`           | 23   | 持久化会话管理                |
| `team-pipeline/`             | 19   | 基于团队的任务管道            |
| `subagent-tracker/`          | 19   | 子智能体生命周期跟踪          |
| `think-mode/`                | 19   | 思考模式实现                  |
| `wiki/`                      | 31   | 会话 wiki 管理                |
| `keyword-detector/`          | 7    | 关键词意图检测                |
| `pre-compact/`               | 10   | 压缩前处理                    |
| `agents-overlay/`            | —    | 智能体叠加系统                |
| `auto-slash-command/`        | —    | 自动斜杠命令生成              |
| `bridge/`                    | —    | OMC 与 Claude Code 之间的桥接 |
| `codebase-map/`              | —    | 代码库结构映射                |
| `directory-readme-injector/` | —    | 自动生成 README 文件          |
| `merge-readiness/`           | —    | 合并就绪性检查                |
| `mode-registry/`             | —    | 模式注册系统                  |
| `notepad/`                   | —    | 会话记事本                    |
| `omc-orchestrator/`          | —    | OMC 编排核心                  |
| `permission-handler/`        | —    | 权限处理                      |
| `skill-bridge/`              | —    | 技能桥接系统                  |
| `task-size-detector/`        | —    | 检测任务复杂度                |
| `team-dispatch-hook/`        | —    | 团队任务分发                  |
| `team-worker-hook/`          | —    | 团队工人管理                  |
| `todo-continuation/`         | —    | TODO 列表持久化               |
| `thinking-block-validator/`  | —    | 验证思考块                    |
| `non-interactive-env/`       | —    | 非交互式环境处理              |

---

## 5. 智能体系统（298 个智能体）

智能体是位于 `~/.claude/agents/` 中的 `.md` 文件，定义了专业化的 AI 角色。每个智能体包含：

- **YAML frontmatter**：`name`、`description`、`tools`，可选的 `model` 覆盖
- **描述**：触发自动加载的关键词
- **工具**：智能体可访问的工具（全部工具，或特定子集）
- **模型**：可选的层级覆盖（haiku/sonnet/opus）

### 5.1 智能体格式

```yaml
---
name: architect
description: 专注于系统设计的软件架构师...
tools: ['Read', 'Grep', 'Glob', 'Write', 'Edit', 'Bash']
model: opus
---
智能体主体内容，包含具体指令...
```

### 5.2 按类别完整的智能体清单

#### 工程与构建智能体（25 个）

| 智能体文件                 | 名称                  | 用途                               |
| -------------------------- | --------------------- | ---------------------------------- |
| `architect.md`             | architect             | 系统设计、领域驱动设计、架构模式   |
| `build-error-resolver.md`  | build-error-resolver  | 修复编译/构建错误                  |
| `code-reviewer.md`         | code-reviewer         | 专业代码审查（正确性、安全、性能） |
| `database-reviewer.md`     | database-reviewer     | 数据库模式和查询审查               |
| `doc-updater.md`           | doc-updater           | 文档更新                           |
| `planner.md`               | planner               | 实现规划和任务分解                 |
| `refactor-cleaner.md`      | refactor-cleaner      | 死代码清理、重构                   |
| `security-reviewer.md`     | security-reviewer     | 安全分析                           |
| `tdd-guide.md`             | tdd-guide             | 测试驱动开发（80%+ 覆盖率）        |
| `cpp-build-resolver.md`    | cpp-build-resolver    | C++ 构建错误解决                   |
| `cpp-reviewer.md`          | cpp-reviewer          | C++ 代码审查                       |
| `docs-lookup.md`           | docs-lookup           | 文档查找                           |
| `e2e-runner.md`            | e2e-runner            | 端到端测试                         |
| `go-build-resolver.md`     | go-build-resolver     | Go 构建错误解决                    |
| `go-reviewer.md`           | go-reviewer           | Go 代码审查                        |
| `harness-optimizer.md`     | harness-optimizer     | 测试工具包优化                     |
| `java-build-resolver.md`   | java-build-resolver   | Java 构建错误解决                  |
| `java-reviewer.md`         | java-reviewer         | Java 代码审查                      |
| `kotlin-build-resolver.md` | kotlin-build-resolver | Kotlin 构建错误解决                |
| `kotlin-reviewer.md`       | kotlin-reviewer       | Kotlin 代码审查                    |
| `loop-operator.md`         | loop-operator         | 循环管理                           |
| `python-reviewer.md`       | python-reviewer       | Python 代码审查                    |
| `rust-build-resolver.md`   | rust-build-resolver   | Rust 构建错误解决                  |
| `rust-reviewer.md`         | rust-reviewer         | Rust 代码审查                      |
| `database-optimizer.md`    | database-optimizer    | PostgreSQL、MySQL、索引、查询优化  |

#### AI/ML 与数据工程智能体（50+ 个）

| 智能体文件                                         | 名称                    | 用途                                       |
| -------------------------------------------------- | ----------------------- | ------------------------------------------ |
| `engineering-ai-data-remediation-engineer.md`      | AI 数据修复工程师       | 使用本地 SLM 的自我修复数据管道            |
| `engineering-ai-engineer.md`                       | AI 工程师               | ML 模型开发和部署                          |
| `engineering-api-platform-engineer.md`             | API 平台工程师          | 公开/合作伙伴 API 平台设计                 |
| `engineering-autonomous-optimization-architect.md` | 自主优化架构师          | 持续 API 性能 + 成本优化                   |
| `engineering-backend-architect.md`                 | 后端架构师              | 可扩展系统架构、微服务                     |
| `engineering-cms-developer.md`                     | CMS 开发者              | Drupal/WordPress 主题和插件开发            |
| `engineering-code-reviewer.md`                     | 工程代码审查员          | 工程项目代码审查                           |
| `engineering-codebase-onboarding-engineer.md`      | 代码库入职工程师        | 帮助理解陌生代码库                         |
| `engineering-data-engineer.md`                     | 数据工程师              | 数据管道、数据湖、ETL/ELT、Spark、dbt      |
| `engineering-data-visualization-engineer.md`       | 数据可视化工程师        | 图表设计、D3、Vega、感知诚实编码           |
| `engineering-database-optimizer.md`                | 数据库优化师            | 模式设计、查询优化、索引                   |
| `engineering-database-reliability-engineer.md`     | 数据库可靠性工程师      | 高可用、复制、备份                         |
| `engineering-desktop-app-engineer.md`              | 桌面应用工程师          | Electron/Tauri 桌面应用                    |
| `engineering-developer-tooling-engineer.md`        | 开发者工具工程师        | CLI 工具、内部开发者平台                   |
| `engineering-devops-automator.md`                  | DevOps 自动化工程师     | CI/CD、基础设施自动化                      |
| `engineering-drupal-performance.md`                | Drupal 性能工程师       | Drupal Core Web Vitals 优化                |
| `engineering-drupal-shopping-cart.md`              | Drupal 购物车工程师     | Drupal Commerce                            |
| `engineering-email-intelligence-engineer.md`       | 邮件智能工程师          | 从邮件线程中提取结构化数据                 |
| `engineering-embedded-firmware-engineer.md`        | 嵌入式固件工程师        | ESP32/ESP-IDF、PlatformIO、STM32、FreeRTOS |
| `engineering-feishu-integration-developer.md`      | 飞书集成开发者          | 飞书/刘克开放平台                          |
| `engineering-filament-optimization-specialist.md`  | Filament 优化专家       | Filament PHP 管理界面                      |
| `engineering-finops-engineer.md`                   | FinOps 工程师           | 云成本优化（AWS/GCP/Azure）                |
| `engineering-frontend-developer.md`                | 前端开发者              | React/Vue/Angular、现代 Web 技术           |
| `engineering-gaussdb-expert.md`                    | GaussDB 专家工程师      | 华为 GaussDB OLTP 优化                     |
| `engineering-git-workflow-master.md`               | Git 工作流大师          | Git 工作流、分支策略、约定式提交           |
| `engineering-i18n-engineer.md`                     | 国际化工程师            | ICU MessageFormat、CLDR、RTL、区域格式     |
| `engineering-identity-access-engineer.md`          | 身份与访问工程师        | OAuth 2.0/OIDC、SSO、通行密钥、WebAuthn    |
| `engineering-incident-response-commander.md`       | 事件响应指挥官          | 生产事件管理                               |
| `engineering-iot-fleet-engineer.md`                | IoT 车队工程师          | 设备配置、OTA 更新、MQTT                   |
| `engineering-it-service-manager.md`                | IT 服务经理             | ITIL 4 框架、服务目录                      |
| `engineering-llm-post-training-engineer.md`        | LLM 后训练工程师        | SFT、RLHF/RLVR、MoE 后训练                 |
| `engineering-minimal-change-engineer.md`           | 最小变更工程师          | 最小可行差异、范围控制                     |
| `engineering-mobile-app-builder.md`                | 移动应用构建器          | iOS/Android/跨平台开发                     |
| `engineering-mobile-release-engineer.md`           | 移动发布工程师          | iOS/Android 发布管道                       |
| `engineering-multi-agent-systems-architect.md`     | 多智能体系统架构师      | 多智能体管道编排                           |
| `engineering-network-engineer.md`                  | 网络工程师              | Cisco/Juniper/Palo Alto networking         |
| `engineering-orgscript-engineer.md`                | OrgScript 工程师        | OrgScript 语法和业务逻辑                   |
| `engineering-payments-billing-engineer.md`         | 支付与计费工程师        | Stripe/Adyen、订阅计费、PCI                |
| `engineering-privacy-engineer.md`                  | 隐私工程师              | PII 分类、同意执行、GDPR                   |
| `engineering-prompt-engineer.md`                   | 提示工程师              | LLM 提示优化和测试                         |
| `engineering-rag-pipeline-engineer.md`             | RAG 管道工程师          | 分块、检索、混合搜索、重排序               |
| `engineering-rapid-prototyper.md`                  | 快速原型师              | 超快速 MVP 开发                            |
| `engineering-realtime-collaboration-engineer.md`   | 实时协作工程师          | WebSocket/SSE、基于 CRDT 的编辑            |
| `engineering-rust-refactoring-specialist.md`       | Rust 重构专家           | Rust 仓库级重构                            |
| `engineering-search-relevance-engineer.md`         | 搜索相关性工程师        | Elasticsearch/OpenSearch 优化              |
| `engineering-section-508-specialist.md`            | Section 508 无障碍专家  | WCAG 2.0/2.1/2.2 AA 合规                   |
| `engineering-senior-developer.md`                  | 高级开发者              | 全栈 Laravel/Livewire/FluxUI               |
| `engineering-software-architect.md`                | 软件架构师              | DDD、架构模式、系统设计                    |
| `engineering-solidity-smart-contract-engineer.md`  | Solidity 智能合约工程师 | EVM 智能合约、DeFi、Gas 优化               |
| `engineering-sre.md`                               | SRE                     | 站点可靠性、SLO、错误预算                  |
| `engineering-technical-writer.md`                  | 技术写手                | 开发者文档、API 参考                       |
| `engineering-uswds-developer.md`                   | USWDS 开发者            | 美国 Web 设计系统                          |
| `engineering-video-streaming-engineer.md`          | 视频流工程师            | HLS/DASH、ffmpeg、CMAF、DRM                |
| `engineering-voice-ai-integration-engineer.md`     | 语音 AI 集成工程师      | 语音转写管道                               |
| `engineering-webassembly-engineer.md`              | WebAssembly 工程师      | Rust/C++/Go 到 Wasm、WASI                  |
| `engineering-wechat-mini-program-developer.md`     | 微信小程序开发者        | 小程序开发                                 |
| `engineering-wordpress-performance.md`             | WordPress 性能工程师    | Core Web Vitals、缓存、优化                |
| `engineering-wordpress-shopping-cart.md`           | WordPress 购物车工程师  | WooCommerce                                |
| `engineering-lsp-index-engineer.md`                | LSP/索引工程师          | 语言服务协议基础设施                       |

#### 安全智能体（13 个）

| 智能体文件                                | 名称                  | 用途                             |
| ----------------------------------------- | --------------------- | -------------------------------- |
| `security-ai-generated-code-auditor.md`   | AI 生成代码安全审计员 | AI 生成代码的安全审查            |
| `security-appsec-engineer.md`             | 应用安全工程师        | SDLC 安全、威胁建模              |
| `security-architect.md`                   | 安全架构师            | 威胁建模、安全设计               |
| `security-blockchain-security-auditor.md` | 区块链安全审计员      | 智能合约安全、形式化验证         |
| `security-cloud-security-architect.md`    | 云安全架构师          | AWS/Azure/GCP 零信任架构         |
| `security-compliance-auditor.md`          | 合规审计员            | SOC 2、ISO 27001、HIPAA、PCI-DSS |
| `security-incident-responder.md`          | 事件响应员            | 数字取证、漏洞响应               |
| `security-penetration-tester.md`          | 渗透测试员            | 进攻性安全、红队                 |
| `security-reviewer.md`                    | security-reviewer     | 通用安全代码审查                 |
| `security-secrets-credential-engineer.md` | 密钥与凭据卫生工程师  | 密钥生命周期管理                 |
| `security-senior-secops.md`               | 高级 SecOps 工程师    | 防御性安全、扫描、控制实施       |
| `security-threat-detection-engineer.md`   | 威胁检测工程师        | SIEM 规则、MITRE ATT&CK 映射     |
| `security-threat-intelligence-analyst.md` | 威胁情报分析师        | 对手跟踪、活动分析               |

#### 营销与增长智能体（35+ 个）

| 智能体文件                                          | 名称                 | 用途                                  |
| --------------------------------------------------- | -------------------- | ------------------------------------- |
| `marketing-aeo-foundations-architect.md`            | AEO 基础架构师       | AI 引擎优化基础设施                   |
| `marketing-agentic-search-optimizer.md`             | 智能体搜索优化师     | WebMCP 对 AI 智能体的就绪性           |
| `marketing-ai-citation-strategist.md`               | AI 引用策略师        | GPT/Claude/Gemini/Perplexity 引用优化 |
| `marketing-app-store-optimizer.md`                  | 应用商店优化师       | ASO 和应用发现                        |
| `marketing-baidu-seo-specialist.md`                 | 百度 SEO 专家        | 百度搜索优化                          |
| `marketing-bilibili-content-strategist.md`          | Bilibili 内容策略师  | Bilibili 平台策略                     |
| `marketing-book-co-author.md`                       | 书籍合著者           | 思想领导力书籍合作                    |
| `marketing-carousel-growth-engine.md`               | 轮播增长引擎         | TikTok/Instagram 轮播生成             |
| `marketing-china-ecommerce-operator.md`             | 中国电商运营师       | 淘宝/天猫/拼多多/京东                 |
| `marketing-china-market-localization-strategist.md` | 中国市场本土化策略师 | 中国 GTM 策略                         |
| `marketing-content-creator.md`                      | 内容创作者           | 多平台活动内容                        |
| `marketing-cross-border-ecommerce-specialist.md`    | 跨境电商专家         | Amazon/Shopee/Lazada/TikTok Shop      |
| `marketing-douyin-strategist.md`                    | 抖音策略师           | 抖音策略                              |
| `marketing-email-strategist.md`                     | 邮件策略师           | CRM 活动、生命周期自动化              |
| `marketing-global-podcast-strategist.md`            | 全球播客策略师       | 多平台播客增长                        |
| `marketing-growth-hacker.md`                        | 增长黑客             | 快速用户获取                          |
| `marketing-instagram-curator.md`                    | Instagram 策展人     | Instagram 视觉叙事                    |
| `marketing-kuaishou-strategist.md`                  | 快手策略师           | 快手平台策略                          |
| `marketing-linkedin-content-creator.md`             | LinkedIn 内容创作者  | LinkedIn 思想领导力                   |
| `marketing-livestream-commerce-coach.md`            | 直播电商教练         | 跨平台直播电商                        |
| `marketing-multi-platform-publisher.md`             | 多平台发布器         | 中文博客发布（知乎/小红书/CSDN）      |
| `marketing-podcast-strategist.md`                   | 播客策略师           | 中国播客市场                          |
| `marketing-pr-communications-manager.md`            | PR 与传播经理        | 媒体关系、新闻稿                      |
| `marketing-private-domain-operator.md`              | 私域运营商           | 企业微信（WeCom）生态                 |
| `marketing-reddit-community-builder.md`             | Reddit 社区构建师    | Reddit 互动                           |
| `marketing-seo-specialist.md`                       | SEO 专家             | 技术 SEO、内容优化                    |
| `marketing-short-video-editing-coach.md`            | 短视频剪辑教练       | CapCut/Premiere 剪辑                  |
| `marketing-social-media-strategist.md`              | 社交媒体策略师       | LinkedIn/Twitter 活动                 |
| `marketing-tiktok-strategist.md`                    | TikTok 策略师        | TikTok 平台策略                       |
| `marketing-twitter-engager.md`                      | Twitter 互动师       | Twitter 对话参与                      |
| `marketing-video-optimization-specialist.md`        | 视频优化专家         | YouTube 算法优化                      |
| `marketing-wechat-official-account.md`              | 微信公众号经理       | 微信 OA 内容营销                      |
| `marketing-weibo-strategist.md`                     | 微博策略师           | 新浪微博运营                          |
| `marketing-x-twitter-intelligence-analyst.md`       | X/Twitter 情报分析师 | X/Twitter 上的社交情报                |
| `marketing-xiaohongshu-specialist.md`               | 小红书专家           | 小红书生活方式营销                    |
| `marketing-zhihu-strategist.md`                     | 知乎策略师           | 知乎知识平台                          |

#### 销售与客户管理智能体（13 个）

| 智能体文件                           | 名称               | 用途                        |
| ------------------------------------ | ------------------ | --------------------------- |
| `sales-account-strategist.md`        | 客户策略师         | 售后深耕和扩展              |
| `sales-coach.md`                     | 销售教练           | 销售代表发展、管线审查      |
| `sales-data-extraction-agent.md`     | 销售数据提取智能体 | Excel 销售指标提取          |
| `sales-deal-strategist.md`           | 交易策略师         | MEDDPICC 资格认定、赢单规划 |
| `sales-discovery-coach.md`           | 发现教练           | 精英发现方法论              |
| `sales-engineer.md`                  | 销售工程师         | 技术售前、演示工程          |
| `sales-offer-lead-gen-strategist.md` | 报价与获客策略师   | 无法抗拒的报价和引流诱饵    |
| `sales-outbound-strategist.md`       | 外呼策略师         | 基于信号的外呼序列          |
| `sales-outreach.md`                  | 销售外联           | B2B 销售外联                |
| `sales-pipeline-analyst.md`          | 管线分析师         | 管线健康诊断                |
| `sales-proposal-strategist.md`       | 提案策略师         | 战略性提案架构              |

#### 设计与 UX 智能体（10 个）

| 智能体文件                               | 名称             | 用途                   |
| ---------------------------------------- | ---------------- | ---------------------- |
| `design-brand-guardian.md`               | 品牌守护者       | 品牌标识和定位         |
| `design-image-prompt-engineer.md`        | 图像提示工程师   | AI 图像生成提示        |
| `design-inclusive-visuals-specialist.md` | 包容性视觉专家   | 文化准确的 AI 视觉     |
| `design-persona-walkthrough.md`          | 人物画像遍历专家 | 基于人物画像的 UX 评估 |
| `design-ui-designer.md`                  | UI 设计师        | 视觉设计系统           |
| `design-ui-finish-gate-reviewer.md`      | UI 完成门审查员  | 界面质量门             |
| `design-ux-architect.md`                 | UX 架构师        | 架构和 CSS 系统        |
| `design-ux-researcher.md`                | UX 研究员        | 用户行为分析           |
| `design-visual-storyteller.md`           | 视觉叙事者       | 视觉传播               |
| `design-whimsy-injector.md`              | 奇思妙想注入器   | 趣味 UI 元素           |

#### 金融与商业策略智能体（8 个）

| 智能体文件                         | 名称           | 用途                   |
| ---------------------------------- | -------------- | ---------------------- |
| `business-strategist.md`           | 商业策略师     | 竞争分析、市场进入     |
| `chief-financial-officer.md`       | 首席财务官     | 战略财务、资本配置     |
| `finance-bookkeeper-controller.md` | 簿记员与控制器 | 会计运营、对账         |
| `finance-financial-analyst.md`     | 财务分析师     | 财务建模、预测         |
| `finance-fpa-analyst.md`           | FP&A 分析师    | 预算、差异分析         |
| `finance-investment-researcher.md` | 投资研究员     | 市场调研、投资组合分析 |
| `finance-tax-strategist.md`        | 税务策略师     | 多辖区税务优化         |

#### GIS 与空间数据智能体（13 个）

| 智能体文件                        | 名称                | 用途                           |
| --------------------------------- | ------------------- | ------------------------------ |
| `gis-3d-scene-developer.md`       | 3D 与场景开发者     | Web 3D（Cesium、ArcGIS Scene） |
| `gis-analyst.md`                  | GIS 分析师          | 日常 GIS 运营                  |
| `gis-bim-specialist.md`           | BIM/GIS 专家        | 建筑信息模型 + GIS             |
| `gis-cartography-designer.md`     | 地图设计设计师      | 地图设计和美学                 |
| `gis-drone-reality-mapping.md`    | 无人机/实景测绘专家 | 摄影测量、正射影像             |
| `gis-geoai-ml-engineer.md`        | GeoAI/ML 工程师     | 空间 ML、特征提取              |
| `gis-geoprocessing-specialist.md` | 地理处理专家        | ArcPy、Model Builder           |
| `gis-qa-engineer.md`              | GIS QA 工程师       | 空间数据质量保证               |
| `gis-solution-engineer.md`        | 解决方案工程师      | GIS 原型构建器                 |
| `gis-spatial-data-engineer.md`    | 空间数据工程师      | 空间 ETL、格式转换             |
| `gis-spatial-data-scientist.md`   | 空间数据科学家      | 空间统计建模                   |
| `gis-technical-consultant.md`     | 技术顾问            | 战略性 GIS 咨询                |
| `gis-web-gis-developer.md`        | Web GIS 开发者      | 交互式地图应用                 |

#### 医疗智能体（6 个）

| 智能体文件                                      | 名称               | 用途             |
| ----------------------------------------------- | ------------------ | ---------------- |
| `healthcare-aging-parent-care-companion.md`     | 老龄父母护理伴侣   | HIPAA 护理协调   |
| `healthcare-clinical-evidence-agent.md`         | 临床证据智能体     | 临床可信度框架   |
| `healthcare-customer-service.md`                | 医疗客服           | 患者支持         |
| `healthcare-innovation-strategist.md`           | 医疗创新策略师     | 医疗叙事架构     |
| `healthcare-marketing-compliance-specialist.md` | 医疗营销合规专家   | 中国医疗营销合规 |
| `healthcare-sovereign-health-systems-agent.md`  | 主权健康系统智能体 | 政府健康任务参与 |

#### 游戏与引擎智能体（17 个）

| 智能体文件                        | 名称                   | 用途                     |
| --------------------------------- | ---------------------- | ------------------------ |
| `blender-addon-engineer.md`       | Blender 插件工程师     | Blender Python 插件开发  |
| `game-audio-engineer.md`          | 游戏音频工程师         | 交互式音频（FMOD/Wwise） |
| `game-designer.md`                | 游戏设计师             | 系统和机制               |
| `godot-gameplay-scripter.md`      | Godot 玩法脚本师       | Godot 4 GDScript         |
| `godot-multiplayer-engineer.md`   | Godot 多人游戏工程师   | Godot 4 networking       |
| `godot-shader-developer.md`       | Godot 着色器开发者     | Godot 4 视觉效果         |
| `unity-architect.md`              | Unity 架构师           | Unity 数据驱动架构       |
| `unity-editor-tool-developer.md`  | Unity 编辑器工具开发者 | Unity 编辑器定制         |
| `unity-multiplayer-engineer.md`   | Unity 多人游戏工程师   | Unity Netcode            |
| `unity-shader-graph-artist.md`    | Unity 着色器图谱艺术家 | Unity Shader Graph       |
| `unreal-multiplayer-architect.md` | Unreal 多人游戏架构师  | Unreal Engine networking |
| `unreal-systems-engineer.md`      | Unreal 系统工程师      | Unreal C++/Blueprint     |
| `unreal-technical-artist.md`      | Unreal 技术艺术家      | Unreal 视觉管道          |
| `unreal-world-builder.md`         | Unreal 世界构建师      | Unreal World Partition   |
| `roblox-avatar-creator.md`        | Roblox 头像创建者      | Roblox UGC 管道          |
| `roblox-experience-designer.md`   | Roblox 体验设计师      | Roblox 体验设计          |
| `roblox-systems-scripter.md`      | Roblox 系统脚本师      | Roblox 平台工程          |

#### 测试与 QA 智能体（9 个）

| 智能体文件                            | 名称             | 用途               |
| ------------------------------------- | ---------------- | ------------------ |
| `testing-accessibility-auditor.md`    | 无障碍审计员     | WCAG 508 无障碍    |
| `testing-api-tester.md`               | API 测试员       | API 测试和验证     |
| `testing-evidence-collector.md`       | 证据收集器       | 基于截图的 QA      |
| `testing-performance-benchmarker.md`  | 性能基准测试员   | 性能基准测试       |
| `testing-reality-checker.md`          | 现实核查员       | 基于证据的认证     |
| `testing-test-automation-engineer.md` | 测试自动化工程师 | Playwright/Cypress |
| `testing-test-results-analyzer.md`    | 测试结果分析员   | 测试结果分析       |
| `testing-tool-evaluator.md`           | 工具评估员       | 工具评估           |
| `testing-workflow-optimizer.md`       | 工作流优化师     | 工作流优化         |

#### 学术与研究智能体（6 个）

| 智能体文件                   | 名称     | 用途               |
| ---------------------------- | -------- | ------------------ |
| `academic-anthropologist.md` | 人类学家 | 文化系统分析       |
| `academic-geographer.md`     | 地理学家 | 自然和人文地理     |
| `academic-historian.md`      | 历史学家 | 历史分析           |
| `academic-narratologist.md`  | 叙事学家 | 叙事理论           |
| `academic-psychologist.md`   | 心理学家 | 人类行为和认知模式 |
| `academic-statistician.md`   | 统计学家 | 定量研究方法       |

#### 专业与基础设施智能体（30+ 个）

| 智能体文件                                        | 名称                      | 用途                     |
| ------------------------------------------------- | ------------------------- | ------------------------ |
| `specialized-chief-of-staff.md`                   | 幕僚长                    | 行政协调                 |
| `specialized-civil-engineer.md`                   | 土木工程师                | 全球土木/结构工程        |
| `specialized-codebase-archaeologist.md`           | 代码库考古学家            | 多工具漂移检测           |
| `specialized-cultural-intelligence-strategist.md` | 文化智能策略师            | 跨文化包容               |
| `specialized-developer-advocate.md`               | 开发者倡导者              | 开发者社区建设           |
| `specialized-document-generator.md`               | 文档生成器                | PDF/PPTX/DOCX/XLSX 生成  |
| `specialized-fedramp-rmf-compliance.md`           | FedRAMP 与 RMF 合规工程师 | FedRAMP 授权             |
| `specialized-french-consulting-market.md`         | 法国咨询市场导航师        | 法国 ESN/SI 市场         |
| `specialized-korean-business-navigator.md`        | 韩国商业导航师            | 韩国商业文化             |
| `specialized-mcp-builder.md`                      | MCP 构建器                | 模型上下文协议服务器     |
| `specialized-model-qa.md`                         | 模型 QA 专家              | ML 模型 QA 和复制        |
| `specialized-pricing-analyst.md`                  | 定价分析师                | 定价模型开发             |
| `specialized-salesforce-architect.md`             | Salesforce 架构师         | Salesforce 多云设计      |
| `specialized-strategy-duel-agent.md`              | 策略对决智能体            | 博弈论策略对决           |
| `specialized-workflow-architect.md`               | 工作流架构师              | 完整工作流树映射         |
| `accounts-payable-agent.md`                       | 应付账款智能体            | 自主付款处理             |
| `agentic-identity-trust-architect.md`             | 智能体身份与信任架构师    | AI 智能体身份/认证       |
| `agents-orchestrator.md`                          | 智能体编排器              | 开发工作流编排           |
| `automation-governance-architect.md`              | 自动化治理架构师          | 业务自动化治理           |
| `change-management-consultant.md`                 | 变革管理顾问              | ADKAR/Kotter/Prosci 框架 |
| `corporate-training-designer.md`                  | 企业培训设计师            | 企业培训系统             |
| `customer-service.md`                             | 客服                      | 专业客户支持             |
| `customer-success-manager.md`                     | 客户成功经理              | 客户成功和留存           |
| `data-consolidation-agent.md`                     | 数据整合智能体            | 销售数据整合             |
| `data-privacy-officer.md`                         | 数据隐私官                | GDPR/CCPA 合规           |
| `hr-onboarding.md`                                | HR 入职                   | 员工入职                 |
| `identity-graph-operator.md`                      | 身份图谱运营商            | 共享身份图谱             |
| `language-translator.md`                          | 语言翻译员                | 西班牙语↔英语翻译        |
| `legal-billing-and-time-tracking.md`              | 法律计费与时间跟踪        | 法律计费专家             |
| `legal-client-intake.md`                          | 法律客户 intake           | 法律客户 intake          |
| `legal-document-review.md`                        | 法律文档审查              | 法律文档审查             |
| `level-designer.md`                               | 关卡设计师                | 空间叙事和流程           |
| `loan-officer-assistant.md`                       | 贷款官员助理              | 房贷/贷款助理            |
| `meeting-notes-specialist.md`                     | 会议记录专家              | 结构化会议纪要           |
| `organizational-psychologist.md`                  | 组织心理学家              | 团队动态分析             |
| `real-estate-buyer-and-seller.md`                 | 房地产买卖                | 房地产交易               |
| `recruitment-specialist.md`                       | 招聘专家                  | 人才招聘                 |
| `report-distribution-agent.md`                    | 报告分发智能体            | 销售报告分发             |
| `resume-tailor.md`                                | 简历定制师                | 简历优化                 |
| `retail-customer-returns.md`                      | 零售客户退货              | 零售退货处理             |
| `sprint-prioritizer.md`                           | 冲刺优先级排序师          | 敏捷冲刺规划             |
| `studio-operations.md`                            | 工作室运营                | 工作室运营管理           |
| `studio-producer.md`                              | 工作室制作人              | 创意项目管理             |
| `trend-researcher.md`                             | 趋势研究员                | 市场情报                 |
| `experiment-tracker.md`                           | 实验追踪器                | 实验设计                 |
| `jira-workflow-steward.md`                        | Jira 工作流管家           | Jira 工作流执行          |
| `project-shepherd.md`                             | 项目牧羊人                | 跨职能项目协调           |
| `paid-media-auditor.md`                           | 付费媒体审计员            | 付费媒体账户审计         |
| `ad-creative-strategist.md`                       | 广告创意策略师            | 付费媒体创意优化         |
| `paid-social-strategist.md`                       | 付费社交策略师            | 跨平台付费社交           |
| `ppc-campaign-strategist.md`                      | PPC 活动策略师            | 搜索/广告活动架构        |
| `programmatic-and-display-buyer.md`               | 程序化与展示购买师        | 展示广告                 |
| `search-query-analyst.md`                         | 搜索查询分析师            | 搜索词分析               |
| `tracking-and-measurement-specialist.md`          | 跟踪与测量专家            | 转化跟踪                 |
| `personal-growth-mentor.md`                       | 个人成长导师              | 个人发展                 |
| `behavioral-nudge-engine.md`                      | 行为助推引擎              | 行为心理学               |
| `feedback-synthesizer.md`                         | 反馈综合师                | 用户反馈分析             |
| `product-manager.md`                              | 产品经理                  | 产品生命周期管理         |
| `supply-chain-strategist.md`                      | 供应链策略师              | 供应链管理               |
| `analytics-reporter.md`                           | 分析报告员                | 数据分析和仪表板         |
| `executive-summary-generator.md`                  | 执行摘要生成器            | 麦肯锡级业务摘要         |
| `finance-tracker.md`                              | 财务追踪员                | 财务规划和预算           |
| `infrastructure-maintainer.md`                    | 基础设施维护员            | 系统可靠性               |
| `legal-compliance-checker.md`                     | 法律合规检查员            | 法律合规                 |
| `support-responder.md`                            | 支持响应员                | 客户支持                 |
| `technical-artist.md`                             | 技术艺术家                | 艺术到工程管道           |
| `terminal-integration-specialist.md`              | 终端集成专家              | 终端模拟                 |
| `study-abroad-advisor.md`                         | 留学顾问                  | 留学规划                 |
| `grants-writer.md`                                | 基金写手                  | 基金撰写和提案           |
| `medical-billing-and-coding-specialist.md`        | 医疗计费与编码专家        | ICD-10/CPT 编码          |
| `narrative-designer.md`                           | 叙事设计师                | 故事系统和对话           |
| `operations-manager.md`                           | 运营经理                  | 业务运营                 |

#### WebAssembly 与流媒体智能体

| 智能体文件                         | 名称               | 用途                  |
| ---------------------------------- | ------------------ | --------------------- |
| `webassembly-engineer.md`          | WebAssembly 工程师 | Wasm 编译和优化       |
| `video-streaming-engineer.md`      | 视频流工程师       | HLS/DASH、ffmpeg 转码 |
| `voice-ai-integration-engineer.md` | 语音 AI 集成工程师 | 语音转写管道          |

#### 新兴技术智能体

| 智能体文件                             | 名称                    | 用途                   |
| -------------------------------------- | ----------------------- | ---------------------- |
| `macos-spatial-metal-engineer.md`      | macOS 空间/Metal 工程师 | Vision Pro、Metal 渲染 |
| `xr-cockpit-interaction-specialist.md` | XR 座舱交互专家         | 沉浸式座舱控制         |
| `xr-immersive-developer.md`            | XR 沉浸式开发者         | WebXR/AR/VR/XR 应用    |
| `xr-interface-architect.md`            | XR 界面架构师           | 空间交互设计           |
| `web-gis-developer.md`                 | Web GIS 开发者          | 交互式地图应用         |

---

## 6. 命令（57 个斜杠命令）

命令是位于 `~/.claude/commands/` 中的 `.md` 文件，带有 YAML frontmatter。每个命令提供通过 `/command-name` 调用的专注工作流模板。

### 6.1 开发工作流命令

| 命令               | 文件                 | 描述                                |
| ------------------ | -------------------- | ----------------------------------- |
| `/tdd`             | `tdd.md`             | 测试驱动开发，要求 80%+ 覆盖率      |
| `/plan`            | `plan.md`            | 需求分析和逐步规划                  |
| `/refactor-clean`  | `refactor-clean.md`  | 代码重构和清理                      |
| `/update-docs`     | `update-docs.md`     | 文档更新                            |
| `/update-codemaps` | `update-codemaps.md` | 代码库地图更新                      |
| `/verify`          | `verify.md`          | 验证：构建 → 测试 → lint → 检查差异 |
| `/quality-gate`    | `quality-gate.md`    | 发布前的质量门检查                  |

### 6.2 多智能体编排命令

| 命令              | 文件                | 描述                                            |
| ----------------- | ------------------- | ----------------------------------------------- |
| `/orchestrate`    | `orchestrate.md`    | 基于角色分配的任务分解                          |
| `/devfleet`       | `devfleet.md`       | 通过 DevFleet MCP 并行智能体编排                |
| `/multi-execute`  | `multi-execute.md`  | 多智能体执行工作流                              |
| `/multi-plan`     | `multi-plan.md`     | 多智能体规划                                    |
| `/multi-workflow` | `multi-workflow.md` | 完整协作工作流（研究→构思→规划→执行→优化→审查） |
| `/multi-backend`  | `multi-backend.md`  | 多模型后端开发                                  |
| `/multi-frontend` | `multi-frontend.md` | 多模型前端开发                                  |
| `/claw`           | `claw.md`           | NanoClaw v2 持久化 REPL                         |

### 6.3 语言特定审查与构建命令

| 命令             | 文件               | 描述            |
| ---------------- | ------------------ | --------------- |
| `/cpp-build`     | `cpp-build.md`     | C++ 构建命令    |
| `/cpp-review`    | `cpp-review.md`    | C++ 代码审查    |
| `/cpp-test`      | `cpp-test.md`      | C++ 测试        |
| `/go-build`      | `go-build.md`      | Go 构建命令     |
| `/go-review`     | `go-review.md`     | Go 代码审查     |
| `/go-test`       | `go-test.md`       | Go 测试         |
| `/kotlin-build`  | `kotlin-build.md`  | Kotlin 构建命令 |
| `/kotlin-review` | `kotlin-review.md` | Kotlin 代码审查 |
| `/kotlin-test`   | `kotlin-test.md`   | Kotlin 测试     |
| `/python-review` | `python-review.md` | Python 代码审查 |
| `/rust-build`    | `rust-build.md`    | Rust 构建命令   |
| `/rust-review`   | `rust-review.md`   | Rust 代码审查   |
| `/rust-test`     | `rust-test.md`     | Rust 测试       |
| `/gradle-build`  | `gradle-build.md`  | Gradle 构建命令 |
| `/code-review`   | `code-review.md`   | 通用代码审查    |

### 6.4 会话管理命令

| 命令              | 文件                | 描述                   |
| ----------------- | ------------------- | ---------------------- |
| `/sessions`       | `sessions.md`       | 会话历史、别名、元数据 |
| `/save-session`   | `save-session.md`   | 保存当前会话状态       |
| `/resume-session` | `resume-session.md` | 加载并恢复已保存的会话 |
| `/checkpoint`     | `checkpoint.md`     | 创建检查点             |
| `/loop-start`     | `loop-start.md`     | 启动循环模式           |
| `/loop-status`    | `loop-status.md`    | 检查循环状态           |
| `/pm2`            | `pm2.md`            | 多进程服务管理         |
| `/setup-pm`       | `setup-pm.md`       | 设置持久化模式         |
| `/model-route`    | `model-route.md`    | 模型路由               |

### 6.5 学习与进化命令

| 命令               | 文件                 | 描述                     |
| ------------------ | -------------------- | ------------------------ |
| `/learn`           | `learn.md`           | 从会话中提取可复用模式   |
| `/learn-eval`      | `learn-eval.md`      | 提取并自我评估模式       |
| `/evolve`          | `evolve.md`          | 分析本能并生成进化结构   |
| `/instinct-export` | `instinct-export.md` | 导出项目本能             |
| `/instinct-import` | `instinct-import.md` | 导入本能                 |
| `/instinct-status` | `instinct-status.md` | 检查本能统计             |
| `/promote`         | `promote.md`         | 将项目本能提升到全局范围 |

### 6.6 技能与质量命令

| 命令             | 文件               | 描述                     |
| ---------------- | ------------------ | ------------------------ |
| `/skill-create`  | `skill-create.md`  | 从 git 历史生成 SKILL.md |
| `/skill-health`  | `skill-health.md`  | 技能组合健康仪表板       |
| `/test-coverage` | `test-coverage.md` | 测试覆盖率报告           |
| `/harness-audit` | `harness-audit.md` | 工具包审计               |
| `/eval`          | `eval.md`          | 评估命令                 |

### 6.7 其他命令

| 命令               | 文件                 | 描述                           |
| ------------------ | -------------------- | ------------------------------ |
| `/aside`           | `aside.md`           | 不丢失上下文的快速侧边问题     |
| `/docs`            | `docs.md`            | 通过 Context7 查找文档         |
| `/e2e`             | `e2e.md`             | 使用 Playwright 进行端到端测试 |
| `/projects`        | `projects.md`        | 列出已知项目和本能统计         |
| `/prompt-optimize` | `prompt-optimize.md` | 提示优化分析                   |

---

## 7. 技能包（125 个目录）

技能包由 `keyword-detector.mjs`（47 KB）中的关键词检测自动触发。每个技能是一个包含 `SKILL.md` 文件的目录。

### 7.1 技能激活机制

1. 用户发送消息
2. `keyword-detector.mjs` 将消息与 47 KB 关键词数据库进行扫描
3. 匹配的关键词触发相关技能
4. `skill-injector.mjs` 将匹配的 SKILL.md 文件加载到上下文中

### 7.2 按类别完整的技能清单

#### 编程语言模式（25 个）

| 技能目录                       | 语言/焦点  | 关键模式                           |
| ------------------------------ | ---------- | ---------------------------------- |
| `python-patterns/`             | Python     | 惯用 Python、类型提示、async/await |
| `python-testing/`              | Python     | pytest、mocking、fixtures          |
| `kotlin-patterns/`             | Kotlin     | 惯用 Kotlin、协程                  |
| `kotlin-testing/`              | Kotlin     | Kotlin 测试框架                    |
| `kotlin-coroutines-flows/`     | Kotlin     | Flow、Channel、StateFlow 模式      |
| `kotlin-exposed-patterns/`     | Kotlin     | Exposed ORM 模式                   |
| `kotlin-ktor-patterns/`        | Kotlin     | Ktor Web 框架模式                  |
| `rust-patterns/`               | Rust       | 所有权、生命周期、异步             |
| `rust-testing/`                | Rust       | 测试框架                           |
| `golang-patterns/`             | Go         | 惯用 Go、通道、context             |
| `golang-testing/`              | Go         | 测试模式                           |
| `cpp-coding-standards/`        | C++        | C++20 最佳实践                     |
| `cpp-testing/`                 | C++        | GoogleTest、Catch2                 |
| `swiftui-patterns/`            | Swift      | SwiftUI 架构                       |
| `swift-concurrency-6-2/`       | Swift      | Actor 模式、async/await            |
| `swift-actor-persistence/`     | Swift      | 并发 + 持久化                      |
| `swift-protocol-di-testing/`   | Swift      | 依赖注入测试                       |
| `typescript/coding-standards/` | TypeScript | 类型模式、泛型                     |
| `perl-patterns/`               | Perl       | Perl 惯用法                        |
| `perl-testing/`                | Perl       | Test::More 模式                    |
| `perl-security/`               | Perl       | 安全模式                           |
| `java-coding-standards/`       | Java       | 企业 Java 模式                     |
| `frontend-patterns/`           | 前端       | 现代前端架构                       |
| `nextjs-turbopack/`            | Next.js    | Turbopack 优化                     |

#### 框架特定技能（12 个）

| 技能目录                   | 框架        | 关键模式                |
| -------------------------- | ----------- | ----------------------- |
| `django-patterns/`         | Django      | ORM、视图、中间件       |
| `django-security/`         | Django      | CSRF、XSS、SQL 注入     |
| `django-tdd/`              | Django      | Django TDD              |
| `django-verification/`     | Django      | Django 验证             |
| `springboot-patterns/`     | Spring Boot | Spring 架构             |
| `springboot-security/`     | Spring Boot | Spring Security、OAuth2 |
| `springboot-tdd/`          | Spring Boot | Spring TDD              |
| `springboot-verification/` | Spring Boot | Spring 验证             |
| `laravel-patterns/`        | Laravel     | Laravel 架构            |
| `laravel-security/`        | Laravel     | Laravel CSRF、XSS、策略 |
| `laravel-tdd/`             | Laravel     | Laravel TDD             |
| `laravel-verification/`    | Laravel     | Laravel 验证            |
| `jpa-patterns/`            | JPA         | JPA/Hibernate 模式      |
| `postgres-patterns/`       | PostgreSQL  | PostgreSQL 优化         |

#### DevOps 与基础设施技能（8 个）

| 技能目录               | 焦点                      |
| ---------------------- | ------------------------- |
| `docker-patterns/`     | Docker 优化、多阶段构建   |
| `deployment-patterns/` | CI/CD、部署策略           |
| `database-migrations/` | 模式迁移模式              |
| `mcp-server-patterns/` | MCP 服务器开发            |
| `clickhouse-io/`       | ClickHouse 分析           |
| `cloudflare-patterns/` | Cloudflare Workers、Pages |
| `vercel/`              | Vercel 部署模式           |
| `railway/`             | Railway 部署模式          |

#### 业务与领域技能（9 个）

| 技能目录                           | 焦点               |
| ---------------------------------- | ------------------ |
| `energy-procurement/`              | 能源行业采购       |
| `inventory-demand-planning/`       | 库存优化           |
| `logistics-exception-management/`  | 物流异常处理       |
| `production-scheduling/`           | 生产计划           |
| `quality-nonconformance/`          | 质量控制           |
| `returns-reverse-logistics/`       | 退货管理           |
| `carrier-relationship-management/` | 承运商管理         |
| `customs-trade-compliance/`        | 海关合规           |
| `investor-materials/`              | 投资人演示文稿创建 |
| `investor-outreach/`               | 投资者关系         |
| `market-research/`                 | 市场调研模式       |

#### 智能体与编排技能（8 个）

| 技能目录                        | 焦点            |
| ------------------------------- | --------------- |
| `autonomous-loops/`             | 自主循环模式    |
| `continuous-learning/`          | 学习系统模式    |
| `continuous-learning-v2/`       | v2 学习系统     |
| `claude-devfleet/`              | DevFleet 编排   |
| `dmux-workflows/`               | Dmux 工作流模式 |
| `parallel-feature-development/` | 并行特性开发    |
| `team-builder/`                 | 团队编排        |
| `enterprise-agent-ops/`         | 企业智能体运营  |

#### 测试与验证技能（6 个）

| 技能目录                 | 焦点               |
| ------------------------ | ------------------ |
| `tdd-workflow/`          | TDD 模式           |
| `verification-loop/`     | 验证循环模式       |
| `e2e-testing/`           | 端到端测试         |
| `ai-regression-testing/` | 基于 AI 的回归测试 |
| `plankton-code-quality/` | Plankton 代码质量  |
| `eval-harness/`          | 评估框架           |

#### 研究与搜索技能（4 个）

| 技能目录                | 焦点                      |
| ----------------------- | ------------------------- |
| `exa-search/`           | 通过 Exa 进行神经营销搜索 |
| `deep-research/`        | 深度研究模式              |
| `search-first/`         | 搜索优先开发              |
| `documentation-lookup/` | 文档搜索                  |

#### 内容与写作技能（9 个）

| 技能目录             | 焦点             |
| -------------------- | ---------------- |
| `content-engine/`    | 内容生成         |
| `crosspost/`         | 多平台发布       |
| `humanizer/`         | 人性化 AI 文本   |
| `humanizer-zh/`      | 中文人性化       |
| `article-writing/`   | 文章写作模式     |
| `rprompt-optimizer/` | 提示优化         |
| `graphify/`          | 图可视化         |
| `zh-code-reviewer/`  | 中文代码审查     |
| `zh-readme/`         | 中文 README 模式 |

#### 特殊工具技能（20+ 个）

| 技能目录                            | 焦点                   |
| ----------------------------------- | ---------------------- |
| `x-api/`                            | 外部 API 集成          |
| `last30days/`                       | 最近 30 天上下文       |
| `blueprint/`                        | 蓝图模式               |
| `nanoclaw-repl/`                    | NanoClaw REPL          |
| `claude-mem/`                       | Claude 记忆模式        |
| `claude-api/`                       | Claude API 模式        |
| `cost-aware-llm-pipeline/`          | 成本优化的 LLM 管道    |
| `iterative-retrieval/`              | 迭代搜索模式           |
| `content-hash-cache-pattern/`       | 内容哈希缓存           |
| `prompt-optimizer/`                 | 提示优化               |
| `strategic-compact/`                | 战略性压缩             |
| `aside/`                            | 侧边问题模式           |
| `build-fix/`                        | 构建修复模式           |
| `security-scan/`                    | 安全扫描               |
| `skill-stocktake/`                  | 技能库存               |
| `security-review/`                  | 安全审查模式           |
| `api-design/`                       | API 设计模式           |
| `foundation-models-on-device/`      | 设备端 ML 模型         |
| `backend-patterns/`                 | 后端架构               |
| `coding-standards/`                 | 通用编码标准           |
| `data-scraper-agent/`               | 网络抓取智能体         |
| `install-demand-planning/`          | 需求计划设置           |
| `pdf-to-markdown-long-task/`        | PDF 处理               |
| `nutrient-document-processing/`     | 文档处理               |
| `visa-doc-translate/`               | 签证文档翻译           |
| `arkham-intelligence-claude-skill/` | Arkham 智能            |
| `composer-multiplatform-patterns/`  | 跨平台 composer        |
| `project-guidelines-example/`       | 项目指南               |
| `regex-vs-llm-structured-text/`     | 正则表达式 vs LLM 文本 |
| `agentic-engineering/`              | 智能体工程             |
| `ai-first-engineering/`             | AI 优先开发            |
| `agent-harness-construction/`       | 智能体工具包构建       |
| `android-clean-architecture/`       | Android 清洁架构       |
| `agent-reach/`                      | 智能体覆盖模式         |
| `c-detailed-design-generator/`      | C 设计生成             |
| `configure-ecc/`                    | ECC 配置               |
| `browser-act/`                      | 浏览器自动化           |
| `fal-ai-media/`                     | Fal AI 媒体生成        |

#### 设计与 UI 技能（5 个）

| 技能目录               | 焦点                     |
| ---------------------- | ------------------------ |
| `frontend-design/`     | 前端设计模式             |
| `frontend-slides/`     | 演示文稿设计             |
| `liquid-glass-design/` | visionOS Liquid Glass UI |
| `videodb/`             | 视频数据库模式           |
| `video-editing/`       | 视频编辑工作流           |

---

## 8. 规则系统

### 8.1 规则架构

规则遵循覆盖模式：**通用默认值 + 语言特定覆盖**。

```
rules/
├── README.md                    # 安装指南
├── common/                      # 通用规则（始终激活）
│   ├── agents.md                # 智能体编排规则
│   ├── coding-style.md          # 不可变性、文件组织、错误处理
│   ├── development-workflow.md  # 研究→规划→TDD→审查→提交
│   ├── git-workflow.md          # 提交格式、PR 工作流
│   ├── hooks.md                 # 钩子类型和权限
│   ├── patterns.md              # 存储库模式、API 响应格式
│   ├── performance.md           # 模型选择、上下文管理
│   ├── security.md              # 提交前的安全检查
│   └── testing.md               # 80%+ 测试覆盖率要求
├── cpp/                         # C++ 规则（5 个文件）
├── golang/                      # Go 规则（5 个文件）
├── kotlin/                      # Kotlin 规则（5 个文件，12KB+ — 最大）
├── perl/                        # Perl 规则（5 个文件）
├── php/                         # PHP 规则（5 个文件）
├── python/                      # Python 规则（5 个文件）
├── swift/                       # Swift 规则（5 个文件）
└── typescript/                  # TypeScript 规则（5 个文件，4.3KB）
```

每个语言目录包含：`coding-style.md`、`hooks.md`、`patterns.md`、`security.md`、`testing.md`

### 8.2 规则优先级

1. **语言特定**规则覆盖**通用**规则
2. 带有具体示例的规则覆盖一般原则
3. 语言规则中的文件引用指向 `../common/` 对应文件
4. 标记为 "> **语言说明**：此规则可能被..."

### 8.3 通用规则摘要

**编码风格（common/coding-style.md）：**

- 不可变性至关重要：始终创建新对象
- 文件组织：许多小文件 > 少量大文件（典型 200-400 行，最大 800）
- 错误处理：始终处理错误，不要静默吞没
- 输入验证：在所有系统边界进行验证
- 标记完成前的代码质量清单

**Git 工作流（common/git-workflow.md）：**

- 约定式提交：`<type>: <description>`（feat、fix、refactor、test、chore、perf、ci）
- PR 工作流：分析完整提交历史，使用 `git diff [base]...HEAD`
- 署名：通过 settings.json 全局禁用

**测试（common/testing.md）：**

- 80%+ 测试覆盖率强制要求
- 所有测试类型必需：单元、集成、E2E
- TDD 工作流：先写测试（RED）→ 实现（GREEN）→ 重构（IMPROVE）
- 智能体支持：主动使用 **tdd-guide** 智能体

**性能（common/performance.md）：**

- Haiku 4.5 用于轻量智能体，Sonnet 4.6 用于主要工作，Opus 4.5 用于深度推理
- 上下文窗口：避免最后 20% 用于大型重构
- 默认启用扩展思维（31,999 个 token 用于推理）

**安全（common/security.md）：**

- 无硬编码密钥
- 参数化查询（SQL 注入）
- XSS 预防、CSRF 保护
- 验证认证/授权
- 所有端点的速率限制
- 错误消息不泄露敏感数据

**模式（common/patterns.md）：**

- 存储库模式：一致的数据访问接口
- API 响应格式：成功信封，包含数据/错误/元数据
- 骨架项目：优先搜索现有实现

### 8.4 规则安装

```bash
# 安装通用 + 语言特定规则
cp -r rules/common ~/.claude/rules/common
cp -r rules/typescript ~/.claude/rules/typescript   # 如果使用 TypeScript
cp -r rules/python ~/.claude/rules/python           # 如果使用 Python
# ... 依此类推，根据您的技术栈
```

---

## 9. 上下文系统

三种执行上下文位于 `~/.claude/contexts/`：

| 上下文 | 文件          | 用途                       | 使用场景                       |
| ------ | ------------- | -------------------------- | ------------------------------ |
| 开发   | `dev.md`      | 先写代码，优先工作解决方案 | `/context dev` — 标准开发      |
| 研究   | `research.md` | 行动前先探索，形成假设     | `/context research` — 调查模式 |
| 审查   | `review.md`   | 按严重程度优先级审查       | `/context review` — 代码审查   |

### 9.1 上下文行为

**dev.md**：先实现，后完善。更改后运行测试。在可行解决方案上迭代。

**research.md**：先研究，后实现。记录发现。用证据验证假设。

**review.md**：按严重性优先级排序：关键 > 高 > 中 > 低。建议具体修复。检查安全、性能、覆盖率。

---

## 10. OMC 集成

### 10.1 Oh My ClaudeCode (OMC) 概述

| 属性      | 值                                                |
| --------- | ------------------------------------------------- |
| 版本      | 4.13.6（本地），5.3.0（GitHub 最新版本）          |
| 仓库      | `https://github.com/Yeachan-Heo/oh-my-claudecode` |
| NPM 包    | `oh-my-claude-sisyphus`                           |
| 作者      | Yeachan Heo（hurrc04@gmail.com）                  |
| 许可证    | MIT                                               |
| Node 要求 | 20.x                                              |     | 22.x |     | 23.x |     | 24.x |     | 25.x |     | 26.x |

### 10.2 OMC 构建系统

```bash
cd ~/.claude/omc
npm install
npm run build    # 运行：tsc + compose-docs + generate:prompt-projections + build:claude-md-coordinator + build:runtime-cli + build:team-server + build:cli
```

**构建步骤顺序：**

1. `generate-skill-entitlements` — 验证技能授权
2. `tsc` — 编译 TypeScript
3. `build-workflow-stage-prompts` — 构建工作流提示
4. `build-skill-bridge` — 构建技能桥
5. `build-mcp-server` — 构建 MCP 服务器
6. `build-bridge-entry` — 构建桥接入口
7. `compose-docs` — 组合文档
8. `generate-prompt-projections` — 生成提示投影
9. `build:claude-md-coordinator` — 构建 Claude.md 协调器
10. `build:runtime-cli` — 构建运行时 CLI
11. `build:team-server` — 构建团队服务器
12. `build:cli` — 构建 CLI

### 10.3 OMC 执行模式

| 模式     | 技能                       | 描述                       | 触发关键词                           |
| -------- | -------------------------- | -------------------------- | ------------------------------------ |
| 自动驾驶 | Full autonomous execution  | 分阶段从想法到可用代码     | "autopilot"、"build me"、"create me" |
| 超工作   | Maximum parallel execution | 生成多个独立智能体         | "ultrawork"、"parallel"、"ulw"       |
| Ralph    | Persistent loop            | 迭代直到所有用户故事通过   | "ralph"、"don't stop"、"finish this" |
| 团队     | N-agent collaboration      | 多个智能体共享任务列表     | "/team N:agent-type"                 |
| UltraQA  | QA loop                    | 测试 → 修复 → 重复直到通过 | "ultraqa"、"qa loop"                 |

### 10.4 OMC 智能体变体（21 个）

| OMC 智能体          | 角色           |
| ------------------- | -------------- |
| analyst             | 数据分析       |
| architect           | 系统设计       |
| code-reviewer       | 代码质量审查   |
| code-simplifier     | 代码简化       |
| critic              | 批判性评估     |
| debugger            | 问题诊断       |
| designer            | UI/UX 设计     |
| document-specialist | 文档           |
| executor            | 代码实现       |
| explore             | 代码探索       |
| git-master          | Git 工作流管理 |
| planner             | 任务规划       |
| qa-tester           | 质量保证       |
| scientist           | 科学研究方法   |
| security-reviewer   | 安全审查       |
| test-engineer       | 测试工程       |
| tracer              | 证据跟踪       |
| verifier            | 变更验证       |
| writer              | 内容撰写       |
| scientist           | 研究方法       |
| designer            | 视觉设计       |

### 10.5 OMC 关键词检测系统

`keyword-detector.mjs`（47 KB）是最大的 OMC 脚本。它：

- 维护全面的关键词数据库，将用户消息映射到智能体/技能
- 在意图检测时触发："build"、"design"、"review"、"test"、"plan" 等
- 对每个技能/智能体与当前上下文的相关性进行评分
- 通过 `skill-injector.mjs` 注入匹配的技能

### 10.6 OMC 调试模式

```bash
export OMC_DEBUG=1
```

启用所有钩子脚本的 `[omc:debug:*]` 前缀输出到 stderr。

---

## 11. 插件系统

### 11.1 内部插件（41 个）

通过 `~/.claude/plugins/marketplaces/claude-plugins-official/` 安装：

| 插件                       | 用途                  |
| -------------------------- | --------------------- |
| `agent-sdk-dev`            | 智能体 SDK 开发       |
| `clangd-lsp`               | C/C++ 语言服务协议    |
| `claude-code-setup`        | Claude Code 配置      |
| `claude-md-management`     | CLAUDE.md 管理        |
| `claude-security`          | 安全指导              |
| `code-modernization`       | 代码现代化模式        |
| `code-review`              | 代码审查自动化        |
| `code-simplifier`          | 代码简化              |
| `commit-commands`          | Git 提交自动化        |
| `csharp-lsp`               | C# 语言服务器         |
| `cwc-makers`               | Maker 模式            |
| `example-plugin`           | 示例/参考插件         |
| `explanatory-output-style` | 解释性输出格式化      |
| `feature-dev`              | 特性开发工作流        |
| `frontend-design`          | 前端设计模式          |
| `gopls-lsp`                | Go 语言服务器         |
| `hookify`                  | 钩子创建和管理        |
| `jdtls-lsp`                | Java 语言服务器       |
| `kotlin-lsp`               | Kotlin 语言服务器     |
| `learning-output-style`    | 学习型输出            |
| `lua-lsp`                  | Lua 语言服务器        |
| `math-olympiad`            | 数学奥林匹克问题解决  |
| `mcp-server-dev`           | MCP 服务器开发        |
| `mcp-tunnels`              | MCP 隧道管理          |
| `php-lsp`                  | PHP 语言服务器        |
| `playground`               | 实验沙箱              |
| `plugin-dev`               | 插件开发              |
| `pr-review-toolkit`        | PR 审查工具           |
| `project-artifact`         | 项目工件管理          |
| `pyright-lsp`              | Python 语言服务器     |
| `ralph-loop`               | Ralph 智能体循环      |
| `receipts`                 | 收据解析              |
| `ruby-lsp`                 | Ruby 语言服务器       |
| `rust-analyzer-lsp`        | Rust 语言服务器       |
| `security-guidance`        | 安全模式              |
| `session-report`           | 会话分析              |
| `skill-creator`            | 技能创建              |
| `swift-lsp`                | Swift 语言服务器      |
| `typescript-lsp`           | TypeScript 语言服务器 |

### 11.2 外部插件家族（16 个）

| 家族            | 用途                |
| --------------- | ------------------- |
| `asana`         | Asana 项目管理集成  |
| `context7`      | 文档查找            |
| `discord`       | Discord 机器人集成  |
| `fakechat`      | 测试用聊天模拟      |
| `firebase`      | Firebase 集成       |
| `github`        | GitHub 操作         |
| `gitlab`        | GitLab 操作         |
| `imessage`      | iMessage 集成       |
| `laravel-boost` | Laravel 增强        |
| `linear`        | Linear 项目管理     |
| `playwright`    | 浏览器自动化        |
| `serena`        | 代码智能            |
| `telegram`      | Telegram 机器人集成 |
| `terraform`     | 基础设施即代码      |

---

## 12. 多智能体编排

### 12.1 DevFleet 集成

DevFleet MCP 服务器（`devfleet` HTTP 服务器）支持并行智能体编排：

```
                    ┌─────────────┐
                    │ Orchestrator│
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
    ┌─────▼─────┐   ┌─────▼─────┐   ┌─────▼─────┐
    │ Agent 1   │   │ Agent 2   │   │ Agent 3   │
    │ (Build)   │   │ (Test)    │   │ (Review)  │
    └───────────┘   └───────────┘   └───────────┘
```

### 12.2 按复杂度选择智能体

| 任务复杂度 | 推荐层级   | 示例用例                     |
| ---------- | ---------- | ---------------------------- |
| 简单       | Haiku 4.5  | 单文件编辑、文档、小修复     |
| 中等       | Sonnet 4.6 | 特性实现、重构、多文件更改   |
| 复杂       | Opus 4.5   | 架构决策、深度研究、战略规划 |

### 12.3 子智能体生命周期

```
SubagentStart → subagent-tracker-subagent.mjs 记录生成事件
    ↓
Subagent 执行（如果指定则使用模型路由）
    ↓
SubagentStop → verify-deliverables-subagent.mjs 检查输出完整性
    ↓
结果合并到主会话上下文
```

---

## 13. 会话与项目管理

### 13.1 会话结构

```
~/.claude/
├── sessions/<session-id>/     # 活动会话
│   ├── tool-results/          # 工具执行结果
│   └── subagents/             # 子智能体输出
├── projects/<project-id>/     # 项目状态
│   ├── state.json             # 项目状态
│   └── subagents/             # 历史子智能体日志
├── tasks/                     # 任务目录
├── shell-snapshots/           # Shell 环境快照（5 个）
├── session-env/               # 会话环境变量（99 个）
├── file-history/              # 文件变更历史（91 个）
└── paste-cache/               # 缓存的粘贴文件
```

### 13.2 项目记忆系统

项目记忆在会话和压缩之间保留上下文：

1. **SessionStart**：`project-memory-session.mjs` 从 `data.cwd` 检测项目目录
2. **PostToolUse**：`project-memory-posttool.mjs` 保存执行状态
3. **PreCompact**：`project-memory-precompact.mjs` 在压缩前保留记忆
4. **动态导入**：所有项目记忆脚本在 `dist/` 缺失时使用 try/catch 和优雅降级

### 13.3 本能系统

本能是从会话中提取的学习模式：

| 命令               | 用途                     |
| ------------------ | ------------------------ |
| `/learn`           | 从当前会话中提取模式     |
| `/learn-eval`      | 提取 + 自我评估模式      |
| `/evolve`          | 从本能生成进化结构       |
| `/instinct-export` | 导出本能                 |
| `/instinct-import` | 导入本能                 |
| `/instinct-status` | 检查统计信息             |
| `/promote`         | 将项目本能提升到全局范围 |

### 13.4 会话保存/恢复

```bash
/save-session <name>     # 保存当前会话状态
/sessions                # 列出所有会话
/resume-session <name>   # 恢复已保存的会话
```

---

## 14. 故障排除

### 14.1 钩子失败

**症状**：钩子崩溃，显示 `ERR_MODULE_NOT_FOUND` 或 `dist/ not found`

**诊断：**

```bash
ls ~/.claude/omc/dist/hooks/project-memory/pre-compact.js
```

**修复：**

```bash
cd ~/.claude/omc
npm install && npm run build
# 或从 GitHub 克隆复制 dist/
```

所有钩子使用开失败模式 — 出错时返回 `{continue: true, suppressOutput: true}`。

### 14.2 模型路由错误

**症状**：`subagent model routing denied`

**修复：**

1. 使用层级别名（`haiku`/`sonnet`/`opus`）而不是提供商特定 ID
2. 在 `settings.json` 中设置 resolver 环境变量：
   - `ANTHROPIC_DEFAULT_SONNET_MODEL`
   - `ANTHROPIC_DEFAULT_OPUS_MODEL`
   - `ANTHROPIC_DEFAULT_HAIKU_MODEL`

### 14.3 过期的 CLAUDE_PLUGIN_ROOT

**症状**：旧插件版本目录的模块未找到

**修复**：`run.cjs` 自动扫描插件缓存以查找最新版本。如果仍然失败，清除 `~/.claude/plugins/` 中的过期目录。

### 14.4 Windows 钩子执行

**症状**：Windows 上 `sh` 是 PE32+ 二进制文件

**修复**：所有 OMC 钩子现在使用 `run.cjs`，直接调用 `process.execPath`。修复了问题 #909、#899、#892、#869。

### 14.5 上下文压缩丢失记忆

**症状**：压缩后项目上下文丢失

**修复：**

1. 验证 PreCompact 钩子返回有效 JSON：`echo '{}' \| node ~/.claude/omc/scripts/project-memory-precompact.mjs`
2. 确保 `dist/` 存在：`ls ~/.claude/omc/dist/`
3. 启用调试：`export OMC_DEBUG=1`

### 14.6 MCP 服务器连接失败

**症状**：日志中 MCP 服务器错误

**修复：**

1. 验证服务器运行：`npx <server> --version`
2. 检查 HTTP 端点：`curl http://localhost:<port>`
3. 重启 Claude Code 会话

### 14.7 JSDOM 中 Vitest 测试超时

**症状**：测试在 5000ms 时超时，显示 `TypeError: Cannot convert undefined or null to object`

**根本原因**：JSDOM FormData 迭代器对 `.keys()` 返回 undefined

**修复：**

```typescript
// 错误：Array.from(formData.keys())
// 正确：
for (const key of Array.from(formData.keys() ?? [])) { ... }
```

---

## 附录 A：组件计数摘要

| 组件类型             | 数量     | 位置                                                      |
| -------------------- | -------- | --------------------------------------------------------- |
| 智能体定义           | 298      | `~/.claude/agents/*.md`                                   |
| 斜杠命令             | 57       | `~/.claude/commands/*.md`                                 |
| 技能目录             | 125      | `~/.claude/skills/*/SKILL.md`                             |
| 规则文件             | 49       | `~/.claude/rules/*/`                                      |
| 上下文文件           | 3        | `~/.claude/contexts/*.md`                                 |
| MCP 服务器           | 24       | `~/.claude/settings.json`                                 |
| 钩子事件类型         | 11       | `~/.claude/settings.json`                                 |
| 独立钩子             | 20       | `~/.claude/settings.json`                                 |
| OMC 脚本             | 40+      | `~/.claude/omc/scripts/`                                  |
| OMC dist 模块        | 83       | `~/.claude/omc/dist/`                                     |
| OMC 智能体变体       | 21       | `~/.claude/omc/agents/`                                   |
| 内部插件             | 41       | `~/.claude/plugins/marketplaces/claude-plugins-official/` |
| 外部插件家族         | 16       | `~/.claude/plugins/marketplaces/claude-plugins-official/` |
| **ECC+OMC 组件总计** | **550+** |                                                           |

## 附录 B：快速参考

### 加载智能体

```
Agent(description: "Architecture review", prompt: "...", subagent_type: "architect")
```

### 使用命令

```
/code-review
/plan
/tdd
/verify
```

### 切换上下文

```
/context dev
/context research
/context review
```

### OMC 执行模式

```
/oh-my-claudecode:autopilot "Build a REST API"
/oh-my-claudecode:ultrawork "Fix all TypeScript errors"
/oh-my-claudecode:ralph "Refactor the payment module"
/oh-my-claudecode:team 3:executor "Implement the 5 endpoints"
/oh-my-claudecode:ultraqa --tests
/oh-my-claudecode:plan "Migrate from Express to Fastify"
/oh-my-claudecode:debug "Why is auth not working?"
/oh-my-claudecode:wiki "Add architecture decisions"
```

### 调试模式

```bash
export OMC_DEBUG=1
```

### 健康检查

```bash
skill-cli doctor
cat ~/.claude/omc/VERSION
```

## 附录 C：文件位置参考

| 资源         | 位置                                                  |
| ------------ | ----------------------------------------------------- |
| 主配置       | `~/.claude/settings.json`                             |
| 插件清单     | `~/.claude/.claude.json`                              |
| 全局规则     | `~/.claude/CLAUDE.md`                                 |
| 智能体       | `~/.claude/agents/*.md`                               |
| 命令         | `~/.claude/commands/*.md`                             |
| 技能         | `~/.claude/skills/*/SKILL.md`                         |
| 规则         | `~/.claude/rules/{common,typescript,python,...}/*.md` |
| 上下文       | `~/.claude/contexts/*.md`                             |
| OMC 根目录   | `~/.claude/omc/`                                      |
| OMC 钩子配置 | `~/.claude/omc/hooks/hooks.json`                      |
| OMC 脚本     | `~/.claude/omc/scripts/*.mjs`                         |
| OMC dist     | `~/.claude/omc/dist/`                                 |
| 插件         | `~/.claude/plugins/marketplaces/`                     |
| 会话         | `~/.claude/sessions/`                                 |
| 项目         | `~/.claude/projects/`                                 |
| MCP 配置     | `~/.claude/settings.json`（mcpServers 部分）          |
| 搜索索引     | `~/.claude/cc-haha/`（SQLite，125 MB）                |
| 会话历史     | `~/.claude/history.jsonl`                             |
| 工具使用统计 | `~/.claude/.session-stats.json`                       |
| 策略限制     | `~/.claude/policy-limits.json`                        |
| 环境变量     | `~/.claude/.env`                                      |
