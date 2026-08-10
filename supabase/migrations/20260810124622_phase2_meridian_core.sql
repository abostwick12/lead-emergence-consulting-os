-- Lead Emergence Consulting OS — Phase 2 Meridian Core
-- Additive migration. Never apply to a hosted target without a separate environment decision.

create type consulting_os.epistemic_review_state as enum (
  'DRAFT', 'SUGGESTED', 'UNDER_REVIEW', 'ACCEPTED',
  'VALIDATED', 'CHALLENGED', 'REJECTED', 'SUPERSEDED'
);
create type consulting_os.evidence_source_type as enum (
  'UPLOADED_DOCUMENT', 'INTERVIEW', 'MEETING', 'ASSESSMENT',
  'METRIC_SYSTEM', 'CONSULTANT_OBSERVATION', 'CLIENT_STATEMENT', 'OTHER'
);
create type consulting_os.observation_type as enum (
  'DIRECT_MEASUREMENT', 'DIRECT_OBSERVATION',
  'STAKEHOLDER_REPORT', 'EXTRACTED_SOURCE_STATEMENT'
);
create type consulting_os.confidence_level as enum ('NOT_ASSESSED', 'LOW', 'MODERATE', 'HIGH');
create type consulting_os.assumption_status as enum (
  'UNTESTED', 'SUPPORTED', 'CHALLENGED', 'DISPROVEN', 'SUPERSEDED'
);
create type consulting_os.hypothesis_status as enum (
  'PROPOSED', 'TESTING', 'SUPPORTED', 'PARTIALLY_SUPPORTED', 'UNSUPPORTED', 'SUPERSEDED'
);
create type consulting_os.decision_status as enum (
  'PROPOSED', 'APPROVED', 'ACTIVE', 'RECONSIDER', 'SUPERSEDED', 'RETIRED'
);
create type consulting_os.citation_role as enum ('SUPPORTING', 'CHALLENGING', 'CONTEXT');

alter table consulting_os.domain_objects
  add constraint domain_objects_typed_identity_key unique (id, organization_id, object_type);

