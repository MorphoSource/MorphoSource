module Morphosource
  module My
    class MediaListsController < ::Hyrax::MyController

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

      def search_builder_class
        Morphosource::My::MediaListsSearchBuilder
      end

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t("morphosource.dashboard.my.media_lists.page_title"), main_app.my_media_lists_path
        # collection_type_list_presenter
        # managed_collections_count
        super
        # @user = current_user
        # (@response, @document_list) = query_solr
        # prepare_instance_variables_for_batch_control_display
        #
        # respond_to do |format|
        #   format.html {}
        #   format.rss  { render layout: false }
        #   format.atom { render layout: false }
        # end
      end

      private

        def search_action_url(*args)
          hyrax.my_collections_url(*args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          hyrax.my_dashboard_collections_facet_path(args[:id])
        end

        # def collection_type_list_presenter
        #   @collection_type_list_presenter ||= Hyrax::SelectCollectionTypeListPresenter.new(current_user)
        # end
        #
        # def managed_collections_count
        #   @managed_collection_count = Hyrax::Collections::ManagedCollectionsService.managed_collections_count(scope: self)
        # end

        # def query_solr
        #   search_results(params)
        # end
    end
  end
end
