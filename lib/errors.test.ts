import { describe, expect, it } from 'vitest';
import {
  AppError,
  authorizationError,
  clientMessage,
  dataAccessError,
  describeError,
  isAppError,
  notFoundError,
  validationError,
} from './errors';

describe('application errors', () => {
  it('maps each kind to the transport status it represents', () => {
    expect(validationError('bad input').status).toBe(400);
    expect(authorizationError('not allowed').status).toBe(403);
    expect(notFoundError('missing').status).toBe(404);
    expect(dataAccessError('scope', new Error('relation does not exist')).status).toBe(500);
  });

  it('keeps a failed data operation message generic while preserving the cause for logs', () => {
    const failure = { message: 'permission denied for table people', code: '42501' };
    const error = dataAccessError('portal.session.person', failure);
    expect(error.message).not.toContain('permission denied');
    expect(describeError(error).cause).toMatchObject({ message: failure.message, code: failure.code });
  });

  it('returns the fallback message for anything that is not an application error', () => {
    expect(clientMessage(new Error('internal detail'), 'Action failed.')).toBe('Action failed.');
    expect(clientMessage(validationError('Provide a statement.'), 'Action failed.')).toBe('Provide a statement.');
  });

  it('recognises application errors and nested causes', () => {
    expect(isAppError(new AppError('bad', 'VALIDATION'))).toBe(true);
    expect(isAppError(new Error('bad'))).toBe(false);
    const described = describeError(new AppError('outer', 'CONFLICT', { cause: new Error('inner') }));
    expect(described).toMatchObject({ kind: 'CONFLICT', status: 409 });
    expect(described.cause).toMatchObject({ message: 'inner' });
  });
});
