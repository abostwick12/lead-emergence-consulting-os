import { expect, test, type Page } from '@playwright/test';

const organizationId = '10000000-0000-4000-8000-000000000001';
async function enter(page: Page, role: 'consultant' | 'client', returnTo: string, reset = false) {
  await page.goto(`/api/test-session?role=${role}&returnTo=${encodeURIComponent(returnTo)}${reset ? '&reset=true' : ''}`);
}

test.afterEach(async ({ request }) => {
  await request.get('/api/test-session?role=consultant&returnTo=%2Fconsultant&reset=true');
});

test('one synthetic engagement completes the full roadmap and renews inquiry inside the product', async ({ page }) => {
  await enter(page, 'consultant', `/consultant/clients/${organizationId}/discovery`, true);
  await expect(page.getByTestId('current-organization')).toHaveText('Northstar Community Works');
  await expect(page.getByTestId('current-engagement')).toHaveText('Organizational Renewal 2026');

  // DISCOVER → UNDERSTAND: grounded Evidence, competing meaning, and human judgment.
  await expect(page.getByText('Authority repeatedly escalates upward').first()).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Supporting evidence' }).first()).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Contrary evidence' }).first()).toBeVisible();
  await expect(page.getByText(/No private coaching notes were searched or summarized/)).toBeVisible();

  // NAME → DESIGN: Interpretation and validated Insight become an authorized design.
  await page.goto(`/consultant/clients/${organizationId}/strategy`);
  await expect(page.getByText('The constraint may be authority architecture').first()).toBeVisible();
  await expect(page.getByText('Authority can expand with explicit capability and boundaries').first()).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Insight becomes accountable structure' })).toBeVisible();
  await expect(page.getByText('Delegate defined routine decisions', { exact: true }).first()).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Bounded operational decision' })).toBeVisible();

  // CULTIVATE: requirements, gaps, practice, and readiness evidence stay connected.
  await page.goto(`/consultant/clients/${organizationId}/development`);
  await expect(page.getByRole('heading', { name: 'From requirement to reliable practice' })).toBeVisible();
  await expect(page.getByText('Pending: six live decisions and reviewer-confirmed transfer across two contexts')).toBeVisible();

  // Meeting and coaching remain inside the engagement with commitments and a physical privacy boundary.
  await page.goto('/consultant/meetings');
  await expect(page.getByRole('heading', { name: 'Meetings', exact: true })).toBeVisible();
  await page.getByRole('button', { name: /Decision judgment coaching/ }).click();
  await expect(page.getByText('Private coaching reflection retained only for Alex.')).toBeVisible();
  await expect(page.getByText('Use the boundary prompt in two decisions and record what happened.')).toBeVisible();

  // MEASURE → INHABIT: expectation, outcome, learning, actual reality, and immutable baseline.
  await page.goto(`/consultant/clients/${organizationId}/outcomes`);
  await expect(page.getByRole('heading', { name: 'Expectation before evidence' })).toBeVisible();
  await page.getByLabel('Current measurement').fill('3.4 days');
  await page.getByLabel('What occurred').fill('Routine decision latency fell while rework remained stable.');
  await page.getByRole('button', { name: 'Record outcome' }).click();
  await expect(page.getByText('No causal claim')).toBeVisible();
  await page.getByLabel('Harvest').fill('Routine decisions now move faster with stable quality.');
  await page.getByLabel('Soil').fill('Team leads strengthened boundary judgment and escalation confidence.');
  await page.getByRole('button', { name: 'Evaluate value' }).click();
  await page.getByLabel('Validated learning').fill('Distributed authority should scale with continued exception review.');
  await page.getByLabel('Decision').selectOption('SCALE');
  await page.getByRole('button', { name: 'Validate learning' }).click();
  await page.getByLabel('What actually became true').fill('Team leads now make routine decisions independently within explicit boundaries.');
  await page.getByLabel('Difference from intent').fill('Adoption became reliable in operations before it spread to every function.');
  await page.getByRole('button', { name: 'Approve profile & establish baseline' }).click();
  await expect(page.getByText('Preserved · not overwritten')).toBeVisible();
  await expect(page.getByText('Ready to SEE AGAIN')).toBeVisible();

  // SEE AGAIN: source-grounded Signal explicitly becomes a new Observation.
  await page.goto(`/consultant/clients/${organizationId}/signals`);
  await expect(page.getByRole('heading', { name: 'Notice change without naming it too soon' })).toBeVisible();
  await page.getByLabel('What changed?').fill('Escalation requests increased in the partner-onboarding workflow this week.');
  await page.getByPlaceholder('Where and when was this noticed?').fill('Weekly operating review · Aug 2026');
  await page.getByRole('button', { name: 'Record descriptive Signal' }).click();
  const signal = page.getByText('Escalation requests increased in the partner-onboarding workflow this week.');
  const signalCard = signal.locator('xpath=ancestor::article');
  await signalCard.getByText('Re-enter as a new Observation').click();
  await signalCard.getByLabel('Observation statement').fill('Partner-onboarding exceptions were recorded in three consecutive operating reviews.');
  await signalCard.getByRole('button', { name: 'Create Observation & preserve re-entry' }).click();
  await expect(signalCard.getByText('REENTERS_AS')).toBeVisible();

  // The Client projection carries shared conclusions and context, never private analysis or authoring controls.
  await enter(page, 'client', '/client/progress');
  await expect(page.getByRole('heading', { name: 'Expectation before evidence' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Notice change without naming it too soon' })).toBeVisible();
  await expect(page.getByText('Private consultant working interpretation')).toHaveCount(0);
  await expect(page.getByRole('button', { name: /Record descriptive Signal|Create Observation|Complete review/ })).toHaveCount(0);
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.screenshot({ path: 'test-results/complete-engagement-client-checkpoint.png', fullPage: true, caret: 'initial' });
});
