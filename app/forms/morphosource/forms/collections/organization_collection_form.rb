module Morphosource
  module Forms
    module Collections
      # rubocop:disable Metrics/ClassLength
      class OrganizationCollectionForm < ::Hyrax::Forms::CollectionForm

        self.model_class = ::OrganizationCollection

        delegate :blacklight_config, to: Morphosource::Collections::OrganizationCollectionsController

        self.terms += [:address,
                       :agreement_uri,
                       :allowed_remote_source,
                       :alternative_title,
                       :can_submit_remote_files,
                       :city,
                       :collection_code,
                       :collection_type,
                       :contact_person,
                       :country,
                       :data_manager,
                       :date_created,
                       :download_permission,
                       :download_reviewer,
                       :identifier,
                       :institution_code,
                       :institution_name,
                       :language,
                       :license,
                       :license_blank,
                       :media_ownership_transfer,
                       :morphosource_use_agreement_type,
                       :organization_type,
                       :permissions_enforcement_mode,
                       :permits_3d_use,
                       :permits_commercial_use,
                       :postal_code,
                       :preview_mode,
                       :publisher,
                       :recordset_id,
                       :required_archival_of_published_derivatives,
                       :resource_type,
                       :rights_holder,
                       :rights_holder_blank,
                       :rights_statement,
                       :rights_statement_blank,
                       :state_province,
                       :subject]

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

        self.required_fields += [:country,
                                 :organization_type]

      end
    end
  end
end