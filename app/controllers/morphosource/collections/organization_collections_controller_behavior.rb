module Morphosource
  module Collections
    module OrganizationCollectionsControllerBehavior

      def about
        @stats = Morphosource::Analytics::Collections::CollectionStats.new(@collection)
        super
      end

      def media_objects_search_builder_class
        Morphosource::Collections::OrganizationCollections::MediaObjectsSearchBuilder
      end

      # supplies @media_count
      def media_count_search_builder_class
        Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder
      end

      # count of devices owned by organization
      def organization_device_count
        Morphosource::SolrService.new.get_count("has_model_ssim:(Device OR DeviceResource) AND device_organization_id_ssim:#{@collection.id}")
      end

      # count of media imaged by organization devices and viewable by current user
      def device_media_count
        search_builder = Morphosource::Collections::OrganizationCollections::DeviceMediaSearchBuilder.new(scope: self, collection: @collection)
        blacklight_config.repository.search(search_builder.query).response["numFound"].to_i
      end

      def query_collection_counts
        @media_count ||= collection_media_count
        @device_media_count ||= device_media_count
        @specimen_count ||= collection_specimen_count
        @cho_count ||= collection_cho_count
        @device_count ||= organization_device_count
      end

      def managed_media_count
        ActiveFedora::SolrService.count(
          %{
            has_model_ssim:Media AND
            media_organization_id_ssim:#{collection.id} AND
            user_with_ownership_ssi:#{@collection.id}
          }
        )
      end

      def unmanaged_media_transferable_count
        ActiveFedora::SolrService.count(
          %{
            has_model_ssim:Media AND
            media_organization_id_ssim:#{collection.id} AND
            -owner_ssim:#{@collection.id} AND
            organization_transfer_on_publish_bsi:true
          }
        )
      end

      def unmanaged_media_untransferable_count
        ActiveFedora::SolrService.count(
          %{
            has_model_ssim:Media AND
            media_organization_id_ssim:#{collection.id} AND
            -owner_ssim:#{@collection.id} AND
            organization_transfer_on_publish_bsi:false
          }
        )
      end

      def query_media_management_counts
        @managed_media_count ||= managed_media_count
        @unmanaged_media_transferable_count ||= unmanaged_media_transferable_count
        @unmanaged_media_untransferable_count ||= unmanaged_media_untransferable_count
      end
    end
  end
end
