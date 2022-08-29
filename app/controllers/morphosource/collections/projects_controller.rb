module Morphosource
  module Collections
    class ProjectsController < Morphosource::CollectionsController

      skip_load_and_authorize_resource only: [:show, :about, :facet, :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet], instance_name: :collection
      # before_action :create_data_manager_facet, only: [:show, :facet, :media_projects]
      # before_action :create_access_facet, only: [:show, :facet, :media_projects]

      before_action :create_data_manager_facet, only: [:show, :facet,
        :media_projects, :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet]
      before_action :create_access_facet, only: [:show, :facet,
        :media_projects, :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet]

      self.presenter_class = Morphosource::Collections::ProjectPresenter

      copy_blacklight_config_from(::MediaCatalogController)

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "publication_status_ssi", label: "Publication Status", limit: 10
          config.add_facet_field "human_readable_media_type_ssim", label: "Media Type", limit: 10
          config.add_facet_field "physical_object_title_ssim", label: "Object", limit: 10
          config.add_facet_field "media_organization_ssim", label: "Organization", limit: 10
          config.add_facet_field "member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
        end
      end
      configure_facets

      private

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          main_app.project_media_path(@curation_concern, *args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          # args id is the solr facet
          # params id is the collection id
          args.merge!(request.params)
          main_app.project_media_facet_path(@collection.id, args)
        end

        # get project or team URL for collection
        def collection_url(coll_hash)
          main_app.project_media_url(coll_hash[:id])
        end

    end
  end
end
