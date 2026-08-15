import type { EngagementOption, OrganizationOption } from '@/lib/portal/types';
import type { StartEngagementInput, StartEngagementResult } from './types';

interface OnboardingFixtureStore { organizations: OrganizationOption[]; engagements: EngagementOption[]; revision: number }
declare global { var __leOnboardingFixtures: OnboardingFixtureStore | undefined; }
function store() {
  globalThis.__leOnboardingFixtures ??= { organizations: [], engagements: [], revision: 0 };
  return globalThis.__leOnboardingFixtures;
}

export function fixtureOnboardingOptions() {
  const current = store();
  return { organizations: current.organizations, engagements: current.engagements };
}

export function startFixtureEngagement(input: StartEngagementInput): StartEngagementResult {
  const current = store();
  current.revision += 1;
  const suffix = String(current.revision).padStart(12, '0');
  const organizationId = `10000000-0000-4000-8001-${suffix}`;
  const engagementId = `20000000-0000-4000-8001-${suffix}`;
  const slugBase = input.organizationName.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'client';
  current.organizations.push({ id: organizationId, name: input.organizationName, slug: `${slugBase}-${current.revision}` });
  current.engagements.push({ id: engagementId, organizationId, name: input.engagementName, status: 'ACTIVE', startsOn: input.startsOn, endsOn: input.endsOn, engagementType: input.engagementType, handlingLabel: input.engagementType === 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION' ? 'Internal — Sanitized Only' : undefined, currentPhase: input.engagementType === 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION' ? 'SEE REALITY' : undefined });
  return { organizationId, engagementId };
}

export function resetOnboardingFixtures() {
  globalThis.__leOnboardingFixtures = { organizations: [], engagements: [], revision: 0 };
}
