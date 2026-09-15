<!--
  Created:     2026-09-13  14:00（创建时间）
  Filename:    everything-claude-code_manaul.md（脚本文件名）
  Author:   ______
               / /  (_)
              / /_  /\____  ____  __   ______
             / __ \/ / __ \/ __ \/ /  / /
            / /_/ / / / / / / / / /__/ /
           /_____/_/_/ /_/_/ /_/____  /
          ========== ______________/ /
                         \______________/

  Email:       Binny@vip.163.com
  Group:       SP
  Create By:   Binny
  Purpose:     Everything Claude Code (ECC) 完整手册 v2.0
  Copyright:   TJYM(C) 2010 - All Rights Reserved
  Version:     2.0（版本号）
  LastModify:  2026-09-14（最后一次修改日期）
-->

# Everything Claude Code (ECC) — Complete Manual

## Table of Contents

1. [Overview](#1-overview)
2. [Installation & Architecture](#2-installation--architecture)
3. [Settings Configuration](#3-settings-configuration)
4. [Hook System](#4-hook-system)
5. [Agent System (298 Agents)](#5-agent-system)
6. [Commands (57 Commands)](#6-commands)
7. [Skills (125 Skills)](#7-skills)
8. [Rules System](#8-rules-system)
9. [Context System](#9-context-system)
10. [OMC Integration](#10-omc-integration)
11. [Plugin System](#11-plugin-system)
12. [MCP Servers (24 Servers)](#12-mcp-servers)
13. [Multi-Agent Orchestration](#13-multi-agent-orchestration)
14. [Session & Project Management](#14-session--project-management)
15. [Troubleshooting](#15-troubleshooting)

---

## 1. Overview

**Everything Claude Code (ECC)** is a comprehensive extension system for Claude Code that transforms a single conversational AI assistant into a full-scale engineering organization with:

- **298 specialized agents** covering engineering, security, marketing, sales, GIS, gaming, healthcare, finance, and more
- **57 slash commands** for TDD, multi-agent workflows, code review, session management, and more
- **125 skill packs** with domain-specific patterns, best practices, and framework conventions
- **49 rule files** across 9 programming languages + common rules
- **3 execution contexts** (dev, research, review)
- **24 MCP servers** for external tool integration (browser, GitHub, Vercel, Supabase, etc.)
- **OMC (Oh My Claude Code)** multi-agent orchestration engine with 83 compiled modules
- **41 internal plugins** and **16 external plugin families**
- **Continuous learning system** with instinct extraction and evolution

### Core Design Principles

1. **Immutability**: All outputs create new objects, never mutate existing state
2. **Fail-Open**: Hooks always continue on error, never block the session
3. **Graceful Degradation**: Missing components are silently skipped
4. **Parallel Execution**: Independent agents run in parallel for speed
5. **Language-Specific Overrides**: Per-language rules extend and can override common rules
6. **Keyword-Driven Activation**: Agents and skills auto-trigger based on intent detection

---

## 2. Installation & Architecture

### 2.1 Directory Structure

```
~/.claude/
├── settings.json                    # Main configuration (hooks, MCP, model, permissions)
├── .claude.json                     # Plugin manifest (53 KB)
├── CLAUDE.md                        # Global project rules (copyright headers, orchestration)
├── history.jsonl                    # Session conversation history (181 KB)
├── .env                             # Environment: LiteLLM proxy at localhost:18080
├── policy-limits.json               # Feature restrictions
│
├── agents/                          # 298 agent definition files (.md)
├── commands/                        # 57 slash command files (.md)
├── skills/                          # 125 skill directories (each with SKILL.md)
├── rules/                           # 49 rule files across 10 directories
├── contexts/                        # 3 context files (dev.md, research.md, review.md)
│
├── omc/                             # Oh My ClaudeCode v4.13.6
│   ├── VERSION                      # "4.13.6"
│   ├── CHANGELOG.md                 # Release notes
│   ├── LICENSE                      # MIT
│   ├── hooks/hooks.json             # Hook definitions (213 lines)
│   ├── skills/                      # 11 hook subdirectories + 9 rule subdirectories
│   ├── scripts/                     # 40+ OMC script files (.mjs/.cjs)
│   ├── dist/                        # Compiled TypeScript (83 module dirs)
│   ├── agents/                      # 21 OMC agent variants (.md)
│   ├── templates/                   # 5 template dirs (deliverables, hooks, rules, skills, scripts)
│   ├── .claude-plugin/              # Plugin metadata
│   └── .claude-plugin/marketplace.json
│
├── plugins/                         # Plugin marketplace
│   └── marketplaces/
│       ├── claude-plugins-official/  # 41 internal plugins + 16 external families
│       └── superpowers-marketplace/  # Git hooks integration
│
├── projects/                        # 31 per-project session directories
├── sessions/                        # 8 active session directories
├── tasks/                           # 24 task directories
├── session-env/                     # 99 session environment directories
├── file-history/                    # 91 file history entries
├── shell-snapshots/                 # 5 zsh shell snapshots
├── paste-cache/                     # Cached paste files
├── telemetry/                       # Failed telemetry events
├── backups/                         # 5 .claude.json backups
├── cc-haha/                         # SQLite search index (125 MB)
├── ide/                             # IDE lock file
├── cache/                           # Local model cache
├── .runtime/                        # Python 3.13 venv for OMC runtime
└── .session-stats.json              # Per-session tool usage statistics
```

### 2.2 Model Configuration

| Component     | Value                                                                              |
| ------------- | ---------------------------------------------------------------------------------- |
| Session Model | Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q8_K_P.gguf                         |
| Model Path    | `/Users/a1/Models/guff/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q8_K_P.gguf` |
| API Proxy     | `http://localhost:18080/v1` (LiteLLM)                                              |
| API Key       | `sk-any-local-key` (local only, no remote API calls)                               |
| Model Family  | Qwen3.6 35B parameter, ~33B active, Q8_K quantization                              |

### 2.3 Component Summary

| Component                    | Count    |
| ---------------------------- | -------- |
| Agent definitions            | 298      |
| Slash commands               | 57       |
| Skill directories            | 125      |
| Rule files                   | 49       |
| Context files                | 3        |
| MCP servers                  | 24       |
| Hook event types             | 11       |
| Individual hooks             | 20       |
| OMC scripts                  | 40+      |
| OMC dist modules             | 83       |
| OMC agent variants           | 21       |
| Internal plugins             | 41       |
| External plugin families     | 16       |
| **Total ECC+OMC components** | **550+** |

---

## 3. Settings Configuration

`~/.claude/settings.json` is the central configuration file (~6.4 KB) containing hooks, MCP servers, model routing, and permissions.

### 3.1 Hooks Configuration

11 hook event types with 20 individual hook commands, all invoked via `scripts/run.cjs` (cross-platform runner).

| Hook Event           | Hook Count | Hook Scripts                                                                     |
| -------------------- | ---------- | -------------------------------------------------------------------------------- |
| `SessionStart`       | 5          | project-memory-session, keyword-detector, skill-injector, wiki-session, omc-init |
| `SessionEnd`         | 2          | session-end, wiki-session-end                                                    |
| `PreToolUse`         | 1          | pre-tool-enforcer                                                                |
| `PostToolUse`        | 3          | post-tool-verifier, project-memory-posttool, rules-injector-posttool             |
| `PostToolUseFailure` | 1          | post-tool-failure-handler                                                        |
| `SubagentStart`      | 1          | subagent-tracker-subagent                                                        |
| `SubagentStop`       | 2          | subagent-tracker-stop, verify-deliverables-subagent                              |
| `PreCompact`         | 3          | pre-compact, project-memory-precompact, wiki-pre-compact                         |
| `Stop`               | 3          | context-guard, persistent-mode, code-simplifier                                  |
| `UserPromptSubmit`   | 2          | keyword-detector, skill-injector                                                 |
| `PermissionRequest`  | 1          | permission-handler                                                               |

### 3.2 MCP Servers (24)

Organized by category:

**Browser Automation (3):**

- `browser-use` (HTTP) — AI-driven browser interaction
- `browserbase` (npx) — Cloud browser sessions
- `playwright` (npx) — Direct Playwright automation

**Documentation Search (2):**

- `context7` (npx) — Library/API documentation lookup
- `cloudflare-docs` (HTTP) — Cloudflare documentation search

**Web Search & Scraping (2):**

- `exa-web-search` (npx) — Neural search powered by Exa AI
- `firecrawl` (npx) — Web scraping and content extraction

**GitHub Ecosystem (2):**

- `github` (npx) — Full GitHub operations (issues, PRs, search, code)
- `confluence` (npx) — Atlassian Confluence search and management

**Deployment (3):**

- `vercel` (HTTP) — Vercel deployment operations
- `railway` (npx) — Railway deployment operations
- `cloudflare-workers-build` (HTTP) — Workers build pipeline

**Cloudflare Suite (3):**

- `cloudflare-observability` (HTTP) — Logs and metrics
- `cloudflare-workers-bindings` (HTTP) — TypeScript bindings generation
- `cloudflare-docs` (HTTP) — Documentation search

**Database (1):**

- `supabase` (npx) — Supabase database operations

**Analytics (1):**

- `clickhouse` (HTTP) — Analytics and log queries

**AI/ML (2):**

- `fal-ai` (npx) — Image/video/audio generation via Fal
- `sequential-thinking` (npx) — Chain-of-thought reasoning

**Security (1):**

- `insaits` (Python3) — AI security monitoring

**UI Components (1):**

- `magic` (npx) — Magic UI component generation

**Infrastructure (2):**

- `filesystem` (npx) — File system operations
- `memory` (npx) — Persistent memory system

**Optimization (1):**

- `token-optimizer` (npx) — Context window compression

**Development (1):**

- `devfleet` (HTTP) — Multi-agent orchestration (parallel tasks)

**Server Types:** HTTP (6) | npx (17) | Python3 (1)

### 3.3 Plugin Permissions

```json
"allowedTools": {
    "Bash": { "mode": "default" }
}
```

Bash commands require user approval by default.

### 3.4 Policy Limits

`policy-limits.json` disables specific features:

| Feature         | Status   |
| --------------- | -------- |
| `remoteControl` | Disabled |
| `routines`      | Disabled |
| `quick-web`     | Disabled |
| `cobalt-plinth` | Disabled |

---

## 4. Hook System Deep Dive

### 4.1 Hook Runner (`omc/scripts/run.cjs`)

The `run.cjs` script is the backbone of all OMC hooks. It solves cross-platform hook execution:

**Key Features:**

- **Cross-platform**: Uses `process.execPath` to find the correct Node binary (works on Windows where `/usr/bin/sh` is a PE32+ binary)
- **Stale path recovery**: If `CLAUDE_PLUGIN_ROOT` points to a deleted/old version, scans the plugin cache for the latest matching version
- **Timeout enforcement**: Reads timeout from `hooks.json`, kills hooks that exceed the limit
- **Fail-open**: Always exits cleanly (code 0) so Claude Code hooks are never blocked

**Usage Pattern:**

```bash
node "$CLAUDE_PLUGIN_ROOT/scripts/run.cjs" \
    "$CLAUDE_PLUGIN_ROOT/scripts/<hook-name>.mjs" \
    [hook-arguments]
```

### 4.2 Hook Execution Flow

```
Session Start
  ├── [SessionStart] project-memory-session.mjs
  │     └── Detects project directory, registers project memory context
  ├── [SessionStart] keyword-detector.mjs
  │     └── Scans user message for intent keywords (47 KB keyword database)
  ├── [SessionStart] skill-injector.mjs
  │     └── Injects relevant skills based on detected keywords (13 KB)
  ├── [SessionStart] wiki-session.mjs
  │     └── Sets up wiki system for session
  └── [SessionStart] omc-init.mjs
        └── Initializes OMC orchestration layer

User Sends Prompt
  ├── [UserPromptSubmit] keyword-detector.mjs
  │     └── Re-detects intent from user message
  └── [UserPromptSubmit] skill-injector.mjs
        └── Loads skills matched to detected keywords

Pre-Tool Execution
  └── [PreToolUse] pre-tool-enforcer.mjs
        └── Validates tool parameters, enforces rules

Tool Executes (Read, Bash, Write, Edit, Agent, etc.)
  ├── [PostToolUse] post-tool-verifier.mjs
  │     └── Verifies tool output quality and completeness
  ├── [PostToolUse] project-memory-posttool.mjs
  │     └── Saves execution state to project memory
  └── [PostToolUse] rules-injector-posttool.mjs
        └── Injects relevant rules based on tool used

  └── [PostToolUseFailure] (if tool failed)
        └── Failure handling and recovery

Subagent Lifecycle
  ├── [SubagentStart] subagent-tracker-subagent.mjs
  │     └── Logs subagent spawn, starts tracking
  └── [SubagentStop] subagent-tracker-stop.mjs
        └── Logs subagent completion
       └── verify-deliverables-subagent.mjs
            └── Checks subagent output for completeness

Pre-Context Compaction
  ├── [PreCompact] pre-compact.mjs
  │     └── General pre-compaction hooks
  ├── [PreCompact] project-memory-precompact.mjs
  │     └── Preserves project memory before compaction
  └── [PreCompact] wiki-pre-compact.mjs
        └── Saves wiki state before compaction

Session Stop
  ├── [Stop] context-guard.mjs
  │     └── Preserves critical context
  ├── [Stop] persistent-mode.mjs (52 KB)
  │     └── Checks and manages persistent session state
  └── [Stop] code-simplifier.mjs (5 KB)
        └── Simplifies code on session end

Session End
  ├── [SessionEnd] session-end.mjs
  │     └── Final session cleanup
  └── [SessionEnd] wiki-session-end.mjs
        └── Updates wiki with session findings
```

### 4.3 OMC Core Scripts

| Script                          | Size  | Purpose                                                |
| ------------------------------- | ----- | ------------------------------------------------------ |
| `keyword-detector.mjs`          | 47 KB | Detects user intent from messages via keyword matching |
| `skill-injector.mjs`            | 13 KB | Injects relevant skills based on detected keywords     |
| `session-start.mjs`             | 38 KB | Session initialization with model routing              |
| `pre-tool-enforcer.mjs`         | 41 KB | Enforces rules before tool execution                   |
| `post-tool-verifier.mjs`        | 38 KB | Verifies tool output quality                           |
| `persistent-mode.mjs`           | 52 KB | Manages long-running persistent sessions               |
| `project-memory-session.mjs`    | 3 KB  | Project-scoped memory detection                        |
| `project-memory-precompact.mjs` | —     | Pre-compaction memory preservation                     |
| `project-memory-posttool.mjs`   | —     | Post-tool state saving                                 |
| `subagent-tracker.mjs`          | 1 KB  | Tracks subagent lifecycle                              |
| `verify-deliverables.mjs`       | 8 KB  | Verifies subagent output completeness                  |
| `permission-handler.mjs`        | —     | Handles Bash permission prompts                        |
| `code-simplifier.mjs`           | 5 KB  | Simplifies code during session end                     |
| `run.cjs`                       | —     | Cross-platform hook runner                             |

### 4.4 OMC dist/ Modules

The `dist/` directory (compiled TypeScript) contains 83 module directories:

| Module                       | Count | Purpose                              |
| ---------------------------- | ----- | ------------------------------------ |
| `autopilot/`                 | 52    | Autonomous workflow execution        |
| `learner/`                   | 70    | Continuous learning from sessions    |
| `factcheck/`                 | 23    | Fact verification and claim checking |
| `project-memory/`            | 47    | Project context preservation         |
| `ralph/`                     | 26    | Persistent loop orchestration        |
| `persistent-mode/`           | 23    | Persistent session management        |
| `team-pipeline/`             | 19    | Team-based task pipelines            |
| `subagent-tracker/`          | 19    | Subagent lifecycle tracking          |
| `think-mode/`                | 19    | Thinking mode implementation         |
| `wiki/`                      | 31    | Session wiki management              |
| `keyword-detector/`          | 7     | Keyword intent detection             |
| `pre-compact/`               | 10    | Pre-compaction handling              |
| `agents-overlay/`            | —     | Agent overlay system                 |
| `auto-slash-command/`        | —     | Auto slash command generation        |
| `bridge/`                    | —     | Bridge between OMC and Claude Code   |
| `codebase-map/`              | —     | Codebase structure mapping           |
| `directory-readme-injector/` | —     | Auto-generates README files          |
| `merge-readiness/`           | —     | Merge readiness checks               |
| `mode-registry/`             | —     | Mode registration system             |
| `notepad/`                   | —     | Session notepad                      |
| `omc-orchestrator/`          | —     | OMC orchestration core               |
| `permission-handler/`        | —     | Permission handling                  |
| `skill-bridge/`              | —     | Skill bridge system                  |
| `task-size-detector/`        | —     | Detects task complexity              |
| `team-dispatch-hook/`        | —     | Team task dispatch                   |
| `team-worker-hook/`          | —     | Team worker management               |
| `todo-continuation/`         | —     | TODO list persistence                |
| `thinking-block-validator/`  | —     | Validates thinking blocks            |
| `non-interactive-env/`       | —     | Non-interactive environment handling |

---

## 5. Agent System (298 Agents)

Agents are `.md` files in `~/.claude/agents/` that define specialized AI personas. Each agent has:

- **YAML frontmatter**: `name`, `description`, `tools`, optional `model` override
- **Description**: Keywords that trigger automatic loading
- **Tools**: Which tools the agent has access to (All tools, or specific subset)
- **Model**: Optional tier override (haiku/sonnet/opus)

### 5.1 Agent Format

```yaml
---
name: architect
description: Software architect specializing in system design...
tools: ['Read', 'Grep', 'Glob', 'Write', 'Edit', 'Bash']
model: opus
---
Agent body content with specific instructions...
```

### 5.2 Complete Agent Inventory by Category

#### Engineering & Build Agents (25)

| Agent File                 | Name                  | Purpose                                                     |
| -------------------------- | --------------------- | ----------------------------------------------------------- |
| `architect.md`             | architect             | System design, domain-driven design, architectural patterns |
| `build-error-resolver.md`  | build-error-resolver  | Fix compilation/build errors                                |
| `code-reviewer.md`         | code-reviewer         | Expert code review (correctness, security, performance)     |
| `database-reviewer.md`     | database-reviewer     | Database schema and query review                            |
| `doc-updater.md`           | doc-updater           | Documentation updates                                       |
| `planner.md`               | planner               | Implementation planning and task breakdown                  |
| `refactor-cleaner.md`      | refactor-cleaner      | Dead code cleanup, refactoring                              |
| `security-reviewer.md`     | security-reviewer     | Security analysis                                           |
| `tdd-guide.md`             | tdd-guide             | Test-driven development (80%+ coverage)                     |
| `cpp-build-resolver.md`    | cpp-build-resolver    | C++ build error resolution                                  |
| `cpp-reviewer.md`          | cpp-reviewer          | C++ code review                                             |
| `docs-lookup.md`           | docs-lookup           | Documentation lookup                                        |
| `e2e-runner.md`            | e2e-runner            | End-to-end testing                                          |
| `go-build-resolver.md`     | go-build-resolver     | Go build error resolution                                   |
| `go-reviewer.md`           | go-reviewer           | Go code review                                              |
| `harness-optimizer.md`     | harness-optimizer     | Test harness optimization                                   |
| `java-build-resolver.md`   | java-build-resolver   | Java build error resolution                                 |
| `java-reviewer.md`         | java-reviewer         | Java code review                                            |
| `kotlin-build-resolver.md` | kotlin-build-resolver | Kotlin build error resolution                               |
| `kotlin-reviewer.md`       | kotlin-reviewer       | Kotlin code review                                          |
| `loop-operator.md`         | loop-operator         | Loop management                                             |
| `python-reviewer.md`       | python-reviewer       | Python code review                                          |
| `rust-build-resolver.md`   | rust-build-resolver   | Rust build error resolution                                 |
| `rust-reviewer.md`         | rust-reviewer         | Rust code review                                            |
| `database-optimizer.md`    | database-optimizer    | PostgreSQL, MySQL, indexing, query optimization             |

#### AI/ML & Data Engineering Agents (50+)

| Agent File                                         | Name                                 | Purpose                                                   |
| -------------------------------------------------- | ------------------------------------ | --------------------------------------------------------- |
| `engineering-ai-data-remediation-engineer.md`      | AI Data Remediation Engineer         | Self-healing data pipelines with local SLMs               |
| `engineering-ai-engineer.md`                       | AI Engineer                          | ML model development and deployment                       |
| `engineering-api-platform-engineer.md`             | API Platform Engineer                | Public/partner API platform design                        |
| `engineering-autonomous-optimization-architect.md` | Autonomous Optimization Architect    | Continuous API performance + cost optimization            |
| `engineering-backend-architect.md`                 | Backend Architect                    | Scalable system architecture, microservices               |
| `engineering-cms-developer.md`                     | CMS Developer                        | Drupal/WordPress theme and plugin development             |
| `engineering-code-reviewer.md`                     | Engineering Code Reviewer            | Code review for engineering projects                      |
| `engineering-codebase-onboarding-engineer.md`      | Codebase Onboarding Engineer         | Help understand unfamiliar codebases                      |
| `engineering-data-engineer.md`                     | Data Engineer                        | Data pipelines, lakehouse, ETL/ELT, Spark, dbt            |
| `engineering-data-visualization-engineer.md`       | Data Visualization Engineer          | Chart design, D3, Vega, perceptually honest encodings     |
| `engineering-database-optimizer.md`                | Database Optimizer                   | Schema design, query optimization, indexing               |
| `engineering-database-reliability-engineer.md`     | Database Reliability Engineer        | High availability, replication, backups                   |
| `engineering-desktop-app-engineer.md`              | Desktop App Engineer                 | Electron/Tauri desktop applications                       |
| `engineering-developer-tooling-engineer.md`        | Developer Tooling Engineer           | CLI tools, internal developer platforms                   |
| `engineering-devops-automator.md`                  | DevOps Automator                     | CI/CD, infrastructure automation                          |
| `engineering-drupal-performance.md`                | Drupal Performance Engineer          | Drupal Core Web Vitals optimization                       |
| `engineering-drupal-shopping-cart.md`              | Drupal Shopping Cart Engineer        | Drupal Commerce                                           |
| `engineering-email-intelligence-engineer.md`       | Email Intelligence Engineer          | Extract structured data from email threads                |
| `engineering-embedded-firmware-engineer.md`        | Embedded Firmware Engineer           | ESP32/ESP-IDF, PlatformIO, STM32, FreeRTOS                |
| `engineering-feishu-integration-developer.md`      | Feishu Integration Developer         | Feishu/Lark Open Platform                                 |
| `engineering-filament-optimization-specialist.md`  | Filament Optimization Specialist     | Filament PHP admin interfaces                             |
| `engineering-finops-engineer.md`                   | FinOps Engineer                      | Cloud cost optimization (AWS/GCP/Azure)                   |
| `engineering-frontend-developer.md`                | Frontend Developer                   | React/Vue/Angular, modern web technologies                |
| `engineering-gaussdb-expert.md`                    | GaussDB Expert Engineer              | Huawei GaussDB OLTP optimization                          |
| `engineering-git-workflow-master.md`               | Git Workflow Master                  | Git workflows, branching strategies, conventional commits |
| `engineering-i18n-engineer.md`                     | Internationalization Engineer        | ICU MessageFormat, CLDR, RTL, locale formatting           |
| `engineering-identity-access-engineer.md`          | Identity & Access Engineer           | OAuth 2.0/OIDC, SSO, passkeys, WebAuthn                   |
| `engineering-incident-response-commander.md`       | Incident Response Commander          | Production incident management                            |
| `engineering-iot-fleet-engineer.md`                | IoT Fleet Engineer                   | Device provisioning, OTA updates, MQTT                    |
| `engineering-it-service-manager.md`                | IT Service Manager                   | ITIL 4 framework, service catalog                         |
| `engineering-llm-post-training-engineer.md`        | LLM Post-Training Engineer           | SFT, RLHF/RLVR, MoE post-training                         |
| `engineering-minimal-change-engineer.md`           | Minimal Change Engineer              | Minimum-viable diffs, scope control                       |
| `engineering-mobile-app-builder.md`                | Mobile App Builder                   | iOS/Android/cross-platform development                    |
| `engineering-mobile-release-engineer.md`           | Mobile Release Engineer              | iOS/Android release pipelines                             |
| `engineering-multi-agent-systems-architect.md`     | Multi-Agent Systems Architect        | Multi-agent pipeline orchestration                        |
| `engineering-network-engineer.md`                  | Network Engineer                     | Cisco/Juniper/Palo Alto networking                        |
| `engineering-orgscript-engineer.md`                | OrgScript Engineer                   | OrgScript grammar and business logic                      |
| `engineering-payments-billing-engineer.md`         | Payments & Billing Engineer          | Stripe/Adyen, subscription billing, PCI                   |
| `engineering-privacy-engineer.md`                  | Privacy Engineer                     | PII classification, consent enforcement, GDPR             |
| `engineering-prompt-engineer.md`                   | Prompt Engineer                      | LLM prompt optimization and testing                       |
| `engineering-rag-pipeline-engineer.md`             | RAG Pipeline Engineer                | Chunking, retrieval, hybrid search, re-ranking            |
| `engineering-rapid-prototyper.md`                  | Rapid Prototyper                     | Ultra-fast MVP development                                |
| `engineering-realtime-collaboration-engineer.md`   | Realtime Collaboration Engineer      | WebSocket/SSE, CRDT-based editing                         |
| `engineering-rust-refactoring-specialist.md`       | Rust Refactoring Specialist          | Rust repository-scale refactoring                         |
| `engineering-search-relevance-engineer.md`         | Search Relevance Engineer            | Elasticsearch/OpenSearch optimization                     |
| `engineering-section-508-specialist.md`            | Section 508 Accessibility Specialist | WCAG 2.0/2.1/2.2 AA compliance                            |
| `engineering-senior-developer.md`                  | Senior Developer                     | Full-stack Laravel/Livewire/FluxUI                        |
| `engineering-software-architect.md`                | Software Architect                   | DDD, architectural patterns, system design                |
| `engineering-solidity-smart-contract-engineer.md`  | Solidity Smart Contract Engineer     | EVM smart contracts, DeFi, gas optimization               |
| `engineering-sre.md`                               | SRE                                  | Site reliability, SLOs, error budgets                     |
| `engineering-technical-writer.md`                  | Technical Writer                     | Developer documentation, API references                   |
| `engineering-uswds-developer.md`                   | USWDS Developer                      | U.S. Web Design System                                    |
| `engineering-video-streaming-engineer.md`          | Video Streaming Engineer             | HLS/DASH, ffmpeg, CMAF, DRM                               |
| `engineering-voice-ai-integration-engineer.md`     | Voice AI Integration Engineer        | Speech transcription pipelines                            |
| `engineering-webassembly-engineer.md`              | WebAssembly Engineer                 | Rust/C++/Go to Wasm, WASI                                 |
| `engineering-wechat-mini-program-developer.md`     | WeChat Mini Program Developer        | 小程序 development                                        |
| `engineering-wordpress-performance.md`             | WordPress Performance Engineer       | Core Web Vitals, caching, optimization                    |
| `engineering-wordpress-shopping-cart.md`           | WordPress Shopping Cart Engineer     | WooCommerce                                               |
| `engineering-lsp-index-engineer.md`                | LSP/Index Engineer                   | Language Server Protocol infrastructure                   |

#### Security Agents (13)

| Agent File                                | Name                                  | Purpose                                              |
| ----------------------------------------- | ------------------------------------- | ---------------------------------------------------- |
| `security-ai-generated-code-auditor.md`   | AI-Generated Code Security Auditor    | Security review of AI-generated code                 |
| `security-appsec-engineer.md`             | Application Security Engineer         | SDLC security, threat modeling                       |
| `security-architect.md`                   | Security Architect                    | Threat modeling, secure-by-design                    |
| `security-blockchain-security-auditor.md` | Blockchain Security Auditor           | Smart contract security, formal verification         |
| `security-cloud-security-architect.md`    | Cloud Security Architect              | AWS/Azure/GCP zero-trust architecture                |
| `security-compliance-auditor.md`          | Compliance Auditor                    | SOC 2, ISO 27001, HIPAA, PCI-DSS                     |
| `security-incident-responder.md`          | Incident Responder                    | Digital forensics, breach response                   |
| `security-penetration-tester.md`          | Penetration Tester                    | Offensive security, red team                         |
| `security-reviewer.md`                    | security-reviewer                     | General security code review                         |
| `security-secrets-credential-engineer.md` | Secrets & Credential Hygiene Engineer | Secret lifecycle management                          |
| `security-senior-secops.md`               | Senior SecOps Engineer                | Defensive security, scanning, control implementation |
| `security-threat-detection-engineer.md`   | Threat Detection Engineer             | SIEM rules, MITRE ATT&CK mapping                     |
| `security-threat-intelligence-analyst.md` | Threat Intelligence Analyst           | Adversary tracking, campaign analysis                |

#### Marketing & Growth Agents (35+)

| Agent File                                          | Name                                 | Purpose                                            |
| --------------------------------------------------- | ------------------------------------ | -------------------------------------------------- |
| `marketing-aeo-foundations-architect.md`            | AEO Foundations Architect            | AI Engine Optimization infrastructure              |
| `marketing-agentic-search-optimizer.md`             | Agentic Search Optimizer             | WebMCP readiness for AI agents                     |
| `marketing-ai-citation-strategist.md`               | AI Citation Strategist               | GPT/Claude/Gemini/Perplexity citation optimization |
| `marketing-app-store-optimizer.md`                  | App Store Optimizer                  | ASO and app discoverability                        |
| `marketing-baidu-seo-specialist.md`                 | Baidu SEO Specialist                 | Baidu search optimization                          |
| `marketing-bilibili-content-strategist.md`          | Bilibili Content Strategist          | Bilibili platform strategy                         |
| `marketing-book-co-author.md`                       | Book Co-Author                       | Thought-leadership book collaboration              |
| `marketing-carousel-growth-engine.md`               | Carousel Growth Engine               | TikTok/Instagram carousel generation               |
| `marketing-china-ecommerce-operator.md`             | China E-Commerce Operator            | Taobao/Tmall/Pinduoduo/JD                          |
| `marketing-china-market-localization-strategist.md` | China Market Localization Strategist | China GTM strategy                                 |
| `marketing-content-creator.md`                      | Content Creator                      | Multi-platform campaign content                    |
| `marketing-cross-border-ecommerce-specialist.md`    | Cross-Border E-Commerce Specialist   | Amazon/Shopee/Lazada/TikTok Shop                   |
| `marketing-douyin-strategist.md`                    | Douyin Strategist                    | Douyin (TikTok China) strategy                     |
| `marketing-email-strategist.md`                     | Email Strategist                     | CRM campaigns, lifecycle automation                |
| `marketing-global-podcast-strategist.md`            | Global Podcast Strategist            | Multi-platform podcast growth                      |
| `marketing-growth-hacker.md`                        | Growth Hacker                        | Rapid user acquisition                             |
| `marketing-instagram-curator.md`                    | Instagram Curator                    | Instagram visual storytelling                      |
| `marketing-kuaishou-strategist.md`                  | Kuaishou Strategist                  | Kuaishou platform strategy                         |
| `marketing-linkedin-content-creator.md`             | LinkedIn Content Creator             | LinkedIn thought leadership                        |
| `marketing-livestream-commerce-coach.md`            | Livestream Commerce Coach            | Live commerce across platforms                     |
| `marketing-multi-platform-publisher.md`             | Multi-Platform Publisher             | Chinese blog publishing (知乎/小红书/CSDN)         |
| `marketing-podcast-strategist.md`                   | Podcast Strategist                   | Chinese podcast market                             |
| `marketing-pr-communications-manager.md`            | PR & Communications Manager          | Media relations, press releases                    |
| `marketing-private-domain-operator.md`              | Private Domain Operator              | Enterprise WeChat (WeCom) ecosystems               |
| `marketing-reddit-community-builder.md`             | Reddit Community Builder             | Reddit engagement                                  |
| `marketing-seo-specialist.md`                       | SEO Specialist                       | Technical SEO, content optimization                |
| `marketing-short-video-editing-coach.md`            | Short-Video Editing Coach            | CapCut/Premiere editing                            |
| `marketing-social-media-strategist.md`              | Social Media Strategist              | LinkedIn/Twitter campaigns                         |
| `marketing-tiktok-strategist.md`                    | TikTok Strategist                    | TikTok platform strategy                           |
| `marketing-twitter-engager.md`                      | Twitter Engager                      | Twitter conversation participation                 |
| `marketing-video-optimization-specialist.md`        | Video Optimization Specialist        | YouTube algorithm optimization                     |
| `marketing-wechat-official-account.md`              | WeChat Official Account Manager      | WeChat OA content marketing                        |
| `marketing-weibo-strategist.md`                     | Weibo Strategist                     | Sina Weibo operations                              |
| `marketing-x-twitter-intelligence-analyst.md`       | X/Twitter Intelligence Analyst       | Social intelligence on X/Twitter                   |
| `marketing-xiaohongshu-specialist.md`               | Xiaohongshu Specialist               | Xiaohongshu lifestyle marketing                    |
| `marketing-zhihu-strategist.md`                     | Zhihu Strategist                     | Zhihu knowledge platform                           |

#### Sales & Account Management Agents (13)

| Agent File                           | Name                        | Purpose                               |
| ------------------------------------ | --------------------------- | ------------------------------------- |
| `sales-account-strategist.md`        | Account Strategist          | Post-sale land-and-expand             |
| `sales-coach.md`                     | Sales Coach                 | Rep development, pipeline review      |
| `sales-data-extraction-agent.md`     | Sales Data Extraction Agent | Excel sales metrics extraction        |
| `sales-deal-strategist.md`           | Deal Strategist             | MEDDPICC qualification, win planning  |
| `sales-discovery-coach.md`           | Discovery Coach             | Elite discovery methodology           |
| `sales-engineer.md`                  | Sales Engineer              | Technical pre-sales, demo engineering |
| `sales-offer-lead-gen-strategist.md` | Offer & Lead Gen Strategist | Irresistible offers and lead magnets  |
| `sales-outbound-strategist.md`       | Outbound Strategist         | Signal-based outbound sequences       |
| `sales-outreach.md`                  | Sales Outreach              | B2B sales outreach                    |
| `sales-pipeline-analyst.md`          | Pipeline Analyst            | Pipeline health diagnostics           |
| `sales-proposal-strategist.md`       | Proposal Strategist         | Strategic proposal architecture       |

#### Design & UX Agents (10)

| Agent File                               | Name                           | Purpose                        |
| ---------------------------------------- | ------------------------------ | ------------------------------ |
| `design-brand-guardian.md`               | Brand Guardian                 | Brand identity and positioning |
| `design-image-prompt-engineer.md`        | Image Prompt Engineer          | AI image generation prompts    |
| `design-inclusive-visuals-specialist.md` | Inclusive Visuals Specialist   | Culturally accurate AI visuals |
| `design-persona-walkthrough.md`          | Persona Walkthrough Specialist | Persona-based UX evaluation    |
| `design-ui-designer.md`                  | UI Designer                    | Visual design systems          |
| `design-ui-finish-gate-reviewer.md`      | UI Finish-Gate Reviewer        | Interface quality gate         |
| `design-ux-architect.md`                 | UX Architect                   | Architecture and CSS systems   |
| `design-ux-researcher.md`                | UX Researcher                  | User behavior analysis         |
| `design-visual-storyteller.md`           | Visual Storyteller             | Visual communication           |
| `design-whimsy-injector.md`              | Whimsy Injector                | Playful UI elements            |

#### Finance & Business Strategy Agents (8)

| Agent File                         | Name                    | Purpose                                |
| ---------------------------------- | ----------------------- | -------------------------------------- |
| `business-strategist.md`           | Business Strategist     | Competitive analysis, market entry     |
| `chief-financial-officer.md`       | Chief Financial Officer | Strategic finance, capital allocation  |
| `finance-bookkeeper-controller.md` | Bookkeeper & Controller | Accounting operations, reconciliations |
| `finance-financial-analyst.md`     | Financial Analyst       | Financial modeling, forecasting        |
| `finance-fpa-analyst.md`           | FP&A Analyst            | Budgeting, variance analysis           |
| `finance-investment-researcher.md` | Investment Researcher   | Market research, portfolio analysis    |
| `finance-tax-strategist.md`        | Tax Strategist          | Multi-jurisdictional tax optimization  |

#### GIS & Spatial Data Agents (13)

| Agent File                        | Name                             | Purpose                             |
| --------------------------------- | -------------------------------- | ----------------------------------- |
| `gis-3d-scene-developer.md`       | 3D & Scene Developer             | Web 3D (Cesium, ArcGIS Scene)       |
| `gis-analyst.md`                  | GIS Analyst                      | Day-to-day GIS operations           |
| `gis-bim-specialist.md`           | BIM/GIS Specialist               | Building Information Modeling + GIS |
| `gis-cartography-designer.md`     | Cartography Designer             | Map design and aesthetics           |
| `gis-drone-reality-mapping.md`    | Drone/Reality Mapping Specialist | Photogrammetry, orthomosaics        |
| `gis-geoai-ml-engineer.md`        | GeoAI/ML Engineer                | Geospatial ML, feature extraction   |
| `gis-geoprocessing-specialist.md` | Geoprocessing Specialist         | ArcPy, Model Builder                |
| `gis-qa-engineer.md`              | GIS QA Engineer                  | Geospatial data quality assurance   |
| `gis-solution-engineer.md`        | Solution Engineer                | GIS prototype builder               |
| `gis-spatial-data-engineer.md`    | Spatial Data Engineer            | Spatial ETL, format conversion      |
| `gis-spatial-data-scientist.md`   | Spatial Data Scientist           | Spatial statistical modeling        |
| `gis-technical-consultant.md`     | Technical Consultant             | Strategic GIS advisory              |
| `gis-web-gis-developer.md`        | Web GIS Developer                | Interactive mapping applications    |

#### Healthcare Agents (6)

| Agent File                                      | Name                             | Purpose                               |
| ----------------------------------------------- | -------------------------------- | ------------------------------------- |
| `healthcare-aging-parent-care-companion.md`     | Aging Parent Care Companion      | HIPAA care coordination               |
| `healthcare-clinical-evidence-agent.md`         | Clinical Evidence Agent          | Clinical credibility framework        |
| `healthcare-customer-service.md`                | Healthcare Customer Service      | Patient support                       |
| `healthcare-innovation-strategist.md`           | Healthcare Innovation Strategist | Healthcare narrative architecture     |
| `healthcare-marketing-compliance-specialist.md` | Healthcare Marketing Compliance  | China healthcare marketing compliance |
| `healthcare-sovereign-health-systems-agent.md`  | Sovereign Health Systems Agent   | Government health mandate engagement  |

#### Gaming & Engine Agents (17)

| Agent File                        | Name                         | Purpose                          |
| --------------------------------- | ---------------------------- | -------------------------------- |
| `blender-addon-engineer.md`       | Blender Add-on Engineer      | Blender Python addon development |
| `game-audio-engineer.md`          | Game Audio Engineer          | Interactive audio (FMOD/Wwise)   |
| `game-designer.md`                | Game Designer                | Systems and mechanics            |
| `godot-gameplay-scripter.md`      | Godot Gameplay Scripter      | Godot 4 GDScript                 |
| `godot-multiplayer-engineer.md`   | Godot Multiplayer Engineer   | Godot 4 networking               |
| `godot-shader-developer.md`       | Godot Shader Developer       | Godot 4 visual effects           |
| `unity-architect.md`              | Unity Architect              | Unity data-driven architecture   |
| `unity-editor-tool-developer.md`  | Unity Editor Tool Developer  | Unity Editor customization       |
| `unity-multiplayer-engineer.md`   | Unity Multiplayer Engineer   | Unity Netcode                    |
| `unity-shader-graph-artist.md`    | Unity Shader Graph Artist    | Unity Shader Graph               |
| `unreal-multiplayer-architect.md` | Unreal Multiplayer Architect | Unreal Engine networking         |
| `unreal-systems-engineer.md`      | Unreal Systems Engineer      | Unreal C++/Blueprint             |
| `unreal-technical-artist.md`      | Unreal Technical Artist      | Unreal visual pipeline           |
| `unreal-world-builder.md`         | Unreal World Builder         | Unreal World Partition           |
| `roblox-avatar-creator.md`        | Roblox Avatar Creator        | Roblox UGC pipeline              |
| `roblox-experience-designer.md`   | Roblox Experience Designer   | Roblox experience design         |
| `roblox-systems-scripter.md`      | Roblox Systems Scripter      | Roblox platform engineering      |

#### Testing & QA Agents (9)

| Agent File                            | Name                     | Purpose                      |
| ------------------------------------- | ------------------------ | ---------------------------- |
| `testing-accessibility-auditor.md`    | Accessibility Auditor    | WCAG 508 accessibility       |
| `testing-api-tester.md`               | API Tester               | API testing and validation   |
| `testing-evidence-collector.md`       | Evidence Collector       | Screenshot-based QA          |
| `testing-performance-benchmarker.md`  | Performance Benchmarker  | Performance benchmarking     |
| `testing-reality-checker.md`          | Reality Checker          | Evidence-based certification |
| `testing-test-automation-engineer.md` | Test Automation Engineer | Playwright/Cypress           |
| `testing-test-results-analyzer.md`    | Test Results Analyzer    | Test result analysis         |
| `testing-tool-evaluator.md`           | Tool Evaluator           | Tool evaluation              |
| `testing-workflow-optimizer.md`       | Workflow Optimizer       | Workflow optimization        |

#### Academic & Research Agents (6)

| Agent File                   | Name           | Purpose                               |
| ---------------------------- | -------------- | ------------------------------------- |
| `academic-anthropologist.md` | Anthropologist | Cultural systems analysis             |
| `academic-geographer.md`     | Geographer     | Physical and human geography          |
| `academic-historian.md`      | Historian      | Historical analysis                   |
| `academic-narratologist.md`  | Narratologist  | Narrative theory                      |
| `academic-psychologist.md`   | Psychologist   | Human behavior and cognitive patterns |
| `academic-statistician.md`   | Statistician   | Quantitative research methodology     |

#### Specialized & Infrastructure Agents (30+)

| Agent File                                        | Name                                | Purpose                               |
| ------------------------------------------------- | ----------------------------------- | ------------------------------------- |
| `specialized-chief-of-staff.md`                   | Chief of Staff                      | Executive coordination                |
| `specialized-civil-engineer.md`                   | Civil Engineer                      | Global civil/structural engineering   |
| `specialized-codebase-archaeologist.md`           | Codebase Archaeologist              | Multi-tool drift detection            |
| `specialized-cultural-intelligence-strategist.md` | Cultural Intelligence Strategist    | Cross-cultural inclusion              |
| `specialized-developer-advocate.md`               | Developer Advocate                  | Developer community building          |
| `specialized-document-generator.md`               | Document Generator                  | PDF/PPTX/DOCX/XLSX generation         |
| `specialized-fedramp-rmf-compliance.md`           | FedRAMP & RMF Compliance Engineer   | FedRAMP authorization                 |
| `specialized-french-consulting-market.md`         | French Consulting Market Navigator  | French ESN/SI marketplace             |
| `specialized-korean-business-navigator.md`        | Korean Business Navigator           | Korean business culture               |
| `specialized-mcp-builder.md`                      | MCP Builder                         | Model Context Protocol servers        |
| `specialized-model-qa.md`                         | Model QA Specialist                 | ML model QA and replication           |
| `specialized-pricing-analyst.md`                  | Pricing Analyst                     | Pricing model development             |
| `specialized-salesforce-architect.md`             | Salesforce Architect                | Salesforce multi-cloud design         |
| `specialized-strategy-duel-agent.md`              | Strategy Duel Agent                 | Game theory strategy duels            |
| `specialized-workflow-architect.md`               | Workflow Architect                  | Complete workflow tree mapping        |
| `accounts-payable-agent.md`                       | Accounts Payable Agent              | Autonomous payment processing         |
| `agentic-identity-trust-architect.md`             | Agentic Identity & Trust Architect  | AI agent identity/authentication      |
| `agents-orchestrator.md`                          | Agents Orchestrator                 | Development workflow orchestration    |
| `automation-governance-architect.md`              | Automation Governance Architect     | Business automation governance        |
| `change-management-consultant.md`                 | Change Management Consultant        | ADKAR/Kotter/Prosci frameworks        |
| `corporate-training-designer.md`                  | Corporate Training Designer         | Enterprise training systems           |
| `customer-service.md`                             | Customer Service                    | Professional customer support         |
| `customer-success-manager.md`                     | Customer Success Manager            | Customer success and retention        |
| `data-consolidation-agent.md`                     | Data Consolidation Agent            | Sales data consolidation              |
| `data-privacy-officer.md`                         | Data Privacy Officer                | GDPR/CCPA compliance                  |
| `hr-onboarding.md`                                | HR Onboarding                       | Employee onboarding                   |
| `identity-graph-operator.md`                      | Identity Graph Operator             | Shared identity graph                 |
| `language-translator.md`                          | Language Translator                 | Spanish↔English translation           |
| `legal-billing-and-time-tracking.md`              | Legal Billing & Time Tracking       | Legal billing specialist              |
| `legal-client-intake.md`                          | Legal Client Intake                 | Legal client intake                   |
| `legal-document-review.md`                        | Legal Document Review               | Legal document review                 |
| `level-designer.md`                               | Level Designer                      | Spatial storytelling and flow         |
| `loan-officer-assistant.md`                       | Loan Officer Assistant              | Mortgage/lending assistant            |
| `meeting-notes-specialist.md`                     | Meeting Notes Specialist            | Structured meeting summaries          |
| `organizational-psychologist.md`                  | Organizational Psychologist         | Team dynamics analysis                |
| `real-estate-buyer-and-seller.md`                 | Real Estate Buyer & Seller          | Real estate transactions              |
| `recruitment-specialist.md`                       | Recruitment Specialist              | Talent acquisition                    |
| `report-distribution-agent.md`                    | Report Distribution Agent           | Sales report distribution             |
| `resume-tailor.md`                                | Resume Tailor                       | Resume optimization                   |
| `retail-customer-returns.md`                      | Retail Customer Returns             | Retail returns processing             |
| `sprint-prioritizer.md`                           | Sprint Prioritizer                  | Agile sprint planning                 |
| `studio-operations.md`                            | Studio Operations                   | Studio operations management          |
| `studio-producer.md`                              | Studio Producer                     | Creative project production           |
| `trend-researcher.md`                             | Trend Researcher                    | Market intelligence                   |
| `experiment-tracker.md`                           | Experiment Tracker                  | Experiment design                     |
| `jira-workflow-steward.md`                        | Jira Workflow Steward               | Jira workflow enforcement             |
| `project-shepherd.md`                             | Project Shepherd                    | Cross-functional project coordination |
| `paid-media-auditor.md`                           | Paid Media Auditor                  | Paid media account audit              |
| `ad-creative-strategist.md`                       | Ad Creative Strategist              | Paid media creative optimization      |
| `paid-social-strategist.md`                       | Paid Social Strategist              | Cross-platform paid social            |
| `ppc-campaign-strategist.md`                      | PPC Campaign Strategist             | Search/ad campaign architecture       |
| `programmatic-and-display-buyer.md`               | Programmatic & Display Buyer        | Display advertising                   |
| `search-query-analyst.md`                         | Search Query Analyst                | Search term analysis                  |
| `tracking-and-measurement-specialist.md`          | Tracking & Measurement Specialist   | Conversion tracking                   |
| `personal-growth-mentor.md`                       | Personal Growth Mentor              | Personal development                  |
| `behavioral-nudge-engine.md`                      | Behavioral Nudge Engine             | Behavioral psychology                 |
| `feedback-synthesizer.md`                         | Feedback Synthesizer                | User feedback analysis                |
| `product-manager.md`                              | Product Manager                     | Product lifecycle management          |
| `supply-chain-strategist.md`                      | Supply Chain Strategist             | Supply chain management               |
| `analytics-reporter.md`                           | Analytics Reporter                  | Data analysis and dashboards          |
| `executive-summary-generator.md`                  | Executive Summary Generator         | McKinsey-grade business summaries     |
| `finance-tracker.md`                              | Finance Tracker                     | Financial planning and budgeting      |
| `infrastructure-maintainer.md`                    | Infrastructure Maintainer           | System reliability                    |
| `legal-compliance-checker.md`                     | Legal Compliance Checker            | Legal compliance                      |
| `support-responder.md`                            | Support Responder                   | Customer support                      |
| `technical-artist.md`                             | Technical Artist                    | Art-to-engine pipelines               |
| `terminal-integration-specialist.md`              | Terminal Integration Specialist     | Terminal emulation                    |
| `study-abroad-advisor.md`                         | Study Abroad Advisor                | Study abroad planning                 |
| `grants-writer.md`                                | Grant Writer                        | Grant writing and proposals           |
| `medical-billing-and-coding-specialist.md`        | Medical Billing & Coding Specialist | ICD-10/CPT coding                     |
| `narrative-designer.md`                           | Narrative Designer                  | Story systems and dialogue            |
| `operations-manager.md`                           | Operations Manager                  | Business operations                   |

#### WebAssembly & Streaming Agents

| Agent File                         | Name                          | Purpose                           |
| ---------------------------------- | ----------------------------- | --------------------------------- |
| `webassembly-engineer.md`          | WebAssembly Engineer          | Wasm compilation and optimization |
| `video-streaming-engineer.md`      | Video Streaming Engineer      | HLS/DASH, ffmpeg transcode        |
| `voice-ai-integration-engineer.md` | Voice AI Integration Engineer | Speech transcription pipelines    |

#### Emerging Tech Agents

| Agent File                             | Name                              | Purpose                     |
| -------------------------------------- | --------------------------------- | --------------------------- |
| `macos-spatial-metal-engineer.md`      | macOS Spatial/Metal Engineer      | Vision Pro, Metal rendering |
| `xr-cockpit-interaction-specialist.md` | XR Cockpit Interaction Specialist | Immersive cockpit controls  |
| `xr-immersive-developer.md`            | XR Immersive Developer            | WebXR/AR/VR/XR applications |
| `xr-interface-architect.md`            | XR Interface Architect            | Spatial interaction design  |
| `web-gis-developer.md`                 | Web GIS Developer                 | Interactive mapping apps    |

---

## 6. Commands (57 Slash Commands)

Commands are `.md` files in `~/.claude/commands/` with YAML frontmatter. Each provides a focused workflow template invoked as `/command-name`.

### 6.1 Development Workflow Commands

| Command            | File                 | Description                                            |
| ------------------ | -------------------- | ------------------------------------------------------ |
| `/tdd`             | `tdd.md`             | Test-driven development with 80%+ coverage requirement |
| `/plan`            | `plan.md`            | Requirement analysis and step-by-step planning         |
| `/refactor-clean`  | `refactor-clean.md`  | Code refactoring and cleanup                           |
| `/update-docs`     | `update-docs.md`     | Documentation updates                                  |
| `/update-codemaps` | `update-codemaps.md` | Codebase map updates                                   |
| `/verify`          | `verify.md`          | Verification: build → test → lint → check diff         |
| `/quality-gate`    | `quality-gate.md`    | Quality gate checks before release                     |

### 6.2 Multi-Agent Orchestration Commands

| Command           | File                | Description                                                                  |
| ----------------- | ------------------- | ---------------------------------------------------------------------------- |
| `/orchestrate`    | `orchestrate.md`    | Task decomposition with role-based assignment                                |
| `/devfleet`       | `devfleet.md`       | Parallel agent orchestration via DevFleet MCP                                |
| `/multi-execute`  | `multi-execute.md`  | Multi-agent execution workflow                                               |
| `/multi-plan`     | `multi-plan.md`     | Multi-agent planning                                                         |
| `/multi-workflow` | `multi-workflow.md` | Full collaborative workflow (Research→Ideation→Plan→Execute→Optimize→Review) |
| `/multi-backend`  | `multi-backend.md`  | Multi-model backend development                                              |
| `/multi-frontend` | `multi-frontend.md` | Multi-model frontend development                                             |
| `/claw`           | `claw.md`           | NanoClaw v2 persistent REPL                                                  |

### 6.3 Language-Specific Review & Build Commands

| Command          | File               | Description          |
| ---------------- | ------------------ | -------------------- |
| `/cpp-build`     | `cpp-build.md`     | C++ build command    |
| `/cpp-review`    | `cpp-review.md`    | C++ code review      |
| `/cpp-test`      | `cpp-test.md`      | C++ testing          |
| `/go-build`      | `go-build.md`      | Go build command     |
| `/go-review`     | `go-review.md`     | Go code review       |
| `/go-test`       | `go-test.md`       | Go testing           |
| `/kotlin-build`  | `kotlin-build.md`  | Kotlin build command |
| `/kotlin-review` | `kotlin-review.md` | Kotlin code review   |
| `/kotlin-test`   | `kotlin-test.md`   | Kotlin testing       |
| `/python-review` | `python-review.md` | Python code review   |
| `/rust-build`    | `rust-build.md`    | Rust build command   |
| `/rust-review`   | `rust-review.md`   | Rust code review     |
| `/rust-test`     | `rust-test.md`     | Rust testing         |
| `/gradle-build`  | `gradle-build.md`  | Gradle build command |
| `/code-review`   | `code-review.md`   | General code review  |

### 6.4 Session Management Commands

| Command           | File                | Description                        |
| ----------------- | ------------------- | ---------------------------------- |
| `/sessions`       | `sessions.md`       | Session history, aliases, metadata |
| `/save-session`   | `save-session.md`   | Save current session state         |
| `/resume-session` | `resume-session.md` | Load and resume saved session      |
| `/checkpoint`     | `checkpoint.md`     | Create checkpoint                  |
| `/loop-start`     | `loop-start.md`     | Start loop mode                    |
| `/loop-status`    | `loop-status.md`    | Check loop status                  |
| `/pm2`            | `pm2.md`            | Multi-process service management   |
| `/setup-pm`       | `setup-pm.md`       | Setup persistent mode              |
| `/model-route`    | `model-route.md`    | Model routing                      |

### 6.5 Learning & Evolution Commands

| Command            | File                 | Description                                       |
| ------------------ | -------------------- | ------------------------------------------------- |
| `/learn`           | `learn.md`           | Extract reusable patterns from sessions           |
| `/learn-eval`      | `learn-eval.md`      | Extract and self-evaluate patterns                |
| `/evolve`          | `evolve.md`          | Analyze instincts and generate evolved structures |
| `/instinct-export` | `instinct-export.md` | Export project instincts                          |
| `/instinct-import` | `instinct-import.md` | Import instincts                                  |
| `/instinct-status` | `instinct-status.md` | Check instinct statistics                         |
| `/promote`         | `promote.md`         | Promote project instincts to global scope         |

### 6.6 Skills & Quality Commands

| Command          | File               | Description                        |
| ---------------- | ------------------ | ---------------------------------- |
| `/skill-create`  | `skill-create.md`  | Generate SKILL.md from git history |
| `/skill-health`  | `skill-health.md`  | Skill portfolio health dashboard   |
| `/test-coverage` | `test-coverage.md` | Test coverage reporting            |
| `/harness-audit` | `harness-audit.md` | Harness audit                      |
| `/eval`          | `eval.md`          | Eval command                       |

### 6.7 Other Commands

| Command            | File                 | Description                                 |
| ------------------ | -------------------- | ------------------------------------------- |
| `/aside`           | `aside.md`           | Quick side questions without losing context |
| `/docs`            | `docs.md`            | Documentation lookup via Context7           |
| `/e2e`             | `e2e.md`             | End-to-end testing with Playwright          |
| `/projects`        | `projects.md`        | List known projects and instinct statistics |
| `/prompt-optimize` | `prompt-optimize.md` | Prompt optimization analysis                |

---

## 7. Skills (125 Directories)

Skills are auto-triggered by keyword detection in `keyword-detector.mjs` (47 KB). Each skill is a directory containing a `SKILL.md` file.

### 7.1 Skill Activation Mechanism

1. User sends message
2. `keyword-detector.mjs` scans message against 47 KB keyword database
3. Matching keywords trigger relevant skills
4. `skill-injector.mjs` loads matched SKILL.md files into context

### 7.2 Complete Skill Inventory by Category

#### Programming Language Patterns (25)

| Skill Directory                | Language/Focus | Key Patterns                              |
| ------------------------------ | -------------- | ----------------------------------------- |
| `python-patterns/`             | Python         | Idiomatic Python, type hints, async/await |
| `python-testing/`              | Python         | pytest, mocking, fixtures                 |
| `kotlin-patterns/`             | Kotlin         | Idiomatic Kotlin, coroutines              |
| `kotlin-testing/`              | Kotlin         | Kotlin test frameworks                    |
| `kotlin-coroutines-flows/`     | Kotlin         | Flow, Channel, StateFlow patterns         |
| `kotlin-exposed-patterns/`     | Kotlin         | Exposed ORM patterns                      |
| `kotlin-ktor-patterns/`        | Kotlin         | Ktor web framework patterns               |
| `rust-patterns/`               | Rust           | Ownership, lifetimes, async               |
| `rust-testing/`                | Rust           | Test frameworks                           |
| `golang-patterns/`             | Go             | Idiomatic Go, channels, context           |
| `golang-testing/`              | Go             | Test patterns                             |
| `cpp-coding-standards/`        | C++            | C++20 best practices                      |
| `cpp-testing/`                 | C++            | GoogleTest, Catch2                        |
| `swiftui-patterns/`            | Swift          | SwiftUI architecture                      |
| `swift-concurrency-6-2/`       | Swift          | Actor patterns, async/await               |
| `swift-actor-persistence/`     | Swift          | Concurrency + persistence                 |
| `swift-protocol-di-testing/`   | Swift          | Dependency injection testing              |
| `typescript/coding-standards/` | TypeScript     | Type patterns, generics                   |
| `perl-patterns/`               | Perl           | Perl idioms                               |
| `perl-testing/`                | Perl           | Test::More patterns                       |
| `perl-security/`               | Perl           | Security patterns                         |
| `java-coding-standards/`       | Java           | Enterprise Java patterns                  |
| `frontend-patterns/`           | Frontend       | Modern frontend architecture              |
| `nextjs-turbopack/`            | Next.js        | Turbopack optimization                    |

#### Framework-Specific Skills (12)

| Skill Directory            | Framework   | Key Patterns                |
| -------------------------- | ----------- | --------------------------- |
| `django-patterns/`         | Django      | ORM, views, middleware      |
| `django-security/`         | Django      | CSRF, XSS, SQL injection    |
| `django-tdd/`              | Django      | Django TDD                  |
| `django-verification/`     | Django      | Django verification         |
| `springboot-patterns/`     | Spring Boot | Spring architecture         |
| `springboot-security/`     | Spring Boot | Spring Security, OAuth2     |
| `springboot-tdd/`          | Spring Boot | Spring TDD                  |
| `springboot-verification/` | Spring Boot | Spring verification         |
| `laravel-patterns/`        | Laravel     | Laravel architecture        |
| `laravel-security/`        | Laravel     | Laravel CSRF, XSS, policies |
| `laravel-tdd/`             | Laravel     | Laravel TDD                 |
| `laravel-verification/`    | Laravel     | Laravel verification        |
| `jpa-patterns/`            | JPA         | JPA/Hibernate patterns      |
| `postgres-patterns/`       | PostgreSQL  | PostgreSQL optimization     |

#### DevOps & Infrastructure Skills (8)

| Skill Directory        | Focus                                   |
| ---------------------- | --------------------------------------- |
| `docker-patterns/`     | Docker optimization, multi-stage builds |
| `deployment-patterns/` | CI/CD, deployment strategies            |
| `database-migrations/` | Schema migration patterns               |
| `mcp-server-patterns/` | MCP server development                  |
| `clickhouse-io/`       | ClickHouse analytics                    |
| `cloudflare-patterns/` | Cloudflare Workers, Pages               |
| `vercel/`              | Vercel deployment patterns              |
| `railway/`             | Railway deployment patterns             |

#### Business & Domain Skills (9)

| Skill Directory                    | Focus                        |
| ---------------------------------- | ---------------------------- |
| `energy-procurement/`              | Energy sector procurement    |
| `inventory-demand-planning/`       | Inventory optimization       |
| `logistics-exception-management/`  | Logistics exception handling |
| `production-scheduling/`           | Production planning          |
| `quality-nonconformance/`          | Quality control              |
| `returns-reverse-logistics/`       | Returns management           |
| `carrier-relationship-management/` | Carrier management           |
| `customs-trade-compliance/`        | Customs compliance           |
| `investor-materials/`              | Investor deck creation       |
| `investor-outreach/`               | Investor relations           |
| `market-research/`                 | Market research patterns     |

#### Agent & Orchestration Skills (8)

| Skill Directory                 | Focus                       |
| ------------------------------- | --------------------------- |
| `autonomous-loops/`             | Autonomous loop patterns    |
| `continuous-learning/`          | Learning system patterns    |
| `continuous-learning-v2/`       | v2 learning system          |
| `claude-devfleet/`              | DevFleet orchestration      |
| `dmux-workflows/`               | Dmux workflow patterns      |
| `parallel-feature-development/` | Parallel feature dev        |
| `team-builder/`                 | Team orchestration          |
| `enterprise-agent-ops/`         | Enterprise agent operations |

#### Testing & Verification Skills (6)

| Skill Directory          | Focus                      |
| ------------------------ | -------------------------- |
| `tdd-workflow/`          | TDD patterns               |
| `verification-loop/`     | Verification loop patterns |
| `e2e-testing/`           | End-to-end testing         |
| `ai-regression-testing/` | AI-based regression        |
| `plankton-code-quality/` | Plankton code quality      |
| `eval-harness/`          | Evaluation framework       |

#### Research & Search Skills (4)

| Skill Directory         | Focus                     |
| ----------------------- | ------------------------- |
| `exa-search/`           | Neural web search via Exa |
| `deep-research/`        | Deep research patterns    |
| `search-first/`         | Search-first development  |
| `documentation-lookup/` | Documentation search      |

#### Content & Writing Skills (9)

| Skill Directory      | Focus                    |
| -------------------- | ------------------------ |
| `content-engine/`    | Content generation       |
| `crosspost/`         | Multi-platform posting   |
| `humanizer/`         | Humanize AI text         |
| `humanizer-zh/`      | Chinese humanization     |
| `article-writing/`   | Article writing patterns |
| `rprompt-optimizer/` | Prompt optimization      |
| `graphify/`          | Graph visualization      |
| `zh-code-reviewer/`  | Chinese code review      |
| `zh-readme/`         | Chinese README patterns  |

#### Special Tools Skills (20+)

| Skill Directory                     | Focus                        |
| ----------------------------------- | ---------------------------- |
| `x-api/`                            | External API integration     |
| `last30days/`                       | Last 30 days context         |
| `blueprint/`                        | Blueprint patterns           |
| `nanoclaw-repl/`                    | NanoClaw REPL                |
| `claude-mem/`                       | Claude memory patterns       |
| `claude-api/`                       | Claude API patterns          |
| `cost-aware-llm-pipeline/`          | Cost-optimized LLM pipelines |
| `iterative-retrieval/`              | Iterative search patterns    |
| `content-hash-cache-pattern/`       | Content hash caching         |
| `prompt-optimizer/`                 | Prompt optimization          |
| `strategic-compact/`                | Strategic compaction         |
| `aside/`                            | Side question patterns       |
| `build-fix/`                        | Build fix patterns           |
| `security-scan/`                    | Security scanning            |
| `skill-stocktake/`                  | Skill inventory              |
| `security-review/`                  | Security review patterns     |
| `api-design/`                       | API design patterns          |
| `foundation-models-on-device/`      | On-device ML models          |
| `backend-patterns/`                 | Backend architecture         |
| `coding-standards/`                 | General coding standards     |
| `data-scraper-agent/`               | Web scraping agents          |
| `install-demand-planning/`          | Demand planning setup        |
| `pdf-to-markdown-long-task/`        | PDF processing               |
| `nutrient-document-processing/`     | Document processing          |
| `visa-doc-translate/`               | Visa document translation    |
| `arkham-intelligence-claude-skill/` | Arkham intelligence          |
| `composer-multiplatform-patterns/`  | Cross-platform composer      |
| `project-guidelines-example/`       | Project guidelines           |
| `regex-vs-llm-structured-text/`     | Regex vs LLM text            |
| `agentic-engineering/`              | Agent engineering            |
| `ai-first-engineering/`             | AI-first development         |
| `agent-harness-construction/`       | Agent harness building       |
| `android-clean-architecture/`       | Android clean architecture   |
| `agent-reach/`                      | Agent reach patterns         |
| `c-detailed-design-generator/`      | C design generation          |
| `configure-ecc/`                    | ECC configuration            |
| `browser-act/`                      | Browser automation           |
| `fal-ai-media/`                     | Fal AI media generation      |

#### Design & UI Skills (5)

| Skill Directory        | Focus                    |
| ---------------------- | ------------------------ |
| `frontend-design/`     | Frontend design patterns |
| `frontend-slides/`     | Presentation design      |
| `liquid-glass-design/` | visionOS Liquid Glass UI |
| `videodb/`             | Video database patterns  |
| `video-editing/`       | Video editing workflows  |

---

## 8. Rules System

### 8.1 Rule Architecture

Rules follow an override pattern: **common defaults + language-specific overrides**.

```
rules/
├── README.md                    # Installation guide
├── common/                      # Universal rules (always active)
│   ├── agents.md                # Agent orchestration rules
│   ├── coding-style.md          # Immutability, file organization, error handling
│   ├── development-workflow.md  # Research→Plan→TDD→Review→Commit
│   ├── git-workflow.md          # Commit format, PR workflow
│   ├── hooks.md                 # Hook types and permissions
│   ├── patterns.md              # Repository pattern, API response format
│   ├── performance.md           # Model selection, context management
│   ├── security.md              # Security checks before commit
│   └── testing.md               # 80%+ test coverage requirement
├── cpp/                         # C++ rules (5 files)
├── golang/                      # Go rules (5 files)
├── kotlin/                      # Kotlin rules (5 files, 12KB+ — largest)
├── perl/                        # Perl rules (5 files)
├── php/                         # PHP rules (5 files)
├── python/                      # Python rules (5 files)
├── swift/                       # Swift rules (5 files)
└── typescript/                  # TypeScript rules (5 files, 4.3KB)
```

Each language directory contains: `coding-style.md`, `hooks.md`, `patterns.md`, `security.md`, `testing.md`

### 8.2 Rule Priority

1. **Language-specific** rules override **common** rules
2. Rules with specific examples override general principles
3. File references in language rules point to `../common/` counterparts
4. Marked with "> **Language note**: This rule may be overridden..."

### 8.3 Common Rules Summary

**Coding Style (common/coding-style.md):**

- Immutability is CRITICAL: Always create new objects
- File organization: Many small files > few large files (200-400 lines typical, 800 max)
- Error handling: Always handle errors, never silently swallow
- Input validation: Validate at all system boundaries
- Code quality checklist before marking complete

**Git Workflow (common/git-workflow.md):**

- Conventional Commits: `<type>: <description>` (feat, fix, refactor, test, chore, perf, ci)
- PR workflow: Analyze full commit history, use `git diff [base]...HEAD`
- Attribution: Disabled globally via settings.json

**Testing (common/testing.md):**

- 80%+ test coverage mandatory
- ALL test types required: Unit, Integration, E2E
- TDD workflow: Write test first (RED) → Implement (GREEN) → Refactor (IMPROVE)
- Agent support: Use **tdd-guide** agent proactively

**Performance (common/performance.md):**

- Haiku 4.5 for lightweight agents, Sonnet 4.6 for main work, Opus 4.5 for deep reasoning
- Context window: Avoid last 20% for large refactoring
- Extended thinking enabled by default (31,999 tokens for reasoning)

**Security (common/security.md):**

- No hardcoded secrets
- Parameterized queries (SQL injection)
- XSS prevention, CSRF protection
- Authentication/authorization verified
- Rate limiting on all endpoints
- Error messages don't leak sensitive data

**Patterns (common/patterns.md):**

- Repository pattern: Consistent data access interface
- API response format: Success envelope with data/error/metadata
- Skeleton projects: Search for existing implementations first

### 8.4 Rule Installation

```bash
# Install common + language-specific rules
cp -r rules/common ~/.claude/rules/common
cp -r rules/typescript ~/.claude/rules/typescript   # if using TypeScript
cp -r rules/python ~/.claude/rules/python           # if using Python
# ... etc for your tech stack
```

---

## 9. Context System

Three execution contexts in `~/.claude/contexts/`:

| Context     | File          | Purpose                                        | When to Use                              |
| ----------- | ------------- | ---------------------------------------------- | ---------------------------------------- |
| Development | `dev.md`      | Write code first, prioritize working solutions | `/context dev` — Standard development    |
| Research    | `research.md` | Explore before acting, form hypotheses         | `/context research` — Investigation mode |
| Review      | `review.md`   | Prioritized review by severity                 | `/context review` — Code review          |

### 9.1 Context Behavior

**dev.md**: Implement first, refine later. Run tests after changes. Iterate on working solutions.

**research.md**: Research first, implement second. Document findings. Verify hypotheses with evidence.

**review.md**: Critical > High > Medium > Low priority. Suggest specific fixes. Check security, performance, coverage.

---

## 10. OMC Integration

### 10.1 Oh My ClaudeCode (OMC) Overview

| Property          | Value                                             |
| ----------------- | ------------------------------------------------- |
| Version           | 4.13.6 (local), 5.3.0 (latest on GitHub)          |
| Repository        | `https://github.com/Yeachan-Heo/oh-my-claudecode` |
| NPM Package       | `oh-my-claude-sisyphus`                           |
| Author            | Yeachan Heo (hurrc04@gmail.com)                   |
| License           | MIT                                               |
| Node Requirements | 20.x                                              |     | 22.x |     | 23.x |     | 24.x |     | 25.x |     | 26.x |

### 10.2 OMC Build System

```bash
cd ~/.claude/omc
npm install
npm run build    # Runs: tsc + compose-docs + generate:prompt-projections + build:claude-md-coordinator + build:runtime-cli + build:team-server + build:cli
```

**Build steps in order:**

1. `generate-skill-entitlements` — Verify skill entitlements
2. `tsc` — Compile TypeScript
3. `build-workflow-stage-prompts` — Build workflow prompts
4. `build-skill-bridge` — Build skill bridge
5. `build-mcp-server` — Build MCP server
6. `build-bridge-entry` — Build bridge entry
7. `compose-docs` — Compose documentation
8. `generate-prompt-projections` — Generate prompt projections
9. `build:claude-md-coordinator` — Build Claude.md coordinator
10. `build:runtime-cli` — Build runtime CLI
11. `build:team-server` — Build team server
12. `build:cli` — Build CLI

### 10.3 OMC Execution Modes

| Mode      | Skill                      | Description                          | Trigger Keywords                     |
| --------- | -------------------------- | ------------------------------------ | ------------------------------------ |
| Autopilot | Full autonomous execution  | From idea to usable code in phases   | "autopilot", "build me", "create me" |
| Ultrawork | Maximum parallel execution | Spawn multiple independent agents    | "ultrawork", "parallel", "ulw"       |
| Ralph     | Persistent loop            | Iterates until all user stories pass | "ralph", "don't stop", "finish this" |
| Team      | N-agent collaboration      | Multiple agents share a task list    | "/team N:agent-type"                 |
| UltraQA   | QA loop                    | Test → Fix → Repeat until passing    | "ultraqa", "qa loop"                 |

### 10.4 OMC Agent Variants (21)

| OMC Agent           | Role                       |
| ------------------- | -------------------------- |
| analyst             | Data analysis              |
| architect           | System design              |
| code-reviewer       | Code quality review        |
| code-simplifier     | Code simplification        |
| critic              | Critical evaluation        |
| debugger            | Problem diagnosis          |
| designer            | UI/UX design               |
| document-specialist | Documentation              |
| executor            | Code implementation        |
| explore             | Code exploration           |
| git-master          | Git workflow management    |
| planner             | Task planning              |
| qa-tester           | Quality assurance          |
| scientist           | Scientific research method |
| security-reviewer   | Security review            |
| test-engineer       | Test engineering           |
| tracer              | Evidence tracking          |
| verifier            | Change verification        |
| writer              | Content writing            |
| scientist           | Research methodology       |
| designer            | Visual design              |

### 10.5 OMC Keyword Detection System

`keyword-detector.mjs` (47 KB) is the largest OMC script. It:

- Maintains a comprehensive keyword database mapping user messages to agents/skills
- Triggers on intent detection: "build", "design", "review", "test", "plan", etc.
- Scores relevance of each skill/agent to the current context
- Injects matched skills via `skill-injector.mjs`

### 10.6 OMC Debug Mode

```bash
export OMC_DEBUG=1
```

Enables `[omc:debug:*]` prefixed output to stderr for all hook scripts.

---

## 11. Plugin System

### 11.1 Internal Plugins (41)

Installed via `~/.claude/plugins/marketplaces/claude-plugins-official/`:

| Plugin                     | Purpose                        |
| -------------------------- | ------------------------------ |
| `agent-sdk-dev`            | Agent SDK development          |
| `clangd-lsp`               | C/C++ language server protocol |
| `claude-code-setup`        | Claude Code configuration      |
| `claude-md-management`     | CLAUDE.md management           |
| `claude-security`          | Security guidance              |
| `code-modernization`       | Code modernization patterns    |
| `code-review`              | Code review automation         |
| `code-simplifier`          | Code simplification            |
| `commit-commands`          | Git commit automation          |
| `csharp-lsp`               | C# language server             |
| `cwc-makers`               | Maker patterns                 |
| `example-plugin`           | Example/reference plugin       |
| `explanatory-output-style` | Explanatory output formatting  |
| `feature-dev`              | Feature development workflow   |
| `frontend-design`          | Frontend design patterns       |
| `gopls-lsp`                | Go language server             |
| `hookify`                  | Hook creation and management   |
| `jdtls-lsp`                | Java language server           |
| `kotlin-lsp`               | Kotlin language server         |
| `learning-output-style`    | Learning-oriented output       |
| `lua-lsp`                  | Lua language server            |
| `math-olympiad`            | Math olympiad problem solving  |
| `mcp-server-dev`           | MCP server development         |
| `mcp-tunnels`              | MCP tunnel management          |
| `php-lsp`                  | PHP language server            |
| `playground`               | Experimentation sandbox        |
| `plugin-dev`               | Plugin development             |
| `pr-review-toolkit`        | PR review tools                |
| `project-artifact`         | Project artifact management    |
| `pyright-lsp`              | Python language server         |
| `ralph-loop`               | Ralph agent loop               |
| `receipts`                 | Receipt parsing                |
| `ruby-lsp`                 | Ruby language server           |
| `rust-analyzer-lsp`        | Rust language server           |
| `security-guidance`        | Security patterns              |
| `session-report`           | Session analytics              |
| `skill-creator`            | Skill creation                 |
| `swift-lsp`                | Swift language server          |
| `typescript-lsp`           | TypeScript language server     |

### 11.2 External Plugin Families (16)

| Family          | Purpose                              |
| --------------- | ------------------------------------ |
| `asana`         | Asana project management integration |
| `context7`      | Documentation lookup                 |
| `discord`       | Discord bot integration              |
| `fakechat`      | Chat mocking for testing             |
| `firebase`      | Firebase integration                 |
| `github`        | GitHub operations                    |
| `gitlab`        | GitLab operations                    |
| `imessage`      | iMessage integration                 |
| `laravel-boost` | Laravel enhancement                  |
| `linear`        | Linear project management            |
| `playwright`    | Browser automation                   |
| `serena`        | Code intelligence                    |
| `telegram`      | Telegram bot integration             |
| `terraform`     | Infrastructure as code               |

---

## 12. Multi-Agent Orchestration

### 12.1 DevFleet Integration

The DevFleet MCP server (`devfleet` HTTP server) enables parallel agent orchestration:

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

### 12.2 Agent Selection by Complexity

| Task Complexity | Recommended Tier | Example Use Cases                                         |
| --------------- | ---------------- | --------------------------------------------------------- |
| Simple          | Haiku 4.5        | Single-file edits, docs, small fixes                      |
| Medium          | Sonnet 4.6       | Feature implementation, refactoring, multi-file changes   |
| Complex         | Opus 4.5         | Architecture decisions, deep research, strategic planning |

### 12.3 Subagent Lifecycle

```
SubagentStart → subagent-tracker-subagent.mjs logs spawn event
    ↓
Subagent executes (with model routing if specified)
    ↓
SubagentStop → verify-deliverables-subagent.mjs checks output completeness
    ↓
Results merged into main session context
```

---

## 13. Session & Project Management

### 13.1 Session Structure

```
~/.claude/
├── sessions/<session-id>/     # Active sessions
│   ├── tool-results/          # Tool execution results
│   └── subagents/             # Subagent output
├── projects/<project-id>/     # Project state
│   ├── state.json             # Project state
│   └── subagents/             # Historical subagent logs
├── tasks/                     # Task directories
├── shell-snapshots/           # Shell environment snapshots (5)
├── session-env/               # Session environment variables (99)
├── file-history/              # File change history (91)
└── paste-cache/               # Cached paste files
```

### 13.2 Project Memory System

Project memory preserves context across sessions and compaction:

1. **SessionStart**: `project-memory-session.mjs` detects project directory from `data.cwd`
2. **PostToolUse**: `project-memory-posttool.mjs` saves execution state
3. **PreCompact**: `project-memory-precompact.mjs` preserves memory before compaction
4. **Dynamic Import**: All project memory scripts use try/catch with graceful fallback when `dist/` is missing

### 13.3 Instinct System

Instincts are learned patterns extracted from sessions:

| Command            | Purpose                                    |
| ------------------ | ------------------------------------------ |
| `/learn`           | Extract patterns from current session      |
| `/learn-eval`      | Extract + self-evaluate patterns           |
| `/evolve`          | Generate evolved structures from instincts |
| `/instinct-export` | Export instincts                           |
| `/instinct-import` | Import instincts                           |
| `/instinct-status` | Check statistics                           |
| `/promote`         | Promote project instincts to global scope  |

### 13.4 Session Save/Resume

```bash
/save-session <name>     # Save current session state
/sessions                # List all sessions
/resume-session <name>   # Resume a saved session
```

---

## 14. Troubleshooting

### 14.1 Hook Failures

**Symptom**: Hook crashes with `ERR_MODULE_NOT_FOUND` or `dist/ not found`

**Diagnosis:**

```bash
ls ~/.claude/omc/dist/hooks/project-memory/pre-compact.js
```

**Fix:**

```bash
cd ~/.claude/omc
npm install && npm run build
# Or copy dist/ from GitHub clone
```

All hooks use fail-open pattern — return `{continue: true, suppressOutput: true}` on error.

### 14.2 Model Routing Errors

**Symptom**: `subagent model routing denied`

**Fix:**

1. Use tier aliases (`haiku`/`sonnet`/`opus`) not provider-specific IDs
2. Set resolver env vars in `settings.json`:
   - `ANTHROPIC_DEFAULT_SONNET_MODEL`
   - `ANTHROPIC_DEFAULT_OPUS_MODEL`
   - `ANTHROPIC_DEFAULT_HAIKU_MODEL`

### 14.3 Stale CLAUDE_PLUGIN_ROOT

**Symptom**: Module not found for old plugin version directory

**Fix**: `run.cjs` auto-scans plugin cache for latest version. If still failing, clear stale directories in `~/.claude/plugins/`.

### 14.4 Windows Hook Execution

**Symptom**: `sh` is PE32+ binary on Windows

**Fix**: All OMC hooks now use `run.cjs` which calls `process.execPath` directly. Fixes issues #909, #899, #892, #869.

### 14.5 Context Compaction Losing Memory

**Symptom**: Project context lost after compaction

**Fix:**

1. Verify PreCompact hooks return valid JSON: `echo '{}' \| node ~/.claude/omc/scripts/project-memory-precompact.mjs`
2. Ensure `dist/` exists: `ls ~/.claude/omc/dist/`
3. Enable debug: `export OMC_DEBUG=1`

### 14.6 MCP Server Connection Failures

**Symptom**: MCP server errors in logs

**Fix:**

1. Verify server runs: `npx <server> --version`
2. Check HTTP endpoints: `curl http://localhost:<port>`
3. Restart Claude Code session

### 14.7 Vitest Test Timeout in JSDOM

**Symptom**: Tests timing out at 5000ms with `TypeError: Cannot convert undefined or null to object`

**Root cause**: JSDOM FormData iterator returns undefined for `.keys()`

**Fix:**

```typescript
// WRONG: Array.from(formData.keys())
// CORRECT:
for (const key of Array.from(formData.keys() ?? [])) { ... }
```

---

## Appendix A: Component Counts Summary

| Component Type               | Count    | Location                                                  |
| ---------------------------- | -------- | --------------------------------------------------------- |
| Agent definitions            | 298      | `~/.claude/agents/*.md`                                   |
| Slash commands               | 57       | `~/.claude/commands/*.md`                                 |
| Skill directories            | 125      | `~/.claude/skills/*/SKILL.md`                             |
| Rule files                   | 49       | `~/.claude/rules/*/`                                      |
| Context files                | 3        | `~/.claude/contexts/*.md`                                 |
| MCP servers                  | 24       | `~/.claude/settings.json`                                 |
| Hook event types             | 11       | `~/.claude/settings.json`                                 |
| Individual hooks             | 20       | `~/.claude/settings.json`                                 |
| OMC scripts                  | 40+      | `~/.claude/omc/scripts/`                                  |
| OMC dist modules             | 83       | `~/.claude/omc/dist/`                                     |
| OMC agent variants           | 21       | `~/.claude/omc/agents/`                                   |
| Internal plugins             | 41       | `~/.claude/plugins/marketplaces/claude-plugins-official/` |
| External plugin families     | 16       | `~/.claude/plugins/marketplaces/claude-plugins-official/` |
| **Total ECC+OMC components** | **550+** |                                                           |

## Appendix B: Quick Reference

### Loading an Agent

```
Agent(description: "Architecture review", prompt: "...", subagent_type: "architect")
```

### Using a Command

```
/code-review
/plan
/tdd
/verify
```

### Switching Context

```
/context dev
/context research
/context review
```

### OMC Execution Modes

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

### Debug Mode

```bash
export OMC_DEBUG=1
```

### Health Check

```bash
skill-cli doctor
cat ~/.claude/omc/VERSION
```

## Appendix C: File Locations Reference

| Resource         | Location                                              |
| ---------------- | ----------------------------------------------------- |
| Main settings    | `~/.claude/settings.json`                             |
| Plugin manifest  | `~/.claude/.claude.json`                              |
| Global rules     | `~/.claude/CLAUDE.md`                                 |
| Agents           | `~/.claude/agents/*.md`                               |
| Commands         | `~/.claude/commands/*.md`                             |
| Skills           | `~/.claude/skills/*/SKILL.md`                         |
| Rules            | `~/.claude/rules/{common,typescript,python,...}/*.md` |
| Contexts         | `~/.claude/contexts/*.md`                             |
| OMC root         | `~/.claude/omc/`                                      |
| OMC hooks config | `~/.claude/omc/hooks/hooks.json`                      |
| OMC scripts      | `~/.claude/omc/scripts/*.mjs`                         |
| OMC dist         | `~/.claude/omc/dist/`                                 |
| Plugins          | `~/.claude/plugins/marketplaces/`                     |
| Sessions         | `~/.claude/sessions/`                                 |
| Projects         | `~/.claude/projects/`                                 |
| MCP config       | `~/.claude/settings.json` (mcpServers section)        |
| Search index     | `~/.claude/cc-haha/` (SQLite, 125 MB)                 |
| Session history  | `~/.claude/history.jsonl`                             |
| Tool usage stats | `~/.claude/.session-stats.json`                       |
| Policy limits    | `~/.claude/policy-limits.json`                        |
| Environment      | `~/.claude/.env`                                      |
