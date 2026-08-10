import { NextResponse, type NextRequest } from 'next/server';
import { fixtureCookieName } from '@/lib/portal/context';
import { isFixtureMode } from '@/lib/supabase/config';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export async function POST(request: NextRequest) {
  if (isFixtureMode()) {
    const response = NextResponse.redirect(new URL('/login', request.url), 303);
    response.cookies.delete(fixtureCookieName());
    return response;
  }
  const supabase = await createSupabaseServerClient();
  await supabase.auth.signOut();
  return NextResponse.redirect(new URL('/login', request.url), 303);
}
