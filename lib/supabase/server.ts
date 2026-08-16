import 'server-only';

import { createClient } from '@supabase/supabase-js';
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { requireSupabasePublicConfig } from './config';
import { currentSupabaseAccessToken } from './token-context';

export async function createSupabaseServerClient() {
  const { url, key } = requireSupabasePublicConfig();
  const accessToken = currentSupabaseAccessToken();
  if (accessToken) {
    return createClient(url, key, {
      db: { schema: 'consulting_os' },
      auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
      global: { headers: { Authorization: `Bearer ${accessToken}` } },
    });
  }

  const cookieStore = await cookies();
  return createServerClient(url, key, {
    db: { schema: 'consulting_os' },
    cookies: {
      getAll() {
        return cookieStore.getAll();
      },
      setAll(cookiesToSet) {
        try {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options),
          );
        } catch {
          // Server Components cannot always write cookies; proxy.ts performs refresh.
        }
      },
    },
  });
}
