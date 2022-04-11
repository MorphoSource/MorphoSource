# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  # Generated form for BiologicalSpecimen
  class BiologicalSpecimenForm < Hyrax::Forms::WorkForm
    include Morphosource::FormMethods
    include ChildCreateButton
    include SingleValuedForm
    class_attribute :single_value_fields

    self.model_class = ::BiologicalSpecimen

    self.child_create_button = true

    self.terms += [
        :bibliographic_citation,
        :catalog_number,
        :collection_code,
        :canonical_taxonomy,
        :organization_relationship,
        :institution_code,
        :latitude,
        :longitude,
        :numeric_time,
        :organization_id,
        :original_location,
        :periodic_time,
        :taxonomy_id,
        :vouchered,
        :idigbio_recordset_id,
        :idigbio_uuid,
        :is_type_specimen,
        :occurrence_id,
        :sex,
        :idigbio_link_origin
    ]

    self.terms -= [ :keyword, :license, :rights_statement, :subject, :title, :language, :source, :resource_type ]

    self.required_fields = []

    self.single_valued_fields = [
        :catalog_number,
        :collection_code,
        :canonical_taxonomy,
        :organization_relationship,
        :institution_code,
        :date_created,
        :description,
        :latitude,
        :longitude,
        :numeric_time,
        :original_location,
        :publisher,
        :vouchered,
        :idigbio_recordset_id,
        :idigbio_uuid,
        :is_type_specimen,
        :occurrence_id,
        :sex,
        :idigbio_link_origin
    ]

    # These show above the fold
    def primary_terms
      required_fields + [
          :bibliographic_citation,
          :canonical_taxonomy,
          :organization_relationship,
          :institution_code,
          :based_near,
          :catalog_number,
          :collection_code,
          :date_created,
          :identifier,
          :related_url
      ]
    end

    def secondary_terms
      []
    end

    def self.build_permitted_params
      super + [:organization_id, :taxonomy_id]
    end

  end
end
