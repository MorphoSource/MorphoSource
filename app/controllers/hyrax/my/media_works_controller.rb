module Hyrax
  module My
    class MediaWorksController < MyController
      include MediaWorksControllerBehavior
      with_themed_layout 'morphosource_dashboard'

      # Define collection specific filter facets.
      #def self.configure_facets
      #  configure_blacklight do |config|
      #    config.add_facet_field solr_name("admin_set", :facetable), limit: 5
      #    config.add_facet_field solr_name('member_of_collections', :symbol), limit: 5
      #  end
      #end
      #configure_facets

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      # Search builder for a list of works that belong to me
      # Override of Blacklight::RequestBuilders
      def search_builder_class
        Hyrax::My::WorksSearchBuilder
      end

      def index
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        @user_collections_for_view = collections_service.search_results(:view)
        # The user's collections for the "add to collection" form
        @user_collections = collections_service.search_results(:deposit)
        @create_work_presenter = create_work_presenter_class.new(current_user)
        @user = current_user
        presenter
        query_collection_information
        query_collection_members
        prepare_instance_variables_for_batch_control_display
        respond_to do |format|
          format.html {}
          format.rss  { render layout: false }
          format.atom { render layout: false }
        end
      end

      def specimens
        @user_collections_for_view = collections_service.search_results(:view)
        presenter
        query_collection_information
        query_collection_members_for_po('bso')
        render :partial => 'tab_bso'
      end

      def chos
        @user_collections_for_view = collections_service.search_results(:view)
        presenter
        query_collection_information
        query_collection_members_for_po('cho')
        render :partial => "tab_cho"
      end

      private

        def collections_service
          Hyrax::CollectionsService.new(self)
        end

        def search_action_url(*args)
          hyrax.my_works_url(*args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          hyrax.my_dashboard_works_facet_path(args[:id])
        end

        def managed_works_count
          @managed_works_count = Hyrax::Works::ManagedWorksService.managed_works_count(scope: self)
        end
    end
  end
end