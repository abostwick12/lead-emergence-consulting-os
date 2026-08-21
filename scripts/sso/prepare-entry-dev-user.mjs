import { createClient } from '@supabase/supabase-js';

function required(name) {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} is required`);
  return value;
}

const email = required('ENTRY_DEV_TEST_EMAIL').toLowerCase();
if (!email.endsWith('.test')) throw new Error('Synthetic Entry user email must use the reserved .test domain');

const admin = createClient(required('ENTRY_DEV_SUPABASE_URL'), required('ENTRY_DEV_SECRET_KEY'), {
  auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
});
const listed = await admin.auth.admin.listUsers({ page: 1, perPage: 1000 });
if (listed.error) throw listed.error;
const existing = listed.data.users.find((user) => user.email?.toLowerCase() === email);
const attributes = {
  email,
  password: required('ENTRY_DEV_TEST_PASSWORD'),
  email_confirm: true,
  user_metadata: {
    display_name: 'Entry to Consulting acceptance user',
    synthetic_test: true,
    synthetic_test_purpose: 'entry_consulting_sso',
  },
};
const result = existing
  ? await admin.auth.admin.updateUserById(existing.id, attributes)
  : await admin.auth.admin.createUser(attributes);
if (result.error || !result.data.user) throw result.error ?? new Error('Synthetic Entry user unavailable');

const entitlement = await admin.rpc('set_entry_product_entitlement', {
  p_canonical_user_id: result.data.user.id,
  p_product: 'CONSULTING',
  p_status: 'ACTIVE',
  p_source: 'synthetic_sso_acceptance',
  p_display_name: 'Entry to Consulting acceptance user',
});
if (entitlement.error) throw entitlement.error;

console.log(JSON.stringify({ userId: result.data.user.id, created: !existing, entitled: true }));
