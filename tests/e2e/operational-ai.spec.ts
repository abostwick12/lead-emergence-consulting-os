import { expect, test } from '@playwright/test';

const organizationId = '70000000-0000-4000-8000-000000000007';

test('consultant can run the sanitized 7th SOS P0 workspace', async ({ page }) => {
  await page.goto(`/api/test-session?role=consultant&reset=true&returnTo=${encodeURIComponent(`/consultant/clients/${organizationId}/overview`)}`);
  await page.goto(`/consultant/clients/${organizationId}/overview`);
  await expect(page.getByTestId('current-organization')).toHaveText('7th Special Operations Squadron');
  await expect(page.getByText('Internal — Sanitized Only', { exact: true })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Operational Product AI Transformation', exact: true })).toBeVisible();
  await expect(page.getByRole('link', { name: /Ministry Handoff/ })).toHaveCount(0);
  await page.screenshot({ path: 'test-results/operational-ai-overview-desktop.png', fullPage: true });

  await page.getByRole('link', { name: /Products P0/ }).click();
  await page.getByRole('button', { name: /Mission Planning and Analysis Toolkit/ }).click();
  await expect(page.getByRole('dialog', { name: 'Mission Planning and Analysis Toolkit' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'What purpose does this product serve, and who relies on it?' })).toBeVisible();
  await page.getByLabel('Confirmed response').fill('It provides a consistent, reviewable structure for authorized analysis and accountable human decisions.');
  await page.getByRole('button', { name: /Save & continue/ }).click();
  await expect(page.getByRole('heading', { name: 'Who owns the product and is accountable for its quality?' })).toBeVisible();
  await page.getByRole('button', { name: 'View & edit record' }).click();
  await expect(page.getByText('It provides a consistent, reviewable structure for authorized analysis and accountable human decisions.')).toBeVisible();
  await page.getByLabel('Close guided workspace').click();
  await page.getByText('Add product', { exact: true }).click();
  await page.getByLabel('Product name').fill('Sanitized Product Four');
  await page.getByLabel('Product owner').fill('Owner to confirm');
  await page.getByLabel('Sanitized purpose and scope').fill('Assess an authorized, sanitized product workflow and its human review points.');
  await page.getByRole('button', { name: 'Save', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Sanitized Product Four' })).toBeVisible();

  await page.getByRole('link', { name: /Audits P0/ }).click();
  await page.getByRole('button', { name: /Product owner written audit/ }).click();
  await expect(page.getByRole('heading', { name: 'What is your role in creating, reviewing, approving, or using this product?' })).toBeVisible();
  await page.getByLabel('Confirmed response').fill('I am accountable for the product standard and final quality review.');
  await page.getByRole('button', { name: /Save & continue/ }).click();
  await page.getByLabel('Close guided workspace').click();

  await page.getByRole('link', { name: /Interviews P0/ }).click();
  await page.getByRole('button', { name: /Product owner/ }).first().click();
  await expect(page.getByRole('heading', { name: 'How does the participant describe their role in this product and workflow?' })).toBeVisible();
  await page.getByLabel('Close guided workspace').click();

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

test('role-specific landing entry does not ask the user to choose a role twice', async ({ page }) => {
  await page.goto('/login?returnTo=%2Fconsultant');
  await expect(page).toHaveURL(/\/login\?returnTo=/);
  await expect(page.getByRole('link', { name: /Enter consultant portal/i })).toHaveCount(1);
  await expect(page.getByRole('link', { name: /Enter client portal/i })).toHaveCount(0);
});
