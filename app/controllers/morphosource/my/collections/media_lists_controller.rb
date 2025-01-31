module Morphosource
  module My
    module Collections
      class MediaListsController < Morphosource::My::CollectionsController

        before_action :build_breadcrumbs, only: []

        configure_blacklight do |config|
          config.search_builder_class = Morphosource::My::Collections::MediaListsSearchBuilder
        end

        def collections_type
          "media_lists"
        end

        def search_builder_class
          Morphosource::My::Collections::MediaListsSearchBuilder
        end

        def search_action_url(*args)
          main_app.my_media_lists_url(*args)
        end

        def search_action_for_dashboard
          main_app.my_media_lists_path
        end

        private

          def add_collection_type_breadcrumb
            add_breadcrumb t(:'morphosource.dashboard.sidebar.my_media_collections.media_lists'), main_app.my_media_lists_path, { "aria-current" => "page" }
          end
      end
    end
  end
end