module Morphosource
  module Facets
    module Collections
      include Morphosource::Facets::SolrTitleLookup

      ID_HELPER_METHODS = [
        :collection_title_by_id,
        :device_title_by_id,
        :title_by_id,
        :user_name_by_id
      ].freeze

      # displays values and pagination links for a single facet field
      # overrides Blacklight 7.40.0 app/controllers/concerns/blacklight/catalog
      def facet
        @facet = blacklight_config.facet_fields[params[:id]]
        raise ActionController::RoutingError, 'Not Found' unless @facet

        # if the facet has an id helper method we need to handle sorting and searching differently
        if id_helper_method?
          id_helper_facet(contains_title: params["facet.containsTitle"])
        else
          @response = facet_search_response
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

      def id_helper_method?
        Morphosource::Facets::Collections::ID_HELPER_METHODS.include? @facet&.helper_method
      end

      # modifies blacklight behavior to retrieve all values for a collection id facet instead of only the values for one page.
      # can then sort all of the collections by title, and then return the section of the sorted array that corresponds to the requested page
      def id_helper_facet(facet_type: nil, contains_title: nil)
        raise ActionController::RoutingError, 'Not Found' unless @facet
        # save page number, but delete facet.page to set offset to 0 for searching
        params["az_facet.page"] = params.delete("facet.page")
        # set default_more_limit to retrieve all facet items instead of just the ones for one page
        blacklight_config.default_more_limit = 999999

        @response = facet_search_response

        # nil when there is no search term, so no lookup is performed and
        # set_display_facet_items paginates every value
        matching_ids =
          case @facet.key
          when 'owner'
            # owners can be users or organizations
            fetch_owner_ids_by_name(contains_title)
          when 'depositor'
            # depositors are always users
            fetch_user_ids_by_name(contains_title)
          else
            fetch_ids_by_title(contains_title, @facet.key)
          end
        if params["facet.sort"] == "index"
          if @facet.helper_method == :user_name_by_id
            # sort all the facet items by user display name
            sort_records_by_name
          else
            # sort all the facet items by title
            sort_records_by_title
          end
        end
        # modify the display facet to include only the items for the current page
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

      def sort_records_by_title
        @response.aggregations[@facet.field].items.sort_by! { |i| filtered_record_title_by_id(i.value).downcase }
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
        # nil means no filtering was requested; [] means a search matched
        # nothing and must show no items
        if filtered_values.nil?
          # remove items not from the page
          @display_facet.instance_variable_set(:@items, @display_facet.items[offset, limit] || [])
        else
          filtered_items = @display_facet.items.select { |item| filtered_values.include?(item.value) }
          @display_facet.instance_variable_set(:@items, filtered_items[offset, limit] || [])
        end
        # reset page params
        params["facet.page"] = params.delete("az_facet.page")
      end

      def filtered_record_title_by_id(id)
        @record_titles ||= record_titles
        @record_titles[id] || "Record #{id} Not Found"
      end

      # returns a hash of record ids and titles:
      # ex: {"000202905"=>"Collection Title 1", "000200071"=>"Collection Title 2"}
      def record_titles
        service = Morphosource::SolrService.new
        fl, title = sort_title(@facet.key)
        # batch requests to avoid solr limit
        facet_item_ids.each_slice(500).flat_map do |batch|
          fq = "id:(#{batch.join(' OR ')})"
          service.get_docs(nil, fl: fl, fq: [fq]).map { |h| [h["id"], title[h]] }
        end.to_h
      end

      def sort_title(facet_key)
        case facet_key
        when 'device'
          fl = 'id,title_tesim,creator_tesim'
          title = ->(hash) { "#{ hash['creator_tesim']&.first || "" } #{ hash['title_tesim']&.first }" }
        else
          fl = 'id,title_tesim'
          title = ->(hash) { "#{hash["title_tesim"].first}" }
        end
        [fl, title]
      end

      def sort_records_by_name
        @response.aggregations[@facet.field].items.sort_by! do |i|
          name = filtered_record_name_by_id(i.value).downcase
          # users sort by last name, organizations by full title
          organization_names.key?(i.value) ? name : name.split.last || name
        end
      end

      def filtered_record_name_by_id(id)
        record_names[id] || "User #{id} Not Found"
      end

      def record_names
        @record_names ||= user_names.merge(organization_names)
      end

      def user_names
        @user_names ||= User.where(ms_id: facet_item_ids).pluck(:ms_id, :display_name).to_h
      end

      # owner facet values can also be OrganizationCollection ids, which
      # user_name_by_id renders as the collection title, so resolve their
      # titles here too for sorting
      def organization_names
        @organization_names ||= organization_titles(facet_item_ids - user_names.keys)
      end

      def facet_item_ids
        @response.aggregations[@facet.field].items.map { |i| i.value }
      end

      def organization_titles(record_ids)
        return {} if record_ids.blank?

        service = Morphosource::SolrService.new
        # batch requests to avoid solr limit
        record_ids.each_slice(500).flat_map do |batch|
          fq = ["id:(#{batch.join(' OR ')})", 'has_model_ssim:OrganizationCollection']
          service.get_docs(nil, fl: 'id,title_tesim', fq: fq).map { |h| [h['id'], h['title_tesim']&.first] }
        end.to_h
      end
    end
  end
end
