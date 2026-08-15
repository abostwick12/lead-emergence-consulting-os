import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { getPortalSession } from '@/lib/portal/context';
import { mutateSignalsWorkspace } from '@/lib/signals/repository';
import { validateSignalsMutation } from '@/lib/signals/workflow';

export async function POST(request: Request) {
  try {
    const session = await getPortalSession();
    if (!session || session.role !== 'consultant') return NextResponse.json({ error: 'Assigned consultant authorization is required.' }, { status: 401 });
    return NextResponse.json(await mutateSignalsWorkspace(session, validateSignalsMutation(await request.json())));
  } catch (error) {
    return apiErrorResponse('api.signals', error, 'The Signals action could not be completed.');
  }
}
