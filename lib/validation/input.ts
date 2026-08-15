/**
 * Shared reading of untrusted JSON mutation payloads. Every workflow validator
 * needs the same primitives: reject non-objects, trim string fields, require
 * fields, and constrain a field to a fixed set of values.
 */
export interface InputReader {
  raw: Record<string, unknown>;
  /** Trimmed string value, or `''` when the field is absent or not a string. */
  text(key: string): string;
  /** Trimmed string value, throwing when it is missing or blank. */
  required(key: string): string;
  /** Trimmed string value, or `undefined` when absent or blank. */
  optional(key: string): string | undefined;
  /** Required trimmed string value constrained to `allowed`. */
  oneOf<T extends string>(key: string, allowed: readonly T[], message?: string): T;
}

export function objectInput(value: unknown, message: string): InputReader {
  if (!value || typeof value !== 'object') throw new Error(message);
  const raw = value as Record<string, unknown>;
  const text = (key: string) => (typeof raw[key] === 'string' ? (raw[key] as string).trim() : '');
  const required = (key: string) => {
    const field = text(key);
    if (!field) throw new Error(`${key} is required.`);
    return field;
  };
  return {
    raw,
    text,
    required,
    optional: (key: string) => text(key) || undefined,
    oneOf<T extends string>(key: string, allowed: readonly T[], invalidMessage = `${key} is invalid.`) {
      const field = required(key);
      if (!allowed.includes(field as T)) throw new Error(invalidMessage);
      return field as T;
    },
  };
}
