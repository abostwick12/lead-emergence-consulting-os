import { expect, test, type APIResponse } from '@playwright/test';

async function readMcpResponse(response: APIResponse) {
  const body = await response.text();
  if (response.headers()['content-type']?.includes('application/json')) return JSON.parse(body);

  const dataLines = body
    .split(/\r?\n/)
    .filter((line) => line.startsWith('data:'))
    .map((line) => line.slice(5).trim())
    .filter((line) => line && line !== '[DONE]');
  const data = dataLines[dataLines.length - 1];

  if (!data) throw new Error(`MCP response did not contain a JSON or SSE data payload: ${body}`);
  return JSON.parse(data);
}

test('consultant can find simple setup instructions for all supported AI assistants', async ({ page, context }) => {
  await page.goto('/api/test-session?role=consultant&returnTo=/consultant/settings');
  await expect(page.getByRole('heading', { name: 'Connect your AI assistant' })).toBeVisible();
  await expect(page.getByText('http://localhost:3200/mcp', { exact: true })).toBeVisible();
  for (const provider of ['ChatGPT', 'Claude', 'Microsoft Copilot', 'GitHub Copilot']) {
    await expect(page.getByText(provider, { exact: true })).toBeVisible();
  }
  await context.grantPermissions(['clipboard-read', 'clipboard-write']);
  await page.getByRole('button', { name: 'Copy address' }).click();
  await expect(page.getByRole('button', { name: 'Copied' })).toBeVisible();
});

