-- Client MCP workspace support. Engagement membership and explicit assigned
-- audit/interview participant identity remain the contribution boundary.
-- This deliberately does not introduce conversation or agent-session storage.

create or replace function consulting_security.has_active_engagement_membership(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_person_id uuid default consulting_security.current_person_id()
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(exists (
    select 1
    from consulting_os.organization_memberships om
    join consulting_os.engagement_memberships em
      on em.organization_membership_id = om.id
     and em.organization_id = om.organization_id
    where om.organization_id = p_organization_id
      and em.engagement_id = p_engagement_id
      and om.person_id = p_person_id
      and om.status = 'ACTIVE'
      and em.status = 'ACTIVE'
      and om.effective_from <= now()
      and (om.effective_to is null or om.effective_to > now())
  ), false)
$$;

create or replace function consulting_security.is_guided_record_participant(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_record_kind text,
  p_record_id uuid,
  p_person_id uuid default consulting_security.current_person_id()
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_person_id is not null
    and consulting_security.has_active_engagement_membership(
      p_organization_id, p_engagement_id, p_person_id
    )
    and case p_record_kind
      when 'AUDIT' then exists (
        select 1
        from consulting_os.written_audit_assignments a
        where a.id = p_record_id
          and a.organization_id = p_organization_id
          and a.engagement_id = p_engagement_id
          and a.respondent_person_id = p_person_id
      )
      when 'INTERVIEW' then exists (
        select 1
        from consulting_os.interviews i
        where i.id = p_record_id
          and i.organization_id = p_organization_id
          and i.engagement_id = p_engagement_id
          and i.participant_person_id = p_person_id
      )
      else false
    end
$$;

create or replace function consulting_security.validate_written_audit_respondent()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.respondent_person_id is not null
    and not consulting_security.has_active_engagement_membership(
      new.organization_id, new.engagement_id, new.respondent_person_id
    )
  then
    raise exception 'written audit respondent must be an active engagement participant' using errcode = '42501';
  end if;
  return new;
end
$$;

revoke all on function consulting_security.has_active_engagement_membership(uuid, uuid, uuid) from public, anon;
revoke all on function consulting_security.is_guided_record_participant(uuid, uuid, text, uuid, uuid) from public, anon;
revoke all on function consulting_security.validate_written_audit_respondent() from public, anon, authenticated;
grant execute on function consulting_security.has_active_engagement_membership(uuid, uuid, uuid) to authenticated, service_role;
grant execute on function consulting_security.is_guided_record_participant(uuid, uuid, text, uuid, uuid) to authenticated, service_role;

drop trigger if exists written_audits_participant_validate on consulting_os.written_audit_assignments;
create trigger written_audits_participant_validate
before insert or update of respondent_person_id, organization_id, engagement_id
on consulting_os.written_audit_assignments
for each row execute function consulting_security.validate_written_audit_respondent();

drop policy if exists guided_responses_select on consulting_os.guided_record_responses;
create policy guided_responses_select on consulting_os.guided_record_responses
  for select to authenticated
  using (
    consulting_security.guided_record_exists(organization_id, engagement_id, record_kind, record_id)
    and (
      consulting_security.can_manage_organization(organization_id)
      or consulting_security.is_guided_record_participant(organization_id, engagement_id, record_kind, record_id)
    )
  );

drop policy if exists guided_responses_insert on consulting_os.guided_record_responses;
create policy guided_responses_insert on consulting_os.guided_record_responses
  for insert to authenticated
  with check (
    confirmed_by = consulting_security.current_person_id()
    and consulting_security.guided_record_exists(organization_id, engagement_id, record_kind, record_id)
    and (
      consulting_security.can_manage_organization(organization_id)
      or consulting_security.is_guided_record_participant(organization_id, engagement_id, record_kind, record_id)
    )
  );

drop policy if exists guided_responses_update on consulting_os.guided_record_responses;
create policy guided_responses_update on consulting_os.guided_record_responses
  for update to authenticated
  using (
    consulting_security.can_manage_organization(organization_id)
    or (
      confirmed_by = consulting_security.current_person_id()
      and consulting_security.is_guided_record_participant(organization_id, engagement_id, record_kind, record_id)
    )
  )
  with check (
    confirmed_by = consulting_security.current_person_id()
    and consulting_security.guided_record_exists(organization_id, engagement_id, record_kind, record_id)
    and (
      consulting_security.can_manage_organization(organization_id)
      or consulting_security.is_guided_record_participant(organization_id, engagement_id, record_kind, record_id)
    )
  );

create or replace function consulting_os.list_my_guided_records(
  p_organization_id uuid,
  p_engagement_id uuid
)
returns table (
  record_kind text,
  record_id uuid,
  title text,
  record_status text,
  scheduled_at timestamptz,
  completed_response_count bigint
)
language sql
stable
security definer
set search_path = ''
as $$
  with actor as (
    select consulting_security.current_person_id() as person_id
  ), permitted as (
    select actor.person_id
    from actor
    where consulting_security.has_active_engagement_membership(
      p_organization_id, p_engagement_id, actor.person_id
    )
  ), records as (
    select
      'AUDIT'::text as record_kind,
      a.id as record_id,
      a.respondent_label as title,
      a.audit_status as record_status,
      null::timestamptz as scheduled_at,
      count(r.id) filter (where r.confirmed_by = permitted.person_id) as completed_response_count
    from consulting_os.written_audit_assignments a
    join permitted on true
    left join consulting_os.guided_record_responses r
      on r.organization_id = a.organization_id and r.engagement_id = a.engagement_id
     and r.record_kind = 'AUDIT' and r.record_id = a.id
    where a.organization_id = p_organization_id
      and a.engagement_id = p_engagement_id
      and a.respondent_person_id = permitted.person_id
    group by a.id, a.respondent_label, a.audit_status
    union all
    select
      'INTERVIEW'::text as record_kind,
      i.id as record_id,
      i.participant_label as title,
      i.interview_status as record_status,
      i.scheduled_at as scheduled_at,
      count(r.id) filter (where r.confirmed_by = permitted.person_id) as completed_response_count
    from consulting_os.interviews i
    join permitted on true
    left join consulting_os.guided_record_responses r
      on r.organization_id = i.organization_id and r.engagement_id = i.engagement_id
     and r.record_kind = 'INTERVIEW' and r.record_id = i.id
    where i.organization_id = p_organization_id
      and i.engagement_id = p_engagement_id
      and i.participant_person_id = permitted.person_id
      and i.interview_status <> 'CANCELLED'
    group by i.id, i.participant_label, i.interview_status, i.scheduled_at
  )
  select
    record_kind,
    record_id,
    title,
    record_status,
    scheduled_at,
    completed_response_count
  from records
  order by scheduled_at nulls last, title
$$;

revoke all on function consulting_os.list_my_guided_records(uuid, uuid) from public, anon;
grant execute on function consulting_os.list_my_guided_records(uuid, uuid) to authenticated, service_role;

create or replace function consulting_os.get_my_guided_record(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_record_kind text,
  p_record_id uuid
)
returns table (
  record_kind text,
  record_id uuid,
  title text,
  record_context text,
  record_status text,
  question_id text,
  answer text,
  updated_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  with actor as (
    select consulting_security.current_person_id() as person_id
  ), permitted as (
    select actor.person_id
    from actor
    where consulting_security.is_guided_record_participant(
      p_organization_id, p_engagement_id, p_record_kind, p_record_id, actor.person_id
    )
  ), record as (
    select 'AUDIT'::text as kind, a.id, a.respondent_label as title,
      coalesce(a.follow_up_note, '') as record_context, a.audit_status as record_status
    from consulting_os.written_audit_assignments a
    join permitted on true
    where p_record_kind = 'AUDIT'
      and a.id = p_record_id and a.organization_id = p_organization_id and a.engagement_id = p_engagement_id
      and a.respondent_person_id = permitted.person_id
    union all
    select 'INTERVIEW'::text, i.id, i.participant_label,
      coalesce(i.objective, i.guide_name), i.interview_status
    from consulting_os.interviews i
    join permitted on true
    where p_record_kind = 'INTERVIEW'
      and i.id = p_record_id and i.organization_id = p_organization_id and i.engagement_id = p_engagement_id
      and i.participant_person_id = permitted.person_id and i.interview_status <> 'CANCELLED'
  )
  select record.kind, record.id, record.title, record.record_context, record.record_status,
    response.question_id, response.answer, response.updated_at
  from record
  left join consulting_os.guided_record_responses response
    on response.organization_id = p_organization_id and response.engagement_id = p_engagement_id
   and response.record_kind = record.kind and response.record_id = record.id
   and response.confirmed_by = (select person_id from actor)
$$;

revoke all on function consulting_os.get_my_guided_record(uuid, uuid, text, uuid) from public, anon;
grant execute on function consulting_os.get_my_guided_record(uuid, uuid, text, uuid) to authenticated, service_role;

alter table consulting_os.mcp_tool_audit
  drop constraint if exists mcp_tool_audit_tool_name_check;
alter table consulting_os.mcp_tool_audit
  add constraint mcp_tool_audit_tool_name_check check (tool_name in (
    'list_available_engagements', 'list_engagement_records', 'get_guided_record', 'save_guided_response',
    'list_assessment_instruments', 'get_assessment_instrument', 'start_assessment_administration', 'save_assessment_response',
    'client_open_workspace', 'client_list_my_engagements', 'client_list_my_guided_records',
    'client_get_guided_record', 'client_save_confirmed_response'
  ));

create index if not exists written_audits_participant_scope_idx
  on consulting_os.written_audit_assignments (organization_id, engagement_id, respondent_person_id)
  where respondent_person_id is not null;
create index if not exists interviews_participant_scope_idx
  on consulting_os.interviews (organization_id, engagement_id, participant_person_id)
  where participant_person_id is not null;

notify pgrst, 'reload schema';