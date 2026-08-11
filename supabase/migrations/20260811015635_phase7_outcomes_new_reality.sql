-- Phase 7: Outcomes + New Reality. Private Consulting OS only.
-- Additive and unapplied to every hosted environment.

create type consulting_os.goal_status as enum ('DRAFT','ACTIVE','ACHIEVED','MISSED','RETIRED','SUPERSEDED');
create type consulting_os.indicator_direction as enum ('INCREASE','DECREASE','MAINTAIN','RANGE','DESCRIPTIVE');
create type consulting_os.value_hypothesis_status as enum ('PROPOSED','TESTING','SUPPORTED','PARTIALLY_SUPPORTED','UNSUPPORTED','SUPERSEDED');
create type consulting_os.outcome_interpretation_status as enum ('OBSERVED','UNDER_REVIEW','REVIEWED');
create type consulting_os.value_dimension as enum ('MISSION','HUMAN','OPERATIONAL','ECONOMIC','SUSTAINABLE');
create type consulting_os.value_dimension_rating as enum ('NOT_ASSESSED','WEAK','MIXED','STRONG');
create type consulting_os.outcome_disposition as enum ('SUSTAIN','IMPROVE','SCALE','STOP','REINVENT');

create table consulting_os.strategic_priorities (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('STRATEGIC_PRIORITY'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  statement text not null check (length(btrim(statement)) > 0),
  owner_domain_object_id uuid not null,
  horizon text not null check (length(btrim(horizon)) > 0),
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (owner_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.strategic_priorities(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.goals (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('GOAL'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  strategic_priority_id uuid,
  statement text not null check (length(btrim(statement)) > 0),
  owner_domain_object_id uuid not null,
  baseline_value text not null check (length(btrim(baseline_value)) > 0),
  baseline_at timestamptz not null,
  target_value text not null check (length(btrim(target_value)) > 0),
  target_at timestamptz not null,
  horizon text not null check (length(btrim(horizon)) > 0),
  status consulting_os.goal_status not null default 'DRAFT',
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (strategic_priority_id, organization_id) references consulting_os.strategic_priorities(id, organization_id) on delete restrict,
  foreign key (owner_domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.goals(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (target_at > baseline_at),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.value_hypotheses (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('VALUE_HYPOTHESIS'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  intervention_id uuid not null,
  capability_id uuid not null,
  change_condition text not null check (length(btrim(change_condition)) > 0),
  capability_condition text not null check (length(btrim(capability_condition)) > 0),
  expected_value text not null check (length(btrim(expected_value)) > 0),
  causal_rationale text not null check (length(btrim(causal_rationale)) > 0),
  value_dimensions consulting_os.value_dimension[] not null default array[]::consulting_os.value_dimension[],
  status consulting_os.value_hypothesis_status not null default 'PROPOSED',
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (intervention_id, organization_id) references consulting_os.reinvention_initiatives(id, organization_id) on delete restrict,
  foreign key (capability_id, organization_id) references consulting_os.capabilities(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.value_hypotheses(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (cardinality(value_dimensions) > 0),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.indicators (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('INDICATOR'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  goal_id uuid,
  value_hypothesis_id uuid,
  name text not null check (length(btrim(name)) > 0),
  definition text not null check (length(btrim(definition)) > 0),
  direction consulting_os.indicator_direction not null,
  cadence text not null check (length(btrim(cadence)) > 0),
  source_description text not null check (length(btrim(source_description)) > 0),
  unit text,
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (goal_id, organization_id) references consulting_os.goals(id, organization_id) on delete restrict,
  foreign key (value_hypothesis_id, organization_id) references consulting_os.value_hypotheses(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.indicators(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (goal_id is not null or value_hypothesis_id is not null),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.measurements (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('MEASUREMENT'::text) stored,
  indicator_id uuid not null,
  primary_evidence_id uuid not null,
  measured_at timestamptz not null,
  period_start timestamptz not null,
  period_end timestamptz not null,
  value_payload jsonb not null,
  display_value text not null check (length(btrim(display_value)) > 0),
  collection_context text not null check (length(btrim(collection_context)) > 0),
  limitations text not null check (length(btrim(limitations)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (indicator_id, organization_id) references consulting_os.indicators(id, organization_id) on delete restrict,
  foreign key (primary_evidence_id, organization_id) references consulting_os.evidence_items(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (jsonb_typeof(value_payload) in ('number','string','boolean','object','array')),
  check (period_end >= period_start),
  check (measured_at >= period_end)
);

create table consulting_os.outcomes (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('OUTCOME'::text) stored,
  goal_id uuid not null,
  value_hypothesis_id uuid not null,
  intervention_id uuid not null,
  primary_measurement_id uuid not null,
  primary_evidence_id uuid not null,
  statement text not null check (length(btrim(statement)) > 0),
  observed_value text not null check (length(btrim(observed_value)) > 0),
  period_start timestamptz not null,
  period_end timestamptz not null,
  unexpected boolean not null default false,
  evidence_summary text not null check (length(btrim(evidence_summary)) > 0),
  interpretation_status consulting_os.outcome_interpretation_status not null default 'OBSERVED',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (goal_id, organization_id) references consulting_os.goals(id, organization_id) on delete restrict,
  foreign key (value_hypothesis_id, organization_id) references consulting_os.value_hypotheses(id, organization_id) on delete restrict,
  foreign key (intervention_id, organization_id) references consulting_os.reinvention_initiatives(id, organization_id) on delete restrict,
  foreign key (primary_measurement_id, organization_id) references consulting_os.measurements(id, organization_id) on delete restrict,
  foreign key (primary_evidence_id, organization_id) references consulting_os.evidence_items(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (period_end >= period_start)
);

create table consulting_os.value_evaluations (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('VALUE_EVALUATION'::text) stored,
  outcome_id uuid not null,
  value_hypothesis_id uuid not null,
  harvest_finding text not null check (length(btrim(harvest_finding)) > 0),
  soil_finding text not null check (length(btrim(soil_finding)) > 0),
  mission_rating consulting_os.value_dimension_rating not null,
  mission_assessment text not null check (length(btrim(mission_assessment)) > 0),
  human_rating consulting_os.value_dimension_rating not null,
  human_assessment text not null check (length(btrim(human_assessment)) > 0),
  operational_rating consulting_os.value_dimension_rating not null,
  operational_assessment text not null check (length(btrim(operational_assessment)) > 0),
  economic_rating consulting_os.value_dimension_rating not null,
  economic_assessment text not null check (length(btrim(economic_assessment)) > 0),
  sustainable_rating consulting_os.value_dimension_rating not null,
  sustainable_assessment text not null check (length(btrim(sustainable_assessment)) > 0),
  significance text not null check (length(btrim(significance)) > 0),
  alternative_explanations text not null check (length(btrim(alternative_explanations)) > 0),
  limitations text not null check (length(btrim(limitations)) > 0),
  evaluated_by uuid not null references consulting_os.people(id) on delete restrict,
  evaluated_at timestamptz not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (outcome_id, organization_id) references consulting_os.outcomes(id, organization_id) on delete restrict,
  foreign key (value_hypothesis_id, organization_id) references consulting_os.value_hypotheses(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.learnings (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('LEARNING'::text) stored,
  value_evaluation_id uuid not null,
  statement text not null check (length(btrim(statement)) > 0),
  evidence_summary text not null check (length(btrim(evidence_summary)) > 0),
  implications text not null check (length(btrim(implications)) > 0),
  limitations text not null check (length(btrim(limitations)) > 0),
  initial_review_state consulting_os.epistemic_review_state not null default 'UNDER_REVIEW',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (value_evaluation_id, organization_id) references consulting_os.value_evaluations(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (initial_review_state not in ('VALIDATED','REJECTED','SUPERSEDED'))
);

create table consulting_os.outcome_decisions (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('OUTCOME_DECISION'::text) stored,
  learning_id uuid not null,
  disposition consulting_os.outcome_disposition not null,
  rationale text not null check (length(btrim(rationale)) > 0),
  next_action text not null check (length(btrim(next_action)) > 0),
  authorized_by uuid not null references consulting_os.people(id) on delete restrict,
  decided_at timestamptz not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (learning_id, organization_id) references consulting_os.learnings(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.emergent_organization_profiles (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('EMERGENT_ORGANIZATION_PROFILE'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  intended_future_state_id uuid not null,
  name text not null check (length(btrim(name)) > 0),
  identity_state text not null check (length(btrim(identity_state)) > 0),
  purpose_state text not null check (length(btrim(purpose_state)) > 0),
  culture_state text not null check (length(btrim(culture_state)) > 0),
  people_state text not null check (length(btrim(people_state)) > 0),
  structure_state text not null check (length(btrim(structure_state)) > 0),
  systems_state text not null check (length(btrim(systems_state)) > 0),
  technology_state text not null check (length(btrim(technology_state)) > 0),
  relationships_state text not null check (length(btrim(relationships_state)) > 0),
  value_state text not null check (length(btrim(value_state)) > 0),
  stories_state text not null check (length(btrim(stories_state)) > 0),
  assumptions_state text not null check (length(btrim(assumptions_state)) > 0),
  status consulting_os.design_record_status not null default 'DRAFT',
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (intended_future_state_id, organization_id) references consulting_os.future_states(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id) references consulting_os.emergent_organization_profiles(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.emergent_profile_members (
  organization_id uuid not null,
  profile_id uuid not null,
  domain_object_id uuid not null,
  member_role text not null check (member_role ~ '^[A-Z][A-Z0-9_]*$'),
  rationale text not null check (length(btrim(rationale)) > 0),
  captured_object_type text not null,
  captured_visibility_scope consulting_os.visibility_scope not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (profile_id, domain_object_id, member_role),
  foreign key (profile_id, organization_id) references consulting_os.emergent_organization_profiles(id, organization_id) on delete restrict,
  foreign key (domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict
);

create table consulting_os.emergent_reality_differences (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('EMERGENT_REALITY_DIFFERENCE'::text) stored,
  intended_future_state_id uuid not null,
  emergent_profile_id uuid not null,
  dimension text not null check (dimension ~ '^[A-Z][A-Z0-9_]*$'),
  intended_state text not null check (length(btrim(intended_state)) > 0),
  actual_state text not null check (length(btrim(actual_state)) > 0),
  difference_statement text not null check (length(btrim(difference_statement)) > 0),
  interpretation text not null check (length(btrim(interpretation)) > 0),
  unexpected_value text not null check (length(btrim(unexpected_value)) > 0),
  new_tensions text not null check (length(btrim(new_tensions)) > 0),
  review_status consulting_os.review_status not null default 'SUGGESTED',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (intended_future_state_id, organization_id) references consulting_os.future_states(id, organization_id) on delete restrict,
  foreign key (emergent_profile_id, organization_id) references consulting_os.emergent_organization_profiles(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.organizational_stories (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('ORGANIZATIONAL_STORY'::text) stored,
  title text not null check (length(btrim(title)) > 0),
  story text not null check (length(btrim(story)) > 0),
  period_start date not null,
  period_end date not null,
  people_summary text not null check (length(btrim(people_summary)) > 0),
  significance text not null check (length(btrim(significance)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (period_end >= period_start)
);

create table consulting_os.organizational_story_links (
  organization_id uuid not null,
  organizational_story_id uuid not null,
  domain_object_id uuid not null,
  link_role text not null check (link_role in ('DECISION','OUTCOME')),
  captured_object_type text not null,
  captured_visibility_scope consulting_os.visibility_scope not null,
  rationale text not null check (length(btrim(rationale)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (organizational_story_id, domain_object_id, link_role),
  foreign key (organizational_story_id, organization_id) references consulting_os.organizational_stories(id, organization_id) on delete restrict,
  foreign key (domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict
);

create table consulting_os.baseline_snapshots (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('BASELINE_SNAPSHOT'::text) stored,
  source_profile_id uuid not null,
  next_engagement_id uuid,
  snapshot_at timestamptz not null,
  scope text not null check (length(btrim(scope)) > 0),
  rationale text not null check (length(btrim(rationale)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (source_profile_id, organization_id) references consulting_os.emergent_organization_profiles(id, organization_id) on delete restrict,
  foreign key (next_engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.baseline_snapshot_members (
  organization_id uuid not null,
  baseline_snapshot_id uuid not null,
  domain_object_id uuid not null,
  captured_object_type text not null,
  captured_visibility_scope consulting_os.visibility_scope not null,
  captured_logical_id uuid,
  captured_version_number integer,
  member_role text not null check (member_role ~ '^[A-Z][A-Z0-9_]*$'),
  label text not null check (length(btrim(label)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (baseline_snapshot_id, domain_object_id, member_role),
  foreign key (baseline_snapshot_id, organization_id) references consulting_os.baseline_snapshots(id, organization_id) on delete restrict,
  foreign key (domain_object_id, organization_id) references consulting_os.domain_objects(id, organization_id) on delete restrict,
  check ((captured_logical_id is null) = (captured_version_number is null))
);

alter table consulting_os.entity_relationships
  add column evidence_summary text,
  add column alternative_explanations text,
  add column validated_by uuid references consulting_os.people(id) on delete restrict,
  add column validated_at timestamptz;

create index strategic_priorities_current_idx on consulting_os.strategic_priorities(organization_id, logical_id, version_number desc);
create index goals_current_idx on consulting_os.goals(organization_id, logical_id, version_number desc);
create index goals_engagement_status_idx on consulting_os.goals(organization_id, engagement_id, status);
create index hypotheses_current_idx on consulting_os.value_hypotheses(organization_id, logical_id, version_number desc);
create index indicators_current_idx on consulting_os.indicators(organization_id, logical_id, version_number desc);
create index measurements_indicator_time_idx on consulting_os.measurements(organization_id, indicator_id, measured_at desc);
create index outcomes_goal_period_idx on consulting_os.outcomes(organization_id, goal_id, period_end desc);
create index evaluations_outcome_idx on consulting_os.value_evaluations(organization_id, outcome_id, evaluated_at desc);
create index learnings_evaluation_idx on consulting_os.learnings(organization_id, value_evaluation_id);
create index profiles_current_idx on consulting_os.emergent_organization_profiles(organization_id, logical_id, version_number desc);
create index differences_profile_idx on consulting_os.emergent_reality_differences(organization_id, emergent_profile_id, dimension);
create index organizational_story_links_object_idx on consulting_os.organizational_story_links(organization_id, domain_object_id);
create index baselines_time_idx on consulting_os.baseline_snapshots(organization_id, snapshot_at desc);

create unique index strategic_priorities_one_current_idx
  on consulting_os.strategic_priorities(organization_id, logical_id)
  where effective_to is null and status <> 'SUPERSEDED';
create unique index goals_one_current_idx
  on consulting_os.goals(organization_id, logical_id)
  where effective_to is null and status <> 'SUPERSEDED';
create unique index value_hypotheses_one_current_idx
  on consulting_os.value_hypotheses(organization_id, logical_id)
  where effective_to is null and status <> 'SUPERSEDED';
create unique index indicators_one_current_idx
  on consulting_os.indicators(organization_id, logical_id)
  where effective_to is null and status <> 'SUPERSEDED';
create unique index emergent_profiles_one_current_idx
  on consulting_os.emergent_organization_profiles(organization_id, logical_id)
  where effective_to is null and status <> 'SUPERSEDED';

create or replace function consulting_security.validate_phase7_typed_record()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_creator uuid;
  v_origin consulting_os.record_origin;
  v_registry_type text;
  v_registry_engagement uuid;
  v_expected_type text;
  v_new jsonb := to_jsonb(new);
begin
  v_expected_type := case tg_table_name
    when 'strategic_priorities' then 'STRATEGIC_PRIORITY'
    when 'goals' then 'GOAL'
    when 'value_hypotheses' then 'VALUE_HYPOTHESIS'
    when 'indicators' then 'INDICATOR'
    when 'measurements' then 'MEASUREMENT'
    when 'outcomes' then 'OUTCOME'
    when 'value_evaluations' then 'VALUE_EVALUATION'
    when 'learnings' then 'LEARNING'
    when 'outcome_decisions' then 'OUTCOME_DECISION'
    when 'emergent_organization_profiles' then 'EMERGENT_ORGANIZATION_PROFILE'
    when 'emergent_reality_differences' then 'EMERGENT_REALITY_DIFFERENCE'
    when 'organizational_stories' then 'ORGANIZATIONAL_STORY'
    when 'baseline_snapshots' then 'BASELINE_SNAPSHOT'
  end;

  select d.created_by, d.origin, d.object_type, d.engagement_id
    into v_creator, v_origin, v_registry_type, v_registry_engagement
  from consulting_os.domain_objects d
  where d.id = new.id and d.organization_id = new.organization_id;

  if v_creator is null or v_creator <> new.created_by or v_registry_type <> v_expected_type then
    raise exception 'Phase 7 typed record must match its domain registry creator and type'
      using errcode = '23514';
  end if;
  if v_new ? 'engagement_id'
    and v_registry_engagement is distinct from (v_new ->> 'engagement_id')::uuid
  then
    raise exception 'Phase 7 typed record must match its domain registry engagement'
      using errcode = '23514';
  end if;
  if v_expected_type in ('VALUE_EVALUATION','LEARNING','OUTCOME_DECISION','EMERGENT_ORGANIZATION_PROFILE','ORGANIZATIONAL_STORY','BASELINE_SNAPSHOT')
    and v_origin <> 'HUMAN'
  then
    raise exception '% requires explicit human origin', v_expected_type using errcode = '23514';
  end if;
  if v_expected_type = 'VALUE_EVALUATION' and (v_new ->> 'evaluated_by')::uuid <> new.created_by then
    raise exception 'Value Evaluation creator must be the human evaluator' using errcode = '23514';
  end if;
  if v_expected_type = 'OUTCOME_DECISION' and (v_new ->> 'authorized_by')::uuid <> new.created_by then
    raise exception 'Outcome Decision creator must be the authorizing human' using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_phase7_reference_visibility()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_new jsonb := to_jsonb(new);
  v_container_id uuid;
  v_refs uuid[] := array[]::uuid[];
  v_ref uuid;
  v_container_visibility consulting_os.visibility_scope;
  v_ref_visibility consulting_os.visibility_scope;
  v_ref_type text;
begin
  if tg_table_name = 'emergent_profile_members' then
    v_container_id := (v_new ->> 'profile_id')::uuid;
    v_refs := array[(v_new ->> 'domain_object_id')::uuid];
  elsif tg_table_name = 'organizational_story_links' then
    v_container_id := (v_new ->> 'organizational_story_id')::uuid;
    v_refs := array[(v_new ->> 'domain_object_id')::uuid];
  elsif tg_table_name = 'baseline_snapshot_members' then
    v_container_id := (v_new ->> 'baseline_snapshot_id')::uuid;
    v_refs := array[(v_new ->> 'domain_object_id')::uuid];
  else
    v_container_id := (v_new ->> 'id')::uuid;
    v_refs := case tg_table_name
      when 'strategic_priorities' then array[(v_new ->> 'owner_domain_object_id')::uuid]
      when 'goals' then array_remove(array[(v_new ->> 'strategic_priority_id')::uuid, (v_new ->> 'owner_domain_object_id')::uuid], null)
      when 'value_hypotheses' then array[(v_new ->> 'intervention_id')::uuid, (v_new ->> 'capability_id')::uuid]
      when 'indicators' then array_remove(array[(v_new ->> 'goal_id')::uuid, (v_new ->> 'value_hypothesis_id')::uuid], null)
      when 'measurements' then array[(v_new ->> 'indicator_id')::uuid, (v_new ->> 'primary_evidence_id')::uuid]
      when 'outcomes' then array[(v_new ->> 'goal_id')::uuid, (v_new ->> 'value_hypothesis_id')::uuid, (v_new ->> 'intervention_id')::uuid, (v_new ->> 'primary_measurement_id')::uuid, (v_new ->> 'primary_evidence_id')::uuid]
      when 'value_evaluations' then array[(v_new ->> 'outcome_id')::uuid, (v_new ->> 'value_hypothesis_id')::uuid]
      when 'learnings' then array[(v_new ->> 'value_evaluation_id')::uuid]
      when 'outcome_decisions' then array[(v_new ->> 'learning_id')::uuid]
      when 'emergent_organization_profiles' then array[(v_new ->> 'intended_future_state_id')::uuid]
      when 'emergent_reality_differences' then array[(v_new ->> 'intended_future_state_id')::uuid, (v_new ->> 'emergent_profile_id')::uuid]
      when 'baseline_snapshots' then array[(v_new ->> 'source_profile_id')::uuid]
      else array[]::uuid[]
    end;
  end if;

  select d.visibility_scope into v_container_visibility
  from consulting_os.domain_objects d
  where d.id = v_container_id and d.organization_id = new.organization_id;
  if v_container_visibility is null then
    raise exception 'Phase 7 composition container is missing' using errcode = '23503';
  end if;

  foreach v_ref in array coalesce(v_refs, array[]::uuid[]) loop
    select d.visibility_scope, d.object_type into v_ref_visibility, v_ref_type
    from consulting_os.domain_objects d
    where d.id = v_ref and d.organization_id = new.organization_id;
    if v_ref_visibility is null then
      raise exception 'Phase 7 referenced object must exist in the same organization' using errcode = '23503';
    end if;
    if not consulting_security.visibility_can_contain(v_container_visibility, v_ref_visibility) then
      raise exception 'Phase 7 composition cannot broaden referenced-object visibility' using errcode = '42501';
    end if;
    if (select auth.uid()) is not null and not consulting_security.can_read_domain_object(v_ref, new.organization_id) then
      raise exception 'Phase 7 composition requires readable referenced objects' using errcode = '42501';
    end if;
    if tg_table_name = 'emergent_profile_members'
      and ((v_new ->> 'captured_object_type') <> v_ref_type or (v_new ->> 'captured_visibility_scope') <> v_ref_visibility::text)
    then
      raise exception 'Emergent Profile member must preserve captured type and visibility' using errcode = '23514';
    end if;
    if tg_table_name = 'baseline_snapshot_members'
      and ((v_new ->> 'captured_object_type') <> v_ref_type or (v_new ->> 'captured_visibility_scope') <> v_ref_visibility::text)
    then
      raise exception 'Baseline member must preserve captured type and visibility' using errcode = '23514';
    end if;
    if tg_table_name = 'organizational_story_links'
      and (v_ref_type not in ('DECISION','OUTCOME') or (v_new ->> 'captured_object_type') <> v_ref_type or (v_new ->> 'captured_visibility_scope') <> v_ref_visibility::text or (v_new ->> 'link_role') <> v_ref_type)
    then
      raise exception 'Organizational Story links must preserve an eligible Decision or Outcome reference' using errcode = '23514';
    end if;
  end loop;
  return new;
end
$$;

create or replace function consulting_security.validate_phase7_value_cycle()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_indicator_goal uuid;
  v_indicator_hypothesis uuid;
  v_measurement_at timestamptz;
  v_hypothesis_effective timestamptz;
  v_hypothesis_created timestamptz;
  v_outcome_hypothesis uuid;
  v_outcome_created timestamptz;
  v_outcome_period_start timestamptz;
  v_profile_future_state uuid;
  v_profile_effective timestamptz;
  v_profile_status consulting_os.design_record_status;
  v_review_action consulting_os.epistemic_review_state;
  v_reviewer uuid;
  v_reviewed_at timestamptz;
begin
  if tg_table_name = 'outcomes' then
    select i.goal_id, i.value_hypothesis_id, m.measured_at
      into v_indicator_goal, v_indicator_hypothesis, v_measurement_at
    from consulting_os.measurements m
    join consulting_os.indicators i on i.id = m.indicator_id and i.organization_id = m.organization_id
    where m.id = new.primary_measurement_id and m.organization_id = new.organization_id;
    if (v_indicator_goal is not null and v_indicator_goal <> new.goal_id)
      or (v_indicator_hypothesis is not null and v_indicator_hypothesis <> new.value_hypothesis_id)
    then
      raise exception 'Outcome measurement must instantiate the linked Goal or Value Hypothesis Indicator' using errcode = '23514';
    end if;
    select h.effective_from, h.created_at into v_hypothesis_effective, v_hypothesis_created
    from consulting_os.value_hypotheses h
    where h.id = new.value_hypothesis_id and h.organization_id = new.organization_id;
    if v_hypothesis_effective > new.period_start or v_hypothesis_created > new.period_start then
      raise exception 'Value Hypothesis must exist prospectively before Outcome evaluation' using errcode = '23514';
    end if;
    if v_measurement_at > new.created_at then
      raise exception 'Outcome cannot precede its primary Measurement' using errcode = '23514';
    end if;
  elsif tg_table_name = 'value_evaluations' then
    select o.value_hypothesis_id, o.created_at, o.period_start
      into v_outcome_hypothesis, v_outcome_created, v_outcome_period_start
    from consulting_os.outcomes o
    where o.id = new.outcome_id and o.organization_id = new.organization_id;
    if v_outcome_hypothesis <> new.value_hypothesis_id or new.evaluated_at < v_outcome_created then
      raise exception 'Value Evaluation must follow and evaluate its linked Outcome and Value Hypothesis' using errcode = '23514';
    end if;
    select h.effective_from, h.created_at into v_hypothesis_effective, v_hypothesis_created
    from consulting_os.value_hypotheses h
    where h.id = new.value_hypothesis_id and h.organization_id = new.organization_id;
    if v_hypothesis_effective > v_outcome_period_start or v_hypothesis_created > new.evaluated_at then
      raise exception 'Value Hypothesis must predate Value Evaluation' using errcode = '23514';
    end if;
  elsif tg_table_name = 'outcome_decisions' then
    select r.review_action, r.reviewer_person_id, r.reviewed_at
      into v_review_action, v_reviewer, v_reviewed_at
    from consulting_os.record_reviews r
    where r.subject_id = new.learning_id and r.organization_id = new.organization_id
    order by r.reviewed_at desc, r.created_at desc
    limit 1;
    if v_review_action is distinct from 'VALIDATED' or v_reviewer <> new.authorized_by or new.decided_at < v_reviewed_at then
      raise exception 'Outcome Decision requires a prior validated Learning by the authorizing human' using errcode = '23514';
    end if;
  elsif tg_table_name = 'emergent_reality_differences' then
    select p.intended_future_state_id into v_profile_future_state
    from consulting_os.emergent_organization_profiles p
    where p.id = new.emergent_profile_id and p.organization_id = new.organization_id;
    if v_profile_future_state <> new.intended_future_state_id then
      raise exception 'Emergent Reality Difference must compare the Profile with its preserved Intended Future State' using errcode = '23514';
    end if;
  elsif tg_table_name = 'baseline_snapshots' then
    select p.effective_from, p.status into v_profile_effective, v_profile_status
    from consulting_os.emergent_organization_profiles p
    where p.id = new.source_profile_id and p.organization_id = new.organization_id;
    if v_profile_effective > new.snapshot_at or v_profile_status not in ('APPROVED','ACTIVE') then
      raise exception 'Baseline requires an approved effective Emergent Organization Profile' using errcode = '23514';
    end if;
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_phase7_causal_relationship()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.relationship_type = 'CONTRIBUTED_TO' then
    if new.origin <> 'HUMAN' or new.review_status is distinct from 'ACCEPTED'
      or new.validated_by is null or new.validated_at is null
      or length(btrim(coalesce(new.evidence_summary, ''))) = 0
    then
      raise exception 'CONTRIBUTED_TO requires an accepted human review and supporting evidence' using errcode = '23514';
    end if;
  elsif new.relationship_type = 'CAUSES' then
    if new.origin <> 'HUMAN' or new.review_status is distinct from 'ACCEPTED'
      or new.validated_by is null or new.validated_at is null
      or length(btrim(coalesce(new.evidence_summary, ''))) = 0
      or length(btrim(coalesce(new.alternative_explanations, ''))) = 0
      or length(btrim(coalesce(new.rationale, ''))) = 0
    then
      raise exception 'CAUSES is exceptional and requires accepted human validation, evidence, alternatives, and rationale' using errcode = '23514';
    end if;
  end if;
  if new.validated_by is not null and not exists (
    select 1 from consulting_os.organization_memberships m
    where m.organization_id = new.organization_id and m.person_id = new.validated_by and m.status = 'ACTIVE'
      and m.effective_from <= coalesce(new.validated_at, now())
      and (m.effective_to is null or m.effective_to > coalesce(new.validated_at, now()))
    union all
    select 1 from consulting_os.consultant_assignments a
    where a.organization_id = new.organization_id and a.consultant_person_id = new.validated_by and a.status = 'ACTIVE'
      and a.effective_from <= coalesce(new.validated_at, now())
      and (a.effective_to is null or a.effective_to > coalesce(new.validated_at, now()))
  ) then
    raise exception 'Relationship validator must be actively authorized for the organization' using errcode = '42501';
  end if;
  return new;
end
$$;

do $$ declare v_table text; begin
  foreach v_table in array array[
    'strategic_priorities','goals','value_hypotheses','indicators','measurements','outcomes','value_evaluations',
    'learnings','outcome_decisions','emergent_organization_profiles','emergent_reality_differences',
    'organizational_stories','baseline_snapshots'
  ] loop
    execute format('create trigger %I before insert on consulting_os.%I for each row execute function consulting_security.validate_phase7_typed_record()', v_table || '_phase7_typed', v_table);
  end loop;
end $$;

create or replace function consulting_security.snapshot_version_coordinates(
  p_domain_object_id uuid,
  p_organization_id uuid,
  p_object_type text
)
returns table (logical_id uuid, version_number integer)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_table text;
begin
  v_table := case p_object_type
    when 'ASSUMPTION' then 'assumptions'
    when 'IDENTITY_ELEMENT' then 'identity_elements'
    when 'ORGANIZATIONAL_DNA' then 'organizational_dna_versions'
    when 'FUTURE_STATE_NARRATIVE' then 'future_state_narratives'
    when 'FUTURE_STATE_PRINCIPLE' then 'future_state_principles'
    when 'FUTURE_STATE' then 'future_states'
    when 'ORGANIZATIONAL_BLUEPRINT' then 'organizational_blueprints'
    when 'ROLE' then 'roles'
    when 'DESIGN_PRINCIPLE' then 'design_principles'
    when 'RESPONSIBILITY' then 'responsibilities'
    when 'AUTHORITY' then 'authorities'
    when 'BOUNDARY' then 'boundaries'
    when 'INTERFACE' then 'interfaces'
    when 'WORKFLOW' then 'workflow_versions'
    when 'CAPABILITY' then 'capabilities'
    when 'STRATEGIC_PRIORITY' then 'strategic_priorities'
    when 'GOAL' then 'goals'
    when 'VALUE_HYPOTHESIS' then 'value_hypotheses'
    when 'INDICATOR' then 'indicators'
    when 'EMERGENT_ORGANIZATION_PROFILE' then 'emergent_organization_profiles'
    else null
  end;

  if v_table is null then
    return;
  end if;

  return query execute format(
    'select logical_id, version_number from consulting_os.%I where id = $1 and organization_id = $2',
    v_table
  ) using p_domain_object_id, p_organization_id;
end
$$;

create or replace function consulting_os.create_baseline_snapshot(
  p_source_profile_id uuid,
  p_snapshot_at timestamptz,
  p_scope text,
  p_rationale text,
  p_next_engagement_id uuid default null,
  p_member_ids uuid[] default array[]::uuid[],
  p_member_roles text[] default array[]::text[],
  p_member_labels text[] default array[]::text[]
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := consulting_security.current_person_id();
  v_profile consulting_os.emergent_organization_profiles%rowtype;
  v_profile_registry consulting_os.domain_objects%rowtype;
  v_member consulting_os.domain_objects%rowtype;
  v_baseline_id uuid := gen_random_uuid();
  v_relationship_id uuid := gen_random_uuid();
  v_logical_id uuid;
  v_version_number integer;
  v_index integer;
begin
  if v_actor is null then
    raise exception 'an authenticated human is required to establish a baseline' using errcode = '42501';
  end if;
  if p_snapshot_at is null or p_snapshot_at > now() then
    raise exception 'baseline snapshot time must be present and cannot be in the future' using errcode = '22007';
  end if;
  if nullif(btrim(p_scope), '') is null or nullif(btrim(p_rationale), '') is null then
    raise exception 'baseline scope and rationale are required' using errcode = '23514';
  end if;
  if cardinality(p_member_ids) <> cardinality(p_member_roles)
    or cardinality(p_member_ids) <> cardinality(p_member_labels) then
    raise exception 'baseline member ids, roles, and labels must have equal cardinality' using errcode = '2202E';
  end if;

  select * into v_profile
  from consulting_os.emergent_organization_profiles
  where id = p_source_profile_id;
  if not found or v_profile.status not in ('APPROVED', 'ACTIVE')
    or v_profile.effective_from > p_snapshot_at
    or (v_profile.effective_to is not null and v_profile.effective_to <= p_snapshot_at) then
    raise exception 'an approved, effective Emergent Organization Profile is required' using errcode = '23514';
  end if;

  select * into v_profile_registry
  from consulting_os.domain_objects
  where id = p_source_profile_id and organization_id = v_profile.organization_id;
  if v_profile_registry.origin <> 'HUMAN'
    or not consulting_security.can_manage_domain_object(p_source_profile_id, v_profile.organization_id) then
    raise exception 'profile management permission is required to establish a baseline' using errcode = '42501';
  end if;

  if p_next_engagement_id is not null and not exists (
    select 1 from consulting_os.engagements e
    where e.id = p_next_engagement_id and e.organization_id = v_profile.organization_id
  ) then
    raise exception 'next engagement must belong to the same organization' using errcode = '23514';
  end if;

  insert into consulting_os.domain_objects (
    id, organization_id, engagement_id, object_type, visibility_scope,
    owner_person_id, origin, created_by
  ) values (
    v_baseline_id, v_profile.organization_id, v_profile.engagement_id,
    'BASELINE_SNAPSHOT', v_profile_registry.visibility_scope,
    v_profile_registry.owner_person_id, 'HUMAN', v_actor
  );

  insert into consulting_os.baseline_snapshots (
    id, organization_id, engagement_id, source_profile_id, next_engagement_id,
    snapshot_at, scope, rationale, created_by
  ) values (
    v_baseline_id, v_profile.organization_id, v_profile.engagement_id,
    p_source_profile_id, p_next_engagement_id, p_snapshot_at,
    btrim(p_scope), btrim(p_rationale), v_actor
  );

  insert into consulting_os.baseline_snapshot_members (
    organization_id, baseline_snapshot_id, domain_object_id,
    captured_object_type, captured_visibility_scope, captured_logical_id,
    captured_version_number, member_role, label, created_by
  ) values (
    v_profile.organization_id, v_baseline_id, p_source_profile_id,
    v_profile_registry.object_type, v_profile_registry.visibility_scope,
    v_profile.logical_id, v_profile.version_number, 'SOURCE_PROFILE',
    v_profile.name, v_actor
  );

  if cardinality(p_member_ids) > 0 then
    for v_index in 1..cardinality(p_member_ids) loop
      if nullif(btrim(p_member_roles[v_index]), '') is null
        or p_member_roles[v_index] !~ '^[A-Z][A-Z0-9_]*$'
        or nullif(btrim(p_member_labels[v_index]), '') is null then
        raise exception 'each baseline member requires a controlled role and label' using errcode = '23514';
      end if;

      select * into v_member
      from consulting_os.domain_objects
      where id = p_member_ids[v_index] and organization_id = v_profile.organization_id;
      if not found
        or not consulting_security.can_read_domain_object(v_member.id, v_member.organization_id)
        or not consulting_security.visibility_can_contain(v_profile_registry.visibility_scope, v_member.visibility_scope) then
        raise exception 'baseline member is unavailable or exceeds the baseline visibility boundary' using errcode = '42501';
      end if;

      select c.logical_id, c.version_number into v_logical_id, v_version_number
      from consulting_security.snapshot_version_coordinates(
        v_member.id, v_member.organization_id, v_member.object_type
      ) c;

      insert into consulting_os.baseline_snapshot_members (
        organization_id, baseline_snapshot_id, domain_object_id,
        captured_object_type, captured_visibility_scope, captured_logical_id,
        captured_version_number, member_role, label, created_by
      ) values (
        v_profile.organization_id, v_baseline_id, v_member.id,
        v_member.object_type, v_member.visibility_scope, v_logical_id,
        v_version_number, p_member_roles[v_index], btrim(p_member_labels[v_index]), v_actor
      );
    end loop;
  end if;

  insert into consulting_os.entity_relationships (
    id, organization_id, engagement_id, relationship_type,
    source_type, source_id, target_type, target_id, origin, review_status,
    rationale, evidence_summary, validated_by, validated_at, created_by, effective_from
  ) values (
    v_relationship_id, v_profile.organization_id, v_profile.engagement_id,
    'BECOMES_BASELINE_FOR', 'EMERGENT_ORGANIZATION_PROFILE', p_source_profile_id,
    'BASELINE_SNAPSHOT', v_baseline_id, 'HUMAN', 'ACCEPTED', btrim(p_rationale),
    'The immutable manifest captures the approved profile and selected visible source records.',
    v_actor, p_snapshot_at, v_actor, p_snapshot_at
  );

  insert into consulting_os.audit_events (
    organization_id, actor_person_id, event_type, target_table,
    target_id, operation, reason, metadata
  ) values (
    v_profile.organization_id, v_actor, 'BASELINE_SNAPSHOT_CREATED',
    'consulting_os.baseline_snapshots', v_baseline_id, 'INSERT', btrim(p_rationale),
    jsonb_build_object(
      'source_profile_id', p_source_profile_id,
      'next_engagement_id', p_next_engagement_id,
      'member_count', cardinality(p_member_ids) + 1,
      'snapshot_at', p_snapshot_at
    )
  );

  return v_baseline_id;
end
$$;

revoke all on function consulting_security.snapshot_version_coordinates(uuid, uuid, text)
  from public, anon, authenticated, service_role;
revoke all on function consulting_os.create_baseline_snapshot(
  uuid, timestamptz, text, text, uuid, uuid[], text[], text[]
) from public, anon, authenticated, service_role;
grant execute on function consulting_os.create_baseline_snapshot(
  uuid, timestamptz, text, text, uuid, uuid[], text[], text[]
) to authenticated;

comment on function consulting_os.create_baseline_snapshot(
  uuid, timestamptz, text, text, uuid, uuid[], text[], text[]
) is 'Atomically freezes an approved human profile and selected visibility-compatible records into an immutable tenant-bound baseline.';

create or replace view consulting_os.current_strategic_priorities with (security_invoker = true) as
select p.*
from consulting_os.strategic_priorities p
where p.effective_from <= now()
  and (p.effective_to is null or p.effective_to > now())
  and p.status in ('APPROVED','ACTIVE')
  and not exists (
    select 1 from consulting_os.strategic_priorities newer
    where newer.organization_id = p.organization_id
      and newer.logical_id = p.logical_id
      and newer.version_number > p.version_number
      and newer.effective_from <= now()
      and newer.status in ('APPROVED','ACTIVE')
  );

create or replace view consulting_os.current_goals with (security_invoker = true) as
select g.*
from consulting_os.goals g
where g.effective_from <= now()
  and (g.effective_to is null or g.effective_to > now())
  and g.status in ('ACTIVE','ACHIEVED','MISSED')
  and not exists (
    select 1 from consulting_os.goals newer
    where newer.organization_id = g.organization_id
      and newer.logical_id = g.logical_id
      and newer.version_number > g.version_number
      and newer.effective_from <= now()
      and newer.status <> 'SUPERSEDED'
  );

create or replace view consulting_os.current_value_hypotheses with (security_invoker = true) as
select h.*
from consulting_os.value_hypotheses h
where h.effective_from <= now()
  and (h.effective_to is null or h.effective_to > now())
  and h.status <> 'SUPERSEDED'
  and not exists (
    select 1 from consulting_os.value_hypotheses newer
    where newer.organization_id = h.organization_id
      and newer.logical_id = h.logical_id
      and newer.version_number > h.version_number
      and newer.effective_from <= now()
      and newer.status <> 'SUPERSEDED'
  );

create or replace view consulting_os.current_indicators with (security_invoker = true) as
select i.*
from consulting_os.indicators i
where i.effective_from <= now()
  and (i.effective_to is null or i.effective_to > now())
  and i.status in ('APPROVED','ACTIVE')
  and not exists (
    select 1 from consulting_os.indicators newer
    where newer.organization_id = i.organization_id
      and newer.logical_id = i.logical_id
      and newer.version_number > i.version_number
      and newer.effective_from <= now()
      and newer.status in ('APPROVED','ACTIVE')
  );

create or replace view consulting_os.current_emergent_organization_profiles with (security_invoker = true) as
select p.*
from consulting_os.emergent_organization_profiles p
where p.effective_from <= now()
  and (p.effective_to is null or p.effective_to > now())
  and p.status in ('APPROVED','ACTIVE')
  and not exists (
    select 1 from consulting_os.emergent_organization_profiles newer
    where newer.organization_id = p.organization_id
      and newer.logical_id = p.logical_id
      and newer.version_number > p.version_number
      and newer.effective_from <= now()
      and newer.status in ('APPROVED','ACTIVE')
  );

create or replace view consulting_os.value_outcome_pathways with (security_invoker = true) as
select
  o.organization_id,
  o.engagement_id,
  g.id as goal_id,
  g.statement as goal_statement,
  g.baseline_value,
  g.baseline_at,
  g.target_value,
  g.target_at,
  h.id as value_hypothesis_id,
  h.expected_value,
  h.change_condition,
  h.capability_condition,
  h.value_dimensions,
  i.id as indicator_id,
  i.name as indicator_name,
  i.definition as indicator_definition,
  i.direction as indicator_direction,
  m.id as measurement_id,
  m.display_value as measurement_value,
  m.measured_at,
  m.period_start as measurement_period_start,
  m.period_end as measurement_period_end,
  o.id as outcome_id,
  o.statement as outcome_statement,
  o.observed_value,
  o.unexpected,
  o.interpretation_status,
  ve.id as value_evaluation_id,
  ve.harvest_finding,
  ve.soil_finding,
  ve.mission_rating,
  ve.human_rating,
  ve.operational_rating,
  ve.economic_rating,
  ve.sustainable_rating,
  ve.significance,
  l.id as learning_id,
  l.statement as learning_statement,
  rr.review_action as learning_review_state,
  od.id as outcome_decision_id,
  od.disposition,
  od.next_action
from consulting_os.outcomes o
join consulting_os.goals g
  on g.id = o.goal_id and g.organization_id = o.organization_id
join consulting_os.value_hypotheses h
  on h.id = o.value_hypothesis_id and h.organization_id = o.organization_id
join consulting_os.measurements m
  on m.id = o.primary_measurement_id and m.organization_id = o.organization_id
join consulting_os.indicators i
  on i.id = m.indicator_id and i.organization_id = o.organization_id
left join lateral (
  select candidate.*
  from consulting_os.value_evaluations candidate
  where candidate.outcome_id = o.id and candidate.organization_id = o.organization_id
  order by candidate.evaluated_at desc, candidate.created_at desc
  limit 1
) ve on true
left join lateral (
  select candidate.*
  from consulting_os.learnings candidate
  where candidate.value_evaluation_id = ve.id and candidate.organization_id = o.organization_id
  order by candidate.created_at desc
  limit 1
) l on true
left join consulting_os.latest_record_reviews rr
  on rr.subject_id = l.id and rr.organization_id = l.organization_id
left join lateral (
  select candidate.*
  from consulting_os.outcome_decisions candidate
  where candidate.learning_id = l.id and candidate.organization_id = o.organization_id
  order by candidate.decided_at desc, candidate.created_at desc
  limit 1
) od on true;

create or replace view consulting_os.client_progress with (security_invoker = true) as
select g.organization_id, g.engagement_id, 'GOAL'::text as item_type, g.id,
  'Goal'::text as title, g.statement as summary, g.status::text as status,
  g.effective_from as occurred_at, 10 as display_order
from consulting_os.current_goals g
join consulting_os.domain_objects d on d.id = g.id and d.organization_id = g.organization_id
where d.visibility_scope in ('TEAM_SHARED','LEADERSHIP_RESTRICTED','ENGAGEMENT_SHARED','ORGANIZATION_SHARED')
union all
select o.organization_id, o.engagement_id, 'OUTCOME', o.id,
  'Outcome', o.statement, o.interpretation_status::text, o.created_at, 20
from consulting_os.outcomes o
join consulting_os.domain_objects d on d.id = o.id and d.organization_id = o.organization_id
where o.interpretation_status = 'REVIEWED'
  and d.visibility_scope in ('TEAM_SHARED','LEADERSHIP_RESTRICTED','ENGAGEMENT_SHARED','ORGANIZATION_SHARED')
union all
select ve.organization_id, ve.engagement_id, 'HARVEST_SOIL', ve.id,
  'Harvest & Soil', 'Harvest: ' || ve.harvest_finding || ' Soil: ' || ve.soil_finding,
  'REVIEWED', ve.evaluated_at, 30
from consulting_os.value_evaluations ve
join consulting_os.outcomes o on o.id = ve.outcome_id and o.organization_id = ve.organization_id
join consulting_os.domain_objects d on d.id = ve.id and d.organization_id = ve.organization_id
where o.interpretation_status = 'REVIEWED'
  and d.visibility_scope in ('TEAM_SHARED','LEADERSHIP_RESTRICTED','ENGAGEMENT_SHARED','ORGANIZATION_SHARED')
union all
select l.organization_id, l.engagement_id, 'LEARNING', l.id,
  'Learning', l.statement, rr.review_action::text, rr.reviewed_at, 40
from consulting_os.learnings l
join consulting_os.latest_record_reviews rr on rr.subject_id = l.id and rr.organization_id = l.organization_id
join consulting_os.domain_objects d on d.id = l.id and d.organization_id = l.organization_id
where rr.review_action = 'VALIDATED'
  and d.visibility_scope in ('TEAM_SHARED','LEADERSHIP_RESTRICTED','ENGAGEMENT_SHARED','ORGANIZATION_SHARED')
union all
select p.organization_id, p.engagement_id, 'NEW_REALITY', p.id,
  p.name, p.value_state, p.status::text, p.effective_from, 50
from consulting_os.current_emergent_organization_profiles p
join consulting_os.domain_objects d on d.id = p.id and d.organization_id = p.organization_id
where d.visibility_scope in ('TEAM_SHARED','LEADERSHIP_RESTRICTED','ENGAGEMENT_SHARED','ORGANIZATION_SHARED')
union all
select b.organization_id, b.engagement_id, 'BASELINE', b.id,
  'New baseline', b.scope, 'IMMUTABLE', b.snapshot_at, 60
from consulting_os.baseline_snapshots b
join consulting_os.domain_objects d on d.id = b.id and d.organization_id = b.organization_id
where d.visibility_scope in ('TEAM_SHARED','LEADERSHIP_RESTRICTED','ENGAGEMENT_SHARED','ORGANIZATION_SHARED');

create or replace view consulting_os.current_baselines with (security_invoker = true) as
select
  b.id,
  b.organization_id,
  b.engagement_id,
  b.source_profile_id,
  p.name as source_profile_name,
  b.next_engagement_id,
  b.snapshot_at,
  b.scope,
  b.rationale,
  coalesce((
    select jsonb_agg(jsonb_build_object(
      'domain_object_id', m.domain_object_id,
      'object_type', m.captured_object_type,
      'visibility_scope', m.captured_visibility_scope,
      'logical_id', m.captured_logical_id,
      'version_number', m.captured_version_number,
      'member_role', m.member_role,
      'label', m.label
    ) order by m.member_role, m.label)
    from consulting_os.baseline_snapshot_members m
    where m.baseline_snapshot_id = b.id and m.organization_id = b.organization_id
  ), '[]'::jsonb) as manifest
from consulting_os.baseline_snapshots b
join consulting_os.emergent_organization_profiles p
  on p.id = b.source_profile_id and p.organization_id = b.organization_id;

revoke all on consulting_os.current_strategic_priorities, consulting_os.current_goals,
  consulting_os.current_value_hypotheses, consulting_os.current_indicators,
  consulting_os.current_emergent_organization_profiles, consulting_os.value_outcome_pathways,
  consulting_os.client_progress, consulting_os.current_baselines
from public, anon;
grant select on consulting_os.current_strategic_priorities, consulting_os.current_goals,
  consulting_os.current_value_hypotheses, consulting_os.current_indicators,
  consulting_os.current_emergent_organization_profiles, consulting_os.value_outcome_pathways,
  consulting_os.client_progress, consulting_os.current_baselines
to authenticated, service_role;

do $$ declare v_table text; begin
  foreach v_table in array array[
    'strategic_priorities','goals','value_hypotheses','indicators','measurements','outcomes','value_evaluations',
    'learnings','outcome_decisions','emergent_organization_profiles','emergent_reality_differences',
    'baseline_snapshots','emergent_profile_members','organizational_story_links','baseline_snapshot_members'
  ] loop
    execute format('create trigger %I before insert or update on consulting_os.%I for each row execute function consulting_security.validate_phase7_reference_visibility()', v_table || '_phase7_visibility', v_table);
  end loop;
end $$;

do $$ declare v_table text; begin
  foreach v_table in array array['strategic_priorities','goals','value_hypotheses','indicators','emergent_organization_profiles'] loop
    execute format('create trigger %I before insert on consulting_os.%I for each row execute function consulting_security.validate_version_chain()', v_table || '_phase7_version_chain', v_table);
    execute format('create trigger %I before update or delete on consulting_os.%I for each row execute function consulting_security.prevent_versioned_mutation()', v_table || '_phase7_immutable', v_table);
  end loop;
end $$;

do $$ declare v_table text; begin
  foreach v_table in array array[
    'measurements','outcomes','value_evaluations','learnings','outcome_decisions','emergent_profile_members',
    'emergent_reality_differences','organizational_stories','organizational_story_links','baseline_snapshots','baseline_snapshot_members'
  ] loop
    execute format('create trigger %I before update or delete on consulting_os.%I for each row execute function consulting_security.prevent_append_only_mutation()', v_table || '_phase7_append_only', v_table);
  end loop;
end $$;

create trigger outcomes_phase7_value_cycle before insert on consulting_os.outcomes
for each row execute function consulting_security.validate_phase7_value_cycle();
create trigger value_evaluations_phase7_value_cycle before insert on consulting_os.value_evaluations
for each row execute function consulting_security.validate_phase7_value_cycle();
create trigger outcome_decisions_phase7_value_cycle before insert on consulting_os.outcome_decisions
for each row execute function consulting_security.validate_phase7_value_cycle();
create trigger emergent_differences_phase7_value_cycle before insert on consulting_os.emergent_reality_differences
for each row execute function consulting_security.validate_phase7_value_cycle();
create trigger baseline_snapshots_phase7_value_cycle before insert on consulting_os.baseline_snapshots
for each row execute function consulting_security.validate_phase7_value_cycle();
create trigger entity_relationships_phase7_causality before insert or update on consulting_os.entity_relationships
for each row execute function consulting_security.validate_phase7_causal_relationship();

insert into consulting_security.relationship_type_rules
  (relationship_type, source_type, target_type, rationale)
values
  ('SUPPORTED_BY','OUTCOME','EVIDENCE','Observed Outcome is supported by inspectable Evidence.'),
  ('MEASURED_BY','GOAL','INDICATOR','Goal is evaluated through a selected Indicator.'),
  ('MEASURED_BY','VALUE_HYPOTHESIS','INDICATOR','Value Hypothesis is evaluated through a selected Indicator.'),
  ('MEASURES','MEASUREMENT','INDICATOR','Measurement instantiates an Indicator for a period.'),
  ('EVALUATES','OUTCOME','GOAL','Outcome evaluates progress relative to a Goal without asserting causation.'),
  ('EVALUATES','OUTCOME','VALUE_HYPOTHESIS','Outcome evaluates the prospective Value Hypothesis.'),
  ('EVALUATES','OUTCOME','REINVENTION_INITIATIVE','Outcome is compared with an Intervention without asserting cause.'),
  ('EVALUATES','VALUE_EVALUATION','GOAL','Human Value Evaluation assesses Goal significance.'),
  ('EVALUATES','VALUE_EVALUATION','VALUE_HYPOTHESIS','Human Value Evaluation assesses the prospective hypothesis.'),
  ('EVALUATES','VALUE_EVALUATION','REINVENTION_INITIATIVE','Human Value Evaluation assesses the Intervention context.'),
  ('CONTRIBUTED_TO','REINVENTION_INITIATIVE','OUTCOME','Human-reviewed contribution claim, weaker than sole causation.'),
  ('CONTRIBUTED_TO','CAPABILITY','OUTCOME','Human-reviewed capability contribution claim.'),
  ('CONTRIBUTED_TO','DECISION','OUTCOME','Human-reviewed Decision contribution claim.'),
  ('CAUSES','REINVENTION_INITIATIVE','OUTCOME','Exceptional human-validated causal assertion.'),
  ('CAUSES','CAPABILITY','OUTCOME','Exceptional human-validated causal assertion.'),
  ('CAUSES','DECISION','OUTCOME','Exceptional human-validated causal assertion.'),
  ('BECOMES_BASELINE_FOR','EMERGENT_ORGANIZATION_PROFILE','BASELINE_SNAPSHOT','Approved Emergent Organization Profile is preserved as the next immutable Baseline.'),
  ('DERIVED_FROM','EMERGENT_ORGANIZATION_PROFILE','OUTCOME','Emergent Profile incorporates observed Outcome evidence.'),
  ('DERIVED_FROM','EMERGENT_ORGANIZATION_PROFILE','LEARNING','Emergent Profile incorporates human-reviewed Learning.'),
  ('DERIVED_FROM','ORGANIZATIONAL_STORY','DECISION','Organizational Story preserves a Decision from this chapter.'),
  ('DERIVED_FROM','ORGANIZATIONAL_STORY','OUTCOME','Organizational Story preserves an Outcome from this chapter.');

alter table consulting_os.strategic_priorities enable row level security;
alter table consulting_os.goals enable row level security;
alter table consulting_os.value_hypotheses enable row level security;
alter table consulting_os.indicators enable row level security;
alter table consulting_os.measurements enable row level security;
alter table consulting_os.outcomes enable row level security;
alter table consulting_os.value_evaluations enable row level security;
alter table consulting_os.learnings enable row level security;
alter table consulting_os.outcome_decisions enable row level security;
alter table consulting_os.emergent_organization_profiles enable row level security;
alter table consulting_os.emergent_profile_members enable row level security;
alter table consulting_os.emergent_reality_differences enable row level security;
alter table consulting_os.organizational_stories enable row level security;
alter table consulting_os.organizational_story_links enable row level security;
alter table consulting_os.baseline_snapshots enable row level security;
alter table consulting_os.baseline_snapshot_members enable row level security;

do $$ declare v_table text; begin
  foreach v_table in array array[
    'strategic_priorities','goals','value_hypotheses','indicators','measurements','outcomes','value_evaluations',
    'learnings','outcome_decisions','emergent_organization_profiles','emergent_reality_differences',
    'organizational_stories'
  ] loop
    execute format(
      'create policy %I on consulting_os.%I for select to authenticated using (consulting_security.can_read_domain_object(id, organization_id))',
      v_table || '_select_visible', v_table
    );
    execute format(
      'create policy %I on consulting_os.%I for insert to authenticated with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(id, organization_id))',
      v_table || '_insert_authorized', v_table
    );
  end loop;
end $$;

create policy baseline_snapshots_select_visible on consulting_os.baseline_snapshots
for select to authenticated
using (consulting_security.can_read_domain_object(id, organization_id));

create policy emergent_profile_members_select_visible on consulting_os.emergent_profile_members
for select to authenticated
using (
  consulting_security.can_read_domain_object(profile_id, organization_id)
  and consulting_security.can_read_domain_object(domain_object_id, organization_id)
);
create policy emergent_profile_members_insert_authorized on consulting_os.emergent_profile_members
for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(profile_id, organization_id)
  and consulting_security.can_read_domain_object(domain_object_id, organization_id)
);

create policy organizational_story_links_select_visible on consulting_os.organizational_story_links
for select to authenticated
using (
  consulting_security.can_read_domain_object(organizational_story_id, organization_id)
  and consulting_security.can_read_domain_object(domain_object_id, organization_id)
);
create policy organizational_story_links_insert_authorized on consulting_os.organizational_story_links
for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(organizational_story_id, organization_id)
  and consulting_security.can_read_domain_object(domain_object_id, organization_id)
);

create policy baseline_snapshot_members_select_visible on consulting_os.baseline_snapshot_members
for select to authenticated
using (
  consulting_security.can_read_domain_object(baseline_snapshot_id, organization_id)
  and consulting_security.can_read_domain_object(domain_object_id, organization_id)
);

do $$ declare v_table text; begin
  foreach v_table in array array[
    'strategic_priorities','goals','value_hypotheses','indicators','measurements','outcomes','value_evaluations',
    'learnings','outcome_decisions','emergent_organization_profiles','emergent_reality_differences',
    'organizational_stories','emergent_profile_members','organizational_story_links'
  ] loop
    execute format('revoke all on consulting_os.%I from public, anon, authenticated', v_table);
    execute format('grant select, insert on consulting_os.%I to authenticated', v_table);
    execute format('grant all on consulting_os.%I to service_role', v_table);
  end loop;
  foreach v_table in array array['baseline_snapshots','baseline_snapshot_members'] loop
    execute format('revoke all on consulting_os.%I from public, anon, authenticated', v_table);
    execute format('grant select on consulting_os.%I to authenticated', v_table);
    execute format('grant all on consulting_os.%I to service_role', v_table);
  end loop;
end $$;
