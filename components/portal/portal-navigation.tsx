'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  BarChart3,
  Building2,
  CalendarDays,
  FolderKanban,
  GraduationCap,
  House,
  Library,
  Settings,
  UsersRound,
  type LucideIcon,
} from 'lucide-react';

export type PortalNavItem = {
  href: string;
  label: string;
  icon: 'home' | 'clients' | 'organization' | 'development' | 'meetings' | 'resources' | 'progress' | 'settings';
};

const icons: Record<PortalNavItem['icon'], LucideIcon> = {
  home: House,
  clients: UsersRound,
  organization: Building2,
  development: GraduationCap,
  meetings: CalendarDays,
  resources: Library,
  progress: BarChart3,
  settings: Settings,
};

function isActive(pathname: string, href: string): boolean {
  const rootRoute = href === '/consultant' || href === '/client';
  return rootRoute ? pathname === href : pathname === href || pathname.startsWith(`${href}/`);
}

export function PortalNavigation({ items, mobile = false }: { items: PortalNavItem[]; mobile?: boolean }) {
  const pathname = usePathname();
  return (
    <nav className={mobile ? 'portal-nav portal-nav-mobile' : 'portal-nav'} aria-label={mobile ? 'Mobile navigation' : 'Primary navigation'}>
      {items.map((item) => {
        const Icon = icons[item.icon] ?? FolderKanban;
        return (
          <Link className={isActive(pathname, item.href) ? 'active' : undefined} key={item.href} href={item.href}>
            <Icon aria-hidden="true" />
            <span>{item.label}</span>
          </Link>
        );
      })}
    </nav>
  );
}
