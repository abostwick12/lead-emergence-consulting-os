import { NextResponse } from 'next/server';
import { resolveTrustedOrigin } from '@/lib/http/origin';
import { getPortalSession } from '@/lib/portal/context';
import { isFixtureMode } from '@/lib/supabase/config';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export async function POST(request: Request) {
  const requestOrigin = new URL(request.url).origin;
  const expectedOrigin = resolveTrustedOrigin(requestOrigin);
  const suppliedOrigin = request.headers.get('origin');
  if (suppliedOrigin && suppliedOrigin !== expectedOrigin) return NextResponse.json({ error: 'Invalid request origin.' }, { status: 403 });
  const formData = await request.formData();
  const authorizationId = formData.get('authorization_id');
  const decision = formData.get('decision');
  if (typeof authorizationId !== 'string' || !authorizationId) return NextResponse.json({ error: 'The connection request is missing.' }, { status: 400 });
  if (decision !== 'approve' && decision !== 'deny') return NextResponse.json({ error: 'The connection decision is invalid.' }, { status: 400 });
  const session = await getPortalSession();
  if (!session || (session.role !== 'consultant' && session.role !== 'client')) return NextResponse.json({ error: 'Consulting OS authorization is required.' }, { status: 403 });
  if (isFixtureMode()) {
    const callback = new URL('/oauth/callback', request.url);
    callback.searchParams.set('state', authorizationId);
    if (decision === 'approve') callback.searchParams.set('code', 'fixture-authorization-code');
    else callback.searchParams.set('error', 'access_denied');
    return NextResponse.redirect(callback, 303);
  }

  const supabase = await createSupabaseServerClient();
  const result = decision === 'approve'
    ? await supabase.auth.oauth.approveAuthorization(authorizationId)
    : await supabase.auth.oauth.denyAuthorization(authorizationId);
  if (result.error) return NextResponse.json({ error: 'The connection decision could not be completed. Please start again.' }, { status: 400 });
  const destination = safeOAuthRedirect(result.data.redirect_url);
  if (!destination) return NextResponse.json({ error: 'The registered callback address is invalid.' }, { status: 400 });
  return NextResponse.redirect(destination, 303);
}

function safeOAuthRedirect(value: string) {
  try {
    const url = new URL(value);
    if (url.protocol === 'https:' || (process.env.NODE_ENV !== 'production' && url.protocol === 'http:')) return url;
  } catch { return null; }
  return null;
}
