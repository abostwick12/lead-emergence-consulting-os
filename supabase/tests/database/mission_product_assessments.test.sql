begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;

select plan(11);

select has_column('consulting_os', 'assessment_instruments', 'definition_key', 'Assessment instruments have a stable organization-scoped definition key');
select has_function(
  'consulting_os',
  'create_operational_assessment_administration',
  array['uuid', 'uuid', 'jsonb', 'text', 'consulting_os.assessment_confidentiality'],
  'Versioned operational assessment administration command exists'
);

insert into auth.users (id, email, role, aud, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
values
  ('8b100000-0000-4000-8000-000000000001', 'assessment-consultant@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now()),
  ('8b100000-0000-4000-8000-000000000002', 'assessment-outsider@example.test', 'authenticated', 'authenticated', '{}', '{}', now(), now());

insert into consulting_os.people (id, auth_user_id, display_name)
values
  ('8b200000-0000-4000-8000-000000000001', '8b100000-0000-4000-8000-000000000001', 'Assessment Consultant'),
  ('8b200000-0000-4000-8000-000000000002', '8b100000-0000-4000-8000-000000000002', 'Unassigned Person');

insert into consulting_os.organizations (id, name, slug, created_by)
values ('8b300000-0000-4000-8000-000000000001', 'Assessment Client', 'assessment-client', '8b200000-0000-4000-8000-000000000001');

insert into consulting_os.consultant_assignments
  (id, organization_id, consultant_person_id, status, assignment_reason, created_by)
values
  ('8b400000-0000-4000-8000-000000000001', '8b300000-0000-4000-8000-000000000001', '8b200000-0000-4000-8000-000000000001', 'ACTIVE', 'Assessment administration test', '8b200000-0000-4000-8000-000000000001');

insert into consulting_os.engagements
  (id, organization_id, name, status, engagement_type, objective, scope_statement, handling_label, handling_notice, current_phase, created_by)
values
  ('8b500000-0000-4000-8000-000000000001', '8b300000-0000-4000-8000-000000000001', 'Operational Product AI Transformation', 'ACTIVE',
   'OPERATIONAL_PRODUCT_AI_TRANSFORMATION', 'Assess sanitized product workflows.', 'Sanitized process-level inquiry only.',
   'Internal — Sanitized Only', 'Do not enter restricted operational information.', 'SEE REALITY', '8b200000-0000-4000-8000-000000000001');

set local role authenticated;
select set_config('request.jwt.claim.sub', '8b100000-0000-4000-8000-000000000001', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select lives_ok(
  $$select consulting_os.create_operational_assessment_administration(
    '8b300000-0000-4000-8000-000000000001',
    '8b500000-0000-4000-8000-000000000001',
    '{"slug":"mission-product-automation-leadership-assessment","title":"Mission Product Automation Leadership Assessment","version":1,"sourceDocument":"Mission_Product_Automation_Leadership_Assessment.docx","sections":[{"key":"MISSION_CONTEXT","label":"Mission Context"}],"items":[{"itemKey":"LEAD_1_1","sectionKey":"MISSION_CONTEXT","prompt":"What mission outcomes do these products support?","responseType":"TEXT","responseOptions":{"section":"Mission Context","guidance":"Sanitized evidence only.","uiType":"text","placeholder":"Response"}}]}'::jsonb,
    'Leadership',
    'IDENTIFIED'
  )$$,
  'Assigned consultant can open an authoritative assessment administration'
);

select results_eq(
  $$select count(*) from consulting_os.assessment_instruments where definition_key = 'mission-product-automation-leadership-assessment'$$,
  array[1::bigint],
  'The stable instrument is created once in the active organization'
);
select results_eq(
  $$select count(*) from consulting_os.assessment_instrument_versions v join consulting_os.assessment_instruments i on i.id = v.instrument_id and i.organization_id = v.organization_id where i.definition_key = 'mission-product-automation-leadership-assessment'$$,
  array[1::bigint],
  'The authoritative version is created once'
);
select results_eq(
  $$select count(*) from consulting_os.assessment_items q join consulting_os.assessment_instrument_versions v on v.id = q.instrument_version_id and v.organization_id = q.organization_id join consulting_os.assessment_instruments i on i.id = v.instrument_id and i.organization_id = v.organization_id where i.definition_key = 'mission-product-automation-leadership-assessment'$$,
  array[1::bigint],
  'Every projected response item is attached to that version'
);
select results_eq(
  $$select count(*) from consulting_os.assessment_administrations where engagement_id = '8b500000-0000-4000-8000-000000000001' and administration_status = 'OPEN'$$,
  array[1::bigint],
  'The administration is open in the verified engagement'
);

select lives_ok(
  $$select consulting_os.create_operational_assessment_administration(
    '8b300000-0000-4000-8000-000000000001',
    '8b500000-0000-4000-8000-000000000001',
    '{"slug":"mission-product-automation-leadership-assessment","title":"Mission Product Automation Leadership Assessment","version":1,"sourceDocument":"Mission_Product_Automation_Leadership_Assessment.docx","sections":[{"key":"MISSION_CONTEXT","label":"Mission Context"}],"items":[{"itemKey":"LEAD_1_1","sectionKey":"MISSION_CONTEXT","prompt":"What mission outcomes do these products support?","responseType":"TEXT","responseOptions":{"section":"Mission Context","guidance":"Sanitized evidence only.","uiType":"text","placeholder":"Response"}}]}'::jsonb,
    'Second leadership administration',
    'IDENTIFIED'
  )$$,
  'A later administration reuses the immutable instrument version'
);
select results_eq(
  $$select count(*) from consulting_os.assessment_instruments where definition_key = 'mission-product-automation-leadership-assessment'$$,
  array[1::bigint],
  'A second administration does not duplicate the instrument'
);
select results_eq(
  $$select count(*) from consulting_os.assessment_administrations where engagement_id = '8b500000-0000-4000-8000-000000000001' and administration_status = 'OPEN'$$,
  array[2::bigint],
  'Each administration remains a separate historical activity'
);

select set_config('request.jwt.claim.sub', '8b100000-0000-4000-8000-000000000002', true);
select throws_ok(
  $$select consulting_os.create_operational_assessment_administration(
    '8b300000-0000-4000-8000-000000000001',
    '8b500000-0000-4000-8000-000000000001',
    '{"slug":"mission-product-automation-leadership-assessment","title":"Mission Product Automation Leadership Assessment","version":1,"sections":[],"items":[{"itemKey":"Q1","sectionKey":"MISSION_CONTEXT","prompt":"Prompt","responseType":"TEXT","responseOptions":{"uiType":"text"}}]}'::jsonb,
    'Unauthorized administration',
    'IDENTIFIED'
  )$$,
  null,
  null,
  'An unassigned user cannot create an administration in another organization'
);

select * from finish();
rollback;
