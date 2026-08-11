import { expect, test, type Page } from '@playwright/test';

const signalsPath = '/consultant/clients/10000000-0000-4000-8000-000000000001/signals';
async function enter(page: Page, role: 'consultant' | 'client', returnTo: string) { await page.goto(`/api/test-session?role=${role}&returnTo=${encodeURIComponent(returnTo)}`); }

test('consultant completes a descriptive Signal to renewed Observation loop', async ({ page }) => {
  await enter(page, 'consultant', signalsPath);
  await expect(page.getByRole('heading', { name: 'Notice change without naming it too soon' })).toBeVisible();
  await expect(page.getByText('Signal ≠ Pattern')).toBeVisible();
  await expect(page.getByText('Same indicator definition · same unit · same scoring rule')).toBeVisible();
  await expect(page.getByText('Private coaching is excluded')).toBeVisible();

  await page.getByLabel('What changed?').fill('Escalation requests increased in the partner-onboarding workflow this week.');
  await page.getByPlaceholder('Where and when was this noticed?').fill('Weekly operating review · Aug 2026');
  await page.getByRole('button', { name: 'Record descriptive Signal' }).click();
  const added = page.getByText('Escalation requests increased in the partner-onboarding workflow this week.');
  await expect(added).toBeVisible();

  const card = added.locator('xpath=ancestor::article');
  await card.getByText('Re-enter as a new Observation').click();
  await card.getByLabel('Observation statement').fill('Partner-onboarding exceptions were recorded in three consecutive operating reviews.');
  await card.getByRole('button', { name: 'Create Observation & preserve re-entry' }).click();
  await expect(card.getByText('REENTERS_AS')).toBeVisible();
  await expect(card.getByText('Partner-onboarding exceptions were recorded in three consecutive operating reviews.')).toBeVisible();

  await page.getByPlaceholder('What did the current evidence show?').first().fill('Quality remained stable while routine approvals moved closer to the work.');
  await page.getByRole('button', { name: 'Complete review' }).first().click();
  await expect(page.getByText('COMPLETED', { exact: true })).toBeVisible();
  await expect(page.getByText('This V1 workspace does not perform autonomous drift detection')).toBeVisible();
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.screenshot({ path: 'test-results/phase9-signals-desktop.png', fullPage: true, caret: 'initial' });
});

test('client sees only deliberately shared descriptive Signals and no controls', async ({ page }) => {
  await enter(page, 'client', '/client/progress');
  await expect(page.getByRole('heading', { name: 'Notice change without naming it too soon' })).toBeVisible();
  await expect(page.getByText('Escalation requests now cluster in two customer-facing workflows.')).toBeVisible();
  await expect(page.getByText('Leader confidence remains uneven after authority expanded.')).toHaveCount(0);
  await expect(page.getByRole('button', { name: /Record descriptive Signal|Create Observation|Complete review/ })).toHaveCount(0);
});

test('Signals remains coherent and readable on a narrow viewport', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await enter(page, 'consultant', signalsPath);
  await expect(page.getByRole('heading', { name: 'Notice change without naming it too soon' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Changes worth noticing' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Compatible comparisons' })).toBeVisible();
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.screenshot({ path: 'test-results/phase9-signals-mobile.png', fullPage: true, caret: 'initial' });
});
