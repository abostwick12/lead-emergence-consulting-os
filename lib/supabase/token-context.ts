import 'server-only';

import { AsyncLocalStorage } from 'node:async_hooks';

const accessTokenStorage = new AsyncLocalStorage<string>();

export function runWithSupabaseAccessToken<T>(accessToken: string, operation: () => T): T {
  return accessTokenStorage.run(accessToken, operation);
}

export function currentSupabaseAccessToken() {
  return accessTokenStorage.getStore();
}
