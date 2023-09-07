module Morphosource
  module My
    module Collections
      module MediaLists
        class SequentialSectionListsController < Morphosource::My::Collections::MediaListsController

          # temporary restriction so only admins can access media lists
          before_action :authorize_admin, only: []

          def collections_type
            "sequential_section_lists"
          end

          def search_builder_class
            Morphosource::My::Collections::MediaLists::SequentialSectionListsSearchBuilder
          end

          def search_action_url(*args)
            main_app.my_sequential_section_lists_url(*args)
          end

          def search_action_for_dashboard
            main_app.my_sequential_section_lists_path
          end


          private

            def add_collection_type_breadcrumb
              add_breadcrumb t(:'hyrax.admin.sidebar.sequential_section_lists'), main_app.my_sequential_section_lists_path
            end

        end
      end
    end
  end
end
