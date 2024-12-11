module Hyrax

  class BrowseOrganizationsController < My::WorksController
    before_action :authenticate_user!, except: [:index]  

    with_themed_layout 'morphosource_1_column'

    def self.configure_facets
      configure_blacklight do |config|
        config.search_builder_class = Morphosource::OrganizationsSearchBuilder
      end
    end

    def search_builder_class
      Morphosource::OrganizationsSearchBuilder
    end
    # todo: this method call (and definition above) might not be needed. remove later
    configure_facets

    def index
      (@response, @document_list) = search_service.search_results
      @paginated_document_list = paginated_item_list
      get_organization_count_by_type

      respond_to do |format|
        format.html {}
      end
    end
  
    def get_organization_count_by_type
      @org_type_and_count ||= begin
        facet_array = @response.dig("facet_counts", "facet_fields", "organization_type_sim")
        if facet_array.present?
          Hash[*facet_array]
        else
          {}
        end
      end
    end
  
    def total_collections
      return @document_list.map { |org| org["team_id_tesim"] }.compact.length
    end

    def org_type_and_count
      @org_type_and_count
    end
    helper_method :org_type_and_count

    private

      def search_action_url(*args)
        Rails.application.routes.url_helpers.browse_organizations_path(*args)
      end

      def paginated_item_list
        # Uses kaminari to paginate an array to avoid need for solr documents for items here
        Kaminari.paginate_array(@document_list, total_count: @document_list.size).page(current_page).per(rows_from_params)
      end

      def total_items
        @document_list.size
      end

      def current_page
        page = request.params[:tpage].nil? ? 1 : request.params[:tpage].to_i
        page > total_pages ? total_pages : page
      end

      # @return [Integer] total number of pages of viewable items
      def total_pages
        (total_items.to_f / rows_from_params.to_f).ceil
      end

      def rows_from_params
        request.params[:rows].nil? ? Hyrax.config.browse_page_item_rows : request.params[:rows].to_i
      end


  end

end
