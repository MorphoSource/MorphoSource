module Morphosource
  module Forms
    module Collections
      # rubocop:disable Metrics/ClassLength
      class OrganizationCollectionForm < ::Hyrax::Forms::CollectionForm

        self.model_class = ::OrganizationCollection

        delegate :blacklight_config, to: Morphosource::Collections::OrganizationCollectionsController

        self.terms += [:address, :agreement_uri, :allowed_remote_source, :alternative_title, :based_near, :can_submit_remote_files, :city, :collection_code, :collection_type, :collection_type_gid, :contact_person, :contributor, :country, :creator, :data_manager, :date_created, :description, :download_permission, :download_reviewer, :identifier, :identifier, :institution_code, :institution_name, :keyword, :language, :license, :license_blank, :media_ownership_transfer, :morphosource_use_agreement_type, :organization_type, :permissions_enforcement_mode, :permits_3d_use, :permits_commercial_use, :postal_code, :preview_mode, :publisher, :recordset_id, :related_url, :representative_id, :required_archival_of_published_derivatives, :resource_type, :rights_holder, :rights_holder_blank, :rights_statement, :rights_statement_blank, :state_province, :subject, :thumbnail_id, :title, :visibility]

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