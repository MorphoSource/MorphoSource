# Generated via
#  `rails generate hyrax:work Organization`
module Hyrax
  # Generated form for Organization
  class OrganizationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Organization
    include Morphosource::FormMethods
    include ChildCreateButton
    include SingleValuedForm

    class_attribute :single_value_fields

    # Customizing field terms

    self.terms = [:title, :institution_code, :description, :address, :city, :state_province, :country, :institution_name, :collection_code]

    self.required_fields = [:title, :institution_code]

    self.single_valued_fields = [:title, :institution_code, :description, :address, :city, :state_province, :country, :institution_name]
  end
end
