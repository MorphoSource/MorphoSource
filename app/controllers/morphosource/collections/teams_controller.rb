module Morphosource
  module Collections
    class TeamsController < Morphosource::CollectionsController
      include Morphosource::Collections::LinkedTeamsControllerBehavior

      skip_load_and_authorize_resource only: [:show, :about, :facet], instance_name: :collection

      before_action :load_organization, only: [:show, :about]

      before_action :create_intersections_facet, only: [:show]

      self.presenter_class = Morphosource::Collections::TeamPresenter

      copy_blacklight_config_from(::MediaCatalogController)

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "publication_status_ssi", label: "Publication Status", limit: 10
          config.add_facet_field "human_readable_media_type_ssim", label: "Media Type", limit: 10
          config.add_facet_field "media_organization_ssim", label: "Organization", limit: 10
          config.add_facet_field "member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
          # intersections facet added by before_action :create_intersections_facet
        end
      end
      configure_facets

      private

        # link for facet filters
        def search_action_url(*args)
          main_app.team_media_path(*args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          main_app.team_media_facet_path(@collection.id, args[:id])
        end

    end
  end
end
