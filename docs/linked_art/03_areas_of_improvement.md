# Deliverable 3 — Areas of Improvement Memo

Each item: benefit, rough effort, disruption. Ordered by value-to-effort for aggregation.

| # | Improvement | Benefit | Effort | Disruption |
|---|---|---|---|---|
| 1 | **Reconcile Darwin Core / local vocabs → Getty AAT for specimens.** Specimens carry only TGN, no AAT (`biological_specimen_metadata.rb:47`); typeStatus/sex/disposition/media-type/technique are local literals. Build DwC→AAT and modality/technique→AAT maps. | Turns thin specimen Linked Art into `classified_as` with dereferenceable URIs; unlocks faceted LOD aggregation for the 99%. | M (curation-heavy) | Additive (new lookup tables + optional new Solr fields). |
| 2 | **Dereferenceable persistent URIs for actors, places, taxa, events** — not just objects. Today only ARK/DOI (objects) + TGN/GBIF (some) resolve. | Aggregators can follow `equivalent`/`carried_out_by` edges; graph becomes traversable, not string-bound. | M | Additive. |
| 3 | **Authority alignment: ROR/GRID (orgs), ORCID (people), GeoNames (places), GBIF (taxa).** Orgs store only DwC codes (`organization_metadata.rb:12`); people are unreconciled strings; ORCIDs not stored on works. | Institutional + researcher identity resolvable; cross-repo joins. | M–L (needs new persisted fields + a reconciliation workflow) | Additive fields; **not** zero-disruption if it adds required form fields. |
| 4 | **Richer event modeling** — actor, TimeSpan, technique, equipment on Imaging/Processing events (CRM `Production`/`Modification`). Data largely exists (`imaging_event_metadata.rb`, `processing_event_metadata.rb`, Device via `device_id`). | The digitization-provenance spine — MorphoSource's highest-value LA contribution: verifiable provenance of digital surrogates. | M | Additive (Phase 2 serialization; maybe small index additions). |
| 5 | **IIIF alignment for 2D and 3D media, targeting IIIF Presentation API 4.0** (RC, https://iiif.io/api/presentation/4.0/, incl. 3D). Factor in existing `remote_manifest_url` / `remote_manifest_url_ssi` (`media_metadata.rb:10`, `media_indexer.rb:49`, `ms_file_set_indexer.rb`). | MorphoSource is a cutting-edge IIIF-Presentation-4 / 3D-IIIF adopter; DigitalObject `conforms_to` + manifest linkage makes 3D surrogates viewer-interoperable. Treat 3D IIIF as in-scope. | M | Additive; reuse existing manifests where present, generate where absent (larger effort). |
| 6 | **Rights/licensing modeling** — Solr already carries `license_ssim`, `rights_statement_ssim` (`media_indexer.rb:62-63`). Map to `subject_to`→`Right` + CC/RightsStatements.org URIs. | Machine-actionable reuse terms; required for responsible aggregation. | S | Additive; usable in Phase 1. |
| 7 | **Natural-history representation decision (DwC ↔ CIDOC-CRM) + complementary Digital Specimen (openDS / GBIF Unified Model).** Weigh CRMsci, Darwin-SW, DwC-RDF guide, ABCD/EFG, Latimer Core, DiSSCo openDS. | For the 99%, a Digital Specimen endpoint likely delivers more aggregation value than lossy Linked Art. Honest, community-aligned. | L | New additive endpoint (Phase 3). |
| 8 | **Index the AAT/TGN URIs — N/A for CHO, needed elsewhere.** VERIFIED: CHO AAT/TGN URIs are **already** in Solr (`aat_type_tesim` etc. via `deep_indexing_service.rb:69-78`), so **no change needed for CHOs**. Specimens/Media would need additive fields if their (future) AAT mappings must be queryable. | Removes the only thing that would have made Phase 1 non-zero-disruption for CHOs (it doesn't — confirmed). | S (only if/when specimen AAT is added) | Additive. |
| 9 | **Publishing infra: Linked Art `Set` endpoints + Activity Streams for harvesting.** | Lets partners mirror/incrementally sync all public records — the payoff of standardization. | M–L | New additive read endpoints (Phase 3). |

**Legend:** S ≤ ~1 wk · M ~2–4 wk · L > 1 mo (rough, single-dev).

**Non-obvious verified fact worth carrying forward:** the CHO AAT/TGN **URIs are indexed today**
(`aat_type_tesim`/`tgn_tesim`, alongside `*_label_tesim`), so CHO Linked Art with real Getty URIs
is genuinely zero-disruption. The disruption risk that _did_ exist would have been specimen AAT
(they carry no AAT at all) — item #1, deferred out of Phase 1.
