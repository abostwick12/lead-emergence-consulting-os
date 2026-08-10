import { notFound } from 'next/navigation';
import { PageIntro, RecordList } from '@/components/portal/dashboard';
import { StateLegend } from '@/components/portal/state-badge';
import { requirePortalRole } from '@/lib/portal/context';
import { getPortalDashboard, recordsForWorkspace } from '@/lib/portal/repository';
import { workspaceDefinitions, type WorkspaceKey } from '@/lib/portal/types';

export default async function WorkspacePage({ params }: { params: Promise<{ organizationId: string; workspace: string }> }) {
  const session = await requirePortalRole('consultant');
  const { organizationId, workspace } = await params;
  if (organizationId !== session.organization.id) notFound();
  const definition = workspaceDefinitions.find((item) => item.key === workspace);
  if (!definition) notFound();
  const dashboard = await getPortalDashboard(session);
  const records = recordsForWorkspace(dashboard, workspace as WorkspaceKey);
  return <><PageIntro eyebrow={`${session.organization.name} · ${session.engagement.name}`} title={definition.label} description={definition.description} />
    <nav className="workspace-tabs" aria-label="Client workspace sections">{workspaceDefinitions.map((item) => <a className={item.key === workspace ? 'active' : ''} href={`/consultant/clients/${organizationId}/${item.key}`} key={item.key}>{item.label}</a>)}</nav>
    <StateLegend />
    <RecordList records={records} role="consultant" title={`${definition.label} records`} />
  </>;
}
