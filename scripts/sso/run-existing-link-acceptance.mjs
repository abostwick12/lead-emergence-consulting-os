import assert from 'node:assert/strict';
import { chromium } from '@playwright/test';
import { createClient } from '@supabase/supabase-js';
import { createServerClient } from '@supabase/ssr';
import { execFileSync } from 'node:child_process';

const PROVIDER = 'custom:lead-emergence-entry-dev';
const PERSON_ID = 'd2000000-0000-4000-8000-000000000002';
const ORGANIZATION_ID = 'd3000000-0000-4000-8000-000000000002';
const ENGAGEMENT_ID = 'd4000000-0000-4000-8000-000000000002';
const MEMBERSHIP_ID = 'd5000000-0000-4000-8000-000000000002';
const WRONG_ORGANIZATION_ID = 'd3000000-0000-4000-8000-000000000003';
const WRONG_ENGAGEMENT_ID = 'd4000000-0000-4000-8000-000000000003';
const PRIVATE_MEETING_ID = 'd8000000-0000-4000-8000-000000000002';
const PRIVATE_NOTE_ID = 'd9000000-0000-4000-8000-000000000002';

function required(name) {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} is required`);
  return value;
}

const canonicalUserId = required('ENTRY_DEV_TEST_USER_ID');
const consultingUrl = required('LOCAL_CONSULTING_SUPABASE_URL');
const consultingSecret = required('LOCAL_CONSULTING_SECRET_KEY');
const evidenceDirectory = process.env.SSO_EVIDENCE_DIRECTORY?.trim() || 'test-results';
const admin = createClient(consultingUrl, consultingSecret, {
  db: { schema: 'consulting_os' },
  auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
});

async function countRows(table, column, value) {
  const result = await admin.from(table).select('id', { count: 'exact', head: true }).eq(column, value);
  if (result.error) throw result.error;
  return result.count;
}

const membershipsBefore = await countRows('organization_memberships', 'person_id', PERSON_ID);
const assignmentsBefore = await countRows('consultant_assignments', 'consultant_person_id', PERSON_ID);
assert.equal(membershipsBefore, 1, 'Existing synthetic client membership is missing');
assert.equal(assignmentsBefore, 0, 'Synthetic client unexpectedly has a consultant assignment');

const browser = await chromium.launch({
  headless: true,
  args: [
    '--host-resolver-rules=MAP localhost [::1]',
    '--disable-features=BlockInsecurePrivateNetworkRequests,PrivateNetworkAccessChecks,LocalNetworkAccessChecks',
  ],
});

function trackErrors(page) {
  const errors = [];
  page.on('console', (message) => {
    if (message.type() === 'error' && !message.text().includes('fonts.googleapis.com')) errors.push(`console:${message.text()}`);
  });
  page.on('pageerror', (error) => errors.push(`page:${error.message}`));
  page.on('requestfailed', (request) => {
    if (!request.url().includes('fonts.googleapis.com')) errors.push(`request:${request.url()} ${request.failure()?.errorText ?? 'failed'}`);
  });
  return errors;
}

async function assertHealthy(page) {
  assert((await page.locator('body').innerText()).trim().length > 0, 'Page body is blank');
  assert.equal(await page.locator('[data-nextjs-dialog],.vite-error-overlay,#webpack-dev-server-client-overlay').count(), 0);
}

async function signIntoEntry(page) {
  await page.getByLabel('Email').fill(required('ENTRY_DEV_TEST_EMAIL'));
  await page.getByLabel('Password').fill(required('ENTRY_DEV_TEST_PASSWORD'));
  await page.getByRole('button', { name: 'Sign in' }).click();
}

async function openClientContext(page) {
  await page.getByRole('link', { name: 'Client work' }).click();
  await page.waitForURL('**/client', { timeout: 30_000 });
  await assertHealthy(page);
  assert.equal(await page.getByTestId('current-organization').innerText(), 'Synthetic Acceptance Organization');
  assert.equal(await page.getByTestId('current-engagement').innerText(), 'Synthetic Acceptance Engagement');
}

async function browserSessionClient(context) {
  const browserCookies = await context.cookies();
  return createServerClient(consultingUrl, required('LOCAL_CONSULTING_PUBLISHABLE_KEY'), {
    db: { schema: 'consulting_os' },
    cookies: {
      getAll() { return browserCookies.map(({ name, value }) => ({ name, value })); },
      setAll() { /* Read-only acceptance client. */ },
    },
  });
}

function localPrivateNoteCount() {
  const dbContainer = process.env.LOCAL_CONSULTING_DB_CONTAINER?.trim() || 'supabase_db_consulting-os-phase1';
  const result = execFileSync('docker', [
    'exec', dbContainer, 'psql', '-U', 'postgres', '-d', 'postgres', '-tAc',
    `select count(*) from consulting_private.meeting_notes where id='${PRIVATE_NOTE_ID}' and content='SYNTHETIC_PRIVATE_NOTE_MUST_NOT_REACH_CLIENT';`,
  ], { encoding: 'utf8' });
  return Number(result.trim());
}

let setupErrors = [];
let oneLoginErrors = [];
let consentDiagnostics = {};
const setupNavigationTrace = [];
const setupDocumentTrace = [];
try {
  const setupContext = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
  const setupPage = await setupContext.newPage();
  setupPage.on('framenavigated', (frame) => {
    if (frame === setupPage.mainFrame()) setupNavigationTrace.push(frame.url());
  });
  setupPage.on('response', (response) => {
    if (response.request().resourceType() === 'document') {
      setupDocumentTrace.push({
        url: response.url(),
        status: response.status(),
        location: response.headers().location ?? null,
      });
    }
  });
  setupErrors = trackErrors(setupPage);
  await setupPage.goto('http://localhost:3400/login?legacy=1&returnTo=%2Fconsulting-context', { waitUntil: 'networkidle' });
  await setupPage.getByLabel('Email').fill(required('LOCAL_CONSULTING_TEST_EMAIL'));
  await setupPage.getByLabel('Password').fill(required('LOCAL_CONSULTING_TEST_PASSWORD'));
  await Promise.all([
    setupPage.waitForURL('**/consulting-context', { timeout: 30_000 }),
    setupPage.getByRole('button', { name: 'Legacy Consulting sign in' }).click(),
  ]);
  await setupPage.getByRole('heading', { name: 'Choose how you are working.' }).waitFor();
  await setupPage.goto('http://localhost:3400/auth/entry/link');
  await setupPage.waitForURL((url) =>
    url.hostname === 'localhost' && url.port === '3000' && ['/login', '/oauth/consent'].includes(url.pathname),
  { timeout: 60_000 });
  if (new URL(setupPage.url()).pathname === '/login') {
    await signIntoEntry(setupPage);
    await setupPage.waitForURL('**/oauth/consent?authorization_id=*', { timeout: 30_000 });
  }
  await setupPage.getByText('Requested identity sharing: openid, profile').waitFor();
  consentDiagnostics = await setupPage.evaluate(() => {
    const form = document.querySelector('form[action="/api/oauth/decision"]');
    return {
      url: window.location.href,
      origin: window.location.origin,
      formAction: form instanceof HTMLFormElement ? form.action : null,
      csp: document.querySelector('meta[http-equiv="Content-Security-Policy"]')?.getAttribute('content') ?? null,
    };
  });
  await setupPage.screenshot({ path: `${evidenceDirectory}/entry-consulting-existing-link-consent.png`, fullPage: true });
  await setupPage.getByRole('button', { name: 'Continue' }).click();
  await setupPage.waitForURL('http://localhost:3400/consulting-context?entry=connected', { timeout: 60_000 });
  await setupPage.getByRole('heading', { name: 'Choose how you are working.' }).waitFor();
  await openClientContext(setupPage);
  await setupPage.screenshot({ path: `${evidenceDirectory}/entry-consulting-existing-link.png`, fullPage: true });
  await setupContext.close();

  const oneLoginContext = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
  const oneLoginPage = await oneLoginContext.newPage();
  oneLoginErrors = trackErrors(oneLoginPage);
  await oneLoginPage.goto('http://localhost:3000/login', { waitUntil: 'networkidle' });
  await signIntoEntry(oneLoginPage);
  await oneLoginPage.waitForURL('**/workspaces', { timeout: 30_000 });
  await Promise.all([
    oneLoginPage.waitForURL((url) =>
      url.hostname === 'localhost' && url.port === '3400' && url.pathname === '/consulting-context',
    { timeout: 60_000 }),
    oneLoginPage.getByRole('link', { name: /Open Consulting/i }).click(),
  ]);
  await oneLoginPage.getByRole('heading', { name: 'Choose how you are working.' }).waitFor();
  await openClientContext(oneLoginPage);
  await oneLoginPage.screenshot({ path: `${evidenceDirectory}/entry-consulting-existing-one-login.png`, fullPage: true });

  // A. The OAuth-created session resolves the active local client membership.
  assert.equal(await oneLoginPage.getByTestId('current-organization').innerText(), 'Synthetic Acceptance Organization');

  // D. The same browser session cannot substitute an unrelated organization.
  const wrongTenant = await oneLoginPage.request.get(
    `http://localhost:3400/api/portal-context?surface=client&organizationId=${WRONG_ORGANIZATION_ID}&engagementId=${WRONG_ENGAGEMENT_ID}&returnTo=%2Fclient`,
    { maxRedirects: 0 },
  );
  assert.equal(wrongTenant.status(), 404, 'OAuth client session selected an unauthorized organization');

  // E. Query the normal Data API with the OAuth-created user session, never
  // service_role, and prove the seeded consultant-private note is withheld.
  const sessionClient = await browserSessionClient(oneLoginContext);
  const verifiedUser = await sessionClient.auth.getUser();
  if (verifiedUser.error || !verifiedUser.data.user) throw verifiedUser.error ?? new Error('OAuth-created Consulting user session is missing');
  const privateNotes = await sessionClient.rpc('private_meeting_notes_for_meeting', { p_meeting_id: PRIVATE_MEETING_ID });
  if (privateNotes.error) throw privateNotes.error;
  assert.equal(privateNotes.data.length, 0, 'Client session received consultant-private meeting material');
  assert.equal(localPrivateNoteCount(), 1, 'Synthetic consultant-private control note is missing');

  // C. Local revocation remains authoritative even while both product identity
  // and the Consulting Auth session are still valid.
  const removed = await admin.from('organization_memberships').update({ status: 'REMOVED' }, { count: 'exact' }).eq('id', MEMBERSHIP_ID);
  if (removed.error) throw removed.error;
  assert.equal(removed.count, 1);
  try {
    await oneLoginPage.goto('http://localhost:3400/consulting-context', { waitUntil: 'networkidle' });
    await oneLoginPage.getByRole('heading', { name: 'No active Consulting workspace' }).waitFor();
  } finally {
    const restored = await admin.from('organization_memberships').update({ status: 'ACTIVE' }, { count: 'exact' }).eq('id', MEMBERSHIP_ID);
    if (restored.error) throw restored.error;
    assert.equal(restored.count, 1);
  }

  // Consulting logout clears only the Consulting session. The still-valid
  // Entry session can immediately reauthorize without another password prompt.
  const signedOut = await oneLoginPage.request.post('http://localhost:3400/auth/sign-out', { maxRedirects: 0 });
  assert.equal(signedOut.status(), 303);
  const signedOutClient = await browserSessionClient(oneLoginContext);
  const signedOutSession = await signedOutClient.auth.getSession();
  if (signedOutSession.error) throw signedOutSession.error;
  assert.equal(signedOutSession.data.session, null, 'Consulting logout left a local session active');
  await oneLoginPage.goto('http://localhost:3000/workspaces', { waitUntil: 'networkidle' });
  await Promise.all([
    oneLoginPage.waitForURL((url) => url.hostname === 'localhost' && url.port === '3400' && url.pathname === '/consulting-context', { timeout: 60_000 }),
    oneLoginPage.getByRole('link', { name: /Open Consulting/i }).click(),
  ]);
  await oneLoginPage.getByRole('heading', { name: 'Choose how you are working.' }).waitFor();
  await oneLoginContext.close();

  const links = await admin.from('canonical_identity_links')
    .select('id,person_id,auth_user_id,canonical_user_id,status,provider_identifier,provider_subject')
    .eq('canonical_user_id', canonicalUserId);
  if (links.error) throw links.error;
  assert.equal(links.data.length, 1);
  const link = links.data[0];
  assert.equal(link.person_id, PERSON_ID);
  assert.equal(link.status, 'LINKED');
  assert.equal(link.provider_identifier, PROVIDER);
  assert.equal(link.provider_subject, canonicalUserId);

  const user = await admin.auth.admin.getUserById(link.auth_user_id);
  if (user.error) throw user.error;
  assert(user.data.user.identities?.some((identity) => identity.provider === PROVIDER && identity.id === canonicalUserId));
  const membershipsAfter = await countRows('organization_memberships', 'person_id', PERSON_ID);
  const assignmentsAfter = await countRows('consultant_assignments', 'consultant_person_id', PERSON_ID);
  assert.equal(membershipsAfter, membershipsBefore);
  assert.equal(assignmentsAfter, assignmentsBefore);
  assert.deepEqual(setupErrors, []);
  assert.deepEqual(oneLoginErrors, []);

  console.log(JSON.stringify({
    status: 'PASS',
    explicitExistingAccountLink: true,
    cleanBrowserEntryLogins: 1,
    consultingLegacyLoginsInCleanBrowser: 0,
    provider: PROVIDER,
    canonicalUserId,
    consultingAuthUserId: link.auth_user_id,
    personId: link.person_id,
    organizationId: ORGANIZATION_ID,
    engagementId: ENGAGEMENT_ID,
    organizationMembershipsBefore: membershipsBefore,
    organizationMembershipsAfter: membershipsAfter,
    consultantAssignmentsBefore: assignmentsBefore,
    consultantAssignmentsAfter: assignmentsAfter,
    authorizationMatrix: {
      activeMembership: 'AUTHORIZED',
      removedMembership: 'NO_WORKSPACE',
      wrongTenant: 'DENIED_404',
      clientConsultantPrivate: 'DENIED_EMPTY',
    },
    consultingLogout: 'SESSION_CLEARED',
    entrySessionAfterConsultingLogout: 'REAUTHORIZED_WITHOUT_PASSWORD',
    setupErrors,
    oneLoginErrors,
  }));
} catch (error) {
  console.error(JSON.stringify({ status: 'FAIL', setupErrors, oneLoginErrors, consentDiagnostics, setupNavigationTrace, setupDocumentTrace }));
  throw error;
} finally {
  await browser.close();
}
