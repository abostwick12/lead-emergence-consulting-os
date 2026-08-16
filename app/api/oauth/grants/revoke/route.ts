import { NextResponse } from 'next/server';
import { getPortalSession } from '@/lib/portal/context';
import { resolveTrustedOrigin } from '@/lib/http/origin';
import { isFixtureMode } from '@/lib/supabase/config';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export async function POST(request: Request) {
  const requestOrigin = new URL(request.url).origin;
  const expectedOrigin = resolveTrustedOrigin(requestOrigin);
  const suppliedOrigin = request.headers.get('origin');
  if (suppliedOrigin && suppliedOrigin !== expectedOrigin) return NextResponse.json({ error: 'Invalid request origin.' }, { status: 403 });
  const session = await getPortalSession();
  if (!session || session.role !== 'consultant') return NextResponse.json({ error: 'Consultant authorization is required.' }, { status: 403 });
  if (isFixtureMode()) return NextResponse.redirect(new URL('/consultant/settings?connection=disconnected', request.url), 303);
  const formData = await request.formData();
  const clientId = formData.get('client_id');
  if (typeof clientId !== 'string' || !/^[0-9a-f-]{36}$/i.test(clientId)) return NextResponse.json({ error: 'The connection identifier is invalid.' }, { status: 400 });
  const { error } = await (await createSupabaseServerClient()).auth.oauth.revokeGrant({ clientId });
  if (error) return NextResponse.json({ error: 'The AI connection could not be disconnected.' }, { status: 400 });
  return NextResponse.redirect(new URL('/consultant/settings?connection=disconnected', request.url), 303);
}
