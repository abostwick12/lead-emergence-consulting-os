import { notFound } from 'next/navigation';
import { MeetingCenter } from '@/components/meetings/meeting-center';
import { PageIntro } from '@/components/portal/dashboard';
import { getMeetingCenter } from '@/lib/meetings/repository';
import { requirePortalRole } from '@/lib/portal/context';

export default async function ConsultantMeetingDetail({ params }: { params: Promise<{ meetingId: string }> }) {
  const session = await requirePortalRole('consultant');
  const { meetingId } = await params;
  const data = await getMeetingCenter(session);
  if (!data.meetings.some((meeting) => meeting.id === meetingId)) notFound();
  return <><PageIntro eyebrow={session.organization.name} title="Meeting workspace" description="The complete interaction, privacy boundary, commitments, and history in context." /><MeetingCenter initialData={data} initialMeetingId={meetingId} /></>;
}
