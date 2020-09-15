module Morphosource
  class BrowseService
  
    attr_reader :solr

    def initialize
      @solr = solr_service.new
    end

    def bso_ids
      params = {
        fl: 'id',
        fq: [
          "(has_model_ssim:BiologicalSpecimen)"
        ]
      }
      return solr.get_docs(nil, params).map(&:values).flatten
    end

    def cho_ids
      params = {
        fl: 'id',
        fq: [
          "(has_model_ssim:CulturalHeritageObject)"
        ]
      }
      return solr.get_docs(nil, params).map(&:values).flatten
    end

    def organization_count_by_type(type)
      query = nil
      params = {
        fq: [
          "has_model_ssim:Organization",
          "#{Solrizer.solr_name('organization_type', :stored_searchable)}:\"#{type}\""
        ]
      }
      solr.get(query, params)
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
      query = nil
      params = {
        fq: [
          "physical_object_id_tesim:(#{po_ids.join(' OR ')})", 
          "has_model_ssim:Media"
        ]
      }
      solr.get(query, params)
      solr.count
    end

    def total_media_by_collection(collection_id)
      query = nil
      params = {
        fq: [
          "member_of_collection_ids_ssim:#{collection_id}",
          "has_model_ssim:Media"
        ]
      }
      solr.get(query, params)
      solr.count
    end

    def total_po_by_collection(collection_id)
      query = nil
      params = {
        fq: [
          "member_of_collection_ids_ssim:#{collection_id}",
          "has_model_ssim:Media",
          "-physical_object_id_tesim:nil"
        ]
      }
      solr.get(query, params)
      solr.count
    end

    def total_team_projects_by_collection(collection_id)
      query = nil
      params = {
        fq: [
          "member_of_collection_ids_ssim:#{collection_id}",
          "has_model_ssim:Collection"
        ]
      }
      solr.get(query, params)
      solr.count
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