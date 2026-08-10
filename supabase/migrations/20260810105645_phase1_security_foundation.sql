-- Lead Emergence Consulting OS — Phase 1 security foundation
-- Additive migration. Production application requires a separately selected target.
-- Forward repair: add a later migration; do not rewrite this file after application.
-- Rollback: drop the three Consulting schemas and the consulting-private bucket only
-- in a verified disposable environment. Never use that rollback against client data.

create schema if not exists consulting_os;
create schema if not exists consulting_security;
create schema if not exists consulting_private;

comment on schema consulting_os is 'Lead Emergence Consulting OS tenant-owned application data.';
comment on schema consulting_security is 'Non-exposed Consulting authorization and privileged helpers.';
comment on schema consulting_private is 'Physically partitioned Consulting private records with no ordinary Data API grants.';

revoke all on schema consulting_os from public, anon;
revoke all on schema consulting_security from public, anon;
revoke all on schema consulting_private from public, anon, authenticated;
grant usage on schema consulting_os to authenticated, service_role;
grant usage on schema consulting_security to authenticated, service_role;
grant usage on schema consulting_private to service_role;

create type consulting_os.platform_role as enum (
  'PLATFORM_ADMIN',
  'CONSULTANT',
  'CLIENT_ADMIN',
  'CLIENT_LEADER',
  'CLIENT_MEMBER'
);

create type consulting_os.access_status as enum (
  'INVITED',
  'ACTIVE',
  'SUSPENDED',
  'REMOVED'
);

create type consulting_os.visibility_scope as enum (
  'CONSULTANT_PRIVATE',
  'INDIVIDUAL_PRIVATE',
  'COACHING_SHARED',
  'TEAM_SHARED',
  'LEADERSHIP_RESTRICTED',
  'ENGAGEMENT_SHARED',
  'ORGANIZATION_SHARED',
  'PLATFORM_RESTRICTED'
);

create type consulting_os.grant_permission as enum ('READ', 'CONTRIBUTE', 'MANAGE');
create type consulting_os.record_origin as enum ('HUMAN', 'SYSTEM', 'AI', 'IMPORTED');
create type consulting_os.review_status as enum ('SUGGESTED', 'ACCEPTED', 'REJECTED', 'SUPERSEDED');
create type consulting_os.private_record_kind as enum ('CONSULTANT_NOTE', 'INDIVIDUAL_REFLECTION');
create type consulting_os.retention_class as enum (
  'ENGAGEMENT_RECORD',
  'ORGANIZATIONAL_MEMORY',
  'PRIVATE_COACHING',
  'SECURITY_AUDIT',
  'IDENTITY_REFERENCE'
);

create table consulting_os.people (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null unique references auth.users(id) on delete restrict,
  display_name text not null check (length(btrim(display_name)) > 0),
  preferred_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, auth_user_id)
);

create table consulting_os.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(btrim(name)) > 0),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  is_active boolean not null default true,
  created_by uuid references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table consulting_os.organization_memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  person_id uuid not null references consulting_os.people(id) on delete restrict,
  platform_role consulting_os.platform_role not null,
  status consulting_os.access_status not null default 'INVITED',
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  created_by uuid references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint organization_memberships_role_check check (platform_role <> 'PLATFORM_ADMIN'),
  constraint organization_memberships_dates_check check (effective_to is null or effective_to >= effective_from),
  unique (organization_id, person_id),
  unique (id, organization_id)
);

create table consulting_os.consultant_assignments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  consultant_person_id uuid not null references consulting_os.people(id) on delete restrict,
  status consulting_os.access_status not null default 'INVITED',
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  assignment_reason text not null check (length(btrim(assignment_reason)) > 0),
  created_by uuid references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint consultant_assignments_dates_check check (effective_to is null or effective_to >= effective_from),
  unique (organization_id, consultant_person_id),
  unique (id, organization_id)
);

create table consulting_security.platform_admin_assignments (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references consulting_os.people(id) on delete restrict,
  status consulting_os.access_status not null default 'INVITED',
  purpose text not null check (length(btrim(purpose)) > 0),
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  created_by uuid references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint platform_admin_dates_check check (effective_to is null or effective_to >= effective_from),
  unique (person_id)
);

create table consulting_os.engagements (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  name text not null check (length(btrim(name)) > 0),
  status text not null default 'PLANNED' check (status in ('PLANNED', 'ACTIVE', 'PAUSED', 'COMPLETED', 'ARCHIVED')),
  starts_on date,
  ends_on date,
  created_by uuid references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint engagements_dates_check check (ends_on is null or starts_on is null or ends_on >= starts_on),
  unique (id, organization_id)
);

create table consulting_os.engagement_memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  engagement_id uuid not null,
  organization_membership_id uuid not null,
  status consulting_os.access_status not null default 'INVITED',
  created_by uuid references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (engagement_id, organization_id)
    references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (organization_membership_id, organization_id)
    references consulting_os.organization_memberships(id, organization_id) on delete restrict,
  unique (engagement_id, organization_membership_id),
  unique (id, organization_id)
);

