import 'server-only';

import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { requireSupabasePublicConfig } from './config';

export async function createSupabaseServerClient() {
  const cookieStore = await cookies();
  const { url, key } = requireSupabasePublicConfig();
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
