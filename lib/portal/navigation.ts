export function safeReturnPath(value: string | null) {
  if (!value || !value.startsWith('/') || value.startsWith('//')) return '/';
  if (value.includes('\\') || /[\u0000-\u001F\u007F]/.test(value)) return '/';
  try {
    const parsed = new URL(value, 'https://consulting.leademergence.invalid');
    if (parsed.origin !== 'https://consulting.leademergence.invalid') return '/';
    return `${parsed.pathname}${parsed.search}${parsed.hash}`;
  } catch {
    return '/';
  }
}
