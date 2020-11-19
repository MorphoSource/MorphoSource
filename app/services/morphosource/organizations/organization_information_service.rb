module Morphosource
  module Organizations
    class OrganizationInformationService
      # Returns derived information about collection (counts, media/category, etc.) with fast solr searches
    
      attr_reader :solr, :facet_results, :media_count, :bso_ids, :cho_ids, :n_idigbio, :info

      SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

      def initialize(org)
        @solr = solr_service.new
        @organization = org
        @bso_ids = bso_ids
        @cho_ids = cho_ids
        query_solr_org_info
      end

      def query_solr_org_info
        @facet_results, @media_count = media_facet_query
        @n_idigbio = bso_idigbio_count
      end

      def organization_information
        @info = { 
          'counts' => {
            'media' => media_count,
            'po' => bso_ids.length + cho_ids.length
          }
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
              "(organization_id_ssim:#{@organization.id})",
              "(has_model_ssim:BiologicalSpecimen)"
            ]
          }
          solr.get_docs(nil, params).map(&:values).flatten
        end

        def cho_ids
          params = {
            fl: 'id',
            fq: [
              "(organization_id_ssim:#{@organization.id})",
              "(has_model_ssim:CulturalHeritageObject)"
            ]
          }
          solr.get_docs(nil, params).map(&:values).flatten
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
              "(media_organization_id_ssim:#{@organization.id})",
              "#{solrize('has_model', :symbol)}:Media",
            ]
          }
          solr.get_facet_fields(nil, facet_fields, params)
          return solr.facet_fields(facet_fields), solr.count
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


        ### Solr utility methods ###

        def solr_service
          Morphosource::SolrService
        end

        def solrize(name, type)
          Solrizer.solr_name(name, type)
        end

        def desolrize(name)
          name[0...name.rindex('_')]
        end

        def assemble_or_query(field, values)
          return "" if !field.present? || !values.present?
          field + ':(' + values.join(' OR ').upcase + ')'
        end

        def assemble_query
          query_clauses = [ model_clause ] + param_clauses
          query_clauses.join(' AND ')
        end

        def model_clause
          "#{Solrizer.solr_name('has_model', :symbol)}:Taxonomy"
        end

        def param_clauses
          clauses = []
          params.each do |k,v|
            term_type = ( k == 'member_ids' ? :symbol : :stored_searchable )
            clauses << "#{Solrizer.solr_name(k, term_type)}:#{prepare_value(v)}"
          end
          clauses
        end

        def prepare_value(v)
          if v.to_s.include? " "
            "\"#{v}\""
          else
            v
          end
        end

        def search_solr(qry)
          ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{SORTABLE_TITLE_FIELD} ASC")
        end
    end
  end
end