-- Security metadata lands in Phase 1 so every later typed record starts with the
-- same tenant and visibility contract. Phase 2 adds epistemic/domain detail.
create table consulting_os.domain_objects (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  engagement_id uuid,
  object_type text not null check (object_type ~ '^[A-Z][A-Z0-9_]*$'),
  visibility_scope consulting_os.visibility_scope not null,
  owner_person_id uuid references consulting_os.people(id) on delete restrict,
  origin consulting_os.record_origin not null default 'HUMAN',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  foreign key (engagement_id, organization_id)
    references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.visibility_grants (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  domain_object_id uuid not null,
  grantee_person_id uuid not null references consulting_os.people(id) on delete restrict,
  permission consulting_os.grant_permission not null default 'READ',
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint visibility_grants_dates_check check (effective_to is null or effective_to >= effective_from),
  foreign key (domain_object_id, organization_id)
    references consulting_os.domain_objects(id, organization_id) on delete restrict,
  unique (domain_object_id, grantee_person_id, permission)
);

create type consulting_os.relationship_type as enum (
  'SUPPORTED_BY', 'CHALLENGED_BY', 'DERIVED_FROM', 'CONTRIBUTES_TO',
  'SUGGESTS', 'EXPLAINS', 'VALIDATES', 'REJECTS', 'SUPERSEDES',
  'INFORMS', 'RESPONDS_TO', 'AUTHORIZES', 'CREATES', 'REQUIRES',
  'DEVELOPS', 'ENABLES', 'CONSTRAINS', 'OWNS', 'MEASURED_BY',
  'MEASURES', 'EVALUATES', 'ASSOCIATED_WITH', 'CONTRIBUTED_TO',
  'CAUSES', 'BECOMES_BASELINE_FOR', 'REENTERS_AS'
);

create table consulting_os.entity_relationships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  engagement_id uuid,
  relationship_type consulting_os.relationship_type not null,
  source_type text not null check (source_type ~ '^[A-Z][A-Z0-9_]*$'),
  source_id uuid not null,
  target_type text not null check (target_type ~ '^[A-Z][A-Z0-9_]*$'),
  target_id uuid not null,
  origin consulting_os.record_origin not null default 'HUMAN',
  review_status consulting_os.review_status,
  rationale text not null check (length(btrim(rationale)) > 0),
  confidence numeric(5,4) check (confidence is null or confidence between 0 and 1),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  effective_from timestamptz,
  effective_to timestamptz,
  foreign key (engagement_id, organization_id)
    references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (source_id, organization_id)
    references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (target_id, organization_id)
    references consulting_os.domain_objects(id, organization_id) on delete restrict,
  constraint relationship_dates_check check (effective_to is null or effective_from is null or effective_to >= effective_from),
  constraint relationship_source_type_check check (source_type <> ''),
  constraint relationship_target_type_check check (target_type <> ''),
  constraint ai_causes_check check (
    not (origin = 'AI' and relationship_type = 'CAUSES' and review_status = 'ACCEPTED')
  ),
  unique (id, organization_id)
);

create table consulting_os.file_objects (
  id uuid primary key,
  organization_id uuid not null,
  bucket_id text not null default 'consulting-private',
  object_path text not null,
  source_domain_object_id uuid,
  visibility_scope consulting_os.visibility_scope not null,
  owner_person_id uuid references consulting_os.people(id) on delete restrict,
  retention_class consulting_os.retention_class not null,
  content_sha256 text check (content_sha256 is null or content_sha256 ~ '^[a-f0-9]{64}$'),
  media_type text,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id)
    references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (source_domain_object_id, organization_id)
    references consulting_os.domain_objects(id, organization_id) on delete restrict,
  constraint file_objects_bucket_check check (bucket_id = 'consulting-private'),
  constraint file_objects_path_check check (split_part(object_path, '/', 1) = organization_id::text),
  unique (bucket_id, object_path),
  unique (id, organization_id)
);

