import { NextResponse } from 'next/server';
import { requirePortalRole } from '@/lib/portal/context';
import { startClientEngagement } from '@/lib/onboarding/repository';
import { validateStartEngagement } from '@/lib/onboarding/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try {
    const session = await requirePortalRole('consultant');
    const result = await startClientEngagement(session, validateStartEngagement(await readJsonBody(request)));
    const response = NextResponse.json(result, { status: 201 });
    const options = { httpOnly: true, sameSite: 'lax' as const, path: '/', secure: process.env.NODE_ENV === 'production' };
    response.cookies.set('le_organization_id', result.organizationId, options);
    response.cookies.set('le_engagement_id', result.engagementId, options);
    return response;
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : 'Client setup failed.' }, { status: 400 });
  }
}
