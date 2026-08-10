# Source manifest

The retained DOCX files are exact copies of the supplied sources except Canonical Document 03, which incorporates the exact owner-supplied authoritative continuation after Section 11. Its pre-existing Section 26-to-end tail was replaced by the same authoritative tail to avoid duplication. Markdown companions are searchable representations. The build Goal, Product Separation constraint, checkpoint response, and architecture approval are retained as human authority records.

| Source | Classification | SHA-256 |
|---|---|---|
| `canonical/01-product-constitution.docx` | Canonical 01 | `1a31807265d8de412f42d152429aee24ff826cb967808b109e3f71c1a9490869` |
| `canonical/02-emergence-methodology.docx` | Canonical 02 | `a5f42bcc20278c49dd776b558c08dc180137d0421e95abc861324d7373232891` |
| `canonical/03-domain-model.docx` | Canonical 03 — restored | `57d185b928b2290353a2893e77521ee5c228f3728ffa83f8bfb8ea0d4e8143a0` |
| `canonical/04-meridian-epistemology.docx` | Canonical 04 | `7a008713df52e7282aed6e186e073333ff455c74255104796db6ad34540fe747` |
| `canonical/05-security-multitenancy.docx` | Canonical 05 | `bc8e2cbcd9a46bd12cd4f3b5af210e0548be2eb910eb7dc794821c8b2a6ffe38` |
| `canonical/06-portal-ux.docx` | Canonical 06 | `664a7f7332f62b22a571e19f092231ba6dcb7ff2ef8c08e8ef5eb015d68ab6fa` |
| `canonical/07-v1-scope-acceptance.docx` | Canonical 07 | `33be6d96d4726824dba61a6d975181295c34e660d2ec1d2b261f2075b3697f03` |
| `reference/full-build-plan.docx` | Supporting reference | `8d3be06d7ccad9ed70966da4ee05bafefac16e94b829cf70f575a712a719c0be` |
| `constraints/product-separation-repository-architecture.md` | Hard constraint | `607f56c61d4bbf1aad913fbba89425ceed217ce28469e75c1ff7280ece53c096` |
| `constraints/build-goal.md` | Highest authority | `5964b080c462ad636a6fbad1be6f4c8e9e4889866ca6bfbe4dbe0dd15d2ee00c` |
| `canonical/03-domain-model-authoritative-continuation-2026-08-10.md` | Canonical 03 authoritative continuation | `0b328f2ba245177bed860513c33f015758ef1c6ebdf8519b3f82e6bcd8119267` |
| `implementation/PHASE-0-CHECKPOINT-RESPONSE-2026-08-10.md` | Human checkpoint direction | `5562ab45ebc02a1f01be639fcf56948ebd6730967dffe8e282d6a8e6ac1b5c59` |
| `implementation/PHASE-0-ARCHITECTURE-APPROVAL-2026-08-10.md` | Human architecture approval and private-repository decision | `a49db74f07a2ec2a5e65b4e833bab7c8f76fb5c2cff9a5333e2bb50a8d25aaff` |

## Review and conversion notes

- All nine source inputs were read in full before Phase 0 architecture drafting began.
- Structural OOXML review confirmed that the original and re-provided Canonical Document 03 jumped from Section 11.2 to Section 26. The owner then supplied an explicit authoritative Section 12-to-end continuation. It is retained verbatim and deterministically merged by `scripts/consulting-os/restore_doc03_continuation.py`; Sections 12-30 each occur exactly once in the restored DOCX extraction and Markdown. `LECO-001` is resolved.
- Byte-level review confirmed that the supplied Goal attachment ends during Final Definition of Done item 5. The owner checkpoint response explicitly confirmed the authoritative V1 Definition of Done and Document 07 phase authority, resolving `LECO-005`.
- The DOCX files retain authoritative formatting, tables, and page structure; Document 03's added tables use explicit widths and repeating header rows. Searchable Markdown retains textual content but may simplify Word layout.
- The packaged DOCX renderer could not run because LibreOffice/`soffice` is unavailable in the environment. Structural review and extraction checks were completed; visual page-render QA was not available.
- Conversion is reproducible through `scripts/consulting-os/extract_docx.py`, and the Document 03 restoration through `scripts/consulting-os/restore_doc03_continuation.py`, using the bundled document runtime.
- Phase 0 documentation integrity and Appendix A mapping coverage are reproducible through `scripts/consulting-os/verify_phase0_docs.ps1`.
- The architecture approval selects this separate private repository, prohibits future Consulting implementation in the Ministry repository, defers shared extraction, and keeps Phase 1 unauthorized.
