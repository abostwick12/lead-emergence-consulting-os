import { cookies } from 'next/headers';
import { NextResponse, type NextRequest } from 'next/server';
import {
  entrySsoModeCookieName,
  entrySsoModeCookieOptions,
  entrySsoConsentReturnCookieName,
  entrySsoConsentReturnCookieOptions,
  oauthConsentReturnPath,
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
  const consentReturn = mode === 'sign_in'
    ? oauthConsentReturnPath(cookieStore.get(entrySsoConsentReturnCookieName())?.value)
    : null;
  cookieStore.set(modeCookie, '', { ...entrySsoModeCookieOptions(mode), maxAge: 0 });
  if (mode === 'sign_in') cookieStore.set(entrySsoConsentReturnCookieName(), '', { ...entrySsoConsentReturnCookieOptions(), maxAge: 0 });

  if (!isEntrySsoMode(modeValue) || modeValue !== mode) {
    await supabase.auth.signOut({ scope: 'local' });
    return loginRedirect(request, loginErrors.entryUnavailable);
  }
  if (request.nextUrl.searchParams.get('error')) return loginRedirect(request, loginErrors.entryDenied, consentReturn);
  const code = request.nextUrl.searchParams.get('code');
  if (!code) return loginRedirect(request, loginErrors.entryUnavailable, consentReturn);

  const { error: exchangeError } = await supabase.auth.exchangeCodeForSession(code);
  if (exchangeError) return loginRedirect(request, loginErrors.entryUnavailable, consentReturn);
  const { data, error: userError } = await supabase.auth.getUser();
  if (userError || !data.user) {
    if (mode === 'sign_in') await supabase.auth.signOut({ scope: 'local' });
    return loginRedirect(request, loginErrors.entryUnavailable, consentReturn);
  }

  try {
    await persistEntryIdentity(data.user, mode);
  } catch {
    if (mode === 'sign_in') await supabase.auth.signOut({ scope: 'local' });
    return loginRedirect(request, loginErrors.entryLinkConflict, consentReturn);
  }
  return NextResponse.redirect(new URL(consentReturn ?? '/consulting-context?entry=connected', request.url), 303);
}

function loginRedirect(request: NextRequest, error: string, consentReturn?: string | null) {
  const destination = new URL('/login', request.url);
  destination.searchParams.set('error', error);
  if (consentReturn) destination.searchParams.set('returnTo', consentReturn);
  return NextResponse.redirect(destination, 303);
}
