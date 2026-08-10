import Link from 'next/link';
import { PageIntro } from '@/components/portal/dashboard';
import { requirePortalRole } from '@/lib/portal/context';

export default async function ClientsPage() {
  const session = await requirePortalRole('consultant');
  return <><PageIntro eyebrow="Portfolio" title="Clients" description="Enter an organization with its active engagement context intact." />
    <section className="client-grid">{session.organizations.map((organization) => (
      <Link className="client-card" href={`/consultant/clients/${organization.id}/overview`} key={organization.id}>
        <span className="client-monogram">{organization.name.split(' ').map((part) => part[0]).slice(0, 2).join('')}</span>
        <div><h2>{organization.name}</h2><p>{organization.id === session.organization.id ? session.engagement.name : 'Open organization workspace'}</p></div>
        <span>Open →</span>
      </Link>
    ))}</section></>;
}
