import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requireApiRole } from '@/lib/api/session';
import { mutateSignalsWorkspace } from '@/lib/signals/repository';
import { validateSignalsMutation } from '@/lib/signals/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try {
    const session = await requireApiRole('consultant', 'Assigned consultant authorization is required.');
    return NextResponse.json(await mutateSignalsWorkspace(session, validateSignalsMutation(await readJsonBody(request))));
  } catch (error) {
    return apiErrorResponse('api.signals', error, 'The Signals action could not be completed.');
  }
}
