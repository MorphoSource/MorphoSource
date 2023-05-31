module Morphosource
  module Dashboard
    class CollectionMembersController < Hyrax::Dashboard::CollectionMembersController
      include Morphosource::CollectionHelper

      before_action :filter_docs_with_read_access!, except: [:update_members]

      before_action :filter_docs_with_access_by_collection_type, only: [:update_members]

      def update_members
        err_msg = validate
        after_update_error(err_msg) if err_msg.present?
        return if err_msg.present?

        collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
        members = collection.add_member_objects batch_ids
        update_physical_object_index
        messages = members.collect { |member| member.errors.full_messages }.flatten
        if messages.size == members.size
          after_update_error(messages.uniq.join(', '))
        elsif messages.present?
          flash[:error] = messages.uniq.join(', ')
          after_update
        else
          after_update
        end
      end

      def update_physical_object_index
        return if params["batch_document_ids"].blank?

        member_ids = params["batch_document_ids"]
        member_ids.each do |id|
          member = Media.find(id)
          object_id = member.physical_object_id
          next if object_id.blank?

          ActiveFedora::Base.where(id: object_id).first.try(:update_index)
        end
      end

      def success_return_path
        collection_media_path(@collection)
      end

      private

        def filter_docs_with_access_by_collection_type
          if collection.list?
            filter_docs_with_read_access!
          else
            filter_docs_with_edit_access!
          end
        end

    end
  end
end
