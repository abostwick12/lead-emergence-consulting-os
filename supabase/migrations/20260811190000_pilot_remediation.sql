-- Lead Emergence Consulting OS — pilot-readiness remediation commands.
-- Additive only. These commands preserve typed domain records and existing RLS.

create or replace function consulting_os.record_development_practice(
  p_requirement_id uuid,
  p_name text,
  p_conditions text,
  p_repetition_target text,
  p_feedback_method text
) returns uuid
language plpgsql
security definer
set search_path = consulting_os, consulting_security, pg_temp
as $$
declare
  v_person_id uuid := consulting_security.current_person_id();
  v_organization_id uuid;
  v_engagement_id uuid;
  v_development_plan_id uuid;
  v_capability_id uuid;
  v_practice_id uuid := gen_random_uuid();
begin
  if v_person_id is null then
    raise exception 'Authentication is required.';
  end if;

  select organization_id, engagement_id, development_plan_id, capability_id
    into v_organization_id, v_engagement_id, v_development_plan_id, v_capability_id
  from consulting_os.capability_pathways
  where requirement_id = p_requirement_id;

  if v_organization_id is null or v_development_plan_id is null then
    raise exception 'An authorized development plan is required before recording practice.';
  end if;

  if not consulting_security.has_active_consultant_assignment(v_organization_id)
     or not consulting_security.can_manage_domain_object(p_requirement_id, v_organization_id)
     or not consulting_security.can_manage_domain_object(v_development_plan_id, v_organization_id) then
    raise exception 'Assigned consultant authorization is required.';
  end if;

  if length(btrim(coalesce(p_name, ''))) = 0
     or length(btrim(coalesce(p_conditions, ''))) = 0
     or length(btrim(coalesce(p_repetition_target, ''))) = 0
     or length(btrim(coalesce(p_feedback_method, ''))) = 0 then
    raise exception 'Practice, conditions, repetition target, and feedback method are required.';
  end if;

  insert into consulting_os.domain_objects(
    id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by
  ) values (
    v_practice_id, v_organization_id, v_engagement_id, 'PRACTICE',
    'ENGAGEMENT_SHARED', 'HUMAN', v_person_id
  );

  insert into consulting_os.practices(
    id, organization_id, development_plan_id, capability_id, name,
    conditions, repetition_target, feedback_method, created_by
  ) values (
    v_practice_id, v_organization_id, v_development_plan_id, v_capability_id,
    btrim(p_name), btrim(p_conditions), btrim(p_repetition_target),
    btrim(p_feedback_method), v_person_id
  );

  return v_practice_id;
end;
$$;

revoke all on function consulting_os.record_development_practice(uuid, text, text, text, text)
  from public, anon;
grant execute on function consulting_os.record_development_practice(uuid, text, text, text, text)
  to authenticated, service_role;

comment on function consulting_os.record_development_practice(uuid, text, text, text, text)
  is 'Atomically records consultant-authorized capability practice as a typed, engagement-shared domain object.';

create or replace function consulting_os.start_client_engagement(
  p_organization_name text,
  p_engagement_name text,
  p_starts_on date,
  p_ends_on date default null
) returns table(organization_id uuid, engagement_id uuid)
language plpgsql
security definer
set search_path = consulting_os, consulting_security, pg_temp
as $$
declare
  v_person_id uuid := consulting_security.current_person_id();
  v_organization_id uuid := gen_random_uuid();
  v_engagement_id uuid := gen_random_uuid();
  v_slug_base text;
  v_slug text;
