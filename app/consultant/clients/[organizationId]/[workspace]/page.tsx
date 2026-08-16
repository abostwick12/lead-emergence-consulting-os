import { notFound, redirect } from 'next/navigation';
import { LockKeyhole } from 'lucide-react';
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
import { AccessCenter } from '@/components/access/access-center';
import { getAccessCenter } from '@/lib/access/repository';
import { MinistryHandoffCenter } from '@/components/handoff/ministry-handoff-center';
import { getMinistryHandoff } from '@/lib/handoff/repository';
import { requirePortalRole } from '@/lib/portal/context';
import { getPortalDashboard, recordsForWorkspace } from '@/lib/portal/repository';
import { workspaceDefinitions, type WorkspaceKey } from '@/lib/portal/types';
import { OperationalEngagementCenter } from '@/components/operational-ai/operational-engagement-center';
import { AssessmentInstrumentLibrary } from '@/components/operational-ai/assessment-instrument-library';
import { getOperationalEngagement, isOperationalWorkspaceProvisioned, operationalProvisioningGateNotice } from '@/lib/operational-ai/repository';
import { isOperationalSection, operationalSections } from '@/lib/operational-ai/types';

export default async function WorkspacePage({ params }: { params: Promise<{ organizationId: string; workspace: string }> }) {
  const session = await requirePortalRole('consultant');
  const { organizationId, workspace } = await params;
  if (organizationId !== session.organization.id) {
    if (!session.organizations.some((item) => item.id === organizationId)) notFound();
    redirect(`/api/portal-context?organizationId=${organizationId}&returnTo=${encodeURIComponent(`/consultant/clients/${organizationId}/${workspace}`)}`);
  }
  if (session.engagement.engagementType === 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION') {
    if (!isOperationalSection(workspace)) notFound();
    const section = operationalSections.find((item) => item.key === workspace)!;
    return <><PageIntro eyebrow={`${session.organization.name} · ${session.engagement.name}`} title={section.label} description={section.phase === 'P0' ? 'Operational product assessment and evidence workspace.' : `${section.phase} engagement workspace — deliberately phase-gated.`} />
      <nav className="workspace-tabs operational-tabs" aria-label="Operational Product AI workspace sections">{operationalSections.map((item) => <a className={item.key === workspace ? 'active' : ''} href={`/consultant/clients/${organizationId}/${item.key}`} key={item.key}>{item.label}<small>{item.phase}</small></a>)}</nav>
      {workspace === 'audits' && <AssessmentInstrumentLibrary />}
      {isOperationalWorkspaceProvisioned(session)
        ? <OperationalEngagementCenter initialData={await getOperationalEngagement(session)} section={workspace} />
        : <section className="phase-gate"><LockKeyhole aria-hidden="true" /><p className="eyebrow">Infrastructure checkpoint</p><h2>This workspace is not provisioned in the hosted environment yet.</h2><p>{operationalProvisioningGateNotice} Nothing can be read or written here until that checkpoint is approved, and no automation is running.</p></section>}
    </>;
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
  const access = workspace === 'handoff' ? await getAccessCenter(session) : null;
  const handoff = workspace === 'handoff' ? await getMinistryHandoff(session) : null;
  return <><PageIntro eyebrow={`${session.organization.name} · ${session.engagement.name}`} title={definition.label} description={definition.description} />
    <nav className="workspace-tabs" aria-label="Client workspace sections">{workspaceDefinitions.map((item) => <a className={item.key === workspace ? 'active' : ''} href={`/consultant/clients/${organizationId}/${item.key}`} key={item.key}>{item.label}</a>)}</nav>
    {alignment && <AlignmentCapabilityCenter initialData={alignment} mode={workspace === 'development' ? 'development' : 'alignment'} />}
    {discovery && <DiscoveryIntake initialData={discovery} />}
    {meridian && <GroundedAssistance initialData={meridian} />}
    {outcomes && <OutcomesNewRealityCenter initialData={outcomes} />}
    {signals && <DescriptiveSignalsCenter initialData={signals} />}
    {access && <AccessCenter initialData={access} />}
    {handoff && <MinistryHandoffCenter initialData={handoff} />}
    {!outcomes && !signals && !handoff && <><StateLegend /><RecordList records={records} role="consultant" title={`${definition.label} records`} /></>}
  </>;
}
