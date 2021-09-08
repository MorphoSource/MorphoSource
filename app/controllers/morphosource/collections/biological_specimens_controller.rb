module Morphosource
  module Collections
    class BiologicalSpecimensController < Morphosource::Collections::PhysicalObjectsController

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
      configure_facets

      # override https://github.com/projectblacklight/blacklight/blob/3120185709271c39f702a4ba176c5ad3865684d6/app/helpers/blacklight/render_constraints_helper_behavior.rb#L50
      # provides link for removing individual search constraints
      def url_for(options)
        options[:controller] = 'biological_specimens'
        options[:action] = 'show'
        super
        url = super
        if @collection.team?
          url.gsub("/projects/","/teams/")
          url.gsub("/collections/","/teams/")
        elsif @collection.project?
          url.gsub("/teams/","/projects/")
          url.gsub("/collections/","/projects/")
        end
      end

      private

        def query_collection_works
          @specimen_count = @response.response["numFound"].to_i if @response.present?
          super
        end

        # link for facet filters
        def search_action_url(*args)
          if @collection.project?
            main_app.project_specimens_path(*args)
          elsif @collection.team?
            main_app.team_specimens_path(*args)
          end
        end

        def tab
          :specimens
        end

    end
  end
end
