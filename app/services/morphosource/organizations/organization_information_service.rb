module Morphosource
  module Organizations
    class OrganizationInformationService
      # Returns derived information about collection (counts, media/category, etc.) with fast solr searches
    
      attr_reader :solr, :collection_id, :collection, :is_org_team, 
        :collection_organization_id, :team_org_po_ids, :n_media_team_organization,
        :facet_results, :media_count, :physical_object_ids, :bso_ids, :cho_ids,
        :n_idigbio, :collection_project_map, :organizations, :info, :subcollection_ids

      SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

      def initialize(org_id, po_ids)
        @solr = solr_service.new
        @organization = Organization.find(org_id)
        @physical_object_ids = po_ids
        query_solr_org_info
      end

      def query_solr_org_info

        @facet_results, @media_count = media_facet_query

        @bso_ids = po_ids_by_model(physical_object_ids, BiologicalSpecimen)          
        @cho_ids = po_ids_by_model(physical_object_ids, CulturalHeritageObject) 
        @n_idigbio = bso_idigbio_count
      end

      def organization_information
        @info = { 
          'counts' => {
            'media' => media_count,
            'po' => physical_object_ids.length
          }
        }

        info['media_groups'] =  { 'organization' => {} }.merge(facet_media_groups) if media_count.present?
        info['bso_groups'] = { 'organization' => {} }.merge(bso_source_groups) if bso_ids.present?
        info['cho_groups'] = { 'organization' => {} } if cho_ids.present?

        info     
      end

      def solrize_filter_params(params = {})
        params.map { |k, v| solrize_param(k, v) }.compact
      end


      private

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
              "#{solrize('has_model', :symbol)}:Media",
            ]
          }

          # Core query
          params[:fq] << assemble_or_query(solrize('physical_object_id', :stored_searchable), @physical_object_ids)
          solr.get_facet_fields(nil, facet_fields, params)

          return solr.facet_fields(facet_fields), solr.count
        end

        def bso_idigbio_count
          return 0 if !bso_ids.present?

          params = {
            rows: 0,
            fq: [
              assemble_or_query('id', bso_ids.map { |id| prepare_value(id) } ),
              "#{solrize('idigbio_uuid', :stored_searchable)}:*"
            ] 
          }

          solr.get(nil, params)
          solr.count
        end

        def po_ids_by_model(po_ids, model)
          return [] if !po_ids.present?

          params = {
            fl: 'id',
            fq: [
              assemble_or_query('id', po_ids),
              "#{solrize('has_model', :symbol)}:#{model}"
            ]
          }

          solr.get_docs(nil, params).map(&:values).flatten
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
