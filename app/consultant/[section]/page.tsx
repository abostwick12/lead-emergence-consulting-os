import { notFound } from 'next/navigation';
import { PageIntro } from '@/components/portal/dashboard';
import { MeetingCenter } from '@/components/meetings/meeting-center';
import { requirePortalRole } from '@/lib/portal/context';
import { getMeetingCenter } from '@/lib/meetings/repository';

const sections: Record<string, { title: string; description: string; message: string }> = {
  meetings: { title: 'Meetings', description: 'Prepare, meet, capture, decide, commit, and follow up in one traceable interaction record.', message: '' },
  resources: { title: 'Resources', description: 'Reusable consulting materials with explicit visibility.', message: 'Resource composition will build on the approved artifact model. No ungoverned file library is active.' },
  settings: { title: 'Settings', description: 'Portal preferences and current access context.', message: 'Access comes from Consulting assignments and memberships. Organization structure roles do not grant software authorization.' },
};

export default async function ConsultantSection({ params }: { params: Promise<{ section: string }> }) {
  const session = await requirePortalRole('consultant');
  const { section } = await params;
  const content = sections[section];
  if (!content) notFound();
  if (section === 'meetings') return <><PageIntro eyebrow={session.organization.name} title={content.title} description={content.description} /><MeetingCenter initialData={await getMeetingCenter(session)} /></>;
  return <><PageIntro eyebrow="Consultant portal" title={content.title} description={content.description} /><section className="empty-state large"><strong>Deliberately bounded</strong><p>{content.message}</p></section></>;
}
