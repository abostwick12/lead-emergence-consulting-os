import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { mutateMeridianAi } from '@/lib/meridian-ai/repository';
import { validateMeridianMutation } from '@/lib/meridian-ai/workflow';
import { getPortalSession } from '@/lib/portal/context';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try {
    const session = await getPortalSession();
    if (!session || session.role !== 'consultant') return NextResponse.json({ error: 'An assigned consultant session is required.' }, { status: 401 });
    return NextResponse.json(await mutateMeridianAi(session, validateMeridianMutation(await readJsonBody(request))));
  } catch (error) {
    return apiErrorResponse('api.meridianAi', error, 'Meridian could not complete the grounded request.');
  }
}
