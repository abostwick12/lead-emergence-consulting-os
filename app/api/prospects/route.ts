import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requireApiRole } from '@/lib/api/session';
import { readJsonBody } from '@/lib/http/json';
import { getProspectCenter, mutateProspect } from '@/lib/prospects/repository';
import { validateProspectMutation } from '@/lib/prospects/workflow';

export async function GET() {
  try { await requireApiRole('consultant'); return NextResponse.json(await getProspectCenter()); }
  catch (error) { return apiErrorResponse('api.prospects.list', error, 'Prospects are not available.'); }
}

export async function POST(request: Request) {
  try {
    const session = await requireApiRole('consultant');
    return NextResponse.json(await mutateProspect(session.personId, validateProspectMutation(await readJsonBody(request))));
  } catch (error) { return apiErrorResponse('api.prospects.mutate', error, 'Prospect action failed.'); }
}