begin
  if v_person_id is null then
    raise exception 'Authentication is required.';
  end if;

  if not consulting_security.is_platform_admin()
     and not exists (
       select 1 from consulting_os.consultant_assignments
       where consultant_person_id = v_person_id and status = 'ACTIVE'
         and effective_from <= now()
         and (effective_to is null or effective_to > now())
     ) then
    raise exception 'An active consultant assignment or platform administrator role is required.';
  end if;

  if length(btrim(coalesce(p_organization_name, ''))) = 0
     or length(btrim(coalesce(p_engagement_name, ''))) = 0
     or p_starts_on is null then
    raise exception 'Organization name, engagement name, and start date are required.';
  end if;
  if p_ends_on is not null and p_ends_on < p_starts_on then
    raise exception 'Engagement end date cannot precede its start date.';
  end if;

  v_slug_base := trim(both '-' from regexp_replace(lower(btrim(p_organization_name)), '[^a-z0-9]+', '-', 'g'));
  if length(v_slug_base) = 0 then v_slug_base := 'client'; end if;
  v_slug := v_slug_base;
  if exists (select 1 from consulting_os.organizations where slug = v_slug) then
    v_slug := v_slug_base || '-' || substr(replace(v_organization_id::text, '-', ''), 1, 8);
  end if;

  insert into consulting_os.organizations(id, name, slug, created_by)
  values (v_organization_id, btrim(p_organization_name), v_slug, v_person_id);

  insert into consulting_os.consultant_assignments(
    organization_id, consultant_person_id, status, assignment_reason, created_by
  ) values (
    v_organization_id, v_person_id, 'ACTIVE',
    'Consultant initiated client engagement setup.', v_person_id
  );

  insert into consulting_os.engagements(
    id, organization_id, name, status, starts_on, ends_on, created_by
  ) values (
    v_engagement_id, v_organization_id, btrim(p_engagement_name), 'ACTIVE',
    p_starts_on, p_ends_on, v_person_id
  );

  return query select v_organization_id, v_engagement_id;
end;
$$;

revoke all on function consulting_os.start_client_engagement(text, text, date, date)
  from public, anon;
grant execute on function consulting_os.start_client_engagement(text, text, date, date)
  to authenticated, service_role;

comment on function consulting_os.start_client_engagement(text, text, date, date)
  is 'Creates a tenant, self-assignment, and active consulting engagement atomically for an authorized consultant.';

create or replace view consulting_os.value_outcome_pathways with (security_invoker = true) as
select
  i.organization_id,
  g.engagement_id,
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
from consulting_os.current_indicators i
join consulting_os.current_goals g
  on g.id = i.goal_id and g.organization_id = i.organization_id
join consulting_os.current_value_hypotheses h
  on h.id = i.value_hypothesis_id and h.organization_id = i.organization_id
left join lateral (
  select candidate.* from consulting_os.outcomes candidate
  where candidate.organization_id = i.organization_id
    and candidate.engagement_id = g.engagement_id
    and candidate.goal_id = g.id
    and candidate.value_hypothesis_id = h.id
  order by candidate.period_end desc, candidate.created_at desc limit 1
) o on true
left join consulting_os.measurements m
  on m.id = o.primary_measurement_id and m.organization_id = o.organization_id
left join lateral (
  select candidate.* from consulting_os.value_evaluations candidate
  where candidate.outcome_id = o.id and candidate.organization_id = o.organization_id
  order by candidate.evaluated_at desc, candidate.created_at desc limit 1
) ve on true
left join lateral (
  select candidate.* from consulting_os.learnings candidate
  where candidate.value_evaluation_id = ve.id and candidate.organization_id = ve.organization_id
  order by candidate.created_at desc limit 1
) l on true
left join consulting_os.latest_record_reviews rr
  on rr.subject_id = l.id and rr.organization_id = l.organization_id
left join lateral (
  select candidate.* from consulting_os.outcome_decisions candidate
  where candidate.learning_id = l.id and candidate.organization_id = l.organization_id
  order by candidate.decided_at desc, candidate.created_at desc limit 1
) od on true;

create or replace function consulting_os.record_value_outcome(
  p_indicator_id uuid,
  p_evidence_id uuid,
  p_measured_value text,
  p_statement text,
  p_collection_context text,
  p_limitations text,
  p_period_start timestamptz,
  p_period_end timestamptz
) returns uuid
language plpgsql
security definer
set search_path = consulting_os, consulting_security, pg_temp
as $$
declare
  v_actor uuid := consulting_security.current_person_id();
  v_path record;
  v_measurement_id uuid := gen_random_uuid();
  v_outcome_id uuid := gen_random_uuid();
