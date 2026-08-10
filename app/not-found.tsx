import Link from 'next/link';

export default function NotFound() {
  return <main className="standalone-message"><p className="eyebrow">Unavailable</p><h1>This record or workspace is not available.</h1><p>It may not exist, or your current organization, engagement, and visibility scope do not permit access.</p><Link className="primary-button" href="/">Return to your portal</Link></main>;
}
