import { afterEach, describe, expect, it, vi } from 'vitest';
import { authorizationError, dataAccessError, notFoundError, validationError } from '@/lib/errors';
import { apiErrorResponse } from './responses';

afterEach(() => {
  vi.restoreAllMocks();
});

async function payload(response: Response) {
  return (await response.json()) as { error: string };
}

describe('apiErrorResponse', () => {
  it('reports each application error with its own status and safe message', async () => {
    const cases = [
      [validationError('Provide a statement.'), 400],
      [authorizationError('Assigned consultant authorization is required.'), 403],
      [notFoundError('Meeting is not available.'), 404],
    ] as const;
    for (const [error, status] of cases) {
      const response = apiErrorResponse('api.test', error, 'Action failed.');
      expect(response.status).toBe(status);
      expect((await payload(response)).error).toBe(error.message);
    }
  });

  it('reports an unexpected failure as a logged 500 without leaking internals', async () => {
    const logged = vi.spyOn(console, 'error').mockImplementation(() => {});
    const response = apiErrorResponse('api.test', new Error('relation "people" does not exist'), 'Action failed.');
    expect(response.status).toBe(500);
    expect((await payload(response)).error).toBe('Action failed.');
    expect(logged).toHaveBeenCalledOnce();
  });

  it('reports a failed data operation generically', async () => {
    vi.spyOn(console, 'error').mockImplementation(() => {});
    const response = apiErrorResponse('api.test', dataAccessError('scope', { message: 'permission denied' }), 'Action failed.');
    expect(response.status).toBe(500);
    expect((await payload(response)).error).not.toContain('permission denied');
  });

  it('rethrows Next.js redirect control flow instead of answering with JSON', () => {
    const redirectError = Object.assign(new Error('NEXT_REDIRECT'), { digest: 'NEXT_REDIRECT;replace;/login;307;' });
    expect(() => apiErrorResponse('api.test', redirectError, 'Action failed.')).toThrow(redirectError);
  });
});
