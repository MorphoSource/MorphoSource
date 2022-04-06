module Morphosource
  module Collections
    module LinkedTeamsControllerBehavior

      def load_organization
        @collection ||= ::Collection.find(params[:id])
        byebug
        @organization ||= @collection.organization
        return if @organization.nil?

        if !@org_media_object_ids.present?
          @org_media_object_ids, @org_media_count = organization_media
        end
        @org_po_count ||= organization_po_count
      end

      # Need to create this here to have access to @collection & @organization
      def create_intersections_facet
        return if @organization.blank?

        config = repository.blacklight_config
        config.add_facet_field 'intersections', label: 'Intersections', query: {
          organization: {
            label: 'All media of organization physical objects',
            fq: "media_organization_id_ssim:#{@organization.id}" },
          team: {
            label: 'All media owned by team',
            fq: "member_of_team_ids_ssim:#{@collection.id}" },
          team_and_organization: {
            label: 'Media owned by team AND of organization physical objects',
            fq: "media_organization_id_ssim:#{@organization.id} AND member_of_team_ids_ssim:#{@collection.id}" },
          organization_not_team: {
            label: 'Media of organization physical objects NOT owned by team',
            fq: "media_organization_id_ssim:#{@organization.id} NOT member_of_team_ids_ssim:#{@collection.id}" },
          team_not_organization: {
            label: 'Media owned by team NOT of organization physical objects',
            fq: "member_of_team_ids_ssim:#{@collection.id} NOT media_organization_id_ssim:#{@organization.id}" }
        }
      end

      # Returns count of objects representing organization_media
      def organization_po_count
        repository.blacklight_config.max_per_page = 999999
        search_builder = Morphosource::Collections::Teams::OrganizationObjectsSearchBuilder.new(self)
        repository.search(search_builder.query).response["numFound"].to_i
      end

      # Returns count of media belonging to linked organization
      # Filtered by user access
      def organization_media
        repository.blacklight_config.max_per_page = 999999
        search_builder = Morphosource::Collections::Teams::OrganizationMediaSearchBuilder.new(self)
        response = repository.search(search_builder.rows(999999).query).response
        org_media_object_ids = response["docs"].map{|d| d["physical_object_id_ssim"].try(:first)}.compact.uniq
        org_media_count = response["numFound"].to_i
        [org_media_object_ids, org_media_count]
      end

      # Returns collections containing media of organization specimens not owned by team
      # Filtered by user access
      def query_organization_media_collections
        return unless current_user.can?(:edit, @collection)

        repository.blacklight_config.max_per_page = 999999
        repository.blacklight_config.facet_fields = {}
        repository.blacklight_config.add_facet_field "member_of_project_ids_ssim", limit: 999999
        repository.blacklight_config.add_facet_field "member_of_team_ids_ssim", limit: 999999
        create_intersections_facet

        @org_media_collection_ids = organization_media_collection_ids
        @collections_document_list = organization_media_collections
      end

      def organization_media_collection_ids
        return unless current_user.can?(:edit, @collection)
        search_builder = Morphosource::Collections::MediaProjectsSearchBuilder.new(
          scope: self, collection: @collection
        ).with(params)
        @response = repository.search(search_builder.rows(999999).query)
        @response.docs.map{|d| d["member_of_collection_ids_ssim"]}.flatten.compact.uniq
      end

      def organization_media_collections
        return unless current_user.can?(:edit, @collection)
        collection_search_builder = Morphosource::Collections::Teams::OrganizationCollectionsSearchBuilder.new(self)
        response = repository.search(collection_search_builder.rows(999999))
        response.docs
      end

    end
  end
end
