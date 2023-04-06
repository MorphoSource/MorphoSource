module Morphosource
  module Collections
    class ProjectsController < Morphosource::CollectionsController

      skip_load_and_authorize_resource only: [:show, :about, :facet, :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet], instance_name: :collection
      before_action :create_access_facet, only: [:show, :facet,
        :media_projects, :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet]

      self.can_authorize_with_temporary_link = true
      self.presenter_class = Morphosource::Collections::ProjectPresenter

      private

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          main_app.project_path(@curation_concern, *args)
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
          main_app.project_url(coll_hash[:id])
        end

    end
  end
end
