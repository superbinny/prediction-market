<!--
  Created:     2026-09-14  14:00（创建时间）
  Filename:    CONTRIBUTING.md（脚本文件名）
  Author:   ______
               / /  (_)
              / /_  /\____  ____  __   ______
             / __ \/ / __ \/ __ \/ /  / /
            / /_/ / / / / / / / / /__/ /
           /_____/_/_/ /_/_/____  /
      ========== ______________/ /
                         \______________/

       Email:       Binny@vip.163.com
       Group:       SP
       Create By:   Binny
       Purpose:     Kuest Prediction Market — Contributing Guide
       Copyright:   TJYM(C) 2010 - All Rights Reserved
       Version:     1.0（版本号）
       LastModify:  2026-09-14（最后一次修改日期）
-->

# Contributing to Kuest

> **Last Updated:** 2026-09-14
>
> This guide covers development workflows, environment setup, code quality, and PR submission for the Kuest prediction market platform.

<!-- AUTO-GENERATED -->

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Using Claude Code with ECC](#using-claude-code-with-ecc)
- [Available Scripts](#available-scripts)
- [Environment Variables](#environment-variables)
- [Testing](#testing)
- [Code Style & Enforcement](#code-style--enforcement)
- [Project Structure](#project-structure)
- [PR Submission Checklist](#pr-submission-checklist)

<!-- AUTO-GENERATED -->

## Prerequisites

| Requirement    | Version  | Notes                                                   |
| -------------- | -------- | ------------------------------------------------------- |
| **Node.js**    | 24.x     | LTS recommended                                         |
| **pnpm**       | 11.22.0+ | Specified in `packageManager` field                     |
| **PostgreSQL** | 17+      | Required for local development (use Docker or Supabase) |
| **Git**        | Latest   | For version control                                     |

Install corepack to use the project's pinned pnpm version:

```bash
corepack enable
```

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/kuestcom/prediction-market.git
cd prediction-market

# 2. Install dependencies
pnpm install

# 3. Copy environment variables
cp .env.example .env.local

# 4. Fill in required values in .env.local (see Environment Variables section)

# 5. Run database migrations
pnpm db:push

# 6. Start the development server
pnpm dev
```

The app will be available at `http://localhost:3000`.

## Using Claude Code with ECC

This project uses **Everything Claude Code (ECC)** — a comprehensive extension system that transforms Claude Code into a full-scale engineering organization. Below is a step-by-step guide.

### 1. What is ECC?

ECC provides:

- **298 specialized agents** for code review, testing, security, architecture, and more
- **57 slash commands** for TDD, multi-agent workflows, session management, and more
- **125 skill packs** with domain-specific patterns and best practices
- **49 rule files** across 9 programming languages
- **24 MCP servers** for external tool integration (browser, GitHub, Vercel, Supabase)
- **Hook system** that automates verification, memory, and code quality checks

### 2. Starting a Session

Launch Claude Code from the project root:

```bash
pnpm dev   # Start dev server in one terminal
claude     # Start Claude Code in another terminal
```

Claude Code auto-loads `CLAUDE.md` (project rules) and `~/.claude/CLAUDE.md` (global copyright and orchestration rules).

### 3. Invoking Agents

Agents are specialized AI personas. Invoke them with the `Agent` tool:

```
# For implementation planning
"Plan the new affiliate dashboard feature"

# For code review
"Review the changes in src/lib/auth.ts"

# For security analysis
"Scan the API routes for injection vulnerabilities"

# For build error resolution
"The build failed with TypeScript errors"
```

Key agents for this project:

| Agent                  | When to Use                                             |
| ---------------------- | ------------------------------------------------------- |
| `planner`              | Complex feature requests, architectural changes         |
| `code-reviewer`        | Immediately after writing or modifying code             |
| `security-reviewer`    | When handling user input, authentication, API endpoints |
| `tdd-guide`            | Writing new features or fixing bugs                     |
| `build-error-resolver` | When the build fails or TypeScript errors occur         |
| `refactor-cleaner`     | Removing dead code, consolidating duplicates            |
| `doc-updater`          | Updating documentation and codemaps                     |

### 4. Using Commands

Commands are slash-invocable workflows. Common commands:

| Command            | Purpose                                       |
| ------------------ | --------------------------------------------- |
| `/update-docs`     | Sync documentation with the codebase          |
| `/update-codemaps` | Update project architecture diagrams          |
| `/commit`          | Create a git commit with conventional commits |
| `/review-pr`       | Review a pull request                         |
| `/test-coverage`   | Check test coverage                           |
| `/tdd`             | Enforce test-driven development workflow      |
| `/verify`          | Quality gate verification                     |
| `/claw`            | Start the NanoClaw REPL                       |
| `/plan`            | Create implementation plan before coding      |
| `/code-review`     | Comprehensive code review                     |

Usage: Type `/command-name` in the chat prompt.

### 5. Loading Skills

Skills provide domain-specific knowledge. They auto-trigger based on keywords, but can also be invoked manually:

```
# Auto-triggered examples:
- Writing Python → `python-patterns` skill loads
- Building Docker → `docker-patterns` skill loads
- New feature → `tdd-workflow` skill loads

# Manual invocation:
/skill-name --args
```

Key skills for this project:

| Skill                 | Purpose                           |
| --------------------- | --------------------------------- |
| `typescript-patterns` | TypeScript idioms, React patterns |
| `nextjs-turbopack`    | Next.js 16+ patterns              |
| `postgres-patterns`   | Database queries, migrations      |
| `security-scan`       | Secrets, XSS, injection checks    |
| `e2e-testing`         | Playwright E2E tests              |
| `coding-standards`    | Universal code style rules        |
| `nextjs-turbopack`    | Next.js bundling and rendering    |

### 6. Hook System

Hooks run automatically at key events. No configuration needed:

- **SessionStart**: Loads project memory, injects skills, checks environment
- **PreToolUse**: Validates tool calls before execution
- **PostToolUse**: Runs code verifier, updates project memory, injects rules
- **PreCommit**: Runs oxlint and oxfmt on staged files
- **PrePush**: Runs unit tests and production build
- **SessionEnd**: Context guard, persistent mode check

### 7. Best Practices

1. **Always use the planner** for complex features — type "Plan the X feature" to auto-activate the planner agent
2. **Run code review** after every meaningful code change — the code-reviewer agent is mandatory
3. **Enable security scanner** when handling user input or API endpoints
4. **Follow TDD** with the tdd-guide agent — tests before implementation
5. **Use conventional commits** — the hook system auto-enforces the format
6. **Let hooks do the work** — don't manually run linters/formatters in the terminal when Claude Code handles it
7. **Check project memory** — relevant context is auto-loaded from `MEMORY.md`

### 8. Multi-Agent Workflows

For large features, use the orchestrator:

```
"Orchestrate the new payment feature with architect, frontend, backend, and qa agents"
```

This splits the work into parallel tasks:

- **architect**: Designs the system layout
- **frontend**: Implements UI components
- **backend**: Builds API routes and data layer
- **qa**: Writes tests and verifies each component

### 9. Model Selection

- **Haiku**: Fast, lightweight tasks (code completion, simple edits) — 3x cost savings
- **Sonnet**: Main development work (features, refactoring, debugging)
- **Opus**: Complex decisions (architecture, security audits, research)

## Available Scripts

All scripts are defined in `package.json`.

| Script          | Command                   | Description                                                 |
| --------------- | ------------------------- | ----------------------------------------------------------- |
| `pnpm dev`      | `next dev`                | Start the Next.js development server at localhost:3000      |
| `pnpm build`    | `next build`              | Production build with Sentry source map upload              |
| `pnpm start`    | `next start`              | Start the production server                                 |
| `pnpm lint`     | `oxlint . --fix`          | Lint with oxlint (type-aware), auto-fix issues              |
| `pnpm fmt`      | `oxfmt`                   | Format files with oxfmt                                     |
| `pnpm test`     | `vitest run`              | Run unit tests (Vitest)                                     |
| `pnpm test:e2e` | `playwright test`         | Run end-to-end tests (Playwright, Chromium + Mobile Safari) |
| `pnpm knip`     | `knip --fix`              | Detect and remove unused dependencies/files                 |
| `pnpm db:push`  | `node scripts/migrate.ts` | Push Drizzle ORM schema changes to the database             |
| `pnpm prepare`  | `husky`                   | Install Git hooks (runs on `pnpm install`)                  |

## Environment Variables

Copy `.env.example` to `.env.local` and configure the following variables.

### Required Variables

| Variable                  | Description                                                                                                    |
| ------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `KUEST_ADDRESS`           | Your EVM wallet address (Polygon, `0x...`) from https://auth.kuest.com                                         |
| `KUEST_API_KEY`           | API key for Kuest CLOB authentication                                                                          |
| `KUEST_API_SECRET`        | API secret for Kuest CLOB authentication                                                                       |
| `KUEST_PASSPHRASE`        | Passphrase for Kuest CLOB authentication                                                                       |
| `ADMIN_WALLETS`           | Comma-separated list of admin EVM wallet addresses on Polygon                                                  |
| `SITE_URL`                | Public URL of the site (used for canonical links, embeds, callbacks)                                           |
| `REOWN_APPKIT_PROJECT_ID` | Project ID from http://dashboard.reown.com/                                                                    |
| `BETTER_AUTH_SECRET`      | Random 32-character secret (use the "generate secret" button at https://www.better-auth.com/docs/installation) |
| `CRON_SECRET`             | Random secret (16+ characters) for Vercel cron jobs                                                            |

> **Note:** Changing `BETTER_AUTH_SECRET` invalidates all user sessions and encrypted credentials.

### Optional Variables

| Variable                               | Description                                                                               |
| -------------------------------------- | ----------------------------------------------------------------------------------------- |
| `DISABLE_IMAGE_OPTIMIZATION`           | Set to `true` to disable Next.js image optimization (default: `false`)                    |
| `POLYGON_RPC_URL`                      | Comma-separated RPC endpoints for on-chain reads                                          |
| `CHAIN_ID`                             | Active chain ID. Empty/`80002` for Amoy testnet, `137` for Polygon mainnet                |
| `RESOLUTION_REPORT_MIN_TRADED_MARKETS` | Minimum number of distinct traded markets required to propose a resolution (default: `5`) |
| `BUILD_PRERENDER_PUBLIC_SHELL`         | Force public shell prerendering on/off during builds                                      |
| `POSTGRES_URL`                         | PostgreSQL runtime connection string (required outside Vercel/Supabase)                   |
| `SUPABASE_URL`                         | Supabase project URL (if using Supabase)                                                  |
| `SUPABASE_SERVICE_ROLE_KEY`            | Supabase service role key (if using Supabase)                                             |
| `S3_BUCKET`                            | S3 bucket name for storage                                                                |
| `S3_ENDPOINT`                          | S3-compatible endpoint URL                                                                |
| `S3_REGION`                            | S3 region                                                                                 |
| `S3_ACCESS_KEY_ID`                     | S3 access key ID                                                                          |
| `S3_SECRET_ACCESS_KEY`                 | S3 secret access key                                                                      |
| `S3_PUBLIC_URL`                        | Public S3 URL                                                                             |
| `S3_FORCE_PATH_STYLE`                  | Force path-style S3 URLs (default: `true`)                                                |
| `SENTRY_DSN`                           | Sentry DSN for error monitoring                                                           |
| `SENTRY_ORG`                           | Sentry organization name                                                                  |
| `SENTRY_PROJECT`                       | Sentry project name                                                                       |
| `SENTRY_AUTH_TOKEN`                    | Sentry auth token                                                                         |
| `EVENT_CREATION_SIGNER_PRIVATE_KEYS`   | Comma-separated private keys for signing recurring event creations                        |

## Testing

### Unit Tests

Unit tests use **Vitest** with both Node and jsdom environments.

```bash
# Run all unit tests
pnpm test

# Run a specific test file
pnpm test tests/unit/EventCard.test.tsx
```

- Tests in `tests/unit/**/*.test.ts` (Node environment) — utility functions, hooks, data processing
- Tests in `tests/unit/**/*.test.tsx` (jsdom environment) — React components

### E2E Tests

E2E tests use **Playwright** with Chromium and Mobile Safari.

```bash
# Run all E2E tests
pnpm test:e2e

# Run E2E tests in a specific browser project
pnpm test:e2e --project=chromium

# Run E2E tests in headed mode for debugging
pnpm test:e2e --headed
```

E2E test files are located in `tests/e2e/` and target critical user flows (home page, public profile, search).

### Running All Tests

```bash
# Pre-push hook runs this automatically
pnpm test
pnpm build
```

## Code Style & Enforcement

### Linting — oxlint

The project uses **oxlint** for linting with type-aware checking:

```bash
pnpm lint
pnpm lint --fix    # Auto-fix fixable issues
```

### Formatting — oxfmt

Code is formatted with **oxfmt**:

```bash
pnpm fmt
```

### Git Hooks — Husky

Git hooks are managed via **Husky** and run automatically:

**Pre-commit hook** (runs on every `git commit`):

1. `oxlint --fix` — lint and auto-fix staged files
2. `oxfmt` — format staged files

**Pre-push hook** (runs before `git push`):

1. `pnpm test` — run all unit tests
2. `pnpm build` — verify production build succeeds

**Staged file hooks** (via `lint-staged`):

```json
"lint-staged": {
  "*": [
    "oxlint --fix --no-error-on-unmatched-pattern",
    "oxfmt --no-error-on-unmatched-pattern"
  ]
}
```

### Additional Quality Checks

```bash
# Detect unused dependencies and files
pnpm knip

# Run both lint + format on the entire codebase
pnpm lint && pnpm fmt
```

## Project Structure

```
src/
├── app/[locale]/          # Next.js App Router (locale-based routing)
│   ├── (platform)/        # Main trading interface (markets, events, sports)
│   ├── admin/             # Operator admin dashboard
│   ├── auth/              # Login/signup flows (SIWE)
│   ├── docs/              # Fumadocs documentation site
│   └── api/               # API routes (50+ endpoints)
├── components/ui/         # shadcn/ui component library (214+ components)
├── lib/                   # Core libraries (db, auth, clob, web3)
├── stores/                # Zustand stores
├── hooks/                 # Custom React hooks
└── providers/             # React context providers
tests/
├── unit/                  # Vitest unit tests
└── e2e/                   # Playwright E2E tests
infra/
├── docker/                # Dockerfile, docker-compose configs
scripts/                   # Migration and utility scripts
docs/                      # This directory
```

## PR Submission Checklist

Before submitting a pull request, verify:

- [ ] `pnpm lint` passes with no errors
- [ ] `pnpm test` passes (all unit tests green)
- [ ] `pnpm build` succeeds (production build works)
- [ ] Code follows the style guide (immutability, no `any`, explicit types on public APIs)
- [ ] New files include the required copyright header (see root CLAUDE.md)
- [ ] Environment variables are documented in `.env.example` if newly required
- [ ] Related tests are written or updated
- [ ] No hardcoded secrets in source code
- [ ] All `console.log` statements removed from production code
- [ ] Commit message follows conventional commits format: `type: description`
  - Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

<!-- AUTO-GENERATED -->
