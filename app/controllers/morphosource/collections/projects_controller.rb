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

      # override https://github.com/projectblacklight/blacklight/blob/3120185709271c39f702a4ba176c5ad3865684d6/app/helpers/blacklight/render_constraints_helper_behavior.rb#L50
      # provides link for removing individual constraints
      def url_for(options)
        options[:controller] = 'projects'
        options[:action] = 'show'
        super
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
          main_app.project_media_path(*args)
        end

    end
  end
end
