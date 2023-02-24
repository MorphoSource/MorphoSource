module Morphosource
  module Ability
    module TemporaryLinkAbilities
      def temporary_link_abilities

        # Destroy temporary links

        can :destroy, TemporaryMediaAccessLink do |link|
          ( current_user.id == link.user_id ) || current_user.admin? || user_is_data_manager?(link.media_id) 
        end
  
        can :destroy, TemporaryCollectionAccessLink do |link|
          ( current_user.id == link.user_id ) || current_user.admin? || (
            Collection.exists?(id) &&
            Collection.find(id).managers.include?(current_user)
          )
        end
  
        # View Media, FileSets, and Projects via temporary access link

        can :read, [Media] do |obj|
          can_read_media_with_temporary_link? obj
        end

        can :read, [FileSet] do |obj|
          can_read_fileset_with_temporary_link? obj
        end

        can :read, [Collection] do |obj|
          can_read_collection_with_temporary_link? obj
        end

        can :read, [::SolrDocument] do |obj|
          case obj.has_model&.first
          when 'Media'
            can_read_media_with_temporary_link? obj
          when 'FileSet'
            can_read_fileset_with_temporary_link? obj
          when 'Collection'
            can_read_collection_with_temporary_link? obj
          else
            false
          end
        end

        can :read, String do |id|
          if temporary_media_access_link.present? || temporary_collection_access_link.present?
            obj = ActiveFedora::Base.find(id)
            can? :read, obj
          end
        end
      end

      private

        def can_read_media_with_temporary_link?(media)
          if temporary_media_access_link.present?
            Rails.logger.debug("[CANCAN] Checking for individual media temporary access grant")
            temporary_media_access_link.active? && temporary_media_access_link.media_id == obj.id
          elsif temporary_collection_access_link.present?
            Rails.logger.debug("[CANCAN] Checking for collection-level media temporary access grant")
            temporary_collection_access_link.present? && 
              media.member_of_collection_ids.include?(temporary_collection_access_link.collection_id)
          end
        end

        def can_read_fileset_with_temporary_link?(fileset)
          media = fileset.is_a?(ActiveFedora::Base) ? fileset.member_of&.first : FileSet.find(fileset.id).member_of&.first
          can_read_media_with_temporary_link?(media) if media.present?
        end

        def can_read_collection_with_temporary_link?(collection)
          return unless temporary_collection_access_link.present?
          Rails.logger.debug("[CANCAN] Checking for collection temporary access grant")
  
          collection.project? && 
            temporary_collection_access_link.active? && 
            temporary_collection_access_link.collection_id == collection.id
        end


    end
  end
end