import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requireApiSession } from '@/lib/api/session';
import { mutateAlignmentCapability } from '@/lib/alignment/repository';
import { validateAlignmentMutation } from '@/lib/alignment/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try {
    const session = await requireApiSession();
    const mutation = validateAlignmentMutation(await readJsonBody(request));
    return NextResponse.json(await mutateAlignmentCapability(session, mutation));
  } catch (error) {
    return apiErrorResponse('api.alignment', error, 'The change could not be saved.');
  }
}
