import { notFound } from 'next/navigation';
import { PageIntro } from '@/components/portal/dashboard';
import { requirePortalRole } from '@/lib/portal/context';

const sections: Record<string, { title: string; description: string; message: string }> = {
  meetings: { title: 'Meetings', description: 'A truthful view of engagement conversations and follow-up.', message: 'Meeting persistence and action workflows arrive in Phase 5. No meeting has been represented as live before then.' },
  resources: { title: 'Resources', description: 'Reusable consulting materials with explicit visibility.', message: 'Resource composition will build on the approved artifact model. No ungoverned file library is active.' },
  settings: { title: 'Settings', description: 'Portal preferences and current access context.', message: 'Access comes from Consulting assignments and memberships. Organization structure roles do not grant software authorization.' },
};

export default async function ConsultantSection({ params }: { params: Promise<{ section: string }> }) {
  await requirePortalRole('consultant');
  const { section } = await params;
  const content = sections[section];
  if (!content) notFound();
  return <><PageIntro eyebrow="Consultant portal" title={content.title} description={content.description} /><section className="empty-state large"><strong>Deliberately bounded</strong><p>{content.message}</p></section></>;
}
