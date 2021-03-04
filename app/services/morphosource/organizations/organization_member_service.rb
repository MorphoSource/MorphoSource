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
      end

      def member_media(fq_params = [])
        core_fq = "(media_organization_id_ssim:#{@organization.id})"
        core_fq += " AND (has_model_ssim:Media)"
        fq_params << core_fq 
        available_member_works_filter_query(fq_params: fq_params)
      end

      def member_bso(fq_params = [])
        @member_bso ||= (
          core_fq = "(organization_id_ssim:#{@organization.id})"
          core_fq += " AND (has_model_ssim:BiologicalSpecimen)"
          fq_params << core_fq 
          available_member_works_filter_query(fq_params: fq_params, object_model: BiologicalSpecimen)
        )
      end

      def member_cho(fq_params = [])
        @member_cho ||= (
          core_fq = "(organization_id_ssim:#{@organization.id})"
          core_fq += " AND (has_model_ssim:CulturalHeritageObject)"
          fq_params << core_fq 
          available_member_works_filter_query(fq_params: fq_params, object_model: CulturalHeritageObject)
        )
      end
  
#      def bso_ids
#        return [] unless @member_bso.present?
#        @bso_ids ||= (
#          @member_bso.documents.map { |o| o.id }
#        )
#      end
#
#      def cho_ids
#        return [] unless @cho_ids.present?
#        @cho_ids ||= (
#          @member_cho.documents.map { |o| o.id }
#        )
#      end

      def assemble_or_query(field, values)
        return "" if !field.present? || !values.present?
        field + ':(' + values.join(' OR ').upcase + ')'
      end


      private

        def available_member_works_filter_query(fq_params: [], object_model: nil)
          query_solr_with_fq(
            query_builder: works_search_builder, 
            query_params: @params[:cq], 
            fq_params: fq_params,
            rows: (rows = rows_param(object_model)), 
            start: start_param(rows)
          )
        end  

        def query_solr_with_fq(query_builder:, query_params:, fq_params:, rows: 10, start: 0)
          initial_q = query_builder[:q]
          initial_fq = query_builder[:fq]
          initial_rows = query_builder.rows
          initial_start = query_builder.start
          begin
            query_builder.merge(q: query_params)
            query_builder.merge(fq: initial_fq + fq_params)
            query_builder.rows = rows
            query_builder.start = start
            repository.search(query_builder.query)
          ensure
            query_builder.merge(q: initial_q)
            query_builder.merge(fq: initial_fq)
            query_builder.rows = initial_rows
            query_builder.start = initial_start
          end
        end

        def works_search_builder
          @works_search_builder ||= Hyrax::OrganizationMemberSearchBuilder.new(scope: @scope, search_includes_models: :works)
        end

        # @api private
        #
        def rows_param(object_model = nil)
          case object_model.to_s
            when "BiologicalSpecimen"
              rows = @params[:brows]
            when "CulturalHeritageObject"
              rows = @params[:crows]
            else
              rows = @params[:rows]
            end
          rows.presence || Hyrax.config.teams_show_work_item_rows
        end

        # @api private
        #
        def start_param(rows = 10)
          page = @params[:page].presence || 1
          ((page.to_i - 1) * rows.to_i).to_s
        end
  
        def solr_service
          Morphosource::SolrService
        end
    end
  end
end