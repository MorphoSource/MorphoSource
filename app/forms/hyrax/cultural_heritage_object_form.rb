module Hyrax
  class CulturalHeritageObjectForm < Morphosource::PhysicalObjectForm

    self.model_class = ::CulturalHeritageObject

    self.terms += [:aat_attribute,
                   :aat_material,
                   :aat_type,
                   :cho_attribute,
                   :cho_type,
                   :material,
                   :short_title]

    self.single_valued_fields += [:short_title]

    self.required_fields += [:vouchered]

    # These show above the fold
    def primary_terms
      super + [:short_title]
    end

    def self.build_permitted_params
      super + [ { aat_attribute_attributes: [:id, :_destroy] },
                { aat_material_attributes: [:id, :_destroy] },
                { aat_type_attributes: [:id, :_destroy] },
                { periodic_time_attributes: [:id, :_destroy] } ]
    end

  end
end
