import { beforeEach, describe, expect, it, vi } from 'vitest';

const checkRateLimit = vi.fn();

vi.mock('@vercel/firewall', () => ({
  unstable_checkRateLimit: checkRateLimit,
}));

describe('assessment response rate limiting', () => {
  beforeEach(() => {
    vi.resetModules();
    vi.unstubAllEnvs();
    checkRateLimit.mockReset();
  });

  it('does not run during local development or automated tests', async () => {
    vi.stubEnv('NODE_ENV', 'test');
    const { enforceAssessmentResponseRateLimit } = await import('./rate-limit');

    await enforceAssessmentResponseRateLimit(new Request('http://localhost/api/assessment-response'));

    expect(checkRateLimit).not.toHaveBeenCalled();
  });

  it('allows a production request below the configured limit', async () => {
    vi.stubEnv('NODE_ENV', 'production');
    checkRateLimit.mockResolvedValue({ rateLimited: false });
    const { ASSESSMENT_RESPONSE_RATE_LIMIT_ID, enforceAssessmentResponseRateLimit } = await import('./rate-limit');
    const request = new Request('https://consulting.leademergence.com/api/assessment-response');

    await expect(enforceAssessmentResponseRateLimit(request)).resolves.toBeUndefined();
    expect(checkRateLimit).toHaveBeenCalledWith(ASSESSMENT_RESPONSE_RATE_LIMIT_ID, { request });
  });

  it('returns a typed 429 condition when the production limit is exceeded', async () => {
    vi.stubEnv('NODE_ENV', 'production');
    checkRateLimit.mockResolvedValue({ rateLimited: true });
    const { enforceAssessmentResponseRateLimit } = await import('./rate-limit');

    await expect(
      enforceAssessmentResponseRateLimit(new Request('https://consulting.leademergence.com/api/assessment-response')),
    ).rejects.toMatchObject({ kind: 'RATE_LIMITED', status: 429 });
  });

  it('fails open when the firewall check is unavailable', async () => {
    vi.stubEnv('NODE_ENV', 'production');
    checkRateLimit.mockRejectedValue(new Error('Firewall unavailable'));
    const consoleError = vi.spyOn(console, 'error').mockImplementation(() => undefined);
    const { enforceAssessmentResponseRateLimit } = await import('./rate-limit');

    await expect(
      enforceAssessmentResponseRateLimit(new Request('https://consulting.leademergence.com/api/assessment-response')),
    ).resolves.toBeUndefined();
    expect(consoleError).toHaveBeenCalled();
    consoleError.mockRestore();
  });
});
