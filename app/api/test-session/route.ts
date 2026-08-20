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
import { resetAccessFixtures } from '@/lib/access/fixtures';
import { resetHandoffFixtures } from '@/lib/handoff/fixtures';
import { resetOperationalFixtures } from '@/lib/operational-ai/fixtures';
import { resetProspectFixtures } from '@/lib/prospects/fixtures';

export function GET(request: NextRequest) {
  if (!isFixtureMode()) return new NextResponse('Not found', { status: 404 });
  if (request.nextUrl.searchParams.get('reset') === 'true') {
    resetAlignmentFixtures(); resetMeetingFixtures(); resetMeridianAiFixtures(); resetOutcomeFixtures(); resetSignalsFixtures(); resetOnboardingFixtures(); resetDiscoveryFixtures(); resetAccessFixtures(); resetHandoffFixtures(); resetOperationalFixtures(); resetProspectFixtures();
  }
  const role = request.nextUrl.searchParams.get('role');
  if (role !== 'consultant' && role !== 'client' && role !== 'outsider') return new NextResponse('Invalid synthetic role', { status: 400 });
  const returnTo = safeReturnPath(request.nextUrl.searchParams.get('returnTo'));
  const response = NextResponse.redirect(new URL(returnTo === '/' ? role === 'outsider' ? '/' : `/${role}` : returnTo, request.url));
  response.cookies.set(fixtureCookieName(), role, { httpOnly: true, sameSite: 'lax', path: '/', secure: false });
  return response;
}
