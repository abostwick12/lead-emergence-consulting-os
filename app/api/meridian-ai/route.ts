import { NextResponse } from 'next/server';
import { mutateMeridianAi } from '@/lib/meridian-ai/repository';
import { validateMeridianMutation } from '@/lib/meridian-ai/workflow';
import { getPortalSession } from '@/lib/portal/context';

export async function POST(request: Request) {
  try {
    const session = await getPortalSession();
    if (!session || session.role !== 'consultant') return NextResponse.json({ error: 'An assigned consultant session is required.' }, { status: 401 });
    return NextResponse.json(await mutateMeridianAi(session, validateMeridianMutation(await request.json())));
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : 'Meridian could not complete the grounded request.' }, { status: 400 });
  }
}
