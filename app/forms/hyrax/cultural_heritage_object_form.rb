# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
module Hyrax
  # Generated form for CulturalHeritageObject
  class CulturalHeritageObjectForm < Hyrax::Forms::WorkForm
    include Morphosource::FormMethods
    include ChildCreateButton
    include SingleValuedForm
    class_attribute :single_value_fields

    self.model_class = ::CulturalHeritageObject

    self.terms += [
        :short_title,
        :bibliographic_citation,
        :institution_code,
        :catalog_number,
        :collection_code,
        :latitude,
        :longitude,
        :numeric_time,
        :organization_id,
        :original_location,
        :periodic_time,
        :vouchered,
        :cho_type,
        :material
    ]

    self.terms -= [ :keyword, :license, :rights_statement, :subject, :title, :language, :source, :resource_type ]

    self.required_fields = [ :vouchered ]

    self.single_valued_fields = [
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
        :short_title,
        :institution_code
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
          :related_url
      ]
    end

    def secondary_terms
      []
    end

    def self.build_permitted_params
      super + [:organization_id]
    end

  end
end
