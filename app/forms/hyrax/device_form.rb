# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  # Generated form for Device
  class DeviceForm < Hyrax::Forms::WorkForm
    self.model_class = ::Device
    include Morphosource::FormMethods
    include ChildCreateButton
    include SingleValuedForm

    # Customizing field terms

    # Remove all default Hyrax metadata
    self.terms -= [:title, :creator, :contributor, :description, :keyword, 
      :license, :rights_statement, :publisher, :date_created, :subject, 
      :language, :identifier, :based_near, :related_url, :source, 
    ]
    self.terms += [:title, :creator, :modality, :description]

    self.required_fields = [:title, :creator, :modality]

    self.single_valued_fields = [:title, :description]
  end
end
