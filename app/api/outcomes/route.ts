import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { getPortalSession } from '@/lib/portal/context';
import { mutateOutcomesNewReality } from '@/lib/outcomes/repository';
import { validateOutcomesMutation } from '@/lib/outcomes/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try {
    const session = await getPortalSession();
    if (!session || session.role !== 'consultant') return NextResponse.json({ error: 'Assigned consultant authorization is required.' }, { status: 401 });
    return NextResponse.json(await mutateOutcomesNewReality(session, validateOutcomesMutation(await readJsonBody(request))));
  } catch (error) {
    return apiErrorResponse('api.outcomes', error, 'The outcome workflow could not be advanced.');
  }
}
