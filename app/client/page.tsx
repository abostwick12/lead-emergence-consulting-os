import { DashboardView } from '@/components/portal/dashboard';
import { requirePortalRole } from '@/lib/portal/context';
import { getPortalDashboard } from '@/lib/portal/repository';

export default async function ClientHome() {
  const session = await requirePortalRole('client');
  const dashboard = await getPortalDashboard(session);
  return <DashboardView dashboard={dashboard} role="client" />;
}
