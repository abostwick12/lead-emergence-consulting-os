export function isFixtureMode() {
  return process.env.E2E_MOCK_AUTH === 'true' && process.env.NODE_ENV !== 'production';
}
export function getSupabasePublicConfig() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url || !key) return null;
  return { url, key };
}

export function requireSupabasePublicConfig() {
  const config = getSupabasePublicConfig();
  if (!config) {
    throw new Error(
      'Supabase is not configured. Set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY.',
    );
  }
  return config;
}

export function requireSupabaseSecretKey() {
  const key = process.env.SUPABASE_SECRET_KEY;
  if (!key) throw new Error('Supabase trusted server access is not configured.');
  return key;
}
