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
