module Morphosource
  module Forms
    module Collections
      # rubocop:disable Metrics/ClassLength
      class OrganizationCollectionForm < ::Hyrax::Forms::CollectionForm

        self.model_class = ::OrganizationCollection

        self.single_valued_fields = [:title, :description]

        delegate :blacklight_config, to: Morphosource::Collections::OrganizationCollectionsController

        self.terms += [:address,
                       :agreement_uri,
                       :city,
                       :collection_code,
                       :collection_type,
                       :contact_person,
                       :country,
                       :data_manager,
                       :download_permission,
                       :download_reviewer,
                       :institution_code,
                       :institution_name,
                       :license_blank,
                       :morphosource_use_agreement_type,
                       :organization_type,
                       :permissions_enforcement_mode,
                       :permits_3d_use,
                       :permits_commercial_use,
                       :postal_code,
                       :preview_mode,
                       :recordset_id,
                       :required_archival_of_published_derivatives,
                       :rights_holder,
                       :rights_holder_blank,
                       :rights_statement,
                       :rights_statement_blank,
                       :state_province]

        self.single_valued_fields += [:address,
                                      :agreement_uri,
                                      :city,
                                      :copyright_blank,
                                      :country,
                                      :data_manager,
                                      :download_permission,
                                      :institution_name,
                                      :license,
                                      :license_blank,
                                      :morphosource_use_agreement_type,
                                      :organization_type,
                                      :permissions_enforcement_mode,
                                      :permits_3d_use,
                                      :permits_commercial_use,
                                      :postal_code,
                                      :preview_mode,
                                      :required_archival_of_published_derivatives,
                                      :rights_holder_blank,
                                      :rights_statement,
                                      :rights_statement_blank,
                                      :state_province]

      end
    end
  end
end