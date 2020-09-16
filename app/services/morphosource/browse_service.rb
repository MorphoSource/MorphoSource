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

    # ---  methods for media types and modality ---

    def media_count_by_modality(modality)
      member_ids = member_ids_by_modality(modality)
      return 0 unless member_ids.present?
      params = {
        rows: 0,
        fq: [
          assemble_or_query('id', member_ids),
          "has_model_ssim:Media"
        ] 
      }
      solr.get(nil, params)
      solr.count
    end

    def member_ids_by_modality(modality)
      # media < IE 
      # or
      # media < PE < IE
      ie_member_ids = imaging_event_member_ids_by_modality(modality)
      pe_member_ids = processing_event_member_ids_by_imaging_events(ie_member_ids)
      return ie_member_ids + pe_member_ids
    end

    def imaging_event_member_ids_by_modality(modality)
      params = {
        fl: 'member_ids_ssim',
        fq: [
          "#{Solrizer.solr_name('ie_modality', :stored_searchable)}:#{modality}",
          "#{Solrizer.solr_name('has_model', :symbol)}:ImagingEvent"
        ]
      }
      solr.get_docs(nil, params).map(&:values).flatten
    end

    def processing_event_member_ids_by_imaging_events(ie_member_ids)
      return [] unless ie_member_ids.present?
      params = {
        fl: 'member_ids_ssim',
        fq: [
          assemble_or_query('id', ie_member_ids),
          "#{Solrizer.solr_name('has_model', :symbol)}:ProcessingEvent"
        ]
      }
      tmp = solr.get_docs(nil, params).map(&:values).flatten
      return tmp
    end


    def media_count_by_media_type
      facet_fields = [
        "media_type_tesim"
      ]
      params = {
        fl: 'id',
        fq: ["has_model_ssim:Media"]

      }
      solr.get_facet_fields(nil, facet_fields, params)
#byebug
      return solr.facet_fields(facet_fields)
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