module Morphosource
  module Ability
    module OrganizationMemberAbilities
      module MediaAbilities

        private

        # returns true if the user has read or edit access to the media through the organization collection
        def has_organizational_access_to_media?(media)
          Rails.logger.debug("[CANCAN] Checking for individual media access through organization membership")
          return false unless media = solr_document(media)

          (organization_groups(media) & @user_groups).present?
        end

        # returns true if the user has edit access to the media through the organization collection
        def has_organizational_edit_access_to_media?(media)
          Rails.logger.debug("[CANCAN] Checking for individual media edit access through organization membership")
          return false unless media = solr_document(media)

          (organization_edit_groups(media) & @user_groups).present?
        end

        def has_organizational_access_to_fileset?(file_set)
          Rails.logger.debug("[CANCAN] Checking for individual file set access through organization membership")
          return false unless file_set = solr_document(file_set)

          return false unless media_id = file_set_media_id(file_set)

          has_organizational_access_to_media?(media_id)
        end

        def has_organizational_edit_access_to_fileset?(file_set)
          Rails.logger.debug("[CANCAN] Checking for individual file set edit access through organization membership")
          return false unless file_set = solr_document(file_set)

          return false unless media_id = file_set_media_id(file_set)

          has_organizational_edit_access_to_media?(media_id)
        end

        def file_set_media_id(file_set)
          ( SolrDocument.where("file_set_ids_ssim:#{file_set.id}")&.first || {} )['id']
        end

        # return an array of organization role names corresponding to organization_fields
        # ex: ['000012345_managers', '000012345_editors', '000012345_depositors', '000012345_downloaders', '000012345_viewers']
        def organization_groups(media)
          return [] unless media = solr_document(media)

          object_org_id = media["media_organization_id_ssim"]&.first
          device_org_id = media["media_device_facility_organization_id_ssim"]&.first
          owner_org_id = (media["owner_type_ssi"] == "OrganizationCollection") ? media["owner_ssim"]&.first : nil

          [object_org_id, device_org_id, owner_org_id].compact.uniq.each_with_object([]) do |id, groups|
            OrganizationCollection::READ_GROUP_ROLES.each {|role| groups << "#{id}_#{role}"}
          end.flatten
        end

        def organization_edit_groups(media)
          return [] unless media = solr_document(media)

          if (media["owner_type_ssi"] == "OrganizationCollection") && media["owner_ssim"]&.first.present?
            owner_org_id = media["owner_ssim"]&.first
            return OrganizationCollection::EDIT_GROUP_ROLES.map {|role| "#{owner_org_id}_#{role}" }
          else
            return []
          end
        end

        def user_manages_media_through_organization?(media_id)
          return false unless media = solr_document(media_id)

          if (media["owner_type_ssi"] == "OrganizationCollection") && (owner_org_id = media["owner_ssim"]&.first).present?
            user_is_manager_of_organization?(owner_org_id)
          else
            false
          end
        end

      end
    end
  end
end