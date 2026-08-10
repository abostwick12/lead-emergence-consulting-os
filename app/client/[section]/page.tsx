import { notFound } from 'next/navigation';
import { PageIntro, RecordList } from '@/components/portal/dashboard';
import { requirePortalRole } from '@/lib/portal/context';
import { getPortalDashboard } from '@/lib/portal/repository';

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
  if (section === 'our-organization') return <><PageIntro eyebrow={session.organization.name} {...copy} /><RecordList records={dashboard.records} role="client" title="Validated organizational records" /></>;
  const messages: Record<string, string> = {
    'my-development': 'Development plans, commitments, and coaching-shared records will become actionable in Phase 7. Private coaching content is never organizational telemetry.',
    meetings: 'Meeting preparation and follow-up become operational in Phase 5. This page does not claim that invitations or actions are currently synchronized.',
    progress: 'Value and outcome workflows arrive in Phase 8. Current records remain visible without implying causal proof.',
    settings: 'Your access is derived from current Consulting memberships and engagement scope.',
  };
  return <><PageIntro eyebrow="Client portal" {...copy} /><section className="empty-state large"><strong>Ready for the next authorized workflow</strong><p>{messages[section]}</p></section></>;
}
