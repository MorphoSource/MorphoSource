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
                :organization_id,
                :device_organization_id,
                :media_id,
                :processing_event_id,
                :raw_or_derived_media,
                :parent_media_how_to_proceed,
                :parent_media_list,
                :parent_media_search,
                :cho_id,
                :cho_search_catalog_number,
                :cho_search_collection_code,
                :cho_search_institution_code,
                :cho_search_occurrence_id,
                :taxonomy_id,
                :taxonomy_search,
                :is_start_over,
                :saved_step,
                :modality


  MEDIA_DERIVED = 'Derived'
  MEDIA_RAW = 'Raw'
  PHYSICAL_OBJECT_BIOSPEC = { code: 'biospec',
                              klass: BiologicalSpecimen,
                              label: BiologicalSpecimen.human_readable_type }
  PHYSICAL_OBJECT_CHO = { code: 'cho',
                          klass: CulturalHeritageObject,
                          label: CulturalHeritageObject.human_readable_type }

  PARENT_MEDIA_LATER = ['Submit derived media and information for media acquisition involving single parent. Can add parent media file later. Can add information and file for additional parent media later as well.', 'later']
  PARENT_MEDIA_NOW = ['Enter information and file for parent media now. This will start submission over. Can add information and file for derived media or additional parent media later', 'now']
end
