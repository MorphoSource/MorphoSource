module Morphosource
  module Collections
    module OrganizationCollectionsControllerBehavior

      def media_objects_search_builder_class
        Morphosource::Collections::OrganizationCollections::MediaObjectsSearchBuilder
      end

      # supplies @media_count
      def media_count_search_builder_class
        Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder
      end

      # count of devices owned by organization
      def organization_device_count
        Morphosource::SolrService.new.get_docs("has_model_ssim:Device AND device_organization_id_ssim:#{@collection.id}").count
      end

      # count of media imaged by organization devices and viewable by current user
      def device_media_count
        search_builder = Morphosource::Collections::OrganizationCollections::DeviceMediaSearchBuilder.new(scope: self, collection: @collection)
        repository.search(search_builder.query).response["numFound"].to_i
      end

      def query_collection_counts
        @media_count ||= collection_media_count
        @device_media_count ||= device_media_count
        @specimen_count ||= collection_specimen_count
        @cho_count ||= collection_cho_count
        @device_count ||= organization_device_count
      end

    end
  end
end
