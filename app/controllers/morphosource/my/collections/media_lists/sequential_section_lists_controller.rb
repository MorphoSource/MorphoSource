module Morphosource
  module My
    module Collections
      module MediaLists
        class SequentialSectionListsController < Morphosource::My::Collections::MediaListsController
          include Morphosource::Facets::Collections

          def self.configure_facets
            super.tap do |config|
              config.add_facet_field "physical_object_id_ssi", label: "Object", limit: 10, helper_method: :title_by_id
              config.add_facet_field "taxonomy_ssim", label: "Taxonomy", limit: 1
              config.add_facet_field "organization_id_ssim", label: "Object Organization", limit: 10, helper_method: :title_by_id
            end
          end
          configure_facets

          # this needs to be called after configure_facets
          configure_blacklight do |config|
            config.search_builder_class = Morphosource::My::Collections::MediaLists::SequentialSectionListsSearchBuilder
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

            # The url of the "more" link for additional facet values
            def search_facet_path(args = {})
              main_app.my_dashboard_sequential_section_lists_facet_path(args[:id])
            end

        end
      end
    end
  end
end
