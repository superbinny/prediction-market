import type { QueryResult } from '@/types'

export async function runQuery<T>(queryFn: () => Promise<QueryResult<T>>): Promise<QueryResult<T>> {
  try {
    return await queryFn()
  } catch {
    // Return null data without error string to avoid duplicate error logging.
    // Callers that need a typed result can fall back to default values.
    return { data: null, error: 'Query failed' } as QueryResult<T>
  }
}
