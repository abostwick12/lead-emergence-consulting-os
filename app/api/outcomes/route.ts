import { NextResponse } from 'next/server';
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
    return NextResponse.json({ error: error instanceof Error ? error.message : 'The outcome workflow could not be advanced.' }, { status: 400 });
  }
}
