module Morphosource
  module Dashboard
    class CollectionMembersController < Hyrax::Dashboard::CollectionMembersController
      include Morphosource::CollectionHelper

      before_action :filter_docs_with_read_access!, except: [:update_members]

      before_action :filter_docs_with_access_by_collection_type, only: [:update_members]

      def update_members
        byebug
        @batch_ids = batch_ids
        if (err_msg = validate).present?
          after_update_error(err_msg)
          return
        end
        if @collection.sequential_section_list? && (err_msg = validate_for_sequential_section_list).present?
          after_update_error(err_msg)
          return
        end
        byebug
        AddCollectionMembersJob.perform_later(@collection.id, @batch_ids)
        byebug
        after_update
      end

      def success_return_path
        collection_media_path(@collection)
      end

      private

        def validate_for_sequential_section_list
          if @collection.specimen_id.present?
            # the sequential section list is not empty and has a specimen id
            # remove any media that does not have the same specimen id
            remove_ids = []
            @batch_ids.each do |id|
              media = Media.find(id)
              media_object_id = media.physical_object_id&.first
              if @collection.specimen_id != media_object_id
                remove_ids << id
              end
            end
            @batch_ids -= remove_ids
            if @batch_ids.empty?
              return "None of the selected media has the same physical object of #{@collection.title.first} collection."
            end
          else
            # the sequential section list is empty
            # return error if not all media have the same specimen id
            physical_object_ids = @batch_ids.map { |id| Media.find(id).physical_object_id&.first }.uniq
            if physical_object_ids.size != 1
              return "Please select media from the same physical object to be added to the #{@collection.title.first} collection.  Currently the selected media are associated with these objects: #{physical_object_ids.join(', ')}. "
            end
          end
          return nil
        end

        def err_return_path
          if @collection.media_list?
            media_list_path(@collection.id)
          elsif @collection.sequential_section_list?
            sequential_section_list_path(@collection.id)
          else
            dashboard_collections_path
          end
        end

        def filter_docs_with_access_by_collection_type
          if @collection.list?
            filter_docs_with_read_access!
          else
            filter_docs_with_edit_access!
          end
        end

    end
  end
end
