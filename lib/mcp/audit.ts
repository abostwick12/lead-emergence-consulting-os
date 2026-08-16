import 'server-only';

import { createSupabaseAdminClient } from '@/lib/supabase/admin';
import type { PortalSession } from '@/lib/portal/types';
import { isFixtureMode } from '@/lib/supabase/config';
import { logError } from '@/lib/errors';

export async function auditMcpToolCall(input: {
  session: PortalSession;
  oauthClientId: string;
  toolName: string;
  succeeded: boolean;
  errorKind?: string;
}) {
  if (isFixtureMode() || input.session.fixture) return;
  const { error } = await createSupabaseAdminClient().from('mcp_tool_audit').insert({
    organization_id: input.session.organization.id,
    engagement_id: input.session.engagement.id,
    person_id: input.session.personId,
    oauth_client_id: input.oauthClientId,
    tool_name: input.toolName,
    succeeded: input.succeeded,
    error_kind: input.errorKind ?? null,
  });
  if (error) logError('mcp.audit', error);
}
