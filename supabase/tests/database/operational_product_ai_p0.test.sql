begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;

select plan(22);

select has_table('consulting_os', 'engagement_products', 'engagement products table exists');
select has_table('consulting_os', 'written_audit_assignments', 'written audit assignments table exists');
select has_table('consulting_os', 'interview_templates', 'interview templates table exists');
select has_table('consulting_os', 'interview_template_questions', 'interview template questions table exists');
select has_table('consulting_os', 'interview_product_links', 'interview product links table exists');
select has_table('consulting_os', 'engagement_product_workflows', 'product workflow links table exists');
select has_table('consulting_os', 'workflow_step_analysis', 'workflow step analysis table exists');
select has_table('consulting_os', 'artifact_requests', 'artifact requests table exists');
select has_table('consulting_os', 'engagement_actions', 'engagement actions table exists');

select has_column('consulting_os', 'engagements', 'engagement_type', 'engagement type is configurable');
select has_column('consulting_os', 'engagements', 'objective', 'engagement objective is stored');
select has_column('consulting_os', 'engagements', 'scope_statement', 'engagement scope is stored');
select has_column('consulting_os', 'engagements', 'owner_person_id', 'engagement owner is stored');
select has_column('consulting_os', 'engagements', 'handling_label', 'handling label is stored');
select has_column('consulting_os', 'engagements', 'handling_notice', 'handling notice is stored');
select has_column('consulting_os', 'engagements', 'current_phase', 'current roadmap phase is stored');

select results_eq(
  $$select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'consulting_os'
      and c.relname in ('engagement_products','written_audit_assignments','interview_templates','interview_template_questions','interview_product_links','engagement_product_workflows','workflow_step_analysis','artifact_requests','engagement_actions')
      and c.relrowsecurity$$,
  array[9::bigint],
  'all P0 operational tables enforce row level security'
);

insert into auth.users (id, email, role, aud, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values ('81000000-0000-4000-8000-000000000001', 'operational-p0@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now());

insert into consulting_os.people (id, auth_user_id, display_name)
values ('82000000-0000-4000-8000-000000000001', '81000000-0000-4000-8000-000000000001', 'Operational P0 Tester');

insert into consulting_os.organizations (id, name, slug, created_by)
values
  ('83000000-0000-4000-8000-000000000001', 'Seventh SOS', 'seventh-sos-test', '82000000-0000-4000-8000-000000000001'),
  ('83000000-0000-4000-8000-000000000002', 'Other Organization', 'other-operational-test', '82000000-0000-4000-8000-000000000001');

select throws_ok(
  $$insert into consulting_os.engagements (id, organization_id, name, status, engagement_type, created_by)
    values ('84000000-0000-4000-8000-000000000001', '83000000-0000-4000-8000-000000000001', 'Invalid Operational Pilot', 'ACTIVE', 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION', '82000000-0000-4000-8000-000000000001')$$,
  null,
  null,
  'an operational engagement cannot omit its handling and scope contract'
);

select lives_ok(
  $$insert into consulting_os.engagements
      (id, organization_id, name, status, engagement_type, objective, scope_statement, handling_label, handling_notice, current_phase, created_by)
    values
      ('84000000-0000-4000-8000-000000000001', '83000000-0000-4000-8000-000000000001', 'Operational Product AI Transformation', 'ACTIVE',
       'OPERATIONAL_PRODUCT_AI_TRANSFORMATION', 'Assess sanitized product workflows.', 'Unclassified product-process assessment only.',
       'Internal — Sanitized Only', 'Do not enter classified or operational mission information.', 'SEE REALITY', '82000000-0000-4000-8000-000000000001')$$,
  'a fully scoped sanitized operational engagement is accepted'
);

insert into consulting_os.engagements (id, organization_id, name, status, created_by)
values ('84000000-0000-4000-8000-000000000002', '83000000-0000-4000-8000-000000000002', 'Other Engagement', 'ACTIVE', '82000000-0000-4000-8000-000000000001');

insert into consulting_os.domain_objects
  (id, organization_id, engagement_id, object_type, visibility_scope, created_by)
values
  ('85000000-0000-4000-8000-000000000001', '83000000-0000-4000-8000-000000000001', '84000000-0000-4000-8000-000000000001', 'ENGAGEMENT_PRODUCT', 'ENGAGEMENT_SHARED', '82000000-0000-4000-8000-000000000001');

select throws_ok(
  $$insert into consulting_os.engagement_products
      (id, organization_id, engagement_id, name, description, owner_label, created_by)
    values
      ('85000000-0000-4000-8000-000000000001', '83000000-0000-4000-8000-000000000001', '84000000-0000-4000-8000-000000000002',
       'Cross-tenant Product', 'Must be rejected.', 'Product Owner', '82000000-0000-4000-8000-000000000001')$$,
  null,
  null,
  'a product cannot reference another organization engagement'
);

select throws_ok(
  $$insert into consulting_os.engagement_products
      (id, organization_id, engagement_id, name, description, owner_label, handling_label, created_by)
    values
      ('85000000-0000-4000-8000-000000000001', '83000000-0000-4000-8000-000000000001', '84000000-0000-4000-8000-000000000001',
       'Unsafe Product', 'Must be rejected.', 'Product Owner', 'Unrestricted', '82000000-0000-4000-8000-000000000001')$$,
  null,
  null,
  'a product cannot weaken the sanitized-only handling label'
);

select lives_ok(
  $$insert into consulting_os.engagement_products
      (id, organization_id, engagement_id, name, description, owner_label, created_by)
    values
      ('85000000-0000-4000-8000-000000000001', '83000000-0000-4000-8000-000000000001', '84000000-0000-4000-8000-000000000001',
       'Sanitized Product', 'An unclassified product workflow.', 'Product Owner', '82000000-0000-4000-8000-000000000001')$$,
  'a same-tenant product with the fixed handling label is accepted'
);

select * from finish();
rollback;
