# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
module Hyrax
  # Generated form for CulturalHeritageObject
  class CulturalHeritageObjectForm < Hyrax::Forms::WorkForm

    include SingleValuedForm
    class_attribute :single_value_fields

    self.model_class = ::CulturalHeritageObject

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
        :cho_type,
        :material
    ]

    self.terms -= [ :keyword, :license, :rights_statement, :subject, :language, :source, :resource_type ]

    self.required_fields = [ :title, :vouchered ]

    self.single_valued_fields = [
        :bibliographic_citation,
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
        :creator,
        :title
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
          :institution,
          :related_url
      ]
    end

    # TODO make title required for CHOs, not for Biological Specimens
  end
end
