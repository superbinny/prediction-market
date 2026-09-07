import { vi } from 'vitest'

vi.mock('next/root-params', () => ({
  locale: vi.fn(async () => 'en'),
}))

if (!process.env.REOWN_APPKIT_PROJECT_ID) {
  process.env.REOWN_APPKIT_PROJECT_ID = 'test-appkit'
}

if (!process.env.POSTGRES_URL) {
  process.env.POSTGRES_URL = 'postgresql://test@test.example:5432/test'
}

if (!process.env.SUPABASE_URL) {
  process.env.SUPABASE_URL = 'https://supabase.test'
}

if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
  process.env.SUPABASE_SERVICE_ROLE_KEY = 'test-service-role-key'
}
