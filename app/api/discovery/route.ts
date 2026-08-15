import { NextResponse } from 'next/server';
import { requirePortalRole } from '@/lib/portal/context';
import { mutateDiscoveryIntake } from '@/lib/discovery/repository';
import { validateDiscoveryMutation } from '@/lib/discovery/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try { const session = await requirePortalRole('consultant'); return NextResponse.json(await mutateDiscoveryIntake(session, validateDiscoveryMutation(await readJsonBody(request)))); }
  catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : 'Discovery intake could not be saved.' }, { status: 400 }); }
}
