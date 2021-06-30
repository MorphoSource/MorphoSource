module Morphosource
  module Collections
    class ProjectsController < Morphosource::CollectionsController
      include Morphosource::Collections::ProjectsControllerBehavior
      include Morphosource::Collections::ProjectHelper
      include Hyrax::BreadcrumbsForCollections


      skip_load_and_authorize_resource only: [:show, :media]

      # include Blacklight::Configurable

      def search_builder_class
        Morphosource::Collections::Projects::MediaSearchBuilder
      end

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "publication_status_ssi", label: "Publication Status"
          config.add_facet_field "human_readable_media_type_ssim", label: "Media Type"
          config.add_facet_field "media_organization_ssim", label: "Organization"
          config.add_facet_field "member_of_project_ids_ssim", label: "Project", helper_method: :collection_title_by_id
          config.add_facet_field "member_of_team_ids_ssim", label: "Team", helper_method: :collection_title_by_id
        end
      end

      # include Blacklight::Configurable
      #
      # copy_blacklight_config_from(CatalogController)
      configure_facets

      def search_builder
        search_builder_class.new(scope: self, collection: @curation_concern)
      end

      private

        def filtered_facets
          ["member_of_project_ids_ssim", "member_of_team_ids_ssim"]
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          main_app.my_dashboard_media_facet_path(args[:id])
        end

        # link for facet filters
        def search_action_url(*args)
          byebug
          main_app.project_media_path(*args)
        end

        # def tab_variables
        #   @tab = :media
        #   @tab_title = 'Media // MorphoSource'
        # end

      def tab
        :media
      end

    end
  end
end
