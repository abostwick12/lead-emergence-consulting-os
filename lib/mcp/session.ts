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

export interface ClientMcpContext extends PortalSession {
  role: 'client';
  platformRole: 'CLIENT_ADMIN' | 'CLIENT_LEADER' | 'CLIENT_MEMBER';
}

export type ClientMcpResolution =
  | { status: 'ready'; context: ClientMcpContext }
  | { status: 'selection_required'; personId: string; displayName: string; engagements: ClientMcpEngagement[] }
  | { status: 'no_assignment'; personId: string; displayName: string };

export interface ClientMcpEngagement extends EngagementOption {
  organization: OrganizationOption;
  platformRole: 'CLIENT_ADMIN' | 'CLIENT_LEADER' | 'CLIENT_MEMBER';
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
    availableContexts: [{ surface: 'consultant', label: 'Consultant work', organizationIds: context.organizations.map((item) => item.id) }],
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

export async function listClientMcpEngagements(): Promise<ClientMcpEngagement[]> {
  if (isFixtureMode()) {
    const session = fixtureSession('client');
    if (!session || session.role !== 'client') throw authorizationError('Client authorization is required.');
    return session.engagements.map((engagement) => ({ ...engagement, organization: session.organizations.find((organization) => organization.id === engagement.organizationId) ?? session.organization, platformRole: 'CLIENT_MEMBER' }));
  }
  const context = await loadClientContext();
  return context.engagements;
}

export async function resolveClientMcpContext(selection: McpEngagementSelection): Promise<ClientMcpResolution> {
  if (isFixtureMode()) {
    const session = fixtureSession('client', selection.organizationId, selection.engagementId);
    if (!session || session.role !== 'client') throw authorizationError('Client authorization is required.');
    return { status: 'ready', context: { ...session, role: 'client', platformRole: 'CLIENT_MEMBER' } };
  }

  const context = await loadClientContext();
  if (!context.engagements.length) return { status: 'no_assignment', personId: context.personId, displayName: context.displayName };
  if (!selection.engagementId && !selection.organizationId && context.engagements.length > 1) {
    return { status: 'selection_required', personId: context.personId, displayName: context.displayName, engagements: context.engagements };
  }
  const selected = selection.engagementId
    ? context.engagements.find((item) => item.id === selection.engagementId)
    : selection.organizationId
      ? context.engagements.find((item) => item.organizationId === selection.organizationId)
      : context.engagements[0];
  if (!selected || (selection.organizationId && selected.organizationId !== selection.organizationId)) {
    throw authorizationError('The requested Lead Emergence workspace is unavailable.');
  }
  const organization = selected.organization;
  return {
    status: 'ready',
    context: {
      personId: context.personId,
      displayName: context.displayName,
      role: 'client',
      platformRole: selected.platformRole,
      organizations: context.organizations,
      organization,
      engagements: context.engagements.filter((item) => item.organizationId === organization.id),
      engagement: selected,
      availableContexts: [{ surface: 'client', label: 'Client work', organizationIds: context.organizations.map((item) => item.id) }],
      fixture: false,
    },
  };
}

async function loadClientContext(): Promise<{ personId: string; displayName: string; organizations: OrganizationOption[]; engagements: ClientMcpEngagement[] }> {
  const supabase = await createSupabaseServerClient();
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) throw authorizationError('The OAuth user session is no longer valid.');
  const person = unwrap('mcp.client.person', await supabase.from('people').select('id, display_name').eq('auth_user_id', userData.user.id).maybeSingle());
  if (!person) throw authorizationError('A Consulting OS person record is required.');
  const memberships = unwrap('mcp.client.memberships', await supabase
    .from('organization_memberships')
    .select('id, organization_id, platform_role, effective_from, effective_to')
    .eq('person_id', person.id)
    .eq('status', 'ACTIVE')
    .in('platform_role', ['CLIENT_ADMIN', 'CLIENT_LEADER', 'CLIENT_MEMBER'])
    .lte('effective_from', new Date().toISOString())
    .or(`effective_to.is.null,effective_to.gt.${new Date().toISOString()}`));
  const activeMemberships = memberships ?? [];
  const membershipIds = activeMemberships.map((item) => item.id);
  if (!membershipIds.length) return { personId: person.id, displayName: person.display_name, organizations: [], engagements: [] };
  const engagementMemberships = unwrap('mcp.client.engagementMemberships', await supabase
    .from('engagement_memberships')
    .select('organization_id, engagement_id, organization_membership_id')
    .in('organization_membership_id', membershipIds)
    .eq('status', 'ACTIVE'));
  const activeEngagementMemberships = engagementMemberships ?? [];
  const organizationIds = [...new Set(activeEngagementMemberships.map((item) => item.organization_id))];
  const engagementIds = [...new Set(activeEngagementMemberships.map((item) => item.engagement_id))];
  if (!organizationIds.length || !engagementIds.length) return { personId: person.id, displayName: person.display_name, organizations: [], engagements: [] };
  const [organizationsResult, engagementsResult] = await Promise.all([
    supabase.from('organizations').select('id, name, slug').in('id', organizationIds).eq('is_active', true).order('name'),
    supabase.from('engagements').select('id, organization_id, name, status, starts_on, ends_on, engagement_type, handling_label, current_phase').in('id', engagementIds).in('status', ['ACTIVE', 'PLANNED', 'PAUSED']).order('starts_on', { ascending: false }),
  ]);
  assertSucceeded('mcp.client.workspace', organizationsResult, engagementsResult);
  const organizations = (organizationsResult.data ?? []) as OrganizationOption[];
  const organizationById = new Map(organizations.map((item) => [item.id, item]));
  const membershipById = new Map(activeMemberships.map((item) => [item.id, item]));
  const engagementMembershipById = new Map(activeEngagementMemberships.map((item) => [item.engagement_id, item]));
  const engagements: ClientMcpEngagement[] = (engagementsResult.data ?? []).flatMap((row) => {
    const engagementMembership = engagementMembershipById.get(row.id);
    const membership = engagementMembership ? membershipById.get(engagementMembership.organization_membership_id) : undefined;
    const organization = organizationById.get(row.organization_id);
    if (!membership || !organization || membership.organization_id !== row.organization_id) return [];
    return [{
      id: row.id,
      organizationId: row.organization_id,
      name: row.name,
      status: row.status,
      startsOn: row.starts_on ?? undefined,
      endsOn: row.ends_on ?? undefined,
      engagementType: row.engagement_type ?? undefined,
      handlingLabel: row.handling_label ?? undefined,
      currentPhase: row.current_phase ?? undefined,
      organization,
      platformRole: membership.platform_role as ClientMcpEngagement['platformRole'],
    }];
  });
  return { personId: person.id, displayName: person.display_name, organizations, engagements };
}
