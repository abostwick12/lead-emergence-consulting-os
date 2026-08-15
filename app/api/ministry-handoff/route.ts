import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requirePortalRole } from '@/lib/portal/context';
import { saveMinistryHandoff } from '@/lib/handoff/repository';
import { validateMinistryHandoff } from '@/lib/handoff/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try {
    const session = await requirePortalRole('consultant');
    return NextResponse.json(await saveMinistryHandoff(session, validateMinistryHandoff(await readJsonBody(request))));
  } catch (error) {
    return apiErrorResponse('api.ministryHandoff', error, 'Ministry handoff could not be saved.');
  }
}

