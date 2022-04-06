module Morphosource
  module Dashboard
    module MediaLists
      class PhysicalObjectsController < Morphosource::Dashboard::MediaListsController
        include Morphosource::CollectionsControllerBehavior

        before_action :load_collection, only: [:show]
        before_action :get_object_ids, only: [:facet]

        def search_builder
          search_builder_class.new(self)
        end

        # def presenter_class
        #   @collection ||= ::Collection.find(params[:id])
        #   if @collection.media_list?
        #     Morphosource::Collections::ProjectPresenter
        #   elsif @collection.team?
        #     Morphosource::Collections::TeamPresenter
        #   end
        # end

        def get_object_ids
          (@media_count, @object_ids) = collection_media
        end

        def load_collection
          @collection ||= ::Collection.find(params[:id])
        end
      end
    end
  end
end
