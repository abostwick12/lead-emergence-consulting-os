import assert from 'node:assert/strict';
import { chromium } from '@playwright/test';
import { createServerClient } from '@supabase/ssr';
import { createClient } from '@supabase/supabase-js';

const PROVIDER = 'custom:lead-emergence-entry-dev';
const CASES = [
  { name: 'ACTIVE', status: 'ACTIVE', expected: 'AUTHORIZED' },
  { name: 'SUSPENDED', status: 'SUSPENDED', expected: 'DENIED' },
  { name: 'REVOKED', status: 'REVOKED', expected: 'DENIED' },
  { name: 'ABSENT', status: null, expected: 'DENIED' },
];

function required(name) {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} is required`);
  return value;
}

const entryUrl = required('ENTRY_DEV_SUPABASE_URL');
const entrySecret = required('ENTRY_DEV_SECRET_KEY');
const entryPublishable = required('ENTRY_DEV_PUBLISHABLE_KEY');
const entryPassword = required('ENTRY_DEV_TEST_PASSWORD');
const oauthClientId = required('ENTRY_OAUTH_CLIENT_ID');
const consultingUrl = required('LOCAL_CONSULTING_SUPABASE_URL');
const consultingSecret = required('LOCAL_CONSULTING_SECRET_KEY');
const consultingPublishable = required('LOCAL_CONSULTING_PUBLISHABLE_KEY');
const entryApp = process.env.ENTRY_APP_ORIGIN?.trim() || 'http://localhost:3000';
const consultingApp = process.env.CONSULTING_APP_ORIGIN?.trim() || 'http://localhost:3400';

const entryAdmin = createClient(entryUrl, entrySecret, {
  auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
});
const consultingAdmin = createClient(consultingUrl, consultingSecret, {
  db: { schema: 'consulting_os' },
  auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
});

async function ensureEntryUser(testCase) {
  const email = `codex-entry-consulting-matrix-${testCase.name.toLowerCase()}@example.test`;
  const listed = await entryAdmin.auth.admin.listUsers({ page: 1, perPage: 1000 });
  if (listed.error) throw listed.error;
  const existing = listed.data.users.find((user) => user.email?.toLowerCase() === email);
  const attributes = {
    email,
    password: entryPassword,
    email_confirm: true,
    user_metadata: { display_name: `SSO matrix ${testCase.name}`, synthetic_test: true, synthetic_test_purpose: 'entry_consulting_entitlement_matrix' },
  };
  const result = existing
    ? await entryAdmin.auth.admin.updateUserById(existing.id, attributes)
    : await entryAdmin.auth.admin.createUser(attributes);
  if (result.error || !result.data.user) throw result.error ?? new Error(`Entry ${testCase.name} user unavailable`);
  if (testCase.status) {
    const entitlement = await entryAdmin.rpc('set_entry_product_entitlement', {
      p_canonical_user_id: result.data.user.id,
      p_product: 'CONSULTING',
      p_status: testCase.status,
      p_source: 'synthetic_entitlement_matrix',
      p_display_name: attributes.user_metadata.display_name,
    });
    if (entitlement.error) throw entitlement.error;
  }
  return { id: result.data.user.id, email };
}

async function revokeExistingGrant(email) {
  const entry = createClient(entryUrl, entryPublishable, {
    auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
  });
  const signedIn = await entry.auth.signInWithPassword({ email, password: entryPassword });
  if (signedIn.error) throw signedIn.error;
  const grants = await entry.auth.oauth.listGrants();
  if (grants.error) throw grants.error;
  for (const grant of grants.data.filter((item) => item.client.id === oauthClientId)) {
    const revoked = await entry.auth.oauth.revokeGrant({ clientId: grant.client.id });
    if (revoked.error) throw revoked.error;
  }
  await entry.auth.signOut({ scope: 'local' });
}

async function consultingSession(context) {
  const browserCookies = await context.cookies();
  const client = createServerClient(consultingUrl, consultingPublishable, {
    db: { schema: 'consulting_os' },
    cookies: {
      getAll() { return browserCookies.map(({ name, value }) => ({ name, value })); },
      setAll() { /* Read-only acceptance client. */ },
    },
  });
  const session = await client.auth.getSession();
  if (session.error) throw session.error;
  return session.data.session;
}

async function countProviderUsers(canonicalUserId) {
  const users = await consultingAdmin.auth.admin.listUsers({ page: 1, perPage: 1000 });
  if (users.error) throw users.error;
  const hydrated = await Promise.all(users.data.users.map(async (user) => {
    const result = await consultingAdmin.auth.admin.getUserById(user.id);
    if (result.error) throw result.error;
    return result.data.user;
  }));
  return hydrated.filter((user) => (user.identities ?? []).some(
    (identity) => identity.provider === PROVIDER && identity.id === canonicalUserId,
  )).length;
}

const users = new Map();
for (const testCase of CASES) {
  const user = await ensureEntryUser(testCase);
  users.set(testCase.name, user);
  await revokeExistingGrant(user.email);
}

const browser = await chromium.launch({
  headless: true,
  args: [
    '--host-resolver-rules=MAP localhost [::1]',
    '--disable-features=BlockInsecurePrivateNetworkRequests,PrivateNetworkAccessChecks,LocalNetworkAccessChecks',
  ],
});
const results = [];
try {
  for (const testCase of CASES) {
    const user = users.get(testCase.name);
    const context = await browser.newContext({ viewport: { width: 1280, height: 900 } });
    const page = await context.newPage();
    const errors = [];
    page.on('pageerror', (error) => errors.push(error.message));
    page.on('console', (message) => {
      if (message.type() === 'error' && !message.text().includes('fonts.googleapis.com')) errors.push(message.text());
    });
    const providerUsersBefore = await countProviderUsers(user.id);

    await page.goto(`${entryApp}/login`, { waitUntil: 'networkidle' });
    await page.getByLabel('Email').fill(user.email);
    await page.getByLabel('Password').fill(entryPassword);
    await Promise.all([
      page.waitForURL('**/workspaces', { timeout: 30_000 }),
      page.getByRole('button', { name: 'Sign in' }).click(),
    ]);
    await page.goto(`${consultingApp}/auth/entry`);
    await page.waitForURL((url) =>
      (url.hostname === 'localhost' && url.port === '3000' && url.pathname === '/oauth/consent')
      || (url.hostname === 'localhost' && url.port === '3400' && url.pathname === '/login'),
    { timeout: 60_000 });
    assert.equal(new URL(page.url()).pathname, '/oauth/consent', `${testCase.name} did not reach the real Entry consent decision`);

    if (testCase.expected === 'AUTHORIZED') {
      await page.getByRole('button', { name: 'Continue' }).click();
      await page.waitForURL(`${consultingApp}/consulting-context?entry=connected`, { timeout: 60_000 });
      await page.getByRole('heading', { name: 'No active Consulting workspace' }).waitFor();
      assert(await consultingSession(context), 'ACTIVE did not create a normal Consulting Supabase session');
    } else {
      await page.getByRole('alert').filter({ hasText: 'Consulting is not currently available' }).waitFor();
      await page.getByRole('button', { name: 'Return' }).click();
      await page.waitForURL((url) => url.hostname === 'localhost' && url.port === '3400' && url.pathname === '/login' && url.searchParams.has('error'), { timeout: 60_000 });
      await page.getByRole('alert').filter({ hasText: 'Lead Emergence access was not approved' }).waitFor();
      assert.equal(await consultingSession(context), null, `${testCase.name} created a Consulting session`);
    }

    const providerUsersAfter = await countProviderUsers(user.id);
    if (testCase.expected === 'AUTHORIZED') assert.equal(providerUsersAfter, 1);
    else assert.equal(providerUsersAfter, providerUsersBefore, `${testCase.name} created a Consulting Auth identity`);
    assert.deepEqual(errors, []);
    results.push({
      entitlement: testCase.name,
      oauthDecisionReached: true,
      consultingSession: testCase.expected === 'AUTHORIZED',
      consultingIdentityDelta: providerUsersAfter - providerUsersBefore,
      result: testCase.expected,
    });
    await context.close();
  }

  // A remembered OAuth grant must not bypass Entry's current entitlement. The
  // ACTIVE case above created the grant; revoke the entitlement without
  // revoking that grant, then exercise the provider again in a clean browser.
  const rememberedUser = users.get('ACTIVE');
  const revokeRemembered = await entryAdmin.rpc('set_entry_product_entitlement', {
    p_canonical_user_id: rememberedUser.id,
    p_product: 'CONSULTING',
    p_status: 'REVOKED',
    p_source: 'synthetic_remembered_grant_recheck',
    p_display_name: 'SSO matrix ACTIVE',
  });
  if (revokeRemembered.error) throw revokeRemembered.error;
  const rememberedContext = await browser.newContext({ viewport: { width: 1280, height: 900 } });
  try {
    const page = await rememberedContext.newPage();
    await page.goto(`${entryApp}/login`, { waitUntil: 'networkidle' });
    await page.getByLabel('Email').fill(rememberedUser.email);
    await page.getByLabel('Password').fill(entryPassword);
    await Promise.all([
      page.waitForURL('**/workspaces', { timeout: 30_000 }),
      page.getByRole('button', { name: 'Sign in' }).click(),
    ]);
    await page.goto(`${consultingApp}/auth/entry`);
    await page.waitForURL((url) => url.hostname === 'localhost' && url.port === '3000' && url.pathname === '/oauth/consent', { timeout: 60_000 });
    await page.getByRole('heading', { name: 'Consulting is unavailable' }).waitFor();
    assert.equal(await consultingSession(rememberedContext), null, 'Remembered grant bypassed revoked Entry entitlement');
    results.push({
      entitlement: 'REVOKED_WITH_REMEMBERED_GRANT',
      oauthDecisionReached: true,
      consultingSession: false,
      consultingIdentityDelta: 0,
      result: 'DENIED',
    });
  } finally {
    await rememberedContext.close();
    const restoreRemembered = await entryAdmin.rpc('set_entry_product_entitlement', {
      p_canonical_user_id: rememberedUser.id,
      p_product: 'CONSULTING',
      p_status: 'ACTIVE',
      p_source: 'synthetic_entitlement_matrix_restore',
      p_display_name: 'SSO matrix ACTIVE',
    });
    if (restoreRemembered.error) throw restoreRemembered.error;
  }
  console.log(JSON.stringify({ status: 'PASS', matrix: results }));
} finally {
  await browser.close();
}
