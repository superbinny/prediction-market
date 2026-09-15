<!--
  Created:     2026-09-14  14:00（创建时间）
  Filename:    RUNBOOK.md（脚本文件名）
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
       Purpose:     Kuest Prediction Market — Operational Runbook
       Copyright:   TJYM(C) 2010 - All Rights Reserved
       Version:     1.0（版本号）
       LastModify:  2026-09-14（最后一次修改日期）
-->

---

title: Operational Runbook
---

# Kuest Prediction Market — Operational Runbook

> **Last Updated:** 2026-09-14
>
> This runbook covers deployment, monitoring, common issues, and rollback procedures for the Kuest prediction market platform.

<!-- AUTO-GENERATED -->

## Table of Contents

- [Deployment Procedures](#deployment-procedures)
  - [Vercel Deployment](#vercel-deployment)
  - [Docker Deployment](#docker-deployment)
  - [Manual Production Start](#manual-production-start)
- [Health Checks & Monitoring](#health-checks--monitoring)
- [Scheduled Jobs](#scheduled-jobs)
- [Common Issues & Fixes](#common-issues--fixes)
  - [Database Migrations](#database-migrations)
  - [Image Optimization](#image-optimization)
  - [Prerendering Timeouts](#prerendering-timeouts)
  - [Web3 Connection Failures](#web3-connection-failures)
  - [S3 / Storage Issues](#s3--storage-issues)
  - [Session Invalidation](#session-invalidation)
- [Rollback Procedures](#rollback-procedures)

<!-- AUTO-GENERATED -->

## Deployment Procedures

### Vercel Deployment

The recommended deployment path is Vercel. The `vercel.json` config defines:

```json
{
  "buildCommand": "pnpm db:push && next build",
  "ignoreCommand": "if [ \"$VERCEL_ENV\" = \"preview\" ] || git log -1 --pretty=%B | grep -q '\\[skip deploy\\]'; then exit 0; else exit 1; fi"
}
```

**Push-based deployment:**

```bash
# 1. Push to main branch
git push origin main

# 2. Vercel auto-deploys (builds + migrations run automatically)
# Monitor the Vercel dashboard for build status

# 3. Verify deployment
curl https://your-site-url.com
```

**Skip deployment** on a specific commit:

```bash
git commit -m "fix: minor update [skip deploy]"
```

**Preview deployments:** Every non-main branch gets an automatic preview URL from Vercel.

**Production deploys are locked to the `main` branch** (all other branches are disabled for production).

### Docker Deployment

Two docker-compose configurations are provided:

**Development (with local PostgreSQL):**

```bash
cd infra/docker
docker compose --profile local-postgres up -d
```

**Production (with Caddy reverse proxy):**

```bash
cd infra/docker
docker compose -f docker-compose.production.yml up -d --build
```

The production compose file:

- Builds the Dockerfile in `infra/docker/Dockerfile`
- Proxies traffic through Caddy on ports 80/443
- Includes health checks on the web container
- Logs to json-file driver (10MB max, 3 files)

**Dockerfile stages:**

1. **Build stage** — installs node:24-bookworm-slim, sets up pnpm, installs deps, runs `pnpm build`
2. **Runner stage** — minimal image with standalone Next.js output, `node server.js`

### Manual Production Start

After a successful build:

```bash
pnpm build
pnpm start
```

The build output includes:

- `.next/standalone/` — standalone Next.js server
- `public/` — static assets
- `scripts/` — migration scripts (for `db:push`)
- `src/lib/site-url.ts` — site URL resolution
- `src/lib/db/migrations/` — migration SQL files

<!-- AUTO-GENERATED -->

## Health Checks & Monitoring

### Application Health

The Docker production compose file includes a health check:

```yaml
healthcheck:
  test: [CMD, node, -e, "fetch('http://127.0.0.1:3000').then((r)=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
  interval: 30s
  timeout: 5s
  retries: 6
  start_period: 40s
```

Verify manually:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
# Expected: 200
```

### Sentry Monitoring

Sentry is configured in `sentry.server.config.ts`:

```typescript
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 0.1,
  enableLogs: true,
  beforeSend(event, hint) {
    // Filter out 404 errors
    if (isNextNotFoundError(hint.originalException)) {
      return null
    }
    return event
  },
})
```

**Required Sentry env vars:** `SENTRY_DSN`, `SENTRY_ORG`, `SENTRY_PROJECT`, `SENTRY_AUTH_TOKEN`

**Check Sentry for:**

- Error rates and crash reports
- Transaction traces for slow endpoints
- Release tracking (source maps uploaded during `next build`)

### Vercel Cron Jobs

The `CRON_SECRET` env var is used for internal cron endpoints. Cron jobs are configured via:

- **Vercel Cron** (hosted deployment) — defined in Vercel dashboard
- **pg_cron** (Self-hosted Supabase) — configured automatically during `pnpm db:push`

<!-- AUTO-GENERATED -->

## Scheduled Jobs

The `scripts/migrate.ts` script sets up pg_cron jobs when running against a Supabase database. Key scheduled endpoints:

| Job Name               | Schedule          | Endpoint                    | Description                          |
| ---------------------- | ----------------- | --------------------------- | ------------------------------------ |
| `sync-events`          | Every 9 min       | `/api/sync/events`          | Sync event data                      |
| `sync-event-creations` | Every 30 min      | `/api/sync/event-creations` | Process pending event creations      |
| `sync-translations`    | Every ~9 min      | `/api/sync/translations`    | Sync translations                    |
| `sync-resolution`      | Every 10 min      | `/api/sync/resolution`      | Sync market resolutions              |
| `sync-sports-scores`   | Every minute      | `/api/sync/sports-scores`   | Fetch latest sports scores           |
| `sync-volume`          | Every 5 min       | `/api/sync/volume`          | Track trading volume                 |
| `clean-jobs`           | Every hour (15m)  | N/A                         | Clean up stale/completed/failed jobs |
| `clean-cron-details`   | Daily at midnight | N/A                         | Remove old cron job run logs         |

**pg_net extension** is required for HTTP-based cron jobs. If missing, sync endpoints must be configured externally (see https://docs.kuest.com/manual-installation/scheduler-jobs).

<!-- AUTO-GENERATED -->

## Common Issues & Fixes

### Database Migrations

**Problem:** Build fails with migration errors.

**Diagnosis:**

```bash
# Check if migrations are applied
node scripts/migrate.ts
```

**Fixes:**

```bash
# Push pending migrations to database
pnpm db:push

# Ensure POSTGRES_URL or POSTGRES_URL_NON_POOLING is set
# For Supabase mode, ensure SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are both set
```

**Migration script behavior:**

- Checks `migrations` table for already-applied versions
- Rewrites `TO service_role` to `TO CURRENT_USER` for non-Supabase deployments
- Acquires a PostgreSQL advisory lock (`20817, 1`) to prevent concurrent migrations
- Auto-configures pg_cron jobs in Supabase mode

### Image Optimization

**Problem:** Image optimization returns errors or slow responses in production.

**Fix:** Set `DISABLE_IMAGE_OPTIMIZATION=true` in environment variables.

This is useful when deploying to environments without standard image optimization support (e.g., custom CDN without Next.js image handler).

### Prerendering Timeouts

**Problem:** Build hangs or times out during prerendering of pages (e.g., sports pages).

**Symptoms:**

- `next build` stalls at a specific route
- Console shows "Prerender timeout" or "resolve prerender timeout"

**Fixes:**

1. **Force prerendering off:**

   ```bash
   BUILD_PRERENDER_PUBLIC_SHELL=true   # or false
   ```

2. **Remove `'use cache'` from problematic components** — check recent commits for patterns like:

   ```
   fix(sports): remove 'use cache' from SportsFeedPageContent to resolve prerender timeout
   ```

3. **Graceful DB error handling** — ensure API routes handle DB connection failures during build time:
   ```bash
   # The build runs db:push first (via vercel.json buildCommand)
   # If DB is unavailable, set POSTGRES_URL to a valid connection string
   ```

### Web3 Connection Failures

**Problem:** Wallet connections fail, transactions time out.

**Checks:**

1. Verify `POLYGON_RPC_URL` is configured (comma-separated RPC endpoints)
2. Confirm `CHAIN_ID` matches the target network (`80002` for Amoy testnet, `137` for Polygon mainnet)
3. Ensure `REOWN_APPKIT_PROJECT_ID` is valid from https://dashboard.reown.com/
4. Check that `KUEST_ADDRESS`, `KUEST_API_KEY`, `KUEST_API_SECRET`, `KUEST_PASSPHRASE` are correct

**Common fix:** RPC endpoint rate limits. Add multiple RPC URLs:

```bash
POLYGON_RPC_URL=https://polygon-rpc.com,https://rpc.ankr.com/polygon,https://1inch.rpc.thirdweb.com
```

### S3 / Storage Issues

**Problem:** Images fail to upload or display.

**Check environment:**

```bash
# If using Supabase storage
echo "SUPABASE_URL=$SUPABASE_URL"
echo "SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY"

# If using direct S3 storage
echo "S3_BUCKET=$S3_BUCKET"
echo "S3_ENDPOINT=$S3_ENDPOINT"
echo "S3_REGION=$S3_REGION"
```

**Requirements:**

- If `SUPABASE_*` is not set, all `S3_*` variables are required
- `S3_FORCE_PATH_STYLE=true` is the default (required for non-AWS S3-compatible storage)

### Session Invalidation

**Problem:** All users are logged out after deployment.

**Cause:** `BETTER_AUTH_SECRET` was changed.

**Fix:** Either:

1. Keep `BETTER_AUTH_SECRET` constant across deployments
2. Or accept that all sessions will be invalidated and users must re-login

**Other session invalidation causes:**

- Database downtime (Better Auth stores sessions in DB)
- `POSTGRES_URL` connection failure

<!-- AUTO-GENERATED -->

## Rollback Procedures

### Vercel Rollback

```bash
# 1. Find the commit to roll back to
git log --oneline -20

# 2. Checkout and push the previous commit
git checkout <previous-commit-hash>
git push origin <previous-commit-hash>:main --force

# 3. Or use Vercel Dashboard:
#    Settings > Deployments > Rollback
```

**Important:** The build command runs `pnpm db:push` automatically, so migrations are applied on rollback. Ensure the target commit has compatible migrations.

### Docker Rollback

```bash
cd infra/docker

# Roll back to a previous image tag
docker compose -f docker-compose.production.yml up -d --force-recreate

# Or rebuild from a specific commit
docker compose -f docker-compose.production.yml build --no-cache
docker compose -f docker-compose.production.yml up -d
```

### Database Rollback

If a migration introduced breaking changes:

```bash
# 1. Identify the migration file to undo
ls src/lib/db/migrations/

# 2. Run the rollback SQL (if migration includes rollback)
psql "$POSTGRES_URL" -f src/lib/db/migrations/<rollback_file>.sql

# 3. Restart the application
```

### Rollback Checklist

- [ ] Identify the commit/Tag to roll back to
- [ ] Ensure migrations are backward compatible (or have rollback scripts)
- [ ] Re-deploy the previous version
- [ ] Verify health check passes (`curl http://localhost:3000`)
- [ ] Check Sentry for error rate changes
- [ ] Monitor for new incidents in Discord/Slack

<!-- AUTO-GENERATED -->

## Quick Reference

| Task              | Command                                                         |
| ----------------- | --------------------------------------------------------------- |
| Start dev server  | `pnpm dev`                                                      |
| Production build  | `pnpm build`                                                    |
| Run tests         | `pnpm test`                                                     |
| Run E2E tests     | `pnpm test:e2e`                                                 |
| Lint and fix      | `pnpm lint`                                                     |
| Format code       | `pnpm fmt`                                                      |
| Push migrations   | `pnpm db:push`                                                  |
| Find unused deps  | `pnpm knip`                                                     |
| Docker local dev  | `docker compose --profile local-postgres up -d`                 |
| Docker production | `docker compose -f docker-compose.production.yml up -d --build` |
| Health check      | `curl http://localhost:3000`                                    |

<!-- AUTO-GENERATED -->
