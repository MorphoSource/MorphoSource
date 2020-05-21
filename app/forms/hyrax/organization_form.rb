# Generated via
#  `rails generate hyrax:work Organization`
module Hyrax
  # Generated form for Organization
  class OrganizationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Organization
    include Morphosource::FormMethods
    include ChildCreateButton
    include SingleValuedForm

    class_attribute :single_valued_fields
    class_attribute :media_permissions_fields

    # Customizing field terms
    self.terms = [
      :institution_code, :address, :city, :state_province, :country, :institution_name, :collection_code, :download_permission, :download_reviewer, :agreement_uri, :terms_of_use,  :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, :cite_as]

    self.required_fields = [:title, :institution_code]

    self.single_valued_fields = [:title, :institution_code, :description, :address, :city, :state_province, :country, :institution_name, :terms_of_use, :cite_as]

    self.media_permissions_fields = [:download_permission, :download_reviewer, :agreement_uri, :license, :rights_statement, :terms_of_use, :permits_commercial_use, :permits_3d_use, :rights_holder, :funding, :publisher, :cite_as]

    def secondary_terms
      terms - primary_terms - media_permissions_fields -
        [:files, :visibility_during_embargo, :embargo_release_date,
         :visibility_after_embargo, :visibility_during_lease,
         :lease_expiration_date, :visibility_after_lease, :visibility,
         :thumbnail_id, :representative_id, :rendering_ids, :ordered_member_ids,
         :member_of_collection_ids, :in_works_ids, :admin_set_id]
    end
  end
end
