import { beforeEach, describe, expect, it, vi } from 'vitest';

const { session, fixture, createClient, product, details, approve, deny, entryStart, persist, cookiesMock } = vi.hoisted(() => ({
  session: vi.fn(), fixture: vi.fn(), createClient: vi.fn(), product: vi.fn(), details: vi.fn(),
  approve: vi.fn(), deny: vi.fn(), entryStart: vi.fn(), persist: vi.fn(), cookiesMock: vi.fn(),
}));
vi.mock('server-only', () => ({}));
vi.mock('@/lib/portal/context', () => ({ getPortalSession: session }));
vi.mock('@/lib/supabase/config', () => ({ isFixtureMode: fixture }));
vi.mock('@/lib/supabase/server', () => ({ createSupabaseServerClient: createClient }));
vi.mock('@/lib/http/origin', () => ({ resolveTrustedOrigin: () => 'https://consulting.leademergence.com' }));
vi.mock('@/lib/auth/entry-sso', () => ({ persistEntryIdentity: persist }));
vi.mock('next/headers', () => ({ cookies: cookiesMock }));

import OAuthConsentPage from '@/app/oauth/consent/page';
import { POST } from '@/app/api/oauth/decision/route';
import { GET as entryCallback } from '@/app/auth/callback/[mode]/route';
import { GET as entryBegin } from '@/app/auth/entry/route';
import { NextRequest } from 'next/server';
import { loginErrors } from '@/lib/portal/login-messages';

const authorizationId = 'a'.repeat(32);
const endpoint = 'https://consulting.leademergence.com/api/oauth/decision';

function client() {
  return {
    auth: {
      getUser: async () => ({ data: { user: { id: 'user-1' } } }),
      oauth: { getAuthorizationDetails: details, approveAuthorization: approve, denyAuthorization: deny },
      signInWithOAuth: entryStart,
      exchangeCodeForSession: async () => ({ error: null }),
      signOut: async () => ({}),
    },
    schema: () => ({ rpc: product }),
  };
}

function decisionRequest(value: string, extra = '') {
  return new Request(endpoint, {
    method: 'POST',
    headers: { origin: 'https://consulting.leademergence.com', 'content-type': 'application/x-www-form-urlencoded' },
    body: `authorization_id=${value}&decision=approve${extra}`,
  });
}

