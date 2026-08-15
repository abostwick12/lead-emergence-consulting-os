import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requirePortalRole } from '@/lib/portal/context';
import { mutateOperationalEngagement } from '@/lib/operational-ai/repository';
import { validateOperationalMutation } from '@/lib/operational-ai/workflow';

export async function POST(request: Request) {
  try { const session = await requirePortalRole('consultant'); return NextResponse.json(await mutateOperationalEngagement(session, validateOperationalMutation(await request.json()))); }
  catch (error) { return apiErrorResponse('api.operationalAi', error, 'The workspace could not be updated.'); }
}
