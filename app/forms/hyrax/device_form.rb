# Generated via
#  `rails generate hyrax:work Device`
# @deprecated Use DeviceResourceForm instead.
module Hyrax
  # Generated form for Device
  class DeviceForm < Hyrax::Forms::WorkForm
    self.model_class = ::Device
    include Morphosource::FormMethods
    include SingleValuedForm

    # Customizing field terms
    # Remove default Hyrax metadata
    self.terms -= [:representative_id, :thumbnail_id, :rendering_ids, :files, :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo, :visibility_during_lease, :lease_expiration_date, :visibility_after_lease, :ordered_member_ids, :member_of_collection_ids, :admin_set_id]

    self.terms += [:modality, :organization_id]

    self.required_fields = [:title, :creator, :modality]

    self.single_valued_fields = [:title, :creator, :description]

    def primary_terms
      [:title, :creator, :modality, :identifier, :description]
    end

    def secondary_terms
      []
    end

    def find_parent_work
      "Add to Organization"
    end
  end
end