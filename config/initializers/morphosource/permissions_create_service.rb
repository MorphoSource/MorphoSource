Hyrax::Collections::PermissionsCreateService.module_eval do

  # Assign new groups to manager/depositor/viewer access if collection is a Team or Project
  def self.create_default(collection:, creating_user:, grants: [])
    if collection.type_assigns_groups?
      access_grants = ms_access_grants_attributes(collection: collection, creating_user: creating_user, grants: grants)
    else
      access_grants = access_grants_attributes(collection_type: collection.collection_type, creating_user: creating_user, grants: grants)
    end
    Hyrax::PermissionTemplate.create!(source_id: collection.id, access_grants_attributes: access_grants.uniq)
    collection.reset_access_controls!
  end

  # Add auto-generated groups.
  # Don't give creating_user individual manager status since they are already added to the manager group.
  def self.ms_access_grants_attributes(collection:, creating_user:, grants:)
    [
      { agent_type: 'group', agent_id: admin_group_name, access: Hyrax::PermissionTemplateAccess::MANAGE },
      { agent_type: 'group', agent_id: collection.managers_group.name, access: Hyrax::PermissionTemplateAccess::MANAGE },
      { agent_type: 'group', agent_id: collection.depositors_group.name, access: Hyrax::PermissionTemplateAccess::DEPOSIT },
      { agent_type: 'group', agent_id: collection.viewers_group.name, access: Hyrax::PermissionTemplateAccess::VIEW }
    ] + managers_of_collection_type(collection_type: collection.collection_type) + grants
  end
end
