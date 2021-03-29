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
      :institution_code,
      :catalog_number,
      :is_pak,
      :is_built_in_fiducials_present,
      :snl_assembler,
      :assembly_date,
      :preparation_notes,
    ]

    self.required_fields = [
      :description
    ]

    self.single_valued_fields = [
      :institution_code,
      :catalog_number,
      :description,
      :is_pak,
      :is_built_in_fiducials_present,
      :snl_assembler,
      :assembly_date,
      :preparation_notes,
    ]

    def self.build_permitted_params
      super + [
                :institution_code,
                :catalog_number,
                :description,
                :is_pak,
                :is_built_in_fiducials_present,
                :snl_assembler,
                :assembly_date,
                :preparation_notes,
              ]
    end
  end
end
