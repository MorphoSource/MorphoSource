module Morphosource
  module Ability
    module OrganizationMemberAbilities
      module PhysicalObjectAbilities
        # returns true if the user has read or edit access to the physical object through the organization collection
        def has_organizational_access_to_physical_object?(physical_object)
          Rails.logger.debug("[CANCAN] Checking for individual physical_object access through organization membership")
          return false unless physical_object = solr_document(physical_object)

          (po_organization_read_groups(physical_object) & @user_groups).present?
        end

        # returns true if the user has edit access to the physical object through the organization collection
        def has_organizational_edit_access_to_physical_object?(physical_object)
          Rails.logger.debug("[CANCAN] Checking for individual physical object edit access through organization membership")
          return false unless physical_object = solr_document(physical_object)

          (po_organization_edit_groups(physical_object) & @user_groups).present?
        end

        # Return an array of organization role names for organization that can read organization physical objects
        # ex: ['000012345_managers', '000012345_editors', '000012345_downloaders', '000012345_viewers']
        def po_organization_read_groups(physical_object)
          @po_organization_read_groups ||= begin
            if (
              (physical_object = solr_document(physical_object)) &&
              (organization_id = physical_object.organization_id&.first).present?
            )
              OrganizationCollection::READ_GROUP_ROLES.map { |role| "#{organization_id}_#{role}" }
            else
              []
            end
          end
        end

        # Return an array of organization role names for organization that can edit organization physical objects
        # ex: ['000012345_managers', '000012345_editors']
        def po_organization_edit_groups(physical_object)
          @po_organization_edit_groups ||= begin
            if (
              (physical_object = solr_document(physical_object)) &&
              (organization_id = physical_object.organization_id&.first).present?
            )
              OrganizationCollection::EDIT_GROUP_ROLES.map {|role| "#{organization_id}_#{role}" }
            else
              []
            end
          end
        end
      end
    end
  end
end