import { NextResponse } from 'next/server';
import { jsonRoute } from '@/lib/http/json-route';
import { requirePortalRole } from '@/lib/portal/context';
import { setEngagementContextCookies } from '@/lib/portal/cookies';
import { startClientEngagement } from '@/lib/onboarding/repository';
import { validateStartEngagement } from '@/lib/onboarding/workflow';

export async function POST(request: Request) {
  return jsonRoute('Client setup failed.', async () => {
    const session = await requirePortalRole('consultant');
    const result = await startClientEngagement(session, validateStartEngagement(await request.json()));
    return setEngagementContextCookies(NextResponse.json(result, { status: 201 }), result);
  });
}
