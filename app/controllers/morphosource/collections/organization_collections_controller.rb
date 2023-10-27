module Morphosource
  module Collections
    class OrganizationCollectionsController < Morphosource::CollectionsController
      include Morphosource::Collections::LinkedTeamsControllerBehavior

      skip_load_and_authorize_resource only: [:show, :about, :facet, :order_media], instance_name: :collection

      before_action :redirect_to_collection_type, only: []

      # temporary restriction so only admins can access organizations
      before_action :authorize_admin

      before_action :load_organization, only: [:show, :facet, :about,
        :media_projects, :media_organization_transfer_status,
        :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet]

      class_attribute :collection_type

      self.presenter_class = Morphosource::Collections::OrganizationPresenter

      self.collection_type = collection_type

      def collection_type
        Hyrax::CollectionType.find_by(title: 'Organization')
      end

      private

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          main_app.organization_path(@curation_concern, *args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          # args id is the solr facet
          # params id is the collection id
          request.params.delete("id")
          args.merge!(request.params)
          main_app.organization_media_facet_path(@collection.id, args)
        end

    end
  end
end