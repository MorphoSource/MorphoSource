# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  # Generated form for BiologicalSpecimen
  class BiologicalSpecimenForm < Hyrax::Forms::WorkForm

    include SingleValuedForm
    class_attribute :single_value_fields

    self.model_class = ::BiologicalSpecimen

    self.terms += [
        :bibliographic_citation,
        :catalog_number,
        :collection_code,
        :institution,
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

    self.terms -= [ :keyword, :license, :rights_statement, :subject, :language, :source, :resource_type ]

    self.required_fields = [ :institution, :title, :vouchered ]

    self.single_valued_fields = [
        :bibliographic_citation,
        :title,
        :catalog_number,
        :collection_code,
        :date_created,
        :description,
        :institution,
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

    # TODO make title required for CHOs, not for Biological Specimens
  end
end
