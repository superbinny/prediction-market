# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kuest is a white-label prediction market platform built on Polygon, derived from Polymarket's CLOB (Central Limit Order Book) architecture. It enables operators to launch branded prediction markets with shared liquidity, configurable trading fees, and on-chain resolution via UMA.

**Stack:** Next.js 16 (App Router, React Compiler, React 19) + TypeScript 7 + Tailwind CSS 4 + shadcn/ui (New York style) + Better Auth + Drizzle ORM + PostgreSQL (Supabase) + Wagmi/Reown AppKit (Web3) + Fumadocs (documentation) + Sentry + next-intl (13 locales).

**Deployment:** Vercel (primary), with infra templates for Cloud Run, Docker, Fly.io, Kubernetes, and Railway.

## Key Commands

```bash
# Development
pnpm dev              # Start Next.js dev server (localhost:3000)
pnpm build            # Production build (Next.js + Sentry upload)
pnpm start            # Start production server

# Code quality
pnpm lint             # oxlint with type-aware checking + tsgolint
pnpm fmt              # oxfmt (format on save in dev)
pnpm knip             # knip (unused dependency/file detection)
pnpm db:push          # Run Drizzle migrations against database

# Testing
pnpm test             # Vitest (unit tests) — runs all tests
pnpm test -- <name>   # Run specific test file
pnpm test:e2e         # Playwright E2E tests (chromium + Mobile Safari)
```

**Pre-commit hooks (via husky):** `oxlint --fix` then `oxfmt` on all staged files. Preview deployments are skipped when commit message contains `[skip deploy]`.

## Architecture

### Routing Structure (`src/app/[locale]/`)

The app uses Next.js App Router with locale-based route groups:

- **`(platform)`** — Main trading interface. Contains home, events, markets, predictions, portfolio, profile, leaderboard, sports, esports, activity, settings routes.
- **`(home)`** — Home page with featured events carousel, filter toolbar, events grid, category sidebar.
- **`event/[slug]`** — Single event detail with markets list, sports metadata, and admin controls.
- **`event/[slug]/[market]`** — Individual market page with order book, chart, and trade execution.
- **`predictions/[slug]`** — Predictions hub pages.
- **`admin`** — Operator admin dashboard (affiliates, settings, events, sports, proposers).
- **`auth`** — Login/signup flows (wallet-based SIWE).
- **`2fa`** — Two-factor authentication pages.
- **`docs`** — Fumadocs documentation site.

### Core Layers

| Layer          | Location                                                | Purpose                                                                                                   |
| -------------- | ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| **API Routes** | `src/app/[locale]/api/`                                 | Affiliate, auth, CLOB proxy, markets, events, leaderboard, geoblock, OG images, notifications, LiFi swaps |
| **Database**   | `src/lib/db/`                                           | Drizzle ORM schema + queries (PostgreSQL/Supabase)                                                        |
| **Web3**       | `src/lib/appkit.ts`, `src/providers/AppKitProvider.tsx` | Reown AppKit + Wagmi adapter, SIWE auth, Polygon network                                                  |
| **CLOB**       | `src/lib/clob.ts`                                       | Polymarket-derived Central Limit Order Book integration                                                   |
| **Auth**       | `src/lib/auth.ts`                                       | Better Auth with SIWE, 2FA, custom sessions, nextCookies                                                  |
| **i18n**       | `src/i18n/`                                             | next-intl with 13 locale message files (ar, de, en, es, fr, it, ja, ko, pl, pt, ru, zh)                   |
| **State**      | `src/stores/`, `src/hooks/`                             | Zustand stores (user, notifications, order) + custom hooks                                                |
| **UI**         | `src/components/ui/`                                    | shadcn/ui component library (214+ components)                                                             |
| **Providers**  | `src/providers/`                                        | AppKit, AppProviders, CommunityFollows, TradeAlerts, SiteIdentity, PublicRuntimeConfig                    |

### Database Schema (`src/lib/db/schema/`)

Ten schema domains: affiliates, auth, bookmarks, events, notifications, orders, settings, subgraph, sumsub (KYC), and tags. Relations are exported per-domain. Migrations live in `src/lib/db/migrations/` as numbered SQL files.

### Key Integration Points

- **Polygon + UMA Oracle:** Trading on Polygon mainnet/testnet (Amoy). Resolution via UMA proposer whitelist.
- **Polymarket CLOB:** Order book data and trade execution proxy through the CLOB service.
- **Li.Fi:** Cross-chain token swaps (lifi API route + hooks).
- **Sumsub:** KYC identity verification.
- **AWS S3:** Image/file storage with custom image optimization loader.
- **Supabase:** PostgreSQL database + storage buckets.

### Runtime Configuration

Site identity, theme, CLOB URL, chain ID, and fee settings are configured per-deployment via environment variables and exposed through `PublicRuntimeConfig`. The `resolvePublicRuntimeEnv` function handles server-side config resolution.

## Conventions

- Path alias `@/` maps to `./src/` (configured in `tsconfig.json`).
- Components use `'use client'` directive when needed; server components are the default.
- React Compiler is enabled (`reactCompiler: true`) — automatic memoization, avoid manual `useMemo`/`useCallback` unless necessary.
- `reactStrictMode: false` — no double-rendering in dev.
- All API routes are async Server Components or Route Handlers under `src/app/[locale]/api/`.
- UI components follow shadcn/ui patterns with `cn()` utility (tailwind-merge + clsx).
- Tests: unit tests in `tests/unit/` (Vitest, node + jsdom environments), E2E in `tests/e2e/` (Playwright).
- Oxlint rules are strict — type-aware checking enabled, no unused imports, exhaustive deps discouraged (use oxlint's rules instead).

<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->
