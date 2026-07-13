# Deliverable 1 — Field Crosswalk (documentation only)

_Every source field is cited to a repo file. Solr field names are the indexed names a Phase-1
serializer reads. "GAP" = data Linked Art wants that MorphoSource lacks, or that is not in
Solr and would need an additive index change (flagged, not done here)._

Organized around the **digitization-provenance spine** (the verified data model):

```
BiologicalSpecimen / CHO   ◄──objectID──   ImagingEvent   ──member──►   Media   ──member──►   ProcessingEvent
      (E19 / E22)              (Production activity)        (DigitalObject)      (Modification activity)
```

## Verified relationship facts the serializer must honor

- **No FK from Media → physical object.** The only explicit pointer lives on the
  **ImagingEvent**: `physical_object_id`, predicate `https://www.morphosource.org/terms/objectID`
  (`app/models/concerns/morphosource/imaging_event_metadata.rb:13`; consumed at
  `app/models/imaging_event.rb:162-164`). The membership chain is
  `ImagingEvent → Media → ProcessingEvent` (`imaging_event.rb:63`, `media.rb:26`).
- Media reaches its object only transitively (`media.rb:219-222`), and
  `ancestors`/`descendants` **recurse over Fedora** via `ActiveFedora::Base.find`
  (`lib/morphosource/works/base.rb:68-78, 205-223`) — **forbidden** in the serializer.
- **Read source = Solr, multi-document fan-out.** The Media Solr doc denormalizes the spine so
  most traversal is avoided (`app/indexers/media_indexer.rb`): `physical_object_id_ssim` (:123),
  `physical_object_title_ssim` (:125), `institution_code_ssim` (:127), `collection_code_ssim`
  (:130), `catalog_number_ssim` (:132), `occurrence_id_ssim` (:134), `taxonomy_ssim` (:140),
  `external_taxonomy_ssim` (:138, GBIF terms), `media_organization_id_ssim` (:148),
  `imaging_event_id_tesim` (:172), `media_device_id_ssim` (:179),
  `media_device_facility_organization_id_ssim` (:185), `ark_ssim` (:47), `doi_ssim` (:48),
  `license_ssim` (:62), `rights_statement_ssim` (:63), `file_set_ids_ssim` (:20),
  `remote_manifest_url_ssi` (:49). Full CHO/specimen/event metadata lives on **their own** Solr
  docs, fetched by id as a small per-record fan-out. A single-hop Solr member lookup already
  exists: `Morphosource::Works::Base#member_docs` (`lib/morphosource/works/base.rb:85-88`).

---

## 1. CulturalHeritageObject → `HumanMadeObject`  (PRIMARY FOCUS)

Source concern: `app/models/concerns/morphosource/cultural_heritage_object_metadata.rb`,
`physical_object_metadata.rb`, `location_metadata.rb`. Read from the CHO's **own** Solr doc.

| MorphoSource field | Predicate (current) | Solr field | Linked Art property + class | Authority |
|---|---|---|---|---|
| `title` | dc:title | `title_tesim` | `identified_by` → `Name` classified_as aat:300404670 (primary name) | — |
| `ark` | ms:ark | `ark_tesim` | `identified_by` → `Identifier` (aat:300404626 accession no.) **and** `equivalent` → ARK resolver URI | ARK/EZID |
| `id` (Fedora id) | — | `id` | JSON `id` = `.jsonld` endpoint URL | — |
| `aat_type` | ms:aatType | **`aat_type_tesim` (URI)** / `aat_type_label_tesim` | `classified_as` → `Type` (the object type) | **Getty AAT** |
| `cho_type` (free text) | ms:choType | `cho_type_tesim` | fallback `classified_as` label when `aat_type` empty (GAP: no URI) | local |
| `aat_material` | ms:aatMaterial | **`aat_material_tesim` (URI)** / `_label_tesim` | `made_of` → `Material` | **Getty AAT** |
| `material` (free text) | dc:medium | `material_tesim` | `made_of` label fallback (GAP: no URI) | local |
| `aat_attribute` | ms:aatAttribute | **`aat_attribute_tesim` (URI)** / `_label_tesim` | `classified_as` (aspect/attribute) | **Getty AAT** |
| `aat_period` | ms:aatPeriod | **`aat_period_tesim` (URI)** / `_label_tesim` | `produced_by` → `Production` → `timespan`/`classified_as` period | **Getty AAT** |
| `based_near` / `tgn` | dcterms:TGN | **`tgn_tesim` / `based_near_tesim` (URI)** + `_label_tesim` | `current_location` → `Place` (`equivalent` → TGN URI) | **Getty TGN** |
| `current_location` | edm:currentLocation | `current_location_tesim` | `current_location` label fallback / holding note | local |
| `dimensions` | dc:format | `dimensions_tesim` | `dimension` → `Dimension` (GAP: unparsed free text; not structured value+unit) | GAP |
| `catalog_number` | dwc:catalogNumber | `catalog_number_tesim` | `identified_by` → `Identifier` (aat:300312355 catalog no.) | — |
| `institution_code` | dwc:organizationCode | `institution_code_tesim` | `current_custodian`/`current_owner` → `Group` (resolve org) | ROR (GAP) |
| `collection_code` | dwc:collectionCode | `collection_code_tesim` | `member_of` → `Set` (the collection) | — |
| `provenance_*` | ms:/dc:provenance | `provenance_*_tesim` | `produced_by` / `changed_ownership_through` (Acquisition) — thin | GAP (unstructured) |
| description | dc:description | `description_tesim` | `referred_to_by` → `LinguisticObject` (aat:300435416 description) | — |
| license / rights | (basic md) | `license_tesim`, `rights_statement_tesim` (CHO: basic-md fields) | `subject_to` → `Right` / `conforms_to` license URI | RightsStatements.org / CC |
| → its public Media | (via ImagingEvent) | reverse lookup (see §4) | `representation` → `DigitalObject` | — |

