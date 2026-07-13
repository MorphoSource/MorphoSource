# Deliverable 2 — Phased Roadmap

Each phase states scope, files likely touched, test strategy, an explicit non-disruption
statement, and a definition of done (DoD).

---

## Phase 1 — Read-only Linked Art serialization from Solr (achievable NOW, zero disruption)

**Scope.** Additive, read-only serialization of **public** CHOs and BiologicalSpecimens (and
their public Media/FileSet DigitalObjects) as Linked Art JSON-LD, assembled from Solr
document(s) only. CHO-first, then BiologicalSpecimen. No writes, no reindex, no data-model
change, no change to existing routes/UI.

**Delivery.** A dedicated `.jsonld` route (canonical, `id` = that URL) plus an
`Accept: application/ld+json` alias on existing show routes (negotiation only fires on the
explicit media type, so default HTML is untouched). See `00_strategic_recommendation.md` §0.4.

**Serializer.** Thin builder objects returning plain Ruby Hashes → `to_json`, referencing
`https://linked.art/ns/v1/linked-art.json` by URL (§0.3). One builder per type
(`CulturalHeritageObjectSerializer`, `BiologicalSpecimenSerializer`, `MediaSerializer`, plus
shared helpers for `Identifier`/`Name`/`Right`/`Place`).

**Assembly rule (hard).** Read only Solr. Start from the target's own Solr doc; fan out by id to
related docs (Media reverse-lookup by `physical_object_id_ssim`; ImagingEvent by
`imaging_event_id_tesim`; Device/Org by their denormalized ids). Use `Morphosource::SolrService`
and the Solr-based `member_docs` pattern (`lib/morphosource/works/base.rb:85-88`). **Never** call
`ancestors`/`descendants`/`physical_objects`/`organizations` model methods (they recurse over
Fedora — `lib/morphosource/works/base.rb:68-78, 205-223`).

**Access control (hard).** Enforce the §0.5 matrix from Solr: gate on `visibility_ssi`,
embargo/lease, `suppressed_bsi`; 404 non-public; 410 tombstone withdrawn; emit `access_point`
only for open FileSets under an open-accessibility Media. No non-public metadata or file URL may
appear in output.

**URI / versioning / stability policy.**
- `id` = the dereferenceable `.jsonld` URL; **stable for the record's life** (based on the
  MorphoSource id, not the label).
- ARK/DOI go in `identified_by` and `equivalent` (persistent even if the `.jsonld` host changes).
- Deletions → **410 Gone** tombstone; restricted/embargoed → **404**.
- `_label` changes are non-breaking (labels are not identifiers); advertise cache freshness via
  HTTP `ETag`/`Last-Modified` derived from the Solr `system_modified_dtsi`/timestamp so caching
  consumers can revalidate.

**Files likely touched (all additive).**
- `config/routes.rb` — add `.jsonld` member routes (does not alter existing route behavior).
- `app/controllers/` — a small `LinkedArtController` (or a concern mixed into show controllers
  guarded by format) returning 200/404/410 per the matrix.
- `app/services/morphosource/linked_art/*` — serializer builders + a Solr fan-out reader.
- `spec/services/...`, `spec/requests/...`, `spec/fixtures/linked_art/*.json` — golden files.
- Possibly `app/models/solr_document.rb` — read-only helper accessors (no index change).

**Test strategy.**
- **Golden-file tests**: serialized hash vs. committed expected JSON, per type and per media
  kind (3D mesh, CT series, 2D image).
- **JSON-LD round-trip**: expand + frame each output with the `json-ld` gem (already available
  via `linkeddata`, `hyrax-5.0.5:app/indexers/hyrax/deep_indexing_service.rb:2`) and assert no
  loss / no unmapped terms.
- **linked.art validator conformance**: run each golden file through the linked.art validator
  (vendored/CI step); build fails on non-conformance.
- **Access-control tests**: restricted/embargoed/private/suppressed → 404; withdrawn → 410;
  non-public FileSet omitted; assert no `access_point` leaks.

**Non-disruption statement.** Phase 1 adds routes, a controller, and services that only **read**
Solr and emit JSON. It changes no Fedora/Valkyrie schema, no Solr indexing, no existing route’s
default (HTML) behavior, and no UI. Removing Phase 1 is a pure deletion.

**Definition of done.**
1. A public CHO `.jsonld` returns valid Linked Art that **passes the linked.art validator** and
   **expands cleanly** (no unmapped terms).
2. A public BiologicalSpecimen serializes to valid, aggregator-consumable output (thin/honest).
3. Media/FileSet DigitalObjects link correctly via the ImagingEvent hinge, reverse-computed from
   Solr; `access_point`s appear only for public files.
4. Every §0.5 non-public state returns 404/410 as specified; no leak of metadata or file URLs.
5. `Accept: application/ld+json` on show routes returns the same doc; default HTML unchanged.
6. Golden-file + round-trip + validator + access-control specs all green.

---

## Phase 2 — Richer, still-additive modeling

**Scope.** Deepen event modeling (ImagingEvent `Production`: `carried_out_by` facility Group,
`used_specific_object` Device, `technique` via AAT, `TimeSpan`; ProcessingEvent `Modification`).
Add **local→AAT technique/modality/media-type maps** so `classified_as` carries URIs, not just
labels. Wire the CHO `representation` ⇄ Media `represents` edges fully. Add IIIF linkage using
existing `remote_manifest_url_ssi` (`conforms_to` IIIF Presentation).

**Files.** New AAT-mapping tables under `lib/morphosource/linked_art/`, serializer extensions,
more golden files. Possibly a small **additive** indexing change if a needed field is not in
Solr (each such change flagged and shipped as its own reindex-safe PR).

**Non-disruption.** Still read-only serialization; any indexing addition is additive and
backward-compatible (new Solr fields only). **DoD:** events serialize with actor+timespan+
technique URIs; IIIF manifests referenced; validator still green.

---

## Phase 3 — Publishing infrastructure & Digital Specimen

**Scope.** Linked Art **`Set` endpoints** (collection/institution rollups) + **Activity Streams**
for incremental harvesting; bulk export. **Complementary DiSSCo openDS / GBIF Unified Model
Digital Specimen** serialization for the 99% (the higher-value natural-history target — see
`00_strategic_recommendation.md` §0.2). Authority reconciliation groundwork (ROR/ORCID/GeoNames)
feeding `equivalent` links.

**Non-disruption.** New read endpoints + optional new persisted authority fields (additive).
**DoD:** a harvester can page a `Set` + Activity Stream to mirror all public records; a Digital
Specimen doc validates against openDS.

---

## Library decision (recap, with criteria)

| Criterion | cromulent | hand-rolled RDF | **thin hashes (chosen)** |
|---|---|---|---|
| Maintenance | dormant | us forever | ours, tiny |
| Rails 6.1 / Ruby | risk | ok | ok |
| Current LA `@context` | may lag | manual | **by URL, always current** |
| Bulk performance | object overhead | ok | **best (plain hashes)** |
| Output control | constrained | total | **total** |

**Chosen: thin hashes → JSON-LD** referencing the Linked Art context by URL, validated by
golden files + JSON-LD expansion + the linked.art validator.
