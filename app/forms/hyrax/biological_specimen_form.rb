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
        :latitude,
        :longitude,
        :numeric_time,
        :original_location,
        :periodic_time,
        :vouchered,
        :idigbio_recordset_id,
        :idigbio_uuid,
        :is_type_specimen,
        :occurrence_id,
        :sex
    ]

    self.terms -= [ :keyword, :license, :rights_statement, :subject, :title, :language, :source, :resource_type ]

    self.required_fields = [ :vouchered ]

    self.single_valued_fields = [
        :bibliographic_citation,
        :catalog_number,
        :collection_code,
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
        :sex
    ]

    # These show above the fold
    def primary_terms
      required_fields + [
          :bibliographic_citation,
          :based_near,
          :catalog_number,
          :collection_code,
          :date_created,
          :identifier,
          :related_url
      ]
    end

  end
end
