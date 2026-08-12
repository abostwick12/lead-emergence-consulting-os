import { expect, test, type Page } from '@playwright/test';

const consultantPath = '/consultant/clients/10000000-0000-4000-8000-000000000001/outcomes';
async function enter(page: Page, role: 'consultant' | 'client', returnTo: string) { await page.goto(`/api/test-session?role=${role}&returnTo=${encodeURIComponent(returnTo)}`); }

test('consultant completes the outcome-to-baseline loop without overwriting Future State', async ({ page }) => {
  await enter(page, 'consultant', consultantPath);
  await expect(page.getByRole('heading', { name: 'Expectation before evidence' })).toBeVisible();
  await expect(page.getByText('Established before implementation')).toBeVisible();
  await page.getByLabel('Current measurement').fill('3.4 days');
  await page.getByLabel('Period start').fill('2026-08-01T09:00');
  await page.getByLabel('Period end').fill('2026-08-10T17:00');
  await page.getByLabel('What occurred').fill('Routine decision latency fell while rework remained stable.');
  await page.getByLabel('Collection context').fill('Ten routine decisions sampled from the operating review.');
  await page.getByLabel('Limitations').fill('Small sample from one operating function.');
  await page.getByRole('button', { name: 'Record outcome' }).click();
  await expect(page.getByText('No causal claim')).toBeVisible();
  await page.getByLabel('Harvest').fill('Routine decisions now move faster with stable quality.');
  await page.getByLabel('Soil').fill('Team leads strengthened boundary judgment and escalation confidence.');
  await page.getByLabel('Significance').fill('Faster decisions with stable quality are materially useful.');
  await page.getByLabel('Alternative explanations').fill('The work mix may have been less complex during this period.');
  await page.getByLabel('Limitations').fill('Early result from one operating function.');
  await page.getByRole('button', { name: 'Evaluate value' }).click();
  await expect(page.getByText('Organizational', { exact: true })).toBeVisible();
  await expect(page.getByText('Purpose', { exact: true })).toBeVisible();
  await page.getByLabel('Validated learning').fill('Distributed authority should scale with continued exception review.');
  await page.getByLabel('Implications and next action').fill('Extend to one adjacent workflow with weekly exception review.');
  await page.getByLabel('Contrary evidence considered').fill('One team continues to escalate routine decisions.');
  await page.getByLabel('Limitations').fill('Do not generalize beyond the current functions yet.');
  await page.getByLabel('Decision').selectOption('SCALE');
  await page.getByRole('button', { name: 'Validate learning' }).click();
  await expect(page.getByText(/VALIDATED · SCALE/)).toBeVisible();
  await page.getByLabel('What actually became true').fill('Team leads now make routine decisions independently within explicit boundaries.');
  await page.getByLabel('Difference from intent').fill('Adoption became reliable in operations before it spread to every function.');
  await page.getByRole('button', { name: 'Approve profile & establish baseline' }).click();
  await expect(page.getByText('Preserved · not overwritten')).toBeVisible();
  await expect(page.locator('.outcomes-center').getByText(/Immutable manifest/)).toBeVisible();
  await expect(page.getByText('Ready to SEE AGAIN')).toBeVisible();
  await page.reload();
  await expect(page.getByText(/New Reality is preserved/)).toBeVisible();
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.screenshot({ path: 'test-results/phase7-outcomes-desktop.png', fullPage: true, caret: 'initial' });

  await enter(page, 'client', '/client/progress');
  await expect(page.getByRole('heading', { name: 'Expectation before evidence' })).toBeVisible();
  await expect(page.getByText('No causal claim')).toBeVisible();
  await expect(page.locator('.outcomes-center').getByText(/Immutable manifest/)).toBeVisible();
  await expect(page.getByRole('button', { name: /Record outcome|Evaluate value|Validate learning|Approve profile/ })).toHaveCount(0);
});

test('client progress remains readable on a narrow viewport', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await enter(page, 'client', '/client/progress');
  await expect(page.getByRole('heading', { name: 'Expectation before evidence' })).toBeVisible();
  await expect(page.getByText('Future State · version 1')).toBeVisible();
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.screenshot({ path: 'test-results/phase7-progress-mobile.png', fullPage: true, caret: 'initial' });
});
