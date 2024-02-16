module Hyrax
  module My
    class TeamsController < MyController
      include MyTeamsControllerBehavior
      include Morphosource::CollectionHelper
      helper_method :page_is_project?, :ms_dashboard_my_collection_link, :hidden_params_for_filters, :visibility_label,
        :page_is_team?, :collection_type, :hidden_params_for_pagination

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
        if page_is_project?
          @collection_list_type = "project"
          add_breadcrumb t(:'hyrax.admin.sidebar.projects'), hyrax.my_collections_path.sub!('collection', 'project')
        elsif page_is_team?
          @collection_list_type = "team"
          add_breadcrumb t(:'hyrax.admin.sidebar.teams'), hyrax.my_collections_path.sub!('collection', 'team')
        else
          @collection_list_type = "collection"
        end

        collections_by_memberships
        query_collection_information

        respond_to do |format|
          format.html {}
        end

      end

      def collections_by_memberships
        @user = current_user
        all_memberships_collection_ids, manager_collection_ids, editor_collection_ids, depositor_collection_ids, downloader_collection_ids, viewer_collection_ids = @user.collections_with_membership_role_ids
        # pass the target_collection_ids to information service (mainly for facets)
        if params['k_membership'].present?
          case params['k_membership']
            when 'Manager'
              @target_collection_ids = manager_collection_ids
            when 'Editor'
              @target_collection_ids = editor_collection_ids
            when 'Depositor'
              @target_collection_ids = depositor_collection_ids
            when 'Downloader'
              @target_collection_ids = downloader_collection_ids
            when 'Viewer'
              @target_collection_ids = viewer_collection_ids
            end
        else
          @target_collection_ids = all_memberships_collection_ids
        end
        # todo: see if there is a way to avoid queries to get each membership docs
        # currently this is needed, at least for getting the counts
        manager_docs = teams_service.collection_docs_by_type_and_ids(page_collection_type_id, collection_filter_params, manager_collection_ids)
        editor_docs = teams_service.collection_docs_by_type_and_ids(page_collection_type_id, collection_filter_params, editor_collection_ids)
        depositor_docs = teams_service.collection_docs_by_type_and_ids(page_collection_type_id, collection_filter_params, depositor_collection_ids)
        downloader_docs = teams_service.collection_docs_by_type_and_ids(page_collection_type_id, collection_filter_params, downloader_collection_ids)
        viewer_docs = teams_service.collection_docs_by_type_and_ids(page_collection_type_id, collection_filter_params, viewer_collection_ids)
        # pass the target_collection_ids to information service
        if params['k_membership'].present?
          case params['k_membership']
            when 'Manager'
              @document_list = manager_docs
            when 'Editor'
              @document_list = editor_docs
            when 'Depositor'
              @document_list = depositor_docs
            when 'Downloader'
              @document_list = downloader_docs
            when 'Viewer'
              @document_list = viewer_docs
            end
        else
          all_memberships_docs = teams_service.collection_docs_by_type_and_ids(page_collection_type_id, collection_filter_params, all_memberships_collection_ids)
          @document_list = all_memberships_docs
        end
        @paginated_document_list = paginated_item_list
        @collection_counts = {}
        @collection_counts["Manager"] = manager_docs.count if manager_docs.count > 0
        @collection_counts["Editor"] = editor_docs.count if editor_docs.count > 0
        @collection_counts["Depositor"] = depositor_docs.count if depositor_docs.count > 0
        @collection_counts["Downloader"] = downloader_docs.count if downloader_docs.count > 0
        @collection_counts["Viewer"] = viewer_docs.count if viewer_docs.count > 0
      end

      def query_collection_information
        @collection_information = teams_information_service.collection_information
        @collection_groups = @collection_information['collection_groups'] ||= {}
      end

      def collection_filter_params
        returned_solrize_filter_params = teams_information_service.solrize_filter_params(filter_params('k_', params))
        #unless params['k_membership'].present?
        #  # if no membership criteria, get collections with any membership value
        #  returned_solrize_filter_params << teams_information_service.default_membership_params
        #end
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
          @teams_service ||= teams_service_class.new(scope: self, user: current_user, params: params_for_query)
        end

        def teams_information_service
          @teams_information_service ||= information_service_class.new(current_user, page_collection_type_id, "my", @target_collection_ids)
        end

        def browse_teams_information_service
          @teams_information_service ||= information_service_class.new(current_user, page_collection_type_id, "browse", nil)
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
