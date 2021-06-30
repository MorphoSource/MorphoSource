# Generated via
#  `rails generate hyrax:work EngineeringObject`
module Hyrax
  # Generated form for EngineeringObject
  class EngineeringObjectForm < Hyrax::Forms::WorkForm
    include Morphosource::FormMethods
    include SingleValuedForm
    class_attribute :single_value_fields

    self.model_class = ::EngineeringObject

    self.terms += [
      :organization_relationship,
      :organization_id,
      :institution_code,
      :catalog_number,
      :is_pak,
      :is_built_in_fiducials_present,
      :snl_assembler,
      :assembly_date,
      :preparation_notes,
      :anonymize_origin,
      :anonymize_metadata,
    ]

    self.required_fields = [
      :description
    ]

    self.single_valued_fields = [
      :organization_relationship,
      :institution_code,
      :catalog_number,
      :description,
      :is_pak,
      :is_built_in_fiducials_present,
      :snl_assembler,
      :assembly_date,
      :preparation_notes,
      :anonymize_origin,
      :anonymize_metadata,
    ]

    # These show above the fold
    def primary_terms
      required_fields + [
        :organization_relationship,
        :institution_code,
        :catalog_number,
        :description,
        :is_pak,
        :is_built_in_fiducials_present,
        :snl_assembler,
        :assembly_date,
        :preparation_notes,
        :anonymize_origin,
        :anonymize_metadata,
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
