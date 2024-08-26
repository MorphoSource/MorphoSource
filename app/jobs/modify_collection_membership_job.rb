# Add and/or remove media from collections reducing number of save operations
# Combines functionality of collection.add_member_objects and collection.remove_member_objects
class ModifyCollectionMembershipJob < Hyrax:: ApplicationJob
    queue_as Hyrax.config.update_medium_queue_name

    def perform(media_id: nil, add_to_collection_ids: [], remove_from_collection_ids: [])
      media = Media.find(media_id)
      add_to_collection_ids = Array(add_to_collection_ids) - Array(remove_from_collection_ids)
      remove_from_collection_ids = Array(remove_from_collection_ids) - Array(add_to_collection_ids)
      
      if media.present? && ( add_to_collection_ids.present? || remove_from_collection_ids.present? )
        # Only add or remove collections when appropriate
        media_in_collection_ids = media.member_of_collection_ids.to_a
        add_to_collection_ids = add_to_collection_ids - media_in_collection_ids # don't add if already in collection
        remove_from_collection_ids = remove_from_collection_ids & media_in_collection_ids # only remove if already in collection

        # Get collections to add/remove and prepare for reindexing
        add_to_collections = Array(add_to_collection_ids).uniq.map { |id| find_collection(id) }.compact
        remove_from_collections = remove_from_collection_ids.uniq.map { |id| find_collection(id) }.compact
        
        (add_to_collections + remove_from_collections).each do |collection| 
          collection.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
        end

        # Check for multiple memberhsip (should never happen)
        add_to_collections.each do |collection|
          message = Hyrax::MultipleMembershipChecker.new(item: media).check(collection_ids: collection.id, include_current_members: true)
          if message
            member.errors.add(:collections, message)
            raise message
          end
        end

        # Create new array of collections to which media should belong
        media_collections = media.member_of_collections.to_a
        media_collections = media_collections.reject { |collection| remove_from_collection_ids.include?(collection.id) }
        media_collections = ( media_collections + add_to_collections ).uniq { |collection| collection.id }

        # Change collection membership
        media.member_of_collections = media_collections

        # Apply permission templates
        add_to_collections.each do |collection|
          if collection.media_inherit_permissions?
            Hyrax::PermissionTemplateApplicator.apply(collection.permission_template).to(model: media)
          end
        end
        remove_from_collections.each do |collection|
          if collection.media_inherit_permissions?
            collection.remove_team_access_grants(media)
          end
        end

        # Save media and reindex associated object
        media.save!
        object_id = media.physical_object_id&.first
        UpdateWorkIndexJob.perform_later(object_id) if object_id.present?

        # Apply permissions to file_set if any collection modified has media inherit permissions
        if ( add_to_collections + remove_from_collections ).any? { |collection| collection.media_inherit_permissions? }
          InheritPermissionsJob.perform_later(media.id)
        end
      end
    end

    def find_collection(collection_id)
      if SequentialSectionList.exists?(collection_id)
        return SequentialSectionList.find(collection_id)
      elsif MediaList.exists?(collection_id)
        return MediaList.find(collection_id)
      elsif Collection.exists?(collection_id)
        return Collection.find(collection_id)
      else
        return nil
      end
    end
end