import { expect, test } from '@playwright/test';

const organizationId = '10000000-0000-4000-8000-000000000001';

test.beforeEach(async ({ page }) => {
  await page.goto('/api/test-session?role=consultant&returnTo=%2Fconsultant%2Fclients&reset=true');
});

test('consultant creates and enters a new church engagement with the correct context', async ({ page }) => {
  await page.getByRole('button', { name: 'Start client setup' }).click();
  await page.getByLabel('Church or organization name').fill('Grace Community Church');
  await page.getByLabel('Engagement name').fill('Healthy Ministry Rhythm 2026');
  await page.getByLabel('Start date').fill('2026-09-01');
  await page.getByRole('button', { name: 'Create engagement' }).click();
  await expect(page).toHaveURL(/\/consultant\/clients\/10000000-0000-4000-8001-000000000001\/overview/);
  await expect(page.getByTestId('current-organization')).toHaveText('Grace Community Church');
  await expect(page.getByTestId('current-engagement')).toHaveText('Healthy Ministry Rhythm 2026');
  await expect(page.getByText('Northstar is moving decision authority')).toHaveCount(0);
});

test('consultant captures discovery evidence, an interview, and an assessment draft', async ({ page }) => {
  await page.goto(`/consultant/clients/${organizationId}/discovery`);
  await expect(page.getByRole('heading', { name: 'Build the evidence base' })).toBeVisible();

  await page.getByLabel('Source title').fill('Weekly staff meeting observation');
  await page.getByLabel('Provenance and collection context').fill('Observed by the consultant during the August staff meeting.');
  await page.getByLabel('Source excerpt or observation').fill('Three urgent changes were added after the agenda was finalized.');
  await page.getByLabel('Why it is relevant').fill('Shows planning volatility and interruption load.');
  await page.getByRole('button', { name: 'Capture evidence' }).click();
  await expect(page.getByText('Weekly staff meeting observation')).toBeVisible();

  await page.getByRole('tab', { name: 'Interview' }).click();
  await page.getByLabel('Participant label').fill('Senior pastor');
  await page.getByLabel('Interview guide').fill('Church health discovery interview');
  await page.getByLabel('Question').fill('What part of the current rhythm is least sustainable?');
  await page.getByLabel('Response or excerpt').fill('The weekly pivots leave leaders reacting instead of preparing.');
  await page.getByLabel(/Consent to retain/).check();
  await page.getByRole('button', { name: 'Record interview' }).click();
  await expect(page.getByText('Senior pastor')).toBeVisible();

  await page.getByRole('tab', { name: 'Assessment' }).click();
  await page.getByLabel('Instrument name').fill('Ministry Rhythm Discovery');
  await page.getByLabel('Dimension').fill('Leadership sustainability');
  await page.getByLabel('First prompt').fill('Our current ministry rhythm is sustainable for staff and volunteers.');
  await page.getByLabel('Audience').fill('Pastoral staff and ministry leads');
  await page.getByLabel('Opens').fill('2026-09-05T09:00');
  await page.getByLabel('Closes').fill('2026-09-12T17:00');
  await page.getByRole('button', { name: 'Create assessment draft' }).click();
  await expect(page.getByText('Ministry Rhythm Discovery')).toBeVisible();
  await page.screenshot({ path: 'test-results/pilot-discovery-intake.png', fullPage: true, caret: 'initial' });
});

test('meeting plan fields follow the selected meeting without stale values', async ({ page }) => {
  await page.goto('/consultant/meetings');
  await page.getByRole('button', { name: /Decision judgment coaching/ }).click();
  await expect(page.getByLabel('Title')).toHaveValue('Decision judgment coaching');
  await page.getByRole('button', { name: /Authority alignment workshop/ }).click();
  await expect(page.getByLabel('Title')).toHaveValue('Authority alignment workshop');
});
