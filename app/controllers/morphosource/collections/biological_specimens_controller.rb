module Morphosource
  module Collections
    class BiologicalSpecimensController < Morphosource::Collections::PhysicalObjectsController

      skip_load_and_authorize_resource only: [:show, :about, :facet], instance_name: :collection

      def search_builder_class
        Morphosource::Collections::SpecimensSearchBuilder
      end

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "record_source_ssim", label: "Source", limit: 10
          config.add_facet_field "organization_ssim", label: "Organization", limit: 10
          config.add_facet_field "media_member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "media_member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
        end
      end
      configure_facets

      private

        def query_collection_counts
          @specimen_count ||= @response.response["numFound"].to_i
          @cho_count ||= collection_cho_count
        end

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          if @collection.project?
            main_app.project_specimens_path(@curation_concern, *args)
          elsif @collection.team?
            main_app.team_specimens_path(@curation_concern, *args)
          end
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          # args id is the solr facet
          # params id is the collection id
          args.merge!(request.params)
          if @collection.project?
            main_app.project_specimens_facet_path(@collection.id, args)
          elsif @collection.team?
            main_app.team_specimens_facet_path(@collection.id, args)
          end
        end

        def tab
          :specimens
        end

    end
  end
end
