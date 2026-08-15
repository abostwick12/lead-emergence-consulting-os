-- Operational Product AI Transformation — P0 consulting/evidence workspace.
-- This schema does not store mission-planning data and does not authorize
-- classified, CUI, SECRET, NOFORN, target, coordinate, frequency, callsign,
-- intelligence, or operational-timeline content.

alter table consulting_os.engagements
  add column if not exists engagement_type text not null default 'ORGANIZATIONAL_TRANSFORMATION',
  add column if not exists objective text,
  add column if not exists scope_statement text,
  add column if not exists owner_person_id uuid references consulting_os.people(id) on delete restrict,
  add column if not exists handling_label text,
  add column if not exists handling_notice text,
  add column if not exists current_phase text;

alter table consulting_os.engagements drop constraint if exists engagements_engagement_type_check;
alter table consulting_os.engagements add constraint engagements_engagement_type_check
  check (engagement_type in ('ORGANIZATIONAL_TRANSFORMATION', 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION'));
alter table consulting_os.engagements drop constraint if exists engagements_operational_handling_check;
alter table consulting_os.engagements add constraint engagements_operational_handling_check check (
  engagement_type <> 'OPERATIONAL_PRODUCT_AI_TRANSFORMATION'
  or (length(btrim(coalesce(objective, ''))) > 0
    and length(btrim(coalesce(scope_statement, ''))) > 0
    and handling_label = 'Internal — Sanitized Only'
    and length(btrim(coalesce(handling_notice, ''))) > 0
    and current_phase in ('SEE REALITY', 'REFRAME REALITY', 'ALIGN WITH REALITY', 'BUILD CAPABILITY', 'PRODUCE VALUE', 'NEW REALITY', 'SEE AGAIN'))
);

create table consulting_os.engagement_products (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('ENGAGEMENT_PRODUCT'::text) stored,
  name text not null check (length(btrim(name)) > 0),
  description text not null check (length(btrim(description)) > 0),
  owner_person_id uuid references consulting_os.people(id) on delete restrict,
  owner_label text not null check (length(btrim(owner_label)) > 0),
  product_status text not null default 'ACTIVE' check (product_status in ('ACTIVE', 'ON_HOLD', 'COMPLETE')),
  handling_label text not null default 'Internal — Sanitized Only' check (handling_label = 'Internal — Sanitized Only'),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (id, organization_id)
);

create table consulting_os.written_audit_assignments (
  id uuid primary key,
  organization_id uuid not null,
  engagement_id uuid not null,
  object_type text generated always as ('WRITTEN_AUDIT_ASSIGNMENT'::text) stored,
  product_id uuid not null,
  administration_id uuid not null,
  respondent_person_id uuid references consulting_os.people(id) on delete restrict,
  respondent_label text not null check (length(btrim(respondent_label)) > 0),
  audit_status text not null default 'NOT_STARTED' check (audit_status in ('NOT_STARTED', 'IN_PROGRESS', 'SUBMITTED', 'REVIEWED')),
  due_on date,
  reviewed_by uuid references consulting_os.people(id) on delete restrict,
  reviewed_at timestamptz,
  follow_up_note text,
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (product_id, organization_id) references consulting_os.engagement_products(id, organization_id) on delete restrict,
  foreign key (administration_id, organization_id) references consulting_os.assessment_administrations(id, organization_id) on delete restrict,
  unique (id, organization_id),
  check (audit_status <> 'REVIEWED' or (reviewed_by is not null and reviewed_at is not null))
);

create table consulting_os.interview_templates (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references consulting_os.organizations(id) on delete restrict,
  engagement_id uuid not null,
  name text not null check (length(btrim(name)) > 0),
  interview_type text not null check (interview_type in ('PRODUCT_OWNER', 'ANALYST', 'REVIEWER', 'USER', 'SPONSOR', 'OTHER')),
  version_number integer not null check (version_number > 0),
  objective text not null check (length(btrim(objective)) > 0),
  status text not null default 'DRAFT' check (status in ('DRAFT', 'ACTIVE', 'RETIRED')),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (engagement_id, name, version_number)
);

create table consulting_os.interview_template_questions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  template_id uuid not null,
  question_key text not null check (question_key ~ '^[A-Z][A-Z0-9_]*$'),
  prompt text not null check (length(btrim(prompt)) > 0),
  purpose text not null check (length(btrim(purpose)) > 0),
  ordinal integer not null check (ordinal > 0),
  created_by uuid not null references consulting_os.people(id) on delete restrict,
  created_at timestamptz not null default now(),
  foreign key (template_id, organization_id) references consulting_os.interview_templates(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (template_id, question_key), unique (template_id, ordinal)
);

alter table consulting_os.interviews
  add column if not exists template_id uuid,
  add column if not exists interview_type text,
  add column if not exists objective text;
alter table consulting_os.interviews add constraint interviews_template_tenant_fk foreign key (template_id, organization_id) references consulting_os.interview_templates(id, organization_id) on delete restrict;
alter table consulting_os.interviews add constraint interviews_type_check check (interview_type is null or interview_type in ('PRODUCT_OWNER', 'ANALYST', 'REVIEWER', 'USER', 'SPONSOR', 'OTHER'));

create table consulting_os.interview_product_links (
  id uuid primary key default gen_random_uuid(), organization_id uuid not null, interview_id uuid not null, product_id uuid not null,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (interview_id, organization_id) references consulting_os.interviews(id, organization_id) on delete restrict,
  foreign key (product_id, organization_id) references consulting_os.engagement_products(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (interview_id, product_id)
);

create table consulting_os.engagement_product_workflows (
  id uuid primary key default gen_random_uuid(), organization_id uuid not null, product_id uuid not null, workflow_version_id uuid not null,
  map_kind text not null default 'CURRENT_STATE' check (map_kind in ('CURRENT_STATE', 'FUTURE_STATE')),
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(),
  foreign key (product_id, organization_id) references consulting_os.engagement_products(id, organization_id) on delete restrict,
  foreign key (workflow_version_id, organization_id) references consulting_os.workflow_versions(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (product_id, workflow_version_id, map_kind)
);

create table consulting_os.workflow_step_analysis (
  id uuid primary key default gen_random_uuid(), organization_id uuid not null, workflow_step_id uuid not null,
  system_tool text not null check (length(btrim(system_tool)) > 0), inputs text not null check (length(btrim(inputs)) > 0), outputs text not null check (length(btrim(outputs)) > 0),
  active_minutes integer not null default 0 check (active_minutes >= 0), wait_minutes integer not null default 0 check (wait_minutes >= 0),
  rework_risk text not null default 'MEDIUM' check (rework_risk in ('LOW', 'MEDIUM', 'HIGH')),
  pain_points text not null default '', judgment_required text not null check (length(btrim(judgment_required)) > 0), verification_required text not null check (length(btrim(verification_required)) > 0),
  work_types text[] not null default '{}', ai_suitability text not null default 'NOT_ASSESSED' check (ai_suitability in ('NOT_ASSESSED', 'ASSISTIVE_CANDIDATE', 'HUMAN_ONLY')),
  ai_suitability_rationale text, reviewed_by uuid references consulting_os.people(id) on delete restrict, reviewed_at timestamptz,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  foreign key (workflow_step_id, organization_id) references consulting_os.workflow_steps(id, organization_id) on delete restrict,
  unique (id, organization_id), unique (workflow_step_id),
  check (ai_suitability = 'NOT_ASSESSED' or (length(btrim(coalesce(ai_suitability_rationale, ''))) > 0 and reviewed_by is not null and reviewed_at is not null))
);

create table consulting_os.artifact_requests (
  id uuid primary key, organization_id uuid not null, engagement_id uuid not null,
  object_type text generated always as ('ARTIFACT_REQUEST'::text) stored, product_id uuid,
  title text not null check (length(btrim(title)) > 0), requested_from text not null check (length(btrim(requested_from)) > 0),
  requested_on date not null, due_on date, request_status text not null default 'REQUESTED' check (request_status in ('REQUESTED', 'RECEIVED', 'DECLINED', 'NOT_AVAILABLE')),
  handling_note text not null check (length(btrim(handling_note)) > 0), received_file_id uuid,
  created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  foreign key (product_id, organization_id) references consulting_os.engagement_products(id, organization_id) on delete restrict,
  foreign key (received_file_id, organization_id) references consulting_os.file_objects(id, organization_id) on delete restrict,
  unique (id, organization_id), check (due_on is null or due_on >= requested_on), check (request_status <> 'RECEIVED' or received_file_id is not null)
);

create table consulting_os.engagement_actions (
  id uuid primary key, organization_id uuid not null, engagement_id uuid not null,
  object_type text generated always as ('ACTION_ITEM'::text) stored, title text not null check (length(btrim(title)) > 0),
  owner_person_id uuid references consulting_os.people(id) on delete restrict, owner_label text not null check (length(btrim(owner_label)) > 0),
  due_on date, action_status text not null default 'OPEN' check (action_status in ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
  completed_at timestamptz, created_by uuid not null references consulting_os.people(id) on delete restrict, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  foreign key (id, organization_id, object_type) references consulting_os.domain_objects(id, organization_id, object_type) on delete restrict,
  foreign key (engagement_id, organization_id) references consulting_os.engagements(id, organization_id) on delete restrict,
  unique (id, organization_id), check (action_status <> 'COMPLETED' or completed_at is not null)
);

create index engagement_products_org_engagement_idx on consulting_os.engagement_products (organization_id, engagement_id, product_status);
create index written_audits_org_engagement_idx on consulting_os.written_audit_assignments (organization_id, engagement_id, audit_status, due_on);
create index interview_templates_org_engagement_idx on consulting_os.interview_templates (organization_id, engagement_id, status);
create index artifact_requests_org_engagement_idx on consulting_os.artifact_requests (organization_id, engagement_id, request_status, due_on);
create index engagement_actions_org_engagement_idx on consulting_os.engagement_actions (organization_id, engagement_id, action_status, due_on);

do $$ declare v_table text; begin
  foreach v_table in array array['engagement_products','written_audit_assignments','interview_templates','interview_template_questions','interview_product_links','engagement_product_workflows','workflow_step_analysis','artifact_requests','engagement_actions'] loop
    execute format('alter table consulting_os.%I enable row level security', v_table);
  end loop;
end $$;

do $$ declare v_table text; begin
  foreach v_table in array array['engagement_products','written_audit_assignments','artifact_requests','engagement_actions'] loop
    execute format('create policy %I on consulting_os.%I for select to authenticated using (consulting_security.can_read_domain_object(id, organization_id))', v_table || '_select_visible', v_table);
    execute format('create policy %I on consulting_os.%I for insert to authenticated with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_domain_object(id, organization_id))', v_table || '_insert_authorized', v_table);
    execute format('create policy %I on consulting_os.%I for update to authenticated using (consulting_security.can_manage_domain_object(id, organization_id)) with check (consulting_security.can_manage_domain_object(id, organization_id))', v_table || '_update_authorized', v_table);
  end loop;
end $$;

create policy interview_templates_select on consulting_os.interview_templates for select to authenticated using (consulting_security.has_engagement_access(organization_id, engagement_id));
create policy interview_questions_select on consulting_os.interview_template_questions for select to authenticated using (exists (select 1 from consulting_os.interview_templates t where t.id = consulting_os.interview_template_questions.template_id and t.organization_id = consulting_os.interview_template_questions.organization_id and consulting_security.has_engagement_access(t.organization_id, t.engagement_id)));
create policy interview_product_links_select on consulting_os.interview_product_links for select to authenticated using (consulting_security.can_read_domain_object(interview_id, organization_id) and consulting_security.can_read_domain_object(product_id, organization_id));
create policy product_workflows_select on consulting_os.engagement_product_workflows for select to authenticated using (consulting_security.can_read_domain_object(product_id, organization_id) and consulting_security.can_read_domain_object(workflow_version_id, organization_id));
create policy workflow_step_analysis_select on consulting_os.workflow_step_analysis for select to authenticated using (exists (select 1 from consulting_os.workflow_steps s where s.id = consulting_os.workflow_step_analysis.workflow_step_id and s.organization_id = consulting_os.workflow_step_analysis.organization_id and consulting_security.can_read_domain_object(s.workflow_version_id, s.organization_id)));

do $$ declare v_table text; begin
  foreach v_table in array array['interview_templates','interview_template_questions','interview_product_links','engagement_product_workflows','workflow_step_analysis'] loop
    execute format('create policy %I on consulting_os.%I for insert to authenticated with check (created_by = consulting_security.current_person_id() and consulting_security.can_manage_organization(organization_id))', v_table || '_insert_authorized', v_table);
    execute format('create policy %I on consulting_os.%I for update to authenticated using (consulting_security.can_manage_organization(organization_id)) with check (consulting_security.can_manage_organization(organization_id))', v_table || '_update_authorized', v_table);
    execute format('create policy %I on consulting_os.%I for delete to authenticated using (consulting_security.can_manage_organization(organization_id))', v_table || '_delete_authorized', v_table);
  end loop;
end $$;

grant select, insert, update, delete on consulting_os.engagement_products, consulting_os.written_audit_assignments, consulting_os.interview_templates, consulting_os.interview_template_questions, consulting_os.interview_product_links, consulting_os.engagement_product_workflows, consulting_os.workflow_step_analysis, consulting_os.artifact_requests, consulting_os.engagement_actions to authenticated;
grant all on consulting_os.engagement_products, consulting_os.written_audit_assignments, consulting_os.interview_templates, consulting_os.interview_template_questions, consulting_os.interview_product_links, consulting_os.engagement_product_workflows, consulting_os.workflow_step_analysis, consulting_os.artifact_requests, consulting_os.engagement_actions to service_role;

create trigger engagement_products_updated_at before update on consulting_os.engagement_products for each row execute function consulting_security.set_updated_at();
create trigger written_audits_updated_at before update on consulting_os.written_audit_assignments for each row execute function consulting_security.set_updated_at();
create trigger workflow_step_analysis_updated_at before update on consulting_os.workflow_step_analysis for each row execute function consulting_security.set_updated_at();
create trigger artifact_requests_updated_at before update on consulting_os.artifact_requests for each row execute function consulting_security.set_updated_at();
create trigger engagement_actions_updated_at before update on consulting_os.engagement_actions for each row execute function consulting_security.set_updated_at();
