module Morphosource
  module Collections
    class CollectionInformationService
      include CollectionInformationHelper
      include SolrHelper
      # Returns derived information about collection (counts, media/category, etc.) with fast solr searches
    
      attr_reader :solr, :scope, :collection_id, :collection, :is_org_team, 
        :collection_organization_id, :team_org_po_ids, :n_media_team_organization, :n_media_team,
        :facet_results, :media_count, :physical_object_ids, :bso_ids, :cho_ids,
        :n_idigbio, :collection_project_map, :po_counts_by_org, 
        :organizations, :info, :subcollection_ids
      delegate :repository, to: :scope

      SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

      def self.call(scope:, collection_id:)
        new(scope, collection_id).call
      end

      def initialize(scope:, collection_id:)
        @solr = solr_service.new
        @scope = scope
        @collection_id = collection_id
        @collection = Collection.find(collection_id)
        @is_org_team = collection.team?

        query_solr_collection_info
      end

      def call
        collection_information
      end

      def query_solr_collection_info
        if is_org_team && Collection.find(collection_id).organization.present?
          @collection_organization_id = Collection.find(collection_id).organization.id
          @team_org_po_ids = organization_po_ids
          if is_org_team
            @n_media_team = team_origin_count 
            @n_media_team_organization = team_org_origin_count
          end
        end

        @facet_results, @media_count = media_facet_query_with_builder

        @physical_object_ids = facet_results['physical_object_id_tesim'].keys.map(&:upcase)
        @bso_ids = po_ids_by_model(physical_object_ids, BiologicalSpecimen)          
        @cho_ids = po_ids_by_model(physical_object_ids, CulturalHeritageObject) 
        @n_idigbio = bso_idigbio_count

        @po_counts_by_org = physical_object_counts_by_organization
        @organizations = organization_docs

        if collection.team?
          @collection_project_map = collection_id_to_project_title_map 
        end
      end

      def collection_information
        @info = { 
          'counts' => {
            'media' => media_count,
            'po' => physical_object_ids.length,
            'bso' => bso_ids.length,
            'cho' => cho_ids.length
          },
          'collection_object_ids' => physical_object_ids
        }

        info['media_groups'] =  { 'organization' => {} }.merge(facet_media_groups) if media_count.present?
        info['bso_groups'] = { 'organization' => {} }.merge(bso_source_groups) if bso_ids.present?
        info['cho_groups'] = { 'organization' => {} } if cho_ids.present?

        info_po_media_counts_by_organization
        
        if is_org_team && collection_organization_id.present?
          info['media_groups']['origin'] = {
            'team_organization' => n_media_team_organization,
            'team_collection' => n_media_team
          }

          if bso_ids.present? && team_org_po_ids.present?
            team_bso_ids = team_org_po_ids.select { |x| bso_ids.include? x }
            info['bso_groups']['origin'] = {
              'team_organization' => team_bso_ids.length,
              'team_collection' => bso_ids.length - team_bso_ids.length
            }
          end

          if cho_ids.present? && team_org_po_ids.present?
            team_cho_ids = team_org_po_ids.select { |x| cho_ids.include? x }
            info['cho_groups']['origin'] = {
              'team_organization' => team_cho_ids.length,
              'team_collection' => cho_ids.length - team_cho_ids.length
            }
          end

          if team_org_po_ids.present?
            info['organization_object_ids'] = team_org_po_ids
          end
        end

        info     
      end

      def solrize_filter_params(params = {})
        params.map { |k, v| solrize_param(k, v) }.compact
      end

      def subcollection_ids
        @subcollection_ids ||= get_subcollection_ids(collection_id)
      end

      private
        ### Solr collection queries ###
      
        # Other solr queries #

        def media_facet_query
          if collection.team?
            facet_fields = [
              solrize('media_type', :stored_searchable),
              solrize('fileset_accessibility', :stored_searchable),
              solrize('physical_object_id', :stored_searchable),
              solrize('media_organization_id', :symbol),
              solrize('member_of_collection_ids', :symbol)
            ]
          else
            facet_fields = [
              solrize('media_type', :stored_searchable),
              solrize('fileset_accessibility', :stored_searchable),
              solrize('physical_object_id', :stored_searchable),
              solrize('media_organization_id', :symbol)
            ]
          end          
          params = { 
            rows: 0,
            fq: [
              "#{solrize('has_model', :symbol)}:Media",
            ],
            "facet.limit": -1
          }

          # Core query
          if is_org_team && collection_organization_id
            params[:fq] << assemble_po_id_or_collection_query(team_org_po_ids, Array(collection_id) + Array(subcollection_ids))
          elsif collection.collection_type.nestable?
            params[:fq] << assemble_or_query(solrize('member_of_collection_ids', :symbol), Array(collection_id) + Array(subcollection_ids))
          else
            params[:fq] << "#{solrize('member_of_collection_ids', :symbol)}:#{collection_id}"
          end
          solr.get_facet_fields(nil, facet_fields, params)
          return solr.facet_fields(facet_fields), solr.count
        end

        def media_facet_query_with_builder
          if collection.team?
            facet_fields = [
              solrize('media_type', :stored_searchable),
              solrize('fileset_accessibility', :stored_searchable),
              solrize('physical_object_id', :stored_searchable),
              solrize('media_organization_id', :symbol),
              solrize('member_of_collection_ids', :symbol)
            ]
          else
            facet_fields = [
              solrize('media_type', :stored_searchable),
              solrize('fileset_accessibility', :stored_searchable),
              solrize('physical_object_id', :stored_searchable),
              solrize('media_organization_id', :symbol)
            ]
          end

          fq =  [ "#{solrize('has_model', :symbol)}:Media" ]         

          # Core query
          if is_org_team && collection_organization_id
            core_fq = assemble_po_id_or_collection_query(team_org_po_ids, Array(collection_id) + Array(subcollection_ids))
          elsif collection.collection_type.nestable?
            core_fq = assemble_or_query(solrize('member_of_collection_ids', :symbol), Array(collection_id) + Array(subcollection_ids))
          else
            core_fq = "#{solrize('member_of_collection_ids', :symbol)}:#{collection_id}"
          end

          result = query_solr_for_media_with_fq(query_builder: works_search_builder, fq_params: fq, core_fq: core_fq, facet_fields: facet_fields)
          return facet_field_hash(result, facet_fields), result['response']['numFound'].to_i
        end

        def query_solr_for_media_with_fq(query_builder:, fq_params:, core_fq:, facet_fields:)
          initial_fq = query_builder[:fq]
          initial_facet_fields = query_builder["facet.field"]
          initial_rows = query_builder[:rows]
          begin
            query_builder.merge(fq: prepare_media_query_fq_param(initial_fq, fq_params, core_fq))
            query_builder.merge('facet.field' => initial_facet_fields + facet_fields)
            query_builder.merge('facet.limit' => -1)
            query_builder.merge(rows: 999999)
            # repository.search(query_builder.with(query_params).query)
            repository.search(query_builder.query)
          ensure
            query_builder.merge(fq: initial_fq)
            query_builder.merge('facet.field' => initial_facet_fields)
            query_builder.merge('facet.limit' => -1)
            query_builder.merge(rows: initial_rows)
          end
        end

        def works_search_builder
          @works_search_builder ||= 
            Morphosource::CollectionMemberSearchBuilderNoFacetLimits.new(
              scope: scope, collection: collection, search_includes_models: :works
            )
        end

        def prepare_media_query_fq_param(initial, new, new_core)
          ((initial.map { |x| x == std_core_fq && new_core.present? ? new_core : x }) + new).uniq
        end

        def std_core_fq
          "#{Solrizer.solr_name('member_of_collection_ids', :symbol)}:#{collection.id}"
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

        def collection_id_to_project_title_map
          return {} if !facet_results[solrize('member_of_collection_ids', :symbol)].present?

          collection_ids = facet_results[solrize('member_of_collection_ids', :symbol)].keys
          solr.get_docs(query = nil, params = { fq: assemble_or_query('id', collection_ids)} ).
            select { |d| is_project? d['collection_type_gid_ssim']&.first }.
            map { |d| [ d['id'], d[ solrize('title', :stored_searchable) ]&.first ] }.
            to_h
        end

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

        ### Collection solrize filter params ###

        def team_or_team_project_ids(coll_id)
          # the team id + any team project id
          ids = [coll_id]
          if Collection.find(collection_id).child_projects
            ids << Collection.find(collection_id).child_projects.first.id    
          end
          return ids
        end

        def solrize_param(name, value)
          case name
          when 'm_pub_status'
            "#{solrize('fileset_accessibility', :stored_searchable)}:#{value}"
          when 'm_organization'
            assemble_or_query(
              solrize('physical_object_id', :stored_searchable), 
              po_ids_by_collection_organization(value)
            )
          when 'm_origin'
            if value == 'team_collection'
              assemble_or_query(
                "#{solrize('member_of_collection_ids', :symbol)}",
                team_or_team_project_ids(collection_id)
              )
            elsif value == 'team_organization' && Collection.find(collection_id).organization.present?
              organization_title = Collection.find(collection_id).organization.title&.first
              assemble_po_id_including_collection_query(
                po_ids_by_collection_organization(organization_title)
              )
            end
          when 'b_source'
            if value == 'idigbio'
              "#{solrize('idigbio_uuid', :stored_searchable)}:*"
            elsif value == 'user'
              "-#{solrize('idigbio_uuid', :stored_searchable)}:*"
            end
          when 'b_organization', 'c_organization'
            assemble_or_query(
              'id', 
              po_ids_by_collection_organization(value)
            )
          when 'b_origin', 'c_origin'
            if Collection.find(collection_id).organization.present?
              organization_title = Collection.find(collection_id).organization.title&.first
              organization_po_query = assemble_or_query(
                'id', 
                po_ids_by_collection_organization(organization_title)
              )

              if value == 'team_collection'
                '-' + organization_po_query
              elsif value == 'team_organization'
                organization_po_query
              end
            end
          else
            "#{solrize(name.split('_', 2).last, :stored_searchable)}:#{value}"
          end
        end
    end
  end
end
