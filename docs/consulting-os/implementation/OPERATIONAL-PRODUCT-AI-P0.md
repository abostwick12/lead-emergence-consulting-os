# Operational Product AI Transformation — P0

## Pilot engagement

- Client: 7th Special Operations Squadron (7th SOS)
- Engagement: Operational Product AI Transformation
- Current roadmap stage: SEE REALITY
- Default handling: Internal — Sanitized Only
- Delivery boundary: local verified build first; hosted pilot requires a separate infrastructure checkpoint
- Ministry handoff: hidden for this engagement type

## Purpose

This workspace helps a consultant assess how authorized, sanitized operational products are created, reviewed, and improved. It is a consulting-management, evidence, and workflow-analysis system. It is not an operational mission-planning system.

The workspace must not receive classified, CUI, SECRET, NOFORN, mission, target, coordinate, frequency, callsign, intelligence, or operational-timeline data. Users are responsible for entering only information authorized for the environment.

## P0 capabilities

- Engagement type, objective, scope, owner, stage, target completion, and handling notice
- Product register
- Two authoritative, versioned written assessments:
  - Mission Product Automation Leadership Assessment (36 guided items across 9 sections)
  - Mission Product Workflow and Automation Assessment (48 guided items across 12 sections)
- Downloadable Word and PDF source instruments for offline completion and printing
- Consultant-created, expiring assessment administrations with identified participant access
- Exact structured response controls for narrative prompts, checklists, ratings, rankings, and matrices
- MCP-first tool contracts for listing instruments, reading the complete instrument, starting an administration, and saving a participant-confirmed response
- Interview templates, questions, plans, product links, and response provenance
- Current-state workflow mapping with timing, wait, rework, judgment, verification, and human-reviewed AI-suitability fields
- Evidence and observation capture with source locators and visibility
- Sanitized artifact requests
- Engagement actions with ownership, due dates, status, and visibility
- Consultant/client visibility enforced through existing domain-object and tenant boundaries

## Phase gates

- P1: findings, evidence links, alternative interpretations, opportunities, open questions, and human-reviewed scoring
- P2: prototypes, human-in-the-loop controls, validation, baseline comparison, and recommendations

Later-phase navigation is visible so the engagement has a coherent destination, but each page states that it is gated. No hidden analysis, diagnosis, scoring, or autonomous agent is running.

## Local operating sequence

1. Open Clients and select 7th Special Operations Squadron.
2. Confirm the persistent handling notice before entering any record.
3. Confirm products, product owners, authorized interview participants, and artifact-request protocol.
4. Open written audits and track assignment state.
5. Select an assessment, then either download the authoritative Word/PDF instrument or prepare a guided administration.
6. For conversation-led delivery, copy the generated MCP brief into a ChatGPT conversation that is connected to the Consulting OS MCP service. The assistant must read the complete instrument, ask one item at a time, preserve the instrument wording and structure, and save only after the respondent explicitly confirms the answer.
7. Schedule interviews with the appropriate guide and sanitized objective.
8. Map the actual current-state workflow before assessing AI suitability.
9. Capture evidence with a reviewable source locator and explicit visibility.
10. Keep follow-up work in Actions.
11. Do not open P1 analysis until P0 evidence is reviewed with the consultant.

## Assessment integrity boundary

- The Word and PDF instruments remain the authoritative printable sources.
- The guided workflow is a structured administration of those instruments, not a rewritten or shortened survey.
- Responses are evidence. They are not scores, diagnoses, findings, or accepted interpretations.
- A participant may skip an item, but the workflow never invents an answer or silently infers one.
- Only sanitized, process-level information may be entered.
- The in-platform guided assessment works without ChatGPT. Conversation-led delivery additionally requires a deployed and connected Consulting OS MCP service.

## Deployment blocker

The migration exists and the application build passes, but local database execution is not verified on this machine because Docker Desktop or Podman is not installed or available on PATH. Do not apply the migration to a hosted environment until it passes local migration, RLS, and database tests.
