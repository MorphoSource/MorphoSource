# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  # Generated form for Device
  class DeviceForm < Hyrax::Forms::WorkForm
    self.model_class = ::Device

    include SingleValuedForm

    # Customizing field terms

    self.terms = [:title, :creator, :modality, :facility, :description]

    self.required_fields = [:title, :creator, :modality]

    self.single_valued_fields = [:title, :description] 
  end
end
