import 'server-only';
import type { PortalSession } from '@/lib/portal/types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { startFixtureEngagement } from './fixtures';
import type { StartEngagementInput, StartEngagementResult } from './types';

export async function startClientEngagement(session: PortalSession, input: StartEngagementInput): Promise<StartEngagementResult> {
  if (session.role !== 'consultant') throw new Error('Consultant access is required.');
  if (session.fixture) return startFixtureEngagement(input);
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.rpc('start_client_engagement', { p_organization_name: input.organizationName, p_engagement_name: input.engagementName, p_starts_on: input.startsOn, p_ends_on: input.endsOn ?? null });
  if (error) throw new Error(error.message);
  const result = Array.isArray(data) ? data[0] : data;
  if (!result?.organization_id || !result?.engagement_id) throw new Error('The client engagement could not be created.');
  return { organizationId: result.organization_id, engagementId: result.engagement_id };
}
