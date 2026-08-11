import { NextResponse } from 'next/server';
import { getPortalSession } from '@/lib/portal/context';
import { mutateAlignmentCapability } from '@/lib/alignment/repository';
import { validateAlignmentMutation } from '@/lib/alignment/workflow';

export async function POST(request: Request) {
  try {
    const session = await getPortalSession();
    if (!session || session.role === 'outsider') return NextResponse.json({ error: 'Authentication is required.' }, { status: 401 });
    const mutation = validateAlignmentMutation(await request.json());
    return NextResponse.json(await mutateAlignmentCapability(session, mutation));
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : 'The change could not be saved.' }, { status: 400 });
  }
}
