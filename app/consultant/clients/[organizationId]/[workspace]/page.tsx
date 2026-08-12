import { notFound, redirect } from 'next/navigation';
import { PageIntro, RecordList } from '@/components/portal/dashboard';
import { StateLegend } from '@/components/portal/state-badge';
import { AlignmentCapabilityCenter } from '@/components/alignment/alignment-capability-center';
import { getAlignmentCapability } from '@/lib/alignment/repository';
import { OutcomesNewRealityCenter } from '@/components/outcomes/outcomes-new-reality-center';
import { getOutcomesNewReality } from '@/lib/outcomes/repository';
import { GroundedAssistance } from '@/components/meridian-ai/grounded-assistance';
import { getMeridianAi } from '@/lib/meridian-ai/repository';
import { DescriptiveSignalsCenter } from '@/components/signals/descriptive-signals-center';
import { getSignalsWorkspace } from '@/lib/signals/repository';
import { DiscoveryIntake } from '@/components/discovery/discovery-intake';
import { getDiscoveryIntake } from '@/lib/discovery/repository';
import { requirePortalRole } from '@/lib/portal/context';
import { getPortalDashboard, recordsForWorkspace } from '@/lib/portal/repository';
import { workspaceDefinitions, type WorkspaceKey } from '@/lib/portal/types';

export default async function WorkspacePage({ params }: { params: Promise<{ organizationId: string; workspace: string }> }) {
  const session = await requirePortalRole('consultant');
  const { organizationId, workspace } = await params;
  if (organizationId !== session.organization.id) {
    if (!session.organizations.some((item) => item.id === organizationId)) notFound();
    redirect(`/api/portal-context?organizationId=${organizationId}&returnTo=${encodeURIComponent(`/consultant/clients/${organizationId}/${workspace}`)}`);
  }
  const definition = workspaceDefinitions.find((item) => item.key === workspace);
  if (!definition) notFound();
  const dashboard = await getPortalDashboard(session);
  const records = recordsForWorkspace(dashboard, workspace as WorkspaceKey);
  const alignment = workspace === 'strategy' || workspace === 'development' ? await getAlignmentCapability(session) : null;
  const outcomes = workspace === 'outcomes' ? await getOutcomesNewReality(session) : null;
  const meridian = workspace === 'discovery' || workspace === 'strategy' ? await getMeridianAi(session) : null;
  const signals = workspace === 'signals' ? await getSignalsWorkspace(session) : null;
  const discovery = workspace === 'discovery' ? await getDiscoveryIntake(session) : null;
  return <><PageIntro eyebrow={`${session.organization.name} · ${session.engagement.name}`} title={definition.label} description={definition.description} />
    <nav className="workspace-tabs" aria-label="Client workspace sections">{workspaceDefinitions.map((item) => <a className={item.key === workspace ? 'active' : ''} href={`/consultant/clients/${organizationId}/${item.key}`} key={item.key}>{item.label}</a>)}</nav>
    {alignment && <AlignmentCapabilityCenter initialData={alignment} mode={workspace === 'development' ? 'development' : 'alignment'} />}
    {discovery && <DiscoveryIntake initialData={discovery} />}
    {meridian && <GroundedAssistance initialData={meridian} />}
    {outcomes && <OutcomesNewRealityCenter initialData={outcomes} />}
    {signals && <DescriptiveSignalsCenter initialData={signals} />}
    {!outcomes && !signals && <><StateLegend /><RecordList records={records} role="consultant" title={`${definition.label} records`} /></>}
  </>;
}
