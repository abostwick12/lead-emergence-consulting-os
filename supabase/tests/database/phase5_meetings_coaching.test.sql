begin;
select plan(46);

select has_table('consulting_os', 'meetings', 'shared meeting engine exists');
select has_table('consulting_os', 'coaching_relationships', 'coaching relationship is first-class');
select has_table('consulting_private', 'meeting_notes', 'private meeting notes are physically partitioned');
select has_view('consulting_os', 'phase5_organizational_intelligence_sources', 'privacy-safe organizational intelligence projection exists');

insert into auth.users (id, email, role, aud, raw_app_meta_data, raw_user_meta_data, created_at, updated_at) values
  ('81000000-0000-4000-8000-000000000001', 'phase5-consultant@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('81000000-0000-4000-8000-000000000002', 'phase5-client@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('81000000-0000-4000-8000-000000000003', 'phase5-leader@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('81000000-0000-4000-8000-000000000004', 'phase5-other@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now());

insert into consulting_os.people (id, auth_user_id, display_name) values
  ('82000000-0000-4000-8000-000000000001', '81000000-0000-4000-8000-000000000001', 'Phase 5 Consultant'),
  ('82000000-0000-4000-8000-000000000002', '81000000-0000-4000-8000-000000000002', 'Phase 5 Participant'),
  ('82000000-0000-4000-8000-000000000003', '81000000-0000-4000-8000-000000000003', 'Unrelated Leader'),
  ('82000000-0000-4000-8000-000000000004', '81000000-0000-4000-8000-000000000004', 'Other Tenant User');

insert into consulting_os.organizations (id, name, slug, created_by) values
  ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Phase 5 Organization', 'phase5-organization', '82000000-0000-4000-8000-000000000001'),
  ('8bbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'Other Phase 5 Organization', 'phase5-other', '82000000-0000-4000-8000-000000000004');

insert into consulting_os.consultant_assignments (id, organization_id, consultant_person_id, status, assignment_reason, created_by)
values ('82100000-0000-4000-8000-000000000001', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '82000000-0000-4000-8000-000000000001', 'ACTIVE', 'Phase 5 test assignment', '82000000-0000-4000-8000-000000000001');

insert into consulting_os.organization_memberships (id, organization_id, person_id, platform_role, status, created_by) values
  ('82200000-0000-4000-8000-000000000001', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '82000000-0000-4000-8000-000000000002', 'CLIENT_MEMBER', 'ACTIVE', '82000000-0000-4000-8000-000000000001'),
  ('82200000-0000-4000-8000-000000000002', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '82000000-0000-4000-8000-000000000003', 'CLIENT_LEADER', 'ACTIVE', '82000000-0000-4000-8000-000000000001'),
  ('82200000-0000-4000-8000-000000000003', '8bbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '82000000-0000-4000-8000-000000000004', 'CLIENT_ADMIN', 'ACTIVE', '82000000-0000-4000-8000-000000000004');

insert into consulting_os.engagements (id, organization_id, name, status, starts_on, created_by) values
  ('83000000-0000-4000-8000-000000000001', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Phase 5 Engagement', 'ACTIVE', '2026-08-01', '82000000-0000-4000-8000-000000000001'),
  ('83000000-0000-4000-8000-000000000002', '8bbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'Other Engagement', 'ACTIVE', '2026-08-01', '82000000-0000-4000-8000-000000000004');

insert into consulting_os.engagement_memberships (organization_id, engagement_id, organization_membership_id, status, created_by) values
  ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', '82200000-0000-4000-8000-000000000001', 'ACTIVE', '82000000-0000-4000-8000-000000000001'),
  ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', '82200000-0000-4000-8000-000000000002', 'ACTIVE', '82000000-0000-4000-8000-000000000001'),
  ('8bbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '83000000-0000-4000-8000-000000000002', '82200000-0000-4000-8000-000000000003', 'ACTIVE', '82000000-0000-4000-8000-000000000004');

insert into consulting_os.domain_objects (id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by) values
  ('84000000-0000-4000-8000-000000000001', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'MEETING', 'ENGAGEMENT_SHARED', null, 'HUMAN', '82000000-0000-4000-8000-000000000001'),
  ('84000000-0000-4000-8000-000000000002', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'COACHING_RELATIONSHIP', 'COACHING_SHARED', '82000000-0000-4000-8000-000000000001', 'HUMAN', '82000000-0000-4000-8000-000000000001'),
  ('84000000-0000-4000-8000-000000000003', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'COACHING_SESSION', 'COACHING_SHARED', '82000000-0000-4000-8000-000000000001', 'HUMAN', '82000000-0000-4000-8000-000000000001'),
  ('84000000-0000-4000-8000-000000000004', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'MEETING_NOTE', 'COACHING_SHARED', '82000000-0000-4000-8000-000000000001', 'HUMAN', '82000000-0000-4000-8000-000000000001'),
  ('84000000-0000-4000-8000-000000000005', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'COMMITMENT', 'COACHING_SHARED', '82000000-0000-4000-8000-000000000002', 'HUMAN', '82000000-0000-4000-8000-000000000001'),
  ('84000000-0000-4000-8000-000000000006', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'INSIGHT', 'ORGANIZATION_SHARED', null, 'HUMAN', '82000000-0000-4000-8000-000000000001'),
  ('84000000-0000-4000-8000-000000000007', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'INTERPRETATION', 'CONSULTANT_PRIVATE', '82000000-0000-4000-8000-000000000001', 'HUMAN', '82000000-0000-4000-8000-000000000001'),
  ('84000000-0000-4000-8000-000000000008', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'OBSERVATION', 'CONSULTANT_PRIVATE', '82000000-0000-4000-8000-000000000001', 'HUMAN', '82000000-0000-4000-8000-000000000001'),
  ('84000000-0000-4000-8000-000000000009', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'INSIGHT', 'CONSULTANT_PRIVATE', '82000000-0000-4000-8000-000000000001', 'HUMAN', '82000000-0000-4000-8000-000000000001'),
  ('84b00000-0000-4000-8000-000000000001', '8bbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '83000000-0000-4000-8000-000000000002', 'MEETING', 'ENGAGEMENT_SHARED', null, 'HUMAN', '82000000-0000-4000-8000-000000000004');

insert into consulting_os.meetings (id, organization_id, engagement_id, meeting_type, title, purpose, scheduled_start, status, current_phase, agenda, created_by) values
  ('84000000-0000-4000-8000-000000000001', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'CONSULTING', 'Alignment workshop', 'Agree operating boundaries', '2026-08-14 10:00+00', 'PREPARED', 'PREPARE', 'Review; decide; commit', '82000000-0000-4000-8000-000000000001'),
  ('84000000-0000-4000-8000-000000000003', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'COACHING', 'Coaching session', 'Practice decision judgment', '2026-08-12 10:00+00', 'IN_PROGRESS', 'CAPTURE', 'Review; practice; commit', '82000000-0000-4000-8000-000000000001'),
  ('84b00000-0000-4000-8000-000000000001', '8bbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '83000000-0000-4000-8000-000000000002', 'CONSULTING', 'Other tenant meeting', 'Remain isolated', '2026-08-13 10:00+00', 'PLANNED', 'PREPARE', 'Isolated', '82000000-0000-4000-8000-000000000004');

insert into consulting_os.visibility_grants (organization_id, domain_object_id, grantee_person_id, permission, created_by)
select '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', object_id, person_id, permission, '82000000-0000-4000-8000-000000000001'
from (values
  ('84000000-0000-4000-8000-000000000002'::uuid, '82000000-0000-4000-8000-000000000001'::uuid, 'MANAGE'::consulting_os.grant_permission),
  ('84000000-0000-4000-8000-000000000002'::uuid, '82000000-0000-4000-8000-000000000002'::uuid, 'READ'::consulting_os.grant_permission),
  ('84000000-0000-4000-8000-000000000003'::uuid, '82000000-0000-4000-8000-000000000001'::uuid, 'MANAGE'::consulting_os.grant_permission),
  ('84000000-0000-4000-8000-000000000003'::uuid, '82000000-0000-4000-8000-000000000002'::uuid, 'READ'::consulting_os.grant_permission)
) grants(object_id, person_id, permission);

insert into consulting_os.meeting_participants (organization_id, meeting_id, person_id, participant_role, created_by) values
  ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000001', '82000000-0000-4000-8000-000000000001', 'FACILITATOR', '82000000-0000-4000-8000-000000000001'),
  ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000001', '82000000-0000-4000-8000-000000000002', 'PARTICIPANT', '82000000-0000-4000-8000-000000000001'),
  ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000003', '82000000-0000-4000-8000-000000000001', 'FACILITATOR', '82000000-0000-4000-8000-000000000001'),
  ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000003', '82000000-0000-4000-8000-000000000002', 'PARTICIPANT', '82000000-0000-4000-8000-000000000001'),
  ('8bbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '84b00000-0000-4000-8000-000000000001', '82000000-0000-4000-8000-000000000004', 'PARTICIPANT', '82000000-0000-4000-8000-000000000004');

insert into consulting_os.coaching_relationships (id, organization_id, engagement_id, coach_person_id, participant_person_id, purpose, development_focus, confidentiality_statement, starts_on, status, created_by)
values ('84000000-0000-4000-8000-000000000002', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', '82000000-0000-4000-8000-000000000001', '82000000-0000-4000-8000-000000000002', 'Develop decision judgment', 'Escalation judgment', 'Named participants only; private reflections separate.', '2026-08-01', 'ACTIVE', '82000000-0000-4000-8000-000000000001');
insert into consulting_os.coaching_sessions (id, organization_id, coaching_relationship_id, session_number, development_focus, created_by)
values ('84000000-0000-4000-8000-000000000003', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000002', 3, 'Escalation judgment', '82000000-0000-4000-8000-000000000001');
insert into consulting_os.meeting_notes (id, organization_id, meeting_id, note_kind, content, author_person_id, created_by)
values ('84000000-0000-4000-8000-000000000004', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000003', 'SHARED_NOTE', 'Shared coaching note', '82000000-0000-4000-8000-000000000001', '82000000-0000-4000-8000-000000000001');
insert into consulting_os.commitments (id, organization_id, engagement_id, source_meeting_id, coaching_relationship_id, owner_person_id, action, due_on, status, created_by)
values ('84000000-0000-4000-8000-000000000005', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', '84000000-0000-4000-8000-000000000003', '84000000-0000-4000-8000-000000000002', '82000000-0000-4000-8000-000000000002', 'Practice two bounded decisions', '2026-08-19', 'OPEN', '82000000-0000-4000-8000-000000000001');

insert into consulting_os.visibility_grants (organization_id, domain_object_id, grantee_person_id, permission, created_by)
select '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', object_id, person_id, permission, '82000000-0000-4000-8000-000000000001'
from (values
  ('84000000-0000-4000-8000-000000000004'::uuid, '82000000-0000-4000-8000-000000000001'::uuid, 'MANAGE'::consulting_os.grant_permission),
  ('84000000-0000-4000-8000-000000000004'::uuid, '82000000-0000-4000-8000-000000000002'::uuid, 'READ'::consulting_os.grant_permission),
  ('84000000-0000-4000-8000-000000000005'::uuid, '82000000-0000-4000-8000-000000000001'::uuid, 'READ'::consulting_os.grant_permission),
  ('84000000-0000-4000-8000-000000000005'::uuid, '82000000-0000-4000-8000-000000000002'::uuid, 'READ'::consulting_os.grant_permission)
) grants(object_id, person_id, permission);

insert into consulting_os.domain_objects (id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by)
values ('84000000-0000-4000-8000-000000000010', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'INSIGHT', 'ENGAGEMENT_SHARED', 'HUMAN', '82000000-0000-4000-8000-000000000001');
select throws_ok(
  $$insert into consulting_os.meetings (id, organization_id, engagement_id, meeting_type, title, purpose, scheduled_start, agenda, created_by) values ('84000000-0000-4000-8000-000000000010', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'CONSULTING', 'Wrong registry', 'Must fail', now(), 'None', '82000000-0000-4000-8000-000000000001')$$,
  '23514', null, 'typed meeting requires the matching registry type');

insert into consulting_os.domain_objects (id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by)
values ('84000000-0000-4000-8000-000000000011', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'MEETING_NOTE', 'CONSULTANT_PRIVATE', '82000000-0000-4000-8000-000000000001', 'HUMAN', '82000000-0000-4000-8000-000000000001');
select throws_ok(
  $$insert into consulting_os.meeting_notes (id, organization_id, meeting_id, note_kind, content, author_person_id, created_by) values ('84000000-0000-4000-8000-000000000011', '8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000003', 'SHARED_NOTE', 'Must not enter shared table', '82000000-0000-4000-8000-000000000001', '82000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'private content is rejected from the shared note table');

select throws_ok(
  $$insert into consulting_os.meeting_context_items (organization_id, meeting_id, context_domain_object_id, reason, created_by) values ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000001', '84000000-0000-4000-8000-000000000007', 'Facilitator can see it but participant cannot', '82000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'preparation rejects context unavailable to every required participant');
select lives_ok(
  $$insert into consulting_os.meeting_context_items (organization_id, meeting_id, context_domain_object_id, reason, created_by) values ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000001', '84000000-0000-4000-8000-000000000006', 'Visible shared insight', '82000000-0000-4000-8000-000000000001')$$,
  'preparation accepts context visible to every required participant');
update consulting_os.meeting_participants set required_for_context = false where meeting_id = '84000000-0000-4000-8000-000000000001' and person_id = '82000000-0000-4000-8000-000000000002';
select lives_ok(
  $$insert into consulting_os.meeting_context_items (organization_id, meeting_id, context_domain_object_id, reason, created_by) values ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000001', '84000000-0000-4000-8000-000000000007', 'Facilitator-only preparation context', '82000000-0000-4000-8000-000000000001')$$,
  'facilitator-only context may be attached when the client is not required for context');
select throws_ok(
  $$update consulting_os.meeting_participants set required_for_context = true where meeting_id = '84000000-0000-4000-8000-000000000001' and person_id = '82000000-0000-4000-8000-000000000002'$$,
  '42501', null, 'a participant cannot later be made context-required when existing context is unavailable');
delete from consulting_os.meeting_context_items where meeting_id = '84000000-0000-4000-8000-000000000001' and context_domain_object_id = '84000000-0000-4000-8000-000000000007';
select lives_ok(
  $$update consulting_os.meeting_participants set required_for_context = true where meeting_id = '84000000-0000-4000-8000-000000000001' and person_id = '82000000-0000-4000-8000-000000000002'$$,
  'participant may be restored after inaccessible preparation context is removed');
select throws_ok(
  $$insert into consulting_os.meeting_participants (organization_id, meeting_id, person_id, created_by) values ('8bbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '84000000-0000-4000-8000-000000000001', '82000000-0000-4000-8000-000000000004', '82000000-0000-4000-8000-000000000004')$$,
  '42501', null, 'meeting participants cannot cross tenant boundaries');
select throws_ok(
  $$insert into consulting_os.meeting_participants (organization_id, meeting_id, person_id, created_by) values ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '84000000-0000-4000-8000-000000000001', '82000000-0000-4000-8000-000000000004', '82000000-0000-4000-8000-000000000001')$$,
  '42501', null, 'a person from another tenant cannot be smuggled into a same-tenant participant row');
select ok(not has_table_privilege('authenticated', 'consulting_private.meeting_notes', 'SELECT'), 'authenticated has no direct private-note SELECT privilege');
select ok(not has_table_privilege('authenticated', 'consulting_os.meeting_notes', 'UPDATE'), 'shared meeting notes cannot be rewritten by ordinary authenticated users');
select ok(has_column_privilege('authenticated', 'consulting_os.commitments', 'status', 'UPDATE'), 'commitment completion state remains updateable');
select ok(not has_column_privilege('authenticated', 'consulting_os.commitments', 'action', 'UPDATE'), 'commitment meaning cannot be rewritten through ordinary update grants');

set local role authenticated;
select set_config('request.jwt.claim.sub', '81000000-0000-4000-8000-000000000002', true);
select results_eq($$select count(*) from consulting_os.meetings where id = '84000000-0000-4000-8000-000000000003'$$, array[1::bigint], 'named coaching participant can read the session');
select results_eq($$select count(*) from consulting_os.meetings where organization_id = '8bbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'$$, array[0::bigint], 'client cannot read another tenant meeting');
select throws_ok($$select consulting_os.create_meeting('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'CONSULTING', 'Unauthorized meeting', 'Must not be created', '2026-08-28 10:00+00', 'None', '82000000-0000-4000-8000-000000000003', null)$$, '42501', null, 'client participant cannot invoke consultant meeting creation');
select lives_ok($$select consulting_os.create_private_meeting_note('84000000-0000-4000-8000-000000000003', 'INDIVIDUAL_REFLECTION', '82000000-0000-4000-8000-000000000002', 'Participant private reflection')$$, 'participant can create an individual-private reflection through the narrow RPC');
select results_eq($$select count(*) from consulting_os.private_meeting_notes_for_meeting('84000000-0000-4000-8000-000000000003') where kind = 'INDIVIDUAL_REFLECTION'$$, array[1::bigint], 'participant can read their own private reflection through the safe projection');
select throws_ok($$select consulting_os.create_private_meeting_note('84000000-0000-4000-8000-000000000003', 'CONSULTANT_NOTE', '82000000-0000-4000-8000-000000000002', 'Forbidden consultant note')$$, '42501', null, 'client cannot create a consultant-private note');
select lives_ok($$select consulting_os.add_shared_meeting_note('84000000-0000-4000-8000-000000000003', 'Participant shared coaching note')$$, 'named participant can add a shared coaching note through the bounded RPC');
select results_eq($$select count(*) from consulting_os.meeting_notes where meeting_id = '84000000-0000-4000-8000-000000000003' and content = 'Participant shared coaching note'$$, array[1::bigint], 'shared coaching note persists and is readable');
select lives_ok($$select consulting_os.add_meeting_commitment('84000000-0000-4000-8000-000000000003', '82000000-0000-4000-8000-000000000002', 'Review two live decisions', '2026-08-26')$$, 'named participant can create a durable commitment');
select results_eq($$select count(*) from consulting_os.commitments where coaching_relationship_id = '84000000-0000-4000-8000-000000000002'$$, array[2::bigint], 'commitments persist independently across the coaching relationship');
select lives_ok($$update consulting_os.commitments set status = 'COMPLETED', completed_at = now() where id = '84000000-0000-4000-8000-000000000005'$$, 'commitment owner can complete their commitment');
select results_eq($$select count(*) from consulting_os.commitments where id = '84000000-0000-4000-8000-000000000005' and status = 'COMPLETED' and completed_at is not null$$, array[1::bigint], 'completed commitment retains durable completion state');
select throws_ok($$insert into consulting_private.coaching_promotions (organization_id, source_private_note_id, derivative_domain_object_id, abstraction_summary, redaction_rationale, authorized_by) values ('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', gen_random_uuid(), '84000000-0000-4000-8000-000000000008', 'Attempt', 'Attempt', '82000000-0000-4000-8000-000000000002')$$, '42501', null, 'ordinary authenticated users cannot write the private promotion ledger directly');

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub', '81000000-0000-4000-8000-000000000003', true);
select results_eq($$select count(*) from consulting_os.meetings where id = '84000000-0000-4000-8000-000000000003'$$, array[0::bigint], 'CLIENT_LEADER status does not unlock coaching sessions');
select results_eq($$select count(*) from consulting_os.private_meeting_notes_for_meeting('84000000-0000-4000-8000-000000000003')$$, array[0::bigint], 'unrelated leader cannot retrieve private coaching notes');
select throws_ok($$select consulting_os.create_private_meeting_note('84000000-0000-4000-8000-000000000001', 'INDIVIDUAL_REFLECTION', '82000000-0000-4000-8000-000000000003', 'Nonparticipant reflection')$$, '42501', null, 'an engagement member who is not a named participant cannot add private meeting content');

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub', '81000000-0000-4000-8000-000000000001', true);
select lives_ok($$select consulting_os.create_meeting('8aaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '83000000-0000-4000-8000-000000000001', 'COACHING', 'Atomic coaching session', 'Create one complete privacy-bounded record', '2026-08-28 10:00+00', 'Prepare; meet; capture; decide; commit; follow up', '82000000-0000-4000-8000-000000000002', 'Decision judgment')$$, 'assigned consultant can atomically create a coaching meeting through the live database path');
select results_eq($$select count(*) from (select m.id from consulting_os.meetings m join consulting_os.coaching_sessions cs on cs.id = m.id and cs.organization_id = m.organization_id join consulting_os.meeting_participants mp on mp.meeting_id = m.id and mp.organization_id = m.organization_id where m.title = 'Atomic coaching session' group by m.id having count(mp.id) = 2) created$$, array[1::bigint], 'atomic creation persists the meeting, coaching specialization, and both named participants');
select lives_ok($$select consulting_os.create_private_meeting_note('84000000-0000-4000-8000-000000000003', 'CONSULTANT_NOTE', '82000000-0000-4000-8000-000000000002', 'Consultant private coaching note')$$, 'assigned consultant can create a physically private note');
select results_eq($$select count(*) from consulting_os.private_meeting_notes_for_meeting('84000000-0000-4000-8000-000000000003') where kind = 'CONSULTANT_NOTE'$$, array[1::bigint], 'consultant can retrieve only their authorized private note');
select results_eq($$select count(*) from consulting_os.phase5_organizational_intelligence_sources where id = '84000000-0000-4000-8000-000000000008'$$, array[0::bigint], 'consultant-private derivative is not organizational intelligence before promotion');
select throws_ok($$select consulting_os.record_coaching_promotion((select note_id from consulting_os.private_meeting_notes_for_meeting('84000000-0000-4000-8000-000000000003') where content = 'Consultant private coaching note'), (select note_id from consulting_os.private_meeting_notes_for_meeting('84000000-0000-4000-8000-000000000003') where content = 'Consultant private coaching note'), 'ORGANIZATION_SHARED', 'Unsafe direct promotion', 'No separate abstraction')$$, '23514', null, 'the original private note cannot be promoted as its own derivative');
select lives_ok($$select consulting_os.record_coaching_promotion((select note_id from consulting_os.private_meeting_notes_for_meeting('84000000-0000-4000-8000-000000000003') where content = 'Consultant private coaching note'), '84000000-0000-4000-8000-000000000008', 'ORGANIZATION_SHARED', 'Abstracted systemic observation without participant detail', 'Names and coaching-specific circumstances removed')$$, 'consultant explicitly promotes a separate abstracted human derivative');

reset role;
select results_eq($$select count(*) from consulting_private.coaching_promotions where derivative_domain_object_id = '84000000-0000-4000-8000-000000000008'$$, array[1::bigint], 'explicit promotion ledger preserves the private-to-shared boundary');
select results_eq($$select count(*) from consulting_os.audit_events where event_type = 'COACHING_DERIVATIVE_PROMOTED' and target_table = 'consulting_private.coaching_promotions'$$, array[1::bigint], 'coaching promotion is audited');
select results_eq($$select count(*) from consulting_os.domain_objects where id = '84000000-0000-4000-8000-000000000008' and visibility_scope = 'ORGANIZATION_SHARED'$$, array[1::bigint], 'promotion atomically applies the approved broader visibility');
select results_eq($$select count(*) from consulting_os.phase5_organizational_intelligence_sources where id = '84000000-0000-4000-8000-000000000004'$$, array[0::bigint], 'direct coaching-shared note is excluded from organizational intelligence');
select results_eq($$select count(*) from consulting_os.phase5_organizational_intelligence_sources where id = '84000000-0000-4000-8000-000000000008'$$, array[1::bigint], 'separate broader derivative is eligible after explicit human promotion');
select results_eq($$select count(*) from consulting_os.coaching_history where coaching_relationship_id = '84000000-0000-4000-8000-000000000002' and session_number = 3$$, array[1::bigint], 'coaching history preserves longitudinal session order without private content');

select * from finish();
rollback;
