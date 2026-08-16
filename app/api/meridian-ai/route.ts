import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { mutateMeridianAi } from '@/lib/meridian-ai/repository';
import { validateMeridianMutation } from '@/lib/meridian-ai/workflow';
import { requireApiRole } from '@/lib/api/session';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try {
    const session = await requireApiRole('consultant', 'An assigned consultant session is required.');
    return NextResponse.json(await mutateMeridianAi(session, validateMeridianMutation(await readJsonBody(request))));
  } catch (error) {
    return apiErrorResponse('api.meridianAi', error, 'Meridian could not complete the grounded request.');
  }
}
