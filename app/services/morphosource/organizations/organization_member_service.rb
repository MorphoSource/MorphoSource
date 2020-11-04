module Morphosource
  module Organizations
    class OrganizationMemberService
      include Blacklight::AccessControls::Catalog
      include Blacklight::Base
    
      attr_reader :solr

      copy_blacklight_config_from(::CatalogController)

      def initialize(scope:, organization:, params:)
        @solr = solr_service.new
        @scope = scope
        @organization = organization
        @params = params

#        @bso_ids = bso_ids
#        @cho_ids = cho_ids
        @po_ids = po_ids
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


      def member_media(fq_params = [])
        return [] unless po_ids.present?
        core_fq = "(physical_object_id_tesim:(#{po_ids.join(' OR ')}))"
        core_fq += " AND (has_model_ssim:Media)"
        fq_params << core_fq 
        available_member_works_filter_query(fq_params: fq_params)
      end

      def member_bso(fq_params = [])
        return [] if !bso_ids.present?
        core_fq = "(id:(#{bso_ids.join(' OR ')}))"
        fq_params << core_fq 
        available_member_works_filter_query(fq_params: fq_params)
      end

      def member_cho(fq_params = [])
        return [] if !cho_ids.present?
        core_fq = "(id:(#{cho_ids.join(' OR ')}))"
        fq_params << core_fq 
        available_member_works_filter_query(fq_params: fq_params)
      end
  
      def po_ids
        return bso_ids + cho_ids
      end

      def po_type
        @po_type ||= get_po_type
      end

      def get_po_type
        if bso_ids.length > 0
          'bso'
        else
          ''
        end
      end

      def bso_ids
        @bso_ids ||= bso_ids_by_org
      end

      def all_bso_ids
        params = {
          fl: 'id',
          fq: [
            "(has_model_ssim:BiologicalSpecimen)"
          ]
        }
        return solr.get_docs(nil, params).map(&:values).flatten
      end

      def bso_ids_by_org
        return [] unless @organization.member_ids.present?
        return all_bso_ids & @organization.member_ids
      end

      def cho_ids
        @cho_ids ||= cho_ids_by_org
      end

      def all_cho_ids
        params = {
          fl: 'id',
          fq: [
            "(has_model_ssim:CulturalHeritageObject)"
          ]
        }
        return solr.get_docs(nil, params).map(&:values).flatten
      end

      def cho_ids_by_org
        return [] unless @organization.member_ids.present?
        return all_cho_ids & @organization.member_ids
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

        def available_member_works_filter_query(fq_params: [])
          query_solr_with_fq(query_builder: works_search_builder, query_params: @params[:cq], fq_params: fq_params)
        end

        def query_solr_with_fq(query_builder:, query_params:, fq_params:)
          initial_q = query_builder[:q]
          initial_fq = query_builder[:fq]
          initial_rows = query_builder[:rows]
          begin
            query_builder.merge(q: query_params)
            query_builder.merge(fq: fq_params)
            query_builder.merge(rows: 99999)
            #repository.search(query_builder.with(query_params).query)
            repository.search(query_builder.query)
          ensure
            query_builder.merge(q: initial_q)
            query_builder.merge(fq: initial_fq)
            query_builder.merge(rows: initial_rows)
          end
        end

        def works_search_builder
          @works_search_builder ||= Hyrax::OrganizationMemberSearchBuilder.new(scope: @scope, search_includes_models: :works)
        end
  
        def solr_service
          Morphosource::SolrService
        end


        #def search_solr(qry)
        #  ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{SORTABLE_TITLE_FIELD} ASC")
        #end
    end

  end
end