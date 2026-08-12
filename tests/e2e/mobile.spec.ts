import { expect, test } from '@playwright/test';

test('client mobile access preserves key V1 destinations and truthful phase boundaries', async ({ page }) => {
  await page.goto('/api/test-session?role=client&returnTo=/client');
  await expect(page.getByText('Prepare boundary examples')).toBeVisible();
  await expect(page.getByText('Assessment opens next week')).toBeVisible();
  await expect(page.getByRole('navigation', { name: 'Mobile navigation' })).toBeVisible();
  await page.getByRole('navigation', { name: 'Mobile navigation' }).getByText('Meetings').click();
  await expect(page.getByRole('heading', { name: 'Meetings' })).toBeVisible();
  await expect(page.getByText('Shared interaction engine')).toBeVisible();
  await page.getByRole('button', { name: /Decision judgment coaching/ }).click();
  await expect(page.getByText('NAMED PARTICIPANTS')).toBeVisible();
  await expect(page.getByText('Commitments across sessions')).toBeVisible();
  await page.screenshot({ path: 'test-results/client-mobile-meeting.png', fullPage: true });
  await page.goto('/client/my-development');
  await expect(page.getByRole('heading', { name: 'My Development' })).toBeVisible();
  await expect(page.getByText(/Private coaching content is never organizational telemetry/)).toBeVisible();
  await page.screenshot({ path: 'test-results/client-mobile.png', fullPage: true });
});

test('consultant can operate access and Ministry handoff controls on mobile', async ({ page }) => {
  await page.goto('/api/test-session?role=consultant&returnTo=/consultant/clients/10000000-0000-4000-8000-000000000001/handoff&reset=true');
  await expect(page.getByRole('heading', { name: 'Invite the right people, in the right context.' })).toBeVisible();
  await page.getByLabel('Name', { exact: true }).fill('Mobile Leader');
  await page.getByLabel('Email', { exact: true }).fill('mobile@example.com');
  await page.getByRole('button', { name: 'Send secure invitation' }).click();
  await expect(page.getByText('mobile@example.com')).toBeVisible();
  await page.getByLabel('Authorized administrator').fill('Mobile Leader');
  await page.getByLabel('Readiness').selectOption('PREPARING');
  await page.getByRole('button', { name: 'Save handoff' }).click();
  await expect(page.getByText('Ministry OS setup handoff saved.')).toBeVisible();
  await page.screenshot({ path: 'test-results/v1-access-handoff-mobile.png', fullPage: true });
});
