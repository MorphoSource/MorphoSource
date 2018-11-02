# Generated via
#  `rails generate hyrax:work Attachment`
module Hyrax
  # Generated form for Attachment
  class AttachmentForm < Hyrax::Forms::WorkForm
    self.model_class = ::Attachment
    include Morphosource::FormMethods
    include ChildCreateButton
    include SingleValuedForm

    self.terms = [:title]

    self.required_fields = [:title]

    self.single_valued_fields = [:title]
  end
end
