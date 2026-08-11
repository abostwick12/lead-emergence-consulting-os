# Landing Scroll-Reveal Design QA

## Visual truth

- Roadmap source: `C:\Users\AWBOST~1\AppData\Local\Temp\codex-clipboard-9d52e4df-4071-48ec-9a2b-a6935ea216f8.png`.
- Returning User source: the user-supplied `ReturningUser.tsx` and `ReturningUser.css` target, with `C:\Users\AWBOST~1\AppData\Local\Temp\codex-clipboard-410828db-e839-4d8c-983c-0258c992adb0.png` as the visual reference.
- Roadmap comparison viewport: 1536 x 1024 CSS pixels at device scale factor 1.
- Returning User comparison: a dedicated 1995-pixel-wide section capture; the supplied screenshot is 1993 x 345 pixels.
- Mobile verification viewport: 390 x 844 CSS pixels at device scale factor 1.

## Final implementation

- The seven roadmap frames are derived directly from the approved mockup pixels and remain in one locked registration throughout the scroll.
- The sequence is the original single-apex progression: point; point with vertical axis; apex with two descending diagonals; illuminated blue mountain planes; gold arc; gold arc and rays with illuminated mountains; and the final See Again continuation.
- The rejected five-dot/X network and generated geometric assumptions are absent.
- Frame changes use short registered opacity transitions. No frame is independently translated, scaled, or re-centered during scroll.
- Ministry and Lead Emergence Consulting are the only card-shaped login surfaces.
- Returning User is a seamless full-width row after the two product cards. Its desktop grid is exactly `330px minmax(440px, 1fr) 375px` with 74px gaps; its button is 375 x 110 pixels; and its tablet/mobile behavior follows the supplied CSS target.
- The Returning User button opens the existing environment selector rather than acting as a dead control.

## Evidence

- Seven-frame source sequence: `docs/consulting-os/implementation/evidence/landing/v9-source-frame-sequence.jpg`.
- New Reality source/implementation comparison: `docs/consulting-os/implementation/evidence/landing/v9-comparison-new-reality.jpg`.
- New Reality desktop: `docs/consulting-os/implementation/evidence/landing/v9-new-reality-1536x1024.png`.
- New Reality mobile: `docs/consulting-os/implementation/evidence/landing/v9-new-reality-mobile-390x844.png`.
- Product cards and seamless Returning User finish: `docs/consulting-os/implementation/evidence/landing/v9-login-cards-returning-1536x1024.png`.
- Returning User direct comparison: `docs/consulting-os/implementation/evidence/landing/v9-comparison-returning-user.jpg`.
- Returning User desktop: `docs/consulting-os/implementation/evidence/landing/v9-returning-user-1995x345.png`.
- Returning User mobile: `docs/consulting-os/implementation/evidence/landing/v9-returning-user-mobile-390x844.png`.

## Findings

No actionable P0, P1, or P2 differences remain for the requested correction.

- Image fidelity: the implemented New Reality artwork is the approved source artwork, not a regenerated approximation. The cyan summit illuminates the blue mountain planes and the gold arc/rays retain the source luminosity.
- Registration: every frame uses the same 808 x 808 canvas and the same rendered slot, removing the misalignment that previously made scrolling feel discontinuous.
- Composition: the journey stays seamless until the product choice; no roadmap stage is presented as a separate card.
- Returning User: the unequal columns, typography, background, colors, border, pill dimensions, spacing, hover/focus treatment, and responsive collapse match the supplied CSS target.
- Accessibility: the sign-in action is a semantic button with visible keyboard focus; the section is labelled; the decorative arrow is hidden from assistive technology; and reduced-motion users receive discrete frame changes.
- Responsive behavior: the roadmap art remains contained and illuminated at 390 x 844. Returning User stacks cleanly and its action remains full-width within the mobile content column.

## Validation

- Typecheck: passed.
- Lint: passed.
- Unit tests: 33 passed.
- Production build: passed.
- End-to-end tests: 29 passed, including desktop/mobile roadmap, Returning User, working sign-in selector, and reduced-motion coverage.
- Dependencies were unchanged, so `npm ci` was not repeated.

## Open questions

None for this visual checkpoint.

final result: passed
