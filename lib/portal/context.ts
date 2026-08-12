import 'server-only';

import { cache } from 'react';
import { cookies } from 'next/headers';
import { notFound, redirect } from 'next/navigation';
import { fixtureSession } from './fixtures';
import type { EngagementOption, OrganizationOption, PortalRole, PortalSession } from './types';
import { isFixtureMode } from '@/lib/supabase/config';
import { createSupabaseServerClient } from '@/lib/supabase/server';

const FIXTURE_COOKIE = 'le_fixture_role';

export const getPortalSession = cache(async (): Promise<PortalSession | null> => {
  if (isFixtureMode()) {
    const cookieStore = await cookies();
    const value = cookieStore.get(FIXTURE_COOKIE)?.value;
    const role: PortalRole = value === 'consultant' || value === 'client' ? value : 'outsider';
    return fixtureSession(role, cookieStore.get('le_organization_id')?.value, cookieStore.get('le_engagement_id')?.value);
  }

  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.auth.getClaims();
  const authUserId = data?.claims?.sub;
  if (error || typeof authUserId !== 'string') return null;

  const { data: person } = await supabase
    .from('people')
    .select('id, display_name')
    .eq('auth_user_id', authUserId)
    .maybeSingle();
  if (!person) return null;

  const [{ data: assignments }, { data: memberships }] = await Promise.all([
    supabase
      .from('consultant_assignments')
      .select('organization_id')
      .eq('consultant_person_id', person.id)
      .eq('status', 'ACTIVE'),
    supabase
      .from('organization_memberships')
      .select('organization_id, platform_role')
      .eq('person_id', person.id)
      .eq('status', 'ACTIVE'),
  ]);

  const role: PortalRole = assignments?.length ? 'consultant' : memberships?.length ? 'client' : 'outsider';
  if (role === 'outsider') return null;
  const organizationIds = role === 'consultant'
    ? assignments!.map((item) => item.organization_id)
    : memberships!.map((item) => item.organization_id);
  const { data: organizationRows } = await supabase
    .from('organizations')
    .select('id, name, slug')
    .in('id', organizationIds)
    .eq('is_active', true)
    .order('name');
  const organizations = (organizationRows ?? []) as OrganizationOption[];
  if (!organizations.length) return null;

  const cookieStore = await cookies();
  const requestedOrgId = cookieStore.get('le_organization_id')?.value;
  const organization = organizations.find((item) => item.id === requestedOrgId) ?? organizations[0];
  const { data: engagementRows } = await supabase
    .from('engagements')
    .select('id, organization_id, name, status, starts_on, ends_on')
    .eq('organization_id', organization.id)
    .in('status', ['ACTIVE', 'PLANNED', 'PAUSED'])
    .order('starts_on', { ascending: false });
  const engagements: EngagementOption[] = (engagementRows ?? []).map((row) => ({
    id: row.id,
    organizationId: row.organization_id,
    name: row.name,
    status: row.status,
    startsOn: row.starts_on ?? undefined,
    endsOn: row.ends_on ?? undefined,
  }));
  if (!engagements.length) return null;
  const requestedEngagementId = cookieStore.get('le_engagement_id')?.value;
  const engagement = engagements.find((item) => item.id === requestedEngagementId) ?? engagements[0];

  return {
    personId: person.id,
    displayName: person.display_name,
    role,
    organizations,
    organization,
    engagements,
    engagement,
    fixture: false,
  };
});

export async function requirePortalRole(role: Exclude<PortalRole, 'outsider'>) {
  const session = await getPortalSession();
  if (!session) redirect(`/login?returnTo=${encodeURIComponent(role === 'consultant' ? '/consultant' : '/client')}`);
  if (session.role !== role) notFound();
  return session;
}

export function fixtureCookieName() {
  return FIXTURE_COOKIE;
}
