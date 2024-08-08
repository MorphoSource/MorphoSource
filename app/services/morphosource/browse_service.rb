module Morphosource
  class BrowseService
    include Blacklight::AccessControls::Catalog
    include Blacklight::Base

    attr_reader :solr

    #copy_blacklight_config_from(::CatalogController)

    def initialize
      @solr = solr_service.new
    end

    def total_media_and_po_by_org(organization_id)
      doc = SolrDocument.find(organization_id)
      qry = "media_organization_id_ssim:#{organization_id} OR media_device_facility_organization_id_ssim:#{organization_id}"
      if doc['team_id_tesim'].present?
        qry += " OR member_of_team_ids_ssim:#{doc['team_id_tesim'].first}"
      end
      facet_fields = [
        "physical_object_id_tesim"
      ]
      params = {
        rows: 0,
        fq: [
          qry,
          "(has_model_ssim:Media)"
        ],
        "facet.limit": -1
      }
      solr.get_facet_fields(nil, facet_fields, params)
      facet_results = solr.facet_fields(facet_fields)
      return solr.count, facet_results["physical_object_id_tesim"].size
    end

    def total_media_and_po_by_collection(collection_id)
      facet_fields = [
        "physical_object_id_tesim"
      ]
      params = {
        fl: 'id',
        fq: [
          "member_of_collection_ids_ssim:#{collection_id}",
          "has_model_ssim:Media"
        ],
        "facet.limit": -1
      }
      solr.get_facet_fields(nil, facet_fields, params)
      facet_results = solr.facet_fields(facet_fields)
      return solr.count, facet_results["physical_object_id_tesim"].size
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
      facet_fields = [ 'media_physical_object_type_ssim' ]

      params = { fl: 'id' }
      solr.get_facet_fields("has_model_ssim:Media", facet_fields, params)
      return solr.facet_fields(facet_fields), solr.count
    end

    def total_bso
      params = { rows: 0 }
      solr.get("has_model_ssim:BiologicalSpecimen", params)
      solr.count
    end

    def total_cho
      params = { rows: 0 }
      solr.get("has_model_ssim:CulturalHeritageObject", params)
      solr.count
    end

    # ---  methods for media types and modality ---

    def media_type_and_modality_facets
      facet_fields = [
        Solrizer.solr_name("media_type", :symbol),
        "modality_ssim"
      ]
      params = { fl: 'id' }
      solr.get_facet_fields("has_model_ssim:Media", facet_fields, params)
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
