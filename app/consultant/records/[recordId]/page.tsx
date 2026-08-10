import { notFound } from 'next/navigation';
import { RecordDetail } from '@/components/portal/record-detail';
import { requirePortalRole } from '@/lib/portal/context';
import { getPortalRecord } from '@/lib/portal/repository';

export default async function ConsultantRecord({ params }: { params: Promise<{ recordId: string }> }) {
  const session = await requirePortalRole('consultant');
  const { recordId } = await params;
  const record = await getPortalRecord(session, recordId);
  if (!record) notFound();
  return <RecordDetail record={record} backHref={`/consultant/clients/${session.organization.id}/overview`} />;
}
