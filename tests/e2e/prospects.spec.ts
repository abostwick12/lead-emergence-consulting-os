import { expect, test } from '@playwright/test';

test('public Consulting intake is mobile-first and never discloses a 3-2-1 immediately', async ({ page }) => {
  await page.goto('/intake/consulting');
  await expect(page.getByText('Question 1 of 6')).toBeVisible();
  for (let index = 0; index < 6; index += 1) {
    await page.getByLabel('Your response').fill(`A thoughtful response for prompt ${index + 1} with enough meaningful detail.`);
    await page.getByRole('button', { name: 'Continue' }).click();
  }
  await page.getByLabel('First name').fill('Taylor');
  await page.getByLabel('Email').fill('taylor@example.test');
  await page.getByRole('button', { name: 'Complete intake' }).click();
  await expect(page.getByRole('heading', { name: /given us enough to begin/i })).toBeVisible();
  await expect(page.getByText(/reviewed by a human before it is sent/i)).toBeVisible();
  await expect(page.getByText('3 signals')).toHaveCount(0);
});

test('consultant must approve before preparing or recording a 3-2-1 delivery', async ({ page }) => {
  await page.goto('/api/test-session?reset=true&role=consultant&returnTo=%2Fconsultant%2Fprospects');
  await expect(page.getByRole('heading', { name: /begin with what is actually there/i })).toBeVisible();
  const prepare = page.getByRole('button', { name: 'Prepare delivery preview' });
  await expect(prepare).toBeDisabled();
  await page.getByRole('button', { name: 'Approve this revision' }).click();
  await expect(page.getByText(/approved revision #1 is preserved/i)).toBeVisible();
  await expect(prepare).toBeEnabled();
  await prepare.click();
  await expect(page.getByRole('button', { name: 'Record delivery' })).toBeEnabled();
  await page.getByRole('button', { name: 'Record delivery' }).click();
  await expect(page.getByText(/Delivery recorded/i)).toBeVisible();
});