module Morphosource
  module My
    module Collections
      class MediaListsController < Morphosource::My::CollectionsController

        before_action :build_breadcrumbs, only: []

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
            add_breadcrumb t(:'hyrax.admin.sidebar.media_lists'), main_app.my_media_lists_path
          end
      end
    end
  end
end