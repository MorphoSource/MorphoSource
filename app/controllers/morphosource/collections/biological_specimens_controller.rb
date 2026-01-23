module Morphosource
  module Collections
    class BiologicalSpecimensController < Morphosource::Collections::PhysicalObjectsController
      include Morphosource::Collections::LinkedTeamsControllerBehavior

      skip_load_and_authorize_resource only: [:show, :about, :facet, :objects_export], instance_name: :collection

      def search_builder_class
        Morphosource::Collections::SpecimensSearchBuilder
      end

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "record_source", field: "record_source_ssim", label: "Source", limit: 10
          config.add_facet_field "organization", field: "organization_ssim", label: "Organization", limit: 10
          config.add_facet_field "taxonomy_name", field: "taxonomy_ssim", label: "Taxonomy (Name)", limit: 10
          config.add_facet_field "taxonomy_gbif", field: "external_taxonomy_ssim", label: "Taxonomy (GBIF)", limit: 25
          config.add_facet_field "media_type", field: "public_media_type_ssim", label: "Media Type", limit: 10
          config.add_facet_field "team", field: "media_member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "project", field: "media_member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
        end
      end
      configure_facets

      private

        def query_collection_counts
          @specimen_count ||= @response.response["numFound"].to_i
          @cho_count ||= collection_cho_count
          @media_count ||= collection_media_count
        end

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          collection_type = @collection.collection_type.machine_id
          main_app.send("#{collection_type}_specimens_path", @collection, *args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          args.merge!(request.params)
          # args :id is the solr facet
          # params/args "id" is the collection id
          args.delete("id")
          collection_type = @collection.collection_type.machine_id
          main_app.send("#{collection_type}_specimens_facet_path", @collection.id, args)
        end

        def tab
          :specimens
        end

        def allowed_sort_parameters
          ["date_uploaded_dtsi asc",
           "date_uploaded_dtsi desc",
           "record_source_si asc",
           "record_source_si desc",
           "taxonomy_name_si asc",
           "taxonomy_name_si desc",
           "title_ssi asc",
           "title_ssi desc"]
        end
    end
  end
end
