interface QueryResult {
  error: { message: string } | null;
}

export function throwOnError(...results: QueryResult[]) {
  for (const result of results) if (result.error) throw new Error(result.error.message);
}
