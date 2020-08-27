module Hyrax
  module My
    class TeamsController < MyController
      include Morphosource::CollectionHelper
      include CollectionsControllerBehavior
      include TeamsControllerBehavior

      with_themed_layout 'morphosource_dashboard'

      # Define collection specific filter facets.
      def self.configure_facets
        configure_blacklight do |config|
          # Name of pivot facet must match field name that uses helper_method
          config.add_facet_field Collection.collection_type_gid_document_field_name,
                                 helper_method: :collection_type_label, limit: 5,
                                 pivot: ['has_model_ssim', Collection.collection_type_gid_document_field_name],
                                 label: I18n.t('hyrax.dashboard.my.heading.collection_type')
          # This causes AdminSets to also be shown with the Collection Type label
          config.add_facet_field 'has_model_ssim',
                                 label: I18n.t('hyrax.dashboard.my.heading.collection_type'),
                                 limit: 5, show: false
        end
      end

      configure_facets

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        #add_breadcrumb t(:'hyrax.admin.sidebar.collections'), hyrax.my_collections_path
        collection_type_list_presenter
        managed_collections_count
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

        prepare_instance_variables_for_batch_control_display

        @collection_count_for_manager = 0
        @collection_count_for_editor = 0
        @collection_count_for_depositor = 0
        @collection_count_for_viewer = 0
        @collection_count_for_downloader = 0
        @collection_docs_count = @document_list.length

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

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          hyrax.my_dashboard_collections_facet_path(args[:id])
        end

        def collection_type_list_presenter
          @collection_type_list_presenter ||= Hyrax::SelectTeamCollectionTypeListPresenter.new(current_user)
        end

        def managed_collections_count
          @managed_collection_count = Hyrax::Collections::ManagedCollectionsService.managed_collections_count(scope: self)
        end
    end
  end
end
