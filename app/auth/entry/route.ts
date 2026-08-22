import type { Provider } from '@supabase/supabase-js';
import { cookies } from 'next/headers';
import { NextResponse, type NextRequest } from 'next/server';
import {
  entrySsoCallbackPath,
  entrySsoModeCookieName,
  entrySsoModeCookieOptions,
  requireEntryProviderIdentifier,
} from '@/lib/auth/entry-identity';
import { resolveTrustedOrigin } from '@/lib/http/origin';
import { loginErrors } from '@/lib/portal/login-messages';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  const mode = 'sign_in' as const;
  const modeCookie = entrySsoModeCookieName(mode);
  try {
    const origin = resolveTrustedOrigin(request.nextUrl.origin);
    const callback = new URL(entrySsoCallbackPath(mode), origin);
    const supabase = await createSupabaseServerClient();
    const { data, error } = await supabase.auth.signInWithOAuth({
      // Runtime support for custom providers precedes this SDK version's Provider union.
      provider: requireEntryProviderIdentifier() as Provider,
      options: { redirectTo: callback.toString(), skipBrowserRedirect: true },
    });
    if (error || !data.url) throw error ?? new Error('Entry authorization URL unavailable');
    (await cookies()).set(modeCookie, mode, entrySsoModeCookieOptions(mode));
    return NextResponse.redirect(data.url, 303);
  } catch {
    (await cookies()).set(modeCookie, '', { ...entrySsoModeCookieOptions(mode), maxAge: 0 });
    return NextResponse.redirect(new URL(`/login?error=${encodeURIComponent(loginErrors.entryUnavailable)}`, request.url), 303);
  }
}
