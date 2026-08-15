export type AppErrorKind =
  | 'VALIDATION'
  | 'AUTHENTICATION'
  | 'AUTHORIZATION'
  | 'NOT_FOUND'
  | 'CONFLICT'
  | 'PAYLOAD_TOO_LARGE'
  | 'UNPROCESSABLE'
  | 'RATE_LIMITED'
  | 'DATA_ACCESS'
  | 'UNAVAILABLE';

const statusByKind: Record<AppErrorKind, number> = {
  VALIDATION: 400,
  AUTHENTICATION: 401,
  AUTHORIZATION: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  PAYLOAD_TOO_LARGE: 413,
  UNPROCESSABLE: 422,
  RATE_LIMITED: 429,
  DATA_ACCESS: 500,
  UNAVAILABLE: 503,
};

/**
 * An error whose message is safe to return to the requesting client and whose
 * kind determines the transport status. Anything that is not an AppError is an
 * unexpected failure: it is logged with its cause and reported generically.
 */
export class AppError extends Error {
  readonly kind: AppErrorKind;
  readonly status: number;
  readonly scope?: string;

  constructor(message: string, kind: AppErrorKind = 'VALIDATION', options: { cause?: unknown; scope?: string } = {}) {
    super(message, { cause: options.cause });
    this.name = 'AppError';
    this.kind = kind;
    this.status = statusByKind[kind];
    this.scope = options.scope;
  }
}

export function isAppError(value: unknown): value is AppError {
  return value instanceof AppError;
}

export function validationError(message: string, options?: { cause?: unknown; scope?: string }) {
  return new AppError(message, 'VALIDATION', options);
}

export function authenticationError(message: string, options?: { cause?: unknown; scope?: string }) {
  return new AppError(message, 'AUTHENTICATION', options);
}

export function authorizationError(message: string, options?: { cause?: unknown; scope?: string }) {
  return new AppError(message, 'AUTHORIZATION', options);
}

export function notFoundError(message: string, options?: { cause?: unknown; scope?: string }) {
  return new AppError(message, 'NOT_FOUND', options);
}

export function conflictError(message: string, options?: { cause?: unknown; scope?: string }) {
  return new AppError(message, 'CONFLICT', options);
}

export function payloadTooLargeError(message = 'The request payload is too large.') {
  return new AppError(message, 'PAYLOAD_TOO_LARGE');
}

export function unprocessableError(message: string, options?: { cause?: unknown; scope?: string }) {
  return new AppError(message, 'UNPROCESSABLE', options);
}

export function rateLimitedError(message = 'Too many requests. Please wait and try again.') {
  return new AppError(message, 'RATE_LIMITED');
}

export function unavailableError(message: string, options?: { cause?: unknown; scope?: string }) {
  return new AppError(message, 'UNAVAILABLE', options);
}

/**
 * Wraps a failed data operation. The underlying database message is preserved
 * as the cause for server logs and never returned to the client.
 */
export function dataAccessError(
  scope: string,
  cause: unknown,
  message = 'The requested data operation could not be completed.',
) {
  return new AppError(message, 'DATA_ACCESS', { cause, scope });
}

export function clientMessage(error: unknown, fallback: string) {
  return isAppError(error) ? error.message : fallback;
}

export function logError(scope: string, error: unknown) {
  console.error(`[${scope}]`, describeError(error));
}

export function describeError(error: unknown): Record<string, unknown> {
  if (error instanceof Error) {
    const described: Record<string, unknown> = { name: error.name, message: error.message, stack: error.stack };
    if (isAppError(error)) {
      described.kind = error.kind;
      described.status = error.status;
      if (error.scope) described.scope = error.scope;
    }
    if (error.cause !== undefined) described.cause = describeError(error.cause);
    return described;
  }
  if (error && typeof error === 'object') {
    const record = error as Record<string, unknown>;
    const described: Record<string, unknown> = {};
    for (const key of ['message', 'code', 'details', 'hint', 'status', 'name']) {
      if (record[key] !== undefined) described[key] = record[key];
    }
    return Object.keys(described).length ? described : { value: String(error) };
  }
  return { value: String(error) };
}
