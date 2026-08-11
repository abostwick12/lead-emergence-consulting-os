import { expect, test, type Page } from '@playwright/test';

const discoveryPath = '/consultant/clients/10000000-0000-4000-8000-000000000001/discovery';
async function enter(page: Page, role: 'consultant' | 'client', returnTo: string) { await page.goto(`/api/test-session?role=${role}&returnTo=${encodeURIComponent(returnTo)}`); }

test.describe.serial('Phase 8 grounded Meridian assistance', () => {
  test('consultant sees reviewable AI origin, citations, contrary evidence, and permission-bounded preparation', async ({ page }) => {
    await enter(page, 'consultant', discoveryPath);
    await expect(page.getByRole('heading', { name: 'Evidence in view. Judgment stays human.' })).toBeVisible();
    await expect(page.getByText('AI ORIGIN').first()).toBeVisible();
    await expect(page.getByText('SUGGESTED').first()).toBeVisible();
    await expect(page.getByRole('heading', { name: 'Supporting evidence' }).first()).toBeVisible();
    await expect(page.getByRole('heading', { name: 'Contrary evidence' }).first()).toBeVisible();
    await expect(page.getByText('Interview 04').first()).toBeVisible();
    await expect(page.getByText('Rows 22–41').first()).toBeVisible();
    await expect(page.getByText(/No private coaching notes were searched or summarized/)).toBeVisible();
    await expect(page.getByText('Consultant-only reflection for the next coaching session.')).toHaveCount(0);
    await page.screenshot({ path: 'test-results/phase8-grounded-ai-desktop.png', fullPage: true, caret: 'initial' });
  });

  test('grounded generation preserves exact source roles and rejected suggestions never return as active truth', async ({ page }) => {
    await enter(page, 'consultant', discoveryPath);
    await page.getByRole('button', { name: 'Suggest a pattern' }).click();
    await expect(page.getByText('Grounded suggestion created with its exact permission-eligible source set.')).toBeVisible();
    await expect(page.getByRole('heading', { name: 'Authority continues to concentrate at escalation points' })).toBeVisible();
    const initialCard = page.locator('.meridian-suggestion-card').filter({ hasText: 'Authority repeatedly escalates upward' });
    await initialCard.getByRole('button', { name: 'Review suggestion' }).click();
    await initialCard.getByLabel('Why should this suggestion be rejected?').fill('The contrary case narrows the recurrence claim and requires a human rewrite.');
    await initialCard.getByRole('button', { name: 'Reject and preserve history' }).click();
    await expect(page.getByText('Rejected suggestion preserved in review history and removed from active retrieval.')).toBeVisible();
    await expect(page.locator('.meridian-suggestion-card').filter({ hasText: 'Authority repeatedly escalates upward' })).toHaveCount(0);
    await expect(page.getByText('Rejected suggestion history')).toBeVisible();
    await page.reload();
    await expect(page.locator('.meridian-suggestion-card').filter({ hasText: 'Authority repeatedly escalates upward' })).toHaveCount(0);
    await expect(page.getByText('Rejected suggestion history')).toBeVisible();
  });

  test('insufficient evidence is explicit and client contexts do not expose raw AI review', async ({ page }) => {
    await enter(page, 'consultant', discoveryPath);
    const result = await page.evaluate(async () => {
      const response = await fetch('/api/meridian-ai', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ action: 'GENERATE_PATTERN', sourceIds: ['source-interview-04'] }) });
      return { status: response.status, body: await response.json() };
    });
    expect(result.status).toBe(400);
    expect(result.body.error).toMatch(/^Insufficient permission-eligible evidence:/);
    await enter(page, 'client', '/client/our-organization');
    await expect(page.getByText('Meridian · grounded assistance')).toHaveCount(0);
    await expect(page.getByText('AI ORIGIN')).toHaveCount(0);
  });

  test('grounded review remains readable on a narrow viewport', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await enter(page, 'consultant', discoveryPath);
    await expect(page.getByRole('heading', { name: 'Evidence in view. Judgment stays human.' })).toBeVisible();
    await expect(page.getByRole('heading', { name: 'Leadership review preparation' })).toBeVisible();
    await page.screenshot({ path: 'test-results/phase8-grounded-ai-mobile.png', fullPage: true, caret: 'initial' });
  });
});
