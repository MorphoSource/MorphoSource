module Morphosource
  module Ability
    module OrganizationMemberAbilities
      include EventAbilities
      include MediaAbilities
      include PhysicalObjectAbilities


      # View Media and FileSets through organization membership
      def organization_member_abilities
        # Read rules

        return unless registered_user?

        can :read, ::Media do |obj|
          has_organizational_access_to_media? obj
        end

        can :read, ::FileSet do |obj|
          has_organizational_access_to_fileset? obj
        end

        can :read, [::BiologicalSpecimen, ::CulturalHeritageObject] do |obj|
          has_organizational_access_to_physical_object? obj
        end

        can :read, [::ImagingEvent, ::ProcessingEvent] do |obj|
          has_organizational_access_to_event? obj
        end

        can :read, ::SolrDocument do |obj|
          case obj.has_model&.first
          when 'Media'
            has_organizational_access_to_media? obj
          when 'FileSet'
            has_organizational_access_to_fileset? obj
          when 'BiologicalSpecimen', 'CulturalHeritageObject'
            has_organizational_access_to_physical_object? obj
          when 'ImagingEvent', 'ProcessingEvent'
            has_organizational_access_to_event? obj
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

        # Download rules

        return unless registered_user? || admin?

        can :download, ::Media do |obj|
          has_organizational_download_access_to_media?(obj)
        end

        can :download, ::SolrDocument do |obj|
          case obj.has_model&.first
          when 'Media'
            has_organizational_download_access_to_media? obj
          else
            false
          end
        end

        can :download, String do |id|
          obj = SolrDocument.find(id)
          can? :download, obj
        rescue
          false
        end

        # Edit rules

        return unless contributor? || admin?

        can [:edit, :update], ::Media do |obj|
          has_organizational_edit_access_to_media? obj
        end

        can [:edit, :update], ::FileSet do |obj|
          has_organizational_edit_access_to_fileset? obj
        end

        can [:edit, :update], [::BiologicalSpecimen, ::CulturalHeritageObject] do |obj|
          has_organizational_edit_access_to_physical_object? obj
        end

        can [:edit, :update], [::ImagingEvent, ::ProcessingEvent] do |obj|
          has_organizational_edit_access_to_event? obj
        end

        can [:edit, :update], ::SolrDocument do |obj|
          case obj.has_model&.first
          when 'Media'
            has_organizational_edit_access_to_media? obj
          when 'FileSet'
            has_organizational_edit_access_to_fileset? obj
          when 'BiologicalSpecimen', 'CulturalHeritageObject'
            has_organizational_edit_access_to_physical_object? obj
          when 'ImagingEvent', 'ProcessingEvent'
            has_organizational_edit_access_to_event? obj
          else
            false
          end
        end

        can [:edit, :update], String do |id|
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

      def user_is_manager_of_organization?(organization_id)
        return false if organization_id.nil?

        current_user.groups.include? "#{organization_id}_managers"
      end

      def solr_document(obj)
        case obj
        when Morphosource::Works::Base
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