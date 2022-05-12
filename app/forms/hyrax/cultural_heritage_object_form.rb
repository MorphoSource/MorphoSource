module Hyrax
  class CulturalHeritageObjectForm < Morphosource::PhysicalObjectForm

    self.model_class = ::CulturalHeritageObject

    self.terms += [:aat_attributes,
                   :aat_material,
                   :aat_type,
                   :cho_attributes,
                   :cho_type,
                   :material,
                   :short_title]

    self.single_valued_fields += [:short_title]

    self.required_fields += [:vouchered]

    # These show above the fold
    def primary_terms
      super + [:short_title]
    end

  end
end
