-- Lead Emergence Consulting OS — Phase 3 Consulting Core
-- Additive migration. Never apply to a hosted target without a separate environment decision.

create type consulting_os.artifact_type as enum (
  'ORGANIZATIONAL_PORTRAIT', 'CURRENT_STATE_REALITY_MAP'
);
create type consulting_os.artifact_status as enum (
  'DRAFT', 'UNDER_REVIEW', 'APPROVED', 'SUPERSEDED', 'ARCHIVED'
);
create type consulting_os.identity_element_type as enum (
  'PURPOSE', 'MISSION', 'VISION', 'VALUE', 'PRINCIPLE', 'DISTINCTIVE', 'DNA'
);
create type consulting_os.assessment_confidentiality as enum (
  'IDENTIFIED', 'CONFIDENTIAL', 'ANONYMOUS'
);
create type consulting_os.assessment_status as enum (
  'DRAFT', 'OPEN', 'CLOSED', 'ARCHIVED'
);
create type consulting_os.validation_claim_status as enum (
  'NOT_VALIDATED', 'EXTERNALLY_REVIEWED', 'VALIDATED'
);

create table consulting_os.risks (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('RISK'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  affected_scope text not null check (length(btrim(affected_scope)) > 0),
  severity text not null check (severity in ('LOW', 'MODERATE', 'HIGH', 'CRITICAL')),
  rationale text not null check (length(btrim(rationale)) > 0),
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.strengths (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('STRENGTH'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  scope text not null check (length(btrim(scope)) > 0),
  value_produced text not null check (length(btrim(value_produced)) > 0),
  protection_rationale text not null check (length(btrim(protection_rationale)) > 0),
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.unrealized_potentials (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('UNREALIZED_POTENTIAL'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  scope text not null check (length(btrim(scope)) > 0),
  existing_capacity text not null check (length(btrim(existing_capacity)) > 0),
  constraint_summary text not null check (length(btrim(constraint_summary)) > 0),
  initial_review_state consulting_os.epistemic_review_state not null default 'DRAFT',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.diagnoses (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('DIAGNOSIS'::text) stored,
  statement text not null check (length(btrim(statement)) > 0),
  scope text not null check (length(btrim(scope)) > 0),
  rationale text not null check (length(btrim(rationale)) > 0),
  alternatives_considered text not null check (length(btrim(alternatives_considered)) > 0),
  limitations text not null check (length(btrim(limitations)) > 0),
  initial_review_state consulting_os.epistemic_review_state not null default 'UNDER_REVIEW',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.interviews (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('INTERVIEW'::text) stored,
  engagement_id uuid not null,
  evidence_source_id uuid not null,
  participant_person_id uuid references consulting_os.people(id) on delete restrict,
  participant_label text not null check (length(btrim(participant_label)) > 0),
  interviewer_person_id uuid not null references consulting_os.people(id) on delete restrict,
  guide_name text not null check (length(btrim(guide_name)) > 0),
  guide_version text not null check (length(btrim(guide_version)) > 0),
  interview_status text not null check (interview_status in ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
  scheduled_at timestamptz,
  conducted_at timestamptz,
  consent_recorded boolean not null default false,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id)
    references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (evidence_source_id, organization_id)
    references consulting_os.evidence_sources(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (interview_status <> 'COMPLETED' or (conducted_at is not null and consent_recorded))
);

create table consulting_os.interview_responses (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('INTERVIEW_RESPONSE'::text) stored,
  interview_id uuid not null,
  question_key text not null check (length(btrim(question_key)) > 0),
  question_text text not null check (length(btrim(question_text)) > 0),
  response_text text not null check (length(btrim(response_text)) > 0),
  evidence_fragment_id uuid not null,
  source_locator text not null check (length(btrim(source_locator)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (interview_id, organization_id)
    references consulting_os.interviews(id, organization_id) on delete restrict,
  foreign key (evidence_fragment_id, organization_id)
    references consulting_os.evidence_fragments(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (interview_id, question_key)
);

create table consulting_private.interview_responses (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('INTERVIEW_RESPONSE'::text) stored,
  interview_id uuid not null,
  question_key text not null check (length(btrim(question_key)) > 0),
  question_text text not null check (length(btrim(question_text)) > 0),
  response_text text not null check (length(btrim(response_text)) > 0),
  evidence_fragment_id uuid not null,
  source_locator text not null check (length(btrim(source_locator)) > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (interview_id, organization_id)
    references consulting_os.interviews(id, organization_id) on delete restrict,
  foreign key (evidence_fragment_id, organization_id)
    references consulting_os.evidence_fragments(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (interview_id, question_key)
);

create table consulting_os.assessment_instruments (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('ASSESSMENT_INSTRUMENT'::text) stored,
  name text not null check (length(btrim(name)) > 0),
  framework_name text not null check (length(btrim(framework_name)) > 0),
  instrument_status text not null check (instrument_status in ('DRAFT', 'ACTIVE', 'RETIRED')),
  validation_claim_status consulting_os.validation_claim_status not null default 'NOT_VALIDATED',
  validation_basis text,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  unique (id, organization_id),
  check (
    validation_claim_status <> 'VALIDATED'
    or length(btrim(coalesce(validation_basis, ''))) > 0
  )
);

create table consulting_os.assessment_instrument_versions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  instrument_id uuid not null,
  version_number integer not null check (version_number > 0),
  version_label text not null check (length(btrim(version_label)) > 0),
  dimensions jsonb not null check (jsonb_typeof(dimensions) = 'array'),
  scoring_rules jsonb not null check (jsonb_typeof(scoring_rules) = 'object'),
  compatibility_key text not null check (length(btrim(compatibility_key)) > 0),
  published_at timestamptz,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (instrument_id, organization_id)
    references consulting_os.assessment_instruments(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (instrument_id, version_number)
);

create table consulting_os.assessment_items (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  instrument_version_id uuid not null,
  item_key text not null check (length(btrim(item_key)) > 0),
  prompt text not null check (length(btrim(prompt)) > 0),
  dimension_key text not null check (length(btrim(dimension_key)) > 0),
  response_type text not null check (response_type in ('TEXT', 'BOOLEAN', 'LIKERT', 'NUMBER', 'SINGLE_SELECT', 'MULTI_SELECT')),
  response_options jsonb,
  ordinal integer not null check (ordinal > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (instrument_version_id, organization_id)
    references consulting_os.assessment_instrument_versions(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (instrument_version_id, item_key),
  unique (instrument_version_id, ordinal)
);

create table consulting_os.assessment_administrations (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('ASSESSMENT_ADMINISTRATION'::text) stored,
  engagement_id uuid not null,
  instrument_version_id uuid not null,
  evidence_source_id uuid not null,
  audience_description text not null check (length(btrim(audience_description)) > 0),
  opens_at timestamptz not null,
  closes_at timestamptz not null,
  confidentiality consulting_os.assessment_confidentiality not null,
  minimum_reporting_cohort integer not null default 1 check (minimum_reporting_cohort > 0),
  administration_status consulting_os.assessment_status not null default 'DRAFT',
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id)
    references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (instrument_version_id, organization_id)
    references consulting_os.assessment_instrument_versions(id, organization_id) on delete restrict,
  foreign key (evidence_source_id, organization_id)
    references consulting_os.evidence_sources(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (closes_at > opens_at),
  check (confidentiality <> 'ANONYMOUS' or minimum_reporting_cohort >= 3)
);

create table consulting_os.assessment_responses (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('ASSESSMENT_RESPONSE'::text) stored,
  administration_id uuid not null,
  item_id uuid not null,
  respondent_person_id uuid references consulting_os.people(id) on delete restrict,
  participant_token_hash text,
  response_value jsonb not null,
  evidence_fragment_id uuid not null,
  submitted_at timestamptz not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (administration_id, organization_id)
    references consulting_os.assessment_administrations(id, organization_id) on delete restrict,
  foreign key (item_id, organization_id)
    references consulting_os.assessment_items(id, organization_id) on delete restrict,
  foreign key (evidence_fragment_id, organization_id)
    references consulting_os.evidence_fragments(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (administration_id, item_id, respondent_person_id),
  check (participant_token_hash is null or participant_token_hash ~ '^[0-9a-f]{64}$')
);

create table consulting_private.assessment_responses (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('ASSESSMENT_RESPONSE'::text) stored,
  administration_id uuid not null,
  item_id uuid not null,
  respondent_person_id uuid references consulting_os.people(id) on delete restrict,
  participant_token_hash text,
  response_value jsonb not null,
  evidence_fragment_id uuid not null,
  submitted_at timestamptz not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (administration_id, organization_id)
    references consulting_os.assessment_administrations(id, organization_id) on delete restrict,
  foreign key (item_id, organization_id)
    references consulting_os.assessment_items(id, organization_id) on delete restrict,
  foreign key (evidence_fragment_id, organization_id)
    references consulting_os.evidence_fragments(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (participant_token_hash is null or participant_token_hash ~ '^[0-9a-f]{64}$')
);

create table consulting_os.artifacts (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('ARTIFACT'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  artifact_type consulting_os.artifact_type not null,
  title text not null check (length(btrim(title)) > 0),
  artifact_status consulting_os.artifact_status not null default 'DRAFT',
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  approved_by uuid references consulting_os.people(id) on delete restrict,
  approved_at timestamptz,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (supersedes_id, organization_id)
    references consulting_os.artifacts(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null)),
  check ((artifact_status <> 'APPROVED') or (approved_by is not null and approved_at is not null))
);

create table consulting_os.artifact_sections (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  artifact_id uuid not null,
  section_key text not null check (section_key ~ '^[A-Z][A-Z0-9_]*$'),
  heading text not null check (length(btrim(heading)) > 0),
  narrative text not null check (length(btrim(narrative)) > 0),
  ordinal integer not null check (ordinal > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (artifact_id, organization_id)
    references consulting_os.artifacts(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (artifact_id, section_key),
  unique (artifact_id, ordinal)
);

create table consulting_os.artifact_members (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  artifact_id uuid not null,
  section_id uuid not null,
  member_type text not null check (member_type ~ '^[A-Z][A-Z0-9_]*$'),
  member_id uuid not null,
  member_note text not null check (length(btrim(member_note)) > 0),
  ordinal integer not null check (ordinal > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (artifact_id, organization_id)
    references consulting_os.artifacts(id, organization_id) on delete restrict,
  foreign key (section_id, organization_id)
    references consulting_os.artifact_sections(id, organization_id) on delete restrict,
  foreign key (member_id, organization_id)
    references consulting_os.domain_objects(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (artifact_id, section_id, member_id)
);

create table consulting_os.identity_elements (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('IDENTITY_ELEMENT'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  element_type consulting_os.identity_element_type not null,
  statement text not null check (length(btrim(statement)) > 0),
  rationale text not null check (length(btrim(rationale)) > 0),
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (supersedes_id, organization_id)
    references consulting_os.identity_elements(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.organizational_dna_versions (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('ORGANIZATIONAL_DNA'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  rationale text not null check (length(btrim(rationale)) > 0),
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  approved_by uuid not null references consulting_os.people(id) on delete restrict,
  approved_at timestamptz not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (supersedes_id, organization_id)
    references consulting_os.organizational_dna_versions(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.organizational_dna_elements (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  dna_version_id uuid not null,
  identity_element_id uuid not null,
  inclusion_rationale text not null check (length(btrim(inclusion_rationale)) > 0),
  ordinal integer not null check (ordinal > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (dna_version_id, organization_id)
    references consulting_os.organizational_dna_versions(id, organization_id) on delete restrict,
  foreign key (identity_element_id, organization_id)
    references consulting_os.identity_elements(id, organization_id) on delete restrict,
  unique (dna_version_id, identity_element_id),
  unique (dna_version_id, ordinal)
);

create table consulting_os.future_state_narratives (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('FUTURE_STATE_NARRATIVE'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  what_was_true text not null check (length(btrim(what_was_true)) > 0),
  what_changed text not null check (length(btrim(what_changed)) > 0),
  what_is_true_now text not null check (length(btrim(what_is_true_now)) > 0),
  what_that_means text not null check (length(btrim(what_that_means)) > 0),
  what_must_become_true_next text not null check (length(btrim(what_must_become_true_next)) > 0),
  what_could_become_possible text not null check (length(btrim(what_could_become_possible)) > 0),
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  approved_by uuid not null references consulting_os.people(id) on delete restrict,
  approved_at timestamptz not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (supersedes_id, organization_id)
    references consulting_os.future_state_narratives(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.future_state_principles (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('FUTURE_STATE_PRINCIPLE'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  narrative_id uuid not null,
  statement text not null check (length(btrim(statement)) > 0),
  rationale text not null check (length(btrim(rationale)) > 0),
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (narrative_id, organization_id)
    references consulting_os.future_state_narratives(id, organization_id) on delete restrict,
  foreign key (supersedes_id, organization_id)
    references consulting_os.future_state_principles(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.future_states (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('FUTURE_STATE'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  state_domain text not null check (state_domain ~ '^[A-Z][A-Z0-9_]*$'),
  current_baseline text not null check (length(btrim(current_baseline)) > 0),
  desired_condition text not null check (length(btrim(desired_condition)) > 0),
  horizon_date date not null,
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (supersedes_id, organization_id)
    references consulting_os.future_states(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null))
);

create table consulting_os.organizational_blueprints (
  id uuid primary key,
  organization_id uuid not null,
  object_type text generated always as ('ORGANIZATIONAL_BLUEPRINT'::text) stored,
  logical_id uuid not null,
  version_number integer not null check (version_number > 0),
  title text not null check (length(btrim(title)) > 0),
  rationale text not null check (length(btrim(rationale)) > 0),
  artifact_status consulting_os.artifact_status not null,
  effective_from timestamptz not null,
  effective_to timestamptz,
  supersedes_id uuid,
  approved_by uuid references consulting_os.people(id) on delete restrict,
  approved_at timestamptz,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type)
    references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (supersedes_id, organization_id)
    references consulting_os.organizational_blueprints(id, organization_id) on delete restrict,
  unique (id, organization_id),
  unique (organization_id, logical_id, version_number),
  check (effective_to is null or effective_to > effective_from),
  check ((version_number = 1 and supersedes_id is null) or (version_number > 1 and supersedes_id is not null)),
  check ((artifact_status <> 'APPROVED') or (approved_by is not null and approved_at is not null))
);

create table consulting_os.blueprint_members (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  blueprint_id uuid not null,
  member_type text not null check (member_type ~ '^[A-Z][A-Z0-9_]*$'),
  member_id uuid not null,
  domain_key text not null check (domain_key ~ '^[A-Z][A-Z0-9_]*$'),
  inclusion_rationale text not null check (length(btrim(inclusion_rationale)) > 0),
  ordinal integer not null check (ordinal > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (blueprint_id, organization_id)
    references consulting_os.organizational_blueprints(id, organization_id) on delete restrict,
  foreign key (member_id, organization_id)
    references consulting_os.domain_objects(id, organization_id) on delete restrict,
  unique (blueprint_id, member_id),
  unique (blueprint_id, ordinal)
);

create table consulting_security.artifact_section_rules (
  artifact_type consulting_os.artifact_type not null,
  section_key text not null,
  allowed_member_types text[] not null,
  primary key (artifact_type, section_key)
);

insert into consulting_security.artifact_section_rules
  (artifact_type, section_key, allowed_member_types)
values
  ('ORGANIZATIONAL_PORTRAIT', 'PURPOSE_IDENTITY', array['IDENTITY_ELEMENT','EVIDENCE','OBSERVATION']),
  ('ORGANIZATIONAL_PORTRAIT', 'HISTORY_CONTEXT', array['EVIDENCE','OBSERVATION','PATTERN']),
  ('ORGANIZATIONAL_PORTRAIT', 'PEOPLE_STAKEHOLDERS', array['EVIDENCE','OBSERVATION','PATTERN']),
  ('ORGANIZATIONAL_PORTRAIT', 'CULTURE_BEHAVIORS', array['EVIDENCE','OBSERVATION','PATTERN','STRENGTH','RISK']),
  ('ORGANIZATIONAL_PORTRAIT', 'STRUCTURE_ROLES', array['EVIDENCE','OBSERVATION','PATTERN']),
  ('ORGANIZATIONAL_PORTRAIT', 'WORKFLOWS', array['EVIDENCE','OBSERVATION','PATTERN']),
  ('ORGANIZATIONAL_PORTRAIT', 'SYSTEMS_TECHNOLOGY', array['EVIDENCE','OBSERVATION','PATTERN','RISK']),
  ('ORGANIZATIONAL_PORTRAIT', 'RELATIONSHIPS', array['EVIDENCE','OBSERVATION','PATTERN','STRENGTH']),
  ('ORGANIZATIONAL_PORTRAIT', 'VALUE_OUTCOMES', array['EVIDENCE','OBSERVATION','PATTERN','STRENGTH']),
  ('ORGANIZATIONAL_PORTRAIT', 'CURRENT_PRESSURES', array['EVIDENCE','OBSERVATION','PATTERN','RISK','UNREALIZED_POTENTIAL']),
  ('CURRENT_STATE_REALITY_MAP', 'OBSERVABLE_EVIDENCE', array['EVIDENCE','OBSERVATION']),
  ('CURRENT_STATE_REALITY_MAP', 'STAKEHOLDER_PERSPECTIVES', array['EVIDENCE','OBSERVATION','PATTERN']),
  ('CURRENT_STATE_REALITY_MAP', 'WORKFLOWS', array['EVIDENCE','OBSERVATION','PATTERN']),
  ('CURRENT_STATE_REALITY_MAP', 'SYSTEM_INTERACTIONS', array['EVIDENCE','OBSERVATION','PATTERN','RISK']),
  ('CURRENT_STATE_REALITY_MAP', 'CULTURE_SIGNALS', array['OBSERVATION','PATTERN','STRENGTH','RISK']),
  ('CURRENT_STATE_REALITY_MAP', 'FRICTION_POINTS', array['OBSERVATION','PATTERN','RISK','DIAGNOSIS']),
  ('CURRENT_STATE_REALITY_MAP', 'RISKS', array['RISK']),
  ('CURRENT_STATE_REALITY_MAP', 'STRENGTHS', array['STRENGTH']),
  ('CURRENT_STATE_REALITY_MAP', 'UNREALIZED_POTENTIAL', array['UNREALIZED_POTENTIAL']),
  ('CURRENT_STATE_REALITY_MAP', 'ASSUMPTION_REGISTER', array['ASSUMPTION']);

create index interviews_org_engagement_idx on consulting_os.interviews(organization_id, engagement_id, conducted_at desc);
create index interview_responses_interview_idx on consulting_os.interview_responses(organization_id, interview_id);
create index private_interview_responses_interview_idx on consulting_private.interview_responses(organization_id, interview_id);
create index assessment_versions_instrument_idx on consulting_os.assessment_instrument_versions(organization_id, instrument_id, version_number desc);
create index assessment_items_version_idx on consulting_os.assessment_items(organization_id, instrument_version_id, ordinal);
create index assessment_administrations_engagement_idx on consulting_os.assessment_administrations(organization_id, engagement_id, opens_at desc);
create index assessment_responses_admin_idx on consulting_os.assessment_responses(organization_id, administration_id, submitted_at);
create index private_assessment_responses_admin_idx on consulting_private.assessment_responses(organization_id, administration_id, submitted_at);
create index artifacts_org_type_version_idx on consulting_os.artifacts(organization_id, artifact_type, logical_id, version_number desc);
create index artifact_sections_artifact_idx on consulting_os.artifact_sections(organization_id, artifact_id, ordinal);
create index artifact_members_artifact_idx on consulting_os.artifact_members(organization_id, artifact_id, section_id, ordinal);
create index identity_elements_current_idx on consulting_os.identity_elements(organization_id, logical_id, version_number desc);
create index future_narratives_current_idx on consulting_os.future_state_narratives(organization_id, logical_id, version_number desc);
create index future_states_current_idx on consulting_os.future_states(organization_id, logical_id, version_number desc);
create index blueprints_current_idx on consulting_os.organizational_blueprints(organization_id, logical_id, version_number desc);

create or replace function consulting_security.validate_typed_record()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_creator uuid;
  v_origin consulting_os.record_origin;
  v_registry_type text;
  v_expected_type text;
begin
  v_expected_type := case tg_table_name
    when 'evidence_sources' then 'EVIDENCE_SOURCE'
    when 'evidence_items' then 'EVIDENCE'
    when 'observations' then 'OBSERVATION'
    when 'patterns' then 'PATTERN'
    when 'assumptions' then 'ASSUMPTION'
    when 'hypotheses' then 'HYPOTHESIS'
    when 'interpretations' then 'INTERPRETATION'
    when 'insights' then 'INSIGHT'
    when 'decisions' then 'DECISION'
    when 'record_reviews' then 'RECORD_REVIEW'
    when 'risks' then 'RISK'
    when 'strengths' then 'STRENGTH'
    when 'unrealized_potentials' then 'UNREALIZED_POTENTIAL'
    when 'diagnoses' then 'DIAGNOSIS'
    when 'interviews' then 'INTERVIEW'
    when 'interview_responses' then 'INTERVIEW_RESPONSE'
    when 'assessment_instruments' then 'ASSESSMENT_INSTRUMENT'
    when 'assessment_administrations' then 'ASSESSMENT_ADMINISTRATION'
    when 'assessment_responses' then 'ASSESSMENT_RESPONSE'
    when 'artifacts' then 'ARTIFACT'
    when 'identity_elements' then 'IDENTITY_ELEMENT'
    when 'organizational_dna_versions' then 'ORGANIZATIONAL_DNA'
    when 'future_state_narratives' then 'FUTURE_STATE_NARRATIVE'
    when 'future_state_principles' then 'FUTURE_STATE_PRINCIPLE'
    when 'future_states' then 'FUTURE_STATE'
    when 'organizational_blueprints' then 'ORGANIZATIONAL_BLUEPRINT'
  end;

  select d.created_by, d.origin, d.object_type into v_creator, v_origin, v_registry_type
  from consulting_os.domain_objects d
  where d.id = new.id and d.organization_id = new.organization_id;

  if v_creator is null or v_creator <> new.created_by or v_registry_type <> v_expected_type then
    raise exception 'typed record must match its domain registry creator and type'
      using errcode = '23514';
  end if;
  if to_jsonb(new) ? 'initial_review_state' then
    if v_origin = 'AI' and (to_jsonb(new) ->> 'initial_review_state') <> 'SUGGESTED' then
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

create or replace function consulting_security.prevent_versioned_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  raise exception 'meaning-changing versioned records are append-only; create a superseding version'
    using errcode = '55000';
end
$$;

create or replace function consulting_security.validate_version_chain()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_prior_logical_id uuid;
  v_prior_version integer;
  v_prior_organization_id uuid;
begin
  if new.version_number = 1 then
    if new.supersedes_id is not null then
      raise exception 'first version cannot supersede another record' using errcode = '23514';
    end if;
    return new;
  end if;

  execute format(
    'select logical_id, version_number, organization_id from %I.%I where id = $1',
    tg_table_schema, tg_table_name
  ) into v_prior_logical_id, v_prior_version, v_prior_organization_id
  using new.supersedes_id;

  if v_prior_logical_id is null
    or v_prior_logical_id <> new.logical_id
    or v_prior_version <> new.version_number - 1
    or v_prior_organization_id <> new.organization_id
  then
    raise exception 'superseding version must follow the same logical record in the same organization'
      using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.visibility_can_contain(
  p_container consulting_os.visibility_scope,
  p_member consulting_os.visibility_scope
)
returns boolean
language sql
immutable
security invoker
set search_path = ''
as $$
  select case
    when p_container = p_member then true
    when p_member = 'ORGANIZATION_SHARED' then true
    when p_container in ('CONSULTANT_PRIVATE', 'INDIVIDUAL_PRIVATE')
      and p_member in ('TEAM_SHARED', 'LEADERSHIP_RESTRICTED', 'ENGAGEMENT_SHARED')
      then true
    else false
  end
$$;

create or replace function consulting_security.validate_artifact_section()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_type consulting_os.artifact_type;
begin
  select artifact_type into v_type from consulting_os.artifacts
  where id = new.artifact_id and organization_id = new.organization_id;
  if not exists (
    select 1 from consulting_security.artifact_section_rules r
    where r.artifact_type = v_type and r.section_key = new.section_key
  ) then
    raise exception 'section is not valid for this artifact type' using errcode = '23514';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_artifact_member()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_artifact_type consulting_os.artifact_type;
  v_section_key text;
  v_section_artifact_id uuid;
  v_member_type text;
  v_artifact_visibility consulting_os.visibility_scope;
  v_member_visibility consulting_os.visibility_scope;
begin
  select a.artifact_type, d.visibility_scope into v_artifact_type, v_artifact_visibility
  from consulting_os.artifacts a
  join consulting_os.domain_objects d on d.id = a.id and d.organization_id = a.organization_id
  where a.id = new.artifact_id and a.organization_id = new.organization_id;

  select section_key, artifact_id into v_section_key, v_section_artifact_id
  from consulting_os.artifact_sections
  where id = new.section_id and organization_id = new.organization_id;

  select object_type, visibility_scope into v_member_type, v_member_visibility
  from consulting_os.domain_objects
  where id = new.member_id and organization_id = new.organization_id;

  if v_section_artifact_id is distinct from new.artifact_id
    or v_member_type is distinct from new.member_type
    or not exists (
      select 1 from consulting_security.artifact_section_rules r
      where r.artifact_type = v_artifact_type
        and r.section_key = v_section_key
        and v_member_type = any(r.allowed_member_types)
    )
  then
    raise exception 'artifact member type or section is invalid' using errcode = '23514';
  end if;
  if not consulting_security.visibility_can_contain(v_artifact_visibility, v_member_visibility) then
    raise exception 'artifact composition cannot broaden member visibility' using errcode = '42501';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_blueprint_member()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_member_type text;
  v_blueprint_visibility consulting_os.visibility_scope;
  v_member_visibility consulting_os.visibility_scope;
begin
  select d.visibility_scope into v_blueprint_visibility
  from consulting_os.domain_objects d
  where d.id = new.blueprint_id and d.organization_id = new.organization_id;
  select d.object_type, d.visibility_scope into v_member_type, v_member_visibility
  from consulting_os.domain_objects d
  where d.id = new.member_id and d.organization_id = new.organization_id;
  if v_member_type is distinct from new.member_type
    or v_member_type not in ('IDENTITY_ELEMENT', 'ORGANIZATIONAL_DNA', 'FUTURE_STATE_NARRATIVE', 'FUTURE_STATE_PRINCIPLE', 'FUTURE_STATE')
  then
    raise exception 'blueprint members must be approved identity or future-state objects'
      using errcode = '23514';
  end if;
  if not consulting_security.visibility_can_contain(v_blueprint_visibility, v_member_visibility) then
    raise exception 'blueprint composition cannot broaden member visibility' using errcode = '42501';
  end if;
  return new;
end
$$;

create or replace function consulting_security.validate_consulting_source()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_source_type consulting_os.evidence_source_type;
  v_record_visibility consulting_os.visibility_scope;
  v_source_visibility consulting_os.visibility_scope;
  v_expected consulting_os.evidence_source_type;
begin
  v_expected := case tg_table_name
    when 'interviews' then 'INTERVIEW'::consulting_os.evidence_source_type
    when 'assessment_administrations' then 'ASSESSMENT'::consulting_os.evidence_source_type
  end;
  select s.source_type, d.visibility_scope into v_source_type, v_source_visibility
  from consulting_os.evidence_sources s
  join consulting_os.domain_objects d on d.id = s.id and d.organization_id = s.organization_id
  where s.id = new.evidence_source_id and s.organization_id = new.organization_id;
  select visibility_scope into v_record_visibility from consulting_os.domain_objects
  where id = new.id and organization_id = new.organization_id;
  if v_source_type is distinct from v_expected or v_record_visibility is distinct from v_source_visibility then
    raise exception 'consulting activity must use a same-visibility source of the correct type'
      using errcode = '23514';
  end if;
  return new;
end
$$;

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
    if v_confidentiality = 'ANONYMOUS' and (
      new.respondent_person_id is not null
      or new.participant_token_hash is null
    ) then
      raise exception 'anonymous responses require a token hash and no respondent identity'
        using errcode = '23514';
    elsif v_confidentiality <> 'ANONYMOUS' and new.respondent_person_id is null then
      raise exception 'non-anonymous responses require a respondent identity'
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

create or replace function consulting_security.protect_assessment_definition()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_version_id uuid;
begin
  v_version_id := case when tg_table_name = 'assessment_instrument_versions' then old.id else old.instrument_version_id end;
  if exists (
    select 1 from consulting_os.assessment_administrations a
    where a.instrument_version_id = v_version_id
  ) then
    raise exception 'administered assessment definitions and items are immutable'
      using errcode = '55000';
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end
$$;

do $$
declare
  v_table text;
begin
  foreach v_table in array array[
    'risks', 'strengths', 'unrealized_potentials', 'diagnoses', 'interviews',
    'interview_responses', 'assessment_instruments', 'assessment_administrations',
    'assessment_responses', 'artifacts', 'identity_elements',
    'organizational_dna_versions', 'future_state_narratives',
    'future_state_principles', 'future_states', 'organizational_blueprints'
  ] loop
    execute format(
      'create trigger %I before insert on consulting_os.%I for each row execute function consulting_security.validate_typed_record()',
      v_table || '_typed_validate', v_table
    );
  end loop;
end
$$;
create trigger private_interview_responses_typed_validate before insert on consulting_private.interview_responses
for each row execute function consulting_security.validate_typed_record();
create trigger private_assessment_responses_typed_validate before insert on consulting_private.assessment_responses
for each row execute function consulting_security.validate_typed_record();

do $$
declare
  v_table text;
begin
  foreach v_table in array array[
    'artifacts', 'identity_elements', 'organizational_dna_versions',
    'future_state_narratives', 'future_state_principles', 'future_states',
    'organizational_blueprints'
  ] loop
    execute format(
      'create trigger %I before insert on consulting_os.%I for each row execute function consulting_security.validate_version_chain()',
      v_table || '_version_chain', v_table
    );
    execute format(
      'create trigger %I before update or delete on consulting_os.%I for each row execute function consulting_security.prevent_versioned_mutation()',
      v_table || '_immutable', v_table
    );
  end loop;
end
$$;

create trigger artifact_sections_validate before insert or update on consulting_os.artifact_sections
for each row execute function consulting_security.validate_artifact_section();
create trigger artifact_members_validate before insert or update on consulting_os.artifact_members
for each row execute function consulting_security.validate_artifact_member();
create trigger blueprint_members_validate before insert or update on consulting_os.blueprint_members
for each row execute function consulting_security.validate_blueprint_member();
create trigger interviews_source_validate before insert or update on consulting_os.interviews
for each row execute function consulting_security.validate_consulting_source();
create trigger administrations_source_validate before insert or update on consulting_os.assessment_administrations
for each row execute function consulting_security.validate_consulting_source();
create trigger interview_responses_provenance before insert or update on consulting_os.interview_responses
for each row execute function consulting_security.validate_response_provenance();
create trigger private_interview_responses_provenance before insert or update on consulting_private.interview_responses
for each row execute function consulting_security.validate_response_provenance();
create trigger assessment_responses_provenance before insert or update on consulting_os.assessment_responses
for each row execute function consulting_security.validate_response_provenance();
create trigger private_assessment_responses_provenance before insert or update on consulting_private.assessment_responses
for each row execute function consulting_security.validate_response_provenance();
create trigger assessment_versions_immutable_after_use before update or delete on consulting_os.assessment_instrument_versions
for each row execute function consulting_security.protect_assessment_definition();
create trigger assessment_items_immutable_after_use before update or delete on consulting_os.assessment_items
for each row execute function consulting_security.protect_assessment_definition();

insert into consulting_security.relationship_type_rules
  (relationship_type, source_type, target_type, rationale)
values
  ('SUPPORTED_BY', 'RISK', 'EVIDENCE', 'Risk is grounded in Evidence.'),
  ('SUPPORTED_BY', 'STRENGTH', 'EVIDENCE', 'Strength is grounded in Evidence.'),
  ('SUPPORTED_BY', 'UNREALIZED_POTENTIAL', 'EVIDENCE', 'Unrealized Potential is grounded in Evidence.'),
  ('SUPPORTED_BY', 'DIAGNOSIS', 'EVIDENCE', 'Diagnosis is grounded in Evidence.'),
  ('CHALLENGED_BY', 'DIAGNOSIS', 'EVIDENCE', 'Evidence challenges a Diagnosis.'),
  ('CHALLENGED_BY', 'DIAGNOSIS', 'OBSERVATION', 'Observation challenges a Diagnosis.'),
  ('VALIDATES', 'RECORD_REVIEW', 'DIAGNOSIS', 'Review validates a Diagnosis.'),
  ('DERIVED_FROM', 'DIAGNOSIS', 'PATTERN', 'Diagnosis derives from reviewed Patterns.'),
  ('DERIVED_FROM', 'DIAGNOSIS', 'INTERPRETATION', 'Diagnosis derives from reviewed Interpretations.'),
  ('DERIVED_FROM', 'IDENTITY_ELEMENT', 'INSIGHT', 'Identity statement derives from reviewed Insight.'),
  ('DERIVED_FROM', 'FUTURE_STATE_NARRATIVE', 'INSIGHT', 'Narrative derives from reviewed Insight.'),
  ('DERIVED_FROM', 'FUTURE_STATE_PRINCIPLE', 'FUTURE_STATE_NARRATIVE', 'Principle derives from the Future-State Narrative.'),
  ('DERIVED_FROM', 'FUTURE_STATE', 'FUTURE_STATE_NARRATIVE', 'Future State derives from the narrative.'),
  ('DERIVED_FROM', 'ORGANIZATIONAL_BLUEPRINT', 'FUTURE_STATE', 'Blueprint composes approved Future States.'),
  ('DERIVED_FROM', 'ARTIFACT', 'OBSERVATION', 'Artifact composes typed Observation records.'),
  ('DERIVED_FROM', 'ARTIFACT', 'PATTERN', 'Artifact composes typed Pattern records.'),
  ('DERIVED_FROM', 'ARTIFACT', 'ASSUMPTION', 'Artifact composes typed Assumption records.');

alter table consulting_os.risks enable row level security;
alter table consulting_os.strengths enable row level security;
alter table consulting_os.unrealized_potentials enable row level security;
alter table consulting_os.diagnoses enable row level security;
alter table consulting_os.interviews enable row level security;
alter table consulting_os.interview_responses enable row level security;
alter table consulting_private.interview_responses enable row level security;
alter table consulting_os.assessment_instruments enable row level security;
alter table consulting_os.assessment_instrument_versions enable row level security;
alter table consulting_os.assessment_items enable row level security;
alter table consulting_os.assessment_administrations enable row level security;
alter table consulting_os.assessment_responses enable row level security;
alter table consulting_private.assessment_responses enable row level security;
alter table consulting_os.artifacts enable row level security;
alter table consulting_os.artifact_sections enable row level security;
alter table consulting_os.artifact_members enable row level security;
alter table consulting_os.identity_elements enable row level security;
alter table consulting_os.organizational_dna_versions enable row level security;
alter table consulting_os.organizational_dna_elements enable row level security;
alter table consulting_os.future_state_narratives enable row level security;
alter table consulting_os.future_state_principles enable row level security;
alter table consulting_os.future_states enable row level security;
alter table consulting_os.organizational_blueprints enable row level security;
alter table consulting_os.blueprint_members enable row level security;
alter table consulting_security.artifact_section_rules enable row level security;

do $$
declare
  v_table text;
begin
  foreach v_table in array array[
    'risks', 'strengths', 'unrealized_potentials', 'diagnoses', 'interviews',
    'interview_responses', 'assessment_instruments', 'assessment_administrations',
    'assessment_responses', 'artifacts', 'identity_elements',
    'organizational_dna_versions', 'future_state_narratives',
    'future_state_principles', 'future_states', 'organizational_blueprints'
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
end
$$;

create policy assessment_versions_select_visible on consulting_os.assessment_instrument_versions
for select to authenticated using (consulting_security.can_read_domain_object(instrument_id, organization_id));
create policy assessment_versions_insert_authorized on consulting_os.assessment_instrument_versions
for insert to authenticated with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(instrument_id, organization_id)
);
create policy assessment_items_select_visible on consulting_os.assessment_items
for select to authenticated using (exists (
  select 1 from consulting_os.assessment_instrument_versions v
  where v.id = consulting_os.assessment_items.instrument_version_id
    and v.organization_id = consulting_os.assessment_items.organization_id
    and consulting_security.can_read_domain_object(v.instrument_id, v.organization_id)
));
create policy assessment_items_insert_authorized on consulting_os.assessment_items
for insert to authenticated with check (exists (
  select 1 from consulting_os.assessment_instrument_versions v
  where v.id = consulting_os.assessment_items.instrument_version_id
    and v.organization_id = consulting_os.assessment_items.organization_id
    and consulting_os.assessment_items.created_by = consulting_security.current_person_id()
    and consulting_security.can_manage_domain_object(v.instrument_id, v.organization_id)
));
create policy artifact_sections_select_visible on consulting_os.artifact_sections
for select to authenticated using (consulting_security.can_read_domain_object(artifact_id, organization_id));
create policy artifact_sections_insert_authorized on consulting_os.artifact_sections
for insert to authenticated with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(artifact_id, organization_id)
);
create policy artifact_members_select_visible on consulting_os.artifact_members
for select to authenticated using (
  consulting_security.can_read_domain_object(artifact_id, organization_id)
  and consulting_security.can_read_domain_object(member_id, organization_id)
);
create policy artifact_members_insert_authorized on consulting_os.artifact_members
for insert to authenticated with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(artifact_id, organization_id)
  and consulting_security.can_read_domain_object(member_id, organization_id)
);
create policy dna_elements_select_visible on consulting_os.organizational_dna_elements
for select to authenticated using (
  consulting_security.can_read_domain_object(dna_version_id, organization_id)
  and consulting_security.can_read_domain_object(identity_element_id, organization_id)
);
create policy dna_elements_insert_authorized on consulting_os.organizational_dna_elements
for insert to authenticated with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(dna_version_id, organization_id)
  and consulting_security.can_read_domain_object(identity_element_id, organization_id)
);
create policy blueprint_members_select_visible on consulting_os.blueprint_members
for select to authenticated using (
  consulting_security.can_read_domain_object(blueprint_id, organization_id)
  and consulting_security.can_read_domain_object(member_id, organization_id)
);
create policy blueprint_members_insert_authorized on consulting_os.blueprint_members
for insert to authenticated with check (
  created_by = consulting_security.current_person_id()
  and consulting_security.can_manage_domain_object(blueprint_id, organization_id)
  and consulting_security.can_read_domain_object(member_id, organization_id)
);

do $$
declare
  v_table text;
begin
  foreach v_table in array array[
    'risks', 'strengths', 'unrealized_potentials', 'diagnoses', 'interviews',
    'interview_responses', 'assessment_instruments', 'assessment_administrations',
    'assessment_responses', 'artifacts', 'identity_elements',
    'organizational_dna_versions', 'future_state_narratives',
    'future_state_principles', 'future_states', 'organizational_blueprints'
  ] loop
    execute format('revoke all on consulting_os.%I from public, anon, authenticated', v_table);
    execute format('grant select, insert on consulting_os.%I to authenticated', v_table);
    execute format('grant all on consulting_os.%I to service_role', v_table);
  end loop;
end
$$;

do $$
declare
  v_table text;
begin
  foreach v_table in array array[
    'assessment_instrument_versions', 'assessment_items', 'artifact_sections',
    'artifact_members', 'organizational_dna_elements', 'blueprint_members'
  ] loop
    execute format('revoke all on consulting_os.%I from public, anon, authenticated', v_table);
    execute format('grant select, insert on consulting_os.%I to authenticated', v_table);
    execute format('grant all on consulting_os.%I to service_role', v_table);
  end loop;
end
$$;

revoke all on consulting_private.interview_responses from public, anon, authenticated;
revoke all on consulting_private.assessment_responses from public, anon, authenticated;
grant all on consulting_private.interview_responses to service_role;
grant all on consulting_private.assessment_responses to service_role;
revoke all on consulting_security.artifact_section_rules from public, anon, authenticated;
grant select on consulting_security.artifact_section_rules to service_role;
revoke all on function consulting_security.prevent_versioned_mutation() from public, anon;
revoke all on function consulting_security.validate_version_chain() from public, anon;
revoke all on function consulting_security.visibility_can_contain(consulting_os.visibility_scope, consulting_os.visibility_scope) from public, anon;
revoke all on function consulting_security.validate_artifact_section() from public, anon;
revoke all on function consulting_security.validate_artifact_member() from public, anon;
revoke all on function consulting_security.validate_blueprint_member() from public, anon;
revoke all on function consulting_security.validate_consulting_source() from public, anon;
revoke all on function consulting_security.validate_response_provenance() from public, anon;
revoke all on function consulting_security.protect_assessment_definition() from public, anon;

create or replace view consulting_os.epistemic_record_states
with (security_invoker = true)
as
with initial_states as (
  select id, organization_id, 'OBSERVATION'::text object_type, initial_review_state from consulting_os.observations
  union all select id, organization_id, 'PATTERN', initial_review_state from consulting_os.patterns
  union all select id, organization_id, 'ASSUMPTION',
    case when assumption_status = 'SUPERSEDED' then 'SUPERSEDED'::consulting_os.epistemic_review_state else initial_review_state end
    from consulting_os.assumptions
  union all select id, organization_id, 'HYPOTHESIS', initial_review_state from consulting_os.hypotheses
  union all select id, organization_id, 'INTERPRETATION', initial_review_state from consulting_os.interpretations
  union all select id, organization_id, 'INSIGHT', initial_review_state from consulting_os.insights
  union all select id, organization_id, 'RISK', initial_review_state from consulting_os.risks
  union all select id, organization_id, 'STRENGTH', initial_review_state from consulting_os.strengths
  union all select id, organization_id, 'UNREALIZED_POTENTIAL', initial_review_state from consulting_os.unrealized_potentials
  union all select id, organization_id, 'DIAGNOSIS', initial_review_state from consulting_os.diagnoses
)
select s.id, s.organization_id, s.object_type, d.origin,
  coalesce(r.review_action, s.initial_review_state) current_review_state,
  d.created_at
from initial_states s
join consulting_os.domain_objects d on d.id = s.id and d.organization_id = s.organization_id
left join consulting_os.latest_record_reviews r on r.subject_id = s.id and r.organization_id = s.organization_id
where d.archived_at is null;

create or replace view consulting_os.assumption_register
with (security_invoker = true)
as
select a.id, a.organization_id, a.logical_id, a.version_number, a.statement,
  a.holder_scope, a.assumption_status, a.confidence_level, a.confidence_rationale,
  a.review_trigger, a.effective_from, a.effective_to,
  count(*) filter (where er.relationship_type = 'SUPPORTED_BY') supporting_links,
  count(*) filter (where er.relationship_type = 'CHALLENGED_BY') challenging_links
from consulting_os.current_assumptions a
left join consulting_os.entity_relationships er
  on er.source_id = a.id and er.organization_id = a.organization_id
  and er.relationship_type in ('SUPPORTED_BY', 'CHALLENGED_BY')
group by a.id, a.organization_id, a.logical_id, a.version_number, a.statement,
  a.holder_scope, a.assumption_status, a.confidence_level, a.confidence_rationale,
  a.review_trigger, a.effective_from, a.effective_to;

create or replace view consulting_os.artifact_completion
with (security_invoker = true)
as
select a.id, a.organization_id, a.artifact_type, a.title, a.artifact_status,
  count(distinct s.section_key) section_count,
  count(m.id) member_count,
  (count(distinct s.section_key) = 10
    and count(distinct s.id) filter (where m.id is not null) = 10
  ) is_complete
from consulting_os.artifacts a
left join consulting_os.artifact_sections s on s.artifact_id = a.id and s.organization_id = a.organization_id
left join consulting_os.artifact_members m
  on m.artifact_id = a.id and m.organization_id = a.organization_id
  and m.section_id = s.id
group by a.id, a.organization_id, a.artifact_type, a.title, a.artifact_status;

create or replace view consulting_os.current_identity_elements
with (security_invoker = true)
as
select i.* from consulting_os.identity_elements i
where i.effective_from <= now() and (i.effective_to is null or i.effective_to > now())
  and not exists (
    select 1 from consulting_os.identity_elements newer
    where newer.organization_id = i.organization_id and newer.logical_id = i.logical_id
      and newer.version_number > i.version_number and newer.effective_from <= now()
  );

create or replace view consulting_os.current_organizational_dna
with (security_invoker = true)
as
select d.* from consulting_os.organizational_dna_versions d
where d.effective_from <= now() and (d.effective_to is null or d.effective_to > now())
  and not exists (
    select 1 from consulting_os.organizational_dna_versions newer
    where newer.organization_id = d.organization_id and newer.logical_id = d.logical_id
      and newer.version_number > d.version_number and newer.effective_from <= now()
  );

create or replace view consulting_os.current_future_state_narratives
with (security_invoker = true)
as
select n.* from consulting_os.future_state_narratives n
where n.effective_from <= now() and (n.effective_to is null or n.effective_to > now())
  and not exists (
    select 1 from consulting_os.future_state_narratives newer
    where newer.organization_id = n.organization_id and newer.logical_id = n.logical_id
      and newer.version_number > n.version_number and newer.effective_from <= now()
  );

create or replace view consulting_os.current_future_states
with (security_invoker = true)
as
select f.* from consulting_os.future_states f
where f.effective_from <= now() and (f.effective_to is null or f.effective_to > now())
  and not exists (
    select 1 from consulting_os.future_states newer
    where newer.organization_id = f.organization_id and newer.logical_id = f.logical_id
      and newer.version_number > f.version_number and newer.effective_from <= now()
  );

create or replace view consulting_os.current_organizational_blueprints
with (security_invoker = true)
as
select b.* from consulting_os.organizational_blueprints b
where b.effective_from <= now() and (b.effective_to is null or b.effective_to > now())
  and b.artifact_status = 'APPROVED'
  and not exists (
    select 1 from consulting_os.organizational_blueprints newer
    where newer.organization_id = b.organization_id and newer.logical_id = b.logical_id
      and newer.version_number > b.version_number and newer.effective_from <= now()
  );

create or replace view consulting_os.client_visible_validated_conclusions
with (security_invoker = true)
as
with conclusions as (
  select id, organization_id, 'INSIGHT'::text object_type, statement, rationale, limitations from consulting_os.insights
  union all
  select id, organization_id, 'DIAGNOSIS', statement, rationale, limitations from consulting_os.diagnoses
)
select c.id, c.organization_id, c.object_type, c.statement, c.rationale, c.limitations,
  r.reviewer_person_id, r.reviewed_at
from conclusions c
join consulting_os.latest_record_reviews r
  on r.subject_id = c.id and r.organization_id = c.organization_id and r.review_action = 'VALIDATED'
join consulting_os.domain_objects d on d.id = c.id and d.organization_id = c.organization_id
where d.visibility_scope not in ('CONSULTANT_PRIVATE', 'INDIVIDUAL_PRIVATE', 'COACHING_SHARED');

create or replace view consulting_os.assessment_response_provenance
with (security_invoker = true)
as
select r.id, r.organization_id, r.administration_id, r.item_id,
  a.instrument_version_id, v.version_number, v.compatibility_key,
  r.evidence_fragment_id, f.evidence_source_id, r.submitted_at
from consulting_os.assessment_responses r
join consulting_os.assessment_administrations a
  on a.id = r.administration_id and a.organization_id = r.organization_id
join consulting_os.assessment_instrument_versions v
  on v.id = a.instrument_version_id and v.organization_id = a.organization_id
join consulting_os.evidence_fragments f
  on f.id = r.evidence_fragment_id and f.organization_id = r.organization_id;

grant select on consulting_os.epistemic_record_states to authenticated, service_role;
grant select on consulting_os.assumption_register to authenticated, service_role;
grant select on consulting_os.artifact_completion to authenticated, service_role;
grant select on consulting_os.current_identity_elements to authenticated, service_role;
grant select on consulting_os.current_organizational_dna to authenticated, service_role;
grant select on consulting_os.current_future_state_narratives to authenticated, service_role;
grant select on consulting_os.current_future_states to authenticated, service_role;
grant select on consulting_os.current_organizational_blueprints to authenticated, service_role;
grant select on consulting_os.client_visible_validated_conclusions to authenticated, service_role;
grant select on consulting_os.assessment_response_provenance to authenticated, service_role;

comment on table consulting_os.artifacts is
  'Versioned structured Organizational Portrait or Current-State Reality Map; sections and typed members remain first-class.';
comment on table consulting_os.assessment_instrument_versions is
  'Bounded versioned assessment definition; immutable after administration and never self-interpreting diagnosis.';
comment on view consulting_os.client_visible_validated_conclusions is
  'Validated non-private conclusions only; private consultant analysis is never promoted by this view.';
