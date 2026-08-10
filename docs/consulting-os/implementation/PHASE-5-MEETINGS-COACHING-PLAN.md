# Phase 5 — Meetings and Coaching plan

## Outcome

One shared interaction engine supports consulting meetings and coaching sessions through Prepare → Meet → Capture → Decide → Commit → Follow Up. Coaching reuses the engine while enforcing a stricter relationship and privacy contract.

## Canonical implementation

- `meetings` owns purpose, timing, status, workflow stage, agenda, summary, and follow-up.
- `meeting_participants` records the named audience and whether each participant must be eligible for preparation context.
- `meeting_notes` stores only shared/permitted notes. Private content is rejected from this table.
- `coaching_relationships` names the coach, participant, purpose, dates, status, and confidentiality statement.
- `coaching_sessions` specializes a meeting without creating a second meeting engine.
- `commitments` persist independently across sessions and may be reviewed or completed later.
- `meeting_decisions` links first-class Meridian Decision records.
- `meeting_context_items` accepts a source only when every required participant is permitted to read it.
- `consulting_private.meeting_notes` physically stores coach-private notes and participant-private reflections. Ordinary Data API roles receive no table access.
- `coaching_promotions` records the explicit abstraction/redaction and human authorization required before a coaching-derived object may enter broader organizational knowledge.

## Privacy invariants

1. `CONSULTANT_PRIVATE` and `INDIVIDUAL_PRIVATE` content cannot be inserted into the shared note table.
2. Coaching-shared records require explicit grants to the coach and participant.
3. Client administration or leadership status does not unlock coaching content.
4. Private content never appears in shared meeting, history, preparation, export, or organizational-intelligence views.
5. A broader derivative requires an explicit promotion record; the private source is preserved and the derivative has its own provenance, visibility, and review state.
6. Meeting preparation is the intersection of required-participant permissions, not the facilitator's full access.

## Verification

- pgTAP proves same-tenant keys, RLS, participant isolation, private physical partition, preparation intersection, persistent commitments, explicit promotion, and non-telemetry defaults.
- Unit tests prove workflow transitions and role-filtered fixture projections.
- Browser tests complete consultant and client create/edit/save/read cycles and verify private controls do not appear to unrelated users.
- Static verification checks the canonical tables, functions, routes, privacy copy, tests, and documentation.
- Existing Phase 0–4 checks remain green; no Ministry source or dependency is changed.
