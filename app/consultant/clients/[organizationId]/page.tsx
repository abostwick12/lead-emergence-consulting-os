import { redirect } from 'next/navigation';

export default async function OrganizationEntry({ params }: { params: Promise<{ organizationId: string }> }) {
  const { organizationId } = await params;
  redirect(`/consultant/clients/${organizationId}/overview`);
}
