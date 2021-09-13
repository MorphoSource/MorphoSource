module Morphosource
  module Collections
    class TeamsController < Morphosource::CollectionsController

      skip_load_and_authorize_resource only: [:show, :about], instance_name: :collection

      before_action :load_organization, only: [:show, :about]

      self.presenter_class = Morphosource::Collections::TeamPresenter

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
          # only display for org-linked teams; removed_facet
          config.add_facet_field "org_linked_team_origin_ssim", label: "Intersections", helper_method: :intersections_values
        end
      end
      configure_facets

      # If team doesn't have a linked organization, don't display the intersections facet
      def removed_facets
        if !@collection.organization.present?
          ["org_linked_team_origin_ssim"]
        else
          super
        end
      end

      private

        def filtered_facets
          ["member_of_project_ids_ssim", "member_of_team_ids_ssim"]
        end

        # link for facet filters
        def search_action_url(*args)
          main_app.team_media_path(*args)
        end

        def load_organization
          @collection ||= ::Collection.find(params[:id])
          @organization ||= @collection.organization
          if !@org_media_object_ids.present?
            @org_media_object_ids, @org_media_count = organization_media
          end
          @org_po_count ||= organization_po_count
        end

        # Returns count of objects representing organization_media
        def organization_po_count
          repository.blacklight_config.max_per_page = 999999
          search_builder = Morphosource::Collections::Teams::OrganizationObjectsSearchBuilder.new(self)
          response = repository.search(search_builder.rows(999999).query)
          count = response.response["numFound"].to_i
        end

        # Returns count of media belonging to linked organization
        # Filtered by user access
        def organization_media
          repository.blacklight_config.max_per_page = 999999
          search_builder = Morphosource::Collections::Teams::OrganizationMediaSearchBuilder.new(self)
          response = repository.search(search_builder.rows(999999).query)
          org_media_object_ids = response.response["docs"]
          org_media_count = response.response["numFound"].to_i
          [org_media_object_ids, org_media_count]
        end

    end
  end
end
