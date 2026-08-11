# Landing Scroll-Reveal Design QA

## Comparison target

- Source visual truth: `C:\Users\AWBOST~1\AppData\Local\Temp\codex-clipboard-9d52e4df-4071-48ec-9a2b-a6935ea216f8.png`
- Source dimensions: 1536 x 1024 pixels.
- User-reported pre-fix transition evidence: `C:\Users\AWBOST~1\AppData\Local\Temp\codex-clipboard-570149f7-8395-4e80-a6e7-0412cd03aea5.png` and `C:\Users\AWBOST~1\AppData\Local\Temp\codex-clipboard-65d187ac-2ea6-4df2-bb56-f60a6b44685d.png`.
- Rendered implementation: `http://localhost:3179/`.
- Desktop viewport: 1680 x 1120 CSS pixels, device scale factor 1; implementation captures are 1680 x 1120 pixels.
- Mobile viewport: 390 x 844 CSS pixels, device scale factor 1; implementation captures are 390 x 844 pixels.
- Full-view evidence: `docs/consulting-os/implementation/evidence/landing/v6-top-1680x1120.png`, `v6-login-cards-1680x1120.png`, and `v6-mobile-login-390x844.png`.
- Focused same-input comparisons: `docs/consulting-os/implementation/evidence/landing/v6-comparison-symbol.jpg` and `v6-comparison-entry.jpg`.
- Transition evidence: `v6-build-1680x1120.png`, `v6-produce-mid-1680x1120.png`, `v6-produce-transition-1680x1120.png`, `v6-new-reality-1680x1120.png`, and `v6-see-again-1680x1120.png`.
- Responsive evidence: `v6-mobile-build-390x844.png` and `v6-mobile-login-390x844.png`.
- States checked: opening, BUILD, PRODUCE, the PRODUCE-to-NEW REALITY transition, NEW REALITY, SEE AGAIN, desktop product entry, mobile BUILD, and mobile product entry.

## Findings

No actionable P0, P1, or P2 differences remain in the requested correction.

- Fonts and typography: the Lead Emergence serif, italic emphasis, monospaced stage metadata, restrained tracking, and copy hierarchy remain consistent with the source. The seamless layout change does not alter copy or typography.
- Spacing and layout rhythm: the opening, roadmap, progress rail, brand reveal, and product-entry background now read as one uninterrupted page. Their former borders, rounded containers, shadows, and segmented rail backgrounds are removed. Only the Ministry and Lead Emergence Consulting environment cards retain card boundaries.
- Colors and visual tokens: the existing deep navy, cyan, blue, and warm-gold platform tokens are preserved. Removing container fills does not introduce a competing visual language.
- Image quality and asset fidelity: the active symbol is no longer a crossfade of seven independently registered full-frame rasters. It is assembled from one locked registration using cumulative source-derived seed, stem, triangle, pathway, arc, and ray layers. BUILD, PRODUCE, and NEW REALITY now follow the source order, and the arc, rays, apex, and pathway do not jump or double during scrolling.
- Copy and content: stage names, statements, supporting copy, product names, and login labels are unchanged.
- Responsiveness and accessibility: the journey remains readable and unclipped at 390 x 844. The symbol stays above the copy, the stage rail remains operable, the two environment cards stack on mobile, reduced-motion behavior remains discrete, and the persistent Sign in control stays visible.
- Interaction and console health: the stage-rail controls reached their intended states; the Sign in selector opened and closed; a fresh in-app browser tab reported no console errors.

## Full-view comparison evidence

`v6-top-1680x1120.png` shows the opening as a full-bleed continuation of the page rather than an inset card. `v6-login-cards-1680x1120.png` and `v6-mobile-login-390x844.png` show the requested endpoint: the surrounding entry composition is unframed, while the two product environments are the only distinct cards. The returning-user action is an inline row, not a third card.

The supplied source is a visual-direction board rather than a sticky single-stage viewport. Full-view comparison therefore evaluates hierarchy, palette, typography, whitespace, border restraint, and the two-environment finish rather than identical simultaneous placement of all seven stages.

## Focused region comparison evidence

`v6-comparison-symbol.jpg` places the source BUILD, PRODUCE, and NEW REALITY panels above the corresponding browser-rendered scroll states. It verifies the corrected source order:

1. cyan seed;
2. vertical stem;
3. skeletal triangle;
4. blue pathway and planes at BUILD;
5. warm-gold arc at PRODUCE;
6. warm-gold rays at NEW REALITY;
7. the completed symbol recedes continuously while a new cyan seed appears at SEE AGAIN.

`v6-produce-transition-1680x1120.png` is the critical scroll-transition capture. It shows one gold arc and one registered set of emerging rays, with no duplicate ring, shifted apex, rectangular raster panel, or competing full-size symbol.

`v6-comparison-entry.jpg` places the source entry composition and the rendered two-card finish in the same comparison input. The product separation remains clear without wrapping the entire section in another card.

## Comparison history

1. Earlier P1: generated artwork did not match the existing platform or approved mockup.
   - Fix: replaced it with source-derived artwork and retained the established platform palette and typography.
2. Earlier P1: independently sourced full-frame rasters were crossfaded during scroll, causing doubled gold arcs, shifted rays, and an odd transition through NEW REALITY.
   - Evidence: the two user-supplied pre-fix screenshots show the duplicate ring and rectangular image boundary.
   - Fix: rebuilt the active symbol as cumulative layers cut from one locked final registration; SEE AGAIN now transforms that same resolved image rather than crossfading to another full-frame raster.
3. Earlier P1: the stage order did not follow the source board closely enough.
   - Fix: restored the source sequence: stem at REFRAME, triangle at ALIGN, pathway at BUILD, arc at PRODUCE, and rays at NEW REALITY.
4. Earlier P1: the page looked like stacked standalone cards through the journey, brand reveal, and entry container.
   - Fix: removed the opening frame, story frame, segmented progress-card treatment, brand panel frame, and entry wrapper frame. Kept only the two product login environments as cards.
5. Earlier P2: SEE AGAIN used a second full-frame raster, which could create another overlapping-symbol transition.
   - Fix: the single resolved symbol now scales and recedes continuously while the registered cyan seed fades in above it.
6. Post-fix evidence: desktop and mobile captures are clean, the focused comparison follows the source stage order, the Sign in selector works, and the fresh browser console is empty.

## Primary interactions tested

- Roadmap controls for BUILD, PRODUCE, NEW REALITY, and SEE AGAIN.
- Manual scroll through the PRODUCE-to-NEW REALITY transition.
- Desktop and mobile responsive states.
- Persistent Sign in button, modal open, and modal close.
- Browser console error inspection in a fresh tab.

## Open questions

None for this correction.

## Implementation checklist

- [x] Rebuild the roadmap symbol on one locked registration.
- [x] Restore the source stage order.
- [x] Eliminate duplicated arc/ray geometry during scroll.
- [x] Remove rectangular raster haze from the active artwork.
- [x] Remove journey, brand, and entry-wrapper card framing.
- [x] Keep only Ministry and Consulting as distinct cards.
- [x] Verify desktop and mobile layouts.
- [x] Compare source and implementation in the same normalized evidence boards.
- [x] Verify interactions and a clean console.

## Follow-up polish

None required for this visual checkpoint.

final result: passed
