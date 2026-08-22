import Link from 'next/link';
import { ArrowRight } from 'lucide-react';
import { hasAuthenticatedIdentity, getPortalSession } from '@/lib/portal/context';
import { redirect } from 'next/navigation';

export const dynamic = 'force-dynamic';

export default async function ConsultingContextPage() {
  const session = await getPortalSession();
  if (!session) {
    if (await hasAuthenticatedIdentity()) {
      return (
        <main className="context-chooser">
          <section className="context-chooser-card" aria-labelledby="consulting-context-heading">
            <p className="eyebrow">Consulting context</p>
            <h1 id="consulting-context-heading">No active Consulting workspace</h1>
            <p className="context-chooser-copy">Your identity is active, but no current Consulting assignment or membership is available.</p>
          </section>
        </main>
      );
    }
    redirect('/login?returnTo=%2Fconsulting-context');
  }
  return (
    <main className="context-chooser">
      <section className="context-chooser-card" aria-labelledby="consulting-context-heading">
        <p className="eyebrow">Consulting context</p>
        <h1 id="consulting-context-heading">Choose how you are working.</h1>
        <p className="context-chooser-copy">Consulting role and organization context are selected here, after product entry.</p>
        <div className="context-choice-grid">
          {session.availableContexts.map((context) => (
            <Link key={context.surface} href={`/api/portal-context?surface=${context.surface}&organizationId=${session.organization.id}&engagementId=${session.engagement.id}&returnTo=/${context.surface}`}>
              <span>
                <small>{context.surface === 'consultant' ? 'CONSULTANT' : 'CLIENT'}</small>
                <strong>{context.label}</strong>
                <em>Open authorized Consulting work</em>
              </span>
              <ArrowRight aria-hidden="true" />
            </Link>
          ))}
        </div>
      </section>
    </main>
  );
}
