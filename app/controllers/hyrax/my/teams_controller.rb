module Hyrax
  module My
    class TeamsController < MyController
      include Morphosource::CollectionHelper
      include MyTeamsControllerBehavior

      with_themed_layout 'morphosource_dashboard'

      class_attribute :presenter_class,
                      :teams_service_class,
                      :information_service_class

      self.teams_service_class = Morphosource::Collections::TeamsService
      self.information_service_class = Morphosource::Collections::TeamsInformationService

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        collection_type_list_presenter
        #super
        @user = current_user 

        if page_is_project?
          @collection_list_type = "project"
          @collection_list_type_id = 2
          add_breadcrumb t(:'hyrax.admin.sidebar.projects'), hyrax.my_collections_path.sub!('collection', 'project')
        elsif page_is_team?
          @collection_list_type = "team"
          @collection_list_type_id = 1
          add_breadcrumb t(:'hyrax.admin.sidebar.teams'), hyrax.my_collections_path.sub!('collection', 'team')
        else
          @collection_list_type = "collection"
        end

        query_collection_information

        @response = teams_service.all_collections_by_type(@collection_list_type_id, collection_filter_params)
        @document_list = @response.documents
        @paginated_document_list = paginated_item_list

        respond_to do |format|
          format.html {}
          format.rss  { render layout: false }
          format.atom { render layout: false }
        end

      end

      def query_collection_information
        @collection_information = teams_information_service.collection_information
        @collection_counts = @collection_information['counts'] ||= {}
        @collection_groups = @collection_information['collection_groups'] ||= {}
      end

      def collection_filter_params
        returned_solrize_filter_params = teams_information_service.solrize_filter_params(filter_params('k_', params))
        unless params['k_membership'].present?
          # if no membership criteria, get collections with any membership value
          returned_solrize_filter_params << teams_information_service.default_membership_params          
        end
        returned_solrize_filter_params
      end

      def filter_params(prefix, params)
        return_params = {}
        temp_params = params.select{ |k,v| k.match(/^#{prefix}/) }.select{ |k,v| v.present? }
        temp_params.each do |k,v|
          return_params[k] = v
        end
        return_params
      end

      def collection
        action_name == 'show' ? @presenter : @collection
      end

      private

        def search_action_url(collection_list_type, *args)
          if collection_list_type == 'project'
            Rails.application.routes.url_helpers.my_projects_path(*args)
          elsif collection_list_type == 'team'
            Rails.application.routes.url_helpers.my_teams_path(*args)
          else
            hyrax.my_collections_url(*args)
          end
        end

        def collection_type_list_presenter
          @collection_type_list_presenter ||= Hyrax::SelectTeamCollectionTypeListPresenter.new(current_user)
        end

        def teams_service 
           teams_service_class.new(scope: self, user: current_user, params: params_for_query)
        end

        def teams_information_service
          @teams_information_service ||= information_service_class.new(current_user, @collection_list_type_id, "my") 
        end

        def browse_teams_information_service
          @teams_information_service ||= information_service_class.new(current_user, @collection_list_type_id, "browse") 
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
