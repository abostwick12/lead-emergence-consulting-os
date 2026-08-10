import { expect, test } from '@playwright/test';

test.describe('public Lead Emergence landing experience', () => {
  test('builds one continuous symbol and keeps returning-user entry available', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByRole('heading', { name: /Before you build what comes next/ })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Sign in', exact: true })).toBeVisible();
    await page.screenshot({ path: 'test-results/landing-hero-desktop.png' });

    await page.getByRole('link', { name: 'SCROLL TO BEGIN' }).click();
    await page.getByRole('link', { name: '02 REFRAME', exact: true }).click();
    await expect(page.locator('[data-active-stage]')).toHaveAttribute('data-active-stage', '2');
    await expect(page.getByText('Meaning gives direction.', { exact: true })).toBeVisible();

    await page.getByRole('link', { name: '06 NEW REALITY', exact: true }).click();
    await expect(page.locator('[data-active-stage]')).toHaveAttribute('data-active-stage', '6');
    await expect(page.getByText('Step into what has become possible.', { exact: true })).toBeVisible();
    await page.screenshot({ path: 'test-results/landing-new-reality-desktop.png' });

    await page.getByRole('button', { name: 'Sign in', exact: true }).click();
    await expect(page.getByRole('heading', { name: 'Choose your environment.' })).toBeVisible();
    await expect(page.getByRole('link', { name: 'Consultant', exact: true })).toHaveAttribute('href', '/login?returnTo=%2Fconsultant');
    await expect(page.getByRole('link', { name: 'Client', exact: true })).toHaveAttribute('href', '/login?returnTo=%2Fclient');
    await expect(page.getByRole('link', { name: 'Ministry user', exact: true })).toHaveAttribute('href', 'https://ministry.leademergence.com/login');
    await page.getByRole('button', { name: 'Close sign in selector' }).click();
    await page.locator('#products').scrollIntoViewIfNeeded();
    await page.screenshot({ path: 'test-results/landing-product-entry-desktop.png' });
  });

  test('preserves the same construction sequence on mobile', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('/');
    await page.getByRole('link', { name: 'SCROLL TO BEGIN' }).click();
    await page.getByRole('link', { name: '06 NEW REALITY', exact: true }).click();
    await expect(page.locator('[data-active-stage]')).toHaveAttribute('data-active-stage', '6');
    await expect(page.getByText('Step into what has become possible.', { exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Sign in', exact: true })).toBeVisible();
    await page.screenshot({ path: 'test-results/landing-new-reality-mobile.png' });
  });

  test('uses discrete progressive states when reduced motion is preferred', async ({ page }) => {
    await page.emulateMedia({ reducedMotion: 'reduce' });
    await page.goto('/');
    await page.getByRole('link', { name: 'SCROLL TO BEGIN' }).click();
    await page.getByRole('link', { name: '03 ALIGN', exact: true }).click();
    await expect(page.locator('[data-active-stage]')).toHaveAttribute('data-active-stage', '3');
    await expect(page.getByText('Boundaries create space. Relationships create coherence.', { exact: true })).toBeVisible();
    await expect(page.getByRole('list').getByText(/SEE: Attention before action/)).toBeAttached();
    await expect(page.getByRole('list').getByText(/SEE AGAIN: Because reality never stops becoming/)).toBeAttached();
  });
});
