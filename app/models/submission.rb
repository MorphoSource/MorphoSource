class Submission
  include ActiveModel::Model

  attr_accessor :biospec_id,
                :biospec_or_cho,
                :biospec_search_catalog_number,
                :biospec_search_collection_code,
                :biospec_search_institution_code,
                :biospec_search_occurrence_id,
                :device_id,
                :imaging_event_id,
                :institution_id,
                :media_id,
                :raw_or_derived_media

  MEDIA_DERIVED = 'Derived'
  MEDIA_RAW = 'Raw'
  PHYSICAL_OBJECT_BIOSPEC = { code: 'biospec',
                              klass: BiologicalSpecimen,
                              label: BiologicalSpecimen.human_readable_type }
  PHYSICAL_OBJECT_CHO = { code: 'cho',
                          klass: CulturalHeritageObject,
                          label: CulturalHeritageObject.human_readable_type }

end
