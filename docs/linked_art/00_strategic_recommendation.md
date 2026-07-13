# Deliverable 0 — Strategic Recommendation & Open Verifications

_Status: for maintainer review. No code, no data-model, indexing, route, or UI change is
proposed or made by this document. Cited file paths are from this repo unless prefixed
`hyrax-5.0.5:` (the engine at `/Users/jbo4/MorphoSource/hyrax-5.0.5`)._

This is the one-page steer requested before the full 8-type crosswalk. Read this first; it
resolves the forks that shape everything downstream.

---

## 0.1 The key verification resolved favorably: AAT/TGN **URIs are already in Solr**

**Question (Deliverable 0):** does Solr carry the dereferenceable Getty AAT/TGN _URI_, or
only the `*_label_tesim` labels? If only labels, Phase 1 is not zero-disruption.

**Answer: the URIs are indexed today.** Verified by tracing the indexing path:

- CHO uses `Hyrax::IndexesLinkedMetadata` (`app/indexers/cultural_heritage_object_indexer.rb:10`),
  which swaps in `Hyrax::DeepIndexingService`
  (`hyrax-5.0.5:app/indexers/concerns/hyrax/indexes_linked_metadata.rb`).
- For every controlled property, `DeepIndexingService#append_label_and_uri`
  (`hyrax-5.0.5:app/indexers/hyrax/deep_indexing_service.rb:69-78`) inserts **two** Solr
  fields: the **URI** into the base field key (`aat_type`, `aat_material`, `aat_attribute`,
  `aat_period`, `tgn`, `based_near`) and the **label** into `<key>_label`.
- With the property behaviors `:stored_searchable, :facetable`
  (`app/models/concerns/morphosource/cultural_heritage_object_metadata.rb:12-38`), the base
  key solrizes to **`aat_type_tesim`** (and `aat_type_sim`) holding the **dereferenceable
  Getty URI**, e.g. `http://vocab.getty.edu/aat/300033618`; the label lands in
  `aat_type_label_tesim`. The CHO indexer already reads `aat_type_label_tesim` /
  `aat_material_label_tesim` (`cultural_heritage_object_indexer.rb:14-15`), which confirms
  both halves exist.
- `controlled_properties` for CHO = `[:aat_attribute, :aat_material, :aat_period, :aat_type,
  :based_near, :tgn]` (`cultural_heritage_object_metadata.rb:47`). TGN place URI is in
  `tgn_tesim`; `based_near` (also TGN-backed) in `based_near_tesim` + `based_near_label_tesim`.

**Consequence:** reusing AAT/TGN URIs for CHOs in Phase 1 is **strictly zero-disruption** —
they are read directly from the CHO's own Solr document. No additive indexing change is
required for CHOs. (BiologicalSpecimen only declares `controlled_properties = [:tgn]`
— `biological_specimen_metadata.rb:47` — so specimens have a TGN URI but **no AAT**; that is
a data gap, not an indexing gap, addressed in the crosswalk and the improvement memo.)

---

## 0.2 Fork 1 — Bio-specimen target: **Hybrid (recommended)**

A biological specimen is CIDOC-CRM **E20 Biological Object**, not the human-made **E22** that
Linked Art centers on. Do not force rich Linked Art onto it. Recommendation:

- **Linked Art as the interoperability envelope for the whole graph** — the digitization
  spine, the digital objects (Media/FileSet), the events, and CHOs. This is where Linked Art
  is a strong fit and where aggregators already speak it.
- **Specimen node:** emit valid Linked Art (a physical object carrying its Darwin Core
  identifiers, taxon label, and locality/TGN place), but keep it deliberately thin and
  **honest** — classify it as a natural-science specimen via AAT and do **not** invent
  human-made structure (no `made_of` artistry, no production-by-artist). This keeps the
  pipeline from breaking on the 99% and yields aggregator-consumable output.
