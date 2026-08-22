import { createClient } from '@supabase/supabase-js';
import { execFileSync } from 'node:child_process';

const PERSON_ID = 'd2000000-0000-4000-8000-000000000002';
const ORGANIZATION_ID = 'd3000000-0000-4000-8000-000000000002';
const ENGAGEMENT_ID = 'd4000000-0000-4000-8000-000000000002';
const MEMBERSHIP_ID = 'd5000000-0000-4000-8000-000000000002';
const ENGAGEMENT_MEMBERSHIP_ID = 'd6000000-0000-4000-8000-000000000002';
const CANONICAL_LINK_ID = 'da000000-0000-4000-8000-000000000002';
const CONSULTANT_PERSON_ID = 'd2000000-0000-4000-8000-000000000003';
const CONSULTANT_ASSIGNMENT_ID = 'd7000000-0000-4000-8000-000000000003';
const WRONG_ORGANIZATION_ID = 'd3000000-0000-4000-8000-000000000003';
const WRONG_ENGAGEMENT_ID = 'd4000000-0000-4000-8000-000000000003';
const MEETING_ID = 'd8000000-0000-4000-8000-000000000002';
const PRIVATE_NOTE_ID = 'd9000000-0000-4000-8000-000000000002';

function required(name) {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} is required`);
  return value;
}

const email = required('LOCAL_CONSULTING_TEST_EMAIL').toLowerCase();
if (!email.endsWith('.test')) throw new Error('Synthetic Consulting email must use the reserved .test domain');
const admin = createClient(required('LOCAL_CONSULTING_SUPABASE_URL'), required('LOCAL_CONSULTING_SECRET_KEY'), {
  db: { schema: 'consulting_os' },
  auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
});
const listed = await admin.auth.admin.listUsers({ page: 1, perPage: 1000 });
if (listed.error) throw listed.error;
const existing = listed.data.users.find((user) => user.email?.toLowerCase() === email);
const attributes = {
  email,
  password: required('LOCAL_CONSULTING_TEST_PASSWORD'),
  email_confirm: true,
  user_metadata: { display_name: 'Existing Consulting acceptance client', synthetic_test: true },
};
const authResult = existing
  ? await admin.auth.admin.updateUserById(existing.id, attributes)
  : await admin.auth.admin.createUser(attributes);
if (authResult.error || !authResult.data.user) throw authResult.error ?? new Error('Synthetic Consulting user unavailable');
const authUserId = authResult.data.user.id;
const canonicalUserId = required('ENTRY_DEV_TEST_USER_ID');

const consultantEmail = 'codex-consulting-matrix-consultant@example.test';
const consultantExisting = listed.data.users.find((user) => user.email?.toLowerCase() === consultantEmail);
const consultantAuth = consultantExisting
  ? await admin.auth.admin.updateUserById(consultantExisting.id, {
      email: consultantEmail,
      password: required('LOCAL_CONSULTING_TEST_PASSWORD'),
      email_confirm: true,
      user_metadata: { display_name: 'Synthetic matrix consultant', synthetic_test: true },
    })
  : await admin.auth.admin.createUser({
      email: consultantEmail,
      password: required('LOCAL_CONSULTING_TEST_PASSWORD'),
      email_confirm: true,
      user_metadata: { display_name: 'Synthetic matrix consultant', synthetic_test: true },
    });
if (consultantAuth.error || !consultantAuth.data.user) throw consultantAuth.error ?? new Error('Synthetic matrix consultant unavailable');

const person = await admin.from('people').upsert({
  id: PERSON_ID,
  auth_user_id: authUserId,
  display_name: 'Existing Consulting acceptance client',
});
if (person.error) throw person.error;
const consultantPerson = await admin.from('people').upsert({
  id: CONSULTANT_PERSON_ID,
  auth_user_id: consultantAuth.data.user.id,
  display_name: 'Synthetic matrix consultant',
});
if (consultantPerson.error) throw consultantPerson.error;
const organization = await admin.from('organizations').upsert({
    id: ORGANIZATION_ID,
    name: 'Synthetic Acceptance Organization',
    slug: 'synthetic-acceptance-organization',
    is_active: true,
    created_by: PERSON_ID,
  });
if (organization.error) throw organization.error;
for (const operation of [
  admin.from('engagements').upsert({
    id: ENGAGEMENT_ID,
    organization_id: ORGANIZATION_ID,
    name: 'Synthetic Acceptance Engagement',
    status: 'ACTIVE',
    created_by: PERSON_ID,
  }),
  admin.from('organization_memberships').upsert({
    id: MEMBERSHIP_ID,
    organization_id: ORGANIZATION_ID,
    person_id: PERSON_ID,
    platform_role: 'CLIENT_ADMIN',
    status: 'ACTIVE',
    created_by: PERSON_ID,
  }),
]) {
  const result = await operation;
  if (result.error) throw result.error;
}
const engagementMembership = await admin.from('engagement_memberships').upsert({
  id: ENGAGEMENT_MEMBERSHIP_ID,
  organization_id: ORGANIZATION_ID,
  engagement_id: ENGAGEMENT_ID,
  organization_membership_id: MEMBERSHIP_ID,
  status: 'ACTIVE',
  created_by: PERSON_ID,
});
if (engagementMembership.error) throw engagementMembership.error;
const canonicalLink = await admin.from('canonical_identity_links').upsert({
  id: CANONICAL_LINK_ID,
  person_id: PERSON_ID,
  canonical_user_id: canonicalUserId,
  status: 'PENDING_VERIFICATION',
  proof_type: 'FUTURE_ENTRY_HANDOFF',
  linked_at: null,
  revoked_at: null,
  auth_user_id: null,
  provider_identifier: null,
  provider_subject: null,
  provider_identity_id: null,
});
if (canonicalLink.error) throw canonicalLink.error;

for (const operation of [
  admin.from('consultant_assignments').upsert({
    id: CONSULTANT_ASSIGNMENT_ID,
    organization_id: ORGANIZATION_ID,
    consultant_person_id: CONSULTANT_PERSON_ID,
    status: 'ACTIVE',
    assignment_reason: 'Synthetic SSO authorization matrix',
    created_by: CONSULTANT_PERSON_ID,
  }),
  admin.from('organizations').upsert({
    id: WRONG_ORGANIZATION_ID,
    name: 'Synthetic Wrong Tenant Organization',
    slug: 'synthetic-wrong-tenant-organization',
    is_active: true,
    created_by: CONSULTANT_PERSON_ID,
  }),
  admin.from('engagements').upsert({
    id: WRONG_ENGAGEMENT_ID,
    organization_id: WRONG_ORGANIZATION_ID,
    name: 'Synthetic Wrong Tenant Engagement',
    status: 'ACTIVE',
    created_by: CONSULTANT_PERSON_ID,
  }),
]) {
  const result = await operation;
  if (result.error) throw result.error;
}

const domainObjects = await admin.from('domain_objects').upsert([
  {
    id: MEETING_ID,
    organization_id: ORGANIZATION_ID,
    engagement_id: ENGAGEMENT_ID,
    object_type: 'MEETING',
    visibility_scope: 'ENGAGEMENT_SHARED',
    owner_person_id: null,
    origin: 'HUMAN',
    created_by: CONSULTANT_PERSON_ID,
  },
  {
    id: PRIVATE_NOTE_ID,
    organization_id: ORGANIZATION_ID,
    engagement_id: ENGAGEMENT_ID,
    object_type: 'MEETING_NOTE',
    visibility_scope: 'CONSULTANT_PRIVATE',
    owner_person_id: CONSULTANT_PERSON_ID,
    origin: 'HUMAN',
    created_by: CONSULTANT_PERSON_ID,
  },
]);
if (domainObjects.error) throw domainObjects.error;
const meeting = await admin.from('meetings').upsert({
  id: MEETING_ID,
  organization_id: ORGANIZATION_ID,
  engagement_id: ENGAGEMENT_ID,
  meeting_type: 'CONSULTING',
  title: 'Synthetic SSO privacy boundary',
  purpose: 'Prove client sessions cannot read consultant-private material',
  scheduled_start: '2026-08-21T18:00:00.000Z',
  status: 'PREPARED',
  current_phase: 'PREPARE',
  agenda: 'Authorization boundary verification',
  created_by: CONSULTANT_PERSON_ID,
});
if (meeting.error) throw meeting.error;
const participants = await admin.from('meeting_participants').upsert([
  { organization_id: ORGANIZATION_ID, meeting_id: MEETING_ID, person_id: CONSULTANT_PERSON_ID, participant_role: 'FACILITATOR', created_by: CONSULTANT_PERSON_ID },
  { organization_id: ORGANIZATION_ID, meeting_id: MEETING_ID, person_id: PERSON_ID, participant_role: 'PARTICIPANT', created_by: CONSULTANT_PERSON_ID },
], { onConflict: 'meeting_id,person_id' });
if (participants.error) throw participants.error;
const dbContainer = process.env.LOCAL_CONSULTING_DB_CONTAINER?.trim() || 'supabase_db_consulting-os-phase1';
execFileSync('docker', [
  'exec', dbContainer, 'psql', '-U', 'postgres', '-d', 'postgres', '-v', 'ON_ERROR_STOP=1', '-c',
  `insert into consulting_private.meeting_notes(id,organization_id,meeting_id,kind,subject_person_id,author_person_id,content)
   values ('${PRIVATE_NOTE_ID}','${ORGANIZATION_ID}','${MEETING_ID}','CONSULTANT_NOTE','${PERSON_ID}','${CONSULTANT_PERSON_ID}','SYNTHETIC_PRIVATE_NOTE_MUST_NOT_REACH_CLIENT')
   on conflict (id) do update set content=excluded.content, subject_person_id=excluded.subject_person_id, author_person_id=excluded.author_person_id;`,
], { stdio: ['ignore', 'ignore', 'inherit'] });

console.log(JSON.stringify({
  authUserId,
  personId: PERSON_ID,
  organizationId: ORGANIZATION_ID,
  engagementId: ENGAGEMENT_ID,
  canonicalLinkId: CANONICAL_LINK_ID,
  wrongOrganizationId: WRONG_ORGANIZATION_ID,
  wrongEngagementId: WRONG_ENGAGEMENT_ID,
  privateMeetingId: MEETING_ID,
  organizationName: 'Synthetic Acceptance Organization',
  engagementName: 'Synthetic Acceptance Engagement',
  created: !existing,
}));