create table consulting_os.evidence_sources (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('EVIDENCE_SOURCE'::text) stored,
  source_type consulting_os.evidence_source_type not null,
  title text not null check (length(btrim(title)) > 0),
  external_reference text,
  source_actor_person_id uuid references consulting_os.people(id) on delete restrict,
  source_system text,
  captured_at timestamptz not null,
  provenance_context text not null check (length(btrim(provenance_context)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.evidence_fragments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  evidence_source_id uuid not null,
  locator_kind text not null check (locator_kind ~ '^[A-Z][A-Z0-9_]*$'),
  locator jsonb not null check (jsonb_typeof(locator) = 'object'),
  content_text text not null check (length(content_text) > 0),
  content_sha256 text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  captured_context text,
  directness consulting_os.confidence_level not null default 'NOT_ASSESSED',
  recency consulting_os.confidence_level not null default 'NOT_ASSESSED',
  relevance consulting_os.confidence_level not null default 'NOT_ASSESSED',
  coverage consulting_os.confidence_level not null default 'NOT_ASSESSED',
  source_reliability consulting_os.confidence_level not null default 'NOT_ASSESSED',
  context_completeness consulting_os.confidence_level not null default 'NOT_ASSESSED',
  quality_rationale text,
  corrects_fragment_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (evidence_source_id, organization_id)
    references consulting_os.evidence_sources(id, organization_id) on delete restrict,
  foreign key (corrects_fragment_id, organization_id)
    references consulting_os.evidence_fragments(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (corrects_fragment_id is null or corrects_fragment_id <> id)
);

create table consulting_os.evidence_items (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('EVIDENCE'::text) stored,
  primary_fragment_id uuid not null,
  evidence_type text not null check (evidence_type ~ '^[A-Z][A-Z0-9_]*$'),
  relevance_note text not null check (length(btrim(relevance_note)) > 0),
  limitations text,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (primary_fragment_id, organization_id)
    references consulting_os.evidence_fragments(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.observations (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('OBSERVATION'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  observation_type consulting_os.observation_type not null,
  observed_at timestamptz not null,
  context text not null check (length(btrim(context)) > 0),
  primary_evidence_id uuid not null,
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  corrects_observation_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (primary_evidence_id, organization_id)
    references consulting_os.evidence_items(id, organization_id) on delete restrict,
  foreign key (corrects_observation_id, organization_id)
    references consulting_os.observations(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (corrects_observation_id is null or corrects_observation_id <> id)
);

create table consulting_os.patterns (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('PATTERN'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  scope text not null check (length(btrim(scope)) > 0),
  recurrence_basis text not null check (length(btrim(recurrence_basis)) > 0),
  contrary_evidence_summary text,
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.assumptions (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('ASSUMPTION'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  statement text not null check (length(btrim(statement)) > 0),
  holder_scope text not null check (length(btrim(holder_scope)) > 0),
  origin_history text,
  assumption_status consulting_os.assumption_status not null default 'UNTESTED',
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  confidence_level consulting_os.confidence_level not null default 'NOT_ASSESSED',
  confidence_rationale text,
  review_trigger text not null check (length(btrim(review_trigger)) > 0),
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (supersedes_id, organization_id)
    references consulting_os.assumptions(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check (
    (version_number = 1 and supersedes_id is null)
    or (version_number > 1 and supersedes_id is not null)
  )
);
create unique index assumptions_one_current_version_idx
  on consulting_os.assumptions(organization_id, logical_id)
  where effective_to is null and assumption_status <> 'SUPERSEDED';

create table consulting_os.hypotheses (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('HYPOTHESIS'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  test_criteria text not null check (length(btrim(test_criteria)) > 0),
  strengthening_evidence text not null check (length(btrim(strengthening_evidence)) > 0),
  weakening_evidence text not null check (length(btrim(weakening_evidence)) > 0),
  hypothesis_status consulting_os.hypothesis_status not null default 'PROPOSED',
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.interpretations (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('INTERPRETATION'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  scope text not null check (length(btrim(scope)) > 0),
  limitations text,
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.insights (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('INSIGHT'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  rationale text not null check (length(btrim(rationale)) > 0),
  limitations text not null check (length(btrim(limitations)) > 0),
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.decisions (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('DECISION'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  authority_person_id uuid not null references consulting_os.people(id) on delete restrict,
  rationale text not null check (length(btrim(rationale)) > 0),
  intended_effect text not null check (length(btrim(intended_effect)) > 0),
  review_trigger text not null check (length(btrim(review_trigger)) > 0),
  decision_status consulting_os.decision_status not null default 'PROPOSED',
  decided_at timestamptz not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.decision_alternatives (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  decision_id uuid not null,
  statement text not null check (length(btrim(statement)) > 0),
  disposition text not null check (length(btrim(disposition)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (decision_id, organization_id)
    references consulting_os.decisions(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.record_reviews (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('RECORD_REVIEW'::text) stored,
  subject_id uuid not null,
  review_action consulting_os.epistemic_review_state not null,
  reviewer_person_id uuid not null references consulting_os.people(id) on delete restrict,
  rationale text not null check (length(btrim(rationale)) > 0),
  evidence_considered text,
  contrary_evidence text,
  limitations text,
  dissent text,
  prior_review_id uuid,
  reviewed_at timestamptz not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (subject_id, organization_id)
    references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (prior_review_id, organization_id)
    references consulting_os.record_reviews(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (review_action <> 'DRAFT'),
  check (
    review_action <> 'VALIDATED'
    or (
      length(btrim(coalesce(evidence_considered, ''))) > 0
      and length(btrim(coalesce(contrary_evidence, ''))) > 0
      and length(btrim(coalesce(limitations, ''))) > 0
    )
  )
);

create table consulting_os.claim_citations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  claim_id uuid not null,
  evidence_fragment_id uuid not null,
  citation_role consulting_os.citation_role not null,
  citation_note text not null check (length(btrim(citation_note)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (claim_id, organization_id)
    references consulting_os.domain_objects(id, organization_id) on delete restrict,
  foreign key (evidence_fragment_id, organization_id)
    references consulting_os.evidence_fragments(id, organization_id) on delete restrict,
  unique (claim_id, evidence_fragment_id, citation_role)
);

create table consulting_security.relationship_type_rules (
  relationship_type consulting_os.relationship_type not null,
  source_type text,
  target_type text,
  rationale text not null check (length(btrim(rationale)) > 0)
);
create unique index relationship_type_rules_identity_idx
  on consulting_security.relationship_type_rules(
    relationship_type, coalesce(source_type, '*'), coalesce(target_type, '*')
  );

insert into consulting_security.relationship_type_rules
  (relationship_type, source_type, target_type, rationale)
values
  ('SUPPORTED_BY', 'OBSERVATION', 'EVIDENCE', 'Observation is supported by Evidence.'),
  ('SUPPORTED_BY', 'ASSUMPTION', 'EVIDENCE', 'Assumption is supported by Evidence.'),
  ('SUPPORTED_BY', 'INTERPRETATION', 'EVIDENCE', 'Interpretation is supported by Evidence.'),
  ('SUPPORTED_BY', 'INSIGHT', 'EVIDENCE', 'Insight is supported by Evidence.'),
  ('CHALLENGED_BY', 'ASSUMPTION', 'EVIDENCE', 'Evidence challenges an Assumption.'),
  ('CHALLENGED_BY', 'ASSUMPTION', 'OBSERVATION', 'Observation challenges an Assumption.'),
  ('CHALLENGED_BY', 'INTERPRETATION', 'EVIDENCE', 'Evidence challenges an Interpretation.'),
  ('CHALLENGED_BY', 'INTERPRETATION', 'OBSERVATION', 'Observation challenges an Interpretation.'),
  ('CHALLENGED_BY', 'INSIGHT', 'EVIDENCE', 'Evidence challenges an Insight.'),
  ('CHALLENGED_BY', 'INSIGHT', 'OBSERVATION', 'Observation challenges an Insight.'),
  ('CONTRIBUTES_TO', 'OBSERVATION', 'PATTERN', 'Observation contributes to Pattern.'),
  ('SUGGESTS', 'PATTERN', 'HYPOTHESIS', 'Pattern suggests Hypothesis.'),
  ('SUGGESTS', 'PATTERN', 'INTERPRETATION', 'Pattern suggests Interpretation.'),
  ('EXPLAINS', 'INTERPRETATION', 'PATTERN', 'Interpretation proposes meaning for Pattern.'),
  ('VALIDATES', 'RECORD_REVIEW', 'INTERPRETATION', 'Review validates Interpretation.'),
  ('VALIDATES', 'RECORD_REVIEW', 'INSIGHT', 'Review validates Insight.'),
  ('REJECTS', 'RECORD_REVIEW', 'HYPOTHESIS', 'Review rejects Hypothesis.'),
  ('REJECTS', 'RECORD_REVIEW', 'INTERPRETATION', 'Review rejects Interpretation.'),
  ('INFORMS', 'INSIGHT', 'DECISION', 'Validated Insight informs Decision.'),
  ('INFORMS', 'ASSUMPTION', 'DECISION', 'Time-specific Assumption informs Decision.'),
  ('SUPERSEDES', null, null, 'Version supersedes prior same-family version.'),
  ('ASSOCIATED_WITH', null, null, 'Non-causal same-tenant association.');

insert into consulting_security.relationship_type_rules
  (relationship_type, source_type, target_type, rationale)
select
  'DERIVED_FROM'::consulting_os.relationship_type,
  source_type,
  target_type,
  'Derived object retains an inspectable source path.'
from (values ('PATTERN'), ('INTERPRETATION'), ('INSIGHT')) s(source_type)
cross join (
  values ('EVIDENCE_SOURCE'), ('EVIDENCE'), ('OBSERVATION'), ('PATTERN'),
    ('ASSUMPTION'), ('HYPOTHESIS'), ('INTERPRETATION')
) t(target_type);

create or replace function consulting_security.prevent_append_only_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  raise exception '% is append-only; create a correction, review, or superseding record', tg_table_name
    using errcode = '55000';
end
$$;

create or replace function consulting_security.protect_domain_object_identity()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.id <> old.id
    or new.organization_id <> old.organization_id
    or new.object_type <> old.object_type
    or new.origin <> old.origin
    or new.created_by <> old.created_by
    or new.created_at <> old.created_at
  then
    raise exception 'domain object identity, tenant, type, origin, and creation provenance are immutable'
      using errcode = '55000';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_typed_record()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_creator uuid;
  v_origin consulting_os.record_origin;
begin
  select d.created_by, d.origin into v_creator, v_origin
  from consulting_os.domain_objects d
  where d.id = new.id
    and d.organization_id = new.organization_id
    and d.object_type = new.object_type;

  if v_creator is null or v_creator <> new.created_by then
    raise exception 'typed record must match its domain registry creator and type'
      using errcode = '23514';
  end if;
  if to_jsonb(new) ? 'initial_review_state' then
    if v_origin = 'AI'
      and (to_jsonb(new) ->> 'initial_review_state') <> 'SUGGESTED'
    then
      raise exception 'AI-originated inferential records must begin SUGGESTED'
        using errcode = '23514';
    end if;
    if (to_jsonb(new) ->> 'initial_review_state') in ('VALIDATED', 'REJECTED', 'SUPERSEDED') then
      raise exception 'terminal state requires an append-only human review event'
        using errcode = '23514';
    end if;
  end if;
  return new;
end
$$;

create or replace function consulting_security.protect_assumption_version()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    raise exception 'assumptions are versioned and may not be deleted' using errcode = '55000';
  end if;
  if (to_jsonb(new) - array['effective_to', 'assumption_status', 'updated_at'])
    <> (to_jsonb(old) - array['effective_to', 'assumption_status', 'updated_at'])
  then
    raise exception 'meaning-changing assumption edits require a new version'
      using errcode = '55000';
  end if;
  if old.assumption_status = 'SUPERSEDED'
    or new.assumption_status <> 'SUPERSEDED'
    or new.effective_to is null
    or new.effective_to <= old.effective_from
  then
    raise exception 'assumption may only transition once to SUPERSEDED with an effective end'
      using errcode = '23514';
  end if;
  new.updated_at := now();
  return new;
end
$$;

create or replace function consulting_security.can_read_evidence_fragment(
  p_fragment_id uuid,
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
    from consulting_os.evidence_fragments f
    where f.id = p_fragment_id
      and f.organization_id = p_organization_id
      and consulting_security.can_read_domain_object(f.evidence_source_id, f.organization_id)
  ), false)
$$;

create or replace function consulting_security.validate_evidence_visibility()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_record_scope consulting_os.visibility_scope;
  v_source_scope consulting_os.visibility_scope;
begin
  select d.visibility_scope into v_record_scope
  from consulting_os.domain_objects d
  where d.id = new.id and d.organization_id = new.organization_id;

  if tg_table_name = 'evidence_items' then
    select d.visibility_scope into v_source_scope
    from consulting_os.evidence_fragments f
    join consulting_os.domain_objects d
      on d.id = f.evidence_source_id and d.organization_id = f.organization_id
    where f.id = new.primary_fragment_id and f.organization_id = new.organization_id;
  else
    select d.visibility_scope into v_source_scope
    from consulting_os.evidence_items e
    join consulting_os.domain_objects d
      on d.id = e.id and d.organization_id = e.organization_id
    where e.id = new.primary_evidence_id and e.organization_id = new.organization_id;
  end if;

  if v_record_scope is null or v_source_scope is null then
    raise exception 'source and derived registry records must exist' using errcode = '23503';
  end if;
  if v_record_scope <> v_source_scope then
    raise exception 'sensitive source material cannot be broadened without explicit promotion'
      using errcode = '42501';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_record_review()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.reviewer_person_id <> new.created_by then
    raise exception 'reviewer and creator must be the same authenticated human'
      using errcode = '23514';
  end if;
  if not exists (
    select 1 from consulting_os.domain_objects d
    where d.id = new.subject_id and d.organization_id = new.organization_id
  ) then
    raise exception 'review subject must exist in the same organization'
      using errcode = '23503';
  end if;
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
  v_review_action consulting_os.epistemic_review_state;
  v_review_subject uuid;
  v_latest_insight_state consulting_os.epistemic_review_state;
begin
  select d.object_type into v_source_type
  from consulting_os.domain_objects d
  where d.id = new.source_id and d.organization_id = new.organization_id;
  select d.object_type into v_target_type
  from consulting_os.domain_objects d
  where d.id = new.target_id and d.organization_id = new.organization_id;

  if v_source_type is null or v_target_type is null then
    raise exception 'relationship endpoints must exist in the same organization'
      using errcode = '23503';
  end if;
  if v_source_type <> new.source_type or v_target_type <> new.target_type then
    raise exception 'relationship endpoint types do not match registry types'
      using errcode = '23514';
  end if;
  if not exists (
    select 1 from consulting_security.relationship_type_rules r
    where r.relationship_type = new.relationship_type
      and (r.source_type is null or r.source_type = new.source_type)
      and (r.target_type is null or r.target_type = new.target_type)
  ) then
    raise exception 'relationship type is invalid for the typed endpoints'
      using errcode = '23514';
  end if;
  if new.relationship_type = 'SUPERSEDES' and new.source_type <> new.target_type then
    raise exception 'SUPERSEDES must remain within one entity family'
      using errcode = '23514';
  end if;

  if new.relationship_type in ('VALIDATES', 'REJECTS') then
    select review_action, subject_id into v_review_action, v_review_subject
    from consulting_os.record_reviews
    where id = new.source_id and organization_id = new.organization_id;
    if v_review_subject <> new.target_id
      or (new.relationship_type = 'VALIDATES' and v_review_action <> 'VALIDATED')
      or (new.relationship_type = 'REJECTS' and v_review_action <> 'REJECTED')
    then
      raise exception 'review relationship must match its subject and action'
        using errcode = '23514';
    end if;
  end if;

  if new.relationship_type = 'INFORMS' and new.source_type = 'INSIGHT' then
    select r.review_action into v_latest_insight_state
    from consulting_os.record_reviews r
    where r.subject_id = new.source_id and r.organization_id = new.organization_id
    order by r.reviewed_at desc, r.created_at desc
    limit 1;
    if v_latest_insight_state <> 'VALIDATED' then
      raise exception 'only a currently validated Insight may inform a Decision'
        using errcode = '23514';
    end if;
  end if;

  if new.origin = 'AI'
    and new.relationship_type in (
      'SUPPORTED_BY', 'CHALLENGED_BY', 'DERIVED_FROM', 'CONTRIBUTES_TO',
      'SUGGESTS', 'EXPLAINS', 'INFORMS', 'CONTRIBUTED_TO', 'CAUSES'
    )
  then
    if new.review_status is null then
      new.review_status := 'SUGGESTED';
    elsif new.review_status <> 'SUGGESTED' then
      raise exception 'AI inferential relationships must remain SUGGESTED'
        using errcode = '23514';
    end if;
  end if;
  return new;
end
$$;

create trigger domain_objects_protect_identity
before update on consulting_os.domain_objects
for each row execute function consulting_security.protect_domain_object_identity();

create trigger evidence_sources_typed before insert or update on consulting_os.evidence_sources
for each row execute function consulting_security.validate_typed_record();
create trigger evidence_items_typed before insert or update on consulting_os.evidence_items
for each row execute function consulting_security.validate_typed_record();
create trigger observations_typed before insert or update on consulting_os.observations
for each row execute function consulting_security.validate_typed_record();
create trigger patterns_typed before insert or update on consulting_os.patterns
for each row execute function consulting_security.validate_typed_record();
create trigger assumptions_typed before insert or update on consulting_os.assumptions
for each row execute function consulting_security.validate_typed_record();
create trigger hypotheses_typed before insert or update on consulting_os.hypotheses
for each row execute function consulting_security.validate_typed_record();
create trigger interpretations_typed before insert or update on consulting_os.interpretations
for each row execute function consulting_security.validate_typed_record();
create trigger insights_typed before insert or update on consulting_os.insights
for each row execute function consulting_security.validate_typed_record();
create trigger decisions_typed before insert or update on consulting_os.decisions
for each row execute function consulting_security.validate_typed_record();
create trigger record_reviews_typed before insert or update on consulting_os.record_reviews
for each row execute function consulting_security.validate_typed_record();

create trigger evidence_items_visibility before insert or update on consulting_os.evidence_items
for each row execute function consulting_security.validate_evidence_visibility();
create trigger observations_visibility before insert or update on consulting_os.observations
for each row execute function consulting_security.validate_evidence_visibility();
create trigger record_reviews_validate before insert or update on consulting_os.record_reviews
for each row execute function consulting_security.validate_record_review();

drop trigger relationship_endpoints_validate on consulting_os.entity_relationships;
create trigger relationship_endpoints_validate before insert or update on consulting_os.entity_relationships
for each row execute function consulting_security.validate_relationship_endpoints();

create trigger evidence_sources_immutable before update or delete on consulting_os.evidence_sources
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger evidence_fragments_immutable before update or delete on consulting_os.evidence_fragments
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger evidence_items_immutable before update or delete on consulting_os.evidence_items
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger observations_immutable before update or delete on consulting_os.observations
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger patterns_immutable before update or delete on consulting_os.patterns
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger hypotheses_immutable before update or delete on consulting_os.hypotheses
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger interpretations_immutable before update or delete on consulting_os.interpretations
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger insights_immutable before update or delete on consulting_os.insights
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger decisions_immutable before update or delete on consulting_os.decisions
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger decision_alternatives_immutable before update or delete on consulting_os.decision_alternatives
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger record_reviews_immutable before update or delete on consulting_os.record_reviews
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger claim_citations_immutable before update or delete on consulting_os.claim_citations
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger entity_relationships_immutable before update or delete on consulting_os.entity_relationships
for each row execute function consulting_security.prevent_append_only_mutation();
create trigger assumptions_version_guard before update or delete on consulting_os.assumptions
for each row execute function consulting_security.protect_assumption_version();

create trigger record_reviews_audit after insert on consulting_os.record_reviews
for each row execute function consulting_security.audit_row_change();

create index evidence_sources_org_type_time_idx
  on consulting_os.evidence_sources(organization_id, source_type, captured_at desc);
create index evidence_fragments_org_source_idx
  on consulting_os.evidence_fragments(organization_id, evidence_source_id, created_at);
create index evidence_fragments_hash_idx
  on consulting_os.evidence_fragments(organization_id, content_sha256);
create index evidence_items_org_fragment_idx
  on consulting_os.evidence_items(organization_id, primary_fragment_id);
create index observations_org_time_idx
  on consulting_os.observations(organization_id, observed_at desc);
create index patterns_org_state_idx
  on consulting_os.patterns(organization_id, initial_review_state, created_at desc);
create index assumptions_org_effective_idx
  on consulting_os.assumptions(organization_id, logical_id, effective_from desc, effective_to);
create index interpretations_org_state_idx
  on consulting_os.interpretations(organization_id, initial_review_state, created_at desc);
create index record_reviews_subject_time_idx
  on consulting_os.record_reviews(organization_id, subject_id, reviewed_at desc, created_at desc);
create index claim_citations_claim_idx
  on consulting_os.claim_citations(organization_id, claim_id);
create index decisions_org_time_idx
  on consulting_os.decisions(organization_id, decided_at desc, decision_status);

alter table consulting_os.evidence_sources enable row level security;
alter table consulting_os.evidence_fragments enable row level security;
alter table consulting_os.evidence_items enable row level security;
alter table consulting_os.observations enable row level security;
alter table consulting_os.patterns enable row level security;
alter table consulting_os.assumptions enable row level security;
alter table consulting_os.hypotheses enable row level security;
alter table consulting_os.interpretations enable row level security;
alter table consulting_os.insights enable row level security;
alter table consulting_os.decisions enable row level security;
alter table consulting_os.decision_alternatives enable row level security;
alter table consulting_os.record_reviews enable row level security;
alter table consulting_os.claim_citations enable row level security;
alter table consulting_security.relationship_type_rules enable row level security;

do $$
declare
  v_table text;
begin
  foreach v_table in array array[
    'evidence_sources', 'observations', 'patterns', 'assumptions',
    'hypotheses', 'interpretations', 'insights'
  ]
  loop
    execute format(
      'create policy %I on consulting_os.%I for select to authenticated using (consulting_security.can_read_domain_object(id, organization_id))',
      v_table || '_select_visible',
      v_table
    );
    execute format(
      'create policy %I on consulting_os.%I for insert to authenticated with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(id, organization_id))',
      v_table || '_insert_authorized',
      v_table
    );
  end loop;
end
$$;

create policy decisions_select_visible on consulting_os.decisions
for select to authenticated
using (consulting_security.can_read_domain_object(id, organization_id));
create policy decisions_insert_authorized on consulting_os.decisions
for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and authority_person_id = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(id, organization_id)
  and consulting_security.can_manage_organization(organization_id)
);

create policy evidence_fragments_select_visible on consulting_os.evidence_fragments
for select to authenticated
using (consulting_security.can_read_domain_object(evidence_source_id, organization_id));
create policy evidence_fragments_insert_authorized on consulting_os.evidence_fragments
for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(evidence_source_id, organization_id)
);

create policy evidence_items_select_visible on consulting_os.evidence_items
for select to authenticated
using (
  consulting_security.can_read_domain_object(id, organization_id)
  and consulting_security.can_read_evidence_fragment(primary_fragment_id, organization_id)
);
create policy evidence_items_insert_authorized on consulting_os.evidence_items
for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(id, organization_id)
  and consulting_security.can_read_evidence_fragment(primary_fragment_id, organization_id)
);

create policy assumptions_update_authorized on consulting_os.assumptions
for update to authenticated
using (consulting_security.can_manage_domain_object(id, organization_id))
with check (consulting_security.can_manage_domain_object(id, organization_id));

create policy decision_alternatives_select_visible on consulting_os.decision_alternatives
for select to authenticated
using (consulting_security.can_read_domain_object(decision_id, organization_id));
create policy decision_alternatives_insert_authorized on consulting_os.decision_alternatives
for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(decision_id, organization_id)
);

create policy record_reviews_select_visible on consulting_os.record_reviews
for select to authenticated
using (
  consulting_security.can_read_domain_object(id, organization_id)
  and consulting_security.can_read_domain_object(subject_id, organization_id)
);
create policy record_reviews_insert_authorized on consulting_os.record_reviews
for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and reviewer_person_id = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(id, organization_id)
  and consulting_security.can_manage_domain_object(subject_id, organization_id)
);

create policy claim_citations_select_visible on consulting_os.claim_citations
for select to authenticated
using (
  consulting_security.can_read_domain_object(claim_id, organization_id)
  and consulting_security.can_read_evidence_fragment(evidence_fragment_id, organization_id)
);
create policy claim_citations_insert_authorized on consulting_os.claim_citations
for insert to authenticated
with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(claim_id, organization_id)
  and consulting_security.can_read_evidence_fragment(evidence_fragment_id, organization_id)
);

revoke update, delete on consulting_os.entity_relationships from authenticated;
revoke all on consulting_security.relationship_type_rules from public, anon, authenticated;

do $$
declare
  v_table text;
begin
  foreach v_table in array array[
    'evidence_sources', 'evidence_fragments', 'evidence_items', 'observations',
    'patterns', 'assumptions', 'hypotheses', 'interpretations', 'insights',
    'decisions', 'decision_alternatives', 'record_reviews', 'claim_citations'
  ]
  loop
    execute format('revoke all on consulting_os.%I from public, anon, authenticated', v_table);
    execute format('grant select, insert on consulting_os.%I to authenticated', v_table);
    execute format('grant all on consulting_os.%I to service_role', v_table);
  end loop;
end
$$;
grant update on consulting_os.assumptions to authenticated;
grant select on consulting_security.relationship_type_rules to service_role;

revoke all on function consulting_security.prevent_append_only_mutation() from public, anon;
revoke all on function consulting_security.protect_domain_object_identity() from public, anon;
revoke all on function consulting_security.validate_typed_record() from public, anon;
revoke all on function consulting_security.protect_assumption_version() from public, anon;
revoke all on function consulting_security.can_read_evidence_fragment(uuid, uuid) from public, anon;
revoke all on function consulting_security.validate_evidence_visibility() from public, anon;
revoke all on function consulting_security.validate_record_review() from public, anon;
revoke all on function consulting_security.validate_relationship_endpoints() from public, anon;
grant execute on function consulting_security.can_read_evidence_fragment(uuid, uuid)
  to authenticated, service_role;

create or replace view consulting_os.latest_record_reviews
with (security_invoker = true)
as
select distinct on (organization_id, subject_id)
  id,
  organization_id,
  subject_id,
  review_action,
  reviewer_person_id,
  rationale,
  evidence_considered,
  contrary_evidence,
  limitations,
  dissent,
  reviewed_at
from consulting_os.record_reviews
order by organization_id, subject_id, reviewed_at desc, created_at desc;

create or replace view consulting_os.epistemic_record_states
with (security_invoker = true)
as
with initial_states as (
  select id, organization_id, 'OBSERVATION'::text object_type, initial_review_state
    from consulting_os.observations
  union all select id, organization_id, 'PATTERN', initial_review_state
    from consulting_os.patterns
  union all select id, organization_id, 'ASSUMPTION',
    case
      when assumption_status = 'SUPERSEDED' then 'SUPERSEDED'::consulting_os.epistemic_review_state
      else initial_review_state
    end
    from consulting_os.assumptions
  union all select id, organization_id, 'HYPOTHESIS', initial_review_state
    from consulting_os.hypotheses
  union all select id, organization_id, 'INTERPRETATION', initial_review_state
    from consulting_os.interpretations
  union all select id, organization_id, 'INSIGHT', initial_review_state
    from consulting_os.insights
)
select
  s.id,
  s.organization_id,
  s.object_type,
  d.origin,
  coalesce(r.review_action, s.initial_review_state) current_review_state,
  d.created_at
from initial_states s
join consulting_os.domain_objects d
  on d.id = s.id and d.organization_id = s.organization_id
left join consulting_os.latest_record_reviews r
  on r.subject_id = s.id and r.organization_id = s.organization_id
where d.archived_at is null;

create or replace view consulting_os.operative_epistemic_records
with (security_invoker = true)
as
select *
from consulting_os.epistemic_record_states
where current_review_state not in ('REJECTED', 'SUPERSEDED');

create or replace view consulting_os.validated_insights
with (security_invoker = true)
as
select
  i.id,
  i.organization_id,
  i.statement,
  i.rationale,
  i.limitations,
  r.reviewer_person_id,
  r.rationale validation_rationale,
  r.reviewed_at validated_at
from consulting_os.insights i
join consulting_os.latest_record_reviews r
  on r.subject_id = i.id
  and r.organization_id = i.organization_id
  and r.review_action = 'VALIDATED';

create or replace view consulting_os.current_assumptions
with (security_invoker = true)
as
select *
from consulting_os.assumptions
where effective_from <= now()
  and (effective_to is null or effective_to > now())
  and assumption_status <> 'SUPERSEDED';

grant select on consulting_os.latest_record_reviews to authenticated, service_role;
grant select on consulting_os.epistemic_record_states to authenticated, service_role;
grant select on consulting_os.operative_epistemic_records to authenticated, service_role;
grant select on consulting_os.validated_insights to authenticated, service_role;
grant select on consulting_os.current_assumptions to authenticated, service_role;

create or replace function consulting_os.assumptions_at(
  p_organization_id uuid,
  p_as_of timestamptz
)
returns table (
  id uuid,
  logical_id uuid,
  version_number integer,
  statement text,
  assumption_status consulting_os.assumption_status,
  effective_from timestamptz,
  effective_to timestamptz
)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    a.id, a.logical_id, a.version_number, a.statement,
    a.assumption_status, a.effective_from, a.effective_to
  from consulting_os.assumptions a
  where a.organization_id = p_organization_id
    and a.effective_from <= p_as_of
    and (a.effective_to is null or a.effective_to > p_as_of)
  order by a.logical_id, a.version_number desc
$$;

create or replace function consulting_os.supersede_assumption(
  p_assumption_id uuid,
  p_new_statement text,
  p_effective_from timestamptz,
  p_status consulting_os.assumption_status default 'UNTESTED',
  p_confidence_level consulting_os.confidence_level default 'NOT_ASSESSED',
  p_confidence_rationale text default null,
  p_review_trigger text default 'Review when material contrary evidence appears.'
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_old consulting_os.assumptions%rowtype;
  v_registry consulting_os.domain_objects%rowtype;
  v_person_id uuid := consulting_security.current_person_id();
  v_new_id uuid := gen_random_uuid();
begin
  if v_person_id is null then
    raise exception 'authenticated person is required' using errcode = '42501';
  end if;

  select * into v_old from consulting_os.assumptions where id = p_assumption_id;
  if not found then
    raise exception 'assumption is unavailable or does not exist' using errcode = 'P0002';
  end if;
  if not consulting_security.can_manage_domain_object(v_old.id, v_old.organization_id) then
    raise exception 'assumption management permission is required' using errcode = '42501';
  end if;
  if p_effective_from <= v_old.effective_from then
    raise exception 'superseding version must begin after the prior version' using errcode = '22007';
  end if;

  select * into v_registry
  from consulting_os.domain_objects
  where id = v_old.id and organization_id = v_old.organization_id;

  update consulting_os.assumptions
  set assumption_status = 'SUPERSEDED', effective_to = p_effective_from
  where id = v_old.id;

  insert into consulting_os.domain_objects (
    id, organization_id, engagement_id, object_type, visibility_scope,
    owner_person_id, origin, created_by
  ) values (
    v_new_id, v_registry.organization_id, v_registry.engagement_id, 'ASSUMPTION',
    v_registry.visibility_scope, v_registry.owner_person_id, 'HUMAN', v_person_id
  );

  insert into consulting_os.assumptions (
    id, organization_id, logical_id, version_number, statement, holder_scope,
    origin_history, assumption_status, initial_review_state, confidence_level,
    confidence_rationale, review_trigger, effective_from, supersedes_id, created_by
  ) values (
    v_new_id, v_old.organization_id, v_old.logical_id, v_old.version_number + 1,
    p_new_statement, v_old.holder_scope, v_old.origin_history, p_status, 'DRAFT',
    p_confidence_level, p_confidence_rationale, p_review_trigger,
    p_effective_from, v_old.id, v_person_id
  );

  insert into consulting_os.entity_relationships (
    organization_id, engagement_id, relationship_type, source_type, source_id,
    target_type, target_id, origin, review_status, rationale, created_by, effective_from
  ) values (
    v_old.organization_id, v_registry.engagement_id, 'SUPERSEDES',
    'ASSUMPTION', v_new_id, 'ASSUMPTION', v_old.id, 'HUMAN', 'ACCEPTED',
    'Meaning-changing edit created a new operative Assumption version.',
    v_person_id, p_effective_from
  );
  return v_new_id;
end
$$;

revoke all on function consulting_os.assumptions_at(uuid, timestamptz) from public, anon;
revoke all on function consulting_os.supersede_assumption(
  uuid, text, timestamptz, consulting_os.assumption_status,
  consulting_os.confidence_level, text, text
) from public, anon;
grant execute on function consulting_os.assumptions_at(uuid, timestamptz)
  to authenticated, service_role;
grant execute on function consulting_os.supersede_assumption(
  uuid, text, timestamptz, consulting_os.assumption_status,
  consulting_os.confidence_level, text, text
) to authenticated, service_role;

comment on table consulting_os.evidence_fragments is
  'Append-only inspectable fragments; corrections create linked fragments.';
comment on table consulting_os.record_reviews is
  'Append-only human review acts; acceptance never changes epistemic class.';
comment on view consulting_os.operative_epistemic_records is
  'Visible records not currently rejected or superseded; history remains queryable.';
