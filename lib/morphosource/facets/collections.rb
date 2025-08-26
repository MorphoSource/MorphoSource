module Morphosource
  module Facets
    module Collections

      # displays values and pagination links for a single facet field
      # overrides Blacklight 7.40.0 app/controllers/concerns/blacklight/catalog
      # if paging on collections id facet (ex: 'member_of_team_ids') and sorting alphabetically, use the alphabetized_collections_facet method instead
      def facet
        @facet = blacklight_config.facet_fields[params[:id]]
        raise ActionController::RoutingError, 'Not Found' unless @facet
        if ([:title_by_id, :collection_title_by_id].include? @facet&.helper_method) && params["facet.sort"] == "index"
          alphabetized_facet
        elsif @facet&.helper_method == :user_name_by_id && params["facet.sort"] == "index"
          alphabetized_facet(facet_type: 'user')
        elsif @facet&.helper_method == :collection_title_by_id && params["facet.containsTitle"].present?
          filter_facet(params["facet.containsTitle"])
        else
          @response = search_service.facet_field_response(@facet.key)
          @display_facet = @response.aggregations[@facet.field]

          @presenter = (@facet.presenter || Blacklight::FacetFieldPresenter).new(@facet, @display_facet, view_context)
          @pagination = @presenter.paginator

          respond_to do |format|
            format.html do
              # Draw the partial for the "more" facet modal window:
              return render layout: false if request.xhr?
              # Otherwise draw the facet selector for users who have javascript disabled.
            end
            format.json
          end
        end
      end

      # Run a filter on the returned facet values to only include the IDs that match the title
      def filter_facet(contains_title)
        blacklight_config.default_more_limit = 999999
        @response = search_service.facet_field_response(@facet.key, params.to_unsafe_h) # todo5 fix this
        title_search_response = fetch_ids_by_title(contains_title, @facet.key)
        matching_ids = title_search_response['response']['docs'].map { |doc| doc['id'] }
        set_display_facet_items(filtered_values: matching_ids)
        # pass the modified display_facet to the facet_paginator
        @pagination = facet_paginator(@facet, @display_facet)
        respond_to do |format|
          format.html do
            # Draw the partial for the "more" facet modal window:
            return render layout: false if request.xhr?
            # Otherwise draw the facet selector for users who have javascript disabled.
          end
          format.json
        end
      end

      # Query Solr to fetch IDs by matching title and model
      def fetch_ids_by_title(title, facet_key)
        # Perform a lookup on the Solr title field to find matching IDs
        case facet_key
        when 'team'
          query = 'has_model_ssim:Collection AND human_readable_type_tesim:Team'
        when 'project'
          query = 'has_model_ssim:Collection AND human_readable_type_tesim:Project'
        when 'media_list'
          query = 'has_model_ssim:MediaList'
        when 'seq_section_list'
          query = 'has_model_ssim:SequentialSectionList'
        else
          query = 'has_model_ssim:unknown'
          Rails.logger.warn("Unknown model for facet key: #{facet_config.key}")
        end

        full_query = "#{query} AND title_tesim:\"#{title}\""
        solr_service = Blacklight.default_index.connection
        solr_service.get('select', params: {
          q: full_query,
          fl: 'id, has_model_ssim, title_tesim',
          rows: 999999
        })
      end

      # modifies blacklight behavior to retrieve all values for a collection id facet instead of only the values for one page.
      # can then sort all of the collections by title, and then return the section of the sorted array that corresponds to the requested page
      def alphabetized_facet(facet_type: nil)
        raise ActionController::RoutingError, 'Not Found' unless @facet
        # save page number, but delete facet.page to set offset to 0 for searching
        params["az_facet.page"] = params.delete("facet.page")
        # set default_more_limit to retrieve all facet items instead of just the ones for one page
        blacklight_config.default_more_limit = 999999
        @response = search_service.facet_field_response(@facet.key, params.to_unsafe_h) # todo5 fix this
        # sort all the facet items by title
        facet_type == 'user' ? sort_users_by_display_name : sort_records_by_title
        # modify the display facet to include only the items for the current page
        set_display_facet_items
        # pass the modified display_facet to the facet_paginator
        @pagination = facet_paginator(@facet, @display_facet)
        respond_to do |format|
          format.html do
            # Draw the partial for the "more" facet modal window:
            return render layout: false if request.xhr?
            # Otherwise draw the facet selector for users who have javascript disabled.
          end
          format.json
        end
      end

      def sort_records_by_title
        @response.aggregations[@facet.field].items.sort_by! { |i| filtered_record_title_by_id(i.value).downcase }
      end

      def sort_users_by_display_name
        @response.aggregations[@facet.field].items.sort_by! { |i| filtered_display_name_by_id(i.value).downcase }
      end

      def set_display_facet_items(filtered_values: nil)
        per_page_count = 20 # set this to the number of items to display per page
        limit = per_page_count + 1 # need to set this because we temporarily set blacklight_config.default_more_limit to 999999
        page = params["az_facet.page"]&.to_i || 1
        offset = page*per_page_count - per_page_count

        @display_facet = @response.aggregations[@facet.field]
        # set display_facet limit to one more than the page item count
        options = @display_facet.instance_variable_get(:@options)
        options[:offset] = offset
        options[:limit] = limit

        if (filtered_values).present?
          filtered_items = @display_facet.items.select { |item| filtered_values.include?(item.value) }
          @display_facet.instance_variable_set(:@items, filtered_items[offset, limit])
        else
          # remove items not from the page
          @display_facet.instance_variable_set(:@items,@display_facet.items[offset,limit])
        end
        # reset page params
        params["facet.page"] = params.delete("az_facet.page")
      end

      def filtered_record_title_by_id(id)
        @record_titles ||= record_titles
        @record_titles[id] || "Collection #{id} Not Found"
      end

      def filtered_display_name_by_id(id)
        @display_names ||= display_names
        @display_names[id] || "User #{id} Not Found"
      end

      # returns a hash of record ids and titles:
      # ex: {"000202905"=>"Collection Title 1", "000200071"=>"Collection Title 2"}
      def record_titles
        record_ids = @response.aggregations[@facet.field].items.map { |i| i.value }
        Morphosource::SolrService.new.get_docs(nil, fl: 'id,title_tesim', fq: ["id:(#{record_ids.join(' OR ')})"]).map {|h| [h["id"], h["title_tesim"].first]}.to_h
      end

      # returns a hash of user ids and display names:
      # ex:
      def display_names
        User.all.each_with_object({}) do |u, names|
          names[u.ms_id] = u.name_or_email
        end
      end

    end
  end
end