**GAPs (CHO):** structured `dimension` value+unit; org URIs (ROL/ROR/ULAN) — only codes/labels
today; `produced_by` actor/date for the object itself is usually absent (CHOs rarely carry a
maker) — omit rather than fabricate.

## 2. BiologicalSpecimen → thin `HumanMadeObject`-shaped physical object + DwC bridge (HYBRID)

Source: `biological_specimen_metadata.rb`, `physical_object_metadata.rb`, `location_metadata.rb`,
`taxonomy_metadata.rb`. Type as a **physical object classified as a natural-science specimen**
(AAT 300235504 "specimens (research)") — **do not** assert human-made semantics. Read from the
specimen's own Solr doc + its Taxonomy work doc.

| MorphoSource field | Predicate | Solr field | Linked Art | Note |
|---|---|---|---|---|
| `title` | dc:title | `title_tesim` | `identified_by` → `Name` | |
| `ark` | ms:ark | `ark_tesim` | `identified_by`→`Identifier` + `equivalent` ARK | |
| `catalog_number` | dwc:catalogNumber | `catalog_number_tesim` | `identified_by`→`Identifier` (aat:300312355) | |
| `occurrence_id` | dwc:occurrenceID | `occurrence_id_ssim` | `identified_by`→`Identifier` + `equivalent` (if resolvable, e.g. GBIF) | |
| `institution_code` | dwc:organizationCode | `institution_code_tesim` | `current_custodian` → `Group` | |
| `collection_code` | dwc:collectionCode | `collection_code_tesim` | `member_of` → `Set` | |
| `idigbio_uuid` | ms:idigbioUUID | `idigbio_uuid_tesim` | `equivalent` → iDigBio record URI | |
| `is_type_specimen` | dwc:typeStatus | `is_type_specimen_tesim` | `classified_as` → `Type` (aat type-specimen concept) | GAP: no AAT reconciliation |
| `sex`, `vouchered` | dwc:sex / disposition | `sex_tesim`, `vouchered_tesim` | `referred_to_by` → `LinguisticObject` classified by AAT aspect | GAP: DwC→AAT map |
| taxon (via `taxonomy_id`) | ms:taxonomyID (Valkyrie assoc) | `taxonomy_ssim` (denorm) / Taxonomy doc `taxonomy_genus_tesim`…`taxonomy_species_tesim`, `gbif_key_ssim` | `referred_to_by`→`LinguisticObject` "taxon"; **`equivalent` → GBIF species URI** from `gbif_key` | Taxonomy is a separate Valkyrie work (`biological_specimen.rb:32`) |
| GBIF terms | — | `external_taxonomy_ssim`/`gbif_key_ssim` | `equivalent` → `https://www.gbif.org/species/<key>` | **GBIF** |
| locality/country/state/city | dwc:locality/country/… | `address_tesim`,`country_tesim`,`state_province_ssim`,`city_ssim` | `encountered_by`/found → `Place` (see below) | |
| `latitude`/`longitude` | exif:gps* | `latitude_tesim`,`longitude_tesim` | `Place.defined_by` → WKT `POINT(lon lat)` | |
| `tgn` | dcterms:TGN | `tgn_tesim` | `Place.equivalent` → TGN URI (only controlled_property on specimens) | **Getty TGN** |
| `formation`,`numeric_time`,`context` | dwc:formation/… | `formation_tesim`,`numeric_time_tesim` | `referred_to_by` geological-context note | GAP: no chronostratigraphy URI |
| license/rights | ms:/basic | `license_tesim`,`rights_statement_tesim` | `subject_to` → `Right` | |
| → its public Media | via ImagingEvent | reverse lookup | `representation` → `DigitalObject` | |

