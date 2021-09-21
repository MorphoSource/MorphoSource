module Morphosource
  module Collections
    module LinkedTeamsControllerBehavior

      def load_organization
        @collection ||= ::Collection.find(params[:id])
        @organization ||= @collection.organization
        return if @organization.nil?

        if !@org_media_object_ids.present?
          @org_media_object_ids, @org_media_count = organization_media
        end
        @org_po_count ||= organization_po_count
      end

      # Returns count of objects representing organization_media
      def organization_po_count
        repository.blacklight_config.max_per_page = 999999
        search_builder = Morphosource::Collections::Teams::OrganizationObjectsSearchBuilder.new(self)
        response = repository.search(search_builder.rows(999999).query)
        count = response.response["numFound"].to_i
      end

      # Returns count of media belonging to linked organization
      # Filtered by user access
      # TODO: refactor to get this info from collection_media ?
      def organization_media
        repository.blacklight_config.max_per_page = 999999
        search_builder = Morphosource::Collections::Teams::OrganizationMediaSearchBuilder.new(self)
        response = repository.search(search_builder.rows(999999).query)
        org_media_object_ids = response.response["docs"]
        org_media_count = response.response["numFound"].to_i
        [org_media_object_ids, org_media_count]
      end

    end
  end
end
