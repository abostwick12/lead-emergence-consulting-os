import { AlertTriangle, ArrowRight, Bot, CheckCircle2, LockKeyhole, ShieldCheck } from 'lucide-react';
import Link from 'next/link';
import { redirect } from 'next/navigation';
import { getPortalSession } from '@/lib/portal/context';
import { safeReturnPath } from '@/lib/portal/navigation';
import { isFixtureMode } from '@/lib/supabase/config';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export default async function OAuthConsentPage({ searchParams }: { searchParams: Promise<{ authorization_id?: string }> }) {
  const authorizationId = (await searchParams).authorization_id;
  if (!authorizationId) return <ConsentProblem title="Connection request missing" copy="Return to your AI assistant and start the connection again." />;
  if (isFixtureMode()) return <ConsentView authorizationId={authorizationId} clientName="Local MCP review client" redirectUri="http://localhost:3200/oauth/callback" scope="openid email profile" />;

  const supabase = await createSupabaseServerClient();
  const { data: userData } = await supabase.auth.getUser();
  if (!userData.user) {
    const returnTo = safeReturnPath(`/oauth/consent?authorization_id=${encodeURIComponent(authorizationId)}`);
    redirect(`/login?returnTo=${encodeURIComponent(returnTo)}`);
  }
  const session = await getPortalSession();
  if (!session || session.role !== 'consultant') {
    return <ConsentProblem title="Consultant access required" copy="This connection can only be approved by a user with an active Consulting OS consultant assignment." />;
  }

  const { data, error } = await supabase.auth.oauth.getAuthorizationDetails(authorizationId);
  if (error || !data) return <ConsentProblem title="Connection request expired" copy="Return to your AI assistant and start the connection again." />;
  if (!('authorization_id' in data)) redirect(data.redirect_url);

  return <ConsentView authorizationId={authorizationId} clientName={data.client.name} redirectUri={data.redirect_uri} scope={data.scope} />;
}

function ConsentView({ authorizationId, clientName, redirectUri, scope }: { authorizationId: string; clientName: string; redirectUri: string; scope?: string }) {
  const callbackHost = safeHostname(redirectUri);
  const recognized = recognizedClientHost(callbackHost);
  return (
    <main className="oauth-consent-page">
      <section className="oauth-consent-card" aria-labelledby="oauth-consent-heading">
        <div className="oauth-consent-icon"><Bot aria-hidden="true" /></div>
        <p className="eyebrow">SECURE AI CONNECTION</p>
        <h1 id="oauth-consent-heading">Connect {clientName}?</h1>
        <p className="oauth-consent-copy">This allows the AI assistant to work with the Consulting OS records that your consultant account is already authorized to access.</p>

        <div className="oauth-client-identity">
          <span><strong>{clientName}</strong><small>{callbackHost || 'Callback address unavailable'}</small></span>
          <span className={recognized ? 'status-chip' : 'status-chip gold'}>{recognized ? <CheckCircle2 aria-hidden="true" /> : <AlertTriangle aria-hidden="true" />}{recognized ? 'Recognized provider' : 'Review carefully'}</span>
        </div>

        <div className="oauth-permissions">
          <h2>This connection can</h2>
          <ul>
            <li><ShieldCheck aria-hidden="true" /><span><strong>Read assigned engagement records</strong><small>Only organizations and engagements already assigned to you.</small></span></li>
            <li><CheckCircle2 aria-hidden="true" /><span><strong>Save responses you explicitly confirm</strong><small>Write tools require confirmation and keep the existing audit trail.</small></span></li>
            <li><LockKeyhole aria-hidden="true" /><span><strong>Respect privacy and tenant boundaries</strong><small>Private coaching, other clients, and unassigned engagements remain unavailable.</small></span></li>
          </ul>
        </div>

        <p className="oauth-handling-warning"><AlertTriangle aria-hidden="true" /><span><strong>Sanitized information only.</strong> Do not enter classified, CUI, operationally sensitive mission data, targets, coordinates, frequencies, callsigns, intelligence, or operational timelines.</span></p>
        {scope && <p className="oauth-scope-note">Identity permissions requested: {scope.split(' ').join(', ')}</p>}

        <form action="/api/oauth/decision" method="post" className="oauth-consent-actions">
          <input type="hidden" name="authorization_id" value={authorizationId} />
          <button className="primary-button" type="submit" name="decision" value="approve">Approve connection <ArrowRight aria-hidden="true" /></button>
          <button className="secondary-button" type="submit" name="decision" value="deny">Cancel</button>
        </form>
        <p className="oauth-revoke-note">You can disconnect an AI assistant later from Consulting OS Settings.</p>
      </section>
    </main>
  );
}

function ConsentProblem({ title, copy }: { title: string; copy: string }) {
  return <main className="oauth-consent-page"><section className="oauth-consent-card"><div className="oauth-consent-icon"><LockKeyhole aria-hidden="true" /></div><p className="eyebrow">SECURE AI CONNECTION</p><h1>{title}</h1><p className="oauth-consent-copy">{copy}</p><Link className="primary-button" href="/consultant/settings">Return to Settings <ArrowRight aria-hidden="true" /></Link></section></main>;
}

function safeHostname(value: string) {
  try { return new URL(value).hostname.toLowerCase(); } catch { return ''; }
}

function recognizedClientHost(hostname: string) {
  return ['chatgpt.com', 'openai.com', 'claude.ai', 'anthropic.com', 'microsoft.com', 'github.com', 'visualstudio.com'].some((domain) => hostname === domain || hostname.endsWith(`.${domain}`));
}