describe('Consulting product-local consent and Entry continuation', () => {
  beforeEach(() => {
    fixture.mockReset().mockReturnValue(false);
    session.mockReset().mockResolvedValue({ role: 'consultant' });
    createClient.mockReset().mockImplementation(async () => client());
    product.mockReset(); details.mockReset(); approve.mockReset(); deny.mockReset(); entryStart.mockReset(); persist.mockReset(); cookiesMock.mockReset();
  });

  it.each(['workspace', 'ministry', 'deny'])('blocks %s before displaying details', async (value) => {
    product.mockResolvedValue({ data: value, error: null });
    await OAuthConsentPage({ searchParams: Promise.resolve({ authorization_id: authorizationId }) });
    expect(details).not.toHaveBeenCalled();
  });

  it('displays a verified Consulting authorization under the existing portal session', async () => {
    product.mockResolvedValue({ data: 'consulting', error: null });
    details.mockResolvedValue({ data: {
      authorization_id: authorizationId,
      client: { name: 'Synthetic AI client' },
      redirect_uri: 'https://client.example/callback',
      scope: 'openid email profile',
    }, error: null });
    const element = await OAuthConsentPage({ searchParams: Promise.resolve({ authorization_id: authorizationId }) });
    expect(details).toHaveBeenCalledWith(authorizationId);
    expect(element.props.authorizationId).toBe(authorizationId);
  });

  it.each(['workspace', 'ministry', 'deny'])('blocks %s before approval', async (value) => {
    product.mockResolvedValue({ data: value, error: null });
    const response = await POST(decisionRequest(authorizationId, '&product=consulting&destination=https%3A%2F%2Fattacker.example'));
    expect(response.status).toBe(403);
    expect(approve).not.toHaveBeenCalled();
  });

  it('fails closed for an invalid or expired stored authorization', async () => {
    product.mockResolvedValue({ data: 'deny', error: null });
    expect((await POST(decisionRequest('missing-id'))).status).toBe(403);
    expect(approve).not.toHaveBeenCalled();
  });

  it('approves only an authenticated Consulting request', async () => {
    product.mockResolvedValue({ data: 'consulting', error: null });
    approve.mockResolvedValue({ data: { redirect_url: 'https://client.example/callback' }, error: null });
    expect((await POST(decisionRequest(authorizationId))).status).toBe(303);
    expect(approve).toHaveBeenCalledTimes(1);
  });

  it('returns to the exact pending consent request after successful Entry OIDC callback', async () => {
    const values = new Map([
      ['le_entry_sso_mode_sign-in', 'sign_in'],
      ['le_entry_sso_consent_return', `/oauth/consent?authorization_id=${authorizationId}`],
    ]);
    const set = vi.fn();
    cookiesMock.mockResolvedValue({ get: (name: string) => ({ value: values.get(name) }), set });
    const response = await entryCallback(new NextRequest('https://consulting.leademergence.com/auth/callback/sign-in?code=synthetic'), {
      params: Promise.resolve({ mode: 'sign-in' }),
    });
    expect(response.status).toBe(303);
    expect(response.headers.get('location')).toBe(`https://consulting.leademergence.com/oauth/consent?authorization_id=${authorizationId}`);
    expect(persist).toHaveBeenCalledTimes(1);
    expect(set).toHaveBeenCalledWith('le_entry_sso_consent_return', '', expect.objectContaining({ maxAge: 0 }));
  });

  it('keeps the pending consent destination available after a failed Entry callback', async () => {
    const returnTo = `/oauth/consent?authorization_id=${authorizationId}`;
    const values = new Map([
      ['le_entry_sso_mode_sign-in', 'sign_in'],
      ['le_entry_sso_consent_return', returnTo],
    ]);
    const set = vi.fn();
    cookiesMock.mockResolvedValue({ get: (name: string) => ({ value: values.get(name) }), set });
    const response = await entryCallback(new NextRequest('https://consulting.leademergence.com/auth/callback/sign-in?error=access_denied'), {
      params: Promise.resolve({ mode: 'sign-in' }),
    });
    const destination = new URL(response.headers.get('location')!);
    expect(destination.pathname).toBe('/login');
    expect(destination.searchParams.get('returnTo')).toBe(returnTo);
    expect(set).toHaveBeenCalledWith('le_entry_sso_consent_return', '', expect.objectContaining({ maxAge: 0 }));
    expect(persist).not.toHaveBeenCalled();
  });

  it.each([
    ['fails', { data: { user: null }, error: new Error('Synthetic user lookup failure') }],
    ['returns no user', { data: { user: null }, error: null }],
  ])('clears the exchanged local session before retry when getUser %s', async (_label, result) => {
    const returnTo = `/oauth/consent?authorization_id=${authorizationId}`;
    const values = new Map([
      ['le_entry_sso_mode_sign-in', 'sign_in'],
      ['le_entry_sso_consent_return', returnTo],
    ]);
    cookiesMock.mockResolvedValue({ get: (name: string) => ({ value: values.get(name) }), set: vi.fn() });
    const supabase = client();
    const exchange = vi.fn().mockResolvedValue({ error: null });
    const getUser = vi.fn().mockResolvedValue(result);
    const signOut = vi.fn().mockResolvedValue({ error: null });
    createClient.mockResolvedValue({
      ...supabase,
      auth: { ...supabase.auth, exchangeCodeForSession: exchange, getUser, signOut },
    });

    const response = await entryCallback(new NextRequest('https://consulting.leademergence.com/auth/callback/sign-in?code=synthetic'), {
      params: Promise.resolve({ mode: 'sign-in' }),
    });

    expect(exchange).toHaveBeenCalledExactlyOnceWith('synthetic');
    expect(getUser).toHaveBeenCalledTimes(1);
    expect(signOut).toHaveBeenCalledExactlyOnceWith({ scope: 'local' });
    expect(signOut.mock.invocationCallOrder[0]).toBeGreaterThan(getUser.mock.invocationCallOrder[0]);
    expect(response.status).toBe(303);
    const destination = new URL(response.headers.get('location')!);
    expect(destination.pathname).toBe('/login');
    expect(destination.searchParams.get('error')).toBe(loginErrors.entryUnavailable);
    expect(destination.searchParams.get('returnTo')).toBe(returnTo);
    expect(persist).not.toHaveBeenCalled();
  });

  it.each([
    ['fails', { data: { user: null }, error: new Error('Synthetic user lookup failure') }],
    ['returns no user', { data: { user: null }, error: null }],
  ])('preserves the existing local session when linking getUser %s', async (_label, result) => {
    const values = new Map([['le_entry_sso_mode_link-existing', 'link_existing']]);
    cookiesMock.mockResolvedValue({ get: (name: string) => ({ value: values.get(name) }), set: vi.fn() });
    const supabase = client();
    const exchange = vi.fn().mockResolvedValue({ error: null });
    const getUser = vi.fn().mockResolvedValue(result);
    const signOut = vi.fn().mockResolvedValue({ error: null });
    createClient.mockResolvedValue({
      ...supabase,
      auth: { ...supabase.auth, exchangeCodeForSession: exchange, getUser, signOut },
    });

    const response = await entryCallback(new NextRequest('https://consulting.leademergence.com/auth/callback/link-existing?code=synthetic'), {
      params: Promise.resolve({ mode: 'link-existing' }),
    });

    expect(exchange).toHaveBeenCalledExactlyOnceWith('synthetic');
    expect(getUser).toHaveBeenCalledTimes(1);
    expect(signOut).not.toHaveBeenCalled();
    expect(response.status).toBe(303);
    const destination = new URL(response.headers.get('location')!);
    expect(destination.pathname).toBe('/login');
    expect(destination.searchParams.get('error')).toBe(loginErrors.entryUnavailable);
    expect(destination.searchParams.has('returnTo')).toBe(false);
    expect(persist).not.toHaveBeenCalled();
  });

  it('stores the exact consent return only for the normal Entry sign-in callback', async () => {
    const previousProvider = process.env.ENTRY_OIDC_PROVIDER;
    process.env.ENTRY_OIDC_PROVIDER = 'custom:lead-emergence-entry-dev';
    const set = vi.fn();
    cookiesMock.mockResolvedValue({ set });
    entryStart.mockResolvedValue({ data: { url: 'https://entry.example/authorize' }, error: null });
    try {
      const returnTo = `/oauth/consent?authorization_id=${authorizationId}`;
      const request = new NextRequest(`https://consulting.leademergence.com/auth/entry?returnTo=${encodeURIComponent(returnTo)}`);
      const response = await entryBegin(request);
      expect(response.status).toBe(303);
      expect(set).toHaveBeenCalledWith('le_entry_sso_consent_return', returnTo, expect.objectContaining({ httpOnly: true, maxAge: 600 }));
    } finally {
      if (previousProvider === undefined) delete process.env.ENTRY_OIDC_PROVIDER;
      else process.env.ENTRY_OIDC_PROVIDER = previousProvider;
    }
  });
});
