-- OAuth-protected MCP support.
-- Guided answers are tenant-scoped operational records. MCP audit rows retain
-- execution metadata only; prompts, arguments, answers, and tool results are
-- intentionally excluded.

create table if not exists consulting_os.guided_record_responses (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  engagement_id uuid not null,
  record_kind text not null check (record_kind in ('PRODUCT', 'AUDIT', 'INTERVIEW')),
  record_id uuid not null,
  question_id text not null check (question_id ~ '^[a-z][a-z0-9-]{1,79}$'),
  answer text not null check (length(btrim(answer)) > 0 and length(answer) <= 12000),
  confirmed_by uuid not null references consulting_os.people(id) on delete restrict,
  confirmed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (organization_id, engagement_id, record_kind, record_id, question_id)
);

create or replace function consulting_security.guided_record_exists(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_record_kind text,
  p_record_id uuid
) returns boolean
language sql
stable
security definer
set search_path = pg_catalog, consulting_os, consulting_security
as $$
  select case p_record_kind
    when 'PRODUCT' then exists (
      select 1 from consulting_os.engagement_products r
      where r.id = p_record_id and r.organization_id = p_organization_id and r.engagement_id = p_engagement_id
    )
    when 'AUDIT' then exists (
      select 1 from consulting_os.written_audit_assignments r
      where r.id = p_record_id and r.organization_id = p_organization_id and r.engagement_id = p_engagement_id
    )
    when 'INTERVIEW' then exists (
      select 1 from consulting_os.interviews r
      where r.id = p_record_id and r.organization_id = p_organization_id and r.engagement_id = p_engagement_id
    )
    else false
  end
$$;

revoke all on function consulting_security.guided_record_exists(uuid, uuid, text, uuid) from public;
grant execute on function consulting_security.guided_record_exists(uuid, uuid, text, uuid) to authenticated, service_role;

alter table consulting_os.guided_record_responses enable row level security;
drop policy if exists guided_responses_select on consulting_os.guided_record_responses;
create policy guided_responses_select on consulting_os.guided_record_responses
  for select to authenticated
  using (
    consulting_security.has_engagement_access(organization_id, engagement_id)
    and consulting_security.guided_record_exists(organization_id, engagement_id, record_kind, record_id)
  );
drop policy if exists guided_responses_insert on consulting_os.guided_record_responses;
create policy guided_responses_insert on consulting_os.guided_record_responses
  for insert to authenticated
  with check (
    confirmed_by = consulting_security.current_person_id()
    and consulting_security.can_manage_organization(organization_id)
    and consulting_security.has_engagement_access(organization_id, engagement_id)
    and consulting_security.guided_record_exists(organization_id, engagement_id, record_kind, record_id)
  );
drop policy if exists guided_responses_update on consulting_os.guided_record_responses;
create policy guided_responses_update on consulting_os.guided_record_responses
  for update to authenticated
  using (
    consulting_security.can_manage_organization(organization_id)
    and consulting_security.has_engagement_access(organization_id, engagement_id)
  )
  with check (
    confirmed_by = consulting_security.current_person_id()
    and consulting_security.can_manage_organization(organization_id)
    and consulting_security.has_engagement_access(organization_id, engagement_id)
    and consulting_security.guided_record_exists(organization_id, engagement_id, record_kind, record_id)
  );

grant select, insert, update on consulting_os.guided_record_responses to authenticated;
grant all on consulting_os.guided_record_responses to service_role;
create index if not exists guided_responses_org_engagement_idx on consulting_os.guided_record_responses (organization_id, engagement_id, record_kind, record_id);
drop trigger if exists guided_record_responses_updated_at on consulting_os.guided_record_responses;
create trigger guided_record_responses_updated_at before update on consulting_os.guided_record_responses for each row execute function consulting_security.set_updated_at();

create table if not exists consulting_os.mcp_tool_audit (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  engagement_id uuid not null,
  person_id uuid not null references consulting_os.people(id) on delete restrict,
  oauth_client_id text not null check (length(btrim(oauth_client_id)) > 0),
  tool_name text not null check (tool_name in (
    'list_available_engagements', 'list_engagement_records', 'get_guided_record', 'save_guided_response',
    'list_assessment_instruments', 'get_assessment_instrument', 'start_assessment_administration', 'save_assessment_response'
  )),
  succeeded boolean not null,
  error_kind text,
  occurred_at timestamptz not null default now(),
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict
);

comment on table consulting_os.mcp_tool_audit is 'Content-free audit of OAuth MCP tool execution. Never stores prompts, arguments, answers, or results.';
alter table consulting_os.mcp_tool_audit enable row level security;
revoke all on consulting_os.mcp_tool_audit from anon, authenticated;
grant all on consulting_os.mcp_tool_audit to service_role;
create index if not exists mcp_tool_audit_org_time_idx on consulting_os.mcp_tool_audit (organization_id, occurred_at desc);
create index if not exists mcp_tool_audit_client_time_idx on consulting_os.mcp_tool_audit (oauth_client_id, occurred_at desc);

notify pgrst, 'reload schema';
