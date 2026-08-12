import 'server-only';

import { createClient } from '@supabase/supabase-js';
import { requireSupabasePublicConfig, requireSupabaseSecretKey } from './config';

export function createSupabaseAdminClient(schema: 'consulting_os' | 'consulting_private' = 'consulting_os') {
  const { url } = requireSupabasePublicConfig();
  return createClient(url, requireSupabaseSecretKey(), {
    db: { schema },
    auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
  });
}
