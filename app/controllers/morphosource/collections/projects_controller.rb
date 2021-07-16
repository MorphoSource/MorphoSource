module Morphosource
  module Collections
    class ProjectsController < Morphosource::CollectionsController
      include Morphosource::Collections::ProjectsControllerBehavior
      # include Hyrax::CollectionsControllerBehavior
      # include Morphosource::Collections::ProjectHelper
      # include Hyrax::BreadcrumbsForCollections

      # skip_load_and_authorize_resource only: [:show]

      # include Blacklight::Configurable

      load_and_authorize_resource except: [:index, :show, :specimens, :chos, :about, :create, :media], instance_name: :collection

      skip_load_and_authorize_resource only: [:show, :about]

      def search_builder_class
        Morphosource::Collections::MediaSearchBuilder
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
      # provides link for removing individual constraints
      def url_for(options)
        options[:controller] = 'projects'
        options[:action] = 'show'
        super
      end

      private

        def query_collection_works
          super
        end

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

        def tab
          :media
        end

        def gather_instance_variables
          @response, @document_list = query_solr unless @response.present? 
          @media_list = @document_list
          super
        end

        def member_count
          @response, @document_list = query_solr unless @response.present?
          media_count = @response.response["numFound"].to_s + ' Media'
        end

    end
  end
end
