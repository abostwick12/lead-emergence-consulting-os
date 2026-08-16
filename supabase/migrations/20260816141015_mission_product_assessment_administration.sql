-- Mission Product assessments are versioned inquiry instruments. They are not
-- psychometric tests and their responses remain evidence, not diagnosis.

alter table consulting_os.assessment_instruments
  add column if not exists definition_key text;

create unique index if not exists assessment_instruments_definition_key_idx
  on consulting_os.assessment_instruments(organization_id, definition_key)
  where definition_key is not null;

create or replace function consulting_os.create_operational_assessment_administration(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_definition jsonb,
  p_audience_description text,
  p_confidentiality consulting_os.assessment_confidentiality default 'IDENTIFIED'
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := consulting_security.current_person_id();
  v_slug text := btrim(p_definition ->> 'slug');
  v_title text := btrim(p_definition ->> 'title');
  v_version_number integer := coalesce((p_definition ->> 'version')::integer, 1);
  v_instrument_id uuid;
  v_version_id uuid;
  v_source_id uuid := gen_random_uuid();
  v_administration_id uuid := gen_random_uuid();
  v_item jsonb;
  v_ordinal integer := 0;
  v_item_count integer;
begin
  if v_actor is null
    or not consulting_security.has_active_consultant_assignment(p_organization_id)
  then
    raise exception 'Assigned consultant authorization is required.' using errcode = '42501';
  end if;

  if not exists (
    select 1
    from consulting_os.engagements e
    where e.id = p_engagement_id
      and e.organization_id = p_organization_id
      and e.engagement_type = 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION'
  ) then
    raise exception 'The operational assessment engagement is outside the verified organization.'
      using errcode = '23503';
  end if;

  if v_slug not in (
    'mission-product-automation-leadership-assessment',
    'mission-product-workflow-and-automation-assessment'
  ) then
    raise exception 'The assessment definition is not an approved Mission Product instrument.'
      using errcode = '22023';
  end if;

  if length(v_title) = 0
    or v_version_number < 1
    or jsonb_typeof(p_definition -> 'sections') <> 'array'
    or jsonb_typeof(p_definition -> 'items') <> 'array'
    or jsonb_array_length(p_definition -> 'items') = 0
    or length(btrim(coalesce(p_audience_description, ''))) = 0
  then
    raise exception 'A complete versioned assessment definition and audience are required.'
      using errcode = '22023';
  end if;

  select i.id into v_instrument_id
  from consulting_os.assessment_instruments i
  where i.organization_id = p_organization_id
    and i.definition_key = v_slug;

  if v_instrument_id is null then
    v_instrument_id := gen_random_uuid();
    insert into consulting_os.domain_objects(
      id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by
    ) values (
      v_instrument_id, p_organization_id, p_engagement_id, 'ASSESSMENT_INSTRUMENT',
      'ENGAGEMENT_SHARED', 'SYSTEM', v_actor
    );

    insert into consulting_os.assessment_instruments(
      id, organization_id, name, framework_name, instrument_status,
      validation_claim_status, validation_basis, definition_key, created_by
    ) values (
      v_instrument_id, p_organization_id, v_title,
      'Lead Emergence Mission Product Assessment', 'ACTIVE', 'NOT_VALIDATED',
      'Structured consulting inquiry instrument; no psychometric validation or autonomous diagnosis is claimed.',
      v_slug, v_actor
    );
  end if;

  select v.id into v_version_id
  from consulting_os.assessment_instrument_versions v
  where v.organization_id = p_organization_id
    and v.instrument_id = v_instrument_id
    and v.version_number = v_version_number;

  if v_version_id is null then
    v_version_id := gen_random_uuid();
    insert into consulting_os.assessment_instrument_versions(
      id, organization_id, instrument_id, version_number, version_label,
      dimensions, scoring_rules, compatibility_key, published_at, created_by
    ) values (
      v_version_id, p_organization_id, v_instrument_id, v_version_number,
      'Authoritative version ' || v_version_number::text,
      p_definition -> 'sections',
      jsonb_build_object(
        'method', 'NONE',
        'epistemic_boundary', 'Responses are evidence, not diagnosis.',
        'source_document', p_definition ->> 'sourceDocument'
      ),
      v_slug, now(), v_actor
    );

    for v_item in
      select value from jsonb_array_elements(p_definition -> 'items')
    loop
      v_ordinal := v_ordinal + 1;
      if length(btrim(coalesce(v_item ->> 'itemKey', ''))) = 0
        or length(btrim(coalesce(v_item ->> 'prompt', ''))) = 0
        or length(btrim(coalesce(v_item ->> 'sectionKey', ''))) = 0
        or coalesce(v_item ->> 'responseType', '') not in (
          'TEXT', 'BOOLEAN', 'LIKERT', 'NUMBER', 'SINGLE_SELECT', 'MULTI_SELECT'
        )
      then
        raise exception 'Assessment item % is incomplete.', v_ordinal using errcode = '22023';
      end if;

      insert into consulting_os.assessment_items(
        organization_id, instrument_version_id, item_key, prompt, dimension_key,
        response_type, response_options, ordinal, created_by
      ) values (
        p_organization_id, v_version_id, v_item ->> 'itemKey', v_item ->> 'prompt',
        v_item ->> 'sectionKey', v_item ->> 'responseType',
        v_item -> 'responseOptions', v_ordinal, v_actor
      );
    end loop;
  else
    select count(*) into v_item_count
    from consulting_os.assessment_items q
    where q.organization_id = p_organization_id
      and q.instrument_version_id = v_version_id;
    if v_item_count <> jsonb_array_length(p_definition -> 'items') then
      raise exception 'The stored assessment version does not match the authoritative item count.'
        using errcode = '23514';
    end if;
  end if;

  insert into consulting_os.domain_objects(
    id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by
  ) values (
    v_source_id, p_organization_id, p_engagement_id, 'EVIDENCE_SOURCE',
    'LEADERSHIP_RESTRICTED', 'SYSTEM', v_actor
  );
  insert into consulting_os.evidence_sources(
    id, organization_id, source_type, title, captured_at, provenance_context, created_by
  ) values (
    v_source_id, p_organization_id, 'ASSESSMENT', v_title, now(),
    'Responses were collected against the immutable authoritative instrument version. They are evidence and have not been interpreted or diagnosed.',
    v_actor
  );

  insert into consulting_os.domain_objects(
    id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by
  ) values (
    v_administration_id, p_organization_id, p_engagement_id, 'ASSESSMENT_ADMINISTRATION',
    'LEADERSHIP_RESTRICTED', 'HUMAN', v_actor
  );
  insert into consulting_os.assessment_administrations(
    id, organization_id, engagement_id, instrument_version_id, evidence_source_id,
    audience_description, opens_at, closes_at, confidentiality,
    minimum_reporting_cohort, administration_status, created_by
  ) values (
    v_administration_id, p_organization_id, p_engagement_id, v_version_id, v_source_id,
    btrim(p_audience_description), now(), now() + interval '14 days', p_confidentiality,
    case when p_confidentiality = 'ANONYMOUS' then 3 else 1 end,
    'OPEN', v_actor
  );

  return v_administration_id;
end
$$;

revoke all on function consulting_os.create_operational_assessment_administration(
  uuid, uuid, jsonb, text, consulting_os.assessment_confidentiality
) from public, anon;
grant execute on function consulting_os.create_operational_assessment_administration(
  uuid, uuid, jsonb, text, consulting_os.assessment_confidentiality
) to authenticated, service_role;

comment on function consulting_os.create_operational_assessment_administration(
  uuid, uuid, jsonb, text, consulting_os.assessment_confidentiality
) is 'Creates or reuses an immutable Mission Product instrument version, then opens a tenant-scoped administration. Responses remain evidence, not diagnosis.';