test('client can start the dedicated MCP setup from portal settings', async ({ page, context }) => {
  await page.goto('/api/test-session?role=client&returnTo=/client/settings');
  await expect(page.getByRole('heading', { name: 'Connect your AI assistant' })).toBeVisible();
  await expect(page.getByText('http://localhost:3200/mcp/client', { exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Start setup · copy address' })).toBeVisible();
  await context.grantPermissions(['clipboard-read', 'clipboard-write']);
  await page.getByRole('button', { name: 'Start setup · copy address' }).click();
  await expect(page.getByRole('button', { name: 'Ready to paste' })).toBeVisible();
});

test('MCP discovery and bearer challenge are standards-shaped', async ({ request }) => {
  const metadata = await request.get('/.well-known/oauth-protected-resource/mcp');
  expect(metadata.ok()).toBeTruthy();
  expect(await metadata.json()).toMatchObject({
    resource: 'http://localhost:3200/mcp',
    authorization_servers: ['https://fixture-auth.leademergence.invalid/auth/v1'],
  });

  const unauthorized = await request.post('/mcp', {
    data: { jsonrpc: '2.0', id: 1, method: 'initialize', params: { protocolVersion: '2025-06-18', capabilities: {}, clientInfo: { name: 'e2e', version: '1.0.0' } } },
  });
  expect(unauthorized.status()).toBe(401);
  expect(unauthorized.headers()['www-authenticate']).toContain('oauth-protected-resource/mcp');

  const clientMetadata = await request.get('/.well-known/oauth-protected-resource/mcp/client');
  expect(clientMetadata.ok()).toBeTruthy();
  expect(await clientMetadata.json()).toMatchObject({ resource: 'http://localhost:3200/mcp/client' });
  const clientUnauthorized = await request.post('/mcp/client', {
    data: { jsonrpc: '2.0', id: 3, method: 'initialize', params: { protocolVersion: '2025-06-18', capabilities: {}, clientInfo: { name: 'e2e', version: '1.0.0' } } },
  });
  expect(clientUnauthorized.status()).toBe(401);
  expect(clientUnauthorized.headers()['www-authenticate']).toContain('oauth-protected-resource/mcp/client');
});

test('authorized OAuth token can initialize the MCP server and list tools', async ({ request }) => {
  const headers = { Authorization: 'Bearer fixture-consultant-oauth-token', Accept: 'application/json, text/event-stream' };
  const initialized = await request.post('/mcp', {
    headers,
    data: { jsonrpc: '2.0', id: 1, method: 'initialize', params: { protocolVersion: '2025-06-18', capabilities: {}, clientInfo: { name: 'e2e', version: '1.0.0' } } },
  });
  expect(initialized.ok()).toBeTruthy();
  const initializedBody = await readMcpResponse(initialized);
  expect(initializedBody.result.serverInfo.name).toBe('Lead Emergence Consulting OS');

  const tools = await request.post('/mcp', { headers, data: { jsonrpc: '2.0', id: 2, method: 'tools/list', params: {} } });
  expect(tools.ok()).toBeTruthy();
  const toolBody = await readMcpResponse(tools);
  expect(toolBody.result.tools.map((tool: { name: string }) => tool.name)).toEqual(expect.arrayContaining([
    'list_available_engagements', 'get_guided_record', 'save_guided_response', 'get_assessment_instrument', 'save_assessment_response',
  ]));
});

test('authorized client OAuth token initializes the dedicated client MCP with participant-safe tools', async ({ request }) => {
  const headers = { Authorization: 'Bearer fixture-client-oauth-token', Accept: 'application/json, text/event-stream' };
  const initialized = await request.post('/mcp/client', {
    headers,
    data: { jsonrpc: '2.0', id: 1, method: 'initialize', params: { protocolVersion: '2025-06-18', capabilities: {}, clientInfo: { name: 'client-e2e', version: '1.0.0' } } },
  });
  expect(initialized.ok()).toBeTruthy();
  const initializedBody = await readMcpResponse(initialized);
  expect(initializedBody.result.serverInfo.name).toBe('Lead Emergence Client Workspace');
  const tools = await request.post('/mcp/client', { headers, data: { jsonrpc: '2.0', id: 2, method: 'tools/list', params: {} } });
  const toolBody = await readMcpResponse(tools);
  const names = toolBody.result.tools.map((tool: { name: string }) => tool.name);
  expect(names).toEqual(expect.arrayContaining(['open_workspace', 'list_my_engagements', 'list_my_guided_records', 'get_guided_record', 'save_confirmed_response']));
  expect(names).not.toContain('start_assessment_administration');
  expect(names).not.toContain('list_engagement_records');
});

test('OAuth consent clearly states access and handling boundaries', async ({ page }) => {
  await page.goto('/api/test-session?role=consultant&returnTo=%2Foauth%2Fconsent%3Fauthorization_id%3Dfixture-review');
  await expect(page).toHaveURL(/\/oauth\/consent\?authorization_id=fixture-review$/);
  await expect(page.getByRole('heading', { name: 'Connect Local MCP review client?' })).toBeVisible();
  await expect(page.getByText('Sanitized information only.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Approve connection' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Cancel' })).toBeVisible();
});

test('unauthenticated OAuth consent preserves the exact safe nested return path through login', async ({ page }) => {
  await page.goto('/oauth/consent?authorization_id=fixture-review');
  await expect(page).toHaveURL(/\/login\?returnTo=%2Foauth%2Fconsent%3Fauthorization_id%3Dfixture-review$/);
  await expect(page.getByText('Local review access')).toBeVisible();
  await page.getByRole('link', { name: /Enter consultant portal/ }).click();
  await expect(page).toHaveURL(/\/oauth\/consent\?authorization_id=fixture-review$/);
  await expect(page.getByRole('heading', { name: 'Connect Local MCP review client?' })).toBeVisible();
});

test('OAuth approval and denial return to the fixture provider callback', async ({ page }) => {
  await page.goto('/api/test-session?role=consultant&returnTo=%2Foauth%2Fconsent%3Fauthorization_id%3Dfixture-review');
  await page.getByRole('button', { name: 'Approve connection' }).click();
  await expect(page).toHaveURL(/\/oauth\/callback\?state=fixture-review&code=fixture-authorization-code$/);

  await page.goto('/oauth/consent?authorization_id=fixture-review');
  await page.getByRole('button', { name: 'Cancel' }).click();
  await expect(page).toHaveURL(/\/oauth\/callback\?state=fixture-review&error=access_denied$/);
});

test('OAuth decisions reject cross-site form submissions', async ({ request }) => {
  const response = await request.post('/api/oauth/decision', {
    headers: { Origin: 'https://attacker.invalid', 'Content-Type': 'application/x-www-form-urlencoded' },
    data: 'authorization_id=fixture-review&decision=approve',
  });
  expect(response.status()).toBe(403);
});
