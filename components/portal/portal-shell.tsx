import Link from 'next/link';
import { LogOut } from 'lucide-react';
import type { PortalSession } from '@/lib/portal/types';
import { PortalNavigation, type PortalNavItem } from './portal-navigation';

const consultantNav: PortalNavItem[] = [
  { href: '/consultant', label: 'Home', icon: 'home' },
  { href: '/consultant/clients', label: 'Clients', icon: 'clients' },
  { href: '/consultant/meetings', label: 'Meetings', icon: 'meetings' },
  { href: '/consultant/resources', label: 'Resources', icon: 'resources' },
  { href: '/consultant/settings', label: 'Settings', icon: 'settings' },
];

const clientNav: PortalNavItem[] = [
  { href: '/client', label: 'Home', icon: 'home' },
  { href: '/client/our-organization', label: 'Our Organization', icon: 'organization' },
  { href: '/client/my-development', label: 'My Development', icon: 'development' },
  { href: '/client/meetings', label: 'Meetings', icon: 'meetings' },
  { href: '/client/progress', label: 'Progress', icon: 'progress' },
  { href: '/client/settings', label: 'Settings', icon: 'settings' },
];

export function PortalShell({ session, children }: { session: PortalSession; children: React.ReactNode }) {
  const nav = session.role === 'consultant' ? consultantNav : clientNav;
  return (
    <div className="portal-frame">
      <a className="skip-link" href="#main-content">Skip to content</a>
      <aside className="sidebar">
        <Link href={session.role === 'consultant' ? '/consultant' : '/client'} className="brand" aria-label="Lead Emergence Consulting OS">
          <span className="brand-wordmark"><strong><i>Lead</i> Emergence</strong><small>CONSULTING OS</small></span>
        </Link>
        <div className="portal-label">{session.role === 'consultant' ? 'Consultant portal' : 'Client portal'}</div>
        <PortalNavigation items={nav} />
        <div className="sidebar-profile">
          <span className="avatar">{session.displayName.split(' ').map((part) => part[0]).join('')}</span>
          <div><strong>{session.displayName}</strong><small>{session.role === 'consultant' ? 'Consultant' : 'Organization member'}</small></div>
        </div>
        <form action="/auth/sign-out" method="post"><button className="text-button" type="submit"><LogOut aria-hidden="true" /> Sign out</button></form>
      </aside>
      <div className="portal-body">
        <header className="context-header">
          <div>
            <span className="context-label">Organization</span>
            <strong data-testid="current-organization">{session.organization.name}</strong>
          </div>
          <div>
            <span className="context-label">Engagement</span>
            <strong data-testid="current-engagement">{session.engagement.name}</strong>
          </div>
          <span className="engagement-status">{session.engagement.status}</span>
        </header>
        <main id="main-content" className="portal-main">{children}</main>
        <div className="mobile-nav">
          <PortalNavigation items={nav.slice(0, 5)} mobile />
        </div>
      </div>
    </div>
  );
}
