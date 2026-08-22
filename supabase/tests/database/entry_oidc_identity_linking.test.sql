begin;
create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(14);

select has_column('consulting_os', 'canonical_identity_links', 'auth_user_id', 'Canonical links retain the Consulting Auth UUID');
select has_column('consulting_os', 'canonical_identity_links', 'provider_subject', 'Canonical links retain the verified Entry provider subject');
select has_function(
  'consulting_os',
  'link_entry_oidc_identity',
  array['uuid','uuid','text','text','uuid','text','boolean'],
  'Trusted callback has one atomic identity-link command'
);

insert into auth.users(id,email,role,aud,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) values
('31000000-0000-4000-8000-000000000001','new-sso@example.test','authenticated','authenticated','{}','{}',now(),now()),
('31000000-0000-4000-8000-000000000002','existing@example.test','authenticated','authenticated','{}','{}',now(),now()),
('31000000-0000-4000-8000-000000000003','conflict@example.test','authenticated','authenticated','{}','{}',now(),now());
insert into consulting_os.people(id,auth_user_id,display_name) values
('32000000-0000-4000-8000-000000000002','31000000-0000-4000-8000-000000000002','Existing Consulting Person');

set local role authenticated;
select throws_ok(
  $$select * from consulting_os.link_entry_oidc_identity('31000000-0000-4000-8000-000000000001','33000000-0000-4000-8000-000000000001','custom:lead-emergence-entry-dev','33000000-0000-4000-8000-000000000001','34000000-0000-4000-8000-000000000001','New SSO Person',false)$$,
  '42501',
  null,
  'Authenticated callers cannot invoke the trusted linking command'
);
reset role;

set local role service_role;
select lives_ok(
  $$select * from consulting_os.link_entry_oidc_identity('31000000-0000-4000-8000-000000000001','33000000-0000-4000-8000-000000000001','custom:lead-emergence-entry-dev','33000000-0000-4000-8000-000000000001','34000000-0000-4000-8000-000000000001','New SSO Person',false)$$,
  'A new verified SSO identity creates a person and durable link'
);
reset role;

select results_eq(
  $$select count(*) from consulting_os.canonical_identity_links where canonical_user_id='33000000-0000-4000-8000-000000000001' and auth_user_id='31000000-0000-4000-8000-000000000001' and provider_subject='33000000-0000-4000-8000-000000000001' and status='LINKED'$$,
  array[1::bigint],
  'Canonical subject, Consulting Auth UUID, and person are durably related'
);
select results_eq(
  $$select count(*) from consulting_os.organization_memberships where person_id=(select person_id from consulting_os.canonical_identity_links where canonical_user_id='33000000-0000-4000-8000-000000000001')$$,
  array[0::bigint],
  'Identity linking creates no organization membership'
);
select results_eq(
  $$select count(*) from consulting_os.consultant_assignments where consultant_person_id=(select person_id from consulting_os.canonical_identity_links where canonical_user_id='33000000-0000-4000-8000-000000000001')$$,
  array[0::bigint],
  'Identity linking creates no consultant assignment'
);

set local role service_role;
select throws_ok(
  $$select * from consulting_os.link_entry_oidc_identity('31000000-0000-4000-8000-000000000002','33000000-0000-4000-8000-000000000002','custom:lead-emergence-entry-dev','33000000-0000-4000-8000-000000000002','34000000-0000-4000-8000-000000000002','Existing Consulting Person',false)$$,
  '42501',
  null,
  'Existing Consulting people cannot be auto-linked during ordinary sign-in'
);
select lives_ok(
  $$select * from consulting_os.link_entry_oidc_identity('31000000-0000-4000-8000-000000000002','33000000-0000-4000-8000-000000000002','custom:lead-emergence-entry-dev','33000000-0000-4000-8000-000000000002','34000000-0000-4000-8000-000000000002','Existing Consulting Person',true)$$,
  'An authenticated existing account can explicitly link a verified Entry subject'
);
select throws_ok(
  $$select * from consulting_os.link_entry_oidc_identity('31000000-0000-4000-8000-000000000003','33000000-0000-4000-8000-000000000002','custom:lead-emergence-entry-dev','33000000-0000-4000-8000-000000000002','34000000-0000-4000-8000-000000000003','Conflict Person',true)$$,
  '23505',
  null,
  'A canonical subject cannot be reassigned to another Auth user'
);
select throws_ok(
  $$select * from consulting_os.link_entry_oidc_identity('31000000-0000-4000-8000-000000000003','33000000-0000-4000-8000-000000000003','custom:lead-emergence-entry-dev','33000000-0000-4000-8000-000000000099','34000000-0000-4000-8000-000000000003','Mismatch',false)$$,
  '22023',
  null,
  'Provider subject must equal the Entry canonical subject'
);
reset role;

select results_eq(
  $$select count(*) from consulting_os.audit_events where event_type='ENTRY_IDENTITY_LINK_CREATED' and target_table='consulting_os.canonical_identity_links' and actor_auth_user_id in ('31000000-0000-4000-8000-000000000001','31000000-0000-4000-8000-000000000002')$$,
  array[2::bigint],
  'Every successful first link is audited'
);
select results_eq(
  $$select count(*) from consulting_os.organization_memberships where person_id='32000000-0000-4000-8000-000000000002'$$,
  array[0::bigint],
  'Explicit existing-account linking also creates no membership'
);

select * from finish();
rollback;
