module Morphosource
  module Organizations
    class OrganizationInformationService < Morphosource::Collections::CollectionInformationService
      # Returns derived information about organization (counts, media/category, etc.) with fast solr searches
      attr_reader :solr, :collection_id, :collection, :is_org_team,
        :collection_organization_id, :team_org_po_ids, :n_media_team_organization,
        :facet_results, :media_count, :physical_object_ids, :bso_ids, :cho_ids,
        :n_idigbio, :collection_project_map, :organizations, :info, :subcollection_ids

      SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

      def self.call(collection_id)
        new(collection_id).call
      end

      def self.collection_organization_object_ids(collection_id)

      end

      def initialize(collection_id)
        @solr = solr_service.new
        @collection = Organization.find(collection_id)
        @collection_organization_id = collection_id
        @collection_id = nil
        @is_org_team = true # collection.team?

        query_solr_collection_info
      end

      def query_solr_collection_info
        if is_org_team # && collection_id && Collection.find(collection_id).organization.present?
          # @collection_organization_id = Collection.find(collection_id).organization.id
          @team_org_po_ids = organization_po_ids
          @n_media_team_organization = team_org_origin_count if is_org_team
        end

        @facet_results, @media_count = media_facet_query

        @physical_object_ids = facet_results['physical_object_id_tesim'].keys.map(&:upcase)
        @bso_ids = po_ids_by_model(physical_object_ids, BiologicalSpecimen)
        @cho_ids = po_ids_by_model(physical_object_ids, CulturalHeritageObject)
        @n_idigbio = bso_idigbio_count

        @collection_project_map = collection_id_to_project_title_map
        @organizations = organization_docs
      end
    end
  end
end
