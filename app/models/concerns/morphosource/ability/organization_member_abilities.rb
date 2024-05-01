module Morphosource
  module Ability
    module OrganizationMemberAbilities
      include PhysicalObjects

      # View Media and FileSets through organization membership
      def organization_member_abilities

        can :read, ::Media do |obj|
          has_organizational_access_to_media? obj
        end

        can :edit, ::Media do |obj|
          has_organizational_edit_access_to_media? obj
        end

        can :read, ::FileSet do |obj|
          has_organizational_access_to_fileset? obj
        end

        can :edit, ::FileSet do |obj|
          has_organizational_edit_access_to_fileset? obj
        end

        can :read, [::BiologicalSpecimen, ::CulturalHeritageObject] do |obj|
          has_organizational_access_to_physical_object? obj
        end

        can :edit, [::BiologicalSpecimen, ::CulturalHeritageObject] do |obj|
          has_organizational_edit_access_to_physical_object? obj
        end

        can :read, ::SolrDocument do |obj|
          case obj.has_model&.first
          when 'Media'
            has_organizational_access_to_media? obj
          when 'FileSet'
            has_organizational_access_to_fileset? obj
          when 'BiologicalSpecimen', 'CulturalHeritageObject'
            has_organizational_access_to_physical_object? obj
          else
            false
          end
        end

        can :edit, ::SolrDocument do |obj|
          case obj.has_model&.first
          when 'Media'
            has_organizational_edit_access_to_media? obj
          when 'FileSet'
            has_organizational_edit_access_to_fileset? obj
          when 'BiologicalSpecimen', 'CulturalHeritageObject'
            has_organizational_edit_access_to_physical_object? obj
          else
            false
          end
        end

        can :read, String do |id|
          obj = SolrDocument.find(id)
          can? :read, obj
        rescue
          false
        end

        can :edit, String do |id|
          obj = SolrDocument.find(id)
          can? :edit, obj
        rescue
          false
        end

        # Proxy Deposits

        can :transfer, String do |id|
          admin? || user_manages_media_through_organization?(id)
        end

        can :accept, ProxyDepositRequest do |request|
          unless request.status == "pending"
            false
          else
            user_is_manager_of_organization?(request.receiving_user_id)
          end
        end

        can :reject, ProxyDepositRequest do |request|
          unless request.status == "pending"
            false
          else
            user_is_manager_of_organization?(request.receiving_user_id)
          end
        end
      end

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
        return unless media = solr_document(media_id)

        if (media["owner_type_ssi"] == "OrganizationCollection") && (owner_org_id = media["owner_ssim"]&.first).present?
          user_is_manager_of_organization?(owner_org_id)
        else
          false
        end
      end

      def user_is_manager_of_organization?(organization_id)
        return false if organization_id.nil?

        current_user.groups.include? "#{organization_id}_managers"
      end

      def solr_document(obj)
        case obj
        when FileSet, Media, BiologicalSpecimen, CulturalHeritageObject
          return SolrDocument.find(obj.id)
        when SolrDocument
          return obj
        when String
          return SolrDocument.find(obj)
        when Hash
          return SolrDocument.find(obj['id'])
        end
      rescue
        nil
      end
    end
  end
end