- **Complementary Digital Specimen serialization (roadmap, not Phase 1):** for the 99%, a
  **DiSSCo openDS / GBIF Unified Model** Digital Specimen representation will deliver more
  aggregation value to the natural-history community than a lossy Linked Art mapping. Prior
  art weighed: **CRMsci** (scientific observation), **Darwin-SW** / TDWG **DwC-RDF guide**
  (the standards-track way to express DwC as RDF), **ABCD/EFG** and **Latimer Core**
  (collection-level description), **DiSSCo openDS / Digital Specimen** and the **GBIF Unified
  Model** (the emerging natural-history aggregation targets).

**Honest statement for maintainers:** for natural-history specimens, Linked Art is the wrong
center of gravity. Ship valid-but-thin Linked Art now so the 99% don't break aggregation, and
treat a Digital Specimen endpoint as the higher-value natural-history deliverable later.
CHOs are where Linked Art earns its keep.

## 0.3 Fork 2 — Serialization library: **thin hand-built hashes → JSON-LD (option iii)**

| Option | Verdict |
|---|---|
| (i) `cromulent` gem | **Reject.** Largely dormant; pulls a heavy RDF/`crom` dependency tree; risks lagging the current `https://linked.art/ns/v1/linked-art.json` context; constrains output shape. |
| (ii) Fully hand-rolled RDF serializer | **Reject.** Reinvents JSON-LD plumbing for no benefit; Linked Art is deliberately a fixed JSON _shape_, not free-form RDF. |
| (iii) **Thin builders emitting plain Ruby Hashes → `to_json`, referencing the Linked Art `@context` by URL** | **Recommend.** Trivially Rails 6.1 / Ruby compatible; always emits the current context (referenced by URL); best bulk-serialization performance (no graph object overhead); output shape fully under our control; testable by golden files + JSON-LD expansion round-trips using the already-present `json-ld`/`linkeddata` gems (`hyrax-5.0.5:app/indexers/hyrax/deep_indexing_service.rb:2` shows `linkeddata` is already a dependency). |

## 0.4 Fork 3 — Delivery mechanism: **dedicated `.jsonld` endpoint (canonical), content-negotiation as alias**

- **Canonical:** a dedicated `.../<id>.jsonld` route whose response `id` **is that URL** —
  explicit, cacheable, unambiguously dereferenceable, and easy to hand to a `Set` harvester
  later.
- **Alias:** honor `Accept: application/ld+json` on the existing show routes as a convenience
  redirect/render to the same document. This keeps default HTML behavior untouched (hard
  constraint) because negotiation only triggers on the explicit media type.
- **Not Phase 1:** bulk export + Linked Art `Set` endpoints + Activity Streams for harvesting
  (roadmap Phase 3).
- **Start with CHOs** (AAT/TGN head start + primary intended consumers), then BiologicalSpecimen.

## 0.5 Access-control posture (hard constraint) — decided up front

Serialization is public/read-only and MUST mirror Hyrax visibility. Read `visibility_ssi`,
embargo/lease state, and Hyrax `suppressed_bsi` (workflow draft/under-review) from Solr:

| Record state | Linked Art behavior |
|---|---|
| Public (`visibility_ssi = open`), workflow-published | Serialize fully (public fields only). |
| Restricted / authenticated-only | **404** (no metadata, no `access_point`). |
| Embargoed / leased (not yet public) | **404** until public; after release, serialize. |
| Private / draft / `suppressed_bsi = true` | **404**. |
| Withdrawn / deleted | **Tombstone: 410 Gone** with a minimal tombstone doc (id + type + `_label` "withdrawn"), no metadata. |
| Non-public FileSets under a public work | Omit those FileSets and their `access_point`s entirely; never leak file URLs. |

`access_point`s are emitted **only** for FileSets whose own `visibility_ssi = open` **and**
whose parent Media `fileset_accessibility_ssim = open` (`media_indexer.rb:22,169,239-247`).

---

## 0.6 What to approve before the crosswalk work proceeds

1. Hybrid bio-specimen strategy (0.2).
2. Thin-hash serializer (0.3).
3. `.jsonld` endpoint + negotiation alias, CHO-first (0.4).
4. Access-control posture (0.5).

On approval, proceed to the crosswalk (`01_field_crosswalk.md`) and the Phase 1 plan
(`02_phased_roadmap.md`), then WAIT for approval again before writing code, per
`CLAUDE.md`.
