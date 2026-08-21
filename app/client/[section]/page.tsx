import { notFound } from 'next/navigation';
import { PageIntro, RecordList } from '@/components/portal/dashboard';
import { MeetingCenter } from '@/components/meetings/meeting-center';
import { AlignmentCapabilityCenter } from '@/components/alignment/alignment-capability-center';
import { getAlignmentCapability } from '@/lib/alignment/repository';
import { requirePortalRole } from '@/lib/portal/context';
import { getPortalDashboard } from '@/lib/portal/repository';
import { getMeetingCenter } from '@/lib/meetings/repository';
import { OutcomesNewRealityCenter } from '@/components/outcomes/outcomes-new-reality-center';
import { getOutcomesNewReality } from '@/lib/outcomes/repository';
import { DescriptiveSignalsCenter } from '@/components/signals/descriptive-signals-center';
import { getSignalsWorkspace } from '@/lib/signals/repository';
import { EntryIdentityConnection } from '@/components/portal/entry-identity-connection';

const sectionCopy: Record<string, { title: string; description: string }> = {
  'our-organization': { title: 'Our Organization', description: 'Validated organizational knowledge, current effective state, and shared decisions.' },
  'my-development': { title: 'My Development', description: 'Your visible growth work, commitments, and coaching-shared context.' },
  meetings: { title: 'Meetings', description: 'Upcoming shared meetings, preparation, and action follow-up.' },
  progress: { title: 'Progress', description: 'Shared goals, indicators, outcomes, and learning without overstating causality.' },
  settings: { title: 'Settings', description: 'Your portal preferences and access context.' },
};

export default async function ClientSection({ params }: { params: Promise<{ section: string }> }) {
  const session = await requirePortalRole('client');
  const { section } = await params;
  const copy = sectionCopy[section];
  if (!copy) notFound();
  const dashboard = await getPortalDashboard(session);
  if (section === 'our-organization') return <><PageIntro eyebrow={session.organization.name} {...copy} /><AlignmentCapabilityCenter initialData={await getAlignmentCapability(session)} mode="alignment" /><RecordList records={dashboard.records} role="client" title="Validated organizational records" /></>;
  if (section === 'my-development') return <><PageIntro eyebrow={session.organization.name} {...copy} /><AlignmentCapabilityCenter initialData={await getAlignmentCapability(session)} mode="development" /></>;
  if (section === 'meetings') return <><PageIntro eyebrow={session.organization.name} {...copy} /><MeetingCenter initialData={await getMeetingCenter(session)} /></>;
  if (section === 'progress') return <><PageIntro eyebrow={session.organization.name} {...copy} /><OutcomesNewRealityCenter initialData={await getOutcomesNewReality(session)} /><DescriptiveSignalsCenter initialData={await getSignalsWorkspace(session)} /></>;
  if (section === 'settings') return <><PageIntro eyebrow="Client portal" {...copy} /><EntryIdentityConnection /><section className="empty-state large"><strong>Consulting authorization remains local</strong><p>Your access is derived from current Consulting memberships and engagement scope.</p></section></>;
  const messages: Record<string, string> = {
  };
  return <><PageIntro eyebrow="Client portal" {...copy} /><section className="empty-state large"><strong>Ready for the next authorized workflow</strong><p>{messages[section]}</p></section></>;
}
