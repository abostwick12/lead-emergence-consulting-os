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
import { getPortalSession } from '@/lib/portal/context';
import { loginErrors } from '@/lib/portal/login-messages';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  const session = await getPortalSession();
  if (!session || (session.role !== 'consultant' && session.role !== 'client')) {
    return NextResponse.redirect(new URL('/login?returnTo=%2Fconsulting-context', request.url), 303);
  }

  const mode = 'link_existing' as const;
  const modeCookie = entrySsoModeCookieName(mode);
  try {
    const origin = resolveTrustedOrigin(request.nextUrl.origin);
    const callback = new URL(entrySsoCallbackPath(mode), origin);
    const supabase = await createSupabaseServerClient();
    const { data, error } = await supabase.auth.linkIdentity({
      provider: requireEntryProviderIdentifier() as Provider,
      options: { redirectTo: callback.toString(), skipBrowserRedirect: true },
    });
    if (error || !data.url) throw error ?? new Error('Entry linking URL unavailable');
    (await cookies()).set(modeCookie, mode, entrySsoModeCookieOptions(mode));
    return NextResponse.redirect(data.url, 303);
  } catch {
    (await cookies()).set(modeCookie, '', { ...entrySsoModeCookieOptions(mode), maxAge: 0 });
    return NextResponse.redirect(new URL(`/login?error=${encodeURIComponent(loginErrors.entryUnavailable)}`, request.url), 303);
  }
}
