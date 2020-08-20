module Hyrax
  module My
    class TeamsController < MyController
      include Morphosource::CollectionHelper

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

      #def search_builder_class
      #  @ms_collection_search_builder ||= Morphosource::My::MsCollectionsSearchBuilder.new(scope: self, collection_type: '2')
      #end

      def search_builder_class
        if page_is_project?
          Morphosource::My::MsProjectsSearchBuilder
        elsif page_is_team?
          Morphosource::My::MsTeamsSearchBuilder
        else
          Morphosource::My::MsCollectionsSearchBuilder
        end
      end

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        #add_breadcrumb t(:'hyrax.admin.sidebar.collections'), hyrax.my_collections_path
        collection_type_list_presenter
        managed_collections_count
        #super
        @user = current_user 
        (@response, @document_list) = query_solr

        prepare_instance_variables_for_batch_control_display

        @collection_count_for_manager = 0
        @collection_count_for_editor = 0
        @collection_count_for_depositor = 0
        @collection_count_for_viewer = 0
        @collection_count_for_downloader = 0
        @collection_docs_by_type = docs_by_collection_type(@response.docs)
        #@collection_docs_count = @collection_docs_by_type.count
        @collection_docs_count = @document_list.length



        #@paged_collection_docs_by_type = paginated_item_list
        if page_is_team?
          @collection_list_type = "team"
          @collection_list_type_id = 1
          add_breadcrumb t(:'hyrax.admin.sidebar.teams'), hyrax.my_collections_path.sub!('collection', 'team')
        elsif page_is_project?
          @collection_list_type = "project"
          @collection_list_type_id = 2
          add_breadcrumb t(:'hyrax.admin.sidebar.projects'), hyrax.my_collections_path.sub!('collection', 'project')
        else
          @collection_list_type = "collection"
        end

        respond_to do |format|
          format.html {}
          format.rss  { render layout: false }
          format.atom { render layout: false }
        end

      end

      # pagination methods
#      def paginated_item_list
#        # Uses kaminari to paginate an array to avoid need for solr documents for items here
#        Kaminari.paginate_array(@collection_docs_by_type, total_count: @collection_docs_count).page(current_page).per(rows_from_params)
#      end
#
#      def total_items
#        @collection_docs_count
#      end
#
#      def current_page
#        page = request.params[:tpage].nil? ? 1 : request.params[:tpage].to_i
#        page > total_pages ? total_pages : page
#      end
#
#      # @return [Integer] total number of pages of viewable items
#      def total_pages
#        (total_items.to_f / rows_from_params.to_f).ceil
#      end
#
#      def rows_from_params
#        request.params[:trows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:trows].to_i
#      end

      def docs_by_collection_type(docs)
        filtered_docs = []
        @visibility_options = []
        @organization_options = []
        @membership_options = []
        collection_filter_params = filter_params('k_', request.params)

        docs.each do |doc|
          collection = Collection.find(doc.id)
          if (page_is_team? and collection.team?) or (page_is_project? and collection.project?)
            if collection.membership_of(current_user).include?('Manager')
              @collection_count_for_manager = @collection_count_for_manager + 1
            elsif collection.membership_of(current_user).include?('Editor')
              @collection_count_for_editor = @collection_count_for_editor + 1
            elsif collection.membership_of(current_user).include?('Depositor')
              @collection_count_for_depositor = @collection_count_for_depositor + 1
            elsif collection.membership_of(current_user).include?('Viewer')
              @collection_count_for_viewer = @collection_count_for_viewer + 1
            elsif collection.membership_of(current_user).include?('Downloader')
              @collection_count_for_downloader = @collection_count_for_downloader + 1
            else
              # should not be here
            end          
            visibility_to_compare = collection_filter_params['visibility'] || collection.visibility
            organization_to_compare = collection_filter_params['organization'] || collection.organization
            membership_to_compare = collection_filter_params['membership'] || collection.membership_of(current_user).first
            if collection.visibility == visibility_to_compare &&
              collection.organization == organization_to_compare &&
              collection.membership_of(current_user).first == membership_to_compare
              filtered_docs << doc 
              @visibility_options << collection.visibility
              @organization_options << collection.organization if collection.organization.present?
              @membership_options << collection.membership_of(current_user).first if collection.membership_of(current_user).first.present?
            end
          end
        end
        @visibility_options = @visibility_options.uniq
        @organization_options = @organization_options.uniq
        @membership_options = @membership_options.uniq
        filtered_docs
      end

      private

        def search_action_url(*args)
          hyrax.my_collections_url(*args)
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
