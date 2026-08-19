import Link from 'next/link';
import { ArrowRight, GitBranch, LockKeyhole, ScanSearch } from 'lucide-react';
import { signIn } from './actions';
import { getPortalSession, hasAuthenticatedIdentity } from '@/lib/portal/context';
import { isFixtureMode } from '@/lib/supabase/config';
import { safeReturnPath } from '@/lib/portal/navigation';
import { safeLoginError } from '@/lib/portal/login-messages';
import { notFound, redirect } from 'next/navigation';

export default async function LoginPage({ searchParams }: { searchParams: Promise<{ error?: string; returnTo?: string }> }) {
  const params = await searchParams;
  const returnTo = safeReturnPath(params.returnTo ?? '/');
  const error = safeLoginError(params.error);
  const fixture = isFixtureMode();
  const portalSession = await getPortalSession();
  if (portalSession?.role === 'consultant' || portalSession?.role === 'client') redirect(returnTo);
  if (await hasAuthenticatedIdentity()) notFound();
  const selectedRole = returnTo === '/consultant' || returnTo.startsWith('/consultant/') ? 'consultant' : returnTo === '/client' || returnTo.startsWith('/client/') ? 'client' : null;
  return (
    <main className="login-page">
      <aside className="login-story" aria-label="Product introduction">
        <div className="login-brand-lockup">
          <span className="login-brand-mark" aria-hidden="true">LE</span>
          <span className="brand-wordmark"><strong><i>Lead</i> Emergence</strong><small>CONSULTING OS</small></span>
        </div>
        <div className="login-story-copy">
          <p className="eyebrow">ORGANIZATIONAL REASONING SYSTEM</p>
          <h1>See reality.<br />Choose change.<br /><em>Trace what emerges.</em></h1>
          <p>Keep evidence, interpretation, decisions, capability, and outcomes connected across the full consulting journey.</p>
        </div>
        <div className="login-outcomes" aria-label="Platform outcomes">
          <span><ScanSearch aria-hidden="true" />Evidence in context</span>
          <span><GitBranch aria-hidden="true" />Reasoning you can trace</span>
          <span><LockKeyhole aria-hidden="true" />Privacy by design</span>
        </div>
      </aside>
      <section className="login-panel">
        <div className="login-panel-inner">
          <p className="eyebrow">SECURE ACCESS</p>
          <h2>Welcome back.</h2>
          <p className="login-copy">Enter the workspace authorized for your current consulting assignment or organization membership.</p>
        {error && <p className="form-error" role="alert">{error}</p>}
        {fixture ? (
          <div className="fixture-login" data-testid="fixture-login">
            <p>Local review access</p>
            {selectedRole !== 'client' && <Link className="primary-button" href={`/api/test-session?role=consultant&returnTo=${encodeURIComponent(returnTo === '/' ? '/consultant' : returnTo)}`}>Enter consultant portal <ArrowRight aria-hidden="true" /></Link>}
            {selectedRole !== 'consultant' && <Link className={selectedRole === 'client' ? 'primary-button' : 'secondary-button'} href={`/api/test-session?role=client&returnTo=${encodeURIComponent(returnTo === '/' ? '/client' : returnTo)}`}>Enter client portal {selectedRole === 'client' && <ArrowRight aria-hidden="true" />}</Link>}
          </div>
        ) : (
          <form action={signIn} className="login-form">
            <input type="hidden" name="returnTo" value={returnTo} />
            <label>Email<input type="email" name="email" autoComplete="email" required /></label>
            <label>Password<input type="password" name="password" autoComplete="current-password" required /></label>
            <button className="primary-button" type="submit">Sign in <ArrowRight aria-hidden="true" /></button>
          </form>
        )}
          <div className="security-note"><LockKeyhole aria-hidden="true" /><span><strong>Protected workspace</strong>Private coaching and consultant material remain partitioned from general organizational knowledge.</span></div>
        </div>
      </section>
    </main>
  );
}
