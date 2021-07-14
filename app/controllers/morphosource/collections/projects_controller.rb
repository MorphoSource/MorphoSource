module Morphosource
  module Collections
    class ProjectsController < Morphosource::CollectionsController
      include Morphosource::Collections::ProjectsControllerBehavior
      include Hyrax::CollectionsControllerBehavior
      include Morphosource::Collections::ProjectHelper
      include Hyrax::BreadcrumbsForCollections


      skip_load_and_authorize_resource only: [:show, :media]

      # include Blacklight::Configurable

      def search_builder_class
        Morphosource::Collections::Projects::MediaSearchBuilder
      end

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

      # include Blacklight::Configurable
      #
      # copy_blacklight_config_from(CatalogController)
      configure_facets

      def search_builder
        search_builder_class.new(scope: self, collection: @curation_concern)
      end

      def presenter
        @presenter ||= begin
          curation_concern = SolrDocument.find(params[:id])
          raise CanCan::AccessDenied unless (curation_concern && current_ability.can?(:read, curation_concern))
          presenter_class.new(curation_concern, current_ability)
        end
      end

      # override https://github.com/projectblacklight/blacklight/blob/3120185709271c39f702a4ba176c5ad3865684d6/app/helpers/blacklight/render_constraints_helper_behavior.rb#L50
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

        def self.search_state_class
          Morphosource::SearchState
        end

        # def tab_variables
        #   @tab = :media
        #   @tab_title = 'Media // MorphoSource'
        # end

      def tab
        :media
      end

    end
  end
end
