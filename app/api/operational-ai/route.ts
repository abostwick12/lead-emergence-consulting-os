import { NextResponse } from 'next/server';
import { requirePortalRole } from '@/lib/portal/context';
import { mutateOperationalEngagement } from '@/lib/operational-ai/repository';
import { validateOperationalMutation } from '@/lib/operational-ai/workflow';
import { readJsonBody } from '@/lib/http/json';

export async function POST(request: Request) {
  try { const session = await requirePortalRole('consultant'); return NextResponse.json(await mutateOperationalEngagement(session, validateOperationalMutation(await readJsonBody(request)))); }
  catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : 'The workspace could not be updated.' }, { status: 400 }); }
}
