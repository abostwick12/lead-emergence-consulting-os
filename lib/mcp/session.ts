import 'server-only';

import { authorizationError, dataAccessError } from '@/lib/errors';
import { fixtureSession } from '@/lib/portal/fixtures';
import type { EngagementOption, OrganizationOption, PortalSession } from '@/lib/portal/types';
import { isFixtureMode } from '@/lib/supabase/config';
import { assertSucceeded, unwrap } from '@/lib/supabase/errors';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export interface McpEngagementSelection {
  organizationId?: string;
  engagementId?: string;
}

export async function listMcpEngagements(): Promise<{ organizations: OrganizationOption[]; engagements: EngagementOption[] }> {
  if (isFixtureMode()) {
    const session = fixtureSession('consultant');
    if (!session) throw authorizationError('The local consultant fixture is unavailable.');
    return { organizations: session.organizations, engagements: session.engagements };
  }
  const context = await loadConsultantContext();
  return { organizations: context.organizations, engagements: context.engagements };
}

export async function resolveMcpSession(selection: McpEngagementSelection): Promise<PortalSession> {
  if (isFixtureMode()) {
    const session = fixtureSession('consultant', selection.organizationId, selection.engagementId);
    if (!session || session.role !== 'consultant') throw authorizationError('Consultant authorization is required.');
    return session;
  }

  const context = await loadConsultantContext();
  const engagement = selection.engagementId
    ? context.engagements.find((item) => item.id === selection.engagementId)
    : selection.organizationId
      ? context.engagements.find((item) => item.organizationId === selection.organizationId)
      : context.engagements[0];
  if (!engagement) throw authorizationError('The requested engagement is not assigned to this consultant.');
  const organization = context.organizations.find((item) => item.id === engagement.organizationId);
  if (!organization) throw authorizationError('The requested organization is not assigned to this consultant.');
  if (selection.organizationId && selection.organizationId !== organization.id) {
    throw authorizationError('The organization and engagement selection do not match.');
  }

  return {
    personId: context.personId,
    displayName: context.displayName,
    role: 'consultant',
    organizations: context.organizations,
    organization,
    engagements: context.engagements.filter((item) => item.organizationId === organization.id),
    engagement,
    fixture: false,
  };
}

async function loadConsultantContext() {
  const supabase = await createSupabaseServerClient();
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) throw authorizationError('The OAuth user session is no longer valid.');

  const person = unwrap('mcp.session.person', await supabase.from('people').select('id, display_name').eq('auth_user_id', userData.user.id).maybeSingle());
  if (!person) throw authorizationError('A Consulting OS person record is required.');
  const assignmentsResult = await supabase.from('consultant_assignments').select('organization_id').eq('consultant_person_id', person.id).eq('status', 'ACTIVE');
  assertSucceeded('mcp.session.assignments', assignmentsResult);
  const organizationIds = [...new Set((assignmentsResult.data ?? []).map((item) => item.organization_id))];
  if (!organizationIds.length) throw authorizationError('An active consultant assignment is required.');

  const organizations = (unwrap('mcp.session.organizations', await supabase.from('organizations').select('id, name, slug').in('id', organizationIds).eq('is_active', true).order('name')) ?? []) as OrganizationOption[];
  if (!organizations.length) throw authorizationError('No active assigned organization is available.');
  const engagementRows = unwrap('mcp.session.engagements', await supabase
    .from('engagements')
    .select('id, organization_id, name, status, starts_on, ends_on, engagement_type, handling_label, current_phase')
    .in('organization_id', organizations.map((item) => item.id))
    .in('status', ['ACTIVE', 'PLANNED', 'PAUSED'])
    .order('starts_on', { ascending: false }));
  const engagements: EngagementOption[] = (engagementRows ?? []).map((row) => ({
    id: row.id,
    organizationId: row.organization_id,
    name: row.name,
    status: row.status,
    startsOn: row.starts_on ?? undefined,
    endsOn: row.ends_on ?? undefined,
    engagementType: row.engagement_type ?? undefined,
    handlingLabel: row.handling_label ?? undefined,
    currentPhase: row.current_phase ?? undefined,
  }));
  if (!engagements.length) throw dataAccessError('mcp.session.engagements', undefined, 'No active assigned engagement is available.');
  return { personId: person.id, displayName: person.display_name, organizations, engagements };
}
