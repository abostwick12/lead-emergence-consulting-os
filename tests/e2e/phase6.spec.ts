import { expect, test, type Page } from '@playwright/test';

async function enter(page: Page, role: 'consultant' | 'client', returnTo: string) {
  await page.goto(`/api/test-session?role=${role}&returnTo=${encodeURIComponent(returnTo)}`);
}

test('consultant traces validated meaning into complete role architecture', async ({ page }) => {
  await enter(page, 'consultant', '/consultant/clients/10000000-0000-4000-8000-000000000001/strategy');
  await expect(page.getByRole('heading', { name: 'Insight becomes accountable structure' })).toBeVisible();
  await expect(page.getByText('Validated insight', { exact: true })).toBeVisible();
  await expect(page.getByLabel('Insight becomes accountable structure').getByText('Delegate defined routine decisions', { exact: true })).toBeVisible();
  for (const part of ['Responsibilities', 'Authority', 'Boundaries', 'Interfaces', 'Support', 'Accountability', 'Success measures']) {
    await expect(page.getByText(part, { exact: true })).toBeVisible();
  }
  await expect(page.getByRole('heading', { name: 'Bounded operational decision' })).toBeVisible();
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.screenshot({ path: 'test-results/phase6-alignment-desktop.png', fullPage: true, caret: 'initial' });
});

test('client sees the shared role contract but not consultant-private analysis', async ({ page }) => {
  await enter(page, 'client', '/client/our-organization');
  await expect(page.getByRole('heading', { name: 'Team Lead' })).toBeVisible();
  await expect(page.getByText('Lower decision latency without increased rework or preventable escalation.')).toBeVisible();
  await expect(page.getByText('Private consultant working interpretation')).toHaveCount(0);
});

test('development pathway persists practice and activity without claiming maturity', async ({ page }) => {
  await enter(page, 'client', '/client/my-development');
  await expect(page.getByRole('heading', { name: 'From requirement to reliable practice' })).toBeVisible();
  await expect(page.getByText('Team Lead role · Bounded operational decision workflow')).toBeVisible();
  await expect(page.getByText('Pending: six live decisions and reviewer-confirmed transfer across two contexts')).toBeVisible();
  await page.getByRole('button', { name: /Boundary judgment lab/ }).click();
  await expect(page.getByText(/Saved\. The development record/)).toBeVisible();
  await expect(page.getByRole('button', { name: /Boundary judgment lab/ }).getByText('COMPLETED')).toBeVisible();
  await page.getByLabel('Record completed practice').fill('Used the threshold guide during a live client exception');
  await page.getByRole('button', { name: 'Save practice' }).click();
  await expect(page.getByText(/Used the threshold guide during a live client exception/)).toBeVisible();
  await page.reload();
  await expect(page.getByText(/Used the threshold guide during a live client exception/)).toBeVisible();
  await expect(page.getByText('Pending: six live decisions and reviewer-confirmed transfer across two contexts')).toBeVisible();
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.screenshot({ path: 'test-results/phase6-development-desktop.png', fullPage: true, caret: 'initial' });
});

test('development pathway stays readable and actionable on mobile', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await enter(page, 'client', '/client/my-development');
  await expect(page.getByRole('heading', { name: 'Bounded decision judgment' })).toBeVisible();
  await expect(page.getByText('Current evidence', { exact: true }).first()).toBeVisible();
  await expect(page.getByRole('button', { name: /Two coached live decisions/ })).toBeVisible();
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.screenshot({ path: 'test-results/phase6-development-mobile.png', fullPage: true, caret: 'initial' });
});
