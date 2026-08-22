import { NextResponse } from 'next/server';
import { z } from 'zod';
import { createSupabaseAdminClient } from '@/lib/supabase/admin';
import { verifyEntryHandoff } from '@/lib/handoff/entry';

const requestSchema = z.object({ handoff: z.string().min(1).max(4096) }).strict();

export async function GET() {
  return NextResponse.json({ error: 'POST required' }, { status: 405, headers: { Allow: 'POST' } });
}

export async function POST(request: Request) {
  try {
    const contentType = request.headers.get('content-type') ?? '';
    const payload = contentType.includes('application/json')
      ? await request.json()
      : Object.fromEntries((await request.formData()).entries());
    const { handoff } = requestSchema.parse(payload);
    const verified = await verifyEntryHandoff(handoff);
    const redemptionUrl = process.env.ENTRY_HANDOFF_REDEEM_URL;
    const redemptionSecret = process.env.ENTRY_HANDOFF_REDEEM_SECRET;
    if (!redemptionUrl || !redemptionSecret) throw new Error('Entry redemption contract is not configured');

    const redemption = await fetch(redemptionUrl, {
      method: 'POST',
      headers: { authorization: `Bearer ${redemptionSecret}`, 'content-type': 'application/json' },
      body: JSON.stringify({ jti: verified.jti, canonical_user_id: verified.sub, product: verified.aud }),
      cache: 'no-store',
    });
    if (!redemption.ok) return NextResponse.json({ error: 'Handoff denied' }, { status: 401 });

    const supabase = createSupabaseAdminClient();
    const { data: link, error } = await supabase
      .from('canonical_identity_links')
      .select('person_id, canonical_user_id, status')
      .eq('canonical_user_id', verified.sub)
      .eq('status', 'LINKED')
      .maybeSingle();
    if (error) throw error;
    if (!link) return NextResponse.json({ status: 'NO_WORKSPACE', canonical_user_id: verified.sub });

    // Local Consulting role, membership, engagement, and RLS resolution remains
    // separate. A canonical link alone never grants Consulting authorization.
    const { data: memberships, error: membershipError } = await supabase
      .from('organization_memberships')
      .select('id, organization_id, platform_role')
      .eq('person_id', link.person_id)
      .eq('status', 'ACTIVE');
    if (membershipError) throw membershipError;
    if (!memberships?.length) return NextResponse.json({ status: 'NO_WORKSPACE', canonical_user_id: link.canonical_user_id, consulting_person_id: link.person_id, local_authorization: 'NONE' });
    return NextResponse.json({
      status: 'AUTHORIZED_CONTEXT_AVAILABLE',
      canonical_user_id: link.canonical_user_id,
      consulting_person_id: link.person_id,
      local_authorization: 'ACTIVE_MEMBERSHIP_PRESENT',
    });
  } catch {
    return NextResponse.json({ error: 'Handoff denied' }, { status: 401 });
  }
}
