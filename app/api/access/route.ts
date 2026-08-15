import { NextResponse } from 'next/server'; import { requirePortalRole } from '@/lib/portal/context'; import { mutateAccess } from '@/lib/access/repository'; import { validateAccessMutation } from '@/lib/access/workflow';
import { readJsonBody } from '@/lib/http/json';
import { resolveTrustedOrigin } from '@/lib/http/origin';
export async function POST(request: Request) { try { const session = await requirePortalRole('consultant'); return NextResponse.json(await mutateAccess(session, validateAccessMutation(await readJsonBody(request)), resolveTrustedOrigin(new URL(request.url).origin))); } catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : 'Access action failed.' }, { status: 400 }); } }
