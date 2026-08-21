import { cookies } from 'next/headers';
import { NextResponse, type NextRequest } from 'next/server';
import {
  entrySsoModeCookieName,
  entrySsoModeCookieOptions,
  entrySsoModeFromCallback,
  isEntrySsoMode,
} from '@/lib/auth/entry-identity';
import { persistEntryIdentity } from '@/lib/auth/entry-sso';
import { loginErrors } from '@/lib/portal/login-messages';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest, { params }: { params: Promise<{ mode: string }> }) {
  const mode = entrySsoModeFromCallback((await params).mode);
  const supabase = await createSupabaseServerClient();
  if (!mode) {
    await supabase.auth.signOut({ scope: 'local' });
    return loginRedirect(request, loginErrors.entryUnavailable);
  }

  const cookieStore = await cookies();
  const modeCookie = entrySsoModeCookieName(mode);
  const modeValue = cookieStore.get(modeCookie)?.value;
  cookieStore.set(modeCookie, '', { ...entrySsoModeCookieOptions(mode), maxAge: 0 });

  if (!isEntrySsoMode(modeValue) || modeValue !== mode) {
    await supabase.auth.signOut({ scope: 'local' });
    return loginRedirect(request, loginErrors.entryUnavailable);
  }
  if (request.nextUrl.searchParams.get('error')) return loginRedirect(request, loginErrors.entryDenied);
  const code = request.nextUrl.searchParams.get('code');
  if (!code) return loginRedirect(request, loginErrors.entryUnavailable);

  const { error: exchangeError } = await supabase.auth.exchangeCodeForSession(code);
  if (exchangeError) return loginRedirect(request, loginErrors.entryUnavailable);
  const { data, error: userError } = await supabase.auth.getUser();
  if (userError || !data.user) return loginRedirect(request, loginErrors.entryUnavailable);

  try {
    await persistEntryIdentity(data.user, mode);
  } catch {
    if (mode === 'sign_in') await supabase.auth.signOut({ scope: 'local' });
    return loginRedirect(request, loginErrors.entryLinkConflict);
  }
  return NextResponse.redirect(new URL('/consulting-context?entry=connected', request.url), 303);
}

function loginRedirect(request: NextRequest, error: string) {
  return NextResponse.redirect(new URL(`/login?error=${encodeURIComponent(error)}`, request.url), 303);
}
