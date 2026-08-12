import { NextResponse, type NextRequest } from 'next/server';
import { fixtureCookieName } from '@/lib/portal/context';
import { safeReturnPath } from '@/lib/portal/navigation';
import { isFixtureMode } from '@/lib/supabase/config';
import { resetAlignmentFixtures } from '@/lib/alignment/fixtures';
import { resetMeetingFixtures } from '@/lib/meetings/fixtures';
import { resetMeridianAiFixtures } from '@/lib/meridian-ai/fixtures';
import { resetOutcomeFixtures } from '@/lib/outcomes/fixtures';
import { resetSignalsFixtures } from '@/lib/signals/fixtures';
import { resetOnboardingFixtures } from '@/lib/onboarding/fixtures';
import { resetDiscoveryFixtures } from '@/lib/discovery/fixtures';

export function GET(request: NextRequest) {
  if (!isFixtureMode()) return new NextResponse('Not found', { status: 404 });
  if (request.nextUrl.searchParams.get('reset') === 'true') {
    resetAlignmentFixtures(); resetMeetingFixtures(); resetMeridianAiFixtures(); resetOutcomeFixtures(); resetSignalsFixtures(); resetOnboardingFixtures(); resetDiscoveryFixtures();
  }
  const role = request.nextUrl.searchParams.get('role');
  if (role !== 'consultant' && role !== 'client') return new NextResponse('Invalid synthetic role', { status: 400 });
  const returnTo = safeReturnPath(request.nextUrl.searchParams.get('returnTo'));
  const response = NextResponse.redirect(new URL(returnTo === '/' ? `/${role}` : returnTo, request.url));
  response.cookies.set(fixtureCookieName(), role, { httpOnly: true, sameSite: 'lax', path: '/', secure: false });
  return response;
}
