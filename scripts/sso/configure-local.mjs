import { createClient } from '@supabase/supabase-js';

const PROVIDER_IDENTIFIER = 'custom:lead-emergence-entry-dev';
const CLIENT_NAME = 'Lead Emergence Consulting OS (local)';

function required(name) {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} is required`);
  return value;
}

function adminClient(url, secretKey) {
  return createClient(url, secretKey, {
    auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
  });
}

function assertLocalHttpUrl(value, name) {
  const url = new URL(value);
  if (url.protocol !== 'http:' || !['127.0.0.1', 'localhost'].includes(url.hostname)) {
    throw new Error(`${name} must be a loopback HTTP URL`);
  }
  return url.origin;
}

const entryAdminUrl = required('LOCAL_ENTRY_ADMIN_URL');
const entryIssuer = required('LOCAL_ENTRY_ISSUER');
const consultingAdminUrl = assertLocalHttpUrl(required('LOCAL_CONSULTING_ADMIN_URL'), 'LOCAL_CONSULTING_ADMIN_URL');
const consultingAppOrigin = assertLocalHttpUrl(required('LOCAL_CONSULTING_APP_ORIGIN'), 'LOCAL_CONSULTING_APP_ORIGIN');
const callbackUrl = `${consultingAdminUrl}/auth/v1/callback`;

const entry = adminClient(entryAdminUrl, required('LOCAL_ENTRY_SECRET_KEY'));
const consulting = adminClient(consultingAdminUrl, required('LOCAL_CONSULTING_SECRET_KEY'));

const listedClients = await entry.auth.admin.oauth.listClients({ page: 1, perPage: 100 });
if (listedClients.error) throw listedClients.error;
// Auth versions have returned either { clients: [...] } or an array-shaped object here.
const oauthClients = Array.isArray(listedClients.data.clients)
  ? listedClients.data.clients
  : Object.values(listedClients.data).filter(
      (value) => value && typeof value === 'object' && 'client_id' in value,
    );
let existingClient = oauthClients.find((client) => client.client_name === CLIENT_NAME);
if (existingClient && process.env.RESET_ENTRY_OAUTH_CLIENT === 'true') {
  const removed = await entry.auth.admin.oauth.deleteClient(existingClient.client_id);
  if (removed.error) throw removed.error;
  existingClient = undefined;
}

let oauthClient;
if (existingClient) {
  const updated = await entry.auth.admin.oauth.updateClient(existingClient.client_id, {
    client_name: CLIENT_NAME,
    client_uri: consultingAppOrigin,
    redirect_uris: [callbackUrl],
    grant_types: ['authorization_code', 'refresh_token'],
    token_endpoint_auth_method: 'client_secret_basic',
  });
  if (updated.error) throw updated.error;
  const rotated = await entry.auth.admin.oauth.regenerateClientSecret(existingClient.client_id);
  if (rotated.error) throw rotated.error;
  oauthClient = rotated.data;
} else {
  const created = await entry.auth.admin.oauth.createClient({
    client_name: CLIENT_NAME,
    client_uri: consultingAppOrigin,
    redirect_uris: [callbackUrl],
    grant_types: ['authorization_code', 'refresh_token'],
    response_types: ['code'],
    scope: 'openid profile',
    token_endpoint_auth_method: 'client_secret_basic',
  });
  if (created.error) throw created.error;
  oauthClient = created.data;
}

if (!oauthClient.client_secret) throw new Error('Entry OAuth client secret was not returned');

const providerConfig = {
  name: 'Lead Emergence',
  client_id: oauthClient.client_id,
  client_secret: oauthClient.client_secret,
  scopes: ['openid', 'profile'],
  pkce_enabled: true,
  enabled: true,
  email_optional: true,
  issuer: entryIssuer,
};
const listedProviders = await consulting.auth.admin.customProviders.listProviders({ type: 'oidc' });
if (listedProviders.error) throw listedProviders.error;
const existingProvider = listedProviders.data.providers.find(
  (provider) => provider.identifier === PROVIDER_IDENTIFIER,
);
const providerResult = existingProvider
  ? await consulting.auth.admin.customProviders.updateProvider(PROVIDER_IDENTIFIER, providerConfig)
  : await consulting.auth.admin.customProviders.createProvider({
      provider_type: 'oidc',
      identifier: PROVIDER_IDENTIFIER,
      ...providerConfig,
    });
if (providerResult.error) throw providerResult.error;

console.log(JSON.stringify({
  clientId: oauthClient.client_id,
  providerIdentifier: PROVIDER_IDENTIFIER,
  entryIssuer,
  callbackUrl,
}));
