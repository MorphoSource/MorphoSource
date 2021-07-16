module Morphosource
  module Collections
    class BiologicalSpecimensController < Morphosource::CollectionsController
      # include Morphosource::Collections::ProjectsControllerBehavior
      # include Hyrax::CollectionsControllerBehavior
      # include Morphosource::Collections::ProjectHelper
      # include Hyrax::BreadcrumbsForCollections

      # skip_load_and_authorize_resource only: [:show]

      # include Blacklight::Configurable

      def search_builder_class
        Morphosource::Collections::SpecimensSearchBuilder
      end

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "record_source_ssim", label: "Source"
          config.add_facet_field "organization_ssim", label: "Organization"
          config.add_facet_field "media_member_of_project_ids_ssim", label: "Project", helper_method: :collection_title_by_id
          config.add_facet_field "media_member_of_team_ids_ssim", label: "Team", helper_method: :collection_title_by_id
        end
      end
      # copy_blacklight_config_from(::CatalogController)
      configure_facets

      def presenter
        @presenter ||= begin
          curation_concern = SolrDocument.find(params[:id])
          raise CanCan::AccessDenied unless (curation_concern && current_ability.can?(:read, curation_concern))
          presenter_class.new(curation_concern, current_ability)
        end
      end

      # override https://github.com/projectblacklight/blacklight/blob/3120185709271c39f702a4ba176c5ad3865684d6/app/helpers/blacklight/render_constraints_helper_behavior.rb#L50
      # provides link for removing individual constraints
      def url_for(options)
        options[:controller] = 'biological_specimens'
        options[:action] = 'show'
        super
      end

      def filtered_facets
        ["media_member_of_project_ids_ssim", "media_member_of_team_ids_ssim"]
      end

      private

        def query_collection_works
          @media_list = collection_media
          super
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          main_app.my_dashboard_media_facet_path(args[:id])
        end

        # link for facet filters
        def search_action_url(*args)
          main_app.project_specimens_path(*args)
        end

        def tab
          :specimens
        end

        def gather_instance_variables
          @media_list ||= collection_media
          super
        end

        def member_count
          @response.response["numFound"].to_s + ' Specimens'
        end

    end
  end
end
