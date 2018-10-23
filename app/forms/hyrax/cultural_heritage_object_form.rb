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
        :material,
        :short_title
    ]

    self.terms -= [ :keyword, :license, :rights_statement, :subject, :title, :language, :source, :resource_type ]

    self.required_fields = [ :vouchered ]

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
        :short_title
    ]

    # These show above the fold
    def primary_terms
      required_fields + [
          :short_title,
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

  end
end
