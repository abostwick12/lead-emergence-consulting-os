import { NextResponse } from 'next/server';
import { getPortalSession } from '@/lib/portal/context';
import { mutateSignalsWorkspace } from '@/lib/signals/repository';
import { validateSignalsMutation } from '@/lib/signals/workflow';

export async function POST(request: Request) {
  try {
    const session = await getPortalSession();
    if (!session || session.role !== 'consultant') return NextResponse.json({ error: 'Assigned consultant authorization is required.' }, { status: 401 });
    return NextResponse.json(await mutateSignalsWorkspace(session, validateSignalsMutation(await request.json())));
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : 'The Signals action could not be completed.' }, { status: 400 });
  }
}
