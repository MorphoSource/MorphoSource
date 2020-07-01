module Hyrax
  module My
    class TeamsController < MyTeamController
      include Morphosource::CollectionHelper

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

      def search_builder_class
        Morphosource::My::MsCollectionsSearchBuilder
      end

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.collections'), hyrax.my_collections_path
        collection_type_list_presenter
        managed_collections_count
        super
        @collection_count_for_manager = 0
        @collection_count_for_editor = 0
        @collection_count_for_depositor = 0
        @collection_count_for_viewer = 0
        @collection_count_for_downloader = 0
        @collection_docs_by_type = docs_by_collection_type(@response.docs)
        @collection_docs_count = @collection_docs_by_type.count
        if page_is_team?
          @collection_list_type = "team"
        elsif page_is_project?
          @collection_list_type = "project"
        else
          @collection_list_type = "collection"
        end
      end

      def docs_by_collection_type(docs)
        filtered_docs = []
        docs.each do |doc|
          collection = Collection.find(doc.id)
          if (page_is_team? and collection.team?) or (page_is_project? and collection.project?)
            if collection.membership_of(current_user).include?('Manager')
              @collection_count_for_manager = @collection_count_for_manager + 1
              filtered_docs << doc 
            elsif collection.membership_of(current_user).include?('Editor')
              @collection_count_for_editor = @collection_count_for_editor + 1
              filtered_docs << doc 
            elsif collection.membership_of(current_user).include?('Depositor')
              @collection_count_for_depositor = @collection_count_for_depositor + 1
              filtered_docs << doc 
            elsif collection.membership_of(current_user).include?('Viewer')
              @collection_count_for_viewer = @collection_count_for_viewer + 1
              filtered_docs << doc 
            elsif collection.membership_of(current_user).include?('Downloader')
              @collection_count_for_downloader = @collection_count_for_downloader + 1
              filtered_docs << doc 
            end          
          end
        end
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
