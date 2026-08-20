import { expect, test } from '@playwright/test';

test('Consulting context selection is a product-internal step', async ({ page }) => {
  await page.goto('/api/test-session?role=consultant&returnTo=%2Fconsulting-context');
  await expect(page.getByRole('heading', { name: /choose how you are working/i })).toBeVisible();
  await expect(page.getByRole('link', { name: /consultant consultant work/i })).toBeVisible();
  await expect(page.getByText('Consulting role and organization context are selected here')).toBeVisible();
  await expect(page.getByText('MINISTRY')).toHaveCount(0);
  await expect(page.getByText('PERSONAL')).toHaveCount(0);
});