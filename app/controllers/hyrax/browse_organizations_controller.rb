module Hyrax

	class BrowseOrganizationsController < My::WorksController

			with_themed_layout 'morphosource_1_column'      

      def search_builder_class
        Morphosource::OrganizationsSearchBuilder
      end

      def index 
				(@response, @document_list) = query_solr
        @paginated_document_list = paginated_item_list

				respond_to do |format|
				format.html {}
				format.rss  { render layout: false }
				format.atom { render layout: false }
				end
      end


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