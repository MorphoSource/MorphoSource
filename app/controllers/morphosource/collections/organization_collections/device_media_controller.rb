module Morphosource
  module Collections
    module OrganizationCollections
      # Media that were created using a device that belongs to the organization
      class DeviceMediaController < Morphosource::Collections::OrganizationCollectionsController
        skip_load_and_authorize_resource only: [:show, :about, :facet, :media_export, :media_downloads, :media_download_counts, :media_requests, :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet], instance_name: :collection

        def search_builder_class
          Morphosource::Collections::OrganizationCollections::DeviceMediaSearchBuilder
        end

        self.presenter_class = Morphosource::Collections::OrganizationPresenter

        def create_extra_facets
          create_access_facet
        end

        private

          # link for facet filters
          def search_action_url(*args)
            args&.first&.delete("collection_id")
            main_app.organization_device_media_path(@curation_concern, *args)
          end

          # The url of the "more" link for additional facet values
          def search_facet_path(args = {})
            # args id is the solr facet
            # params id is the collection id
            request.params.delete("id")
            args.merge!(request.params)
            main_app.organization_device_media_facet_path(@collection.id, args)
          end

          def tab
            :device_media
          end

      end
    end
  end
end