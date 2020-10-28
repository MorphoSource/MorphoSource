module Morphosource
  module Organizations
    class OrganizationMemberService
      include Blacklight::AccessControls::Catalog
      include Blacklight::Base
    
      attr_reader :solr

      def initialize
        @solr = solr_service.new
      end

#      def organization_facets
#        facet_fields = [
#          Solrizer.solr_name('organization_type', :facetable)
#        ]
#        params = {
#          fl: 'id',
#          fq: ["has_model_ssim:Organization"]
#        }
#        solr.get_facet_fields(nil, facet_fields, params)
#        return solr.facet_fields(facet_fields)
#      end

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
end