/**
 * Fixture-mode state lives on `globalThis` so it survives module reloads between
 * requests in development and end-to-end runs.
 */
export interface FixtureStore<T> {
  read(): T;
  write(value: T): T;
  reset(): void;
}

declare global {
  var __leFixtureStores: Map<string, unknown> | undefined;
}

function stores() {
  globalThis.__leFixtureStores ??= new Map<string, unknown>();
  return globalThis.__leFixtureStores;
}

export function createFixtureStore<T>(key: string, initial: () => T): FixtureStore<T> {
  return {
    read() {
      if (!stores().has(key)) stores().set(key, initial());
      return stores().get(key) as T;
    },
    write(value: T) {
      stores().set(key, value);
      return value;
    },
    reset() {
      stores().set(key, initial());
    },
  };
}