create table consulting_private.private_records (
  id uuid primary key,
  organization_id uuid not null,
  kind consulting_os.private_record_kind not null,
  subject_person_id uuid not null references consulting_os.people(id) on delete restrict,
  author_person_id uuid not null references consulting_os.people(id) on delete restrict,
  ciphertext_or_content text not null check (length(ciphertext_or_content) > 0),
  created_at timestamptz not null default now(),
  corrected_by_id uuid,
  corrected_at timestamptz,
  foreign key (id, organization_id)
    references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (corrected_by_id, organization_id)
    references consulting_private.private_records(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.audit_events (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references consulting_os.organizations(id) on delete restrict,
  actor_auth_user_id uuid,
  actor_person_id uuid references consulting_os.people(id) on delete restrict,
  event_type text not null check (event_type ~ '^[A-Z][A-Z0-9_]*$'),
  target_table text not null,
  target_id uuid,
  operation text not null check (operation in ('INSERT', 'UPDATE', 'DELETE', 'EXPORT', 'PROMOTE', 'PRIVILEGED_ACCESS')),
  reason text,
  correlation_id text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

create index people_auth_user_idx on consulting_os.people(auth_user_id);
create index organizations_created_by_idx on consulting_os.organizations(created_by);
create index organization_memberships_person_status_idx
  on consulting_os.organization_memberships(person_id, status, organization_id);
create index organization_memberships_org_role_status_idx
  on consulting_os.organization_memberships(organization_id, platform_role, status);
create index organization_memberships_created_by_idx on consulting_os.organization_memberships(created_by);
create index consultant_assignments_person_status_idx
  on consulting_os.consultant_assignments(consultant_person_id, status, organization_id);
create index consultant_assignments_created_by_idx on consulting_os.consultant_assignments(created_by);
create index platform_admin_assignments_created_by_idx
  on consulting_security.platform_admin_assignments(created_by);
create index engagements_org_idx on consulting_os.engagements(organization_id);
create index engagements_created_by_idx on consulting_os.engagements(created_by);
create index engagement_memberships_membership_status_idx
  on consulting_os.engagement_memberships(organization_membership_id, status, engagement_id);
create index engagement_memberships_membership_org_idx
  on consulting_os.engagement_memberships(organization_membership_id, organization_id);
create index engagement_memberships_created_by_idx on consulting_os.engagement_memberships(created_by);
create index domain_objects_org_visibility_idx
  on consulting_os.domain_objects(organization_id, visibility_scope, engagement_id);
create index domain_objects_owner_idx on consulting_os.domain_objects(owner_person_id, organization_id);
create index domain_objects_engagement_org_idx on consulting_os.domain_objects(engagement_id, organization_id)
  where engagement_id is not null;
create index domain_objects_created_by_idx on consulting_os.domain_objects(created_by);
create index visibility_grants_grantee_idx
  on consulting_os.visibility_grants(grantee_person_id, organization_id, domain_object_id);
create index visibility_grants_object_org_idx
  on consulting_os.visibility_grants(domain_object_id, organization_id);
create index visibility_grants_created_by_idx on consulting_os.visibility_grants(created_by);
create index relationships_source_idx on consulting_os.entity_relationships(organization_id, source_id);
create index relationships_target_idx on consulting_os.entity_relationships(organization_id, target_id);
create index relationships_engagement_org_idx
  on consulting_os.entity_relationships(engagement_id, organization_id) where engagement_id is not null;
create index relationships_created_by_idx on consulting_os.entity_relationships(created_by);
create index file_objects_org_visibility_idx
  on consulting_os.file_objects(organization_id, visibility_scope);
create index file_objects_source_org_idx
  on consulting_os.file_objects(source_domain_object_id, organization_id) where source_domain_object_id is not null;
create index file_objects_owner_idx on consulting_os.file_objects(owner_person_id);
create index file_objects_created_by_idx on consulting_os.file_objects(created_by);
create index private_records_subject_idx on consulting_private.private_records(subject_person_id, organization_id);
create index private_records_author_idx on consulting_private.private_records(author_person_id, organization_id);
create index private_records_corrected_by_idx
  on consulting_private.private_records(corrected_by_id, organization_id) where corrected_by_id is not null;
create index audit_events_org_time_idx on consulting_os.audit_events(organization_id, occurred_at desc);
create index audit_events_actor_time_idx on consulting_os.audit_events(actor_auth_user_id, occurred_at desc);
create index audit_events_actor_person_idx on consulting_os.audit_events(actor_person_id, occurred_at desc);

create or replace function consulting_security.current_person_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select p.id
  from consulting_os.people p
  where p.auth_user_id = (select auth.uid())
  limit 1
$$;

create or replace function consulting_security.is_platform_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(exists (
    select 1
    from consulting_security.platform_admin_assignments paa
    join consulting_os.people p on p.id = paa.person_id
    where p.auth_user_id = (select auth.uid())
      and paa.status = 'ACTIVE'
      and paa.effective_from <= now()
      and (paa.effective_to is null or paa.effective_to > now())
  ), false)
$$;

create or replace function consulting_security.has_active_org_role(
  p_organization_id uuid,
  p_roles consulting_os.platform_role[] default null
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(exists (
    select 1
    from consulting_os.organization_memberships m
    join consulting_os.people p on p.id = m.person_id
    where m.organization_id = p_organization_id
      and p.auth_user_id = (select auth.uid())
      and m.status = 'ACTIVE'
      and m.effective_from <= now()
      and (m.effective_to is null or m.effective_to > now())
      and (p_roles is null or m.platform_role = any(p_roles))
  ), false)
$$;

create or replace function consulting_security.has_active_consultant_assignment(p_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(exists (
    select 1
    from consulting_os.consultant_assignments ca
    join consulting_os.people p on p.id = ca.consultant_person_id
    where ca.organization_id = p_organization_id
      and p.auth_user_id = (select auth.uid())
      and ca.status = 'ACTIVE'
      and ca.effective_from <= now()
      and (ca.effective_to is null or ca.effective_to > now())
  ), false)
$$;

create or replace function consulting_security.can_access_organization(p_organization_id uuid)
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select (select auth.uid()) is not null
    and (
      consulting_security.has_active_org_role(p_organization_id, null)
      or consulting_security.has_active_consultant_assignment(p_organization_id)
    )
$$;

create or replace function consulting_security.can_manage_organization(p_organization_id uuid)
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select (select auth.uid()) is not null
    and (
      consulting_security.has_active_consultant_assignment(p_organization_id)
      or consulting_security.has_active_org_role(
        p_organization_id,
        array['CLIENT_ADMIN']::consulting_os.platform_role[]
      )
    )
$$;

create or replace function consulting_security.has_engagement_access(
  p_organization_id uuid,
  p_engagement_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when p_engagement_id is null then consulting_security.can_access_organization(p_organization_id)
    when consulting_security.has_active_consultant_assignment(p_organization_id) then true
    else coalesce(exists (
      select 1
      from consulting_os.engagement_memberships em
      join consulting_os.organization_memberships om
        on om.id = em.organization_membership_id
       and om.organization_id = em.organization_id
      join consulting_os.people p on p.id = om.person_id
      where em.organization_id = p_organization_id
        and em.engagement_id = p_engagement_id
        and p.auth_user_id = (select auth.uid())
        and em.status = 'ACTIVE'
        and om.status = 'ACTIVE'
        and om.effective_from <= now()
        and (om.effective_to is null or om.effective_to > now())
    ), false)
  end
$$;

create or replace function consulting_security.has_visibility_grant(
  p_organization_id uuid,
  p_domain_object_id uuid,
  p_permissions consulting_os.grant_permission[] default array['READ', 'CONTRIBUTE', 'MANAGE']::consulting_os.grant_permission[]
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(exists (
    select 1
    from consulting_os.visibility_grants vg
    join consulting_os.people p on p.id = vg.grantee_person_id
    where vg.organization_id = p_organization_id
      and vg.domain_object_id = p_domain_object_id
      and p.auth_user_id = (select auth.uid())
      and vg.permission = any(p_permissions)
      and vg.effective_from <= now()
      and (vg.effective_to is null or vg.effective_to > now())
  ), false)
$$;

create or replace function consulting_security.can_read_visibility(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_visibility consulting_os.visibility_scope,
  p_owner_person_id uuid,
  p_domain_object_id uuid
)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_person_id uuid := consulting_security.current_person_id();
begin
  if p_visibility = 'PLATFORM_RESTRICTED' then
    return consulting_security.is_platform_admin();
  end if;

  if v_person_id is null or not consulting_security.can_access_organization(p_organization_id) then
    return false;
  end if;

  return case p_visibility
    when 'CONSULTANT_PRIVATE' then
      consulting_security.has_active_consultant_assignment(p_organization_id)
      and (p_owner_person_id = v_person_id or consulting_security.has_visibility_grant(p_organization_id, p_domain_object_id))
    when 'INDIVIDUAL_PRIVATE' then
      p_owner_person_id = v_person_id
      or consulting_security.has_visibility_grant(p_organization_id, p_domain_object_id)
    when 'COACHING_SHARED' then
      consulting_security.has_visibility_grant(p_organization_id, p_domain_object_id)
    when 'TEAM_SHARED' then
      consulting_security.has_visibility_grant(p_organization_id, p_domain_object_id)
    when 'LEADERSHIP_RESTRICTED' then
      consulting_security.has_active_consultant_assignment(p_organization_id)
      or consulting_security.has_active_org_role(
        p_organization_id,
        array['CLIENT_ADMIN', 'CLIENT_LEADER']::consulting_os.platform_role[]
      )
      or consulting_security.has_visibility_grant(p_organization_id, p_domain_object_id)
    when 'ENGAGEMENT_SHARED' then
      consulting_security.has_engagement_access(p_organization_id, p_engagement_id)
    when 'ORGANIZATION_SHARED' then
      consulting_security.can_access_organization(p_organization_id)
    when 'PLATFORM_RESTRICTED' then false
    else false
  end;
end
$$;

create or replace function consulting_security.can_create_visibility(
  p_organization_id uuid,
  p_engagement_id uuid,
  p_visibility consulting_os.visibility_scope,
  p_owner_person_id uuid
)
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select case p_visibility
    when 'CONSULTANT_PRIVATE' then consulting_security.has_active_consultant_assignment(p_organization_id)
    when 'INDIVIDUAL_PRIVATE' then p_owner_person_id = consulting_security.current_person_id()
    when 'COACHING_SHARED' then consulting_security.can_manage_organization(p_organization_id)
    when 'TEAM_SHARED' then consulting_security.can_manage_organization(p_organization_id)
    when 'LEADERSHIP_RESTRICTED' then consulting_security.can_manage_organization(p_organization_id)
    when 'ENGAGEMENT_SHARED' then consulting_security.has_engagement_access(p_organization_id, p_engagement_id)
    when 'ORGANIZATION_SHARED' then consulting_security.can_manage_organization(p_organization_id)
    when 'PLATFORM_RESTRICTED' then consulting_security.is_platform_admin()
    else false
  end
$$;

create or replace function consulting_security.can_read_domain_object(
  p_domain_object_id uuid,
  p_organization_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(exists (
    select 1
    from consulting_os.domain_objects d
    where d.id = p_domain_object_id
      and d.organization_id = p_organization_id
      and d.archived_at is null
      and consulting_security.can_read_visibility(
        d.organization_id,
        d.engagement_id,
        d.visibility_scope,
        d.owner_person_id,
        d.id
      )
  ), false)
$$;

create or replace function consulting_security.can_manage_domain_object(
  p_domain_object_id uuid,
  p_organization_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(exists (
    select 1
    from consulting_os.domain_objects d
    where d.id = p_domain_object_id
      and d.organization_id = p_organization_id
      and (
        d.created_by = consulting_security.current_person_id()
        or consulting_security.has_visibility_grant(
          p_organization_id,
          p_domain_object_id,
          array['MANAGE']::consulting_os.grant_permission[]
        )
        or (
          d.visibility_scope not in ('CONSULTANT_PRIVATE', 'INDIVIDUAL_PRIVATE', 'COACHING_SHARED')
          and consulting_security.can_manage_organization(p_organization_id)
        )
      )
  ), false)
$$;

create or replace function consulting_security.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end
$$;

create or replace function consulting_security.validate_relationship_endpoints()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_source_type text;
  v_target_type text;
begin
  select d.object_type into v_source_type
  from consulting_os.domain_objects d
  where d.id = new.source_id and d.organization_id = new.organization_id;

  select d.object_type into v_target_type
  from consulting_os.domain_objects d
  where d.id = new.target_id and d.organization_id = new.organization_id;

  if v_source_type is null or v_target_type is null then
    raise exception 'relationship endpoints must exist in the same organization' using errcode = '23503';
  end if;
  if v_source_type <> new.source_type or v_target_type <> new.target_type then
    raise exception 'relationship endpoint types do not match registered object types' using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.audit_row_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row jsonb := case when tg_op = 'DELETE' then to_jsonb(old) else to_jsonb(new) end;
  v_organization_id uuid;
  v_target_id uuid;
begin
  v_organization_id := nullif(v_row ->> 'organization_id', '')::uuid;
  v_target_id := nullif(v_row ->> 'id', '')::uuid;

  insert into consulting_os.audit_events (
    organization_id,
    actor_auth_user_id,
    actor_person_id,
    event_type,
    target_table,
    target_id,
    operation,
    metadata
  ) values (
    v_organization_id,
    auth.uid(),
    consulting_security.current_person_id(),
    upper(tg_table_name || '_' || tg_op),
    tg_table_schema || '.' || tg_table_name,
    v_target_id,
    tg_op,
    jsonb_build_object('visibility_scope', v_row ->> 'visibility_scope', 'status', v_row ->> 'status')
  );

  return case when tg_op = 'DELETE' then old else new end;
end
$$;

create or replace function consulting_security.prevent_audit_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  raise exception 'audit_events are append-only' using errcode = '55000';
end
$$;

create or replace function consulting_security.record_privileged_operation(
  p_organization_id uuid,
  p_operation text,
  p_target_table text,
  p_target_id uuid,
  p_reason text,
  p_correlation_id text,
  p_metadata jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
begin
  if coalesce(current_setting('request.jwt.claim.role', true), '') <> 'service_role' then
    raise exception 'service role context required' using errcode = '42501';
  end if;
  if p_organization_id is null or not exists (
    select 1 from consulting_os.organizations o where o.id = p_organization_id
  ) then
    raise exception 'verified organization context required' using errcode = '22023';
  end if;
  if nullif(btrim(p_reason), '') is null or nullif(btrim(p_correlation_id), '') is null then
    raise exception 'reason and correlation_id are required' using errcode = '22023';
  end if;
  if nullif(btrim(p_operation), '') is null then
    raise exception 'operation is required' using errcode = '22023';
  end if;

  insert into consulting_os.audit_events (
    organization_id,
    actor_auth_user_id,
    actor_person_id,
    event_type,
    target_table,
    target_id,
    operation,
    reason,
    correlation_id,
    metadata
  ) values (
    p_organization_id,
    auth.uid(),
    consulting_security.current_person_id(),
    'PRIVILEGED_OPERATION',
    p_target_table,
    p_target_id,
    'PRIVILEGED_ACCESS',
    p_reason,
    p_correlation_id,
    jsonb_build_object('requested_operation', p_operation) || coalesce(p_metadata, '{}'::jsonb)
  ) returning id into v_id;

  return v_id;
end
$$;

revoke all on all functions in schema consulting_security from public, anon, authenticated;
grant execute on function consulting_security.current_person_id() to authenticated, service_role;
grant execute on function consulting_security.is_platform_admin() to authenticated, service_role;
grant execute on function consulting_security.has_active_org_role(uuid, consulting_os.platform_role[]) to authenticated, service_role;
grant execute on function consulting_security.has_active_consultant_assignment(uuid) to authenticated, service_role;
grant execute on function consulting_security.can_access_organization(uuid) to authenticated, service_role;
grant execute on function consulting_security.can_manage_organization(uuid) to authenticated, service_role;
grant execute on function consulting_security.has_engagement_access(uuid, uuid) to authenticated, service_role;
grant execute on function consulting_security.has_visibility_grant(uuid, uuid, consulting_os.grant_permission[]) to authenticated, service_role;
grant execute on function consulting_security.can_read_visibility(uuid, uuid, consulting_os.visibility_scope, uuid, uuid) to authenticated, service_role;
grant execute on function consulting_security.can_create_visibility(uuid, uuid, consulting_os.visibility_scope, uuid) to authenticated, service_role;
grant execute on function consulting_security.can_read_domain_object(uuid, uuid) to authenticated, service_role;
grant execute on function consulting_security.can_manage_domain_object(uuid, uuid) to authenticated, service_role;
grant execute on function consulting_security.record_privileged_operation(uuid, text, text, uuid, text, text, jsonb) to service_role;

create trigger people_updated_at before update on consulting_os.people
for each row execute function consulting_security.set_updated_at();
create trigger organizations_updated_at before update on consulting_os.organizations
for each row execute function consulting_security.set_updated_at();
create trigger organization_memberships_updated_at before update on consulting_os.organization_memberships
for each row execute function consulting_security.set_updated_at();
create trigger consultant_assignments_updated_at before update on consulting_os.consultant_assignments
for each row execute function consulting_security.set_updated_at();
create trigger engagements_updated_at before update on consulting_os.engagements
for each row execute function consulting_security.set_updated_at();
create trigger engagement_memberships_updated_at before update on consulting_os.engagement_memberships
for each row execute function consulting_security.set_updated_at();
create trigger domain_objects_updated_at before update on consulting_os.domain_objects
for each row execute function consulting_security.set_updated_at();
create trigger entity_relationships_validate
before insert or update on consulting_os.entity_relationships
for each row execute function consulting_security.validate_relationship_endpoints();

create trigger organization_memberships_audit
after insert or update or delete on consulting_os.organization_memberships
for each row execute function consulting_security.audit_row_change();
create trigger consultant_assignments_audit
after insert or update or delete on consulting_os.consultant_assignments
for each row execute function consulting_security.audit_row_change();
create trigger visibility_grants_audit
after insert or update or delete on consulting_os.visibility_grants
for each row execute function consulting_security.audit_row_change();
create trigger file_objects_audit
after insert or update or delete on consulting_os.file_objects
for each row execute function consulting_security.audit_row_change();
create trigger private_records_audit
after insert or update or delete on consulting_private.private_records
for each row execute function consulting_security.audit_row_change();
create trigger audit_events_immutable
before update or delete on consulting_os.audit_events
for each row execute function consulting_security.prevent_audit_mutation();

alter table consulting_os.people enable row level security;
alter table consulting_os.organizations enable row level security;
alter table consulting_os.organization_memberships enable row level security;
alter table consulting_os.consultant_assignments enable row level security;
alter table consulting_security.platform_admin_assignments enable row level security;
alter table consulting_os.engagements enable row level security;
alter table consulting_os.engagement_memberships enable row level security;
alter table consulting_os.domain_objects enable row level security;
alter table consulting_os.visibility_grants enable row level security;
alter table consulting_os.entity_relationships enable row level security;
alter table consulting_os.file_objects enable row level security;
alter table consulting_private.private_records enable row level security;
alter table consulting_os.audit_events enable row level security;

create policy people_select_self on consulting_os.people for select to authenticated
using (auth_user_id = (select auth.uid()) or consulting_security.is_platform_admin());
create policy people_update_self on consulting_os.people for update to authenticated
using (auth_user_id = (select auth.uid()))
with check (auth_user_id = (select auth.uid()));

create policy organizations_select_authorized on consulting_os.organizations for select to authenticated
using (consulting_security.can_access_organization(id) or consulting_security.is_platform_admin());
create policy organizations_update_managers on consulting_os.organizations for update to authenticated
using (consulting_security.can_manage_organization(id))
with check (consulting_security.can_manage_organization(id));

create policy memberships_select_authorized on consulting_os.organization_memberships for select to authenticated
using (
  person_id = consulting_security.current_person_id()
  or consulting_security.can_manage_organization(organization_id)
);
create policy memberships_insert_managers on consulting_os.organization_memberships for insert to authenticated
with check (
  consulting_security.can_manage_organization(organization_id)
  and platform_role <> 'PLATFORM_ADMIN'
);
create policy memberships_update_managers on consulting_os.organization_memberships for update to authenticated
using (consulting_security.can_manage_organization(organization_id))
with check (
  consulting_security.can_manage_organization(organization_id)
  and platform_role <> 'PLATFORM_ADMIN'
);

create policy consultant_assignments_select_self on consulting_os.consultant_assignments for select to authenticated
using (
  consultant_person_id = consulting_security.current_person_id()
  or consulting_security.is_platform_admin()
);

create policy engagements_select_authorized on consulting_os.engagements for select to authenticated
using (consulting_security.has_engagement_access(organization_id, id));
create policy engagements_insert_managers on consulting_os.engagements for insert to authenticated
with check (consulting_security.can_manage_organization(organization_id));
create policy engagements_update_managers on consulting_os.engagements for update to authenticated
using (consulting_security.can_manage_organization(organization_id))
with check (consulting_security.can_manage_organization(organization_id));

create policy engagement_memberships_select_authorized on consulting_os.engagement_memberships for select to authenticated
using (consulting_security.has_engagement_access(organization_id, engagement_id));
create policy engagement_memberships_insert_managers on consulting_os.engagement_memberships for insert to authenticated
with check (consulting_security.can_manage_organization(organization_id));
create policy engagement_memberships_update_managers on consulting_os.engagement_memberships for update to authenticated
using (consulting_security.can_manage_organization(organization_id))
with check (consulting_security.can_manage_organization(organization_id));

create policy domain_objects_select_visible on consulting_os.domain_objects for select to authenticated
using (
  archived_at is null
  and consulting_security.can_read_visibility(
    organization_id,
    engagement_id,
    visibility_scope,
    owner_person_id,
    id
  )
);
create policy domain_objects_insert_authorized on consulting_os.domain_objects for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_create_visibility(
    organization_id,
    engagement_id,
    visibility_scope,
    owner_person_id
  )
);
create policy domain_objects_update_authorized on consulting_os.domain_objects for update to authenticated
using (consulting_security.can_manage_domain_object(id, organization_id))
with check (
  consulting_security.can_manage_domain_object(id, organization_id)
  and consulting_security.can_create_visibility(
    organization_id,
    engagement_id,
    visibility_scope,
    owner_person_id
  )
);

create policy visibility_grants_select_resource on consulting_os.visibility_grants for select to authenticated
using (consulting_security.can_read_domain_object(domain_object_id, organization_id));
create policy visibility_grants_insert_manager on consulting_os.visibility_grants for insert to authenticated
with check (consulting_security.can_manage_domain_object(domain_object_id, organization_id));
create policy visibility_grants_update_manager on consulting_os.visibility_grants for update to authenticated
using (consulting_security.can_manage_domain_object(domain_object_id, organization_id))
with check (consulting_security.can_manage_domain_object(domain_object_id, organization_id));
create policy visibility_grants_delete_manager on consulting_os.visibility_grants for delete to authenticated
using (consulting_security.can_manage_domain_object(domain_object_id, organization_id));

create policy relationships_select_visible on consulting_os.entity_relationships for select to authenticated
using (
  consulting_security.can_read_domain_object(source_id, organization_id)
  and consulting_security.can_read_domain_object(target_id, organization_id)
);
create policy relationships_insert_authorized on consulting_os.entity_relationships for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_organization(organization_id)
  and consulting_security.can_read_domain_object(source_id, organization_id)
  and consulting_security.can_read_domain_object(target_id, organization_id)
);
create policy relationships_update_authorized on consulting_os.entity_relationships for update to authenticated
using (consulting_security.can_manage_organization(organization_id))
with check (
  consulting_security.can_manage_organization(organization_id)
  and consulting_security.can_read_domain_object(source_id, organization_id)
  and consulting_security.can_read_domain_object(target_id, organization_id)
);

create policy file_objects_select_visible on consulting_os.file_objects for select to authenticated
using (consulting_security.can_read_domain_object(id, organization_id));
create policy file_objects_insert_authorized on consulting_os.file_objects for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(id, organization_id)
);
create policy file_objects_update_authorized on consulting_os.file_objects for update to authenticated
using (consulting_security.can_manage_domain_object(id, organization_id))
with check (consulting_security.can_manage_domain_object(id, organization_id));
create policy file_objects_delete_authorized on consulting_os.file_objects for delete to authenticated
using (consulting_security.can_manage_domain_object(id, organization_id));

revoke all on all tables in schema consulting_os from public, anon, authenticated;
revoke all on all tables in schema consulting_private from public, anon, authenticated;
revoke all on all tables in schema consulting_security from public, anon, authenticated;

grant select, update on consulting_os.people to authenticated;
grant select, update on consulting_os.organizations to authenticated;
grant select, insert, update, delete on consulting_os.organization_memberships to authenticated;
grant select on consulting_os.consultant_assignments to authenticated;
grant select, insert, update, delete on consulting_os.engagements to authenticated;
grant select, insert, update, delete on consulting_os.engagement_memberships to authenticated;
grant select, insert, update, delete on consulting_os.domain_objects to authenticated;
grant select, insert, update, delete on consulting_os.visibility_grants to authenticated;
grant select, insert, update, delete on consulting_os.entity_relationships to authenticated;
grant select, insert, update, delete on consulting_os.file_objects to authenticated;

grant all on all tables in schema consulting_os to service_role;
grant all on all tables in schema consulting_private to service_role;
grant all on all tables in schema consulting_security to service_role;

alter default privileges in schema consulting_os revoke all on tables from public, anon, authenticated;
alter default privileges in schema consulting_private revoke all on tables from public, anon, authenticated;
alter default privileges in schema consulting_security revoke all on tables from public, anon, authenticated;
alter default privileges in schema consulting_os revoke execute on functions from public, anon, authenticated;
alter default privileges in schema consulting_private revoke execute on functions from public, anon, authenticated;
alter default privileges in schema consulting_security revoke execute on functions from public, anon, authenticated;

create or replace view consulting_os.authorized_domain_objects
with (security_invoker = true)
as
select
  id,
  organization_id,
  engagement_id,
  object_type,
  visibility_scope,
  owner_person_id,
  origin,
  created_at,
  updated_at
from consulting_os.domain_objects
where archived_at is null;

grant select on consulting_os.authorized_domain_objects to authenticated, service_role;

create or replace function consulting_os.authorized_source_ids(
  p_organization_id uuid,
  p_purpose text
)
returns table (domain_object_id uuid)
language sql
stable
security invoker
set search_path = ''
as $$
  select d.id
  from consulting_os.domain_objects d
  where d.organization_id = p_organization_id
    and d.archived_at is null
    and nullif(btrim(p_purpose), '') is not null
$$;

revoke all on function consulting_os.authorized_source_ids(uuid, text) from public, anon;
grant execute on function consulting_os.authorized_source_ids(uuid, text) to authenticated, service_role;

insert into storage.buckets (id, name, public, file_size_limit)
values ('consulting-private', 'consulting-private', false, 52428800)
on conflict (id) do update
set public = false,
    file_size_limit = excluded.file_size_limit;

drop policy if exists consulting_files_select on storage.objects;
drop policy if exists consulting_files_insert on storage.objects;
drop policy if exists consulting_files_update on storage.objects;
drop policy if exists consulting_files_delete on storage.objects;

create policy consulting_files_select on storage.objects for select to authenticated
using (
  bucket_id = 'consulting-private'
  and exists (
    select 1
    from consulting_os.file_objects f
    where f.bucket_id = storage.objects.bucket_id
      and f.object_path = storage.objects.name
      and consulting_security.can_read_domain_object(f.id, f.organization_id)
  )
);

create policy consulting_files_insert on storage.objects for insert to authenticated
with check (
  bucket_id = 'consulting-private'
  and exists (
    select 1
    from consulting_os.file_objects f
    where f.bucket_id = storage.objects.bucket_id
      and f.object_path = storage.objects.name
      and consulting_security.can_manage_domain_object(f.id, f.organization_id)
  )
);

create policy consulting_files_update on storage.objects for update to authenticated
using (
  bucket_id = 'consulting-private'
  and exists (
    select 1
    from consulting_os.file_objects f
    where f.bucket_id = storage.objects.bucket_id
      and f.object_path = storage.objects.name
      and consulting_security.can_manage_domain_object(f.id, f.organization_id)
  )
)
with check (
  bucket_id = 'consulting-private'
  and exists (
    select 1
    from consulting_os.file_objects f
    where f.bucket_id = storage.objects.bucket_id
      and f.object_path = storage.objects.name
      and consulting_security.can_manage_domain_object(f.id, f.organization_id)
  )
);

create policy consulting_files_delete on storage.objects for delete to authenticated
using (
  bucket_id = 'consulting-private'
  and exists (
    select 1
    from consulting_os.file_objects f
    where f.bucket_id = storage.objects.bucket_id
      and f.object_path = storage.objects.name
      and consulting_security.can_manage_domain_object(f.id, f.organization_id)
  )
);
