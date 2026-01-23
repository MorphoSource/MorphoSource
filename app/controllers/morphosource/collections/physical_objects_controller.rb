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

      def media_count_search_builder_class
        Morphosource::Collections::MediaSearchBuilder
      end

      def get_object_ids
        @object_ids = collection_object_ids
        @media_count = collection_media_count
      end

    end
  end
end