**Lossiness / open questions (specimen):** (a) natural-history collecting event (E19
encounter, recordedBy/eventDate) is only partially modeled and mostly unreconciled strings —
flag as GAP; (b) `recordedBy`/`identifiedBy` are free-text, **not** ORCID/person URIs — emit as
`Name` strings, **do not** promise `carried_out_by` person links (GAP); (c) specimens carry **no
AAT** (only TGN) — object typing is a single AAT literal at best. The richer, less-lossy home
for this data is a **Digital Specimen (openDS)** serialization — see roadmap Phase 3.

## 3. Media → `DigitalObject`   (physical↔digital link lives on the ImagingEvent)

Source: `media_metadata.rb`; Solr denormalized fields per §"relationship facts". The serializer
starts from Media, uses `imaging_event_id_tesim` and `physical_object_id_ssim` to wire the link.

| MorphoSource field | Solr field | Linked Art |
|---|---|---|
| `id` | `id` | JSON `id` = `.jsonld` URL |
| `ark` / `doi` | `ark_ssim` / `doi_ssim` | `identified_by`→`Identifier` + `equivalent` (ARK resolver, `https://doi.org/<doi>`) |
| `title` | `title_tesim` | `identified_by`→`Name` |
| `media_type`/modality | `human_readable_media_type_ssim`, `modality_ssim` | `classified_as` → `Type` (3D mesh / CT image series / 2D image — map to AAT) — GAP: local→AAT map |
| physical object link | `physical_object_id_ssim` (on Media) | `represents` / `digitally_shows` → the object; reciprocal on object = `representation` |
| `license`/`rights` | `license_ssim`,`rights_statement_ssim` | `subject_to`→`Right`; `conforms_to` license URI |
| `remote_manifest_url` | `remote_manifest_url_ssi` | `subject_of`→ IIIF `DigitalObject` (`conforms_to` IIIF Presentation) — see improvement memo |
| produced_by | `imaging_event_id_tesim` | `created_by`/`produced_by` → `Production` (the ImagingEvent, §5) |
| `file_set_ids` | `file_set_ids_ssim` | each public FileSet → child `DigitalObject` (§6) |

**Per-media-type `represents` treatment:** 3D model → `DigitalObject` classified as 3D model,
`represents` the whole object; **CT stack** → `DigitalObject` classified as image-series, each
slice not individually surfaced (GAP); **2D image** → `DigitalObject`/`VisualItem` `represents`
the object or a `part_of` it (use `part` field `part_ssi`).

## 4. Reverse link (object → its Media) without Fedora

Media denormalizes `physical_object_id_ssim`. To list a CHO/specimen's public digital
surrogates: Solr query `physical_object_id_ssim:<objid> AND has_model_ssim:Media AND
visibility_ssi:open`. This is the reciprocal `representation` edge, computed from Solr only.

## 5. ImagingEvent → `Production` (`produced_by` of the Media DigitalObject) — THE HINGE

