module Morphosource
  module Collections
    class PhysicalObjectsController < Morphosource::CollectionsController
      include Morphosource::Collections::LinkedTeamsControllerBehavior

      before_action :load_organization, only: [:show]
      before_action :get_object_ids, only: [:facet, :objects_export]

      self.can_authorize_with_temporary_link = true

      def search_builder
        search_builder_class.new(self)
      end

      def presenter_class
        @collection ||= ::Collection.find(params[:id])
        if @collection.project?
          Morphosource::Collections::ProjectPresenter
        elsif @collection.team?
          Morphosource::Collections::TeamPresenter
        end
      end

      def get_object_ids
        (@media_count, @object_ids) = collection_media
      end
    end
  end
end
