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

      # override https://github.com/projectblacklight/blacklight/blob/3120185709271c39f702a4ba176c5ad3865684d6/app/helpers/blacklight/render_constraints_helper_behavior.rb#L50
      # provides link for removing individual constraints
      def url_for(options)
        options[:controller] = 'teams'
        options[:action] = 'show'
        super
      end

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
        end

        def tab
          :media
        end

    end
  end
end
