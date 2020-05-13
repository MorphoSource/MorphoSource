module Morphosource
  module Collections
    class PermissionsCreateService < Hyrax::Collections::PermissionsCreateService
      # Assign new groups to manager/editor/depositor/downloader/viewer access if collection is a Team or Project
      def self.create_default(collection:)
        access_grants = access_grants_attributes(collection: collection)
        Hyrax::PermissionTemplate.create!(source_id: collection.id, access_grants_attributes: access_grants.uniq)
        collection.reset_access_controls!
      end

      # Add auto-generated groups.
      # Don't give creating_user individual manager status since they are already added to the manager group.
      def self.access_grants_attributes(collection:)
        [
          { agent_type: 'group', agent_id: admin_group_name, access: Hyrax::PermissionTemplateAccess::MANAGE },
          { agent_type: 'group', agent_id: collection.managers_group.name, access: Hyrax::PermissionTemplateAccess::MANAGE },
          { agent_type: 'group', agent_id: collection.editors_group.name, access: Hyrax::PermissionTemplateAccess::EDIT_WORKS },
          { agent_type: 'group', agent_id: collection.depositors_group.name, access: Hyrax::PermissionTemplateAccess::DEPOSIT },
          { agent_type: 'group', agent_id: collection.downloaders_group.name, access: Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS },
          { agent_type: 'group', agent_id: collection.viewers_group.name, access: Hyrax::PermissionTemplateAccess::VIEW }
        ] + managers_of_collection_type(collection_type: collection.collection_type)
      end
    end
  end
end
