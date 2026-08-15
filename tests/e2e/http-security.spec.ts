import { expect, test } from '@playwright/test';

test('HTTP surface preserves authentication, authorization, validation, and not-found semantics', async ({ page }) => {
  const unauthenticated = await page.request.post('/api/discovery', { data: { action: 'CAPTURE_EVIDENCE' } });
  expect(unauthenticated.status()).toBe(401);
  expect(await unauthenticated.json()).toEqual({ error: 'Authentication is required.' });

  await page.goto('/api/test-session?role=client&returnTo=%2Fclient');
  const denied = await page.request.post('/api/discovery', { data: { action: 'CAPTURE_EVIDENCE' } });
  expect(denied.status()).toBe(403);
  expect(await denied.json()).toEqual({ error: 'Consultant authorization is required.' });

  await page.goto('/api/test-session?role=consultant&returnTo=%2Fconsultant');
  const malformed = await page.request.post('/api/discovery', {
    data: Buffer.from('{', 'utf8'),
    headers: { 'content-type': 'application/json' },
  });
  expect(malformed.status()).toBe(400);
  expect(await malformed.json()).toEqual({ error: 'The request body must be valid JSON.' });

  const oversized = await page.request.post('/api/discovery', {
    data: { action: 'CAPTURE_EVIDENCE', content: 'x'.repeat(70 * 1024) },
  });
  expect(oversized.status()).toBe(413);
  expect(await oversized.json()).toEqual({ error: 'The request payload is too large.' });

  const absentRecord = await page.request.post('/api/operational-ai', {
    data: {
      action: 'SAVE_GUIDED_RESPONSE',
      recordKind: 'PRODUCT',
      recordId: 'missing-product',
      questionId: 'product-purpose',
      answer: 'A sanitized answer.',
    },
  });
  expect(absentRecord.status()).toBe(404);
  expect(await absentRecord.json()).toEqual({ error: 'The requested guided record was not found.' });
});

test('public assessment errors and security headers are client-safe', async ({ page }) => {
  const invalidAssessment = await page.request.post('/api/assessment-response', {
    data: {
      token: 'invalid',
      itemId: '76100000-0000-4000-8000-000000000001',
      value: 3,
    },
  });
  expect(invalidAssessment.status()).toBe(400);
  expect(await invalidAssessment.json()).toEqual({ error: 'Assessment link is invalid.' });

  const landing = await page.request.get('/');
  expect(landing.headers()['content-security-policy']).toContain("default-src 'self'");
  expect(landing.headers()['x-content-type-options']).toBe('nosniff');
  expect(landing.headers()['x-frame-options']).toBe('DENY');
  expect(landing.headers()['referrer-policy']).toBe('strict-origin-when-cross-origin');
});
