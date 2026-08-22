import type { NextConfig } from 'next';

const isProduction = process.env.NODE_ENV === 'production';

function configuredOrigin(value: string | undefined) {
  if (!value) return null;
  try {
    return new URL(value).origin;
  } catch {
    return null;
  }
}

function contentSecurityPolicy() {
  const supabase = configuredOrigin(process.env.NEXT_PUBLIC_SUPABASE_URL);
  const entryOidc = configuredOrigin(process.env.ENTRY_OIDC_ISSUER_URL);
  const entryApp = configuredOrigin(process.env.ENTRY_APP_ORIGIN);
  const connect = ["'self'", supabase, supabase ? `wss://${new URL(supabase).host}` : null, entryOidc, entryApp, isProduction ? null : 'ws:']
    .filter(Boolean)
    .join(' ');
  return [
    "default-src 'self'",
    "base-uri 'self'",
    "object-src 'none'",
    "frame-ancestors 'none'",
    "form-action 'self'",
    "img-src 'self' data: blob:",
    "font-src 'self' data:",
    "style-src 'self' 'unsafe-inline'",
    // Next.js inlines its hydration bootstrap; nonce-based script policy is a
    // follow-up that requires moving every route onto dynamic rendering.
    `script-src 'self' 'unsafe-inline'${isProduction ? '' : " 'unsafe-eval'"}`,
    `connect-src ${connect}`,
  ].join('; ');
}

const securityHeaders = [
  { key: 'Content-Security-Policy', value: contentSecurityPolicy() },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=(), payment=()' },
  { key: 'Cross-Origin-Opener-Policy', value: 'same-origin' },
  ...(isProduction ? [{ key: 'Strict-Transport-Security', value: 'max-age=31536000; includeSubDomains' }] : []),
];

const nextConfig: NextConfig = {
  poweredByHeader: false,
  reactStrictMode: true,
  devIndicators: false,
  turbopack: { root: process.cwd() },
  outputFileTracingIncludes: {
    '/api/assessment-instruments/*': ['./assets/assessments/**/*'],
  },
  async headers() {
    return [{ source: '/:path*', headers: securityHeaders }];
  },
};

export default nextConfig;
