import 'server-only';
import type { PortalSession } from '@/lib/portal/types';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { startFixtureEngagement } from './fixtures';
import type { StartEngagementInput, StartEngagementResult } from './types';
import { dataAccessError } from '@/lib/http/errors';
import { authorizationError, unavailableError } from '@/lib/errors';
import { isOperationalWorkspaceProvisioned, operationalProvisioningGateNotice } from '@/lib/operational-ai/repository';

export async function startClientEngagement(session: PortalSession, input: StartEngagementInput): Promise<StartEngagementResult> {
  if (session.role !== 'consultant') throw authorizationError('Consultant access is required.');
  if (session.fixture) return startFixtureEngagement(input);
  if (input.engagementType === 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION' && !isOperationalWorkspaceProvisioned(session)) {
    throw unavailableError(`${operationalProvisioningGateNotice} Start an organizational transformation engagement instead.`);
  }
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.rpc('start_client_engagement', { p_organization_name: input.organizationName, p_engagement_name: input.engagementName, p_starts_on: input.startsOn, p_ends_on: input.endsOn ?? null });
  if (error) throw dataAccessError(error, 'lib/onboarding/repository.ts');
  const result = Array.isArray(data) ? data[0] : data;
  if (!result?.organization_id || !result?.engagement_id) throw new Error('The client engagement could not be created.');
  if (input.engagementType === 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION') {
    const { error: configureError } = await supabase.from('engagements').update({
      engagement_type: input.engagementType,
      objective: input.objective,
      scope_statement: input.scopeStatement,
      handling_label: 'Internal — Sanitized Only',
      handling_notice: 'Enter only information authorized for this environment. Do not enter classified, CUI, SECRET, NOFORN, mission, target, coordinate, frequency, callsign, intelligence, or operational timeline data.',
      current_phase: 'SEE REALITY',
    }).eq('id', result.engagement_id).eq('organization_id', result.organization_id);
    if (configureError) throw dataAccessError(configureError, 'lib/onboarding/repository.ts');
  }
  return { organizationId: result.organization_id, engagementId: result.engagement_id };
}
