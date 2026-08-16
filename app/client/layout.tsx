import { PortalShell } from '@/components/portal/portal-shell';
import { requirePortalRole } from '@/lib/portal/context';

export const dynamic = 'force-dynamic';

export default async function ClientLayout({ children }: { children: React.ReactNode }) {
  const session = await requirePortalRole('client');
  return <PortalShell session={session}>{children}</PortalShell>;
}
