import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requireApiRole } from '@/lib/api/session';
import { mutateAccess } from '@/lib/access/repository';
import { validateAccessMutation } from '@/lib/access/workflow';
import { readJsonBody } from '@/lib/http/json';
import { resolveTrustedOrigin } from '@/lib/http/origin';

export async function POST(request: Request) {
  try {
    const session = await requireApiRole('consultant');
    const mutation = validateAccessMutation(await readJsonBody(request));
    return NextResponse.json(await mutateAccess(session, mutation, resolveTrustedOrigin(new URL(request.url).origin)));
  } catch (error) {
    return apiErrorResponse('api.access', error, 'Access action failed.');
  }
}
