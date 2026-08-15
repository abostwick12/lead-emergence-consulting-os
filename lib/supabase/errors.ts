import { dataAccessError } from '@/lib/errors';

export interface SupabaseFailure {
  message: string;
  code?: string;
  details?: string | null;
  hint?: string | null;
}

export interface SupabaseResult<T> {
  data: T;
  error: SupabaseFailure | null;
}

/** Returns the rows of a Supabase result, converting a failed query into a reportable error. */
export function unwrap<T>(scope: string, result: SupabaseResult<T>): T {
  if (result.error) throw dataAccessError(scope, result.error);
  return result.data;
}

/** Fails as soon as any of the supplied Supabase results carries an error. */
export function assertSucceeded(scope: string, ...results: Array<{ error: SupabaseFailure | null }>) {
  for (const result of results) {
    if (result.error) throw dataAccessError(scope, result.error);
  }
}
