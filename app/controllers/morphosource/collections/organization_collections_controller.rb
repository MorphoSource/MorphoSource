module Morphosource
  module Collections
    class OrganizationCollectionsController < Morphosource::CollectionsController
      include Morphosource::Collections::LinkedTeamsControllerBehavior
      include Morphosource::Collections::OrganizationCollectionsControllerBehavior

      skip_load_and_authorize_resource only: [:show, :about, :facet, :order_media, :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet, :media_downloads, :media_requests], instance_name: :collection

      before_action :redirect_to_collection_type, only: []

      # temporary restriction so only admins can access organizations
      before_action :authorize_admin

      before_action :load_organization, only: [:show, :facet, :about,
        :media_projects, :media_organization_transfer_status]

      class_attribute :collection_type

      self.presenter_class = Morphosource::Collections::OrganizationPresenter

      self.collection_type = collection_type

      def collection_type
        Hyrax::CollectionType.find_by(title: 'Organization')
      end

      def search_builder_class
        Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder
      end

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class

          config.facet_fields = {} # clear catalog facet fields
          config.add_facet_field "publication_status", field: "publication_status_ssi", label: "Publication Status", limit: 10
          config.add_facet_field "media_type", field: "human_readable_media_type_ssim", label: "Media Type", limit: 10
          config.add_facet_field "organization", field: "media_organization_ssim", label: "Organization", limit: 10
          config.add_facet_field "object", field: "physical_object_title_ssim", label: "Object", limit: 10
          config.add_facet_field "taxonomy_name", field: "taxonomy_ssim", label: "Taxonomy (Name)", limit: 10
          config.add_facet_field "device", field: "media_device_ssim", label: "Device", limit: 10
          config.add_facet_field "device_organization", field: "media_device_facility_organization_ssim", label: "Device Organization", limit: 10
          config.add_facet_field "team", field: "member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "project", field: "member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "owner", field: "user_with_ownership_name_ssim", label: "Data Manager", limit: 10
          config.add_facet_field "depositor", field: "depositor_name_ssim", label: "Data Uploader", limit: 10
          # hidden field used to determine if there are specimens on the page
          config.add_facet_field "object_type", field: "media_physical_object_type_ssim", label: "Object Type", limit: 10, show: false
        end
      end
      configure_facets

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