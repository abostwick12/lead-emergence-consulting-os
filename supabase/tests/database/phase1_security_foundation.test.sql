begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;

select plan(32);

insert into auth.users (id, email, role, aud, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('10000000-0000-4000-8000-000000000001', 'admin-a@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('10000000-0000-4000-8000-000000000002', 'leader-a@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('10000000-0000-4000-8000-000000000003', 'member-a@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('10000000-0000-4000-8000-000000000004', 'admin-b@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('10000000-0000-4000-8000-000000000005', 'consultant@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('10000000-0000-4000-8000-000000000006', 'platform@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now());

insert into consulting_os.people (id, auth_user_id, display_name)
values
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Client Admin A'),
  ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000002', 'Client Leader A'),
  ('20000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000003', 'Client Member A'),
  ('20000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000004', 'Client Admin B'),
  ('20000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000005', 'Assigned Consultant'),
  ('20000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000006', 'Platform Operator');

insert into consulting_os.organizations (id, name, slug, created_by)
values
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Northstar Partners', 'northstar-a', '20000000-0000-4000-8000-000000000005'),
  ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'Northstar Partners', 'northstar-b', '20000000-0000-4000-8000-000000000005');

insert into consulting_os.organization_memberships
  (id, organization_id, person_id, platform_role, status, created_by)
values
  ('30000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '20000000-0000-4000-8000-000000000001', 'CLIENT_ADMIN', 'ACTIVE', '20000000-0000-4000-8000-000000000005'),
  ('30000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '20000000-0000-4000-8000-000000000002', 'CLIENT_LEADER', 'ACTIVE', '20000000-0000-4000-8000-000000000005'),
  ('30000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '20000000-0000-4000-8000-000000000003', 'CLIENT_MEMBER', 'ACTIVE', '20000000-0000-4000-8000-000000000005'),
  ('30000000-0000-4000-8000-000000000004', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '20000000-0000-4000-8000-000000000004', 'CLIENT_ADMIN', 'ACTIVE', '20000000-0000-4000-8000-000000000005');

insert into consulting_os.consultant_assignments
  (id, organization_id, consultant_person_id, status, assignment_reason, created_by)
values
  ('31000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '20000000-0000-4000-8000-000000000005', 'ACTIVE', 'Phase 1 synthetic assignment', '20000000-0000-4000-8000-000000000006');

insert into consulting_security.platform_admin_assignments
  (id, person_id, status, purpose, created_by)
values
  ('32000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000006', 'ACTIVE', 'Synthetic security test operator', '20000000-0000-4000-8000-000000000006');

insert into consulting_os.engagements (id, organization_id, name, status, created_by)
values
  ('33000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Transformation A', 'ACTIVE', '20000000-0000-4000-8000-000000000005'),
  ('33000000-0000-4000-8000-000000000002', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'Transformation B', 'ACTIVE', '20000000-0000-4000-8000-000000000004');

insert into consulting_os.engagement_memberships
  (id, organization_id, engagement_id, organization_membership_id, status, created_by)
values
  ('34000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '33000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000003', 'ACTIVE', '20000000-0000-4000-8000-000000000001');

insert into consulting_os.domain_objects
  (id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, created_by)
values
  ('40000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'OBSERVATION', 'ORGANIZATION_SHARED', null, '20000000-0000-4000-8000-000000000005'),
  ('40000000-0000-4000-8000-000000000002', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', null, 'OBSERVATION', 'ORGANIZATION_SHARED', null, '20000000-0000-4000-8000-000000000004'),
  ('40000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'MEETING_NOTE', 'CONSULTANT_PRIVATE', '20000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000005'),
  ('40000000-0000-4000-8000-000000000004', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'REFLECTION', 'INDIVIDUAL_PRIVATE', '20000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000003'),
  ('40000000-0000-4000-8000-000000000005', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'COACHING_SESSION', 'COACHING_SHARED', '20000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000005'),
  ('40000000-0000-4000-8000-000000000006', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'INSIGHT', 'LEADERSHIP_RESTRICTED', null, '20000000-0000-4000-8000-000000000005'),
  ('40000000-0000-4000-8000-000000000007', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '33000000-0000-4000-8000-000000000001', 'MEETING', 'ENGAGEMENT_SHARED', null, '20000000-0000-4000-8000-000000000005'),
  ('40000000-0000-4000-8000-000000000008', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'AUDIT_ARTIFACT', 'PLATFORM_RESTRICTED', null, '20000000-0000-4000-8000-000000000006'),
  ('40000000-0000-4000-8000-000000000009', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', null, 'FILE', 'ORGANIZATION_SHARED', null, '20000000-0000-4000-8000-000000000001'),
  ('40000000-0000-4000-8000-000000000010', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', null, 'FILE', 'ORGANIZATION_SHARED', null, '20000000-0000-4000-8000-000000000004');

insert into consulting_os.visibility_grants
  (id, organization_id, domain_object_id, grantee_person_id, permission, created_by)
values
  ('41000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '40000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000003', 'READ', '20000000-0000-4000-8000-000000000005'),
  ('41000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '40000000-0000-4000-8000-000000000005', '20000000-0000-4000-8000-000000000005', 'MANAGE', '20000000-0000-4000-8000-000000000005');

insert into consulting_private.private_records
  (id, organization_id, kind, subject_person_id, author_person_id, ciphertext_or_content)
values
  ('40000000-0000-4000-8000-000000000003', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'CONSULTANT_NOTE', '20000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000005', 'Synthetic private note');

insert into consulting_os.file_objects
  (id, organization_id, object_path, visibility_scope, retention_class, created_by)
values
  ('40000000-0000-4000-8000-000000000009', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa/evidence/a.txt', 'ORGANIZATION_SHARED', 'ENGAGEMENT_RECORD', '20000000-0000-4000-8000-000000000001'),
  ('40000000-0000-4000-8000-000000000010', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb/evidence/b.txt', 'ORGANIZATION_SHARED', 'ENGAGEMENT_RECORD', '20000000-0000-4000-8000-000000000004');

insert into storage.objects (bucket_id, name, metadata)
values
  ('consulting-private', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa/evidence/a.txt', '{}'::jsonb),
  ('consulting-private', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb/evidence/b.txt', '{}'::jsonb);

insert into consulting_os.entity_relationships
  (id, organization_id, relationship_type, source_type, source_id, target_type, target_id, origin, review_status, rationale, created_by)
values
  ('42000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'ASSOCIATED_WITH', 'OBSERVATION', '40000000-0000-4000-8000-000000000001', 'INSIGHT', '40000000-0000-4000-8000-000000000006', 'HUMAN', 'ACCEPTED', 'Synthetic same-tenant edge', '20000000-0000-4000-8000-000000000005');

set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select results_eq(
  $$select count(*) from consulting_os.organizations where id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'$$,
  array[0::bigint],
  'Org A cannot select Org B by known UUID'
);
select throws_ok(
  $$insert into consulting_os.domain_objects (organization_id, object_type, visibility_scope, created_by)
    values ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'OBSERVATION', 'ORGANIZATION_SHARED', '20000000-0000-4000-8000-000000000001')$$,
  null, null, 'Org A cannot insert a record into Org B'
);
select throws_ok(
  $$update consulting_os.domain_objects set organization_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
    where id = '40000000-0000-4000-8000-000000000001'$$,
  null, null, 'Org A cannot move its record into Org B'
);

reset role;
select throws_ok(
  $$insert into consulting_os.entity_relationships
      (organization_id, relationship_type, source_type, source_id, target_type, target_id, rationale, created_by)
    values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'ASSOCIATED_WITH', 'OBSERVATION',
      '40000000-0000-4000-8000-000000000001', 'OBSERVATION', '40000000-0000-4000-8000-000000000002',
      'Cross-tenant attempt', '20000000-0000-4000-8000-000000000005')$$,
  null, null, 'Cross-tenant relationship creation is rejected by the database'
);
select throws_ok(
  $$insert into consulting_os.entity_relationships
      (organization_id, relationship_type, source_type, source_id, target_type, target_id, rationale, created_by)
    values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'ASSOCIATED_WITH', 'PATTERN',
      '40000000-0000-4000-8000-000000000001', 'INSIGHT', '40000000-0000-4000-8000-000000000006',
      'Wrong endpoint type attempt', '20000000-0000-4000-8000-000000000005')$$,
  null, null, 'Relationship endpoint type must match the registry'
);
select throws_ok(
  $$insert into consulting_os.entity_relationships
      (organization_id, relationship_type, source_type, source_id, target_type, target_id, origin, review_status, rationale, created_by)
    values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'CAUSES', 'OBSERVATION',
      '40000000-0000-4000-8000-000000000001', 'INSIGHT', '40000000-0000-4000-8000-000000000006',
      'AI', 'ACCEPTED', 'AI may not establish accepted causality', '20000000-0000-4000-8000-000000000005')$$,
  null, null, 'AI cannot create an accepted CAUSES edge'
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000005', true);
select results_eq($$select count(*) from consulting_os.organizations where id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'$$, array[1::bigint], 'Assigned consultant can access Org A');
select results_eq($$select count(*) from consulting_os.organizations where id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'$$, array[0::bigint], 'Unassigned consultant cannot access Org B');
select results_eq($$select count(*) from consulting_os.domain_objects where id = '40000000-0000-4000-8000-000000000003'$$, array[1::bigint], 'Assigned consultant can read their consultant-private object');

select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);
select results_eq($$select count(*) from consulting_os.domain_objects where id = '40000000-0000-4000-8000-000000000003'$$, array[0::bigint], 'CLIENT_ADMIN cannot read consultant-private material');
select results_eq($$select count(*) from consulting_os.domain_objects where id = '40000000-0000-4000-8000-000000000005'$$, array[0::bigint], 'CLIENT_ADMIN cannot override coaching-shared confidentiality');

select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000002', true);
select results_eq($$select count(*) from consulting_os.domain_objects where id = '40000000-0000-4000-8000-000000000004'$$, array[0::bigint], 'CLIENT_LEADER cannot read an individual-private reflection');
select results_eq($$select count(*) from consulting_os.domain_objects where id = '40000000-0000-4000-8000-000000000005'$$, array[0::bigint], 'Unrelated leader cannot read coaching-shared material');

select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000003', true);
select results_eq($$select count(*) from consulting_os.domain_objects where id = '40000000-0000-4000-8000-000000000005'$$, array[1::bigint], 'Named coaching participant can read coaching-shared material');

reset role;
update consulting_os.organization_memberships set status = 'REMOVED', effective_to = now()
where id = '30000000-0000-4000-8000-000000000003';
set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000003', true);
select results_eq($$select count(*) from consulting_os.domain_objects where id = '40000000-0000-4000-8000-000000000001'$$, array[0::bigint], 'Membership removal stops access on the next operation');

select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);
select results_eq($$select count(*) from consulting_os.file_objects where id = '40000000-0000-4000-8000-000000000009'$$, array[1::bigint], 'Authorized user can see same-tenant file metadata');
select results_eq($$select count(*) from consulting_os.file_objects where id = '40000000-0000-4000-8000-000000000010'$$, array[0::bigint], 'File metadata does not leak across tenants');
select results_eq($$select count(*) from storage.objects where name = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb/evidence/b.txt'$$, array[0::bigint], 'Guessed storage path from another tenant cannot be read');
select results_eq($$select count(*) from consulting_os.authorized_source_ids('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'AI_RETRIEVAL')$$, array[3::bigint], 'AI/search source filtering occurs before retrieval and excludes private or unassigned sources');
select results_eq($$select count(*) from consulting_os.authorized_domain_objects where organization_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'$$, array[3::bigint], 'Security-invoker export view returns exactly visible records');
select results_eq($$select count(*) from consulting_os.entity_relationships where id = '42000000-0000-4000-8000-000000000001'$$, array[1::bigint], 'Relationship is visible only when both endpoints are visible');

select throws_ok($$select count(*) from consulting_private.private_records$$, null, null, 'Authenticated users have no direct private-schema access');
select throws_ok($$select count(*) from consulting_os.audit_events$$, null, null, 'Authenticated users have no direct audit-log access');
select throws_ok(
  $$select consulting_security.record_privileged_operation('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'READ', 'consulting_os.domain_objects',
      '40000000-0000-4000-8000-000000000001', 'No grant', 'corr-auth')$$,
  null, null, 'Authenticated role cannot invoke privileged service operation'
);
select results_eq(
  $$with removed as (delete from consulting_os.organization_memberships where id = '30000000-0000-4000-8000-000000000002' returning id)
    select count(*) from removed$$,
  array[0::bigint], 'Canonical access history cannot be hard-deleted through ordinary RLS'
);

reset role;
select cmp_ok((select count(*) from consulting_os.audit_events where event_type like 'ORGANIZATION_MEMBERSHIPS_%'), '>=', 5::bigint, 'Membership changes emit audit events');
select cmp_ok((select count(*) from consulting_os.audit_events where event_type like 'VISIBILITY_GRANTS_%'), '>=', 2::bigint, 'Visibility grants emit audit events');
select throws_ok($$update consulting_os.audit_events set reason = 'tampered' where true$$, null, null, 'Audit events are append-only');

set local role service_role;
select set_config('request.jwt.claim.role', 'service_role', true);
select throws_ok(
  $$select consulting_security.record_privileged_operation(null, 'READ', 'consulting_os.domain_objects', null, 'Missing tenant', 'corr-null')$$,
  null, null, 'Privileged operation without verified tenant context fails closed'
);
select ok(
  consulting_security.record_privileged_operation('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'READ', 'consulting_os.domain_objects',
    '40000000-0000-4000-8000-000000000001', 'Synthetic support verification', 'corr-service') is not null,
  'Verified service-role operation emits an audit event'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000006', true);
select set_config('request.jwt.claim.role', 'authenticated', true);
select results_eq($$select count(*) from consulting_os.domain_objects where id = '40000000-0000-4000-8000-000000000008'$$, array[1::bigint], 'Active platform operator can read platform-restricted metadata');

reset role;
set local role anon;
select set_config('request.jwt.claim.sub', '', true);
select set_config('request.jwt.claim.role', 'anon', true);
select throws_ok($$select count(*) from consulting_os.organizations$$, null, null, 'Anonymous role has no Consulting schema access');

reset role;
select * from finish();
rollback;
