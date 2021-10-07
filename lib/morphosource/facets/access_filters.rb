module Morphosource
  module Facets
    module AccessFilters

      # remove collections from team and project facets that the user is not able to view
      # display collection title - updating the items themselves rather than using a helper allows for the items to be sorted alphabetically
      def filter_facets
        if current_user&.admin?
          filtered_facets.each do |facet|
            items = @response.aggregations[facet].items
            @response.aggregations[facet].instance_variable_set(:@items,items[0,filtered_facet_limit + 1])
            byebug
            @response.aggregations[facet].items[0,filtered_facet_limit].each{ |i| i.value = collection_title_by_id(i.value) }
            byebug
            @response.aggregations[facet].instance_variable_get(:@options)[:limit] = filtered_facet_limit + 1
            blacklight_config.facet_fields[facet].limit = filtered_facet_limit
          end
        else
          get_viewable_collections_ids
          filtered_facets.each do |facet|
            items = @response.aggregations[facet].items
            @response.aggregations[facet].instance_variable_set(:@items,authorized_items(items))
            @response.aggregations[facet].items[0,filtered_facet_limit].each{ |i| i.value = collection_title_by_id(i.value) }
            options = @response.aggregations[facet].instance_variable_get(:@options)
            options[:limit] = filtered_facet_limit + 1
            @response.aggregations[facet].instance_variable_set(:@options, options)
            blacklight_config.facet_fields[facet].limit = filtered_facet_limit
          end
        end
      end

      def

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
      # displays values and pagination links for a single facet field
      # def facet
      #   get_viewable_collections_ids
      #   blacklight_config.search_builder_class = Morphosource::Catalog::MediaFilteredFacetsSearchBuilder
      #
      #   @facet = blacklight_config.facet_fields[params[:id]]
      #   raise ActionController::RoutingError, 'Not Found' unless @facet
      #   @response = get_facet_field_response(@facet.key, params)
      #   byebug
      #   @display_facet = @response.aggregations[@facet.field]
      #   @pagination = facet_paginator(@facet, @display_facet)
      #   byebug
      #   respond_to do |format|
      #     format.html do
      #       # Draw the partial for the "more" facet modal window:
      #       return render layout: false if request.xhr?
      #       # Otherwise draw the facet selector for users who have javascript disabled.
      #     end
      #     format.json
      #   end
      # end

      def get_viewable_collections_ids
        if current_user
          @viewable_collections_ids ||= user_viewable_collection_ids
        else
          @viewable_collections_ids ||= Morphosource::SolrService.new.get_docs('has_model_ssim:Collection AND visibility_ssi:open', fl: 'id').map{|c| c["id"]}
        end
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
        authorized = []
        items.each do |item|
          return authorized if authorized.count == filtered_facet_limit + 1
          if authorized.count <= filtered_facet_limit
            authorized << item if item_authorized?(item)
          end
        end
        authorized
      end

      def authorized_items(items)
        authorized = []
        items.each do |item|
          return authorized if authorized.count == filtered_facet_limit + 1
          if authorized.count <= filtered_facet_limit
            authorized << item if item_authorized?(item)
          end
        end
        authorized
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

      # override in controller
      def filtered_facet_limit
        5
      end

      # modified from https://github.com/samvera/hyrax/blob/7588d785f71522e23ad73daf908151aea1d53165/app/helpers/hyrax/hyrax_helper_behavior.rb#L262
      def collection_title_by_id(id)
        solr_docs = repository.find(id).docs
        return nil if solr_docs.empty?
        solr_field = solr_docs.first["title_tesim"]
        return nil if solr_field.nil?
        solr_field.first
      end
    end
  end
end
