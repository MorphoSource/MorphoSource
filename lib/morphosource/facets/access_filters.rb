module Morphosource
  module Facets
    module AccessFilters

      # override in controller
      # ex: ["member_of_project_ids_ssim", "member_of_team_ids_ssim"]
      def filtered_facets
        []
      end

      # remove collections from team and project facets that the user is not able to view
      def filter_facets
        return if current_user&.admin?
        get_viewable_collections_ids
        filtered_facets.each do |facet|
          items = @response.aggregations[facet].items
          unauthorized_items = unauthorized_items(items)
          unauthorized_items.each do |item|
            items.delete(item)
          end
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
          @viewable_collections_ids ||= Hyrax::Collections::PermissionsService.collection_ids_for_view(ability: current_ability)
        else
          @viewable_collections_ids ||= Morphosource::SolrService.new.get_docs('has_model_ssim:Collection AND visibility_ssi:open', fl: 'id').map{|c| c["id"]}
        end
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
    end
  end
end
