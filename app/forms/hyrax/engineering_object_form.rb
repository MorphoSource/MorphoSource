# Generated via
#  `rails generate hyrax:work EngineeringObject`
module Hyrax
  # Generated form for EngineeringObject
  class EngineeringObjectForm < Hyrax::Forms::WorkForm
    include Morphosource::FormMethods
    self.model_class = ::EngineeringObject

    self.terms += [
      :resource_type,
      :description,
    ]

    self.required_fields = [
      :description
    ]

  end
end
