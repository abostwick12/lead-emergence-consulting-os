import { NextResponse } from 'next/server';
import { apiErrorResponse } from '@/lib/api/responses';
import { requirePortalRole } from '@/lib/portal/context';
import { mutateDiscoveryIntake } from '@/lib/discovery/repository';
import { validateDiscoveryMutation } from '@/lib/discovery/workflow';

export async function POST(request: Request) {
  try { const session = await requirePortalRole('consultant'); return NextResponse.json(await mutateDiscoveryIntake(session, validateDiscoveryMutation(await request.json()))); }
  catch (error) { return apiErrorResponse('api.discovery', error, 'Discovery intake could not be saved.'); }
}
