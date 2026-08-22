# Design QA

## Latest pass — Consulting context selector (2026-08-21)

- Source visual truth: `docs/consulting-os/implementation/evidence/sso/hosted-client-workspace-reference-1440x2569.png`
- User direction: keep the hosted Consulting flow visually continuous with the dark Consulting OS and do not introduce a second login page.
- Implementation capture: `docs/consulting-os/implementation/evidence/sso/hosted-context-selector-dark-1440x1000.png`
- Browser viewport: 1440 × 1000 CSS px, device scale factor 1
- Source pixels: 1440 × 2569 (full-page client workspace capture)
- Implementation pixels: 1440 × 1000 (full-page context selector capture)
- State: authenticated Entry user choosing an authorized Consulting role before entering the client workspace
- Density normalization: none required; both captures use device scale factor 1 and the same 1440px viewport width

### Full-view comparison evidence

The context selector now uses the authenticated Consulting OS navy grid, deep panel, cyan structure, white serif hierarchy, muted supporting copy, and dark action card. The earlier 700px cream page surface and exposed dark remainder are gone. Because the source is the downstream client workspace rather than the same route, this pass checks design-system continuity instead of claiming pixel-for-pixel layout fidelity.

### Focused comparison evidence

No separate crop was needed: the implementation is a single centered card and all typography, borders, spacing, colors, and the action icon are clearly readable in the full 1440 × 1000 capture.

- Fonts and typography: the selector uses the same serif display face, compact mono eyebrow, sans-serif supporting copy, weights, and hierarchy as the authenticated workspace.
- Spacing and layout rhythm: the page fills the viewport, the card is centered with balanced padding, and the action row has consistent inset spacing and radius.
- Colors and visual tokens: no off-white surface remains; the page uses the established deep navy, panel, line, cyan, white, and muted-text tokens.
- Image quality and asset fidelity: the screen has no raster imagery or decorative image asset to reproduce; the action uses the existing Lucide icon library rather than a text glyph or drawn approximation.
- Copy and content: role, workspace label, and authorized-work explanation are unchanged in meaning.

### Comparison history

1. The initial hosted capture rendered the context selector as a fixed-width cream page, leaving the dark application background visible beside it.
2. The selector was changed to a full-width dark shell with a centered Consulting OS panel and dark role card; authentication, authorization, and routing behavior were preserved.
3. A fresh hosted capture at the same viewport confirmed that the cream split is gone and the page is visually continuous with the client workspace.

### Findings

No actionable P0, P1, or P2 differences remain for the context-selector correction.

### Interaction verification

- The explicit existing-account link journey reaches the context selector after one Entry password submission.
- Selecting `Client work` opens the authorized client workspace without a Consulting password submission.
- Consulting logout clears only the Consulting session; the Entry session reauthorizes Consulting without another password.
- Removed or absent memberships render the dark `No active Consulting workspace` state.
- Browser page errors and console errors: none in the hosted one-login acceptance journey.

## Prior pass — landing and workbench

- Source visual truth: `C:\Users\awbostwick\Pictures\ChatGPT Image Aug 10, 2026, 03_57_29 PM.png`
- Behavioral source truth: `C:\Users\awbostwick\.codex\attachments\ff092b8d-a4ff-4663-8f8d-17c435600dc1\pasted-text.txt`
- Implementation captures:
  - `test-results/landing-new-reality-desktop.png`
  - `test-results/landing-product-entry-desktop.png`
  - `test-results/landing-new-reality-mobile.png`
  - `test-results/operational-ai-overview-desktop.png`
- Desktop viewport: 1536 × 1024 CSS px, device scale factor 1
- Mobile viewport: 390 × 844 CSS px, device scale factor 1
- States: NEW REALITY, product entry, 7th SOS engagement overview

## Full-view comparison evidence

The reference provides the visual system and final composition; the behavioral specification intentionally replaces the reference's seven independent stage cards with a single sticky scroll narrative. The implementation uses the approved high-resolution stage assets in one registered image stack. The object remains anchored while stage copy and the progress rail change. The transition into NEW REALITY resolves from the same image position rather than introducing a separate logo.

The product-entry section preserves the reference's navy field, cyan/gold distinction, serif display typography, mountain artwork, and two product environments. Only Ministry and Lead Emergence Consulting are separate cards. The removed universal returning-user strip does not reappear; the persistent header sign-in remains available.

## Focused comparison evidence

- Typography: Cormorant-style serif display hierarchy, restrained uppercase stage labels, compact mono metadata, and readable supporting copy match the established platform language.
- Spacing and layout: the landing narrative has one continuous full-viewport stage, no stage cards, a stable visual column, and a single progress rail. The product cards align on one baseline. The workbench uses the existing portal shell and responsive grid.
- Colors and tokens: deep navy, high-contrast white, crisp cyan structure, and gold handling/capability accents use existing tokens consistently.
- Image quality: the supplied v10 raster assets are used directly without CSS geometry, replacement nodes, added decorative details, or stretching. `object-fit: contain` preserves registration and aspect ratio.
- Copy: stage copy matches the approved specification. The Consulting public product name is Lead Emergence Consulting. The 7th SOS workbench uses process-level, sanitized language and explicit exclusions.

## Comparison history

1. Earlier build used a reconstructed vector symbol and a separate returning-user section. It also made the visual sequence difficult to see at the first scroll threshold.
2. Fixed by replacing the vector with the approved seven-image stack, keeping the symbol frame fixed, removing the separate returning-user block, and showing SEE immediately when the narrative begins.
3. Earlier operational navigation overflowed horizontally at desktop width.
4. Fixed by wrapping the engagement's phase-labeled navigation into two clean rows.

## Findings

No actionable P0, P1, or P2 design differences remain for the selected behavior and states.

## Follow-up polish

- P3: once the hosted pilot is approved, repeat the same captures against the deployment and confirm production font loading.

## Interaction verification

- Persistent sign-in opens the independent product selector.
- Stage rail moves between the seven sticky visual states.
- Reduced-motion mode uses discrete states.
- Product login links retain their intended destinations.
- 7th SOS products and evidence can be created in local review mode.
- Sanitized-content boundary rejects controlled-content indicators.
- Browser console errors: none in the landing-page journey test.

final result: passed
