module Morphosource
  module Collections
    class ProjectsController < Morphosource::CollectionsController

      skip_load_and_authorize_resource only: [:show, :about], instance_name: :collection

      self.presenter_class = Morphosource::Collections::ProjectPresenter

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
      configure_facets

      private

        def filtered_facets
          ["member_of_project_ids_ssim", "member_of_team_ids_ssim"]
        end

        # link for facet filters
        def search_action_url(*args)
          main_app.project_media_path(*args)
        end

    end
  end
end
