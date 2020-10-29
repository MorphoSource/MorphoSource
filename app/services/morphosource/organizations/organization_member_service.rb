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

      def bso_docs(org)
        bso_ids = bso_ids_by_org(org)
        return [] if !bso_ids.present?

        params = { 
#          fl: ['id', solrize('title', :stored_searchable), solrize('member_ids', :symbol)].join(','),
          fq: [
            assemble_or_query('id', bso_ids)
          ]
        }

        docs = solr.get_docs(nil, params)
        return docs
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

      def bso_ids_by_org(org)
        return [] unless org.member_ids.present?
        return bso_ids & org.member_ids
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