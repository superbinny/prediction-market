import type { MDXComponents } from 'mdx/types'
import type { Metadata } from 'next'

import { DocsBody, DocsDescription, DocsPage, DocsTitle } from 'fumadocs-ui/layouts/docs/page'
import defaultMdxComponents from 'fumadocs-ui/mdx'
import { setRequestLocale } from 'next-intl/server'
import { notFound, redirect } from 'next/navigation'

import type { SupportedLocale } from '@/i18n/locales'

import { AffiliateShareDisplay } from '@/app/[locale]/docs/_components/AffiliateShareDisplay'
import { APIPage } from '@/app/[locale]/docs/_components/APIPage'
import { DiscordLink } from '@/app/[locale]/docs/_components/DiscordLink'
import { GammaAPIPage } from '@/app/[locale]/docs/_components/GammaAPIPage'
import { ViewOptions } from '@/app/[locale]/docs/_components/LLMPageActions'
import {
  PublicRuntimeServiceUrl,
  PublicRuntimeWebSocketPlayground,
} from '@/app/[locale]/docs/_components/PublicRuntimeServiceUrl'
import { SecurityReserveBalance } from '@/app/[locale]/docs/_components/SecurityReserveBalance'
import { SiteName } from '@/app/[locale]/docs/_components/SiteName'
import { TradingFeeChart } from '@/app/[locale]/docs/_components/TradingFeeChart'
import { WebSocketPlayground } from '@/app/[locale]/docs/_components/WebSocketPlayground'
import { getDocsStaticParams } from '@/lib/docs-static-params'
import { withLocalePrefix } from '@/lib/locale-path'
import { source } from '@/lib/source'
import { loadRuntimeThemeState } from '@/lib/theme-settings'
import { cn } from '@/lib/utils'

export const instant = false

function getMDXComponents(components?: MDXComponents): MDXComponents {
  return {
    ...defaultMdxComponents,
    APIPage,
    GammaAPIPage,
    AffiliateShareDisplay,
    TradingFeeChart,
    WebSocketPlayground,
    PublicRuntimeServiceUrl,
    PublicRuntimeWebSocketPlayground,
    SecurityReserveBalance,
    DiscordLink,
    SiteName,
    ...components,
  }
}

export async function generateStaticParams() {
  return getDocsStaticParams()
}

async function generateCachedDocsMetadata({ locale, slug }: { locale: string; slug?: string[] }): Promise<Metadata> {
  'use cache'

  setRequestLocale(locale)
  const runtimeTheme = await loadRuntimeThemeState()
  const siteDocumentationTitle = `${runtimeTheme.site.name} Documentation`

  const resolvedSlug = Array.isArray(slug) ? slug : slug === undefined ? [] : [slug]
  let page = source.getPage(resolvedSlug, locale)

  // For root page, source.getPage might return EN even for zh locale
  // Use getPages which has correct data. Check both '/docs' and '/docs/index'.
  if (resolvedSlug.length === 0) {
    const allPages = source.getPages(locale) as any[]
    // Try '/docs/index' first (may have translated content), then '/docs' (may have EN content)
    let rootPage = allPages.find((p: any) => p.url === '/docs/index' && p.locale === locale)
    if (!rootPage) {
      rootPage = allPages.find((p: any) => p.url === '/docs' && p.locale === locale)
    }
    page = rootPage ?? page
    console.log(`[META DEBUG] locale=${locale}, foundZhRoot=${Boolean(page)}, title=${(page as any)?.data?.title}`)
    const rootPageMeta = source.getPages(locale).find((p: any) => p.url === '/docs')
    console.log(
      `[META DEBUG] zh root page data: title=${rootPageMeta?.data?.title} desc=${rootPageMeta?.data?.description?.substring(0, 30)} hasBody=${Boolean(rootPageMeta?.data?.body)}`,
    )
  }

  if (!page) {
    notFound()
  }
  const pageTitle = page.data.title ?? 'Documentation'

  return {
    title: {
      absolute: `${pageTitle} | ${siteDocumentationTitle}`,
    },
    description: page.data.description,
  }
}

export async function generateMetadata(props: PageProps<'/[locale]/docs/[[...slug]]'>): Promise<Metadata> {
  return generateCachedDocsMetadata(await props.params)
}

