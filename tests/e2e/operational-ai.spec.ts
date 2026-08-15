import { expect, test } from '@playwright/test';

const organizationId = '70000000-0000-4000-8000-000000000007';

test('consultant can run the sanitized 7th SOS P0 workspace', async ({ page }) => {
  await page.goto(`/api/test-session?role=consultant&returnTo=${encodeURIComponent(`/consultant/clients/${organizationId}/overview`)}`);
  await page.goto(`/consultant/clients/${organizationId}/overview`);
  await expect(page.getByTestId('current-organization')).toHaveText('7th Special Operations Squadron');
  await expect(page.getByText('Internal — Sanitized Only', { exact: true })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Operational Product AI Transformation', exact: true })).toBeVisible();
  await expect(page.getByRole('link', { name: /Ministry Handoff/ })).toHaveCount(0);
  await page.screenshot({ path: 'test-results/operational-ai-overview-desktop.png', fullPage: true });

  await page.getByRole('link', { name: /Products P0/ }).click();
  await page.getByText('Add product', { exact: true }).click();
  await page.getByLabel('Product name').fill('Sanitized Product Four');
  await page.getByLabel('Product owner').fill('Owner to confirm');
  await page.getByLabel('Sanitized purpose and scope').fill('Assess an authorized, sanitized product workflow and its human review points.');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Sanitized Product Four' })).toBeVisible();

  await page.getByRole('link', { name: /Evidence P0/ }).click();
  await page.getByText('Capture evidence', { exact: true }).click();
  await page.getByLabel('Evidence title').fill('Sanitized process walkthrough');
  await page.getByLabel('Reviewable source locator').fill('Consultant note 01 — approved summary');
  await page.getByLabel('What was observed or recorded').fill('A named human reviewer verifies the product before authorized release.');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Sanitized process walkthrough' })).toBeVisible();

  await page.getByLabel('Evidence title').fill('Classified mission timeline');
  await page.getByLabel('Reviewable source locator').fill('Unsafe source');
  await page.getByLabel('What was observed or recorded').fill('Do not store this.');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByText(/sanitized consulting content only/i)).toBeVisible();
});
