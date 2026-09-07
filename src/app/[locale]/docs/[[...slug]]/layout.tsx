import type { Root } from 'fumadocs-core/page-tree'
import type { ReactNode } from 'react'

import { DocsLayout } from 'fumadocs-ui/layouts/docs'
import { BookOpenIcon, HomeIcon, SquareTerminalIcon } from 'lucide-react'
import { setRequestLocale } from 'next-intl/server'

import DiscordIcon from '@/components/icons/DiscordIcon'
import SiteLogoIcon from '@/components/SiteLogoIcon'
import { source } from '@/lib/source'
import { loadRuntimeThemeState } from '@/lib/theme-settings'

interface DocsSlugLayoutProps {
  params: Promise<{ locale: string; slug?: string[] }>
  children: ReactNode
}

const translations: Record<string, Record<string, string>> = {
  en: {
    docsTabTitle: 'Documentation',
    docsTabDesc: 'For Users',
    apiTabTitle: 'API Reference',
    apiTabDesc: 'For Developers',
    mainSiteLink: 'Main site',
    helpLink: 'Get Help',
  },
  zh: {
    docsTabTitle: '文档',
    docsTabDesc: '面向用户',
    apiTabTitle: 'API 参考',
    apiTabDesc: '面向开发者',
    mainSiteLink: '主站',
    helpLink: '获取帮助',
  },
}

export default async function Layout({ params, children }: DocsSlugLayoutProps) {
  const { locale } = await params
  setRequestLocale(locale)
  const runtimeTheme = await loadRuntimeThemeState()
  const site = runtimeTheme.site
  const msgs = translations[locale] || translations.en

  return (
    <DocsLayout
      nav={{
        url: '/docs',
        title: (
          <>
            <SiteLogoIcon
              logoSvg={site.logoSvg}
              logoImageUrl={site.logoImageUrl}
              alt={`${site.name} logo`}
              className="size-6"
              imageClassName="object-contain"
              size={24}
            />
            <span className="font-medium">{`${site.name} ${msgs.docsTabTitle}`}</span>
          </>
        ),
        transparentMode: 'top',
      }}
      sidebar={{
        prefetch: false,
        tabs: [
          {
            title: msgs.docsTabTitle,
            description: msgs.docsTabDesc,
            url: '/docs',
            icon: <BookOpenIcon className="size-4" />,
          },
          {
            title: msgs.apiTabTitle,
            description: msgs.apiTabDesc,
            url: '/docs/api-reference',
            icon: <SquareTerminalIcon className="size-4" />,
          },
        ],
      }}
      tree={source.getPageTree(locale) as Root}
      themeSwitch={{
        mode: 'light-dark-system',
      }}
      links={[
        {
          type: 'main',
          url: '/',
          external: true,
          text: msgs.mainSiteLink,
          icon: <HomeIcon />,
        },
        ...(site.discordLink
          ? [
              {
                type: 'main' as const,
                url: site.discordLink,
                external: true,
                text: msgs.helpLink,
                icon: <DiscordIcon />,
              },
            ]
          : []),
      ]}
    >
      {children}
    </DocsLayout>
  )
}
