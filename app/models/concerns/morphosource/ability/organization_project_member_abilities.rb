module Morphosource
  module Ability
    module OrganizationProjectMemberAbilities

      # View Media and FileSets through organization membership
      def organization_project_member_abilities

        can :read, ::Media do |obj|
          has_organization_project_access_to_media? obj
        end

        can :edit, ::Media do |obj|
          has_organization_project_edit_access_to_media? obj
        end

        can :read, ::FileSet do |obj|
          has_organization_project_access_to_fileset? obj
        end

        can :edit, ::FileSet do |obj|
          has_organization_project_edit_access_to_fileset? obj
        end

        can :read, ::SolrDocument do |obj|
          case obj.has_model&.first
          when 'Media'
            has_organization_project_access_to_media? obj
          when 'FileSet'
            has_organization_project_access_to_fileset? obj
          else
            false
          end
        end

        can :edit, ::SolrDocument do |obj|
          case obj.has_model&.first
          when 'Media'
            has_organization_project_edit_access_to_media? obj
          when 'FileSet'
            has_organization_project_edit_access_to_fileset? obj
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
      end

      private

        # Users who are members of the organizations whose IDs are stored in these media fields can view the media
        def organization_fields
          ["media_organization_id_ssim","media_device_facility_organization_id_ssim"]
        end

        def has_organization_project_access_to_media?(media)
          Rails.logger.debug("[CANCAN] Checking for individual media access through organization membership")
          return false unless media = solr_document(media)
          byebug
          (organization_project_groups(media) & @user_groups).present?
        end

        def has_organization_project_edit_access_to_media?(media)
          Rails.logger.debug("[CANCAN] Checking for individual media edit access through organization membership")
          return false unless media = solr_document(media)
          (organization_project_edit_groups(media) & @user_groups).present?
        end

        def has_organization_project_access_to_fileset?(file_set)
          Rails.logger.debug("[CANCAN] Checking for individual file set access through organization membership")
          return false unless file_set = solr_document(file_set)

          return false unless media_id = Morphosource::SolrService.new.get_docs("file_set_ids_ssim:#{file_set.id}").first&.dig("id")

          has_organization_project_access_to_media?(media_id)
        end

        def has_organization_project_edit_access_to_fileset?(file_set)
          Rails.logger.debug("[CANCAN] Checking for individual file set edit access through organization membership")
          return false unless file_set = solr_document(file_set)

          return false unless media_id = Morphosource::SolrService.new.get_docs("file_set_ids_ssim:#{file_set.id}").first&.dig("id")

          has_organization_project_edit_access_to_media?(media_id)
        end

        def organization_project_groups(media)
          return [] unless document = solr_document(media)

          groups = organization_fields.each_with_object([]) do |field, roles|
            next unless org_id = document[field]&.first

            if OrganizationCollection.exists?(org_id)
              projects = OrganizationCollection.find(org_id).child_projects
              roles << projects.map(&:user_groups_names)
            end
          end.flatten
        end

        def organization_project_edit_groups(media)
          return [] unless document = solr_document(media)

          organization_project_groups(media).select {|group| (group.include? "managers")}
        end


        def solr_document(obj)
          case obj
          when FileSet
            return SolrDocument.find(obj.id)
          when Media
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