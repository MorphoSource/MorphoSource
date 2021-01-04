module Morphosource
  class BrowseService
    include Blacklight::AccessControls::Catalog
    include Blacklight::Base
  
    attr_reader :solr

    #copy_blacklight_config_from(::CatalogController)

    def initialize
      @solr = solr_service.new
    end

    def organization_facets
      facet_fields = [
        Solrizer.solr_name('organization_type', :facetable)
      ]
      params = {
        fl: 'id',
        fq: ["has_model_ssim:Organization"]
      }
      solr.get_facet_fields(nil, facet_fields, params)
      return solr.facet_fields(facet_fields)
    end

    def total_media_by_org(organization_id)
      params = {
        rows: 0,
        fq: [
          "media_organization_id_ssim:#{organization_id}",
          "(has_model_ssim:Media)"
        ]
      }
      solr.get(nil, params)
      solr.count
    end

    def total_po_by_org(organization_id)
      params = {
        rows: 0,
        fq: [
          "organization_id_ssim:#{organization_id}",
          "(has_model_ssim:BiologicalSpecimen OR has_model_ssim:CulturalHeritageObject)"
        ]
      }
      solr.get(nil, params)
      solr.count
    end

    def total_media_by_collection(collection_id)
      params = {
        rows: 0,
        fq: [
          "member_of_collection_ids_ssim:#{collection_id}",
          "has_model_ssim:Media"
        ]
      }
      solr.get(nil, params)
      solr.count
    end

    def total_po_by_collection(collection_id)
      params = {
        rows: 0,
        fq: [
          "member_of_collection_ids_ssim:#{collection_id}",
          "has_model_ssim:Media",
          "-physical_object_id_tesim:nil"
        ]
      }
      solr.get(nil, params)
      solr.count
    end

    def total_team_projects_by_collection(collection_id)
      params = {
        rows: 0,
        fq: [
          "member_of_collection_ids_ssim:#{collection_id}",
          "has_model_ssim:Collection"
        ]
      }
      solr.get(nil, params)
      solr.count
    end

    # ---  methods for physical object types ---

    def media_po_type_facets
      facet_fields = [
        Solrizer.solr_name('media_physical_object_type', :facetable)
      ]
      params = {
        fl: 'id',
        fq: ["has_model_ssim:Media"]
      }
      solr.get_facet_fields(nil, facet_fields, params)
      return solr.facet_fields(facet_fields), solr.count
    end

    def total_bso
      params = {
        rows: 0,
        fq: [
          "(has_model_ssim:BiologicalSpecimen)"
        ]
      }
      solr.get(nil, params)
      solr.count
    end

    def total_cho
      params = {
        rows: 0,
        fq: [
          "(has_model_ssim:CulturalHeritageObject)"
        ]
      }
      solr.get(nil, params)
      solr.count
    end

    # ---  methods for media types and modality ---

    def media_type_and_modality_facets
      facet_fields = [
        Solrizer.solr_name("media_type", :facetable),
        Solrizer.solr_name("media_modality", :facetable)
      ]
      params = {
        fl: 'id',
        fq: ["has_model_ssim:Media"]
      }
      solr.get_facet_fields(nil, facet_fields, params)
      return solr.facet_fields(facet_fields), solr.count
    end

    def assemble_or_query(field, values)
      return "" if !field.present? || !values.present?
      field + ':(' + values.join(' OR ').upcase + ')'
    end


    private

      ### Solr utility methods ###

      def solr_service
        Morphosource::SolrService
      end
  end
end