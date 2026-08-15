import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requireApiRole } from '@/lib/api/session';
import { mutateOperationalEngagement } from '@/lib/operational-ai/repository';
import { validateOperationalMutation } from '@/lib/operational-ai/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try {
    const session = await requireApiRole('consultant');
    return NextResponse.json(await mutateOperationalEngagement(session, validateOperationalMutation(await readJsonBody(request))));
  } catch (error) {
    return apiErrorResponse('api.operationalAi', error, 'The workspace could not be updated.');
  }
}
