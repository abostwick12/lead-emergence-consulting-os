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
- Written-audit assignment status over the existing versioned assessment model
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
5. Schedule interviews with the appropriate guide and sanitized objective.
6. Map the actual current-state workflow before assessing AI suitability.
7. Capture evidence with a reviewable source locator and explicit visibility.
8. Keep follow-up work in Actions.
9. Do not open P1 analysis until P0 evidence is reviewed with the consultant.

## Deployment blocker

The migration exists and the application build passes, but local database execution is not verified on this machine because Docker Desktop or Podman is not installed or available on PATH. Do not apply the migration to a hosted environment until it passes local migration, RLS, and database tests.
