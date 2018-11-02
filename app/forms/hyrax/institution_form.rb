# Generated via
#  `rails generate hyrax:work Institution`
module Hyrax
  # Generated form for Institution
  class InstitutionForm < Hyrax::Forms::WorkForm
    self.model_class = ::Institution
    include Morphosource::FormMethods
    include ChildCreateButton
    include SingleValuedForm

    class_attribute :single_value_fields

    # Customizing field terms

    self.terms = [:title, :institution_code, :description, :address, :city, :state_province, :country]

    self.required_fields = [:title, :institution_code]

    self.single_valued_fields = [:title, :institution_code, :description, :address, :city, :state_province, :country]
  end
end
