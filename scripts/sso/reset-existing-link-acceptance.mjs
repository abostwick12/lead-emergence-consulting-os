import { createClient } from '@supabase/supabase-js';

const PROVIDER = 'custom:lead-emergence-entry-dev';
const PERSON_ID = 'd2000000-0000-4000-8000-000000000002';

function required(name) {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} is required`);
  return value;
}

const entryEmail = required('ENTRY_DEV_TEST_EMAIL').toLowerCase();
const consultingEmail = required('LOCAL_CONSULTING_TEST_EMAIL').toLowerCase();
if (!entryEmail.endsWith('.test') || !consultingEmail.endsWith('.test')) {
  throw new Error('Acceptance reset is restricted to reserved .test users');
}

const canonicalUserId = required('ENTRY_DEV_TEST_USER_ID');
const oauthClientId = required('ENTRY_OAUTH_CLIENT_ID');
const entry = createClient(required('ENTRY_DEV_SUPABASE_URL'), required('ENTRY_DEV_PUBLISHABLE_KEY'), {
  auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
});
const entrySignIn = await entry.auth.signInWithPassword({
  email: entryEmail,
  password: required('ENTRY_DEV_TEST_PASSWORD'),
});
if (entrySignIn.error) throw entrySignIn.error;
const grants = await entry.auth.oauth.listGrants();
if (grants.error) throw grants.error;
const matchingGrants = grants.data.filter((grant) => grant.client.id === oauthClientId);
for (const grant of matchingGrants) {
  const revoked = await entry.auth.oauth.revokeGrant({ clientId: grant.client.id });
  if (revoked.error) throw revoked.error;
}
await entry.auth.signOut({ scope: 'local' });

const consultingUrl = required('LOCAL_CONSULTING_SUPABASE_URL');
const consulting = createClient(consultingUrl, required('LOCAL_CONSULTING_PUBLISHABLE_KEY'), {
  auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
});
const consultingSignIn = await consulting.auth.signInWithPassword({
  email: consultingEmail,
  password: required('LOCAL_CONSULTING_TEST_PASSWORD'),
});
if (consultingSignIn.error) throw consultingSignIn.error;
const identities = await consulting.auth.getUserIdentities();
if (identities.error) throw identities.error;
const providerIdentities = identities.data.identities.filter((identity) => identity.provider === PROVIDER);
for (const identity of providerIdentities) {
  const unlinked = await consulting.auth.unlinkIdentity(identity);
  if (unlinked.error) throw unlinked.error;
}
await consulting.auth.signOut({ scope: 'local' });

const admin = createClient(consultingUrl, required('LOCAL_CONSULTING_SECRET_KEY'), {
  db: { schema: 'consulting_os' },
  auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
});
const pendingLink = await admin
  .from('canonical_identity_links')
  .update({
    canonical_user_id: canonicalUserId,
    status: 'PENDING_VERIFICATION',
    proof_type: 'FUTURE_ENTRY_HANDOFF',
    auth_user_id: null,
    provider_identifier: null,
    provider_subject: null,
    provider_identity_id: null,
    linked_at: null,
    revoked_at: null,
  }, { count: 'exact' })
  .eq('person_id', PERSON_ID);
if (pendingLink.error) throw pendingLink.error;

console.log(JSON.stringify({
  status: 'RESET',
  entryOAuthGrantsRevoked: matchingGrants.length,
  consultingProviderIdentitiesUnlinked: providerIdentities.length,
  consultingCanonicalLinksPrepared: pendingLink.count ?? 0,
}));
