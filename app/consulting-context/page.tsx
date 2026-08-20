import Link from 'next/link';
import { hasAuthenticatedIdentity, getPortalSession } from '@/lib/portal/context';
import { redirect } from 'next/navigation';

export const dynamic = 'force-dynamic';

export default async function ConsultingContextPage() {
  const session = await getPortalSession();
  if (!session) {
    if (await hasAuthenticatedIdentity()) return <main className="context-chooser"><p className="eyebrow">Consulting context</p><h1>No active Consulting workspace</h1><p>Your identity is active, but no current Consulting assignment or membership is available.</p></main>;
    redirect('/login?returnTo=%2Fconsulting-context');
  }
  return <main className="context-chooser"><p className="eyebrow">Consulting context</p><h1>Choose how you are working.</h1><p>Consulting role and organization context are selected here, after product entry.</p><div className="context-choice-grid">{session.availableContexts.map((context) => <Link key={context.surface} href={`/api/portal-context?surface=${context.surface}&organizationId=${session.organization.id}&engagementId=${session.engagement.id}&returnTo=/${context.surface}`}><span>{context.surface === 'consultant' ? 'CONSULTANT' : 'CLIENT'}</span><strong>{context.label}</strong><small>Open authorized Consulting work →</small></Link>)}</div></main>;
}