import { describe, expect, it } from 'vitest';
import { dataAccessError } from './errors';

describe('dataAccessError', () => {
  it('preserves provider detail only as a typed internal cause', () => {
    const cause = { message: 'permission denied for table consulting_private.private_records' };
    const error = dataAccessError(cause, 'lib/test');
    expect(error.message).toBe('The request could not be completed. Please retry or contact your consultant.');
    expect(error.status).toBe(500);
    expect(error.cause).toBe(cause);
  });
});