async function renderCachedDocsPage({ locale, slug }: { locale: string; slug?: string[] }) {
  'use cache'

  setRequestLocale(locale)

  // Fumadocs source.getPage expects an array of slugs (not undefined)
  const resolvedSlug = Array.isArray(slug) ? slug : slug === undefined ? [] : [slug]
  console.log(
    `[PAGE DEBUG] locale=${locale}, originalSlug=${JSON.stringify(slug)}, resolvedSlug=${JSON.stringify(resolvedSlug)}`,
  )

  // Get all pages for this locale to find the correct one
  const allPages = source.getPages(locale) as any[]
  console.log(`[PAGE DEBUG] allPages count for ${locale}:`, allPages.length)

  // Find the zh root page and check its data (try /docs/index first, then /docs)
  const zhRootPage =
    allPages.find((p: any) => p.url === '/docs/index' && p.locale === locale) ??
    allPages.find((p: any) => p.url === '/docs' && p.locale === locale)
  console.log(
    `[PAGE DEBUG] zh root page: url=${zhRootPage?.url} title=${zhRootPage?.data?.title} locale=${zhRootPage?.locale} hasBody=${Boolean(zhRootPage?.data?.body)}`,
  )
  console.log(
    `[PAGE DEBUG] zh root page data keys:`,
    zhRootPage ? Object.keys(zhRootPage.data || {}).join(', ') : 'N/A',
  )

  // First try source.getPage, then fall back to finding the page from getPages
  let page = source.getPage(resolvedSlug, locale)
  if (page && page.url && !resolvedSlug.length) {
    // Root page: find from getPages which has correct data.
    // Try '/docs/index' first (may have translated content), then '/docs' (may have EN content)
    let rootPage = allPages.find((p: any) => p.url === '/docs/index' && p.locale === locale)
    if (!rootPage) {
      rootPage = allPages.find((p: any) => p.url === '/docs' && p.locale === locale)
    }
    if (rootPage) {
      page = rootPage
    }
  }
  const effectivePage = page
  console.log(
    `[PAGE DEBUG] locale=${locale}, found=${Boolean(effectivePage)}, page.url=${(effectivePage as any)?.url ?? 'N/A'}, title=${(effectivePage as any)?.data?.title ?? 'N/A'}, pageLocale=${(effectivePage as any)?.locale ?? 'N/A'}, description=${(effectivePage as any)?.data?.description ?? 'N/A'}`,
  )
  // Debug: find the zh root page in allPages to check data
  if (locale === 'zh' && resolvedSlug.length === 0) {
    const zhRoot = allPages.find((p: any) => p.url === '/docs' && p.locale === 'zh')
    if (zhRoot) {
      console.log(`[PAGE DEBUG] zh root page:`, {
        url: zhRoot.url,
        locale: zhRoot.locale,
        title: zhRoot.data?.title,
        description: zhRoot.data?.description,
        hasBody: Boolean(zhRoot.data?.body),
        bodyType: typeof zhRoot.data?.body,
      })
    }
  }
  if (!effectivePage) {
    redirect(`/${locale}/docs`)
  }

  const localizedPageUrl = withLocalePrefix(effectivePage.url, locale as SupportedLocale)
  const markdownUrl = `${localizedPageUrl}.md`
  const MDX = effectivePage.data.body
  const useFullLayout = Boolean(effectivePage.data.full)

  return (
    <DocsPage
      toc={effectivePage.data.toc}
      full={useFullLayout}
      tableOfContent={{
        style: 'clerk',
      }}
    >
      <div className="border-b pb-4 lg:pb-0">
        <div className="flex items-start justify-between gap-4">
          <div className="min-w-0">
            <DocsTitle>{effectivePage.data.title}</DocsTitle>
            <DocsDescription>{effectivePage.data.description}</DocsDescription>
          </div>
          <div className="hidden shrink-0 items-center gap-2 lg:flex">
            <ViewOptions markdownUrl={markdownUrl} />
            <DiscordLink className="h-8.5">Get Help</DiscordLink>
          </div>
        </div>
        <div className="-mt-4 flex flex-wrap items-center gap-2 lg:hidden">
          <ViewOptions markdownUrl={markdownUrl} />
          <DiscordLink className="h-8.5">Get Help</DiscordLink>
        </div>
      </div>
      <DocsBody className={cn({ 'max-w-none': useFullLayout })}>
        <MDX components={getMDXComponents()} />
      </DocsBody>
    </DocsPage>
  )
}

export default async function Page(props: PageProps<'/[locale]/docs/[[...slug]]'>) {
  return renderCachedDocsPage(await props.params)
}
