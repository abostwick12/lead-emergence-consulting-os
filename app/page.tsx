import type { Metadata } from 'next';
import { LandingExperience } from '@/components/landing/landing-experience';

export const metadata: Metadata = {
  title: 'Lead Emergence',
  description: 'Technology for leaders building organizations and ministries where people, purpose, and systems can flourish together.',
};

export default function EntryPage() {
  return <LandingExperience />;
}
