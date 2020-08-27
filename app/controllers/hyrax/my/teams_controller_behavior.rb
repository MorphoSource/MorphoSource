# Cloned from CollectionsControllerBehavior to set TeamPresenter
module Hyrax
  module My
    module TeamsControllerBehavior
      extend ActiveSupport::Concern
      include Blacklight::AccessControls::Catalog
      include Blacklight::Base

      included do
        # include the display_trophy_link view helper method
        helper Hyrax::TrophyHelper

        # This is needed as of BL 3.7
        copy_blacklight_config_from(::CatalogController)

        class_attribute :presenter_class,
                        :teams_service_class,
                        :information_service_class

        self.teams_service_class = Morphosource::Collections::TeamsService
        self.information_service_class = Morphosource::Collections::TeamsInformationService
      end

      def collection
        action_name == 'show' ? @presenter : @collection
      end


      private

        def teams_service 
           teams_service_class.new(scope: self, user: current_user, params: params_for_query)
        end

        def teams_information_service
          @teams_information_service ||= information_service_class.new(current_user, @collection_list_type_id) 
        end

        def paginated_item_list
          # Uses kaminari to paginate an array to avoid need for solr documents for items here
          Kaminari.paginate_array(@document_list, total_count: @document_list.size).page(current_page).per(rows_from_params)
        end

        def total_items
          @document_list.size
        end

        def current_page
          page = request.params[:page].nil? ? 1 : request.params[:page].to_i
          page > total_pages ? total_pages : page
        end

        # @return [Integer] total number of pages of viewable items
        def total_pages
          (total_items.to_f / rows_from_params.to_f).ceil
        end

        def rows_from_params
          request.params[:rows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:rows].to_i
        end

        # You can override this method if you need to provide additional inputs to the search
        # builder. For example:
        #   search_field: 'all_fields'
        # @return <Hash> the inputs required for the collection member query service
        def params_for_query
          #params.merge(q: params[:cq])

          # setting higher collection limit for paginating the array       
          params.merge(q: params[:q]).merge({ 'rows' => '999999', 'page' => '1' })
        end
    end
  end
end