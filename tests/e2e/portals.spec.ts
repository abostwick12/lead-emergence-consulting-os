import { expect, test, type Page } from '@playwright/test';

async function enter(page: Page, role: 'consultant' | 'client', returnTo?: string) {
  await page.goto(`/api/test-session?role=${role}&returnTo=${encodeURIComponent(returnTo ?? `/${role}`)}`);
}

test('consultant portal keeps organization and engagement context visible', async ({ page }) => {
  await enter(page, 'consultant');
  await expect(page.getByTestId('current-organization')).toHaveText('Northstar Community Works');
  await expect(page.getByTestId('current-engagement')).toHaveText('Organizational Renewal 2026');
  await expect(page.getByRole('heading', { name: /Northstar Community Works is in focus/ })).toBeVisible();
  await expect(page.getByText('Private consultant working interpretation')).toBeVisible();
  await page.screenshot({ path: 'test-results/consultant-desktop.png', fullPage: true });
});

test('consultant can move through the workspace and inspect provenance and history', async ({ page }) => {
  await enter(page, 'consultant', '/consultant/clients/10000000-0000-4000-8000-000000000001/discovery');
  await expect(page.getByRole('heading', { name: 'Discovery', exact: true })).toBeVisible();
  await expect(page.getByRole('navigation', { name: 'Client workspace sections' })).toBeVisible();
  await page.getByText('Authority repeatedly escalates upward').click();
  await expect(page.getByRole('heading', { name: 'Inspectable sources' })).toBeVisible();
  await expect(page.getByText('Interview 04 · excerpt 12')).toBeVisible();
  await expect(page.getByRole('heading', { name: 'How this record changed' })).toBeVisible();
});

test('canonical roadmap remains one visible journey', async ({ page }) => {
  await enter(page, 'consultant');
  for (const stage of ['SEE REALITY', 'REFRAME REALITY', 'ALIGN WITH REALITY', 'BUILD CAPABILITY', 'PRODUCE VALUE', 'NEW REALITY', 'SEE AGAIN']) {
    await expect(page.getByText(stage, { exact: true })).toBeVisible();
  }
  await expect(page.getByText('The roadmap is context—not seven separate applications.')).toBeVisible();
});

test('knowledge states are visibly distinct', async ({ page }) => {
  await enter(page, 'consultant');
  await expect(page.locator('.state-ai-suggestion').first()).toHaveText('AI SUGGESTION');
  await expect(page.locator('.state-interpretation').first()).toHaveText('INTERPRETATION');
  await expect(page.locator('.state-validated-insight').first()).toHaveText('VALIDATED INSIGHT');
  await expect(page.locator('.state-decision').first()).toHaveText('DECISION');
});

test('client home makes attention items clear and shows only shared conclusions', async ({ page }) => {
  await enter(page, 'client');
  await expect(page.getByRole('heading', { name: 'What needs your attention' })).toBeVisible();
  await expect(page.getByText('Review the validated authority insight')).toBeVisible();
  await expect(page.getByText('Private consultant working interpretation')).toHaveCount(0);
  await expect(page.getByText('Authority can expand with explicit capability and boundaries')).toBeVisible();
});

test('client cannot guess consultant-private record URL', async ({ page }) => {
  await enter(page, 'client', '/client/records/30000000-0000-4000-8000-000000000005');
  await expect(page.getByRole('heading', { name: 'This record or workspace is not available.' })).toBeVisible();
  await expect(page.getByText('A private working interpretation')).toHaveCount(0);
});

test('role boundaries reject cross-portal URL guessing', async ({ page }) => {
  await enter(page, 'client', '/consultant');
  await expect(page.getByRole('heading', { name: 'This record or workspace is not available.' })).toBeVisible();
  await enter(page, 'consultant', '/client');
  await expect(page.getByRole('heading', { name: 'This record or workspace is not available.' })).toBeVisible();
});

