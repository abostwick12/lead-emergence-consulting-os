-- Phase 6: Alignment + Capability. Private Consulting OS only.

create type consulting_os.design_record_status as enum ('DRAFT','PROPOSED','APPROVED','ACTIVE','SUPERSEDED','RETIRED');
create type consulting_os.assignment_status as enum ('PLANNED','ACTIVE','ENDED');
create type consulting_os.capability_level as enum ('NOT_DEMONSTRATED','FOUNDATIONAL','DEVELOPING','RELIABLE','TRANSFERABLE');
create type consulting_os.gap_priority as enum ('LOW','MEDIUM','HIGH','CRITICAL');
create type consulting_os.development_status as enum ('DRAFT','ACTIVE','PAUSED','COMPLETED','CANCELLED');
create type consulting_os.development_activity_type as enum ('LEARNING','PRACTICE','COACHING','EXPERIENCE','RESOURCE');

create table consulting_os.roles (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('ROLE'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  name text not null check (length(btrim(name)) > 0),
  purpose text not null check (length(btrim(purpose)) > 0),
  support text not null check (length(btrim(support)) > 0),
  accountability text not null check (length(btrim(accountability)) > 0),
  success_measures text not null check (length(btrim(success_measures)) > 0),
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.role_assignments (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('ROLE_ASSIGNMENT'::text) stored,
  role_id uuid not null,
  organization_membership_id uuid not null,
  starts_on date not null,
  ends_on date,
  status consulting_os.assignment_status not null default 'PLANNED',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  foreign key (organization_membership_id, organization_id) references consulting_os.organization_memberships(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (ends_on is null or ends_on >= starts_on)
);

create table consulting_os.design_principles (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('DESIGN_PRINCIPLE'::text) stored,
  logical_id uuid not null, version_number integer not null check (version_number > 0),
  statement text not null check (length(btrim(statement)) > 0),
  rationale text not null check (length(btrim(rationale)) > 0),
  source_future_state_principle_id uuid,
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null, effective_to timestamptz, supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (source_future_state_principle_id, organization_id) references consulting_os.future_state_principles(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.design_principles(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from), check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.responsibilities (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('RESPONSIBILITY'::text) stored,
  logical_id uuid not null, version_number integer not null check (version_number > 0),
  role_id uuid not null, statement text not null check (length(btrim(statement)) > 0),
  outcome_definition text not null check (length(btrim(outcome_definition)) > 0),
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null, effective_to timestamptz, supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.responsibilities(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from), check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.authorities (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('AUTHORITY'::text) stored,
  logical_id uuid not null, version_number integer not null check (version_number > 0),
  role_id uuid not null, decision_domain text not null check (length(btrim(decision_domain)) > 0),
  authority_limit text not null check (length(btrim(authority_limit)) > 0),
  escalation_condition text not null check (length(btrim(escalation_condition)) > 0),
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null, effective_to timestamptz, supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.authorities(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from), check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.boundaries (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('BOUNDARY'::text) stored,
  logical_id uuid not null, version_number integer not null check (version_number > 0),
  role_id uuid not null, inside_scope text not null check (length(btrim(inside_scope)) > 0),
  outside_scope text not null check (length(btrim(outside_scope)) > 0),
  constraints text not null check (length(btrim(constraints)) > 0),
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null, effective_to timestamptz, supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.boundaries(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from), check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.interfaces (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('INTERFACE'::text) stored,
  logical_id uuid not null, version_number integer not null check (version_number > 0),
  source_role_id uuid not null, target_role_id uuid not null,
  purpose text not null check (length(btrim(purpose)) > 0),
  inputs text not null check (length(btrim(inputs)) > 0), outputs text not null check (length(btrim(outputs)) > 0),
  operating_rules text not null check (length(btrim(operating_rules)) > 0), cadence text not null check (length(btrim(cadence)) > 0),
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null, effective_to timestamptz, supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (source_role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  foreign key (target_role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.interfaces(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (organization_id, logical_id, version_number),
  check (source_role_id <> target_role_id), check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

-- A workflow is a stable container. WORKFLOW domain objects are the immutable
-- versions below, preserving both the approved mapping and historical meaning.
create table consulting_os.workflows (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  canonical_name text not null check (length(btrim(canonical_name)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (id, organization_id)
);

create table consulting_os.workflow_versions (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('WORKFLOW'::text) stored,
  logical_id uuid not null, version_number integer not null check (version_number > 0),
  name text not null check (length(btrim(name)) > 0), purpose text not null check (length(btrim(purpose)) > 0),
  owner_role_id uuid not null, entry_condition text not null check (length(btrim(entry_condition)) > 0),
  completion_condition text not null check (length(btrim(completion_condition)) > 0),
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null, effective_to timestamptz, supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (logical_id, organization_id) references consulting_os.workflows(id, organization_id) on delete restrict,
  foreign key (owner_role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.workflow_versions(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from), check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.workflow_steps (
  id uuid primary key default gen_random_uuid(), organization_id uuid not null,
  workflow_version_id uuid not null, sequence_number integer not null check (sequence_number > 0),
  name text not null check (length(btrim(name)) > 0),
  description text not null check (length(btrim(description)) > 0),
  owner_role_id uuid not null, decision_point boolean not null default false,
  handoff_to_role_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (workflow_version_id, organization_id) references consulting_os.workflow_versions(id, organization_id) on delete restrict,
  foreign key (owner_role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  foreign key (handoff_to_role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  unique (workflow_version_id, sequence_number), unique (id, organization_id)
);

create table consulting_os.reinvention_initiatives (
  id uuid primary key, organization_id uuid not null, engagement_id uuid not null,
  object_type text generated always as ('REINVENTION_INITIATIVE'::text) stored,
  name text not null check (length(btrim(name)) > 0),
  current_condition text not null check (length(btrim(current_condition)) > 0),
  intended_condition text not null check (length(btrim(intended_condition)) > 0),
  barrier text not null check (length(btrim(barrier)) > 0),
  change_approach text not null check (length(btrim(change_approach)) > 0),
  owner_person_id uuid not null references consulting_os.people(id) on delete restrict,
  dependencies text not null check (length(btrim(dependencies)) > 0),
  success_evidence text not null check (length(btrim(success_evidence)) > 0),
  authorizing_decision_id uuid not null,
  status consulting_os.design_record_status not null default 'PROPOSED', starts_on date, target_date date,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (authorizing_decision_id, organization_id) references consulting_os.decisions(id, organization_id) on delete restrict,
  unique (id, organization_id), check (target_date is null or starts_on is null or target_date >= starts_on)
);

create table consulting_os.capabilities (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('CAPABILITY'::text) stored,
  logical_id uuid not null, version_number integer not null check (version_number > 0),
  name text not null check (length(btrim(name)) > 0),
  definition text not null check (length(btrim(definition)) > 0),
  performance_conditions text not null check (length(btrim(performance_conditions)) > 0),
  reliability_definition text not null check (length(btrim(reliability_definition)) > 0),
  transfer_definition text not null check (length(btrim(transfer_definition)) > 0),
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null, effective_to timestamptz, supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.capabilities(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from), check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.capability_requirements (
  id uuid primary key, organization_id uuid not null, engagement_id uuid not null,
  object_type text generated always as ('CAPABILITY_REQUIREMENT'::text) stored,
  capability_id uuid not null, source_domain_object_id uuid not null,
  source_type text not null check (source_type in ('FUTURE_STATE','ROLE','REINVENTION_INITIATIVE','WORKFLOW')),
  target_subject_id uuid not null,
  required_level consulting_os.capability_level not null,
  rationale text not null check (length(btrim(rationale)) > 0),
  due_on date, status consulting_os.design_record_status not null default 'PROPOSED',
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (capability_id, organization_id) references consulting_os.capabilities(id, organization_id) on delete restrict,
  foreign key (source_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (target_subject_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.capability_assessments (
  id uuid primary key, organization_id uuid not null, engagement_id uuid not null,
  object_type text generated always as ('CAPABILITY_ASSESSMENT'::text) stored,
  capability_id uuid not null, subject_domain_object_id uuid not null,
  assessed_level consulting_os.capability_level not null,
  evidence_summary text not null check (length(btrim(evidence_summary)) > 0),
  limitations text not null check (length(btrim(limitations)) > 0),
  assessed_by uuid not null references consulting_os.people(id) on delete restrict,
  assessed_at timestamptz not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (capability_id, organization_id) references consulting_os.capabilities(id, organization_id) on delete restrict,
  foreign key (subject_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.capability_assessment_evidence (
  organization_id uuid not null, assessment_id uuid not null, evidence_id uuid not null,
  relevance text not null check (length(btrim(relevance)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  primary key (assessment_id, evidence_id),
  foreign key (assessment_id, organization_id) references consulting_os.capability_assessments(id, organization_id) on delete restrict,
  foreign key (evidence_id, organization_id) references consulting_os.evidence_items(id, organization_id) on delete restrict
);

create table consulting_os.capability_gaps (
  id uuid primary key, organization_id uuid not null, engagement_id uuid not null,
  object_type text generated always as ('CAPABILITY_GAP'::text) stored,
  requirement_id uuid not null, assessment_id uuid not null,
  required_level consulting_os.capability_level not null, current_level consulting_os.capability_level not null,
  gap_statement text not null check (length(btrim(gap_statement)) > 0),
  priority consulting_os.gap_priority not null, review_status consulting_os.review_status not null default 'SUGGESTED',
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (requirement_id, organization_id) references consulting_os.capability_requirements(id, organization_id) on delete restrict,
  foreign key (assessment_id, organization_id) references consulting_os.capability_assessments(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.organizational_systems (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('SYSTEM'::text) stored,
  logical_id uuid not null, version_number integer not null check (version_number > 0),
  name text not null check (length(btrim(name)) > 0),
  purpose text not null check (length(btrim(purpose)) > 0),
  operating_owner_role_id uuid not null,
  constraints text not null check (length(btrim(constraints)) > 0),
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null, effective_to timestamptz, supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (operating_owner_role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.organizational_systems(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.metric_definitions (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('METRIC_DEFINITION'::text) stored,
  logical_id uuid not null, version_number integer not null check (version_number > 0),
  name text not null check (length(btrim(name)) > 0),
  definition text not null check (length(btrim(definition)) > 0),
  calculation text not null check (length(btrim(calculation)) > 0),
  cadence text not null check (length(btrim(cadence)) > 0),
  accountable_role_id uuid not null,
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null, effective_to timestamptz, supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (accountable_role_id, organization_id) references consulting_os.roles(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.metric_definitions(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.alignment_conflicts (
  id uuid primary key, organization_id uuid not null, engagement_id uuid not null,
  object_type text generated always as ('ALIGNMENT_CONFLICT'::text) stored,
  first_domain_object_id uuid not null, second_domain_object_id uuid not null,
  conflict_statement text not null check (length(btrim(conflict_statement)) > 0),
  implications text not null check (length(btrim(implications)) > 0),
  review_status consulting_os.review_status not null default 'SUGGESTED',
  resolution_decision_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (first_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (second_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (resolution_decision_id, organization_id) references consulting_os.decisions(id, organization_id) on delete restrict,
  unique (id, organization_id), check (first_domain_object_id <> second_domain_object_id)
);

create table consulting_os.development_plans (
  id uuid primary key, organization_id uuid not null, engagement_id uuid not null,
  object_type text generated always as ('DEVELOPMENT_PLAN'::text) stored,
  capability_gap_id uuid not null, subject_domain_object_id uuid not null,
  title text not null check (length(btrim(title)) > 0),
  intended_progress text not null check (length(btrim(intended_progress)) > 0),
  review_cadence text not null check (length(btrim(review_cadence)) > 0),
  starts_on date not null, target_date date,
  status consulting_os.development_status not null default 'DRAFT',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (capability_gap_id, organization_id) references consulting_os.capability_gaps(id, organization_id) on delete restrict,
  foreign key (subject_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  unique (id, organization_id), check (target_date is null or target_date >= starts_on)
);

create table consulting_os.development_activities (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('DEVELOPMENT_ACTIVITY'::text) stored,
  development_plan_id uuid not null,
  activity_type consulting_os.development_activity_type not null,
  title text not null check (length(btrim(title)) > 0),
  expected_learning text not null check (length(btrim(expected_learning)) > 0),
  due_on date, completed_at timestamptz,
  status consulting_os.development_status not null default 'DRAFT',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (development_plan_id, organization_id) references consulting_os.development_plans(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check ((status = 'COMPLETED' and completed_at is not null) or (status <> 'COMPLETED' and completed_at is null))
);

create table consulting_os.practices (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('PRACTICE'::text) stored,
  development_plan_id uuid not null, capability_id uuid not null,
  name text not null check (length(btrim(name)) > 0),
  conditions text not null check (length(btrim(conditions)) > 0),
  repetition_target text not null check (length(btrim(repetition_target)) > 0),
  feedback_method text not null check (length(btrim(feedback_method)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (development_plan_id, organization_id) references consulting_os.development_plans(id, organization_id) on delete restrict,
  foreign key (capability_id, organization_id) references consulting_os.capabilities(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.resources (
  id uuid primary key, organization_id uuid not null,
  object_type text generated always as ('RESOURCE'::text) stored,
  development_plan_id uuid not null,
  title text not null check (length(btrim(title)) > 0),
  resource_kind text not null check (length(btrim(resource_kind)) > 0),
  locator text not null check (length(btrim(locator)) > 0),
  use_guidance text not null check (length(btrim(use_guidance)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (development_plan_id, organization_id) references consulting_os.development_plans(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.capability_maturity_assessments (
  id uuid primary key, organization_id uuid not null, engagement_id uuid not null,
  object_type text generated always as ('READINESS_MATURITY'::text) stored,
  capability_id uuid not null, subject_domain_object_id uuid not null,
  prior_assessment_id uuid,
  achieved_level consulting_os.capability_level not null,
  evidence_summary text not null check (length(btrim(evidence_summary)) > 0),
  transfer_test text not null check (length(btrim(transfer_test)) > 0),
  limitations text not null check (length(btrim(limitations)) > 0),
  assessed_by uuid not null references consulting_os.people(id) on delete restrict,
  assessed_at timestamptz not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (capability_id, organization_id) references consulting_os.capabilities(id, organization_id) on delete restrict,
  foreign key (subject_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (prior_assessment_id, organization_id) references consulting_os.capability_assessments(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.capability_maturity_evidence (
  organization_id uuid not null,
  maturity_assessment_id uuid not null,
  evidence_domain_object_id uuid not null,
  relevance text not null check (length(btrim(relevance)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (maturity_assessment_id, evidence_domain_object_id),
  foreign key (maturity_assessment_id, organization_id) references consulting_os.capability_maturity_assessments(id, organization_id) on delete restrict,
  foreign key (evidence_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict
);

create index roles_current_idx on consulting_os.roles(organization_id, logical_id, version_number desc);
create index role_assignments_member_idx on consulting_os.role_assignments(organization_id, organization_membership_id, status);
create index responsibilities_role_idx on consulting_os.responsibilities(organization_id, role_id);
create index authorities_role_idx on consulting_os.authorities(organization_id, role_id);
create index boundaries_role_idx on consulting_os.boundaries(organization_id, role_id);
create index interfaces_roles_idx on consulting_os.interfaces(organization_id, source_role_id, target_role_id);
create index workflow_versions_current_idx on consulting_os.workflow_versions(organization_id, logical_id, version_number desc);
create index workflow_steps_version_idx on consulting_os.workflow_steps(organization_id, workflow_version_id, sequence_number);
create index capability_requirements_source_idx on consulting_os.capability_requirements(organization_id, source_domain_object_id, target_subject_id);
create index capability_assessments_subject_idx on consulting_os.capability_assessments(organization_id, subject_domain_object_id, capability_id, assessed_at desc);
create index capability_gaps_subject_idx on consulting_os.capability_gaps(organization_id, requirement_id, assessment_id);
create index development_plans_subject_idx on consulting_os.development_plans(organization_id, subject_domain_object_id, status);
create index maturity_assessments_subject_idx on consulting_os.capability_maturity_assessments(organization_id, subject_domain_object_id, capability_id, assessed_at desc);

create or replace function consulting_security.validate_phase6_typed_record()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_type text;
  v_creator uuid;
  v_origin consulting_os.record_origin;
  v_expected text;
begin
  v_expected := case tg_table_name
    when 'roles' then 'ROLE'
    when 'role_assignments' then 'ROLE_ASSIGNMENT'
    when 'design_principles' then 'DESIGN_PRINCIPLE'
    when 'responsibilities' then 'RESPONSIBILITY'
    when 'authorities' then 'AUTHORITY'
    when 'boundaries' then 'BOUNDARY'
    when 'interfaces' then 'INTERFACE'
    when 'workflow_versions' then 'WORKFLOW'
    when 'reinvention_initiatives' then 'REINVENTION_INITIATIVE'
    when 'capabilities' then 'CAPABILITY'
    when 'capability_requirements' then 'CAPABILITY_REQUIREMENT'
    when 'capability_assessments' then 'CAPABILITY_ASSESSMENT'
    when 'capability_gaps' then 'CAPABILITY_GAP'
    when 'organizational_systems' then 'SYSTEM'
    when 'metric_definitions' then 'METRIC_DEFINITION'
    when 'alignment_conflicts' then 'ALIGNMENT_CONFLICT'
    when 'development_plans' then 'DEVELOPMENT_PLAN'
    when 'development_activities' then 'DEVELOPMENT_ACTIVITY'
    when 'practices' then 'PRACTICE'
    when 'resources' then 'RESOURCE'
    when 'capability_maturity_assessments' then 'READINESS_MATURITY'
  end;

  select object_type, created_by, origin into v_type, v_creator, v_origin
  from consulting_os.domain_objects
  where id = new.id and organization_id = new.organization_id;

  if v_type is distinct from v_expected or v_creator is distinct from new.created_by then
    raise exception '% requires a matching % domain registry record and creator', tg_table_name, v_expected
      using errcode = '23514';
  end if;
  if tg_table_name = 'alignment_conflicts'
    and v_origin = 'AI'
    and (to_jsonb(new)->>'review_status') <> 'SUGGESTED'
  then
    raise exception 'AI alignment conflicts must begin SUGGESTED' using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_role_architecture()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_role_id uuid;
  v_org uuid;
  v_status consulting_os.design_record_status;
begin
  v_role_id := case tg_table_name
    when 'roles' then new.id
    when 'interfaces' then new.source_role_id
    else new.role_id
  end;
  v_org := new.organization_id;
  select status into v_status from consulting_os.roles where id = v_role_id and organization_id = v_org;
  if v_status in ('APPROVED','ACTIVE') and (
    not exists (select 1 from consulting_os.responsibilities where role_id = v_role_id and organization_id = v_org)
    or not exists (select 1 from consulting_os.authorities where role_id = v_role_id and organization_id = v_org)
    or not exists (select 1 from consulting_os.boundaries where role_id = v_role_id and organization_id = v_org)
    or not exists (select 1 from consulting_os.interfaces where source_role_id = v_role_id and organization_id = v_org)
  ) then
    raise exception 'approved or active role requires responsibility, authority, boundary, and interface records'
      using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_capability_requirement()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare v_source_type text; v_subject_type text;
begin
  select object_type into v_source_type from consulting_os.domain_objects
  where id = new.source_domain_object_id and organization_id = new.organization_id;
  select object_type into v_subject_type from consulting_os.domain_objects
  where id = new.target_subject_id and organization_id = new.organization_id;
  if v_source_type is distinct from new.source_type then
    raise exception 'capability requirement source_type must match its typed source object' using errcode = '23514';
  end if;
  if v_subject_type not in ('ROLE','ROLE_ASSIGNMENT','TEAM','REINVENTION_INITIATIVE','WORKFLOW') then
    raise exception 'capability requirement subject must be a role, assignment, team, initiative, or workflow'
      using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_capability_assessment_evidence()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1 from consulting_os.capability_assessment_evidence
    where assessment_id = new.id and organization_id = new.organization_id
  ) then
    raise exception 'capability assessment requires at least one visible evidence record' using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_capability_gap()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_required consulting_os.capability_level;
  v_current consulting_os.capability_level;
  v_req_capability uuid;
  v_assessment_capability uuid;
  v_req_subject uuid;
  v_assessment_subject uuid;
  v_req_engagement uuid;
  v_assessment_engagement uuid;
begin
  select required_level, capability_id, target_subject_id, engagement_id
    into v_required, v_req_capability, v_req_subject, v_req_engagement
  from consulting_os.capability_requirements
  where id = new.requirement_id and organization_id = new.organization_id;
  select assessed_level, capability_id, subject_domain_object_id, engagement_id
    into v_current, v_assessment_capability, v_assessment_subject, v_assessment_engagement
  from consulting_os.capability_assessments
  where id = new.assessment_id and organization_id = new.organization_id;
  if v_req_capability is distinct from v_assessment_capability
    or v_req_subject is distinct from v_assessment_subject
    or v_req_engagement is distinct from v_assessment_engagement
    or v_req_engagement is distinct from new.engagement_id
    or v_required is distinct from new.required_level
    or v_current is distinct from new.current_level
  then
    raise exception 'capability gap must compare the same capability, subject, engagement, and recorded levels'
      using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_development_plan()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare v_subject uuid; v_engagement uuid;
begin
  select r.target_subject_id, g.engagement_id into v_subject, v_engagement
  from consulting_os.capability_gaps g
  join consulting_os.capability_requirements r
    on r.id = g.requirement_id and r.organization_id = g.organization_id
  where g.id = new.capability_gap_id and g.organization_id = new.organization_id;
  if v_subject is distinct from new.subject_domain_object_id or v_engagement is distinct from new.engagement_id then
    raise exception 'development plan must retain the capability gap subject and engagement'
      using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_maturity_evidence()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare v_capability uuid; v_subject uuid;
begin
  if not exists (
    select 1 from consulting_os.capability_maturity_evidence
    where maturity_assessment_id = new.id and organization_id = new.organization_id
  ) then
    raise exception 'maturity assessment requires at least one evidence record' using errcode = '23514';
  end if;
  if new.prior_assessment_id is not null then
    select capability_id, subject_domain_object_id into v_capability, v_subject
    from consulting_os.capability_assessments
    where id = new.prior_assessment_id and organization_id = new.organization_id;
    if v_capability is distinct from new.capability_id or v_subject is distinct from new.subject_domain_object_id then
      raise exception 'maturity assessment must retain the prior capability and subject'
        using errcode = '23514';
    end if;
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_phase6_reference_visibility()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_new jsonb;
  v_container_id uuid;
  v_refs uuid[];
  v_ref uuid;
  v_container_visibility consulting_os.visibility_scope;
  v_ref_visibility consulting_os.visibility_scope;
  v_ref_type text;
begin
  v_new := to_jsonb(new);
  if tg_table_name = 'workflow_steps' then
    v_container_id := (v_new ->> 'workflow_version_id')::uuid;
    v_refs := array_remove(array[(v_new ->> 'owner_role_id')::uuid, (v_new ->> 'handoff_to_role_id')::uuid], null);
  elsif tg_table_name = 'capability_assessment_evidence' then
    v_container_id := (v_new ->> 'assessment_id')::uuid;
    v_refs := array[(v_new ->> 'evidence_id')::uuid];
  elsif tg_table_name = 'capability_maturity_evidence' then
    v_container_id := (v_new ->> 'maturity_assessment_id')::uuid;
    v_refs := array[(v_new ->> 'evidence_domain_object_id')::uuid];
  else
    v_container_id := (v_new ->> 'id')::uuid;
    v_refs := case tg_table_name
      when 'role_assignments' then array[(v_new ->> 'role_id')::uuid]
      when 'design_principles' then array_remove(array[(v_new ->> 'source_future_state_principle_id')::uuid], null)
      when 'responsibilities' then array[(v_new ->> 'role_id')::uuid]
      when 'authorities' then array[(v_new ->> 'role_id')::uuid]
      when 'boundaries' then array[(v_new ->> 'role_id')::uuid]
      when 'interfaces' then array[(v_new ->> 'source_role_id')::uuid, (v_new ->> 'target_role_id')::uuid]
      when 'workflow_versions' then array[(v_new ->> 'owner_role_id')::uuid]
      when 'reinvention_initiatives' then array[(v_new ->> 'authorizing_decision_id')::uuid]
      when 'capability_requirements' then array[(v_new ->> 'capability_id')::uuid, (v_new ->> 'source_domain_object_id')::uuid, (v_new ->> 'target_subject_id')::uuid]
      when 'capability_assessments' then array[(v_new ->> 'capability_id')::uuid, (v_new ->> 'subject_domain_object_id')::uuid]
      when 'capability_gaps' then array[(v_new ->> 'requirement_id')::uuid, (v_new ->> 'assessment_id')::uuid]
      when 'organizational_systems' then array[(v_new ->> 'operating_owner_role_id')::uuid]
      when 'metric_definitions' then array[(v_new ->> 'accountable_role_id')::uuid]
      when 'alignment_conflicts' then array_remove(array[(v_new ->> 'first_domain_object_id')::uuid, (v_new ->> 'second_domain_object_id')::uuid, (v_new ->> 'resolution_decision_id')::uuid], null)
      when 'development_plans' then array[(v_new ->> 'capability_gap_id')::uuid, (v_new ->> 'subject_domain_object_id')::uuid]
      when 'development_activities' then array[(v_new ->> 'development_plan_id')::uuid]
      when 'practices' then array[(v_new ->> 'development_plan_id')::uuid, (v_new ->> 'capability_id')::uuid]
      when 'resources' then array[(v_new ->> 'development_plan_id')::uuid]
      when 'capability_maturity_assessments' then array_remove(array[(v_new ->> 'capability_id')::uuid, (v_new ->> 'subject_domain_object_id')::uuid, (v_new ->> 'prior_assessment_id')::uuid], null)
      else array[]::uuid[]
    end;
  end if;

  select visibility_scope into v_container_visibility from consulting_os.domain_objects
  where id = v_container_id and organization_id = new.organization_id;
  foreach v_ref in array v_refs loop
    select visibility_scope, object_type into v_ref_visibility, v_ref_type
    from consulting_os.domain_objects where id = v_ref and organization_id = new.organization_id;
    if v_ref_visibility is null or not consulting_security.visibility_can_contain(v_container_visibility, v_ref_visibility) then
      raise exception 'Phase 6 composition cannot broaden referenced-object visibility' using errcode = '42501';
    end if;
    if (select auth.uid()) is not null and not consulting_security.can_read_domain_object(v_ref, new.organization_id) then
      raise exception 'Phase 6 composition requires readable referenced objects' using errcode = '42501';
    end if;
    if tg_table_name = 'capability_maturity_evidence'
      and v_ref_type not in ('EVIDENCE','MEASUREMENT','OUTCOME','MEETING_NOTE','COMMITMENT','ASSESSMENT_RESPONSE')
    then
      raise exception 'maturity evidence must be an eligible observed or recorded evidence object' using errcode = '23514';
    end if;
  end loop;
  return new;
end
$$;

do $$ declare v_table text; begin
  foreach v_table in array array[
    'roles','role_assignments','design_principles','responsibilities','authorities','boundaries','interfaces',
    'workflow_versions','reinvention_initiatives','capabilities','capability_requirements','capability_assessments',
    'capability_gaps','organizational_systems','metric_definitions','alignment_conflicts','development_plans',
    'development_activities','practices','resources','capability_maturity_assessments'
  ] loop
    execute format('create trigger %I before insert on consulting_os.%I for each row execute function consulting_security.validate_phase6_typed_record()', v_table || '_typed_validate', v_table);
  end loop;
end $$;

do $$ declare v_table text; begin
  foreach v_table in array array[
    'role_assignments','design_principles','responsibilities','authorities','boundaries','interfaces','workflow_versions',
    'reinvention_initiatives','capability_requirements','capability_assessments','capability_gaps','organizational_systems',
    'metric_definitions','alignment_conflicts','development_plans','development_activities','practices','resources',
    'capability_maturity_assessments','workflow_steps','capability_assessment_evidence','capability_maturity_evidence'
  ] loop
    execute format('create trigger %I before insert or update on consulting_os.%I for each row execute function consulting_security.validate_phase6_reference_visibility()', v_table || '_reference_visibility', v_table);
  end loop;
end $$;

do $$ declare v_table text; begin
  foreach v_table in array array[
    'roles','design_principles','responsibilities','authorities','boundaries','interfaces','workflow_versions',
    'capabilities','organizational_systems','metric_definitions'
  ] loop
    execute format('create trigger %I before insert on consulting_os.%I for each row execute function consulting_security.validate_version_chain()', v_table || '_version_chain', v_table);
    execute format('create trigger %I before update or delete on consulting_os.%I for each row execute function consulting_security.prevent_versioned_mutation()', v_table || '_immutable', v_table);
  end loop;
end $$;

create constraint trigger roles_complete after insert or update on consulting_os.roles
deferrable initially deferred for each row execute function consulting_security.validate_role_architecture();
create constraint trigger responsibilities_role_complete after insert or update on consulting_os.responsibilities
deferrable initially deferred for each row execute function consulting_security.validate_role_architecture();
create constraint trigger authorities_role_complete after insert or update on consulting_os.authorities
deferrable initially deferred for each row execute function consulting_security.validate_role_architecture();
create constraint trigger boundaries_role_complete after insert or update on consulting_os.boundaries
deferrable initially deferred for each row execute function consulting_security.validate_role_architecture();
create constraint trigger interfaces_role_complete after insert or update on consulting_os.interfaces
deferrable initially deferred for each row execute function consulting_security.validate_role_architecture();
create trigger capability_requirements_validate before insert or update on consulting_os.capability_requirements
for each row execute function consulting_security.validate_capability_requirement();
create constraint trigger capability_assessments_require_evidence after insert or update on consulting_os.capability_assessments
deferrable initially deferred for each row execute function consulting_security.validate_capability_assessment_evidence();
create trigger capability_gaps_validate before insert or update on consulting_os.capability_gaps
for each row execute function consulting_security.validate_capability_gap();
create trigger development_plans_validate before insert or update on consulting_os.development_plans
for each row execute function consulting_security.validate_development_plan();
create constraint trigger maturity_assessments_require_evidence after insert or update on consulting_os.capability_maturity_assessments
deferrable initially deferred for each row execute function consulting_security.validate_maturity_evidence();

insert into consulting_security.relationship_type_rules
  (relationship_type, source_type, target_type, rationale)
values
  ('INFORMS','FUTURE_STATE_PRINCIPLE','DECISION','Future-state principle informs an authorized Decision.'),
  ('CREATES','DECISION','ROLE','Decision creates a Role architecture record.'),
  ('CREATES','DECISION','RESPONSIBILITY','Decision creates Responsibility.'),
  ('CREATES','DECISION','AUTHORITY','Decision creates Authority.'),
  ('CREATES','DECISION','BOUNDARY','Decision creates Boundary.'),
  ('CREATES','DECISION','INTERFACE','Decision creates Interface.'),
  ('CREATES','DECISION','WORKFLOW','Decision creates a versioned Workflow.'),
  ('CREATES','DECISION','SYSTEM','Decision creates an organizational System.'),
  ('CREATES','DECISION','REINVENTION_INITIATIVE','Decision creates a Reinvention Initiative.'),
  ('AUTHORIZES','DECISION','REINVENTION_INITIATIVE','Decision authorizes an Initiative.'),
  ('AUTHORIZES','DECISION','AUTHORITY','Decision authorizes Authority.'),
  ('AUTHORIZES','DECISION','WORKFLOW','Decision authorizes a Workflow change.'),
  ('REQUIRES','FUTURE_STATE','CAPABILITY_REQUIREMENT','Future State requires capability.'),
  ('REQUIRES','ROLE','CAPABILITY_REQUIREMENT','Role requires capability.'),
  ('REQUIRES','REINVENTION_INITIATIVE','CAPABILITY_REQUIREMENT','Initiative requires capability.'),
  ('REQUIRES','WORKFLOW','CAPABILITY_REQUIREMENT','Workflow requires capability.'),
  ('DEVELOPS','DEVELOPMENT_PLAN','CAPABILITY','Development plan develops Capability.'),
  ('DEVELOPS','DEVELOPMENT_ACTIVITY','CAPABILITY','Development activity develops Capability.'),
  ('DEVELOPS','COACHING_SESSION','CAPABILITY','Coaching develops Capability.'),
  ('ENABLES','CAPABILITY','FUTURE_STATE','Capability enables a Future State.'),
  ('ENABLES','CAPABILITY','REINVENTION_INITIATIVE','Capability enables an Initiative.'),
  ('ENABLES','CAPABILITY','ROLE','Capability enables a Role.'),
  ('ENABLES','SYSTEM','FUTURE_STATE','System enables a Future State.'),
  ('ENABLES','SYSTEM','ROLE','System enables a Role.'),
  ('ENABLES','AUTHORITY','ROLE','Authority enables a Role.'),
  ('CONSTRAINS','BOUNDARY','ROLE','Boundary constrains a Role.'),
  ('CONSTRAINS','BOUNDARY','AUTHORITY','Boundary constrains Authority.'),
  ('CONSTRAINS','BOUNDARY','WORKFLOW','Boundary constrains a Workflow.'),
  ('CONSTRAINS','DESIGN_PRINCIPLE','ROLE','Design Principle constrains Role design.'),
  ('CONSTRAINS','DESIGN_PRINCIPLE','WORKFLOW','Design Principle constrains Workflow design.'),
  ('OWNS','ROLE_ASSIGNMENT','RESPONSIBILITY','Assigned person owns Responsibility through a Role.'),
  ('OWNS','ROLE_ASSIGNMENT','WORKFLOW','Assigned person owns a Workflow through a Role.'),
  ('OWNS','ROLE_ASSIGNMENT','REINVENTION_INITIATIVE','Assigned person owns an Initiative.'),
  ('SUPPORTED_BY','CAPABILITY_ASSESSMENT','EVIDENCE','Capability assessment is evidence-based.'),
  ('SUPPORTED_BY','READINESS_MATURITY','EVIDENCE','Maturity judgment is evidence-based.');

alter table consulting_os.roles enable row level security;
alter table consulting_os.role_assignments enable row level security;
alter table consulting_os.design_principles enable row level security;
alter table consulting_os.responsibilities enable row level security;
alter table consulting_os.authorities enable row level security;
alter table consulting_os.boundaries enable row level security;
alter table consulting_os.interfaces enable row level security;
alter table consulting_os.workflows enable row level security;
alter table consulting_os.workflow_versions enable row level security;
alter table consulting_os.workflow_steps enable row level security;
alter table consulting_os.reinvention_initiatives enable row level security;
alter table consulting_os.capabilities enable row level security;
alter table consulting_os.capability_requirements enable row level security;
alter table consulting_os.capability_assessments enable row level security;
alter table consulting_os.capability_assessment_evidence enable row level security;
alter table consulting_os.capability_gaps enable row level security;
alter table consulting_os.organizational_systems enable row level security;
alter table consulting_os.metric_definitions enable row level security;
alter table consulting_os.alignment_conflicts enable row level security;
alter table consulting_os.development_plans enable row level security;
alter table consulting_os.development_activities enable row level security;
alter table consulting_os.practices enable row level security;
alter table consulting_os.resources enable row level security;
alter table consulting_os.capability_maturity_assessments enable row level security;
alter table consulting_os.capability_maturity_evidence enable row level security;

do $$ declare v_table text; begin
  foreach v_table in array array[
    'roles','role_assignments','design_principles','responsibilities','authorities','boundaries','interfaces',
    'workflow_versions','reinvention_initiatives','capabilities','capability_requirements','capability_assessments',
    'capability_gaps','organizational_systems','metric_definitions','alignment_conflicts','development_plans',
    'development_activities','practices','resources','capability_maturity_assessments'
  ] loop
    execute format('create policy %I on consulting_os.%I for select to authenticated using (consulting_security.can_read_domain_object(id, organization_id))', v_table || '_select_visible', v_table);
    execute format('create policy %I on consulting_os.%I for insert to authenticated with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(id, organization_id))', v_table || '_insert_authorized', v_table);
  end loop;
end $$;

create policy workflows_select_visible on consulting_os.workflows for select to authenticated
using (consulting_security.can_access_organization(organization_id));
create policy workflows_insert_authorized on consulting_os.workflows for insert to authenticated
with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_organization(organization_id));
create policy workflow_steps_select_visible on consulting_os.workflow_steps for select to authenticated
using (consulting_security.can_read_domain_object(workflow_version_id, organization_id));
create policy workflow_steps_insert_authorized on consulting_os.workflow_steps for insert to authenticated
with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(workflow_version_id, organization_id));
create policy assessment_evidence_select_visible on consulting_os.capability_assessment_evidence for select to authenticated
using (consulting_security.can_read_domain_object(assessment_id, organization_id) and consulting_security.can_read_domain_object(evidence_id, organization_id));
create policy assessment_evidence_insert_authorized on consulting_os.capability_assessment_evidence for insert to authenticated
with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(assessment_id, organization_id) and consulting_security.can_read_domain_object(evidence_id, organization_id));
create policy maturity_evidence_select_visible on consulting_os.capability_maturity_evidence for select to authenticated
using (consulting_security.can_read_domain_object(maturity_assessment_id, organization_id) and consulting_security.can_read_domain_object(evidence_domain_object_id, organization_id));
create policy maturity_evidence_insert_authorized on consulting_os.capability_maturity_evidence for insert to authenticated
with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(maturity_assessment_id, organization_id) and consulting_security.can_read_domain_object(evidence_domain_object_id, organization_id));

create policy role_assignments_update_authorized on consulting_os.role_assignments for update to authenticated
using (consulting_security.can_manage_domain_object(id, organization_id))
with check (consulting_security.can_manage_domain_object(id, organization_id));
create policy initiatives_update_authorized on consulting_os.reinvention_initiatives for update to authenticated
using (consulting_security.can_manage_domain_object(id, organization_id))
with check (consulting_security.can_manage_domain_object(id, organization_id));
create policy development_plans_update_authorized on consulting_os.development_plans for update to authenticated
using (consulting_security.can_manage_domain_object(id, organization_id))
with check (consulting_security.can_manage_domain_object(id, organization_id));
create policy development_activities_update_authorized on consulting_os.development_activities for update to authenticated
using (consulting_security.can_manage_domain_object(id, organization_id))
with check (consulting_security.can_manage_domain_object(id, organization_id));

do $$ declare v_table text; begin
  foreach v_table in array array[
    'roles','role_assignments','design_principles','responsibilities','authorities','boundaries','interfaces',
    'workflow_versions','reinvention_initiatives','capabilities','capability_requirements','capability_assessments',
    'capability_gaps','organizational_systems','metric_definitions','alignment_conflicts','development_plans',
    'development_activities','practices','resources','capability_maturity_assessments'
  ] loop
    execute format('revoke all on consulting_os.%I from public, anon, authenticated', v_table);
    execute format('grant select, insert on consulting_os.%I to authenticated', v_table);
    execute format('grant all on consulting_os.%I to service_role', v_table);
  end loop;
  foreach v_table in array array['workflows','workflow_steps','capability_assessment_evidence','capability_maturity_evidence'] loop
    execute format('revoke all on consulting_os.%I from public, anon, authenticated', v_table);
    execute format('grant select, insert on consulting_os.%I to authenticated', v_table);
    execute format('grant all on consulting_os.%I to service_role', v_table);
  end loop;
end $$;

grant update (status, ends_on) on consulting_os.role_assignments to authenticated;
grant update (status) on consulting_os.reinvention_initiatives to authenticated;
grant update (status) on consulting_os.development_plans to authenticated;
grant update (status, completed_at) on consulting_os.development_activities to authenticated;

create or replace view consulting_os.current_roles with (security_invoker = true) as
select r.* from consulting_os.roles r
where r.effective_from <= now() and (r.effective_to is null or r.effective_to > now())
  and r.status in ('APPROVED','ACTIVE')
  and not exists (select 1 from consulting_os.roles newer where newer.organization_id = r.organization_id and newer.logical_id = r.logical_id and newer.version_number > r.version_number and newer.effective_from <= now() and newer.status in ('APPROVED','ACTIVE'));

create or replace view consulting_os.current_design_principles with (security_invoker = true) as
select d.* from consulting_os.design_principles d
where d.effective_from <= now() and (d.effective_to is null or d.effective_to > now())
  and d.status in ('APPROVED','ACTIVE')
  and not exists (select 1 from consulting_os.design_principles newer where newer.organization_id = d.organization_id and newer.logical_id = d.logical_id and newer.version_number > d.version_number and newer.effective_from <= now() and newer.status in ('APPROVED','ACTIVE'));

create or replace view consulting_os.current_workflow_versions with (security_invoker = true) as
select wv.* from consulting_os.workflow_versions wv
where wv.effective_from <= now() and (wv.effective_to is null or wv.effective_to > now())
  and wv.status in ('APPROVED','ACTIVE')
  and not exists (select 1 from consulting_os.workflow_versions newer where newer.organization_id = wv.organization_id and newer.logical_id = wv.logical_id and newer.version_number > wv.version_number and newer.effective_from <= now() and newer.status in ('APPROVED','ACTIVE'));

create or replace view consulting_os.current_capabilities with (security_invoker = true) as
select c.* from consulting_os.capabilities c
where c.effective_from <= now() and (c.effective_to is null or c.effective_to > now())
  and c.status in ('APPROVED','ACTIVE')
  and not exists (select 1 from consulting_os.capabilities newer where newer.organization_id = c.organization_id and newer.logical_id = c.logical_id and newer.version_number > c.version_number and newer.effective_from <= now() and newer.status in ('APPROVED','ACTIVE'));

create or replace view consulting_os.role_architecture with (security_invoker = true) as
select r.id, r.organization_id, r.logical_id, r.version_number, r.name, r.purpose, r.support, r.accountability, r.success_measures, r.status,
  coalesce((select jsonb_agg(jsonb_build_object('id', x.id, 'statement', x.statement, 'outcome', x.outcome_definition) order by x.created_at) from consulting_os.responsibilities x where x.role_id = r.id and x.organization_id = r.organization_id), '[]'::jsonb) responsibilities,
  coalesce((select jsonb_agg(jsonb_build_object('id', x.id, 'domain', x.decision_domain, 'limit', x.authority_limit, 'escalation', x.escalation_condition) order by x.created_at) from consulting_os.authorities x where x.role_id = r.id and x.organization_id = r.organization_id), '[]'::jsonb) authorities,
  coalesce((select jsonb_agg(jsonb_build_object('id', x.id, 'inside', x.inside_scope, 'outside', x.outside_scope, 'constraints', x.constraints) order by x.created_at) from consulting_os.boundaries x where x.role_id = r.id and x.organization_id = r.organization_id), '[]'::jsonb) boundaries,
  coalesce((select jsonb_agg(jsonb_build_object('id', x.id, 'target_role_id', x.target_role_id, 'purpose', x.purpose, 'cadence', x.cadence) order by x.created_at) from consulting_os.interfaces x where x.source_role_id = r.id and x.organization_id = r.organization_id), '[]'::jsonb) interfaces
from consulting_os.current_roles r;

create or replace view consulting_os.capability_pathways with (security_invoker = true) as
select req.id requirement_id, req.organization_id, req.engagement_id, req.source_domain_object_id, req.source_type,
  req.target_subject_id, c.id capability_id, c.name capability_name, req.required_level,
  a.id assessment_id, a.assessed_level current_level, a.evidence_summary, g.id gap_id, g.gap_statement, g.priority,
  p.id development_plan_id, p.title development_plan_title, p.status development_status,
  (select count(*) from consulting_os.practices pr where pr.development_plan_id = p.id and pr.organization_id = p.organization_id) practice_count,
  (select max(m.assessed_at) from consulting_os.capability_maturity_assessments m where m.capability_id = c.id and m.subject_domain_object_id = req.target_subject_id and m.organization_id = req.organization_id) latest_maturity_at
from consulting_os.capability_requirements req
join consulting_os.current_capabilities c on c.id = req.capability_id and c.organization_id = req.organization_id
left join lateral (
  select ca.* from consulting_os.capability_assessments ca
  where ca.capability_id = req.capability_id and ca.subject_domain_object_id = req.target_subject_id and ca.organization_id = req.organization_id
  order by ca.assessed_at desc limit 1
) a on true
left join consulting_os.capability_gaps g on g.requirement_id = req.id and g.assessment_id = a.id and g.organization_id = req.organization_id
left join consulting_os.development_plans p on p.capability_gap_id = g.id and p.organization_id = req.organization_id;

create or replace view consulting_os.my_capability_pathways with (security_invoker = true) as
select cp.*
from consulting_os.capability_pathways cp
join consulting_os.role_assignments ra
  on ra.id = cp.target_subject_id and ra.organization_id = cp.organization_id
join consulting_os.organization_memberships om
  on om.id = ra.organization_membership_id and om.organization_id = ra.organization_id
where om.person_id = consulting_security.current_person_id()
  and om.status = 'ACTIVE'
  and ra.status = 'ACTIVE';

grant select on consulting_os.current_roles, consulting_os.current_design_principles,
  consulting_os.current_workflow_versions, consulting_os.current_capabilities,
  consulting_os.role_architecture, consulting_os.capability_pathways,
  consulting_os.my_capability_pathways
to authenticated, service_role;

comment on table consulting_os.roles is 'Versioned role architecture: Purpose + Responsibility + Authority + Boundaries + Interfaces + Support + Accountability + Success Measures.';
comment on table consulting_os.workflow_versions is 'Immutable meaning-bearing WORKFLOW domain records under a stable workflow container.';
comment on table consulting_os.capability_assessments is 'Evidence-based current-state assessment; never a self-explanatory score or diagnosis.';
comment on view consulting_os.capability_pathways is 'Permission-filtered trace from required capability through assessment, gap, development, practice, and maturity evidence.';
comment on view consulting_os.my_capability_pathways is 'Current person projection through their active organization membership and role assignment; never a broad client development listing.';
