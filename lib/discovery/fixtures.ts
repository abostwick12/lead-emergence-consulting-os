import type { PortalSession } from '@/lib/portal/types';
import { createFixtureStore } from '../fixtures/store';
import type { DiscoveryIntakeData, DiscoveryMutation } from './types';

interface DiscoveryFixtureStore { items: Array<{ id: string; kind: string; title: string; detail: string }>; revision: number }
const fixtures = createFixtureStore<DiscoveryFixtureStore>('discovery', () => ({ items: [], revision: 0 }));
const store = fixtures.read;

export function fixtureDiscoveryIntake(session: PortalSession): DiscoveryIntakeData {
  const current = store();
  return { organizationId: session.organization.id, engagementId: session.engagement.id, role: session.role as 'consultant' | 'client', evidenceCount: current.items.filter((item) => item.kind === 'EVIDENCE').length, interviewCount: current.items.filter((item) => item.kind === 'INTERVIEW').length, assessmentCount: current.items.filter((item) => item.kind === 'ASSESSMENT').length, recentItems: [...current.items].reverse().slice(0, 8) };
}

export function mutateFixtureDiscovery(session: PortalSession, mutation: DiscoveryMutation) {
  const current = store(); current.revision += 1;
  if (mutation.action === 'CAPTURE_EVIDENCE') current.items.push({ id: `evidence-${current.revision}`, kind: 'EVIDENCE', title: mutation.title, detail: mutation.relevanceNote });
  if (mutation.action === 'RECORD_INTERVIEW') current.items.push({ id: `interview-${current.revision}`, kind: 'INTERVIEW', title: mutation.participantLabel, detail: mutation.question });
  if (mutation.action === 'CREATE_ASSESSMENT') current.items.push({ id: `assessment-${current.revision}`, kind: 'ASSESSMENT', title: mutation.name, detail: `${mutation.audience} · ${mutation.confidentiality}` });
  return fixtureDiscoveryIntake(session);
}
export function resetDiscoveryFixtures() { fixtures.reset(); }
