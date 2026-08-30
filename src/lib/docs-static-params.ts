import type { SupportedLocale } from '@/i18n/locales'

import { source } from '@/lib/source'

interface DocsStaticParam {
  slug?: string[]
}

const DOCS_LOCALES = ['en', 'zh'] as SupportedLocale[]

function getAllDocsParams(): Array<{ locale: string; slug: string[] | undefined }> {
  const params = source.generateParams()
  return params.flatMap(({ slug }: DocsStaticParam) => {
    if (slug?.[0] === 'api-reference') {
      return []
    }
    return DOCS_LOCALES.map((locale) => ({ locale, slug }))
  })
}
export function getDocsLlmStaticParams() {
  return source
    .getPages()
    .map((page) => page.slugs)
    .map((slug) => ({
      slug,
    }))
}

export function getDocsStaticParams() {
  return getAllDocsParams()
}