test('current effective state defaults with historical state accessible', async ({ page }) => {
  await enter(page, 'client');
  await expect(page.getByRole('heading', { name: 'What is true now' })).toBeVisible();
  await page.getByText('View historical state').click();
  await expect(page.getByText('June 1, 2026')).toBeVisible();
});

test('unauthenticated portal request returns to secure entry', async ({ page }) => {
  await page.goto('/consultant');
  await expect(page).toHaveURL(/\/login\?returnTo=/);
  await expect(page.getByText('Local review access')).toBeVisible();
});

test.describe.serial('Phase 5 meeting and coaching cycles', () => {
  test('consultant creates, advances, captures, commits, and privately reflects', async ({ page }) => {
    await enter(page, 'consultant', '/consultant/meetings');
    await expect(page.getByRole('heading', { name: 'Meetings', exact: true })).toBeVisible();
    await page.getByRole('button', { name: 'New meeting' }).click();
    const createForm = page.locator('.create-meeting-form');
    await createForm.getByLabel('Type').selectOption('COACHING');
    await createForm.getByLabel('Title').fill('Delegation practice review');
    await createForm.getByLabel('Purpose').fill('Practice bounded authority decisions and choose the next experiment.');
    await createForm.getByLabel('Starts').fill('2026-08-20T09:00');
    await createForm.getByLabel('Development focus').fill('Escalation judgment');
    await createForm.getByRole('button', { name: 'Create meeting' }).click();
    await expect(page.getByRole('heading', { name: 'Delegation practice review' })).toBeVisible();
    await expect(page.getByText('NAMED PARTICIPANTS')).toBeVisible();

    await page.getByLabel('Workflow stage').selectOption('MEET');
    await page.getByRole('button', { name: 'Save meeting plan' }).click();
    await expect(page.getByText(/Saved\. The shared meeting record/)).toBeVisible();
    const sharedForm = page.locator('form.quick-form').filter({ hasText: 'Add shared note' });
    await sharedForm.getByRole('textbox').fill('We agreed to test the boundary prompt in live decisions.');
    await sharedForm.getByRole('button', { name: 'Save shared note' }).click();
    await expect(page.getByText('We agreed to test the boundary prompt in live decisions.')).toBeVisible();

    const privateForm = page.locator('form.quick-form').filter({ hasText: 'Add private reflection' });
    await privateForm.getByRole('textbox').fill('Consultant-only reflection for the next coaching session.');
    await privateForm.getByRole('button', { name: 'Save privately' }).click();
    await expect(page.getByText('Consultant-only reflection for the next coaching session.')).toBeVisible();
    await page.reload();
    await expect(page.getByText('Consultant-only reflection for the next coaching session.')).toBeVisible();
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({ path: 'test-results/consultant-meeting-desktop.png', caret: 'initial' });
  });

  test('client sees shared coaching work, persists own reflection, and never sees consultant-private content', async ({ page }) => {
    await enter(page, 'client', '/client/meetings');
    await expect(page.getByText('Private coaching reflection retained only for Alex.')).toHaveCount(0);
    await expect(page.getByText('Consultant-only reflection for the next coaching session.')).toHaveCount(0);
    const coachingItem = page.getByRole('button', { name: /Decision judgment coaching/ });
    await coachingItem.click();
    const privateForm = page.locator('form.quick-form').filter({ hasText: 'Add private reflection' });
    await privateForm.getByRole('textbox').fill('My private reflection remains mine.');
    await privateForm.getByRole('button', { name: 'Save privately' }).click();
    await expect(page.getByText('My private reflection remains mine.')).toBeVisible();
    await page.reload();
    await page.getByRole('button', { name: /Decision judgment coaching/ }).click();
    await expect(page.getByText('My private reflection remains mine.')).toBeVisible();
    await expect(page.getByText('Private coaching reflection retained only for Alex.')).toHaveCount(0);
  });
});
