import assert from 'node:assert/strict';
import { chromium } from '@playwright/test';
import { createClient } from '@supabase/supabase-js';

const PROVIDER = 'custom:lead-emergence-entry-dev';

function required(name) {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} is required`);
  return value;
}

const expectedCanonicalUserId = required('ENTRY_DEV_TEST_USER_ID');
const consultingUrl = required('LOCAL_CONSULTING_SUPABASE_URL');
const consultingSecret = required('LOCAL_CONSULTING_SECRET_KEY');
const evidenceDirectory = process.env.SSO_EVIDENCE_DIRECTORY?.trim() || 'test-results';
const browser = await chromium.launch({
  headless: true,
  args: [
    '--host-resolver-rules=MAP localhost [::1]',
    // Hosted Entry redirects to loopback-only Consulting during this acceptance
    // run. Production-to-production remains HTTPS and does not need this flag.
    '--disable-features=BlockInsecurePrivateNetworkRequests,PrivateNetworkAccessChecks,LocalNetworkAccessChecks',
  ],
});
const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
const page = await context.newPage();
const browserErrors = [];
page.on('console', (message) => {
  if (message.type() === 'error' && !message.text().includes('fonts.googleapis.com')) {
    browserErrors.push(`console:${message.text()}`);
  }
});
page.on('pageerror', (error) => browserErrors.push(`page:${error.message}`));
page.on('requestfailed', (request) => {
  if (!request.url().includes('fonts.googleapis.com')) {
    browserErrors.push(`request:${request.url()} ${request.failure()?.errorText ?? 'failed'}`);
  }
});

async function assertHealthyPage() {
  assert((await page.locator('body').innerText()).trim().length > 0, 'Page body is blank');
  assert.equal(
    await page.locator('[data-nextjs-dialog],.vite-error-overlay,#webpack-dev-server-client-overlay').count(),
    0,
    'Framework error overlay is visible',
  );
}

async function continueFromEntry() {
  await page.goto('http://localhost:3000/workspaces', { waitUntil: 'networkidle' });
  await assertHealthyPage();
  await Promise.all([
    page.waitForURL((url) =>
      (url.hostname === 'localhost' && url.port === '3000' && url.pathname === '/oauth/consent')
      || (url.hostname === 'localhost' && url.port === '3400' && url.pathname === '/consulting-context'),
    { timeout: 60_000 }),
    page.getByRole('link', { name: /Open Consulting/i }).click(),
  ]);
  const consentShown = new URL(page.url()).pathname === '/oauth/consent';
  if (consentShown) {
    await assertHealthyPage();
    await page.getByText('Requested identity sharing: openid, profile').waitFor();
    await page.screenshot({ path: `${evidenceDirectory}/entry-consulting-consent.png`, fullPage: true });
    await page.getByRole('button', { name: 'Continue' }).click();
    await page.waitForURL('http://localhost:3400/consulting-context?entry=connected', { timeout: 60_000 });
  }
  await page.waitForLoadState('networkidle');
  await assertHealthyPage();
  await page.getByRole('heading', { name: 'No active Consulting workspace' }).waitFor();
  return consentShown;
}

try {
  await page.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
  await assertHealthyPage();
  await page.getByLabel('Email').fill(required('ENTRY_DEV_TEST_EMAIL'));
  await page.getByLabel('Password').fill(required('ENTRY_DEV_TEST_PASSWORD'));
  await Promise.all([
    page.waitForURL('**/workspaces', { timeout: 30_000 }),
    page.getByRole('button', { name: 'Sign in' }).click(),
  ]);
  await page.getByRole('link', { name: /Open Consulting/i }).waitFor();

  const firstConsentShown = await continueFromEntry();
  await page.screenshot({ path: `${evidenceDirectory}/entry-consulting-sso-first.png`, fullPage: true });
  const repeatConsentShown = await continueFromEntry();
  await page.screenshot({ path: `${evidenceDirectory}/entry-consulting-sso-repeat.png`, fullPage: true });
  if (process.env.SSO_REQUIRE_FIRST_CONSENT === 'true') {
    assert.equal(firstConsentShown, true, 'First authorization did not display Entry consent');
    assert.equal(repeatConsentShown, false, 'Previously approved authorization displayed consent again');
  }

  const admin = createClient(consultingUrl, consultingSecret, {
    db: { schema: 'consulting_os' },
    auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
  });
  const users = await admin.auth.admin.listUsers({ page: 1, perPage: 1000 });
  if (users.error) throw users.error;
  const providerCandidates = users.data.users.filter((user) =>
    user.app_metadata?.provider === PROVIDER || user.app_metadata?.providers?.includes(PROVIDER),
  );
  const hydratedUsers = await Promise.all(providerCandidates.map(async (user) => {
    const hydrated = await admin.auth.admin.getUserById(user.id);
    if (hydrated.error) throw hydrated.error;
    return hydrated.data.user;
  }));
  const matchingUsers = hydratedUsers.filter((user) =>
    (user.identities ?? []).some(
      (identity) => identity.provider === PROVIDER && identity.id === expectedCanonicalUserId,
    ),
  );
  assert.equal(matchingUsers.length, 1, 'Expected exactly one Consulting Auth user for the Entry subject');
  const consultingAuthUser = matchingUsers[0];

  const links = await admin
    .from('canonical_identity_links')
    .select('id,person_id,auth_user_id,canonical_user_id,status,provider_identifier,provider_subject,provider_identity_id')
    .eq('canonical_user_id', expectedCanonicalUserId);
  if (links.error) throw links.error;
  assert.equal(links.data.length, 1, 'Expected exactly one durable canonical identity link');
  const link = links.data[0];
  assert.equal(link.auth_user_id, consultingAuthUser.id);
  assert.equal(link.status, 'LINKED');
  assert.equal(link.provider_identifier, PROVIDER);
  assert.equal(link.provider_subject, expectedCanonicalUserId);

  const [memberships, assignments, audits] = await Promise.all([
    admin.from('organization_memberships').select('id', { count: 'exact', head: true }).eq('person_id', link.person_id),
    admin.from('consultant_assignments').select('id', { count: 'exact', head: true }).eq('consultant_person_id', link.person_id),
    admin.from('audit_events').select('event_type').eq('target_id', link.id).in('event_type', [
      'ENTRY_IDENTITY_LINK_CREATED',
      'ENTRY_SSO_IDENTITY_VERIFIED',
    ]),
  ]);
  if (memberships.error) throw memberships.error;
  if (assignments.error) throw assignments.error;
  if (audits.error) throw audits.error;
  assert.equal(memberships.count, 0, 'SSO created an organization membership');
  assert.equal(assignments.count, 0, 'SSO created a consultant assignment');
  const auditCounts = audits.data.reduce((counts, event) => {
    counts[event.event_type] = (counts[event.event_type] ?? 0) + 1;
    return counts;
  }, {});
  assert.equal(auditCounts.ENTRY_IDENTITY_LINK_CREATED, 1, 'The durable link was created more than once');
  assert((auditCounts.ENTRY_SSO_IDENTITY_VERIFIED ?? 0) >= 1, 'Repeat SSO verification was not audited');
  assert.deepEqual(browserErrors, []);

  console.log(JSON.stringify({
    status: 'PASS',
    entryLogins: 1,
    consultingArrivals: 2,
    firstConsentShown,
    repeatConsentShown,
    provider: PROVIDER,
    canonicalUserId: expectedCanonicalUserId,
    consultingAuthUserId: consultingAuthUser.id,
    personId: link.person_id,
    durableLinks: links.data.length,
    organizationMembershipsCreated: memberships.count,
    consultantAssignmentsCreated: assignments.count,
    auditCounts,
    browserErrors,
  }));
} catch (error) {
  await page.screenshot({ path: `${evidenceDirectory}/entry-consulting-sso-failure.png`, fullPage: true }).catch(() => {});
  console.error(JSON.stringify({
    status: 'FAIL',
    url: page.url(),
    body: await page.locator('body').innerText().catch(() => ''),
    browserErrors,
  }));
  throw error;
} finally {
  await browser.close();
}
