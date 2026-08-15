import { PageIntro } from '@/components/portal/dashboard';
import { requirePortalRole } from '@/lib/portal/context';
import { ClientSetup } from '@/components/onboarding/client-setup';

export default async function ClientsPage() {
  const session = await requirePortalRole('consultant');
  return <><PageIntro eyebrow="Portfolio" title="Clients" description="Enter an organization with its active engagement context intact." />
    <ClientSetup />
    <section className="client-grid">{session.organizations.map((organization) => (
      <a className="client-card" href={`/api/portal-context?organizationId=${organization.id}&returnTo=${encodeURIComponent(`/consultant/clients/${organization.id}/overview`)}`} key={organization.id}>
        <span className="client-monogram">{organization.name.split(' ').map((part) => part[0]).slice(0, 2).join('')}</span>
        <div><h2>{organization.name}</h2><p>{session.engagements.find((item) => item.organizationId === organization.id)?.name ?? 'Open organization workspace'}</p></div>
        <span>Open →</span>
      </a>
    ))}</section></>;
}
