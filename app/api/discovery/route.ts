import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requireApiRole } from '@/lib/api/session';
import { mutateDiscoveryIntake } from '@/lib/discovery/repository';
import { validateDiscoveryMutation } from '@/lib/discovery/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try {
    const session = await requireApiRole('consultant');
    return NextResponse.json(await mutateDiscoveryIntake(session, validateDiscoveryMutation(await readJsonBody(request))));
  } catch (error) {
    return apiErrorResponse('api.discovery', error, 'Discovery intake could not be saved.');
  }
}
