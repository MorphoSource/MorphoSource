module Morphosource
  module Facets
    module AccessFilters

      # remove collections from team and project facets that the user is not able to view
      def filter_facets
        return if current_user&.admin?

        get_viewable_collections_ids
        filtered_facets.each do |facet|
          items = @response.aggregations[facet].items
          @response.aggregations[facet].instance_variable_set(:@items,authorized_items(items))
          byebug
        end
      end

      # removes facets from display
      # ex: removes intersections facet from non-linked teams
      def remove_facets
        return if removed_facets.blank?

        removed_facets.each do |facet|
          @response.aggregations[facet].instance_variable_set(:@items,[])
        end
      end

      # displays values and pagination links for a single facet field
      # overrides Blacklight 6.23.0 app/controllers/concerns/blacklight/catalog
      def facet
        get_viewable_collections_ids
        super
      end

      def get_viewable_collections_ids
        if current_user
          @viewable_collections_ids ||= user_viewable_collection_ids
        else
          @viewable_collections_ids ||= Morphosource::SolrService.new.get_docs('has_model_ssim:Collection AND visibility_ssi:open', fl: 'id').map{|c| c["id"]}
        end
        byebug
      end

      def user_viewable_collection_ids
        Hyrax::Collections::PermissionsService.collection_ids_for_view(ability: current_ability) | Morphosource::SolrService.new.get_docs('has_model_ssim:Collection AND visibility_ssi:open', fl: 'id').map{|c| c["id"]}
      end

      # An item is unauthorized if its value (collection id) is not included in the array of ids a user is able to read.
      def item_unauthorized?(item)
        !@viewable_collections_ids.include? item.value
      end

      def unauthorized_items(items)
        items.each_with_object([]) do |item, unauthorized|
          unauthorized << item if item_unauthorized?(item)
        end
      end

      # An item is authorized if its value (collection id) is  included in the array of ids a user is able to read.
      def item_authorized?(item)
        @viewable_collections_ids.include? item.value
      end

      def authorized_items(items)
        items.each_with_object([]) do |item, authorized|
          authorized << item if item_authorized?(item)
        end
      end

      # override in controller
      # ex: ["member_of_project_ids_ssim", "member_of_team_ids_ssim"]
      def filtered_facets
        []
      end

      # override in controller
      def removed_facets
        []
      end
    end
  end
end
