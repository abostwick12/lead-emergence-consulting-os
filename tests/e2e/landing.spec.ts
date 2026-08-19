import { expect, test } from '@playwright/test';

test.describe('public Lead Emergence landing experience', () => {
  test('builds one continuous symbol and keeps the persistent returning-user entry available', async ({ page }) => {
    const consoleErrors: string[] = [];
    page.on('console', (message) => {
      if (message.type() === 'error') consoleErrors.push(message.text());
    });
    await page.setViewportSize({ width: 1536, height: 1024 });
    await page.goto('/');
    await expect(page.getByRole('heading', { name: /Before you build what comes next/ })).toBeVisible();
    await expect(page.locator('header').getByRole('button', { name: 'Sign in', exact: true })).toBeVisible();
    await page.screenshot({ path: 'test-results/landing-hero-desktop.png' });

    await page.getByRole('link', { name: 'SCROLL TO BEGIN' }).click();
    await page.getByRole('link', { name: '02 REFRAME', exact: true }).click();
    await expect(page.locator('[data-active-stage]')).toHaveAttribute('data-active-stage', '2');
    await expect(page.getByText('Meaning gives direction.', { exact: true })).toBeVisible();
    await expect(page.locator('[data-active-stage] article')).toHaveCount(1);

    await page.getByRole('link', { name: '06 NEW REALITY', exact: true }).click();
    await expect(page.locator('[data-active-stage]')).toHaveAttribute('data-active-stage', '6');
    await expect(page.getByText('Step into what has become possible.', { exact: true })).toBeVisible();
    await page.screenshot({ path: 'test-results/landing-new-reality-desktop.png' });

    await page.locator('header').getByRole('button', { name: 'Sign in', exact: true }).click();
    await expect(page.getByRole('heading', { name: 'Choose your environment.' })).toBeVisible();
    await expect(page.getByRole('link', { name: 'Consultant', exact: true })).toHaveAttribute('href', '/login?returnTo=%2Fconsultant');
    await expect(page.getByRole('link', { name: 'Client', exact: true })).toHaveAttribute('href', '/login?returnTo=%2Fclient');
    await expect(page.getByRole('link', { name: 'Ministry user', exact: true })).toHaveAttribute('href', 'https://ministry.leademergence.com/login');
    await page.getByRole('button', { name: 'Close sign in selector' }).click();
    await page.getByRole('link', { name: '07 SEE AGAIN', exact: true }).click();
    await expect(page.locator('[data-active-stage]')).toHaveAttribute('data-active-stage', '7');
    await expect(page.getByText('Because reality never stops becoming.', { exact: true })).toBeVisible();
    await page.screenshot({ path: 'test-results/landing-see-again-desktop.png' });
    await page.locator('#products').scrollIntoViewIfNeeded();
    await expect(page.getByRole('heading', { name: 'Choose your workspace' })).toBeVisible();
    await expect(page.getByRole('link', { name: /Team member login/ })).toHaveAttribute('href', 'https://ministry.leademergence.com/login');
    await expect(page.getByRole('link', { name: /Guest access/ })).toHaveAttribute('href', 'https://ministry.leademergence.com/api/auth/guest');
    await expect(page.getByRole('link', { name: /Client login/ })).toHaveAttribute('href', '/login?returnTo=%2Fclient');
    await expect(page.getByRole('button', { name: 'Sign in', exact: true })).toHaveCount(1);
    await expect(page.getByText('Returning user?', { exact: true })).toHaveCount(0);
    await expect(page.getByText('TWO ENVIRONMENTS. ONE CONVICTION.', { exact: true })).toHaveCount(0);
    await expect(page.locator('img[src*="mock-product-intro-v10"]')).toHaveCount(0);
    await expect(page.locator('img[src*="mock-stage-06-new-reality-v10"]')).toHaveCount(1);
    await page.screenshot({ path: 'test-results/landing-product-entry-desktop.png' });
    expect(consoleErrors).toEqual([]);
  });

  test('preserves the same construction sequence on mobile', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('/');
    await page.getByRole('link', { name: 'SCROLL TO BEGIN' }).click();
    await page.getByRole('link', { name: '06 NEW REALITY', exact: true }).click();
    await expect(page.locator('[data-active-stage]')).toHaveAttribute('data-active-stage', '6');
    await expect(page.getByText('Step into what has become possible.', { exact: true })).toBeVisible();
    await expect(page.locator('header').getByRole('button', { name: 'Sign in', exact: true })).toBeVisible();
    await page.screenshot({ path: 'test-results/landing-new-reality-mobile.png' });
    await page.locator('#products').scrollIntoViewIfNeeded();
    await page.screenshot({ path: 'test-results/landing-product-entry-mobile.png' });
    await expect(page.getByText('Returning user?', { exact: true })).toHaveCount(0);
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
