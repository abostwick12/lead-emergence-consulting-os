import { notFound } from 'next/navigation';
import { headers } from 'next/headers';
import { PageIntro } from '@/components/portal/dashboard';
import { MeetingCenter } from '@/components/meetings/meeting-center';
import { requirePortalRole } from '@/lib/portal/context';
import { getMeetingCenter } from '@/lib/meetings/repository';
import { McpConnectionCenter, type ConnectedAiGrant } from '@/components/mcp/mcp-connection-center';
import { mcpOAuthReadiness, mcpResourceUrl } from '@/lib/mcp/configuration';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { EntryIdentityConnection } from '@/components/portal/entry-identity-connection';

const sections: Record<string, { title: string; description: string; message: string }> = {
  meetings: { title: 'Meetings', description: 'Prepare, meet, capture, decide, commit, and follow up in one traceable interaction record.', message: '' },
  resources: { title: 'Resources', description: 'Reusable consulting materials with explicit visibility.', message: 'Resource composition will build on the approved artifact model. No ungoverned file library is active.' },
  settings: { title: 'Settings', description: 'Portal preferences and current access context.', message: 'Access comes from Consulting assignments and memberships. Organization structure roles do not grant software authorization.' },
};

export default async function ConsultantSection({ params }: { params: Promise<{ section: string }> }) {
  const session = await requirePortalRole('consultant');
  const { section } = await params;
  const content = sections[section];
  if (!content) notFound();
  if (section === 'meetings') return <><PageIntro eyebrow={session.organization.name} title={content.title} description={content.description} /><MeetingCenter initialData={await getMeetingCenter(session)} /></>;
  if (section === 'settings') {
    const readiness = await mcpOAuthReadiness();
    let requestOrigin: string | undefined;
    if (session.fixture) {
      const requestHeaders = await headers();
      const host = requestHeaders.get('host');
      if (host) requestOrigin = `http://${host}`;
    }
    let grants: ConnectedAiGrant[] = [];
    if (!session.fixture) {
      const { data } = await (await createSupabaseServerClient()).auth.oauth.listGrants();
      grants = (data ?? []).map((grant) => ({ clientId: grant.client.id, name: grant.client.name, website: grant.client.uri || undefined, grantedAt: grant.granted_at }));
    }
    return <><PageIntro eyebrow="Consultant portal" title={content.title} description="Manage secure identity, AI assistant connections, and your current access context." /><EntryIdentityConnection /><McpConnectionCenter endpoint={mcpResourceUrl(requestOrigin).toString()} readiness={readiness} grants={grants} /></>;
  }
  return <><PageIntro eyebrow="Consultant portal" title={content.title} description={content.description} /><section className="empty-state large"><strong>Deliberately bounded</strong><p>{content.message}</p></section></>;
}
