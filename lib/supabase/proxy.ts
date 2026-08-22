import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';
import { logError } from '@/lib/errors';
import { getSupabasePublicConfig, isFixtureMode } from './config';

export async function refreshSupabaseSession(request: NextRequest) {
  if (isFixtureMode()) return NextResponse.next({ request });
  const config = getSupabasePublicConfig();
  if (!config) return NextResponse.next({ request });

  let response = NextResponse.next({ request });
  const supabase = createServerClient(config.url, config.key, {
    db: { schema: 'consulting_os' },
    cookieOptions: { secure: process.env.NODE_ENV === 'production' },
    cookies: {
      getAll: () => request.cookies.getAll(),
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) => response.cookies.set(name, value, options));
      },
    },
  });
  const { error } = await supabase.auth.getClaims();
  if (error) logError('supabase.proxy.refresh', error);
  return response;
}
