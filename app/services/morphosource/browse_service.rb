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

    def po_ids
      params = {
        fl: 'id',
        fq: [
          "(has_model_ssim:BiologicalSpecimen OR has_model_ssim:CulturalHeritageObject)"
        ]
      }
      return solr.get_docs(nil, params).map(&:values).flatten
    end

    def po_ids_by_org(org)
      # If an org has large number of member IDs, the long fq param string can cause the Request-URI Too Long error,
      # To avoid adding long list of IDs in the fq, intersect the PO ids and the Org member ids
      return [] unless org.member_ids.present?
      return po_ids & org.member_ids
    end

    def total_media_by_po_ids(po_ids)
      media_ids = []
      po_ids.each do |id|
        media_ids << media_ids_by_po_id(id)
      end    
      return media_ids.flatten.uniq.count
    end

    def media_ids_by_po_id(po_id)
      return 0 unless po_id.present?
      params = {
        fl: 'id',
        fq: [
          "physical_object_id_tesim:(#{po_id})", 
          "has_model_ssim:Media"
        ]
      }
      return solr.get_docs(nil, params).map(&:values).flatten
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


      #def search_solr(qry)
      #  ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{SORTABLE_TITLE_FIELD} ASC")
      #end
  end

end