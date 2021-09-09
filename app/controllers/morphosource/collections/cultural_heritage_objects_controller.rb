module Morphosource
  module Collections
    class CulturalHeritageObjectsController < Morphosource::Collections::PhysicalObjectsController

      def search_builder_class
        Morphosource::Collections::ChosSearchBuilder
      end

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "organization_ssim", label: "Organization"
          config.add_facet_field "media_member_of_project_ids_ssim", label: "Project", helper_method: :collection_title_by_id
          config.add_facet_field "media_member_of_team_ids_ssim", label: "Team", helper_method: :collection_title_by_id
        end
      end
      configure_facets

      private

        def query_collection_works
          @cho_count = @response.response["numFound"].to_i if @response.present?
          super
        end

        # link for facet filters
        def search_action_url(*args)
          if @collection.project?
            main_app.project_chos_path(*args)
          elsif @collection.team?
            main_app.team_chos_path(*args)
          end
        end

        def tab
          :chos
        end

    end
  end
end
