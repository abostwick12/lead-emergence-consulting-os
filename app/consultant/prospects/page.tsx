import { ProspectCenter } from '@/components/prospects/prospect-center';
import { requirePortalRole } from '@/lib/portal/context';
import { getProspectCenter } from '@/lib/prospects/repository';
export default async function ProspectsPage() { await requirePortalRole('consultant'); return <ProspectCenter initialData={await getProspectCenter()} />; }