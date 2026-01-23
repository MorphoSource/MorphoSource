module Morphosource
  module My
    module Collections
      class MediaListsController < Morphosource::My::CollectionsController

        configure_blacklight do |config|
          config.search_builder_class = Morphosource::My::Collections::MediaListsSearchBuilder
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

        def allowed_sort_parameters
          ["date_modified_dtsi asc",
           "date_modified_dtsi desc",
           "date_uploaded_dtsi asc",
           "date_uploaded_dtsi desc",
           "list_type_ssim asc",
           "list_type_ssim desc",
           "publication_status_si asc",
           "publication_status_si desc",
           "title_ssi asc",
           "title_ssi desc"]
        end

      end
    end
  end
end