Source: `imaging_event_metadata.rb`, `app/models/imaging_event.rb`. Read from the ImagingEvent's
own Solr doc (id from Media's `imaging_event_id_tesim`).

| Field | Predicate | Solr | Linked Art |
|---|---|---|---|
| `physical_object_id` | ms:objectID | `physical_object_id_tesim` | ties Production output (Media) to input object — the hinge |
| `device_id` | ms:deviceID | `device_id_tesim` / Media `media_device_id_ssim` | `Production.used_specific_object` → the Device (§7) |
| facility org | — | `media_device_facility_organization_id_ssim` (on Media) | `Production.carried_out_by` → `Group` |
| `ie_modality` | ac:captureDevice | `ie_modality_tesim` | `Production.technique` → `Type` (map modality→AAT) — GAP |
| `software` | ms:software | `software_tesim` | `Production` note / `used_specific_object` software |
| `date_created` | dc:created | `date_created_tesim` | `Production.timespan` → `TimeSpan` |
| CT params (kV, mA, …) | healthcarevocab | many `*_tesim` | `Production` `referred_to_by` technical notes (GAP: no CRM props) |

## 5b. ProcessingEvent → subsequent modification `Activity`

Source: `processing_event_metadata.rb`. `processing_activity` uses Audubon Core
`resourceCreationTechnique` (`processing_event_metadata.rb:13`).

| Field | Solr | Linked Art |
|---|---|---|
| `processing_activity` | `processing_activity_tesim` | `Modification.technique` → `Type` (AC technique → AAT) — GAP |
| `processing_activity_software`/`software` | `*_software_tesim` | `used_specific_object` (software) |
| `processing_activity_description` | `*_description_tesim` | `referred_to_by` note |

## 6. FileSet → child `DigitalObject`

Source: `app/indexers/ms_file_set_indexer.rb`, Hyrax FileSet. **Public FileSets only** (§0.5).

| Field | Solr | Linked Art |
|---|---|---|
| download route | (computed from id) | `access_point` → `DigitalObject`/`id` = download URL (**public FileSets only**) |
| `mime_type` | `mime_type_ssi` | `format` (media type) |
| `file_size` | `file_size_lts` | `dimension` → `Dimension` (bytes, aat filesize) |
| `label` | `label_tesim` | `identified_by`→`Name` |
| `remote_manifest_url` | `remote_manifest_url_ssi` | `conforms_to` IIIF; link IIIF manifest |

## 7. Device → equipment (`crm:P16 used_specific_object` in the ImagingEvent Production)

Source: `device_metadata.rb`. Id from `media_device_id_ssim` / ImagingEvent `device_id_tesim`.

| Field | Solr | Linked Art |
|---|---|---|
| `title`/`creator` | `title_tesim`/`creator_tesim` | `HumanMadeObject`/`Type` `_label` (scanner make+model) |
| `modality` | `modality_tesim` | `classified_as` |
| `organization_id` | `organization_id_tesim` | `current_owner` → facility `Group` |
| `ark` | `ark_tesim` | `identified_by`→`Identifier` |

## 8. Organization → `Group`; collections → `Set`

Source: `organization_metadata.rb`. MorphoSource itself is the publishing `Group`; source
institution is `current_custodian`/`current_owner` of the object.

| Field | Predicate | Solr | Linked Art |
|---|---|---|---|
| `institution_name` | dwc:institutionName | `institution_name_ssim` | `Group._label` |
| `institution_code` | dwc:organizationID | `institution_code_ssim` | `identified_by`→`Identifier`; **`equivalent` → ROR/GRID** — GAP (not stored) |
| `collection_code` | dwc:collectionCode | `collection_code_ssim` | `Set` grouping objects |
| address/city/country | dwc:locality/… | `address_tesim`/… | `Group.residence` → `Place` |
| `contact_person`/`data_manager` | ms: | `contact_person_ssim` | omit (PII — not public) |

## 9. People, places, taxa → external authorities

- **People:** DwC `recordedBy`/`identifiedBy`, and creator/depositor, are **unreconciled
  strings** — emit as `Name`, not `carried_out_by` person URIs. Where a researcher **ORCID**
  exists it is the correct authority (not ULAN); MorphoSource does not currently store ORCIDs
  on works → **GAP**.
- **Places:** TGN URI (`tgn_tesim`) present on CHO and specimen; GeoNames not stored → GAP.
- **Taxa:** GBIF key present (`gbif_key_ssim`) → `equivalent https://www.gbif.org/species/<key>`.
- **Orgs:** ROR/GRID/ULAN not stored → GAP (improvement memo).

---

## Worked example A — a public CulturalHeritageObject

> Representative document built from the verified field/Solr structure above (illustrative
> values). Phase-1 DoD requires generating this from a **real** public CHO Solr doc and passing
> the linked.art validator + a JSON-LD expand/frame round-trip in CI before merge.

```json
{
  "@context": "https://linked.art/ns/v1/linked-art.json",
  "id": "https://www.morphosource.org/concern/cultural_heritage_objects/000123456.jsonld",
  "type": "HumanMadeObject",
  "_label": "Carved stone figurine",
  "identified_by": [
    { "type": "Name", "content": "Carved stone figurine",
      "classified_as": [ { "id": "http://vocab.getty.edu/aat/300404670", "type": "Type", "_label": "primary name" } ] },
    { "type": "Identifier", "content": "CHO-2019-0042",
      "classified_as": [ { "id": "http://vocab.getty.edu/aat/300312355", "type": "Type", "_label": "catalog number" } ] },
    { "type": "Identifier", "content": "ark:/87602/m4/123456",
      "classified_as": [ { "id": "http://vocab.getty.edu/aat/300404626", "type": "Type", "_label": "accession number" } ] }
  ],
  "equivalent": [ { "id": "https://n2t.net/ark:/87602/m4/123456", "type": "HumanMadeObject" } ],
  "classified_as": [
    { "id": "http://vocab.getty.edu/aat/300047676", "type": "Type", "_label": "sculpture" }
  ],
  "made_of": [
    { "id": "http://vocab.getty.edu/aat/300011176", "type": "Material", "_label": "limestone" }
  ],
  "produced_by": {
    "type": "Production",
    "timespan": { "type": "TimeSpan", "_label": "Neolithic",
      "classified_as": [ { "id": "http://vocab.getty.edu/aat/300020219", "type": "Type", "_label": "Neolithic" } ] }
  },
  "current_location": {
    "type": "Place", "_label": "Anatolia",
    "equivalent": [ { "id": "http://vocab.getty.edu/tgn/7000644", "type": "Place" } ]
  },
  "current_custodian": [
    { "type": "Group", "_label": "Example Museum of Anthropology" }
  ],
  "member_of": [ { "type": "Set", "_label": "Archaeology Collection" } ],
  "subject_to": [
    { "type": "Right",
      "classified_as": [ { "id": "https://creativecommons.org/licenses/by/4.0/", "type": "Type", "_label": "CC BY 4.0" } ] }
  ],
  "representation": [
    { "id": "https://www.morphosource.org/concern/media/000987654.jsonld",
      "type": "DigitalObject", "_label": "3D mesh of carved stone figurine" }
  ]
}
```

## Worked example B — a public BiologicalSpecimen (thin, honest)

> Illustrative. Typed as a physical object classified as a research specimen — no human-made
> assertions. Same Phase-1 DoD validation gate applies.

```json
{
  "@context": "https://linked.art/ns/v1/linked-art.json",
  "id": "https://www.morphosource.org/concern/biological_specimens/000222333.jsonld",
  "type": "HumanMadeObject",
  "_label": "Pan troglodytes cranium (MCZ 12345)",
  "classified_as": [
    { "id": "http://vocab.getty.edu/aat/300235504", "type": "Type", "_label": "specimens (research)" }
  ],
  "identified_by": [
    { "type": "Name", "content": "Pan troglodytes cranium (MCZ 12345)",
      "classified_as": [ { "id": "http://vocab.getty.edu/aat/300404670", "type": "Type", "_label": "primary name" } ] },
    { "type": "Identifier", "content": "MCZ 12345",
      "classified_as": [ { "id": "http://vocab.getty.edu/aat/300312355", "type": "Type", "_label": "catalog number" } ] },
    { "type": "Identifier", "content": "ark:/87602/m4/222333" }
  ],
  "equivalent": [ { "id": "https://n2t.net/ark:/87602/m4/222333", "type": "HumanMadeObject" } ],
  "referred_to_by": [
    { "type": "LinguisticObject", "content": "Pan troglodytes",
      "classified_as": [ { "id": "http://vocab.getty.edu/aat/300417443", "type": "Type", "_label": "scientific names" } ],
      "equivalent": [ { "id": "https://www.gbif.org/species/5219534", "type": "LinguisticObject" } ] }
  ],
  "current_custodian": [
    { "type": "Group", "_label": "Museum of Comparative Zoology" }
  ],
  "current_location": {
    "type": "Place", "_label": "Gombe, Tanzania",
    "defined_by": "POINT(29.6 -4.67)",
    "equivalent": [ { "id": "http://vocab.getty.edu/tgn/7002894", "type": "Place" } ]
  },
  "subject_to": [
    { "type": "Right",
      "classified_as": [ { "id": "http://creativecommons.org/publicdomain/zero/1.0/", "type": "Type", "_label": "CC0" } ] }
  ],
  "representation": [
    { "id": "https://www.morphosource.org/concern/media/000444555.jsonld",
      "type": "DigitalObject", "_label": "CT image series of cranium" }
  ]
}
```