begin
  select i.organization_id, g.engagement_id, g.id as goal_id,
         h.id as hypothesis_id, h.intervention_id
    into v_path
  from consulting_os.current_indicators i
  join consulting_os.current_goals g on g.id = i.goal_id and g.organization_id = i.organization_id
  join consulting_os.current_value_hypotheses h on h.id = i.value_hypothesis_id and h.organization_id = i.organization_id
  where i.id = p_indicator_id;
  if v_actor is null or v_path.organization_id is null
     or not consulting_security.can_manage_domain_object(p_indicator_id, v_path.organization_id) then
    raise exception 'An authorized consultant and a current value pathway are required.';
  end if;
  if not exists (select 1 from consulting_os.evidence_items where id = p_evidence_id and organization_id = v_path.organization_id)
     or not consulting_security.can_read_domain_object(p_evidence_id, v_path.organization_id) then
    raise exception 'A visible evidence item from this organization is required.';
  end if;
  if p_period_start is null or p_period_end is null or p_period_end < p_period_start or p_period_end > now() then
    raise exception 'The measurement period must be valid and cannot end in the future.';
  end if;
  if length(btrim(coalesce(p_measured_value, ''))) = 0 or length(btrim(coalesce(p_statement, ''))) = 0
     or length(btrim(coalesce(p_collection_context, ''))) = 0 or length(btrim(coalesce(p_limitations, ''))) = 0 then
    raise exception 'Measurement, outcome, collection context, and limitations are required.';
  end if;
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by)
  values (v_measurement_id, v_path.organization_id, v_path.engagement_id, 'MEASUREMENT', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.measurements(id, organization_id, engagement_id, indicator_id, primary_evidence_id, measured_at, period_start, period_end, value_payload, display_value, collection_context, limitations, created_by)
  values (v_measurement_id, v_path.organization_id, v_path.engagement_id, p_indicator_id, p_evidence_id, now(), p_period_start, p_period_end, to_jsonb(btrim(p_measured_value)), btrim(p_measured_value), btrim(p_collection_context), btrim(p_limitations), v_actor);
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by)
  values (v_outcome_id, v_path.organization_id, v_path.engagement_id, 'OUTCOME', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.outcomes(id, organization_id, engagement_id, goal_id, value_hypothesis_id, intervention_id, primary_measurement_id, primary_evidence_id, statement, observed_value, period_start, period_end, evidence_summary, interpretation_status, created_by)
  values (v_outcome_id, v_path.organization_id, v_path.engagement_id, v_path.goal_id, v_path.hypothesis_id, v_path.intervention_id, v_measurement_id, p_evidence_id, btrim(p_statement), btrim(p_measured_value), p_period_start, p_period_end, btrim(p_collection_context), 'OBSERVED', v_actor);
  return v_outcome_id;
end;
$$;

create or replace function consulting_os.record_value_evaluation(
  p_outcome_id uuid, p_harvest text, p_soil text, p_significance text,
  p_alternative_explanations text, p_limitations text
) returns uuid
language plpgsql security definer
set search_path = consulting_os, consulting_security, pg_temp
as $$
declare v_actor uuid := consulting_security.current_person_id(); v_outcome consulting_os.outcomes%rowtype; v_id uuid := gen_random_uuid();
begin
  select * into v_outcome from consulting_os.outcomes where id = p_outcome_id;
  if v_actor is null or v_outcome.id is null or not consulting_security.can_manage_domain_object(p_outcome_id, v_outcome.organization_id) then raise exception 'Outcome management permission is required.'; end if;
  if length(btrim(coalesce(p_harvest,''))) = 0 or length(btrim(coalesce(p_soil,''))) = 0 or length(btrim(coalesce(p_significance,''))) = 0 or length(btrim(coalesce(p_alternative_explanations,''))) = 0 or length(btrim(coalesce(p_limitations,''))) = 0 then raise exception 'Harvest, soil, significance, alternatives, and limitations are required.'; end if;
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_id, v_outcome.organization_id, v_outcome.engagement_id, 'VALUE_EVALUATION', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.value_evaluations(id, organization_id, engagement_id, outcome_id, value_hypothesis_id, harvest_finding, soil_finding, mission_rating, mission_assessment, human_rating, human_assessment, operational_rating, operational_assessment, economic_rating, economic_assessment, sustainable_rating, sustainable_assessment, significance, alternative_explanations, limitations, evaluated_by, evaluated_at, created_by)
  values (v_id, v_outcome.organization_id, v_outcome.engagement_id, v_outcome.id, v_outcome.value_hypothesis_id, btrim(p_harvest), btrim(p_soil), 'MIXED', btrim(p_significance), 'MIXED', btrim(p_significance), 'MIXED', btrim(p_harvest), 'MIXED', btrim(p_harvest), 'MIXED', btrim(p_soil), btrim(p_significance), btrim(p_alternative_explanations), btrim(p_limitations), v_actor, now(), v_actor);
  return v_id;
end;
$$;

create or replace function consulting_os.validate_outcome_learning(
  p_evaluation_id uuid, p_statement text, p_disposition consulting_os.outcome_disposition,
  p_implications text, p_contrary_evidence text, p_limitations text
) returns uuid
language plpgsql security definer
set search_path = consulting_os, consulting_security, pg_temp
as $$
declare v_actor uuid := consulting_security.current_person_id(); v_evaluation consulting_os.value_evaluations%rowtype; v_learning_id uuid := gen_random_uuid(); v_review_id uuid := gen_random_uuid(); v_decision_id uuid := gen_random_uuid();
begin
  select * into v_evaluation from consulting_os.value_evaluations where id = p_evaluation_id;
  if v_actor is null or v_evaluation.id is null or not consulting_security.can_manage_domain_object(p_evaluation_id, v_evaluation.organization_id) then raise exception 'Evaluation management permission is required.'; end if;
  if length(btrim(coalesce(p_statement,''))) = 0 or length(btrim(coalesce(p_implications,''))) = 0 or length(btrim(coalesce(p_contrary_evidence,''))) = 0 or length(btrim(coalesce(p_limitations,''))) = 0 then raise exception 'Learning, implications, contrary evidence, and limitations are required.'; end if;
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_learning_id, v_evaluation.organization_id, v_evaluation.engagement_id, 'LEARNING', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.learnings(id, organization_id, engagement_id, value_evaluation_id, statement, evidence_summary, implications, limitations, created_by) values (v_learning_id, v_evaluation.organization_id, v_evaluation.engagement_id, v_evaluation.id, btrim(p_statement), 'Human review of the recorded outcome and Harvest and Soil evaluation.', btrim(p_implications), btrim(p_limitations), v_actor);
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_review_id, v_evaluation.organization_id, v_evaluation.engagement_id, 'RECORD_REVIEW', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.record_reviews(id, organization_id, subject_id, review_action, reviewer_person_id, rationale, evidence_considered, contrary_evidence, limitations, reviewed_at, created_by) values (v_review_id, v_evaluation.organization_id, v_learning_id, 'VALIDATED', v_actor, btrim(p_statement), 'Recorded outcome and value evaluation.', btrim(p_contrary_evidence), btrim(p_limitations), now(), v_actor);
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_decision_id, v_evaluation.organization_id, v_evaluation.engagement_id, 'OUTCOME_DECISION', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.outcome_decisions(id, organization_id, engagement_id, learning_id, disposition, rationale, next_action, authorized_by, decided_at, created_by) values (v_decision_id, v_evaluation.organization_id, v_evaluation.engagement_id, v_learning_id, p_disposition, btrim(p_statement), btrim(p_implications), v_actor, now(), v_actor);
  return v_learning_id;
end;
$$;

create or replace function consulting_os.establish_new_reality(
  p_organization_id uuid, p_engagement_id uuid, p_profile_name text,
  p_actual_state text, p_difference text
) returns uuid
language plpgsql security definer
set search_path = consulting_os, consulting_security, pg_temp
as $$
declare v_actor uuid := consulting_security.current_person_id(); v_future consulting_os.future_states%rowtype; v_profile_id uuid := gen_random_uuid(); v_difference_id uuid := gen_random_uuid(); v_baseline_id uuid;
begin
  select f.* into v_future from consulting_os.current_future_states f join consulting_os.domain_objects d on d.id = f.id and d.organization_id = f.organization_id where f.organization_id = p_organization_id and d.engagement_id = p_engagement_id order by f.effective_from desc limit 1;
  if v_actor is null or v_future.id is null or not consulting_security.has_active_consultant_assignment(p_organization_id) then raise exception 'An assigned consultant and current Future State are required.'; end if;
  if length(btrim(coalesce(p_profile_name,''))) = 0 or length(btrim(coalesce(p_actual_state,''))) = 0 or length(btrim(coalesce(p_difference,''))) = 0 then raise exception 'Profile name, actual state, and difference are required.'; end if;
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_profile_id, p_organization_id, p_engagement_id, 'EMERGENT_ORGANIZATION_PROFILE', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.emergent_organization_profiles(id, organization_id, engagement_id, logical_id, version_number, intended_future_state_id, name, identity_state, purpose_state, culture_state, people_state, structure_state, systems_state, technology_state, relationships_state, value_state, stories_state, assumptions_state, status, effective_from, created_by)
  values (v_profile_id, p_organization_id, p_engagement_id, gen_random_uuid(), 1, v_future.id, btrim(p_profile_name), btrim(p_actual_state), btrim(p_actual_state), btrim(p_actual_state), btrim(p_actual_state), btrim(p_actual_state), btrim(p_actual_state), btrim(p_actual_state), btrim(p_actual_state), btrim(p_actual_state), btrim(p_actual_state), btrim(p_actual_state), 'APPROVED', now(), v_actor);
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_difference_id, p_organization_id, p_engagement_id, 'EMERGENT_REALITY_DIFFERENCE', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.emergent_reality_differences(id, organization_id, engagement_id, intended_future_state_id, emergent_profile_id, dimension, intended_state, actual_state, difference_statement, interpretation, unexpected_value, new_tensions, review_status, created_by)
  values (v_difference_id, p_organization_id, p_engagement_id, v_future.id, v_profile_id, v_future.state_domain, v_future.desired_condition, btrim(p_actual_state), btrim(p_difference), btrim(p_difference), 'To be reviewed in the next SEE AGAIN cycle.', 'To be reviewed in the next SEE AGAIN cycle.', 'ACCEPTED', v_actor);
  v_baseline_id := consulting_os.create_baseline_snapshot(v_profile_id, now(), 'Approved Emergent Organization Profile', 'Carry the human-approved New Reality into the next inquiry cycle.');
  return v_baseline_id;
end;
$$;

revoke all on function consulting_os.record_value_outcome(uuid, uuid, text, text, text, text, timestamptz, timestamptz) from public, anon;
revoke all on function consulting_os.record_value_evaluation(uuid, text, text, text, text, text) from public, anon;
revoke all on function consulting_os.validate_outcome_learning(uuid, text, consulting_os.outcome_disposition, text, text, text) from public, anon;
revoke all on function consulting_os.establish_new_reality(uuid, uuid, text, text, text) from public, anon;
grant execute on function consulting_os.record_value_outcome(uuid, uuid, text, text, text, text, timestamptz, timestamptz) to authenticated, service_role;
grant execute on function consulting_os.record_value_evaluation(uuid, text, text, text, text, text) to authenticated, service_role;
grant execute on function consulting_os.validate_outcome_learning(uuid, text, consulting_os.outcome_disposition, text, text, text) to authenticated, service_role;
grant execute on function consulting_os.establish_new_reality(uuid, uuid, text, text, text) to authenticated, service_role;

create or replace function consulting_os.capture_discovery_evidence(
  p_organization_id uuid, p_engagement_id uuid,
  p_source_type consulting_os.evidence_source_type, p_title text,
  p_provenance_context text, p_content text, p_relevance_note text,
  p_limitations text default null
) returns uuid
language plpgsql security definer
set search_path = consulting_os, consulting_security, pg_temp
as $$
declare v_actor uuid := consulting_security.current_person_id(); v_source_id uuid := gen_random_uuid(); v_fragment_id uuid := gen_random_uuid(); v_evidence_id uuid := gen_random_uuid();
begin
  if v_actor is null or not consulting_security.has_active_consultant_assignment(p_organization_id) then raise exception 'Assigned consultant authorization is required.'; end if;
  if not exists (select 1 from consulting_os.engagements where id = p_engagement_id and organization_id = p_organization_id) then raise exception 'The engagement is not available in this organization.'; end if;
  if length(btrim(coalesce(p_title,''))) = 0 or length(btrim(coalesce(p_provenance_context,''))) = 0 or length(btrim(coalesce(p_content,''))) = 0 or length(btrim(coalesce(p_relevance_note,''))) = 0 then raise exception 'Title, provenance, content, and relevance are required.'; end if;
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_source_id, p_organization_id, p_engagement_id, 'EVIDENCE_SOURCE', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.evidence_sources(id, organization_id, source_type, title, captured_at, provenance_context, created_by) values (v_source_id, p_organization_id, p_source_type, btrim(p_title), now(), btrim(p_provenance_context), v_actor);
  insert into consulting_os.evidence_fragments(id, organization_id, evidence_source_id, locator_kind, locator, content_text, content_sha256, captured_context, created_by) values (v_fragment_id, p_organization_id, v_source_id, 'TEXT', jsonb_build_object('source','consultant_discovery_intake'), p_content, encode(extensions.digest(convert_to(p_content, 'UTF8'), 'sha256'), 'hex'), p_provenance_context, v_actor);
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_evidence_id, p_organization_id, p_engagement_id, 'EVIDENCE', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.evidence_items(id, organization_id, primary_fragment_id, evidence_type, relevance_note, limitations, created_by) values (v_evidence_id, p_organization_id, v_fragment_id, 'DISCOVERY_INTAKE', btrim(p_relevance_note), nullif(btrim(coalesce(p_limitations,'')), ''), v_actor);
  return v_evidence_id;
end;
$$;

create or replace function consulting_os.record_discovery_interview(
  p_organization_id uuid, p_engagement_id uuid, p_participant_label text,
  p_guide_name text, p_question text, p_response text, p_consent_recorded boolean
) returns uuid
language plpgsql security definer
set search_path = consulting_os, consulting_security, pg_temp
as $$
declare v_actor uuid := consulting_security.current_person_id(); v_source_id uuid := gen_random_uuid(); v_fragment_id uuid := gen_random_uuid(); v_interview_id uuid := gen_random_uuid(); v_response_id uuid := gen_random_uuid();
begin
  if v_actor is null or not consulting_security.has_active_consultant_assignment(p_organization_id) then raise exception 'Assigned consultant authorization is required.'; end if;
  if not coalesce(p_consent_recorded, false) then raise exception 'Recorded consent is required before storing a completed interview response.'; end if;
  if length(btrim(coalesce(p_participant_label,''))) = 0 or length(btrim(coalesce(p_guide_name,''))) = 0 or length(btrim(coalesce(p_question,''))) = 0 or length(btrim(coalesce(p_response,''))) = 0 then raise exception 'Participant, guide, question, and response are required.'; end if;
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_source_id, p_organization_id, p_engagement_id, 'EVIDENCE_SOURCE', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.evidence_sources(id, organization_id, source_type, title, captured_at, provenance_context, created_by) values (v_source_id, p_organization_id, 'INTERVIEW', 'Interview · ' || btrim(p_participant_label), now(), 'Consultant-recorded stakeholder interview.', v_actor);
  insert into consulting_os.evidence_fragments(id, organization_id, evidence_source_id, locator_kind, locator, content_text, content_sha256, captured_context, created_by) values (v_fragment_id, p_organization_id, v_source_id, 'QUESTION_RESPONSE', jsonb_build_object('question', btrim(p_question)), p_response, encode(extensions.digest(convert_to(p_response, 'UTF8'), 'sha256'), 'hex'), 'Recorded with participant consent.', v_actor);
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_interview_id, p_organization_id, p_engagement_id, 'INTERVIEW', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.interviews(id, organization_id, engagement_id, evidence_source_id, participant_label, interviewer_person_id, guide_name, guide_version, interview_status, conducted_at, consent_recorded, created_by) values (v_interview_id, p_organization_id, p_engagement_id, v_source_id, btrim(p_participant_label), v_actor, btrim(p_guide_name), '1', 'COMPLETED', now(), true, v_actor);
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_response_id, p_organization_id, p_engagement_id, 'INTERVIEW_RESPONSE', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.interview_responses(id, organization_id, interview_id, question_key, question_text, response_text, evidence_fragment_id, source_locator, created_by) values (v_response_id, p_organization_id, v_interview_id, 'Q1', btrim(p_question), btrim(p_response), v_fragment_id, 'Consultant discovery intake · Q1', v_actor);
  return v_interview_id;
end;
$$;

create or replace function consulting_os.create_discovery_assessment(
  p_organization_id uuid, p_engagement_id uuid, p_name text,
  p_dimension text, p_prompt text, p_audience text,
  p_opens_at timestamptz, p_closes_at timestamptz,
  p_confidentiality consulting_os.assessment_confidentiality
) returns uuid
language plpgsql security definer
set search_path = consulting_os, consulting_security, pg_temp
as $$
declare v_actor uuid := consulting_security.current_person_id(); v_instrument_id uuid := gen_random_uuid(); v_version_id uuid := gen_random_uuid(); v_source_id uuid := gen_random_uuid(); v_admin_id uuid := gen_random_uuid();
begin
  if v_actor is null or not consulting_security.has_active_consultant_assignment(p_organization_id) then raise exception 'Assigned consultant authorization is required.'; end if;
  if p_opens_at is null or p_closes_at is null or p_closes_at <= p_opens_at then raise exception 'Assessment open and close dates must define a valid window.'; end if;
  if length(btrim(coalesce(p_name,''))) = 0 or length(btrim(coalesce(p_dimension,''))) = 0 or length(btrim(coalesce(p_prompt,''))) = 0 or length(btrim(coalesce(p_audience,''))) = 0 then raise exception 'Name, dimension, prompt, and audience are required.'; end if;
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_instrument_id, p_organization_id, p_engagement_id, 'ASSESSMENT_INSTRUMENT', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.assessment_instruments(id, organization_id, name, framework_name, instrument_status, validation_claim_status, validation_basis, created_by) values (v_instrument_id, p_organization_id, btrim(p_name), 'Lead Emergence Discovery', 'DRAFT', 'NOT_VALIDATED', 'Consulting inquiry instrument; no psychometric validation claimed.', v_actor);
  insert into consulting_os.assessment_instrument_versions(id, organization_id, instrument_id, version_number, version_label, dimensions, scoring_rules, compatibility_key, created_by) values (v_version_id, p_organization_id, v_instrument_id, 1, 'Version 1', jsonb_build_array(jsonb_build_object('key', upper(regexp_replace(btrim(p_dimension), '[^A-Za-z0-9]+', '_', 'g')), 'label', btrim(p_dimension))), '{}'::jsonb, replace(v_instrument_id::text, '-', ''), v_actor);
  insert into consulting_os.assessment_items(organization_id, instrument_version_id, item_key, prompt, dimension_key, response_type, response_options, ordinal, created_by) values (p_organization_id, v_version_id, 'Q1', btrim(p_prompt), upper(regexp_replace(btrim(p_dimension), '[^A-Za-z0-9]+', '_', 'g')), 'LIKERT', '[1,2,3,4,5]'::jsonb, 1, v_actor);
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_source_id, p_organization_id, p_engagement_id, 'EVIDENCE_SOURCE', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.evidence_sources(id, organization_id, source_type, title, captured_at, provenance_context, created_by) values (v_source_id, p_organization_id, 'ASSESSMENT', btrim(p_name), now(), 'Assessment administration responses are evidence, not diagnosis.', v_actor);
  insert into consulting_os.domain_objects(id, organization_id, engagement_id, object_type, visibility_scope, origin, created_by) values (v_admin_id, p_organization_id, p_engagement_id, 'ASSESSMENT_ADMINISTRATION', 'ENGAGEMENT_SHARED', 'HUMAN', v_actor);
  insert into consulting_os.assessment_administrations(id, organization_id, engagement_id, instrument_version_id, evidence_source_id, audience_description, opens_at, closes_at, confidentiality, minimum_reporting_cohort, administration_status, created_by) values (v_admin_id, p_organization_id, p_engagement_id, v_version_id, v_source_id, btrim(p_audience), p_opens_at, p_closes_at, p_confidentiality, case when p_confidentiality = 'ANONYMOUS' then 3 else 1 end, 'DRAFT', v_actor);
  return v_admin_id;
end;
$$;

revoke all on function consulting_os.capture_discovery_evidence(uuid, uuid, consulting_os.evidence_source_type, text, text, text, text, text) from public, anon;
revoke all on function consulting_os.record_discovery_interview(uuid, uuid, text, text, text, text, boolean) from public, anon;
revoke all on function consulting_os.create_discovery_assessment(uuid, uuid, text, text, text, text, timestamptz, timestamptz, consulting_os.assessment_confidentiality) from public, anon;
grant execute on function consulting_os.capture_discovery_evidence(uuid, uuid, consulting_os.evidence_source_type, text, text, text, text, text) to authenticated, service_role;
grant execute on function consulting_os.record_discovery_interview(uuid, uuid, text, text, text, text, boolean) to authenticated, service_role;
grant execute on function consulting_os.create_discovery_assessment(uuid, uuid, text, text, text, text, timestamptz, timestamptz, consulting_os.assessment_confidentiality) to authenticated, service_role;
