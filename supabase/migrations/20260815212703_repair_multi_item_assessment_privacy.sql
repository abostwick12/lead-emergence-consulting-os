-- A participant capability belongs to an administration, not to a single item.
-- Track item completion privately so multi-item instruments can be completed
-- without exposing a response-to-recipient join to ordinary portal roles.
create table consulting_private.assessment_participant_item_submissions (
  participant_link_id uuid not null,
  organization_id uuid not null,
  item_id uuid not null,
  response_id uuid not null,
  submitted_at timestamptz not null default now(),
  primary key (participant_link_id, item_id),
  foreign key (participant_link_id, organization_id)
    references consulting_private.assessment_participant_links(id, organization_id) on delete restrict,
  foreign key (item_id, organization_id)
    references consulting_os.assessment_items(id, organization_id) on delete restrict,
  foreign key (response_id, organization_id)
    references consulting_private.assessment_responses(id, organization_id) on delete restrict,
  unique (response_id, organization_id)
);

create index assessment_participant_item_submissions_scope_idx
  on consulting_private.assessment_participant_item_submissions(organization_id, participant_link_id, submitted_at);

alter table consulting_private.assessment_participant_item_submissions enable row level security;
revoke all on consulting_private.assessment_participant_item_submissions from public, anon, authenticated;
grant all on consulting_private.assessment_participant_item_submissions to service_role;

comment on table consulting_private.assessment_participant_item_submissions is
  'Private completion ledger. It prevents duplicate item responses and keeps participant capability identity separate from response content.';

create or replace function consulting_security.validate_response_provenance()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_expected_source uuid;
  v_fragment_source uuid;
  v_version uuid;
  v_item_version uuid;
  v_confidentiality consulting_os.assessment_confidentiality;
  v_record_visibility consulting_os.visibility_scope;
  v_fragment_visibility consulting_os.visibility_scope;
begin
  select f.evidence_source_id, d.visibility_scope into v_fragment_source, v_fragment_visibility
  from consulting_os.evidence_fragments f
  join consulting_os.domain_objects d on d.id = f.evidence_source_id and d.organization_id = f.organization_id
  where f.id = new.evidence_fragment_id and f.organization_id = new.organization_id;
  select visibility_scope into v_record_visibility from consulting_os.domain_objects
  where id = new.id and organization_id = new.organization_id;

  if tg_table_name = 'interview_responses' then
    select evidence_source_id into v_expected_source from consulting_os.interviews
    where id = new.interview_id and organization_id = new.organization_id;
  else
    select evidence_source_id, instrument_version_id, confidentiality
      into v_expected_source, v_version, v_confidentiality
    from consulting_os.assessment_administrations
    where id = new.administration_id and organization_id = new.organization_id;
    select instrument_version_id into v_item_version from consulting_os.assessment_items
    where id = new.item_id and organization_id = new.organization_id;
    if v_item_version is distinct from v_version then
      raise exception 'response item must belong to the administered instrument version'
        using errcode = '23514';
    end if;
    if v_confidentiality in ('CONFIDENTIAL', 'ANONYMOUS') and tg_table_schema <> 'consulting_private' then
      raise exception 'confidential and anonymous responses require physical private partitioning'
        using errcode = '42501';
    end if;
    if v_confidentiality in ('CONFIDENTIAL', 'ANONYMOUS') and new.respondent_person_id is not null then
      raise exception 'confidential and anonymous response rows cannot retain respondent identity'
        using errcode = '23514';
    end if;
    if v_confidentiality = 'IDENTIFIED'
      and tg_table_schema = 'consulting_os'
      and new.respondent_person_id is null
    then
      raise exception 'identified organizational response rows require respondent identity'
        using errcode = '23514';
    end if;
    if new.participant_token_hash is null then
      raise exception 'participant assessment responses require a capability token hash'
        using errcode = '23514';
    end if;
  end if;

  if v_expected_source is distinct from v_fragment_source
    or not consulting_security.visibility_can_contain(v_record_visibility, v_fragment_visibility)
  then
    raise exception 'response must cite a fragment from its activity source without broadening source visibility'
      using errcode = '23514';
  end if;
  return new;
end
$$;

revoke all on function consulting_security.validate_response_provenance() from public, anon, authenticated;

