'use client';

import { useEffect } from 'react';
import { logError } from '@/lib/errors';

export default function ErrorPage({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  useEffect(() => {
    logError('app.errorBoundary', error);
  }, [error]);
  return <main className="standalone-message"><p className="eyebrow">Something interrupted the view</p><h1>We could not load this workspace.</h1><p>No record was changed. Try loading the view again.</p><button className="primary-button" onClick={() => reset()}>Try again</button></main>;
}
