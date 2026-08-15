import { describe, expect, it, vi } from 'vitest';
import { dataAccessError } from './errors';

describe('dataAccessError', () => {
  it('replaces provider detail with a generic client message and logs the detail', () => {
    const log = vi.spyOn(console, 'error').mockImplementation(() => undefined);
    const error = dataAccessError({ message: 'permission denied for table consulting_private.private_records' }, 'lib/test');
    expect(error.message).toBe('The request could not be completed. Please retry or contact your consultant.');
    expect(log).toHaveBeenCalledWith(expect.stringContaining('permission denied for table'));
    log.mockRestore();
  });
});