create or replace function consulting_os.resolve_assessment_participant_link(p_token_hash text)
returns table (
  link_id uuid, organization_name text, instrument_name text, administration_id uuid,
  item_id uuid, prompt text, response_type text, response_options jsonb,
  confidentiality consulting_os.assessment_confidentiality, closes_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select l.id, o.name, i.name, a.id, q.id, q.prompt, q.response_type, q.response_options, a.confidentiality, a.closes_at
  from consulting_private.assessment_participant_links l
  join consulting_os.organizations o on o.id = l.organization_id
  join consulting_os.assessment_administrations a on a.id = l.administration_id and a.organization_id = l.organization_id
  join consulting_os.assessment_instrument_versions v on v.id = a.instrument_version_id and v.organization_id = a.organization_id
  join consulting_os.assessment_instruments i on i.id = v.instrument_id and i.organization_id = v.organization_id
  join consulting_os.assessment_items q on q.instrument_version_id = v.id and q.organization_id = v.organization_id
  where l.token_hash = p_token_hash and l.link_status = 'ACTIVE' and l.expires_at > now()
    and a.administration_status = 'OPEN' and a.opens_at <= now() and a.closes_at > now()
    and not exists (
      select 1
      from consulting_private.assessment_participant_item_submissions s
      where s.participant_link_id = l.id
        and s.organization_id = l.organization_id
        and s.item_id = q.id
    )
  order by q.ordinal
$$;

create or replace function consulting_os.submit_assessment_participant_response(p_token_hash text, p_item_id uuid, p_response jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_link consulting_private.assessment_participant_links%rowtype;
  v_admin consulting_os.assessment_administrations%rowtype;
  v_response_id uuid := gen_random_uuid();
  v_fragment_id uuid;
  v_content text := p_response::text;
begin
  if coalesce(current_setting('request.jwt.claim.role', true), '') <> 'service_role' then
    raise exception 'service role context required' using errcode = '42501';
  end if;
  if p_response is null or p_response = 'null'::jsonb then
    raise exception 'assessment response is required' using errcode = '22023';
  end if;

  select * into v_link
  from consulting_private.assessment_participant_links
  where token_hash = p_token_hash
  for update;
  if v_link.id is null or v_link.link_status <> 'ACTIVE' or v_link.expires_at <= now() then
    raise exception 'assessment link is no longer active' using errcode = '22023';
  end if;
  select * into v_admin
  from consulting_os.assessment_administrations
  where id = v_link.administration_id and organization_id = v_link.organization_id;
  if v_admin.administration_status <> 'OPEN' or v_admin.opens_at > now() or v_admin.closes_at <= now() then
    raise exception 'assessment is not accepting responses' using errcode = '22023';
  end if;
  if not exists (
    select 1 from consulting_os.assessment_items
    where id = p_item_id
      and organization_id = v_link.organization_id
      and instrument_version_id = v_admin.instrument_version_id
  ) then
    raise exception 'assessment item is outside administration' using errcode = '23503';
  end if;
  if exists (
    select 1 from consulting_private.assessment_participant_item_submissions
    where participant_link_id = v_link.id
      and organization_id = v_link.organization_id
      and item_id = p_item_id
  ) then
    raise exception 'assessment item has already been answered' using errcode = '23505';
  end if;

  insert into consulting_os.evidence_fragments(
    organization_id, evidence_source_id, locator_kind, locator, content_text, content_sha256,
    captured_context, directness, relevance, source_reliability, context_completeness, quality_rationale, created_by
  ) values (
    v_link.organization_id, v_admin.evidence_source_id, 'ASSESSMENT_ITEM',
    jsonb_build_object('item_id', p_item_id, 'participant_link_id', v_link.id),
    v_content, encode(extensions.digest(convert_to(v_content, 'UTF8'), 'sha256'), 'hex'),
    'Participant response submitted through an expiring assessment link.',
    'HIGH', 'HIGH', 'MODERATE', 'MODERATE',
    'Response is evidence and has not been interpreted or diagnosed.', v_admin.created_by
  ) returning id into v_fragment_id;

  insert into consulting_os.domain_objects(
    id, organization_id, engagement_id, object_type, visibility_scope, owner_person_id, origin, created_by
  ) values (
    v_response_id, v_link.organization_id, v_link.engagement_id, 'ASSESSMENT_RESPONSE',
    'LEADERSHIP_RESTRICTED'::consulting_os.visibility_scope,
    case when v_link.confidentiality = 'IDENTIFIED' then v_link.respondent_person_id else null end,
    'HUMAN', v_admin.created_by
  );

  insert into consulting_private.assessment_responses(
    id, organization_id, administration_id, item_id, respondent_person_id, participant_token_hash,
    response_value, evidence_fragment_id, submitted_at, created_by
  ) values (
    v_response_id, v_link.organization_id, v_link.administration_id, p_item_id,
    case when v_link.confidentiality = 'IDENTIFIED' then v_link.respondent_person_id else null end,
    p_token_hash, p_response, v_fragment_id, now(), v_admin.created_by
  );

  insert into consulting_private.assessment_participant_item_submissions(
    participant_link_id, organization_id, item_id, response_id
  ) values (v_link.id, v_link.organization_id, p_item_id, v_response_id);

  if not exists (
    select 1
    from consulting_os.assessment_items q
    where q.organization_id = v_link.organization_id
      and q.instrument_version_id = v_admin.instrument_version_id
      and not exists (
        select 1
        from consulting_private.assessment_participant_item_submissions s
        where s.participant_link_id = v_link.id
          and s.organization_id = v_link.organization_id
          and s.item_id = q.id
      )
  ) then
    update consulting_private.assessment_participant_links
    set link_status = 'USED', used_at = now()
    where id = v_link.id;
  end if;
  return v_response_id;
end
$$;

revoke all on function consulting_os.resolve_assessment_participant_link(text) from public, anon, authenticated;
revoke all on function consulting_os.submit_assessment_participant_response(text, uuid, jsonb) from public, anon, authenticated;
grant execute on function consulting_os.resolve_assessment_participant_link(text) to service_role;
grant execute on function consulting_os.submit_assessment_participant_response(text, uuid, jsonb) to service_role;
