module Morphosource
  module My
    class MediaController < WorksController

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = Morphosource::Users::MyMediaSearchBuilder
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "media_type", field: "human_readable_media_type_ssim", label: "Media Type", limit: 10
          config.add_facet_field "object", field: "physical_object_title_ssim", label: "Object", limit: 10
          config.add_facet_field "organization", field: "media_organization_ssim", label: "Organization", limit: 10
          config.add_facet_field "publication_status", field: "publication_status_ssi", label: "Publication Status", limit: 10
          config.add_facet_field "taxonomy_name", field: "taxonomy_ssim", label: "Taxonomy (Name)", limit: 10
          config.add_facet_field "team", field: "member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "project", field: "member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "owner", field: "user_with_ownership_name_ssim", label: "Data Manager", limit: 10
          config.add_facet_field "depositor", field: "depositor_name_ssim", label: "Data Uploader", limit: 10

          config.default_solr_params = {
            qt: "search",
            qf: "id title_tesim description_tesim creator_tesim keyword_tesim physical_object_title_tesim taxonomy_tesim"
          }
        end
      end
      configure_facets

      before_action :modify_search_builder_class_for_admin, only: [:index]

      private
        # If user is admin, use different search builder class
        def modify_search_builder_class_for_admin
          if current_user&.admin?
            blacklight_config.search_builder_class = Morphosource::Users::EditMediaSearchBuilder
          end
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          main_app.my_dashboard_media_facet_path(args[:id])
        end

        def search_action_url(*args)
          main_app.my_media_index_path(*args)
        end

        def tab_variables
          @tab = :media
          @tab_title = 'Media // MorphoSource'
        end
    end
  end
end
