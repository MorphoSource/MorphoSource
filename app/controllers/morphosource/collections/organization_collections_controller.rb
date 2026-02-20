module Morphosource
  module Collections
    class OrganizationCollectionsController < Morphosource::CollectionsController
      include Morphosource::Collections::LinkedTeamsControllerBehavior
      include Morphosource::Collections::OrganizationCollectionsControllerBehavior

      skip_load_and_authorize_resource only: [:show, :about, :facet,
        :media_export, :media_download_counts, :media_downloads, :media_requests
      ], instance_name: :collection

      before_action :redirect_to_collection_type, only: []

      before_action :load_organization, only: [:show, :facet, :about,
        :media_projects, :media_organization_transfer_status]

      # must go after load_organization
      before_action :redirect_organization_type, only: [:show]

      before_action :create_extra_facets, only: [:show, :facet, :about,
        :media_export, :media_download_counts, :media_projects, :media_organization_transfer_status]

      helper_method :search_action_for_dashboard

      self.presenter_class = Morphosource::Collections::OrganizationPresenter

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class

          config.facet_fields = {} # clear catalog facet fields
          config.add_facet_field "publication_status", field: "publication_status_ssi", label: "Publication Status", limit: 10
          config.add_facet_field "media_type", field: "human_readable_media_type_ssim", label: "Media Type", limit: 10
          config.add_facet_field "object", field: "physical_object_title_ssim", label: "Object", limit: 10
          config.add_facet_field "taxonomy_name", field: "taxonomy_ssim", label: "Taxonomy (Name)", limit: 10
          config.add_facet_field "device", field: "media_device_ssim", label: "Device", limit: 10
          config.add_facet_field "device_organization", field: "media_device_facility_organization_ssim", label: "Device Organization", limit: 10
          config.add_facet_field "team", field: "member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "project", field: "member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "owner", field: "user_with_ownership_ssi", label: "Data Manager", limit: 10, helper_method: :user_name_by_id
          config.add_facet_field "depositor", field: "depositor_ssim", label: "Data Uploader", limit: 10, helper_method: :user_name_by_id
          # hidden field used to determine if there are specimens on the page
          config.add_facet_field "object_type", field: "media_physical_object_type_ssim", label: "Object Type", limit: 10, show: false
        end
      end
      configure_facets

      def create_extra_facets
        create_access_facet
        create_transfer_facet if current_user&.can?(:edit, @curation_concern) && @curation_concern.media_ownership_transfer
      end

      # Media search facet for whether media is owned by organization, in transfer system, or out
      def create_transfer_facet
        return unless current_user&.can? :edit, @curation_concern
        return if blacklight_config.facet_fields["transfer"].present?

        org_is_owner_clause = "owner_ssim:#{@curation_concern.id}"
        transfer_ready_clause = "organization_transfer_on_publish_bsi:true"

        blacklight_config.add_facet_field "transfer", label: "Transfer Status", query: {
          managed: {
            label: t("hyrax.organization.show.facets.transfer.managed"),
            fq: "#{org_is_owner_clause}"
          },
          ready: {
            label: t("hyrax.organization.show.facets.transfer.ready"),
            fq: "-#{org_is_owner_clause} AND #{transfer_ready_clause}"
          },
          unready: {
            label: t("hyrax.organization.show.facets.transfer.unready"),
            fq: "-#{org_is_owner_clause} AND -#{transfer_ready_clause}"
          }
        }
      end

      def collection_type
        Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::Organizations::SETTINGS)
      end

      def search_builder_class
        Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder
      end

      def search_action_for_dashboard
        main_app.organization_path
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

        def redirect_organization_type
          # if the organization has object media, do not redirect to the device media tab
          return unless @org_media_count == 0

          redirect_to organization_device_media_path(@collection) if @collection.scanning_facility?
        end

    end
  end
end