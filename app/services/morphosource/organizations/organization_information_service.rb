module Morphosource
  module Organizations
    class OrganizationInformationService
      include SolrHelper

      # Returns derived information about collection (counts, media/category, etc.) with fast solr searches

      attr_reader :scope, :solr, :facet_results, :media_count, :physical_object_ids,
        :bso_ids, :cho_ids, :n_idigbio, :info
      delegate :blacklight_config, to: :scope

      SORTABLE_TITLE_FIELD = ActiveFedora.index_field_mapper.solr_name('title', :stored_sortable)

      def initialize(scope, org)
        @solr = solr_service.new
        @scope = scope
        @organization = org
        query_solr_org_info
      end

      def query_solr_org_info
        @facet_results, @media_count = media_facet_query_with_builder

        @physical_object_ids = facet_results['physical_object_id_tesim'].keys.map(&:upcase)
        @bso_ids = bso_ids
        @cho_ids = cho_ids
        @n_idigbio = bso_idigbio_count
      end

      def organization_information
        @info = {
          'counts' => {
            'media' => media_count,
            'po' => physical_object_ids.length
          },
          'organization_object_ids' => physical_object_ids
        }

        info['media_groups'] =  { 'organization' => {} }.merge(facet_media_groups) if media_count.present?
        info['bso_groups'] = { 'organization' => {} }.merge(bso_source_groups) if @bso_ids.present?
        info['cho_groups'] = { 'organization' => {} } if @cho_ids.present?
        info
      end

      def solrize_filter_params(params = {})
        params.map { |k, v| solrize_param(k, v) }.compact
      end

      private

        def bso_ids
          params = {
            fl: 'id',
            fq: [
              po_core_fq,
              "(has_model_ssim:BiologicalSpecimen)"
            ]
          }
          solr.get_docs(nil, params).map(&:values).flatten
        end

        def cho_ids
          params = {
            fl: 'id',
            fq: [
              po_core_fq,
              "(has_model_ssim:CulturalHeritageObject)"
            ]
          }
          solr.get_docs(nil, params).map(&:values).flatten
        end

        def po_core_fq
          if physical_object_ids.present? && @organization.organization_type&.first == "Scanning Facility"
            "(#{assemble_or_query('id', physical_object_ids)})"
          elsif physical_object_ids.present? && @organization.organization_type&.first == "Collection and Scanning Facility"
            "((#{assemble_or_query('id', physical_object_ids)}) OR (organization_id_ssim:#{@organization.id}))"
          else
            "(organization_id_ssim:#{@organization.id})"
          end
        end


        ### Solr collection queries ###


        # Other solr queries #

        def media_facet_query
          facet_fields = [
            solrize('media_type', :stored_searchable),
            solrize('fileset_accessibility', :stored_searchable)
          ]
          params = {
            rows: 0,
            fq: [
              media_core_fq,
              "#{solrize('has_model', :symbol)}:Media",
            ],
            "facet.limit": -1
          }
          solr.get_facet_fields(nil, facet_fields, params)
          return solr.facet_fields(facet_fields), solr.count
        end

        def media_facet_query_with_builder
          facet_fields = [
            solrize('media_type', :stored_searchable),
            solrize('fileset_accessibility', :stored_searchable),
            solrize('physical_object_id', :stored_searchable),
          ]

          fq = [
            media_core_fq,
            "#{solrize('has_model', :symbol)}:Media",
          ]

          result = query_solr_with_fq(query_builder: works_search_builder, fq_params: fq, facet_fields: facet_fields)
          return facet_field_hash(result, facet_fields), result['response']['numFound'].to_i
        end

        def media_core_fq
          if @organization.organization_type&.first == "Scanning Facility"
            "(media_device_facility_organization_id_ssim:#{@organization.id})"
          elsif @organization.organization_type&.first == "Collection and Scanning Facility"
            "(media_device_facility_organization_id_ssim:#{@organization.id}) OR (media_organization_id_ssim:#{@organization.id})"
          else
            "(media_organization_id_ssim:#{@organization.id})"
          end
        end

        def query_solr_with_fq(query_builder:, fq_params:, facet_fields:)
          initial_fq = query_builder[:fq]
          initial_facet_fields = query_builder["facet.field"]
          initial_rows = query_builder[:rows]
          begin
            query_builder.merge(fq: initial_fq + fq_params)
            query_builder.merge('facet.field' => initial_facet_fields + facet_fields)
            query_builder.merge('facet.limit' => -1)
            query_builder.merge(rows: 99999)
            #repository.search(query_builder.with(query_params).query)
            blacklight_config.repository.search(query_builder.query)
          ensure
            query_builder.merge(fq: initial_fq)
            query_builder.merge('facet.field' => initial_facet_fields)
            query_builder.merge('facet.limit' => -1)
            query_builder.merge(rows: initial_rows)
          end
        end

        def works_search_builder
          @works_search_builder ||= Hyrax::OrganizationMemberSearchBuilder.new(scope: @scope, search_includes_models: :works)
        end

        def facet_field_hash(result, field_names)
          if result.present? and result["facet_counts"]["facet_fields"].present?
            facet_hash = {}
            facet_result = result["facet_counts"]["facet_fields"]
            field_names.each do |f|
              facet_hash[f] = Hash[*facet_result[f].flatten(1)] if facet_result.key?(f)
            end
            facet_hash
          else
            {}
          end
        end

        def bso_idigbio_count
          return 0 if !@bso_ids.present?
          params = {
            rows: 0,
            fq: [
              assemble_or_query('id', @bso_ids.map { |id| prepare_value(id) } ),
              "#{solrize('idigbio_uuid', :stored_searchable)}:*"
            ]
          }
          solr.get(nil, params)
          solr.count
        end


        ### Collection information parsing ###

        # Convert solr facet results to media groups
        def facet_media_groups
          facet_results.map do |key, value|
            clean_key = desolrize(key)
            case clean_key
            when 'media_type'
              [ clean_key, value.transform_keys { |k| map_media_type(k) } ]
            when 'member_of_collection_ids'
              [
                'project',
                value.
                  map { |sub_k, sub_v| [collection_project_map[sub_k], sub_v] if collection_project_map.include? sub_k }.
                  compact.
                  to_h
              ]
            when 'physical_object_id'
              nil
            else
              [ clean_key, value ]
            end
          end.compact.to_h
        end

        def map_media_type(t)
          case t
            when 'ctimagesery' then 'CTImageSeries'
            when 'photogrammetryimagesery' then 'PhotogrammetryImageSeries'
            else t.titleize
          end
        end

        def bso_source_groups
          if n_idigbio.present?
            { 'source' => {
              'idigbio' => n_idigbio,
              'user' => bso_ids.length - n_idigbio
            } }
          else
            {}
          end
        end

        ### Collection solrize filter params ###

        def solrize_param(name, value)
          case name
          when 'm_pub_status'
            "#{solrize('fileset_accessibility', :stored_searchable)}:#{value}"
          when 'm_organization'
            assemble_or_query(
              solrize('physical_object_id', :stored_searchable),
              po_ids_by_collection_organization(value)
            )
          when 'b_source'
            if value == 'idigbio'
              "#{solrize('idigbio_uuid', :stored_searchable)}:*"
            elsif value == 'user'
              "-#{solrize('idigbio_uuid', :stored_searchable)}:*"
            end
          else
            "#{solrize(name.split('_', 2).last, :stored_searchable)}:#{value}"
          end
        end
    end
  end
end
