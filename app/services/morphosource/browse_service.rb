module Morphosource
  class BrowseService
  
    attr_reader :solr

    def initialize
      @solr = solr_service.new
    end

    def organization_count_by_type(type)
      params = {
        rows: 0,
        fq: [
          "has_model_ssim:Organization",
          "#{Solrizer.solr_name('organization_type', :stored_searchable)}:\"#{type}\""
        ]
      }
      solr.get(nil, params)
      solr.count
    end

    def po_ids_by_org(org)
      return [] unless org.member_ids.present?
      params = {
        fl: 'id',
        fq: [
          "id:(#{org.member_ids.join(' OR ')})",
          "(has_model_ssim:BiologicalSpecimen OR has_model_ssim:CulturalHeritageObject)"
        ]
      }
      return solr.get_docs(nil, params).map(&:values).flatten
    end

    def total_media_by_po_ids(po_ids)
      return 0 unless po_ids.present?
      params = {
        rows: 0,
        fq: [
          "physical_object_id_tesim:(#{po_ids.join(' OR ')})", 
          "has_model_ssim:Media"
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
        "media_physical_object_type_sim"
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
        Solrizer.solr_name("media_type", :stored_searchable),
        "media_modality_sim"
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