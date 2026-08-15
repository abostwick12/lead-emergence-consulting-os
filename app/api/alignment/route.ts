import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { getPortalSession } from '@/lib/portal/context';
import { mutateAlignmentCapability } from '@/lib/alignment/repository';
import { validateAlignmentMutation } from '@/lib/alignment/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try {
    const session = await getPortalSession();
    if (!session || session.role === 'outsider') return NextResponse.json({ error: 'Authentication is required.' }, { status: 401 });
    const mutation = validateAlignmentMutation(await readJsonBody(request));
    return NextResponse.json(await mutateAlignmentCapability(session, mutation));
  } catch (error) {
    return apiErrorResponse('api.alignment', error, 'The change could not be saved.');
  }
}
