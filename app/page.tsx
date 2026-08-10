import { redirect } from 'next/navigation';
import { getPortalSession } from '@/lib/portal/context';

export default async function EntryPage() {
  const session = await getPortalSession();
  if (!session) redirect('/login');
  redirect(session.role === 'consultant' ? '/consultant' : '/client');
}
